import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as p;
import '../models/preview_match_item.dart';

class EmailSendResult {
  final String employeeNumber;
  final String email;
  final String status;
  final String details;

  EmailSendResult({
    required this.employeeNumber,
    required this.email,
    required this.status,
    required this.details,
  });
}

class EmailService {
  Future<List<EmailSendResult>> sendMatchedPayslips({
    required String? sourcePdfPath,
    required List<PreviewMatchItem> matchItems,
    required String smtpHost,
    required int smtpPort,
    required String username,
    required String password,
    required String fromName,
    required String subject,
    bool ssl = false,
    bool allowInsecure = false,
    String outputFolderName = 'generated_payslips',
  }) async {
    if (sourcePdfPath == null) return [];

    final sourceFile = File(sourcePdfPath);
    if (!await sourceFile.exists()) return [];

    final sendableItems =
        matchItems.where((item) => item.status == 'Matched').toList();

    if (sendableItems.isEmpty) return [];

    final smtpServer = SmtpServer(
      smtpHost,
      port: smtpPort,
      username: username,
      password: password,
      ssl: ssl,
      allowInsecure: allowInsecure,
    );

    final connection = PersistentConnection(smtpServer);
    final List<EmailSendResult> results = [];

    try {
      for (final item in sendableItems) {
        final attachmentPath = p.join(
          sourceFile.parent.path,
          outputFolderName,
          '${_sanitizeFileName(item.employeeNumber)}_${_sanitizeFileName(item.employeeName)}.pdf',
        );

        final attachmentFile = File(attachmentPath);

        if (!await attachmentFile.exists()) {
          results.add(
            EmailSendResult(
              employeeNumber: item.employeeNumber,
              email: item.employeeEmail,
              status: 'Skipped',
              details: 'Attachment file not found.',
            ),
          );
          continue;
        }

        final message = Message()
          ..from = Address(username, fromName)
          ..recipients.add(item.employeeEmail)
          ..subject = subject
          ..text =
              'Hello ${item.employeeName},\n\nPlease find attached your payslip.\n\nRegards,'
          ..attachments = [
            FileAttachment(attachmentFile),
          ];

        try {
          await connection.send(message);

          results.add(
            EmailSendResult(
              employeeNumber: item.employeeNumber,
              email: item.employeeEmail,
              status: 'Sent',
              details: 'Email sent successfully.',
            ),
          );
        } on MailerException catch (e) {
          final details = e.problems.isEmpty
              ? e.toString()
              : e.problems.map((problem) {
                  return '${problem.code}: ${problem.msg}';
                }).join(', ');

          results.add(
            EmailSendResult(
              employeeNumber: item.employeeNumber,
              email: item.employeeEmail,
              status: 'Failed',
              details: details,
            ),
          );
        } catch (e) {
          results.add(
            EmailSendResult(
              employeeNumber: item.employeeNumber,
              email: item.employeeEmail,
              status: 'Failed',
              details: e.toString(),
            ),
          );
        }
      }
    } finally {
      await connection.close();
    }

    return results;
  }

  String _sanitizeFileName(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
