import 'package:flutter/material.dart';
class PendingReports extends StatefulWidget {
  const PendingReports({Key? key}) : super(key: key);

  @override
  State<PendingReports> createState() => _PendingReportsState();
}

class _PendingReportsState extends State<PendingReports> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
