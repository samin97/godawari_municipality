import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/public_home/about_app.dart';
import 'package:smart_attendance/main_screen/public_home/complain_registration.dart';
import 'package:smart_attendance/main_screen/public_home/employee_login.dart';
import 'package:smart_attendance/main_screen/public_home/public_events.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    PublicEvents(),
    ComplainRegistration(),
    Login(),
    AboutApp(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  // Widget _listViewBody() {
  //   return ListView.separated(
  //       controller: _homeController,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Center(
  //           child: Text(
  //             'Item $index',
  //           ),
  //         );
  //       },
  //       separatorBuilder: (BuildContext context, int index) => const Divider(
  //             thickness: 1,
  //           ),
  //       itemCount: 50);
  //}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
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
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).size.height / 9.4,
          child: BottomNavigationBar(
            iconSize: 34,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'इभेन्टस्',
                  backgroundColor: Colors.blueAccent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer),
                  label: 'गुनासो दर्ता',
                  backgroundColor: Colors.blueAccent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  label: 'लगिन',
                  backgroundColor: Colors.blueAccent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: 'एपको बारेमा',
                  backgroundColor: Colors.blueAccent),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xCD55E0E3),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
