class SmtpSettings {
  final String smtpHost;
  final int smtpPort;
  final bool smtpSsl;
  //final bool smtpAllowInsecure;
  final String senderEmail;
  final String senderPassword;
  final String senderName;
  //final String emailSubject;

  const SmtpSettings({
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSsl,
   // required this.smtpAllowInsecure,
    required this.senderEmail,
    required this.senderPassword,
    required this.senderName,
  //  required this.emailSubject,
  });

  factory SmtpSettings.defaults() {
    return const SmtpSettings(
      smtpHost: 'mail.bajfreight.com',
      smtpPort: 465,
      smtpSsl: true,
     // smtpAllowInsecure: false,
      senderEmail: '',
      senderPassword: '',
      senderName: '',
    //  emailSubject: 'Your Payslip',
    );
  }
}
