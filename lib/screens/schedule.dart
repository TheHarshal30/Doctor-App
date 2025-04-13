// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, unused_import, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:medigine/screens/navigation.dart' as navv;

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  int _selecPT = -1;
  List<Patient> followUpPatients = [];
  late List<Map<String, dynamic>> _data;
  late List<Map<String, dynamic>> _filteredData;
  List<Map<String, dynamic>> data = [];
  TextEditingController _starttimeslot = TextEditingController();
  TextEditingController _endtimeslot = TextEditingController();
  var oncall = 0;
  var physical = 0;
  var loded = 0;
  @override
  void initState() {
    super.initState();
    // fetchFollowUps();
    fetchData();
  }

  Future<void> _addPatient(String docid, String type, String from, String to,
      String name, String phNo) async {
    try {
      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(Duration(days: 1));
      String formattedTomorrow = DateFormat('d/M/yyyy').format(tomorrow);
      formattedTomorrow = formattedTomorrow.replaceAll('/', 'A');
      var patientRef = FirebaseFirestore.instance.collection(db).doc(docid);
      await patientRef.update({
        'appointmentFrom': from,
        'appointmentTo': to,
        'appointmentType': type,
        'appointmentToday': formattedTomorrow,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment scheduled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to add appointment, CHECK YOUR INTERNET CONNECTION OR RESTART THE APPLICATION: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchData() async {
    await FirebaseService().temp();
    data = FirebaseService.globalDocs;
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));
    String formattedTomorrow = DateFormat('d/M/yyyy').format(tomorrow);
    print(formattedTomorrow);
    setState(() {
      _data = data.where((patient) {
        return patient['data']['followUpDate'] == formattedTomorrow.toString();
      }).toList();
      _filteredData = List.from(_data);
      // print(_filteredData[0]['data']['name']);
      loded = 1;
    });
  }

  Future<void> refreshData() async {
    await FirebaseService().temp();
    await fetchData();
  }

  TextEditingController followupDate = TextEditingController();
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, String docId) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";

      try {
        // Update Firebase with the selected date
        await _firestore
            .collection(db) // replace with your collection name
            .doc(docId)
            .update({'followUpDate': controller.text});
        await refreshData();

        // Show success snackbar with green background
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow-up date updated successfully!'),
            backgroundColor: Colors.green, // Green for success
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        // Show error snackbar with red background
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update follow-up date: $e'),
            backgroundColor: Colors.red, // Red for error
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _updateFollowUp(String docId) async {
    await _firestore.collection(db).doc(docId).update({'followUpDate': '-'});
    refreshData();
  }

  Future<void> _showConfirmationDialog(BuildContext context, String docId,
      String type, int dcc, String name, String phNo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are you sure you want include this patient in tomorrow's follow up",
                  style: GoogleFonts.exo2(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _addPatient(_filteredData[dcc]['id'], type, _starttimeslot.text,
                    _endtimeslot.text, name, phNo);
                _updateFollowUp(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(fontSize: 14);
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 70;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: headings1, left: headings3, right: headings1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Schedule Appointments",
                  style: GoogleFonts.exo2(
                      fontSize: headings2, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    navv.pageController.jumpToPage(11);
                  },
                  child: Row(
                    children: [
                      Text(
                        "All FollowUps",
                        style: GoogleFonts.exo2(
                            color: Colors.white, fontSize: headings4),
                      ),
                      SizedBox(
                        width: headings3,
                      ),
                      Icon(
                        FontAwesomeIcons.arrowRightLong,
                        size: headings4,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: headings2 * 5, top: headings2 * 2),
            child: Text(
              "Patient's eligible for tomorrow's appointment",
              style: GoogleFonts.exo2(fontSize: headings2),
            ),
          ),
          (loded == 1)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: headings2 * 5, top: headings2),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: ListView.builder(
                          itemCount: _filteredData.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selecPT = index;
                                    if (_filteredData[_selecPT]['data']
                                            ['startTime'] !=
                                        null) {
                                      _starttimeslot.text =
                                          _filteredData[_selecPT]['data']
                                              ['startTime'];
                                      _endtimeslot.text =
                                          _filteredData[_selecPT]['data']
                                              ['endTime'];
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: headings5),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 10,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: headings2,
                                                  top: headings2),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: headings3,
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    _filteredData[index]['data']
                                                        ['name'],
                                                    style: GoogleFonts.exo2(
                                                      fontSize: headings2,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: headings2,
                                                  left: headings2),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: headings2),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.phone,
                                                          size: headings4,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          _filteredData[index]
                                                                  ['data']
                                                              ['contactNumber'],
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings4),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: headings2),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .stethoscope,
                                                          size: headings4,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          _filteredData[index]
                                                                  ['data']
                                                              ['consultant'],
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings3),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .userDoctor,
                                                        size: headings4,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        _filteredData[index]
                                                                ['data']
                                                            ['caseTakenBy'],
                                                        style: GoogleFonts.exo2(
                                                            fontSize:
                                                                headings3),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(right: headings2),
                                          child:
                                              Icon(FontAwesomeIcons.caretRight),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: headings2 * 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 1.8,
                            width: MediaQuery.of(context).size.width / 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: headings2),
                                    child: Text(
                                      "Patient Summary",
                                      style: GoogleFonts.exo2(
                                        fontSize: headings2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                (_selecPT != -1)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: headings2),
                                              child: Text(
                                                _filteredData[_selecPT]['data']
                                                    ['name'],
                                                style: GoogleFonts.exo2(
                                                    fontSize: headings2),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: headings2,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2),
                                            child: Text(
                                              "Description",
                                              style: GoogleFonts.exo2(
                                                fontSize: headings3,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings5),
                                            child: Container(
                                              padding:
                                                  EdgeInsets.all(headings5),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .deepPurple.shade100
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  7,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  5,
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  _filteredData[_selecPT]
                                                          ['data']
                                                      ['additionalDescription'],
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.exo2(
                                                    fontSize: headings3,
                                                    wordSpacing: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings2),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Consultant   ',
                                                style: GoogleFonts.exo2(
                                                  color: Colors.black,
                                                  fontSize: headings3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        _filteredData[_selecPT]
                                                                ['data']
                                                            ['consultant'],
                                                    style: GoogleFonts.exo2(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: headings3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings2),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Case Taken By   ',
                                                style: GoogleFonts.exo2(
                                                  color: Colors.black,
                                                  fontSize: headings3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        _filteredData[_selecPT]
                                                                ['data']
                                                            ['caseTakenBy'],
                                                    style: GoogleFonts.exo2(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: headings3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings2),
                                            child: Text(
                                              "Time Slot for Appointment",
                                              style: GoogleFonts.exo2(
                                                color: Colors.black,
                                                fontSize: headings3,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings5),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      20,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade600),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: TextField(
                                                    controller: _starttimeslot,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left:
                                                                    headings5 /
                                                                        2,
                                                                top: headings5,
                                                                bottom:
                                                                    headings5,
                                                                right:
                                                                    headings5 /
                                                                        2),
                                                        border: InputBorder
                                                            .none,
                                                        hintText: "10:00 AM",
                                                        hintStyle:
                                                            GoogleFonts.exo2(
                                                                fontSize:
                                                                    headings3)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: headings5 / 2,
                                                      right: headings5 / 2),
                                                  child: SizedBox(
                                                    width: headings2,
                                                    child: Text(
                                                      "-",
                                                      style: GoogleFonts.exo2(
                                                          fontSize: headings1),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      20,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade600),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: TextField(
                                                    controller: _endtimeslot,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left:
                                                                    headings5 /
                                                                        2,
                                                                top: headings5,
                                                                bottom:
                                                                    headings5,
                                                                right:
                                                                    headings5 /
                                                                        2),
                                                        border: InputBorder
                                                            .none,
                                                        hintText: "10:00 AM",
                                                        hintStyle:
                                                            GoogleFonts.exo2(
                                                                fontSize:
                                                                    headings3)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: headings2,
                                                top: headings2),
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        oncall ^= 1;
                                                        physical = 0;
                                                      });
                                                      print("physical: " +
                                                          physical.toString());
                                                      print("on call: " +
                                                          oncall.toString());
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          (oncall == 1)
                                                              ? Colors.green
                                                              : Colors
                                                                  .deepPurple,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .mobileRetro,
                                                          size: headings5,
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          "On-Call",
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings4),
                                                        )
                                                      ],
                                                    )),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        physical ^= 1;
                                                        oncall = 0;
                                                      });
                                                      print("physical: " +
                                                          physical.toString());
                                                      print("on call: " +
                                                          oncall.toString());
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          (physical == 1)
                                                              ? Colors.green
                                                              : Colors
                                                                  .deepPurple,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .person,
                                                          size: headings5,
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          "Physical",
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings4),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: headings2 * 10),
                                          child: Column(
                                            children: [
                                              Text(
                                                "No Patient Selected",
                                                style: GoogleFonts.exo2(
                                                  fontSize: headings3,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "Tap on a patient to view details",
                                                style: GoogleFonts.exo2(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          (_selecPT != -1)
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 0.0, top: headings5),
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            _selectDate(context, followupDate,
                                                _filteredData[_selecPT]['id']);
                                            setState(() {
                                              _selecPT = -1;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.ban,
                                                size: 14,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Cancel",
                                                style: GoogleFonts.exo2(
                                                    fontSize: headings4),
                                              )
                                            ],
                                          )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            String type = (physical == 1)
                                                ? "physical"
                                                : "oncall";
                                            var ptdocid = _selecPT;
                                            _showConfirmationDialog(
                                                context,
                                                _filteredData[ptdocid]['id'],
                                                type,
                                                ptdocid,
                                                _filteredData[ptdocid]['data']
                                                    ['name'],
                                                _filteredData[ptdocid]['data']
                                                    ['contactNumber']);
                                            setState(() {
                                              _selecPT = -1;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.checkToSlot,
                                                size: 14,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Approve",
                                                style: GoogleFonts.exo2(
                                                    fontSize: headings4),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class Patient {
  final String name;
  final String contactNumber;
  final String caseTakenBy;
  final String consultant;
  final String additionalDescription;
  final String courseSuggested;
  final String caseSummary;

  Patient({
    required this.name,
    required this.contactNumber,
    required this.caseTakenBy,
    required this.consultant,
    required this.additionalDescription,
    required this.courseSuggested,
    required this.caseSummary,
  });

  factory Patient.fromFirestore(Map<String, dynamic> data) {
    return Patient(
      name: data['name'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      caseTakenBy: data['caseTakenBy'] ?? '',
      consultant: data['consultant'] ?? '',
      additionalDescription: data['additionalDescription'] ?? '',
      courseSuggested: data['courseSuggested'] ?? '',
      caseSummary: data['caseSummary'] ?? '',
    );
  }
}
