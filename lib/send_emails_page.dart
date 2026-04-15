import 'package:flutter/material.dart';
import 'models/preview_match_item.dart';

class SendEmailsPage extends StatefulWidget {
  final List<PreviewMatchItem> matchItems;
  final String senderEmail;
  final String initialSubject;
  final Future<void> Function(String subject) onSend;
  final VoidCallback onBack;

  const SendEmailsPage({
    super.key,
    required this.matchItems,
    required this.senderEmail,
    required this.initialSubject,
    required this.onSend,
    required this.onBack,
  });

  @override
  State<SendEmailsPage> createState() => _SendEmailsPageState();
}

class _SendEmailsPageState extends State<SendEmailsPage> {
  late final TextEditingController _subjectController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.initialSubject);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final subject = _subjectController.text.trim();

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the email subject.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    await widget.onSend(subject);

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchedCount =
        widget.matchItems.where((item) => item.status == 'Matched').length;
    final noEmailCount =
        widget.matchItems.where((item) => item.status == 'No Email').length;
    final unmatchedCount = widget.matchItems
        .where((item) => item.status == 'Unmatched' || item.status == 'No Employee Number')
        .length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Emails',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review the sending summary and enter the subject for this payslip batch.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Matched',
                  value: matchedCount.toString(),
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'No Email',
                  value: noEmailCount.toString(),
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Unmatched',
                  value: unmatchedCount.toString(),
                  icon: Icons.error_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sender: ${widget.senderEmail.isEmpty ? '-' : widget.senderEmail}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Email Subject',
                    hintText: 'March 2026 Payslip',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Employee No',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: widget.matchItems.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final item = widget.matchItems[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item.employeeNumber),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item.employeeName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.employeeEmail,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildStatusChip(item.status),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSending ? null : widget.onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSending ? null : _handleSend,
                child: Text(_isSending ? 'Sending...' : 'Send Payslips'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isMatched = status == 'Matched';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isMatched ? Colors.green.shade800 : Colors.orange.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
