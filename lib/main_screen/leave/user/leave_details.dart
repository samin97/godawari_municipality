import 'package:flutter/material.dart';
import '../../../global/widgets/app_button.dart';
import '../../../models/leave_model.dart';
import 'leave_category.dart';

class UserLeaveDetails extends StatefulWidget {
  final LeaveModel leaveModel;
  final String status;

  const UserLeaveDetails(
      {Key? key, required this.leaveModel, required this.status})
      : super(key: key);

  @override
  State<UserLeaveDetails> createState() => _UserLeaveDetailsState();
}

class _UserLeaveDetailsState extends State<UserLeaveDetails> {
  @override
  Widget build(BuildContext context) {
    String type = widget.status;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            '$type Leave Details',
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Route newRoute =
                  MaterialPageRoute(builder: (_) => const LeaveCategory());
              Navigator.pushReplacement(context, newRoute);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Text(
                  "Date : " + widget.leaveModel.leaveDate.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Reason : " + widget.leaveModel.leaveFor.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Status : " + widget.leaveModel.status.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Divider(
                  thickness: 3,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Description : ",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.leaveModel.description.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Divider(
                  thickness: 3,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(flex: 1),
                    Flexible(
                      flex: 2,
                      child: AppButton(
                        textColour: Colors.black54,
                        backgroundColor: const Color(0xFF80DEEA),
                        borderColor: const Color(0xFF80DEEA),
                        text: 'Conform',
                        onTap: () {
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => const LeaveCategory());
                          Navigator.pushReplacement(context, newRoute);
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
