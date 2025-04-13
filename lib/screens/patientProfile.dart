// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, unused_field, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_element, prefer_const_declarations, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:medigine/components/messageOptions.dart';
import 'package:medigine/screens/testing.dart';
import 'package:medigine/screens/utils.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:medigine/screens/testing.dart' as test;
import 'package:path/path.dart' as path;
import 'package:medigine/screens/navigation.dart' as navv;

class PatientProfile extends StatefulWidget {
  final String docID;
  const PatientProfile({super.key, required this.docID});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    fetchAndFillPatientData(widget.docID);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _registrationNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _diagnosisController = TextEditingController();
  TextEditingController _additionalDescriptionController =
      TextEditingController();
  TextEditingController _additionalNotesController = TextEditingController();
  TextEditingController _consultantController = TextEditingController();
  TextEditingController _caseTakenDateController = TextEditingController();
  TextEditingController _followUpDateController = TextEditingController();
  TextEditingController _courseSuggestedController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _sexController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _martialStatusController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _referredByController = TextEditingController();

  TextEditingController _addressController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _caseTakenByController = TextEditingController();
  TextEditingController _weeklyCharges = TextEditingController();
  var active = 0;
  var inactive = 0;
  bool isEdit = false;
  void printAllText() async {
    var patient = {
      'name': _nameController.text,
      'age': _ageController.text,
      'sex': _sexController.text,
      'address': _addressController.text,
      'contactNumber': _contactNumberController.text,
      'consultant': _consultantController.text,
      'diagnosis': _diagnosisController.text,
      'registrationNumber': _registrationNumberController.text,
      'qualification': _qualificationController.text,
      'martialStatus': _martialStatusController.text,
      'dob': _dobController.text,
      'email': _emailController.text,
      'caseTakenBy': _caseTakenByController.text,
      'referredBy': _referredByController.text,
      'courseSuggested': _courseSuggestedController.text,
      'caseTakenDate': _caseTakenDateController.text,
      'followUpDate': _followUpDateController.text,
      'additionalDescription': _additionalNotesController.text,
      'weeklyCharges': _weeklyCharges.text,
      'patientStatus': (active == 1)
          ? "Active"
          : (inactive == 1)
              ? "Inactive"
              : "reeval",
    };

    // Add patient to Firestore
    var patientRef =
        FirebaseFirestore.instance.collection(db).doc(widget.docID);
    await patientRef.update(patient);
    await FirebaseService().temp();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('DETAILS UPDATED'),
        backgroundColor: Colors.green,
      ),
    );

    // print('Name: ${_nameController.text}');
    // print('Contact Number: ${_contactNumberController.text}');
    // print('Registration Number: ${_registrationNumberController.text}');
    // print('Email: ${_emailController.text}');
    // print('Diagnosis: ${_diagnosisController.text}');
    // print('Additional Description: ${_additionalDescriptionController.text}');
    // print('Consultant: ${_consultantController.text}');
    // print('Case Taken Date: ${_caseTakenDateController.text}');
    // print('Follow-Up Date: ${_followUpDateController.text}');
    // print('Course Suggested: ${_courseSuggestedController.text}');
    // print('Age: ${_ageController.text}');
    // print('Sex: ${_sexController.text}');
    // print('Qualification: ${_qualificationController.text}');
    // print('Marital Status: ${_martialStatusController.text}');
    // print('Date of Birth: ${_dobController.text}');
    // print('Referred By: ${_referredByController.text}');
    // print('Address: ${_addressController.text}');
    // print('Occupation: ${_occupationController.text}');
    // print('Case Taken By: ${_caseTakenByController.text}');
  }

  List<DateTime> dates = [DateTime.now()];
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        dates.add(picked);
        dates.sort((a, b) => b.compareTo(a));
      });
  }

  DateTime calculateFollowUpDate(String course, DateTime startDate) {
    // Check if the course is empty or contains no digits
    if (course.isEmpty || !RegExp(r'\d').hasMatch(course)) {
      // Handle the invalid input scenario
      throw Exception('Invalid course input');
    }

    // Extract the number of DR from the course string
    int numberOfDays = int.parse(course.replaceAll('DR', '')) * 7;
    // Calculate the follow-up date by adding the number of days to the start date
    return startDate.add(Duration(days: numberOfDays));
  }

  void _calculateFollowUpDate() {
    String course = _courseSuggestedController.text;

    try {
      // Calculate follow-up date only if valid input
      DateTime followUpDate = calculateFollowUpDate(course, DateTime.now());
      _followUpDateController.text =
          "${followUpDate.day}/${followUpDate.month}/${followUpDate.year}";
    } catch (e) {
      // Handle invalid input, e.g., show an error message
      print('Error: ${e.toString()}');
    }
  }

  List<dynamic> prevFollows = [];

  Future<void> fetchAndFillPatientData(String docID) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection(db).doc(docID).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      print(data['followUpDetails']);
      setState(() {
        prevFollows = data['followUpDetails'] ?? 'Not Available';
        _nameController.text = data['name'] ?? 'Not available';
        _contactNumberController.text =
            data['contactNumber'] ?? 'Not available';
        _registrationNumberController.text =
            data['registrationNumber'] ?? 'Not available';
        _emailController.text = data['email'] ?? 'Not available';
        _diagnosisController.text = data['diagnosis'] ?? 'Not available';
        _additionalDescriptionController.text =
            data['additionalDescription'] ?? 'Not available';
        _additionalNotesController.text =
            data['additionalDescription'] ?? 'Not available';
        _consultantController.text = data['consultant'] ?? 'Not available';

        _caseTakenDateController.text =
            data['caseTakenDate'] ?? 'Not available';

        _followUpDateController.text = data['followUpDate'] ?? 'Not available';

        _courseSuggestedController.text =
            data['medicines'][0].keys.toString() ?? 'Not available';
        _ageController.text =
            data['age'] != null ? data['age'].toString() : 'Not available';
        _sexController.text = data['sex'] ?? 'Not available';
        _qualificationController.text =
            data['qualification'] ?? 'Not available';
        _martialStatusController.text =
            data['martialStatus'] ?? 'Not available';

        _dobController.text = data['dob'] ?? 'Not available';
        _weeklyCharges.text = data['weeklyCharges'] ?? "Not available";
        _referredByController.text = data['referredBy'] ?? 'Not available';
        _addressController.text = data['address'] ?? 'Not available';
        _occupationController.text = data['ocuupation'] ?? 'Not available';
        active = (data['patientStatus'] == "Active") ? 1 : 0;
        inactive = (data['patientStatus'] == "Inactive" ||
                data['patientStatus'] == "not available")
            ? 1
            : 0;
      });

      _caseTakenByController.text = data['caseTakenBy'] ?? 'Not available';
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
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: headings2, top: headings2 * 2, bottom: headings2),
                    child: Text(
                      "Patient Information",
                      style: GoogleFonts.exo2(
                          color: Colors.black,
                          fontSize: headings1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(right: headings2, top: headings2 * 2),
                    child: ElevatedButton(
                        onPressed: () {
                          isEdit
                              ? setState(() {
                                  isEdit = false;
                                  printAllText();
                                })
                              : setState(() {
                                  isEdit = true;
                                });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: headings5, vertical: headings5),
                          child: Text(
                            isEdit ? "Save" : "Edit",
                            style: GoogleFonts.exo2(fontSize: headings3),
                          ),
                        )),
                  )
                  // Padding(
                  //   padding:
                  //       EdgeInsets.only(right: headings2, top: headings2 * 2),
                  //   child: ElevatedButton(
                  //       onPressed: () {
                  // isEdit
                  //     ? setState(() {
                  //         isEdit = false;
                  //         _calculateFollowUpDate();
                  //         printAllText();
                  //       })
                  //     : setState(() {
                  //         isEdit = true;
                  //       });
                  //       },
                  //       child: Padding(
                  // padding: EdgeInsets.symmetric(
                  //     horizontal: headings5, vertical: headings5),
                  //         child: Text(
                  //           isEdit ? "Save" : "Edit",
                  //           style: GoogleFonts.exo2(fontSize: headings3),
                  //         ),
                  //       )),
                  // )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: headings2, bottom: headings5),
                    child: Container(
                      padding: EdgeInsets.only(bottom: headings2 * 5),
                      height: isEdit
                          ? MediaQuery.of(context).size.height * 1.25
                          : MediaQuery.of(context).size.height / 1.05,
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: headings2, top: headings2, right: headings2),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: headings5),
                                  child: isEdit
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: TextField(
                                            decoration: InputDecoration(),
                                            controller: _nameController,
                                          ),
                                        )
                                      : Text(
                                          _nameController.text,
                                          style: GoogleFonts.exo2(
                                              color: Colors.black,
                                              fontSize: headings2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 40.0),
                                //   child: Text(
                                //     "General Details",
                                //     style: GoogleFonts.exo2(
                                //       color: Colors.black,
                                //       fontSize: 18,
                                //     ),
                                //   ),
                                // ),
                                // Divider(
                                //   thickness: 2,
                                // ),
                                // Container(
                                //   // decoration: BoxDecoration(border: Border.all()),
                                //   width: MediaQuery.of(context).size.width / 3,
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Row(
                                //             children: [
                                //               Icon(FontAwesomeIcons.imagePortrait,
                                //                   size: 20),
                                //               Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     left: 8.0),
                                //                 child: Text(
                                //                   "18" +
                                //                       _ageController.text +
                                //                       " yrs",
                                //                   style: GoogleFonts.exo2(
                                //                       color: Colors.black,
                                //                       fontSize: 16),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //           Row(
                                //             children: [
                                //               Icon(FontAwesomeIcons.mars, size: 20),
                                //               Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     left: 8.0),
                                //                 child: Text(
                                //                   "Male" + _sexController.text,
                                //                   style: GoogleFonts.exo2(
                                //                       color: Colors.black,
                                //                       fontSize: 16),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //           Row(
                                //             children: [
                                //               Icon(Icons.call),
                                //               Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     left: 8.0),
                                //                 child: Text(
                                //                   "124578954" +
                                //                       _contactNumberController.text,
                                //                   style: GoogleFonts.exo2(
                                //                       color: Colors.black,
                                //                       fontSize: 16),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //           Row(
                                //             children: [
                                //               Icon(Icons.email),
                                //               Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     left: 8.0),
                                //                 child: Text(
                                //                   "hasfas@gmail.com" +
                                //                       _emailController.text,
                                //                   style: GoogleFonts.exo2(
                                //                       color: Colors.black,
                                //                       fontSize: 16),
                                //                 ),
                                //               ),
                                //             ],
                                //           )
                                //         ],
                                //       ),
                                //       Padding(
                                //         padding: const EdgeInsets.only(top: 20.0),
                                //         child: Container(
                                //           width: MediaQuery.of(context).size.width /
                                //               4.7,
                                //           child: Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.spaceBetween,
                                //             crossAxisAlignment:
                                //                 CrossAxisAlignment.start,
                                //             children: [
                                //               Row(
                                //                 children: [
                                //                   Icon(FontAwesomeIcons.briefcase,
                                //                       size: 18),
                                //                   Padding(
                                //                     padding: const EdgeInsets.only(
                                //                         left: 8.0),
                                //                     child: Text(
                                //                       "Engineer" +
                                //                           _qualificationController
                                //                               .text,
                                //                       style: GoogleFonts.exo2(
                                //                           color: Colors.black,
                                //                           fontSize: 16),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //               Row(
                                //                 children: [
                                //                   Icon(FontAwesomeIcons.heartCrack,
                                //                       size: 20),
                                //                   Padding(
                                //                     padding: const EdgeInsets.only(
                                //                         left: 8.0),
                                //                     child: Text(
                                //                       "Single" +
                                //                           _martialStatusController
                                //                               .text,
                                //                       style: GoogleFonts.exo2(
                                //                           color: Colors.black,
                                //                           fontSize: 16),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //               Row(
                                //                 children: [
                                //                   Icon(
                                //                       FontAwesomeIcons.calendarDay),
                                //                   Padding(
                                //                     padding: const EdgeInsets.only(
                                //                         left: 8.0),
                                //                     child: Text(
                                //                       "30-07-2004" +
                                //                           _dobController.text,
                                //                       style: GoogleFonts.exo2(
                                //                           color: Colors.black,
                                //                           fontSize: 16),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //       Padding(
                                //         padding: const EdgeInsets.only(top: 30.0),
                                //         child: Row(
                                //           children: [
                                //             Icon(FontAwesomeIcons.locationDot,
                                //                 size: 18),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.only(left: 8.0),
                                //               child: Text(
                                //                 "11, Ganganager Society, Tilak Chowk, Kalyan(W)" +
                                //                     _addressController.text,
                                //                 style: GoogleFonts.exo2(
                                //                     color: Colors.black,
                                //                     fontSize: 16),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                // Padding(
                                //   padding: const EdgeInsets.only(top: 40.0),
                                //   child: Text(
                                //     "Case",
                                //     style: GoogleFonts.exo2(
                                //       color: Colors.black,
                                //       fontSize: 18,
                                //     ),
                                //   ),
                                // ),
                                Divider(
                                  height:
                                      MediaQuery.of(context).size.height / 30,
                                  thickness: 2,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 0.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Registration No.",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    decoration:
                                                        InputDecoration(),
                                                    controller:
                                                        _registrationNumberController,
                                                  ),
                                                )
                                              : Text(
                                                  _registrationNumberController
                                                      .text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Diagnosis",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    decoration:
                                                        InputDecoration(),
                                                    controller:
                                                        _diagnosisController,
                                                  ),
                                                )
                                              : Text(
                                                  _diagnosisController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 30.0),
                                    //   child: Row(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Container(
                                    //         width: MediaQuery.of(context)
                                    //                 .size
                                    //                 .width /
                                    //             10,
                                    //         child: Text(
                                    //           "Additional Case Information",
                                    //           style: GoogleFonts.exo2(
                                    //             color: Colors.grey.shade700,
                                    //             fontSize: 16,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Container(
                                    //         height: MediaQuery.of(context)
                                    //                 .size
                                    //                 .height /
                                    //             7,
                                    //         width: MediaQuery.of(context)
                                    //                 .size
                                    //                 .width /
                                    //             3,
                                    //         decoration: BoxDecoration(
                                    //             borderRadius:
                                    //                 BorderRadius.circular(10),
                                    //             border: Border.all(
                                    //                 width: 0.5,
                                    //                 color: Colors.grey)),
                                    //         padding: EdgeInsets.all(8),
                                    //         child: SingleChildScrollView(
                                    //           child: isEdit
                                    //               ? Container(
                                    //                   width:
                                    //                       MediaQuery.of(context)
                                    //                               .size
                                    //                               .width /
                                    //                           3,
                                    //                   child: TextField(
                                    //                     maxLines: 100,
                                    //                     decoration:
                                    //                         InputDecoration(
                                    //                       border:
                                    //                           InputBorder.none,
                                    //                       focusedBorder:
                                    //                           InputBorder.none,
                                    //                       enabledBorder:
                                    //                           InputBorder.none,
                                    //                       errorBorder:
                                    //                           InputBorder.none,
                                    //                       disabledBorder:
                                    //                           InputBorder.none,
                                    //                       contentPadding:
                                    //                           EdgeInsets.all(0),
                                    //                     ),
                                    //                     controller:
                                    //                         _additionalDescriptionController,
                                    //                   ),
                                    //                 )
                                    //               : Text(
                                    //                   _additionalDescriptionController
                                    //                       .text,
                                    //                   style: GoogleFonts.exo2(
                                    //                     color:
                                    //                         Colors.grey.shade700,
                                    //                     fontSize: 16,
                                    //                   ),
                                    //                 ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),

                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Consultant",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    decoration:
                                                        InputDecoration(),
                                                    controller:
                                                        _consultantController,
                                                  ),
                                                )
                                              : Text(
                                                  _consultantController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Case Taken",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    decoration:
                                                        InputDecoration(),
                                                    controller:
                                                        _caseTakenDateController,
                                                  ),
                                                )
                                              : Text(
                                                  _caseTakenDateController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Follow-up Date",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _followUpDateController,
                                                  ),
                                                )
                                              : Text(
                                                  _followUpDateController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Course Suggested",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _courseSuggestedController,
                                                    onSubmitted: (val) => {
                                                      _calculateFollowUpDate()
                                                    },
                                                  ),
                                                )
                                              : Text(
                                                  _courseSuggestedController
                                                      .text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Referred by: ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _referredByController,
                                                  ),
                                                )
                                              : Text(
                                                  _referredByController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Age",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller: _ageController,
                                                  ),
                                                )
                                              : Text(
                                                  _ageController.text +
                                                      " years",
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Gender",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller: _sexController,
                                                  ),
                                                )
                                              : Text(
                                                  _sexController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Contact Info: ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _contactNumberController,
                                                  ),
                                                )
                                              : Text(
                                                  _contactNumberController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Date of Birth: ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller: _dobController,
                                                  ),
                                                )
                                              : Text(
                                                  _dobController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Address",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                10,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.grey)),
                                            padding: EdgeInsets.all(headings5),
                                            child: isEdit
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3,
                                                    child: TextField(
                                                      maxLines: 100,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                      ),
                                                      controller:
                                                          _addressController,
                                                    ),
                                                  )
                                                : Text(
                                                    _addressController.text,
                                                    style: GoogleFonts.exo2(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: headings3,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Marital Status ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _martialStatusController,
                                                  ),
                                                )
                                              : Text(
                                                  _martialStatusController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Profession/ Education ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _occupationController,
                                                  ),
                                                )
                                              : Text(
                                                  _occupationController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Email ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller:
                                                        _emailController,
                                                  ),
                                                )
                                              : Text(
                                                  _emailController.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: headings2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                            child: Text(
                                              "Consultation + Weekly Charges ",
                                              style: GoogleFonts.exo2(
                                                color: Colors.grey.shade700,
                                                fontSize: headings3,
                                              ),
                                            ),
                                          ),
                                          isEdit
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: TextField(
                                                    controller: _weeklyCharges,
                                                  ),
                                                )
                                              : Text(
                                                  _weeklyCharges.text,
                                                  style: GoogleFonts.exo2(
                                                    color: Colors.grey.shade700,
                                                    fontSize: headings3,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: headings2 * 2),
                    // decoration: BoxDecoration(border: Border.all()),
                    height: MediaQuery.of(context).size.height / 1.1,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(right: 20.0, top: 00),
                              //   child: Container(
                              //     // decoration: BoxDecoration(border: Border.all()),
                              //     width: MediaQuery.of(context).size.width / 6,
                              //     child: TableCalendar<Event>(
                              //       firstDay: kFirstDay,
                              //       lastDay: kLastDay,
                              //       focusedDay: _focusedDay,
                              //       selectedDayPredicate: (day) =>
                              //           isSameDay(_selectedDay, day),
                              //       rangeStartDay: _rangeStart,
                              //       rangeEndDay: _rangeEnd,
                              //       calendarFormat: _calendarFormat,
                              //       rangeSelectionMode: _rangeSelectionMode,
                              //       eventLoader: _getEventsForDay,
                              //       startingDayOfWeek: StartingDayOfWeek.monday,
                              //       calendarStyle: CalendarStyle(
                              //         // Use `CalendarStyle` to customize the UI
                              //         markersMaxCount: 0,
                              //         todayDecoration: BoxDecoration(
                              //           color: Color.fromRGBO(83, 22, 107, 1),
                              //           shape: BoxShape.circle,
                              //         ),
                              //         selectedDecoration: BoxDecoration(
                              //           color: Color.fromRGBO(83, 22, 107, 1),
                              //           shape: BoxShape.circle,
                              //         ),
                              //         markerDecoration: BoxDecoration(),
                              //         outsideDaysVisible: true,
                              //       ),
                              //       onDaySelected: _onDaySelected,
                              //       onRangeSelected: _onRangeSelected,
                              //       onFormatChanged: (format) {
                              //         if (_calendarFormat != format) {
                              //           setState(() {
                              //             _calendarFormat = format;
                              //           });
                              //         }
                              //       },
                              //       onPageChanged: (focusedDay) {
                              //         _focusedDay = focusedDay;
                              //       },
                              //       calendarBuilders: CalendarBuilders(
                              //         defaultBuilder: (context, day, focusedDay) {
                              //           if (kEvents[day] != null &&
                              //               kEvents[day]!.isNotEmpty) {
                              //             return Container(
                              //               margin: const EdgeInsets.all(6.0),
                              //               alignment: Alignment.center,
                              //               decoration: BoxDecoration(
                              //                 color:
                              //                     Color.fromRGBO(83, 22, 107, 1),
                              //                 shape: BoxShape.circle,
                              //               ),
                              //               child: Text(
                              //                 '${day.day}',
                              //                 style: GoogleFonts.exo2(
                              //                     color: Colors.white),
                              //               ),
                              //             );
                              //           }
                              //           return null;
                              //         },
                              //         todayBuilder: (context, day, focusedDay) {
                              //           return Container(
                              //             margin: const EdgeInsets.all(6.0),
                              //             alignment: Alignment.center,
                              //             decoration: BoxDecoration(
                              //               color: Color.fromRGBO(83, 22, 107, 1),
                              //               shape: BoxShape.circle,
                              //             ),
                              //             child: Text(
                              //               '${day.day}',
                              //               style: GoogleFonts.exo2(
                              //                   color: Colors.white),
                              //             ),
                              //           );
                              //         },
                              //         selectedBuilder:
                              //             (context, day, focusedDay) {
                              //           return Container(
                              //             margin: const EdgeInsets.all(6.0),
                              //             alignment: Alignment.center,
                              //             decoration: BoxDecoration(
                              //               color: Color.fromRGBO(83, 22, 107, 1),
                              //               shape: BoxShape.circle,
                              //             ),
                              //             child: Text(
                              //               '${day.day}',
                              //               style: GoogleFonts.exo2(
                              //                   color: Colors.white),
                              //             ),
                              //           );
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              Padding(
                                padding: EdgeInsets.only(
                                    top: headings2, right: headings2),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: headings2,
                                      top: 0,
                                      right: headings2),
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400)),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: headings5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Prev Follow Ups",
                                          style: GoogleFonts.exo2(
                                              fontSize: headings3,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: headings5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.5,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: prevFollows.length,
                                                itemBuilder: (context, index) {
                                                  return MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        overlayEntry =
                                                            OverlayEntry(
                                                          builder: (context) =>
                                                              Center(
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  3,
                                                              child: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              headings2),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey,
                                                                        blurRadius:
                                                                            10.0,
                                                                        spreadRadius:
                                                                            2.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          prevFollows[index]
                                                                              .keys
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontSize: headings3)),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                5,
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Text(
                                                                            prevFollows[index].values.toString(),
                                                                            style:
                                                                                GoogleFonts.exo2(
                                                                              fontSize: headings3,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              headings1),
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          overlayEntry
                                                                              ?.remove();
                                                                        },
                                                                        child: Text(
                                                                            'Close'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );

                                                        Overlay.of(context)
                                                            .insert(
                                                                overlayEntry!);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom:
                                                                    headings4),
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 10,
                                                                  bottom: 5),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              5,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              12,
                                                          decoration:
                                                              BoxDecoration(
                                                                  // border: Border.all(),
                                                                  color: Colors
                                                                      .deepPurple
                                                                      .shade100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  prevFollows[
                                                                          index]
                                                                      .keys
                                                                      .toString(),
                                                                  style: GoogleFonts.exo2(
                                                                      fontSize:
                                                                          headings4,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade700),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              5.0),
                                                                  child: Text(
                                                                    prevFollows[
                                                                            index]
                                                                        .values
                                                                        .toString(),
                                                                    style:
                                                                        GoogleFonts
                                                                            .exo2(
                                                                      fontSize:
                                                                          headings3,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: headings2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Additional Notes",
                                  style: GoogleFonts.exo2(
                                      fontSize: headings2, color: Colors.black),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: headings2, top: headings5),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isEdit) {
                                          overlayEntry = OverlayEntry(
                                            builder: (context) => Center(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1.5,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        headings2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          blurRadius: 10.0,
                                                          spreadRadius: 2.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Center(
                                                              child: Text(
                                                                "Additional Notes",
                                                                style: GoogleFonts.exo2(
                                                                    fontSize:
                                                                        headings2,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: headings3,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.5,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2,
                                                              child: TextField(
                                                                maxLines: 100,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  focusedBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  enabledBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  errorBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  disabledBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                ),
                                                                controller:
                                                                    _additionalNotesController,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: headings3,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            overlayEntry
                                                                ?.remove();
                                                            setState(() {});
                                                          },
                                                          child: Text('Done'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );

                                          Overlay.of(context)
                                              .insert(overlayEntry!);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(headings2),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade100
                                                .withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            _additionalNotesController.text,
                                            style: GoogleFonts.exo2(
                                                wordSpacing: 2,
                                                fontSize: headings3,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 15,
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: headings2, top: headings2),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            navv.followUpPageArgument.value =
                                                widget.docID;
                                            navv.pageController.jumpToPage(9);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: headings5,
                                                vertical: headings5),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .calendarCheck,
                                                  size: headings3,
                                                ),
                                                SizedBox(
                                                  width: headings5,
                                                ),
                                                Text(
                                                  "Medicines",
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings3),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: headings2, top: headings2),
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            // Absolute path to your .bat file
                                            List<String> textValues = [
                                              _nameController.text,
                                              _ageController.text,
                                              _sexController.text,
                                              _addressController.text,
                                              _contactNumberController.text,
                                              _consultantController.text,
                                              _diagnosisController.text,
                                            ];
                                            List<String> textValues2 = [
                                              _registrationNumberController
                                                  .text,
                                              _qualificationController.text,
                                              _occupationController.text,
                                              _martialStatusController.text,
                                              _dobController.text,
                                              _emailController.text,
                                              _caseTakenByController.text,
                                              _referredByController.text,
                                              _caseTakenDateController.text,
                                            ];
                                            String tgt1 = path.join(
                                                "scripts", "run_print3.bat");
                                            String tgt2 = path.join(
                                                "scripts", "run_print4.bat");
                                            String scritpsDIR = path.join(
                                                Directory.current.path,
                                                'scripts');

                                            String batFilePath = path.join(
                                                Directory.current.path, tgt1);
                                            // print(batFilePath);
                                            String batFilePath2 = path.join(
                                                Directory.current.path, tgt2);
                                            List<String> args1 = textValues;
                                            List<String> args2 = textValues2;
                                            print(args1);
                                            print(args2);

                                            // Run the batch file with arguments
                                            ProcessResult result =
                                                await Process.run(
                                                    batFilePath, args1,
                                                    workingDirectory:
                                                        scritpsDIR);
                                            if (result.exitCode == 0) {
                                              ProcessResult result2 =
                                                  await Process.run(
                                                      batFilePath2, args2,
                                                      workingDirectory:
                                                          scritpsDIR);
                                              if (result2.exitCode == 0) {
                                                print("woohooo");
                                              }
                                            }

                                            // Check the result
                                            if (result.exitCode == 0) {
                                              print(
                                                  'Python script executed successfully.');
                                            } else {
                                              print('Error: ${result.stderr}');
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: headings5,
                                                vertical: headings5),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .rectangleList,
                                                  size: headings3,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  "Print Letter Head",
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings3),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                isEdit
                                    ? Padding(
                                        padding:
                                            EdgeInsets.only(top: headings4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        active ^= 1;
                                                        inactive = 0;
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          (active == 1)
                                                              ? Colors.green
                                                              : Colors
                                                                  .deepPurple,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .hourglass,
                                                          size: 14,
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text("Active",
                                                            style: GoogleFonts.exo(
                                                                fontSize:
                                                                    headings4))
                                                      ],
                                                    )),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        inactive ^= 1;
                                                        active = 0;
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          (inactive == 1)
                                                              ? Colors.green
                                                              : Colors
                                                                  .deepPurple,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .clipboardCheck,
                                                          size: 14,
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text("Inactive",
                                                            style: GoogleFonts.exo(
                                                                fontSize:
                                                                    headings4))
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(top: headings4),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Patient Status: ",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings3),
                                            ),
                                            Text(
                                              (active == 1)
                                                  ? "Active"
                                                  : "Inactive",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings3,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  void showMessageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageOptionsDialog();
      },
    );
  }

  String formatFullDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy');
    return formatter.format(dateTime);
  }
}

