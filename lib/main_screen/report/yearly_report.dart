
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:municpality_app/global/widgets/error_dialog.dart';
import 'package:municpality_app/main_screen/report/yearly_report_details.dart';

import '../../global/widgets/button_widget.dart';

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
      return 'Select';
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
      firstDate: DateTime(DateTime
          .now()
          .year - 10),
      lastDate: DateTime(DateTime
          .now()
          .year + 5),
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
  validate(){
    if(selectedDate == null){
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select a year",
            );
          });
    }else{
      //todo
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Function not available at the moment",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(
                  child: Text(
                    'Year:',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Flexible(
                  child: ButtonHeaderWidget(
                    title: 'Date',
                    text: getText(),
                    onClicked: () => pickDate(context: context),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

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