import 'package:flutter/material.dart';
import 'package:municpality_app/main_screen/home_screen.dart';
import 'package:municpality_app/main_screen/settings/change_password.dart';

import '../../authenticate/login.dart';
import '../../global/global.dart';
import '../../global/widgets/app_button.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future logoutNow() async {
    await sharedPreferences?.remove("email");
    Route newRoute = MaterialPageRoute(builder: (_) => const Login());
    Navigator.pushReplacement(context, newRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Route newRoute =
                MaterialPageRoute(builder: (_) => const HomeScreen());
                Navigator.pushReplacement(context, newRoute);
              },
            ),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 50,)
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {


                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Edit personal Information"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  Route newRoute =
                  MaterialPageRoute(builder: (_) => const ChangePassword());
                  Navigator.pushReplacement(context, newRoute);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Change Password"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Help"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Gives us FeedBack"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Legal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Terms of Service"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Privacy Policy"),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppButton(
                textColour: Colors.black54,
                backgroundColor: const Color(0xFFDADADA),
                borderColor: const Color(0xFFC4C4C4),
                text: 'बाहिरिनुहोस्',
                onTap: () {
                  logoutNow();
                },
                icon: const Icon(Icons.logout,
                    size: 30, color: Color(0xFF10599e)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
