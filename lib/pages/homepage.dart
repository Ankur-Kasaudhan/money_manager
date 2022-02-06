// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print, unused_local_variable, unused_import

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/controllers/db_helper.dart';
import 'package:money_manager/models/info_snackbar.dart';
import 'package:money_manager/models/transaction_modal.dart';
import 'package:money_manager/pages/add_transaction.dart';
import 'package:money_manager/pages/settings.dart';
import 'package:money_manager/pages/widgets/confirm_dialog.dart';
import 'package:money_manager/static.dart' as Static;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  DbHelper dbHelper = DbHelper();
  late SharedPreferences Preferences;
  late Box box;
  // Map? data;
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  List<FlSpot> dataSet = [];
  DateTime today = DateTime.now();
  DateTime now = DateTime.now();
  int index = 1;
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  List<FlSpot> getPlotPoints(List<TransactionModel> entireData) {
    dataSet = [];
    List tempdataSet = [];

    for (TransactionModel item in entireData) {
      if (item.date.month == today.month && item.type == "Expense") {
        tempdataSet.add(item);
      }
    }
    //
    // Sorting the list as per the date
    tempdataSet.sort((a, b) => a.date.day.compareTo(b.date.day));
    //
    for (var i = 0; i < tempdataSet.length; i++) {
      dataSet.add(
        FlSpot(
          tempdataSet[i].date.day.toDouble(),
          tempdataSet[i].amount.toDouble(),
        ),
      );
    }
    return dataSet;
  }

  getTotalBalance(List<TransactionModel> entireData) {
    totalExpense = 0;
    totalIncome = 0;
    totalBalance = 0;
    for (TransactionModel data in entireData) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  getPreference() async {
    Preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModel>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModel> items = [];
      box.toMap().values.forEach(
        (element) {
          // print(element);
          items.add(
            TransactionModel(
              element['amount'] as int,
              element['date'] as DateTime,
              element['type'],
              element['note'],
            ),
          );
        },
      );
      return items;
    }
  }

  @override
  void initState() {
    super.initState();
    getPreference();
    box = Hive.box('money');
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      backgroundColor: Color(0xffe2e7ef),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (context) => AddTransaction()),
          )
              .whenComplete(() {
            setState(() {});
          });
        },
        backgroundColor: Static.PrimaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Icon(
          Icons.add,
          size: 32.0,
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Unexpected Error !"),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text("No Values Found !"),
              );
            }
            getTotalBalance(snapshot.data!);
            getPlotPoints(snapshot.data!);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.0),
                                color: Colors.white),
                            child: CircleAvatar(
                              maxRadius: 32.0,
                              child: Image.asset(
                                "assets/face.png",
                                width: 64.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            "Welcome ${Preferences.getString('name')}",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                color: Static.PrimaryMaterialColor[800]),
                          )
                        ],
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12.0),
                      //       color: Colors.white),
                      //   padding: EdgeInsets.all(12.0),
                      //   child: Icon(
                      //     Icons.settings,
                      //     size: 32.0,
                      //     color: Color(0xFF3E454C),
                      //   ),
                      // ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ),
                          color: Colors.white70,
                        ),
                        padding: EdgeInsets.all(
                          12.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => Settings(),
                              ),
                            )
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: Icon(
                            Icons.settings,
                            size: 32.0,
                            color: Color(0xff3E454C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Static.PrimaryColor,
                            Colors.blueAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24.0))),
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Balance',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22.0, color: Colors.white),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          'Rs $totalBalance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              cardIncome(
                                totalIncome.toString(),
                              ),
                              cardExpense(
                                totalExpense.toString(),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Expenses",
                    style: TextStyle(
                        fontSize: 32.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                // dataSet.length >= 2
                //     ? Container(
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(8.0),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.grey.withOpacity(0.4),
                //               spreadRadius: 5,
                //               blurRadius: 6,
                //               offset: Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 10.0,
                //           vertical: 40.0,
                //         ),
                //         margin: EdgeInsets.all(12.0),
                //         height: 400.0,
                //         child: LineChart(
                //           LineChartData(
                //             borderData: FlBorderData(show: false),
                //             lineBarsData: [
                //               LineChartBarData(
                //                 spots: getPlotPoints(snapshot.data!),
                //                 isCurved: false,
                //                 barWidth: 2.5,
                //                 colors: [
                //                   Static.PrimaryColor,
                //                 ],
                //                 showingIndicators: [200, 200, 90, 10],
                //                 dotData: FlDotData(
                //                   show: true,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       )
                //     : Container(
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(8.0),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.grey.withOpacity(0.4),
                //               spreadRadius: 5,
                //               blurRadius: 6,
                //               offset: Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 10.0,
                //           vertical: 40.0,
                //         ),
                //         margin: EdgeInsets.all(12.0),
                //         child: Text(
                //           "No enough Values to render Charts !",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: 20.0,
                //             color: Colors.black87,
                //           ),
                //         )),
                dataSet.isEmpty || dataSet.length < 2
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40.0,
                          horizontal: 20.0,
                        ),
                        margin: EdgeInsets.all(
                          12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Text(
                          "Not Enough Data to render Chart",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      )
                    : Container(
                        height: 400.0,
                        padding: EdgeInsets.symmetric(
                          vertical: 40.0,
                          horizontal: 12.0,
                        ),
                        margin: EdgeInsets.all(
                          12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(
                              show: false,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getPlotPoints(snapshot.data!),
                                // spots: getPlotPoints(snapshot.data!),
                                isCurved: false,
                                barWidth: 2.5,
                                colors: [
                                  Static.PrimaryColor,
                                ],
                                showingIndicators: [200, 200, 90, 10],
                                dotData: FlDotData(
                                  show: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                        fontSize: 32.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    TransactionModel datAtIndex;

                    try {
                      datAtIndex = snapshot.data![index];
                    } catch (e) {
                      return Container();
                    }

                    if (datAtIndex.type == "Income") {
                      return incomeTile(
                        datAtIndex.amount,
                        datAtIndex.note,
                        datAtIndex.date,
                        index,
                      );
                    } else {
                      return expenseTile(
                        datAtIndex.amount,
                        datAtIndex.note,
                        datAtIndex.date,
                        index,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 60.0,
                )
              ],
            );
          } else {
            return Center(
              child: Text("Unexpected Error !"),
            );
          }
        },
      ),
    );
  }

  Widget cardIncome(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_downward,
            size: 28.0,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(right: 8.0),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Income",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget cardExpense(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_upward,
            size: 28.0,
            color: Colors.red[700],
          ),
          margin: EdgeInsets.only(right: 8.0),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Expense",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      splashColor: Static.PrimaryMaterialColor[400],
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          deleteInfoSnackBar,
        );
      },
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
            context, "WARNING! ", "Do you want to delete this record ? ");
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 28.0,
                      color: Colors.red[700],
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Expense",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ",
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "-$value",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget incomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      splashColor: Static.PrimaryMaterialColor[400],
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          deleteInfoSnackBar,
        );
      },
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING! ",
          "This will delete this record. This action is irreversible. Do you want to continue ?",
        );
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 28.0,
                      color: Colors.green[700],
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Income",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ",
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+$value",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget selectMonth() {
  //   return Padding(
  //     padding: EdgeInsets.all(
  //       8.0,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               index = 3;
  //               today = DateTime(now.year, now.month - 2, today.day);
  //             });
  //           },
  //           child: Container(
  //             height: 50.0,
  //             width: MediaQuery.of(context).size.width * 0.3,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(
  //                 8.0,
  //               ),
  //               color: index == 3 ? Static.PrimaryColor : Colors.white,
  //             ),
  //             alignment: Alignment.center,
  //             child: Text(
  //               months[now.month - 3],
  //               style: TextStyle(
  //                 fontSize: 20.0,
  //                 fontWeight: FontWeight.w600,
  //                 color: index == 3 ? Colors.white : Static.PrimaryColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               index = 2;
  //               today = DateTime(now.year, now.month - 1, today.day);
  //             });
  //           },
  //           child: Container(
  //             height: 50.0,
  //             width: MediaQuery.of(context).size.width * 0.3,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(
  //                 8.0,
  //               ),
  //               color: index == 2 ? Static.PrimaryColor : Colors.white,
  //             ),
  //             alignment: Alignment.center,
  //             child: Text(
  //               months[now.month - 2],
  //               style: TextStyle(
  //                 fontSize: 20.0,
  //                 fontWeight: FontWeight.w600,
  //                 color: index == 2 ? Colors.white : Static.PrimaryColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               index = 1;
  //               today = DateTime.now();
  //             });
  //           },
  //           child: Container(
  //             height: 50.0,
  //             width: MediaQuery.of(context).size.width * 0.3,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(
  //                 8.0,
  //               ),
  //               color: index == 1 ? Static.PrimaryColor : Colors.white,
  //             ),
  //             alignment: Alignment.center,
  //             child: Text(
  //               months[now.month - 1],
  //               style: TextStyle(
  //                 fontSize: 20.0,
  //                 fontWeight: FontWeight.w600,
  //                 color: index == 1 ? Colors.white : Static.PrimaryColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
