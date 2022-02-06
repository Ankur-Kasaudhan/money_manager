// // ignore_for_file: prefer_const_constructors_in_immutables

// import 'package:flutter/material.dart';
// import 'package:money_manager/controllers/db_helper.dart';
// import 'package:money_manager/pages/add_name.dart';
// import 'package:money_manager/pages/homepage.dart';

// class Splash extends StatefulWidget {
//   Splash({Key? key}) : super(key: key);

//   @override
//   State<Splash> createState() => _SplashState();
// }

// class _SplashState extends State<Splash> {
//   DbHelper dbHelper = DbHelper();
//   Future getSettings() async {
//     String? name = await dbHelper.getName();
//     if (name != null) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => MyHomePage()),
//       );
//     } else {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => AddName()),
//       );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0.0,
//       ),
//       //
//       backgroundColor: Color(0xffe2e7ef),
//       //
//       body: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white70,
//             borderRadius: BorderRadius.circular(
//               12.0,
//             ),
//           ),
//           padding: EdgeInsets.all(
//             16.0,
//           ),
//           child: Image.asset(
//             "assets/icon.png",
//             width: 64.0,
//             height: 64.0,
//           ),
//         ),
//       ),
//     );
//   }
// }

// not just splash , will ask use for their name here

// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:money_manager/controllers/db_helper.dart';
import 'package:money_manager/pages/add_name.dart';
import 'package:money_manager/pages/auth.dart';
import 'package:money_manager/pages/homepage.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  //
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future getName() async {
    String? name = await dbHelper.getName();
    if (name != null) {
      // user has entered a name
      // since name is also important and can't be null
      // we will check for auth here and will show , auth if it is on
      bool? auth = await dbHelper.getLocalAuth();
      if (auth != null && auth) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FingerPrintAuth(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AddName(),
        ),
      );
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      //
      backgroundColor: Color(0xffe2e7ef),
      //
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              12.0,
            ),
          ),
          padding: EdgeInsets.all(
            16.0,
          ),
          child: Image.asset(
            "assets/icon.png",
            width: 64.0,
            height: 64.0,
          ),
        ),
      ),
    );
  }
}