class MessageOptionsDialog extends StatefulWidget {
  @override
  _MessageOptionsDialogState createState() => _MessageOptionsDialogState();
}

class _MessageOptionsDialogState extends State<MessageOptionsDialog> {
  String _selectedOption = '';
  bool _showTemplate = false;

  final Map<String, String> messageTemplates = {
    'Appointment Reminder': 'This is a reminder for your upcoming appointment.',
    'Appointment Missed':
        'You have missed your appointment. Please reschedule.',
    'Tracking ID sharing': 'Here is your tracking ID: 1234567890.',
    'Payment Reminder': 'This is a reminder to complete your payment.'
  };

  void _onOptionSelected(String option) {
    setState(() {
      _selectedOption = option;
      _showTemplate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _showTemplate ? _buildMessageTemplate() : _buildOptions(),
    );
  }

  Widget _buildOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Appointment Reminder'),
          onTap: () => _onOptionSelected('Appointment Reminder'),
        ),
        ListTile(
          title: Text('Appointment Missed'),
          onTap: () => _onOptionSelected('Appointment Missed'),
        ),
        ListTile(
          title: Text('Tracking ID sharing'),
          onTap: () => _onOptionSelected('Tracking ID sharing'),
        ),
        ListTile(
          title: Text('Payment Reminder'),
          onTap: () => _onOptionSelected('Payment Reminder'),
        ),
      ],
    );
  }

  Widget _buildMessageTemplate() {
    String template = messageTemplates[_selectedOption]!;
    final String accountSid = '';
    final String authToken = '';
    final String twilioNumber =
        'whatsapp:+14155238886'; // Twilio sandbox number
    final String toNumber = '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Template:'),
        SizedBox(height: MediaQuery.of(context).size.height / 80),
        Text(template),
        SizedBox(height: MediaQuery.of(context).size.height / 80),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Add more to the template',
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 80),
        ElevatedButton(
          onPressed: () {
            // Implement the send message functionality here
            Navigator.of(context).pop();
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}
