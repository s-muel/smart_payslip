import 'package:flutter/material.dart';

class SplitMatchScreen extends StatelessWidget {
  final int? pdfPageCount;
  final int? excelRowCount;
  final String splitMethod;
  final ValueChanged<String> onSplitMethodChanged;
  final VoidCallback onBack;
  final VoidCallback? onStartMatching;

  const SplitMatchScreen({
    super.key,
    required this.pdfPageCount,
    required this.excelRowCount,
    required this.splitMethod,
    required this.onSplitMethodChanged,
    required this.onBack,
    required this.onStartMatching,
  });

  @override
  Widget build(BuildContext context) {
    final int pdfCount = pdfPageCount ?? 0;
    final int employeeCount = excelRowCount ?? 0;
    final int difference = pdfCount - employeeCount;

// This logic determines if the system is ready to proceed based on whether the PDF page count matches the employee record count. The matching criteria can be adjusted based on the selected split method, but for simplicity, this example assumes a direct 1:1 relationship.
    final bool isReady = pdfPageCount != null &&
        excelRowCount != null &&
        pdfPageCount == excelRowCount;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Split & Match',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review the uploaded files and confirm how the combined PDF should be split.',
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
                  title: 'PDF Pages',
                  value: pdfPageCount?.toString() ?? '-',
                  icon: Icons.picture_as_pdf_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Employee Records',
                  value: excelRowCount?.toString() ?? '-',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Difference',
                  value: (pdfPageCount != null && excelRowCount != null)
                      ? difference.toString()
                      : '-',
                  icon: Icons.compare_arrows_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSplitMethodCard(),
          const SizedBox(height: 24),
          _buildValidationCard(isReady, pdfCount, employeeCount),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onStartMatching,
                child: Text(
                  (pdfPageCount != null &&
                          excelRowCount != null &&
                          pdfPageCount != excelRowCount)
                      ? 'Continue Anyway'
                      : 'Start Matching',
                ),
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

  Widget _buildSplitMethodCard() {
    return Container(
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
            'Split Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            value: 'one_page',
            groupValue: splitMethod,
            onChanged: (value) {
              if (value != null) {
                onSplitMethodChanged(value);
              }
            },
            title: const Text('1 page per employee'),
            subtitle: const Text(
              'Use this when each payslip is exactly one page.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            value: 'fixed_pages',
            groupValue: splitMethod,
            onChanged: (value) {
              if (value != null) {
                onSplitMethodChanged(value);
              }
            },
            title: const Text('Fixed pages per employee'),
            subtitle: const Text(
              'Use this when each payslip has the same number of pages.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(bool isReady, int pdfCount, int employeeCount) {
    final bool hasCounts = pdfPageCount != null && excelRowCount != null;
    final bool isMismatch = hasCounts && pdfCount != employeeCount;

    return Container(
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
      child: Row(
        children: [
          Icon(
            isReady
                ? Icons.check_circle
                : isMismatch
                    ? Icons.warning_amber_rounded
                    : Icons.error,
            color: isReady
                ? Colors.green
                : isMismatch
                    ? Colors.orange
                    : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isReady
                  ? 'PDF pages and employee records match. The system is ready for the next step.'
                  : isMismatch
                      ? 'Mismatch detected: PDF pages = $pdfCount, employee records = $employeeCount. You can still continue, but some payslips may remain unmatched.'
                      : 'Required file information is missing. Please return and confirm the uploaded files.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
