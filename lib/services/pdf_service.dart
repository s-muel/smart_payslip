import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/preview_match_item.dart';

class PdfPageTextItem {
  final int pageNumber;
  final String text;
  final String normalizedText;
  final String? employeeNumber;

  PdfPageTextItem({
    required this.pageNumber,
    required this.text,
    required this.normalizedText,
    required this.employeeNumber,
  });
}

class PdfService {
  Future<int?> getPdfPageCount(String? path) async {
    if (path == null) return null;

    PdfDocument? document;

    try {
      final bytes = await File(path).readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      return document.pages.count;
    } catch (e) {
      debugPrint('Error getting PDF page count: $e');
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
        final text = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        pageTexts.add(text);
      }

      return pageTexts;
    } catch (e) {
      debugPrint('Error extracting text from pages: $e');
      return [];
    } finally {
      document?.dispose();
    }
  }

  Future<List<PdfPageTextItem>> extractTextPageByPage(String? path) async {
    if (path == null) return [];

    PdfDocument? document;

    try {
      final bytes = await File(path).readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);

      final List<PdfPageTextItem> results = [];

      for (int i = 0; i < document.pages.count; i++) {
        final rawText = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );

        final normalized = _normalizeText(rawText);
        final employeeNumber = extractEmployeeNumber(normalized);

        debugPrint(
          'Page ${i + 1} -> Employee Number: ${employeeNumber ?? "NOT FOUND"}',
        );

        results.add(
          PdfPageTextItem(
            pageNumber: i + 1,
            text: rawText,
            normalizedText: normalized,
            employeeNumber: employeeNumber,
          ),
        );
      }

      return results;
    } catch (e) {
      debugPrint('Error extracting PDF text page by page: $e');
      return [];
    } finally {
      document?.dispose();
    }
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? extractEmployeeNumber(String text) {
    final patterns = [
      RegExp(r'\bBF\s*[-:]?\s*(\d+)\b', caseSensitive: false),
      RegExp(r'\b(BF\d+)\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final full = match.group(0)!;
        final cleaned = full.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
        if (cleaned.toUpperCase().startsWith('BF')) {
          return cleaned.toUpperCase();
        }
      }
    }

    return null;
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
      debugPrint('Error splitting and saving matched payslips: $e');
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
