import 'package:smartpayslip/models/employee_record.dart';
import 'package:smartpayslip/models/preview_match_item.dart';

class MatchService {
  List<PreviewMatchItem> generatePreviewMatchesFromPdf({
    required List<String> pageTexts,
    required List<EmployeeRecord> employees,
    required String? Function(String text) extractEmployeeNumber,
  }) {
    final Map<String, EmployeeRecord> employeesByNumber = {
      for (final employee in employees)
        employee.employeeNumber.trim().toUpperCase(): employee,
    };

    return List.generate(pageTexts.length, (index) {
      final pageNumber = index + 1;
      final extractedNumber = extractEmployeeNumber(pageTexts[index]);
      final normalizedNumber = extractedNumber?.trim().toUpperCase();
      final employee = normalizedNumber == null
          ? null
          : employeesByNumber[normalizedNumber];

      if (extractedNumber == null || extractedNumber.isEmpty) {
        return PreviewMatchItem(
          pageNumber: pageNumber,
          employeeNumber: '-',
          employeeName: '-',
          employeeEmail: '-',
          status: 'No Employee Number',
        );
      }

      if (employee == null) {
        return PreviewMatchItem(
          pageNumber: pageNumber,
          employeeNumber: extractedNumber,
          employeeName: '-',
          employeeEmail: '-',
          status: 'Unmatched',
        );
      }

      return PreviewMatchItem(
        pageNumber: pageNumber,
        employeeNumber: employee.employeeNumber,
        employeeName: employee.name,
        employeeEmail: employee.email,
        status: employee.email.isNotEmpty ? 'Matched' : 'No Email',
      );
    });
  }

  List<PreviewMatchItem> generatePreviewMatches({
    required int pdfPageCount,
    required List<EmployeeRecord> employees,
  }) {
    return List.generate(pdfPageCount, (index) {
      final page = index + 1;

      if (index < employees.length) {
        final employee = employees[index];

        return PreviewMatchItem(
          pageNumber: page,
          employeeNumber: employee.employeeNumber,
          employeeName: employee.name,
          employeeEmail: employee.email,
          status: employee.email.isNotEmpty ? 'Matched' : 'No Email',
        );
      } else {
        return PreviewMatchItem(
          pageNumber: page,
          employeeNumber: '-',
          employeeName: '-',
          employeeEmail: '-',
          status: 'Unmatched',
        );
      }
    });
  }
}
