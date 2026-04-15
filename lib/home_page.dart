import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartpayslip/UI%20Element/app_bar.dart';
import 'package:smartpayslip/UI%20Element/slider_bar.dart';
import 'package:smartpayslip/upload_files_page.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'split_match_page.dart';

import '../models/employee_record.dart';
import '../models/preview_match_item.dart';
import '../services/match_service.dart';
import 'preview_match_page.dart';

import '../services/excel_service.dart';
import '../services/pdf_service.dart';
import '../services/email_service.dart';

import '../models/smtp_settings.dart';
import '../services/settings_service.dart';
import 'settings_page.dart';

import 'send_emails_page.dart';

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

  String splitMethod = 'one_page';

  List<EmployeeRecord> employees = [];

  final ExcelService excelService = ExcelService();

  final PdfService pdfService = PdfService();

  List<PreviewMatchItem> previewMatchItems = [];
  final MatchService matchService = MatchService();
  final EmailService emailService = EmailService();

  String emailSubject = 'March 2026 Payslip';

// Dammy data
  // final List<EmployeeRecord> sampleEmployees = [
  //   EmployeeRecord(
  //     employeeNumber: 'EMP001',
  //     name: 'Samuel Essuman',
  //     email: 'samuel@company.com',
  //   ),
  //   EmployeeRecord(
  //     employeeNumber: 'EMP002',
  //     name: 'Ama Mensah',
  //     email: 'ama@company.com',
  //   ),
  //   EmployeeRecord(
  //     employeeNumber: 'EMP003',
  //     name: 'Kojo Arthur',
  //     email: 'kojo@company.com',
  //   ),
  // ];

  final SettingsService settingsService = SettingsService();
  SmtpSettings smtpSettings = SmtpSettings.defaults();
  Future<void> _loadSmtpSettings() async {
    smtpSettings = await settingsService.loadSmtpSettings();
    if (mounted) {
      setState(() {});
    }
  }

  // Mailing Variables for testing
  // final EmailService emailService = EmailService();

  // final String smtpHost = 'mail.bajfreight.com';
  // final int smtpPort = 465;
  // final bool smtpSsl = true;
  // final bool smtpAllowInsecure = false;

  // final String senderEmail = 'samuel.essuman@bajfreight.com';
  // final String senderPassword = '123@**bajtd**';
  // final String senderName = 'Samuel Simon Essuman';
  // final String emailSubject = 'Your Payslip';

//Mailing method for testing
  Future<void> _splitAndSendPayslips(
    String subject,
    void Function(int current, int total, String employeeName) onProgress,
  ) async {
    final savedFiles = await pdfService.splitAndSaveMatchedPayslips(
      sourcePdfPath: selectedPdfPath,
      matchItems: previewMatchItems,
    );

    if (!mounted) return;

    if (savedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payslips were generated for sending.'),
        ),
      );
      return;
    }

    await _loadSmtpSettings();

    try {
      final results = await emailService.sendMatchedPayslips(
        sourcePdfPath: selectedPdfPath,
        matchItems: previewMatchItems,
        smtpHost: smtpSettings.smtpHost,
        smtpPort: smtpSettings.smtpPort,
        username: smtpSettings.senderEmail,
        password: smtpSettings.senderPassword,
        fromName: smtpSettings.senderName,
        subject: subject,
        ssl: smtpSettings.smtpSsl,
        allowInsecure: false,
        onProgress: onProgress,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Email Sending Summary'),
            content: SingleChildScrollView(
              child: Text(
                results.map((item) {
                  return '${item.employeeNumber} | ${item.email} | ${item.status} | ${item.details}';
                }).join('\n'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email sending failed: $e'),
        ),
      );
    }
  }

  Future<void> _splitMatchedPayslips() async {
    final savedFiles = await pdfService.splitAndSaveMatchedPayslips(
      sourcePdfPath: selectedPdfPath,
      matchItems: previewMatchItems,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedFiles.isEmpty
              ? 'No payslips were generated.'
              : 'Saved ${savedFiles.length} payslip PDFs to the generated_payslips folder.',
        ),
      ),
    );
  }

  void _showMismatchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mismatch Detected'),
          content: Text(
            'The PDF page count ($pdfPageCount) does not match the employee record count ($excelRowCount). '
            'You can continue, but some payslips may not match correctly.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  //_generatePreviewMatchItems();
                  selectedItem = 'Preview Match';
                });
              },
              child: const Text('Continue Anyway'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pop(dialogContext);

            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text('Continuing to next stage...'),
            //       ),
            //     );
            //   },
            //   child: const Text('Continue Anyway'),
            // ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSmtpSettings();
  }

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
                  onItemSelected: (value) async {
                    if (value == 'Settings') {
                      await _loadSmtpSettings();
                    }

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
              final employeeList =
                  await excelService.getEmployeeRecords(file.path);

              setState(() {
                selectedExcelFileName = file.name;
                selectedExcelPath = file.path;
                excelRowCount = employeeList.length;
                employees = employeeList;
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
      case 'Split & Match':
        final bool canProceed = pdfPageCount != null && excelRowCount != null;

        return SplitMatchScreen(
          pdfPageCount: pdfPageCount,
          excelRowCount: excelRowCount,
          splitMethod: splitMethod,
          onSplitMethodChanged: (value) {
            setState(() {
              splitMethod = value;
            });
          },
          onBack: () {
            setState(() {
              selectedItem = 'Upload Files';
            });
          },
          onStartMatching: canProceed
              ? () async {
                  await _generatePreviewMatchItems();

                  if (pdfPageCount != excelRowCount) {
                    _showMismatchDialog();
                  } else {
                    setState(() {
                      selectedItem = 'Preview Match';
                    });
                  }
                }
              : null,
        );
      case 'Preview Match':
        return PreviewMatchScreen(
          matchItems: previewMatchItems,
          onBack: () {
            setState(() {
              selectedItem = 'Split & Match';
            });
          },
          onProceed: previewMatchItems.isNotEmpty
              ? () {
                  setState(() {
                    selectedItem = 'Send Emails';
                  });
                }
              : null,
        );

      case 'Send Emails':
        return SendEmailsPage(
          matchItems: previewMatchItems,
          senderEmail: smtpSettings.senderEmail,
          initialSubject: emailSubject,
          onBack: () {
            setState(() {
              selectedItem = 'Preview Match';
            });
          },
          onSend: (subject, onProgress) async {
            emailSubject = subject;
            await _splitAndSendPayslips(subject, onProgress);
          },
        );

      case 'Reports':
        return const Center(
          child: Text(
            'Reports Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );

      case 'Settings':
        return SettingsPage(
          initialSettings: smtpSettings,
          onBack: () {
            setState(() {
              selectedItem = 'Dashboard';
            });
          },
          onSave: (settings) async {
            await settingsService.saveSmtpSettings(settings);
            smtpSettings = settings;
          },
        );

      default:
        return _buildDashboardScreen();
    }
  }

// this generate Preview Matched Items
  Future<void> _generatePreviewMatchItems() async {
    final pageTexts = await pdfService.extractTextFromPages(selectedPdfPath);

    previewMatchItems = matchService.generatePreviewMatchesFromPdf(
      pageTexts: pageTexts,
      employees: employees,
      extractEmployeeNumber: pdfService.extractEmployeeNumber,
    );
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
