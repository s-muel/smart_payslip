import 'dart:io';
import 'package:excel/excel.dart' as excel;
import '../models/employee_record.dart';

class ExcelService {
  Future<List<EmployeeRecord>> getEmployeeRecords(String? path) async {
    if (path == null) return [];

    try {
      final bytes = await File(path).readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);

      if (excelFile.sheets.isEmpty) return [];

      final firstSheet = excelFile.sheets.values.first;
      final rows = firstSheet.rows;

      List<EmployeeRecord> employees = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        final employeeNumber =
            row.isNotEmpty && row[0] != null ? row[0]!.value.toString() : '';

        final name =
            row.length > 1 && row[1] != null ? row[1]!.value.toString() : '';

        final email =
            row.length > 2 && row[2] != null ? row[2]!.value.toString() : '';

        if (employeeNumber.isNotEmpty) {
          employees.add(
            EmployeeRecord(
              employeeNumber: employeeNumber,
              name: name,
              email: email,
            ),
          );
        }
      }

      return employees;
    } catch (e) {
      return [];
    }
  }
}