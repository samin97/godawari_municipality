import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../global/widgets/button_widget.dart';
import '../../global/widgets/error_dialog.dart';

class ReportYear extends StatefulWidget {
  const ReportYear({Key? key}) : super(key: key);

  @override
  _ReportYearState createState() => _ReportYearState();
}

class _ReportYearState extends State<ReportYear> {
  DateTime? selectedDate;
  late String value;

  String getText() {
    if (selectedDate == null) {
      return 'आ.व. छान्नुहोस्';
    } else {
      return DateFormat('yyyy').format(selectedDate!);
    }
  }

  Future<void> pickDate({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 5),
      locale: localeObj,
      initialMonthYearPickerMode: MonthYearPickerMode.year,
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        print(selectedDate);
      });
    }
  }

  validate() {
    if (selectedDate == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "वर्ष छान्नुहोस् ।",
            );
          });
    } else {
      //todo
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "वार्षिक प्रतिवेदनको लागि विवरण उपलब्ध हुन सकेन ।",
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'वर्ष :',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                ButtonHeaderWidget(
                  title: 'Date',
                  text: getText(),
                  onClicked: () => pickDate(context: context),
                ),
                const SizedBox(height: 12),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  validate();
                  // Route newRoute =
                  // MaterialPageRoute(builder: (_) =>
                  //     YearlyReport(value: value, ));
                  // Navigator.pushReplacement(context, newRoute);
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}
