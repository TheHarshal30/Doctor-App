// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, unused_local_variable, unused_import, prefer_interpolation_to_compose_strings

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/screens/addpatient.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/screens/followopDetails.dart';
import 'package:medigine/screens/navigation.dart' as navv;
// import 'package:medigine/components/AuthManager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _search = TextEditingController();
  late List<Map<String, dynamic>> data;
  late List<Map<String, dynamic>> physical;
  late List<Map<String, dynamic>> oncall;
  late List<Map<String, dynamic>> profiles;
  void initState() {
    super.initState();
    // Map<String, dynamic> documents =
    // FirestoreService2().getDocumentsWithIds("patient_info");
    // FirestoreService2().fetchPatientsWithFollowUpDateTomorrow();
    // FirestoreService2().fetchPatientsWithPendingPayment();
    // FirebaseService.printData();
    // print(FirebaseService.globalSchedule);
    fetchData();
    fetchProfile();
    // print(profiles[0]['data']['followUpDetails'][0].values);
    // findSingleFollowUpInCurrentMonth(FirebaseService.globalDocs);
    // findMultipleFollowUpsInCurrentMonth(FirebaseService.globalDocs);
  }

  // Function to update followUpDetails key with caseTakenDate

  List<String> findSingleFollowUpInCurrentMonth(
      List<Map<String, dynamic>> data) {
    List<String> names = [];
    DateTime now = DateTime.now();
    String currentMonthYear =
        "${now.month.toString().padLeft(2, '0')}/${now.year}";
    for (var entry in data) {
      var followUpDetails = entry['data']['caseTakenDate'];

      // print(dateStr);
      // dateStr = dateStr.replaceAll("(", "").replaceAll(")", "");
      if (followUpDetails.endsWith(currentMonthYear)) {
        names.add(entry['data']['name']);
      }
    }
    // print(names);
    return names;
  }

  List<String> findMultipleFollowUpsInCurrentMonth(
      List<Map<String, dynamic>> data) {
    List<String> names = [];
    DateTime now = DateTime.now();
    String currentMonthYear =
        "${now.month.toString().padLeft(2, '0')}/${now.year}";
    // print(currentMonthYear);

    for (var entry in data) {
      var followUpDetails = entry['data']['followUpDetails'];
      if (followUpDetails.length > 1) {
        for (var detail in followUpDetails) {
          var dateStr = detail.keys.first;
          if (dateStr.endsWith(currentMonthYear)) {
            names.add(entry['data']['name']);
            break;
          }
        }
      }
    }
    // print("MULTIPLE");
    // print(names);
    return names;
  }

  Future<void> fetchData() async {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 0)); //FOLLOWUP DATE CALLING
    String formattedTomorrow = DateFormat('d/M/yyyy').format(tomorrow);
    formattedTomorrow = formattedTomorrow.replaceAll('/', 'A');
    data = FirebaseService.globalDocs;
    data = data.where((patient) {
      return patient['data']['appointmentToday'] == formattedTomorrow;
    }).toList();
    setState(() {
      physical = data.where((patient) {
        return patient['data']['appointmentType'] == 'physical';
      }).toList();
      // print(physical);
      oncall = data.where((patient) {
        return patient['data']['appointmentType'] == 'oncall';
      }).toList();
    });
  }

  Future<void> fetchProfile() async {
    profiles = FirebaseService.globalDocs;
  }

  String getCurrentDayAndTime() {
    DateTime now = DateTime.now();
    String day = _getDayOfWeek(now.weekday);
    String time = _formatTime(now);
    return '$day, $time';
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String minuteStr = minute < 10 ? '0$minute' : '$minute';
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Adjust hour to be in 12-hour format
    return '$hour:$minuteStr $period';
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  OverlayEntry? overlayEntry;
  @override
  Widget build(BuildContext context) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;

    final TextStyle textStyle = GoogleFonts.exo2(
      fontStyle: FontStyle.italic,
      color: Colors.white,
    );
    final TextStyle textStyle2 = GoogleFonts.exo2(
      fontSize: 18,
      color: Colors.black,
    );
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: headings2, top: (headings2 * 4), right: headings2),
            child: Text(
              getCurrentDayAndTime(),
              style: GoogleFonts.exo2(
                  fontSize: headings1, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 1.15,
            // decoration: BoxDecoration(
            //     border: Border.all(
            //   width: 1,
            // )),
            child: Padding(
              padding: EdgeInsets.only(
                right: headings2 * 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width / 2.05,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 0.0, left: headings2),
                                child: Text(
                                  "Dashboard",
                                  style: GoogleFonts.exo2(
                                      fontSize: headings1,
                                      fontWeight: FontWeight.bold),
                                )),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: headings2),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(83, 22, 107, 1),
                                      // gradient: LinearGradient(
                                      //   colors: [
                                      //     // Color.fromRGBO(132, 112, 255, 1),
                                      //     Color.fromRGBO(65, 160, 166, 1),
                                      //     Color.fromRGBO(65, 160, 166, 1),
                                      //     Color.fromRGBO(62, 54, 176, 1)
                                      //   ],
                                      //   begin: Alignment.centerLeft,
                                      //   end: Alignment.centerRight,
                                      // ),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: headings2),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: headings2 * 2),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: getGreeting() + ", ",
                                                    style: GoogleFonts.exo2(
                                                        fontSize: headings1,
                                                        color: Colors.white),
                                                    children: const <TextSpan>[
                                                      TextSpan(
                                                          text: 'Doc!',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.yellow,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: headings5),
                                                child: Text(
                                                  "Hope you have a good day!",
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.white60,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: headings2 * 3),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.5,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .userGroup,
                                                        color: Colors.white,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            55,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left:
                                                                    headings4),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              findSingleFollowUpInCurrentMonth(
                                                                      FirebaseService
                                                                          .globalDocs)
                                                                  .length
                                                                  .toString(),
                                                              style: GoogleFonts.exo2(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      headings2),
                                                            ),
                                                            Text(
                                                              "New Patients this month",
                                                              style: GoogleFonts.exo2(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      headings5),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .squarePhone,
                                                        color: Colors.white,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            50,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left:
                                                                    headings4),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              findMultipleFollowUpsInCurrentMonth(
                                                                      FirebaseService
                                                                          .globalDocs)
                                                                  .length
                                                                  .toString(),
                                                              style: GoogleFonts.exo2(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      headings2),
                                                            ),
                                                            Text(
                                                              "Follow-ups this month",
                                                              style: GoogleFonts.exo2(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      headings5),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                  // decoration:
                                  //     BoxDecoration(border: Border.all()),
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width: MediaQuery.of(context).size.width / 9,
                                  child: Image(
                                      fit: BoxFit.fill,
                                      image: AssetImage("assets/homepic.png"))),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: headings2),
                        child: Container(
                            width: MediaQuery.of(context).size.width / 2.1,
                            // height: MediaQuery.of(context).size.height / 2.5,
                            decoration: BoxDecoration(
                                color:
                                    Colors.deepPurple.shade100.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: headings2,
                                      top: headings2,
                                      bottom: headings2),
                                  child: Text(
                                    " Physical Appointments",
                                    style: GoogleFonts.exo2(
                                        fontSize: headings2,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Divider(),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.1,
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  child: ListView.builder(
                                      itemCount: (physical.isEmpty)
                                          ? 1
                                          : physical.length,
                                      itemBuilder: (context, index) {
                                        if (physical.isEmpty) {
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            child: Center(
                                              child: Text(
                                                "No physical appointments today!",
                                                style: GoogleFonts.exo2(
                                                    fontSize: headings3,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () {
                                              navv.followUpPageArgument.value =
                                                  physical[index]['id'];
                                              navv.pageController.jumpToPage(9);
                                            },
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: headings2 * 2,
                                                    vertical: headings2),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(index.toString()),
                                                    Container(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                                // border: Border.all(),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: 100,
                                                              // border: Border
                                                              //     .all()),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    physical[index]
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'appointmentFrom'],
                                                                    style: GoogleFonts.exo2(
                                                                        fontSize:
                                                                            headings3),
                                                                  ),
                                                                  Text(
                                                                    physical[index]
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'appointmentTo'],
                                                                    style: GoogleFonts.exo2(
                                                                        fontSize:
                                                                            headings3),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  5.5,
                                                              child: Center(
                                                                child: Text(
                                                                  physical[index]
                                                                          [
                                                                          'data']
                                                                      ['name'],
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      textStyle2,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 0,
                                                            ),
                                                            Text(
                                                              physical[index]
                                                                      ['data'][
                                                                  'contactNumber'],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: headings2,
                      top: headings2 * 4.5,
                      bottom: headings2 * 2,
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        // height: MediaQuery.of(context).size.height / 1.25,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                // Color.fromRGBO(132, 112, 255, 1),
                                Color.fromRGBO(83, 22, 107, 1),
                                Color.fromRGBO(83, 22, 107, 1),
                                Color.fromRGBO(143, 37, 185, 1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: headings2, top: headings2),
                              child: Text(
                                "On-Call Appointments ",
                                style: GoogleFonts.exo2(
                                    fontSize: headings2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  // decoration:
                                  //     BoxDecoration(border: Border.all()),
                                  height:
                                      MediaQuery.of(context).size.height / 1.75,
                                  child: ListView.builder(
                                    itemCount:
                                        oncall.isEmpty ? 1 : oncall.length,
                                    itemBuilder: (context, index) {
                                      if (oncall.isEmpty) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.5,
                                          child: Center(
                                            child: Text(
                                              'No on-call appointments today!',
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings3,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return GestureDetector(
                                          onTap: () {
                                            navv.followUpPageArgument.value =
                                                oncall[index]['id'];
                                            navv.pageController.jumpToPage(9);
                                          },
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: headings2,
                                                  vertical: headings2),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                padding:
                                                    EdgeInsets.all(headings2),
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                          143, 37, 185, 1)
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          (oncall[index]['data']
                                                                      [
                                                                      'name'] ??
                                                                  'NA')
                                                              .toString(),
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings3,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              oncall[index][
                                                                          'data']
                                                                      [
                                                                      'appointmentFrom'] ??
                                                                  'NA',
                                                              style: GoogleFonts
                                                                  .exo2(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                            SizedBox(width: 20),
                                                            Text(
                                                              oncall[index][
                                                                          'data']
                                                                      [
                                                                      'appointmentTo'] ??
                                                                  'NA',
                                                              style: GoogleFonts
                                                                  .exo2(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: headings5),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "|",
                                                            style: GoogleFonts
                                                                .exo2(
                                                                    fontSize:
                                                                        headings4,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5.0,
                                                                    top: 2),
                                                            child: Icon(
                                                                Icons.phone,
                                                                color: Colors
                                                                    .white,
                                                                size: 12),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5.0),
                                                            child: Text(
                                                              oncall[index][
                                                                          'data']
                                                                      [
                                                                      'contactNumber'] ??
                                                                  'NA',
                                                              style: GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings4,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
