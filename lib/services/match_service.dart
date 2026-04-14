import 'package:smartpayslip/models/employee_record.dart';
import 'package:smartpayslip/models/preview_match_item.dart';

class MatchService {
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