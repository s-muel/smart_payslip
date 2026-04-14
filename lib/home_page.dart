import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartpayslip/UI%20Element/app_bar.dart';
import 'package:smartpayslip/UI%20Element/slider_bar.dart';
import 'package:smartpayslip/upload_files_page.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedItem = 'Dashboard';
  String? selectedPdfFileName;
  String? selectedExcelFileName;
  int? pdfPageCount;
  int? excelRowCount;

  String? selectedPdfPath;
  String? selectedExcelPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(' BAJ Payslip Distribution System'),
      //   actions: [
      //     const Center(child: Text('HR Admin')),
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: [
                SideBar(
                  selectedItem: selectedItem,
                  onItemSelected: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                ),

                // MAIN CONTENT AREA
// MAIN CONTENT AREA
                Expanded(
                  child: _buildMainContent(),
                ),

                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const Text(
                //           'Dashboard',
                //           style: TextStyle(
                //             fontSize: 24,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),

                //         const SizedBox(height: 20),

                //         const Text(
                //           'Welcome back, manage your payslip processing here.',
                //           style: TextStyle(fontSize: 14),
                //         ),

                //         const SizedBox(height: 30),

                //         // Quick Actions
                //         Wrap(
                //           spacing: 20,
                //           runSpacing: 20,
                //           children: [
                //             _buildCard('Upload PaySlip (PDF File)',
                //                 Icons.picture_as_pdf, 'Upload Files'),
                //             _buildCard('Upload Employee Data (Excel File)',
                //                 Icons.table_chart, 'Upload Files'),
                //             _buildCard('Split & Match', Icons.call_split,
                //                 'Split & Match'),
                //             _buildCard(
                //                 'Send Emails', Icons.send, 'Send Emails'),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//This Method builds the Card content for the Dashboard
  Widget _buildCard(String title, IconData icon, String targetScreen) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedItem = targetScreen;
        });
      },
      child: Container(
        width: 180,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //This method builds the main content based on the selected sidebar item
  Widget _buildMainContent() {
    switch (selectedItem) {
      case 'Dashboard':
        return _buildDashboardScreen();

      case 'Upload Files':
        return UploadFilesScreen(
          selectedPdfFileName: selectedPdfFileName,
          selectedExcelFileName: selectedExcelFileName,
          pdfPageCount: pdfPageCount,
          excelRowCount: excelRowCount,
          onPickPdf: () async {
            final result = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            if (result != null && result.files.isNotEmpty) {
              final file = result.files.single;
              final pageCount = await _getPdfPageCount(file.path);

              setState(() {
                selectedPdfFileName = file.name;
                selectedPdfPath = file.path;
                pdfPageCount = pageCount;
              });
            }
          },
          onPickExcel: () async {
            final result = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx', 'xls'],
            );

            if (result != null && result.files.isNotEmpty) {
              final file = result.files.single;
              final rowCount = await _getExcelRowCount(file.path);

              setState(() {
                selectedExcelFileName = file.name;
                selectedExcelPath = file.path;
                excelRowCount = rowCount;
              });
            }
          },
          onBack: () {
            setState(() {
              selectedItem = 'Dashboard';
            });
          },
          onContinue:
              (selectedPdfFileName != null && selectedExcelFileName != null)
                  ? () {
                      setState(() {
                        selectedItem = 'Split & Match';
                      });
                    }
                  : null,
        );

      case 'Send Emails':
        return const Center(
          child: Text(
            'Send Emails Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );

      case 'Reports':
        return const Center(
          child: Text(
            'Reports Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );

      case 'Settings':
        return const Center(
          child: Text(
            'Settings Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );

      default:
        return _buildDashboardScreen();
    }
  }

// This method builds the Dashboard screen content
  Widget _buildDashboardScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome back, manage your payslip processing here.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildCard('Upload PaySlip (PDF File)', Icons.picture_as_pdf,
                  'Upload Files'),
              _buildCard('Upload Employee Data (Excel File)', Icons.table_chart,
                  'Upload Files'),
              _buildCard('Split & Match', Icons.call_split, 'Split & Match'),
              _buildCard('Send Emails', Icons.send, 'Send Emails'),
            ],
          ),
        ],
      ),
    );
  }

  Future<int?> _getPdfPageCount(String? path) async {
    if (path == null) return null;

    try {
      final bytes = await File(path).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final count = document.pages.count;
      document.dispose();
      return count;
    } catch (e) {
      debugPrint('Error reading PDF page count: $e');
      return null;
    }
  }

  Future<int?> _getExcelRowCount(String? path) async {
    if (path == null) return null;

    try {
      final bytes = await File(path).readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);

      int totalRows = 0;

      for (final sheet in excelFile.tables.values) {
        totalRows += sheet.maxRows;
      }

      return totalRows;
    } catch (e) {
      debugPrint('Error reading Excel row count: $e');
      return null;
    }
  }
}
