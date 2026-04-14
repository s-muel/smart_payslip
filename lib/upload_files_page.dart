import 'package:flutter/material.dart';

class UploadFilesScreen extends StatelessWidget {
  final String? selectedPdfFileName;
  final String? selectedExcelFileName;
  final int? pdfPageCount;
  final int? excelRowCount;
  final VoidCallback onPickPdf;
  final VoidCallback onPickExcel;
  final VoidCallback onBack;
  final VoidCallback? onContinue;

  const UploadFilesScreen({
    super.key,
    required this.selectedPdfFileName,
    required this.selectedExcelFileName,
    required this.pdfPageCount,
    required this.excelRowCount,
    required this.onPickPdf,
    required this.onPickExcel,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool pdfReady = selectedPdfFileName != null;
    final bool excelReady = selectedExcelFileName != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Files',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload the combined payslip PDF and the employee Excel file.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildUploadCard(
                  title: 'Combined Payslip PDF',
                  description:
                      'Upload the single PDF containing all employee payslips.',
                  icon: Icons.picture_as_pdf_outlined,
                  fileName: selectedPdfFileName ?? 'No PDF selected',
                  buttonText: 'Choose PDF',
                  onTap: onPickPdf,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildUploadCard(
                  title: 'Employee Data Excel File',
                  description:
                      'Upload the Excel file containing employee number and email.',
                  icon: Icons.table_chart_outlined,
                  fileName: selectedExcelFileName ?? 'No Excel file selected',
                  buttonText: 'Choose Excel File',
                  onTap: onPickExcel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildValidationPanel(pdfReady, excelReady),
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
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required String fileName,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 220,
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
          Icon(icon, size: 34, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          // const SizedBox(height: 16),
          // Text(fileName),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              style: TextStyle(fontSize: 13),
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          //const Spacer(),
          // const SizedBox(
          //   height: 15,
          //   child: Text('Upload'),
          // ),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_file),
              label: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationPanel(bool pdfReady, bool excelReady) {
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
            'Validation Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Payslip PDF', pdfReady),
          const SizedBox(height: 10),
          _buildStatusRow('Employee Excel File', excelReady),
          const SizedBox(height: 10),
          Text(
            'PDF Pages: ${pdfPageCount ?? '-'}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Employee Records: ${excelRowCount ?? '-'}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, bool isReady) {
    return Row(
      children: [
        Icon(
          isReady ? Icons.check_circle : Icons.cancel,
          color: isReady ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          '$title: ${isReady ? "Loaded" : "Not loaded"}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
