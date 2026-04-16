class SendReportItem {
  final String employeeNumber;
  final String email;
  final String status;
  final String details;

  SendReportItem({
    required this.employeeNumber,
    required this.email,
    required this.status,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeNumber': employeeNumber,
      'email': email,
      'status': status,
      'details': details,
    };
  }

  factory SendReportItem.fromMap(Map<String, dynamic> map) {
    return SendReportItem(
      employeeNumber: map['employeeNumber'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      details: map['details'] ?? '',
    );
  }
}

class SendReport {
  final String subject;
  final String senderEmail;
  final DateTime sentAt;
  final List<SendReportItem> items;

  SendReport({
    required this.subject,
    required this.senderEmail,
    required this.sentAt,
    required this.items,
  });

  int get sentCount => items.where((item) => item.status == 'Sent').length;
  int get failedCount => items.where((item) => item.status == 'Failed').length;
  int get skippedCount =>
      items.where((item) => item.status == 'Skipped').length;

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'senderEmail': senderEmail,
      'sentAt': sentAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory SendReport.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['items'] as List<dynamic>? ?? []);

    return SendReport(
      subject: map['subject'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      sentAt: DateTime.tryParse(map['sentAt'] ?? '') ?? DateTime.now(),
      items: rawItems
          .map((item) => SendReportItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
