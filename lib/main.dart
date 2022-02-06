// ignore_for_file: unused_import, unnecessary_import

import 'package:flutter/material.dart';
import 'package:money_manager/pages/add_name.dart';
import 'package:money_manager/pages/homepage.dart';
import 'package:money_manager/pages/splash.dart';
import 'package:money_manager/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('money');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: Splash(),
    );
  }
}
