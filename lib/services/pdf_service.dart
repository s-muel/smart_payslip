import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/preview_match_item.dart';

class PdfService {
  Future<int?> getPdfPageCount(String? path) async {
    if (path == null) return null;

    PdfDocument? document;

    try {
      final bytes = await File(path).readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      return document.pages.count;
    } catch (e) {
      return null;
    } finally {
      document?.dispose();
    }
  }

  Future<List<String>> extractTextFromPages(String? path) async {
    if (path == null) return [];

    PdfDocument? document;

    try {
      final bytes = await File(path).readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);

      final List<String> pageTexts = [];

      for (int i = 0; i < document.pages.count; i++) {
        final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        pageTexts.add(text);
      }

      return pageTexts;
    } catch (e) {
      return [];
    } finally {
      document?.dispose();
    }
  }

  String? extractEmployeeNumber(String text) {
    final regex = RegExp(r'BF\d+');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  Future<List<String>> splitAndSaveMatchedPayslips({
    required String? sourcePdfPath,
    required List<PreviewMatchItem> matchItems,
    String outputFolderName = 'generated_payslips',
  }) async {
    if (sourcePdfPath == null) return [];

    final sourceFile = File(sourcePdfPath);
    if (!await sourceFile.exists()) return [];

    final itemsToExport = matchItems.where((item) {
      return item.status == 'Matched' || item.status == 'No Email';
    }).toList();

    if (itemsToExport.isEmpty) return [];

    final outputDirectory = Directory(
      '${sourceFile.parent.path}${Platform.pathSeparator}$outputFolderName',
    );

    if (!await outputDirectory.exists()) {
      await outputDirectory.create(recursive: true);
    }

    PdfDocument? sourceDocument;

    try {
      final bytes = await sourceFile.readAsBytes();
      sourceDocument = PdfDocument(inputBytes: bytes);

      final List<String> savedFiles = [];

      for (final item in itemsToExport) {
        final pageIndex = item.pageNumber - 1;

        if (pageIndex < 0 || pageIndex >= sourceDocument.pages.count) {
          continue;
        }

        final sourcePage = sourceDocument.pages[pageIndex];
        final template = sourcePage.createTemplate();

        final outputDocument = PdfDocument();

        try {
          outputDocument.pageSettings.size = sourcePage.size;
          outputDocument.pageSettings.margins.all = 0;
          final newPage = outputDocument.pages.add();
          newPage.graphics.drawPdfTemplate(template, Offset.zero);

          final safeEmployeeNumber = _sanitizeFileName(item.employeeNumber);
          final safeEmployeeName = _sanitizeFileName(item.employeeName);

          final outputPath = '${outputDirectory.path}${Platform.pathSeparator}'
              '${safeEmployeeNumber}_$safeEmployeeName.pdf';

          final outputBytes = await outputDocument.save();
          await File(outputPath).writeAsBytes(outputBytes, flush: true);

          savedFiles.add(outputPath);
        } finally {
          outputDocument.dispose();
        }
      }

      return savedFiles;
    } catch (e) {
      return [];
    } finally {
      sourceDocument?.dispose();
    }
  }

  String _sanitizeFileName(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
