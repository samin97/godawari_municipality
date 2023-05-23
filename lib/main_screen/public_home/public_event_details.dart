import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/public_home/public_home_screen.dart';
import 'package:smart_attendance/models/PublicEventModel.dart';
class PublicEventDetails extends StatefulWidget {
  final PublicEventModel eventModel;

  const PublicEventDetails(
      {Key? key, required this.eventModel, })
      : super(key: key);

  @override
  State<PublicEventDetails> createState() => _PublicEventDetailsState();
}

class _PublicEventDetailsState extends State<PublicEventDetails> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Event Details',
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
              MaterialPageRoute(builder: (_) => const PublicHomeScreen());
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/noImage.jpg',
                    image: 'http://mis.godawarimun.gov.np/uploads/' + widget.eventModel.photo.toString(),


                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Event : " + widget.eventModel.name.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Description : " + widget.eventModel.longDescription.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}
