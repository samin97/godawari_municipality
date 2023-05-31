import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:smart_attendance/models/registration_model.dart';
import '../../global/widgets/error_dialog.dart';
import '../../global/global.dart';
import '../attendance/offline_home.dart';
import '../employee_home_screen.dart';
import '../../models/login_model.dart';
import '../../models/login_response_model.dart';
import '../landing_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  TextEditingController rUsernameController = TextEditingController();
  TextEditingController rPasswordController = TextEditingController();
  TextEditingController employeeId = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController localLevel = TextEditingController();
  TextEditingController wardNo = TextEditingController();
  TextEditingController rastyaParichayaPatraNo = TextEditingController();
  TextEditingController nagariktaNo = TextEditingController();



  @override
  void initState() {
    super.initState();
    final newVersion = NewVersionPlus(
      iOSId: 'com.DEBUGSOFT.godawari_app',
      androidId: 'com.DEBUGSOFT.godawari_app',
    );
    advancedStatusCheck(newVersion);

  }



  advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      if(status.canUpdate){
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'New version available',
          dialogText: 'Please update application',
        );
      }
    }
  }

  offlineLogin() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      checkIfOffline();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please write email/password",
            );
          });
    }
  }

  loginOffline() {
    if (usernameController.text == sharedPreferences!.getString("username")! &&
        passwordController.text == sharedPreferences!.getString("password")!) {
      Route newRoute = MaterialPageRoute(builder: (_) => const OfflineHome());
      Navigator.pushReplacement(context, newRoute);
      const snackBar = SnackBar(
        content: Text('Logging in offline'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      failedSignIn();
    }
  }

  Future checkIfOffline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are online."),
          content: const Text("Please login through online."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    } else if (connectivityResult == ConnectivityResult.wifi) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are online."),
          content: const Text("Please login through online."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    } else {
      loginOffline();
      //localStorage();
    }
  }

  formValidation() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      checkConnection();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please write email/password",
            );
          });
    }
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      loginNow();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      loginNow();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are offline."),
          content: const Text("Internet connection is required to login."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
      //localStorage();
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  failedSignIn() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Sign in failed."),
        content: const Text("User name or password is entered incorrectly."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Conform"))
        ],
      ),
    );
  }

  Future loginNow() async {
    LoginModel user = LoginModel(username: '', password: '');
    setState(() {
      user.username = usernameController.text;
      user.password = passwordController.text;
    });
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Auth/Authenticate"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(user));

    if (response.statusCode == 200) {
      showLoaderDialog(context);
      LoginResponseModel userDetails =
          LoginResponseModel.fromJson(jsonDecode(response.body));
      print(userDetails.meters);
      await sharedPreferences?.setString(
          "token", userDetails.tokenString as String);
      await sharedPreferences?.setString("username", userDetails.username!);
      await sharedPreferences?.setString(
          "firstName", userDetails.firstName ?? "First Name");
      await sharedPreferences?.setString(
          "nepaliName", userDetails.nepaliName ?? "nepali name");
      await sharedPreferences?.setString(
          "latitude", userDetails.latitude ?? "latitude");
      await sharedPreferences?.setString(
          "longitude", userDetails.longitude ?? "longitude");
      await sharedPreferences?.setString(
          "deviceId", userDetails.deviceId ?? 'deviceID');
      await sharedPreferences?.setString(
          "permittedDistance", userDetails.meters ?? "meters");
      await sharedPreferences?.setString("role", userDetails.role ?? "role");

      await sharedPreferences?.setString("password", passwordController.text);
      await sharedPreferences?.setString("username", usernameController.text);
      print(sharedPreferences!.getString("password")!);
      print(sharedPreferences!.getString("username")!);
      print(userDetails);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      failedSignIn();
    }
  }

  Future registerNow() async {
    RegistrationModel registrationModel = RegistrationModel();

    setState(() {
      registrationModel.firstName = rUsernameController.text;
      registrationModel.password = rPasswordController.text;
      registrationModel.employeeId =
      registrationModel.dob = dob.text;
      registrationModel.email = email.text;
      registrationModel.phoneNo = phoneNo.text;
      registrationModel.province = selectedProvince;
      registrationModel.district = selectedDistrict;
      registrationModel.localLevel = rPasswordController.text;
      registrationModel.wardNo = rUsernameController.text;
      registrationModel.rastyaParichayaPatraNo = rPasswordController.text;
      registrationModel.nagariktaNo = rUsernameController.text;


    });
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Karmachari/AddUser"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(registrationModel));
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Registration successful."),
          content: const Text("You will be notified through sms after we have validated your account."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Registration failed."),
          content: const Text("Please fill all the details correctly and try again later."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
  bool isLogin = true;
  String logState = 'Log in';

  final List<String> district01 = [
    'TAPLEJUNG',
    'SANKHUWASABHA',
    'SOLUKHUMBU',
    'OKHALDHUNGA',
    'KHOTANG',
    'BHOJPUR',
    'DHANKUTA',
    'TERHATHUM',
    'PANCHTHAR',
    'ILAM',
    'JHAPA',
    'MORANG',
    'SUNSARI',
    'UDAYAPUR',

  ];
  final List<String> district02 = [
    'SAPTARI',
    'SIRAHA',
    'DHANUSA',
    'MAHOTTARI',
    'SARLAHI',
    'RAUTAHAT',
    'BARA',
    'PARSA',

  ];
  final List<String> district03 = [
    'DOLAKHA',
    'SINDHUPALCHOK',
    'RASUWA',
    'DHADING',
    'NUWAKOT',
    'KATHMANDU',
    'BHAKTAPUR',
    'LALITPUR',
    'KAVREPALANCHOK'
        'RAMECHHAP',
    'SINDHULI',
    'MAKWANPUR',
    'CHITAWAN',

  ];
  final List<String> district04 = [
    'GORKHA',
    'MANANG',
    'MUSTANG',
    'MYAGDI',
    'KASKI',
    'LAMJUNG',
    'TANAHU',
    'NAWALPARASI EAST',
    'SYANGJA',
    'PARBAT',
    'BAGLUNG'

  ];
  final List<String> district05 = [
    'RUKUM EAST',
    'ROLPA',
    'PYUTHAN',
    'GULMI',
    'ARGHAKHANCHI',
    'PALPA',
    'NAWALPARASI WEST',
    'RUPANDEHI',
    'KAPILBASTU',
    'DANG',
    'BANKE',
    'BARDIYA',

  ];
  final List<String> district06 = [
    'DOLPA',
    'MUGU',
    'HUMLA',
    'JUMLA',
    'KALIKOT',
    'DAILEKH',
    'JAJARKOT',
    'RUKUM WEST',
    'SALYAN',
    'SURKHET',

  ];
  final List<String> district07 = [
    'BAJURA',
    'BAJHANG',
    'DARCHULA',
    'BAITADI',
    'DADELDHURA',
    'DOTI',
    'ACHHAM',
    'KAILALI',
    'KANCHANPUR',

  ];


  String? selectedProvince;
  String? selectedDistrict;

  late Map<String, List<String>> dataset = {
    'Koshi Province' :district01 ,
    'Madhesh Province' : district02,
    'Bagmati Province' : district03,
    'Gandaki Province' : district04,
    'Lumbini Province' : district05,
    'Karnali Province' : district06,
    'Sudurpashchim Province':district07,

  };

  onProvinceChanged(String? value) {
    //dont change second dropdown if 1st item didnt change
    if (value != selectedProvince) selectedDistrict = null;
    setState(() {
      selectedProvince = value;
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               Text(
                logState,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 0,)
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Route newRoute =
              MaterialPageRoute(builder: (_) => const LandingScreen());
              Navigator.pushReplacement(context, newRoute);
            },
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Visibility(
                visible: isLogin,
                child: Column(
                  children: [
                    Container(),
                    Image.asset(
                      'images/logo.jpg',
                      fit: BoxFit.contain,
                      height: 120,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'User ID'),
                          controller: usernameController,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            hintText: 'Password',
                          ),
                          controller: passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              const snackBar = SnackBar(
                                content: Text('Logging in'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              formValidation();
                            },
                            child: const Text("Log In")),
                        const SizedBox(
                          height: 20,
                        ),
                        Text("New user?"),
                        TextButton(onPressed: (){setState(() {
                          isLogin = false;
                          logState ="Register";
                        });}, child: Text('Register'))

                        // ElevatedButton(
                        //     onPressed: () {
                        //       offlineLogin();
                        //     },
                        //     child: const Text("Offline login")),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !isLogin,
                child: Column(
                  children: [
                    Container(),
                    Image.asset(
                      'images/logo.jpg',
                      fit: BoxFit.contain,
                      height: 120,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Full name'),
                          controller: rUsernameController,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            hintText: 'Password',
                          ),
                          controller: rPasswordController,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'employee ID'),
                          controller: employeeId,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Date of birth'),
                          controller: dob,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Email'),
                          controller: email,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Phone'),
                          controller: phoneNo,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                                value: selectedProvince,
                                hint: const Text("Province"),
                                items: dataset.keys.map((e) {
                                  return DropdownMenuItem<String?>(
                                    value: e,
                                    child: Text('$e'),
                                  );
                                }).toList(),
                                onChanged: onProvinceChanged),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                                value: selectedDistrict,
                                hint: const Text("District"),
                                items: (dataset[selectedProvince] ?? []).map((e) {
                                  return DropdownMenuItem<String?>(
                                    value: e,
                                    child: Text('$e'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedDistrict = val!;
                                  });
                                }),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Local address'),
                          controller: localLevel,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Ward no'),
                          controller: wardNo,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Rastya Parichaya Patra No'),
                          controller: rastyaParichayaPatraNo,
                        ),
                        const SizedBox(
                          height: 10,
                        ),TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: 'Nagarikta No'),
                          controller: nagariktaNo,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              const snackBar = SnackBar(
                                content: Text('Register account'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              registerNow();
                            },
                            child: const Text("Register account")),
                        const SizedBox(
                          height: 20,
                        ),
                        Text('Already registered?,'),

                        TextButton(onPressed: (){setState(() {
                          isLogin = true;
                          logState ="Log in";
                        });}, child: Text('Log in'))

                        // ElevatedButton(
                        //     onPressed: () {
                        //       offlineLogin();
                        //     },
                        //     child: const Text("Offline login")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



