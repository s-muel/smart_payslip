import 'package:shared_preferences/shared_preferences.dart';
import '../models/smtp_settings.dart';

class SettingsService {
  static const _smtpHostKey = 'smtp_host';
  static const _smtpPortKey = 'smtp_port';
  static const _smtpSslKey = 'smtp_ssl';
  //static const _smtpAllowInsecureKey = 'smtp_allow_insecure';
  static const _senderEmailKey = 'sender_email';
  static const _senderPasswordKey = 'sender_password';
  static const _senderNameKey = 'sender_name';
  static const _emailSubjectKey = 'email_subject';

  Future<SmtpSettings> loadSmtpSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = SmtpSettings.defaults();

    return SmtpSettings(
      smtpHost: prefs.getString(_smtpHostKey) ?? defaults.smtpHost,
      smtpPort: prefs.getInt(_smtpPortKey) ?? defaults.smtpPort,
      smtpSsl: prefs.getBool(_smtpSslKey) ?? defaults.smtpSsl,
     // smtpAllowInsecure:
       //   prefs.getBool(_smtpAllowInsecureKey) ?? defaults.smtpAllowInsecure,
      senderEmail: prefs.getString(_senderEmailKey) ?? defaults.senderEmail,
      senderPassword:
          prefs.getString(_senderPasswordKey) ?? defaults.senderPassword,
      senderName: prefs.getString(_senderNameKey) ?? defaults.senderName,
      // emailSubject:
      //     prefs.getString(_emailSubjectKey) ?? defaults.emailSubject,
    );
  }

  Future<void> saveSmtpSettings(SmtpSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_smtpHostKey, settings.smtpHost);
    await prefs.setInt(_smtpPortKey, settings.smtpPort);
    await prefs.setBool(_smtpSslKey, settings.smtpSsl);
    // await prefs.setBool(
    //   _smtpAllowInsecureKey,
    //  settings.smtpAllowInsecure,
    // );
    await prefs.setString(_senderEmailKey, settings.senderEmail);
    await prefs.setString(_senderPasswordKey, settings.senderPassword);
    await prefs.setString(_senderNameKey, settings.senderName);
   // await prefs.setString(_emailSubjectKey, settings.emailSubject);
  }
}
