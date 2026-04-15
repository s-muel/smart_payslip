import 'package:flutter/material.dart';
import 'models/smtp_settings.dart';

class SettingsPage extends StatefulWidget {
  final SmtpSettings initialSettings;
  final Future<void> Function(SmtpSettings settings) onSave;
  final VoidCallback onBack;

  const SettingsPage({
    super.key,
    required this.initialSettings,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;

  late bool _smtpSsl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hostController =
        TextEditingController(text: widget.initialSettings.smtpHost);
    _portController =
        TextEditingController(text: widget.initialSettings.smtpPort.toString());
    _emailController =
        TextEditingController(text: widget.initialSettings.senderEmail);
    _passwordController =
        TextEditingController(text: widget.initialSettings.senderPassword);
    _nameController =
        TextEditingController(text: widget.initialSettings.senderName);
    _smtpSsl = widget.initialSettings.smtpSsl;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final port = int.tryParse(_portController.text.trim());

    if (_hostController.text.trim().isEmpty ||
        port == null ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields correctly.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final settings = SmtpSettings(
      smtpHost: _hostController.text.trim(),
      smtpPort: port,
      smtpSsl: _smtpSsl,
      senderEmail: _emailController.text.trim(),
      senderPassword: _passwordController.text.trim(),
      senderName: _nameController.text.trim(),
    );

    await widget.onSave(settings);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SMTP settings saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Update the email settings used when sending payslips.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildTextField('SMTP Host', _hostController),
                const SizedBox(height: 16),
                _buildTextField(
                  'SMTP Port',
                  _portController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField('Sender Email', _emailController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Sender Password',
                  _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildTextField('Sender Name', _nameController),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use SSL'),
                  value: _smtpSsl,
                  onChanged: (value) {
                    setState(() {
                      _smtpSsl = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSaving ? null : widget.onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
