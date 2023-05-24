import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
class CitizenChart extends StatefulWidget {
  const CitizenChart({Key? key}) : super(key: key);

  @override
  State<CitizenChart> createState() => _CitizenChartState();
}

class _CitizenChartState extends State<CitizenChart> {


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Citizen Chart',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
     body: Column(
       children: [
       ],
     ),

    );
  }
}
