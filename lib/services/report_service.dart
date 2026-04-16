import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/send_report.dart';
import 'email_service.dart';

class ReportService {
  static const _reportsKey = 'send_reports';

  Future<List<SendReport>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_reportsKey);

    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(rawJson);

    return decoded
        .map((item) => SendReport.fromMap(Map<String, dynamic>.from(item)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> saveReport({
    required String subject,
    required String senderEmail,
    required List<EmailSendResult> results,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReports = await loadReports();

    final report = SendReport(
      subject: subject,
      senderEmail: senderEmail,
      sentAt: DateTime.now(),
      items: results
          .map(
            (result) => SendReportItem(
              employeeNumber: result.employeeNumber,
              email: result.email,
              status: result.status,
              details: result.details,
            ),
          )
          .toList(),
    );

    final updatedReports = [report, ...existingReports];

    final encoded = jsonEncode(
      updatedReports.map((item) => item.toMap()).toList(),
    );

    await prefs.setString(_reportsKey, encoded);
  }
}
