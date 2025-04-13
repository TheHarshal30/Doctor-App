// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:medigine/screens/navigation.dart' as navv;

class FollowUpPage extends StatefulWidget {
  final String docID;
  const FollowUpPage({super.key, required this.docID});

  @override
  State<FollowUpPage> createState() => FollowUpPageState();
}

class FollowUpPageState extends State<FollowUpPage> {
  var deact = 0;
  var reEval = 0;

  TextEditingController folloup = TextEditingController(text: "");
  TextEditingController medicines = TextEditingController(text: "");
  TextEditingController followupDate = TextEditingController();
  TextEditingController charges = TextEditingController();
  TextEditingController courseSuggested = TextEditingController();
  TextEditingController paymentMethod = TextEditingController();
  TextEditingController dreval = TextEditingController();
  TextEditingController _starttimeslot = TextEditingController();
  TextEditingController _endtimeslot = TextEditingController();

  late Map<String, dynamic> data;
  void initState() {
    super.initState();
    print(widget.docID);
    data = FirebaseService.globalDocs
        .firstWhere((element) => element['id'] == widget.docID);

    if (data['data']['reeval'] == "1") {
      deact = 0;
      reEval = 1;
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  var paid = 0;
  var pending = 0;

  var method = 0;

  Future<void> _updatePatient() async {
    try {
      // Check if the followUpDate is empty
      if (followupDate.text.isEmpty) {
        // Show an alert dialog to inform the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Follow-up Date is empty. Please provide a date.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
        return; // Exit the function if follow-up date is empty
      }

      // Proceed with the rest of the function if follow-up date is provided
      String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // Create the initial patient object
      var patient = {
        'patientStatus': (deact == 1) ? 'deactive' : 'Active',
        'appointmentToday': "-",
        'followUpDate': followupDate.text,
        'charges': FieldValue.arrayUnion(
            [charges.text.isNotEmpty ? charges.text : "not available"]),
        'paymentStatus': (paid == 1)
            ? "paid"
            : (pending == 1)
                ? "pending"
                : "not available",
        'followUpDetails': FieldValue.arrayUnion([
          {
            date: folloup.text.isNotEmpty ? folloup.text : "not available",
          }
        ]),
        'startTime': _starttimeslot.text,
        'endTime': _endtimeslot.text,
        'medicines': FieldValue.arrayUnion([
          {
            courseSuggested.text.isNotEmpty
                    ? courseSuggested.text
                    : "not available":
                medicines.text.isNotEmpty ? medicines.text : "not available",
          }
        ]),
        'paymentMethod': (pending == 1)
            ? "not available"
            : (method == 0)
                ? "Cash"
                : "Online"
      };

      // Conditionally add the `drEval` field if reEval == 1
      if (reEval == 1) {
        patient['drEval'] =
            dreval.text.isNotEmpty ? dreval.text : "not available";
        patient['reeval'] = "1";
      } else if (reEval == 0) {
        patient['reeval'] = "0";
      }

      paymentMethod.text = (pending == 1)
          ? "not available"
          : (method == 0)
              ? "Cash"
              : "Online";

      // Reference the Firestore document for the patient
      var patientRef =
          FirebaseFirestore.instance.collection(db).doc(widget.docID);

      // Update the patient document with the new fields
      await patientRef.update(patient);

      // Add the entry to today's tally
      if (patient['paymentStatus'] != "pending") {
        addEntryToTodaysTally(
            data['id'],
            data['data']['name'],
            charges.text,
            courseSuggested.text,
            data['data']['registrationNumber'],
            paymentMethod.text);
      }

      await FirebaseService().temp();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add patient: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    navv.pageController.jumpToPage(0);
  }

  DateTime calculateFollowUpDate(String course, DateTime startDate) {
    // Extract the number of DR from the course string
    int numberOfDays = int.parse(course.replaceAll('DR', '')) * 7;
    // Calculate the follow-up date by adding the number of days to the start date
    return startDate.add(Duration(days: numberOfDays));
  }

  void _calculateFollowUpDate() {
    String course = courseSuggested.text;
    DateTime followUpDate = calculateFollowUpDate(course, DateTime.now());
    setState(() {
      followupDate.text =
          "${followUpDate.day}/${followUpDate.month}/${followUpDate.year}";
    });
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        var headings1 = MediaQuery.of(context).size.height / 40;
        var headings2 = MediaQuery.of(context).size.height / 50;
        var headings3 = MediaQuery.of(context).size.height / 60;
        var headings4 = MediaQuery.of(context).size.height / 80;
        var headings5 = MediaQuery.of(context).size.height / 90;
        return AlertDialog(
          title: Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(children: [
                  Text(
                    "Evaluatoin DR: ",
                    style: GoogleFonts.exo2(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    width: headings5,
                  ),
                  Container(
                    width: headings2 * 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade900),
                        borderRadius: BorderRadius.circular(5)),
                    child: TextField(
                      controller: dreval,
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: headings5 / 2,
                              top: headings5,
                              bottom: headings5,
                              right: headings5),
                          border: InputBorder.none,
                          hintText: "Dr. Someone",
                          hintStyle: GoogleFonts.exo2()),
                    ),
                  ),
                ])
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                setState(() {
                  reEval = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  reEval = 1;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(top: headings1, left: headings2),
                        child: Text(
                          "Appointment Details",
                          style: GoogleFonts.exo2(
                              fontSize: headings1, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: headings1),
                        child: ElevatedButton(
                            onPressed: () {
                              _updatePatient();
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.cloudArrowUp,
                                  size: headings4,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Save Data",
                                  style: GoogleFonts.exo2(fontSize: headings4),
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: headings2,
                                  top: (headings1 + headings2)),
                              child: Text(
                                "Personal Details",
                                style: GoogleFonts.exo2(
                                    fontSize: headings2,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: headings3, left: headings2),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: headings2,
                                    top: headings2,
                                    bottom: headings2),
                                height:
                                    MediaQuery.of(context).size.height / 3.5,
                                width: MediaQuery.of(context).size.width / 3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey.shade400)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data['data']['name'],
                                            style: GoogleFonts.exo2(
                                                fontSize: headings2,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: headings2),
                                            child: GestureDetector(
                                              onTap: () {
                                                navv.PatientProfilePageArgument
                                                    .value = widget.docID;
                                                navv.pageController
                                                    .jumpToPage(10);
                                              },
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .deepPurple.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  padding:
                                                      EdgeInsets.all(headings4),
                                                  child: Text(
                                                    "Edit Profile",
                                                    style: GoogleFonts.exo2(
                                                        fontSize: headings4,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // PHONE NUMBER AND GMAIL
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: headings4),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.phone,
                                                  size: headings5,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  data['data']['contactNumber'],
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings4),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: headings2,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.envelope,
                                                  size: headings4,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  data['data']['email'],
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings4),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: headings2),
                                        child: Container(
                                          padding:
                                              EdgeInsets.only(left: 20, top: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              15,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Reason",
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings4,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                    data['data'][
                                                            'followUpDetails'][0]
                                                        .values
                                                        .toString(),
                                                    style: GoogleFonts.exo2(
                                                      fontSize: headings3,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: (headings1 + headings5)),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: headings4, top: 5),
                                              // width: MediaQuery.of(context)
                                              //         .size
                                              //         .width /
                                              //     8,
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height /
                                              //     15,
                                              decoration: BoxDecoration(
                                                  color:
                                                      Colors.blueGrey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .faceFrown,
                                                          size: headings4,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Diagnosis",
                                                          style:
                                                              GoogleFonts.exo2(
                                                                  fontSize:
                                                                      headings4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: headings4,
                                                          right: headings2,
                                                          top: 5),
                                                      child: Text(
                                                        data['data']
                                                            ['diagnosis'],
                                                        style: GoogleFonts.exo2(
                                                          fontSize: headings3,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: headings2, top: headings2),
                                      child: Text(
                                        "Previous FollowUps",
                                        style: GoogleFonts.exo2(
                                            fontSize: headings3,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: headings2, left: headings2),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: headings2,
                                            top: 0,
                                            right: headings2),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                6,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400)),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(top: headings2),
                                          child: ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              physics: BouncingScrollPhysics(),
                                              itemCount: data['data']
                                                      ['followUpDetails']
                                                  .length,
                                              itemBuilder: (context, index) {
                                                String key = data['data']
                                                            ['followUpDetails']
                                                        [index]
                                                    .keys
                                                    .toString();
                                                String value = data['data']
                                                            ['followUpDetails']
                                                        [index]
                                                    .values
                                                    .toString();
                                                return MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
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
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        headings2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
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
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            key,
                                                                            style:
                                                                                TextStyle(fontSize: headings4)),
                                                                        SizedBox(
                                                                            height:
                                                                                headings4),
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 5,
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Text(
                                                                              value,
                                                                              style: GoogleFonts.exo2(
                                                                                fontSize: (headings3),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                      padding: EdgeInsets.only(
                                                          bottom: headings2),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: headings2,
                                                                top: 5,
                                                                bottom: 2),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            15,
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
                                                                key,
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
                                                                  value,
                                                                  style:
                                                                      GoogleFonts
                                                                          .exo2(
                                                                    fontSize:
                                                                        headings4,
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
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: headings2, top: headings2),
                                      child: Text(
                                        "Medicine History",
                                        style: GoogleFonts.exo2(
                                            fontSize: headings3,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: headings2, left: headings2),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: headings2,
                                            top: 0,
                                            right: headings2),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                6.5,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400)),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(top: headings2),
                                          child: ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              physics: BouncingScrollPhysics(),
                                              itemCount: data['data']
                                                      ['medicines']
                                                  .length,
                                              itemBuilder: (context, index) {
                                                String key = data['data']
                                                        ['medicines'][index]
                                                    .keys
                                                    .toString();
                                                String value = data['data']
                                                        ['medicines'][index]
                                                    .values
                                                    .toString();
                                                return MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
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
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        headings2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
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
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            key,
                                                                            style:
                                                                                TextStyle(fontSize: headings4)),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 5,
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Text(
                                                                              value,
                                                                              style: GoogleFonts.exo2(
                                                                                fontSize: headings3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                      padding: EdgeInsets.only(
                                                          bottom: headings2),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: headings2,
                                                                top: 5,
                                                                bottom: 2),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            15,
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
                                                                key,
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
                                                                  value,
                                                                  style:
                                                                      GoogleFonts
                                                                          .exo2(
                                                                    fontSize:
                                                                        headings4,
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: (headings1 + headings1),
                                      left: headings2),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: (deact == 0)
                                              ? Colors.deepPurple
                                              : Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          deact ^= 1;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: headings5, horizontal: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.userSlash,
                                              size: headings4,
                                            ),
                                            SizedBox(
                                              width: headings3,
                                            ),
                                            Text(
                                              "Deactivate",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings3),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: (headings1 + headings1),
                                      left: headings2),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: (reEval == 0)
                                              ? Colors.deepPurple
                                              : Colors.green),
                                      onPressed: () {
                                        _showConfirmationDialog(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: headings5, horizontal: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.userSlash,
                                              size: headings4,
                                            ),
                                            SizedBox(
                                              width: headings3,
                                            ),
                                            Text(
                                              "Mark for re-evaluation",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings3),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: (headings1 + headings1),
                                      left: headings2),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: (reEval == 1)
                                              ? Colors.deepPurple
                                              : Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          reEval = 0;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: headings5, horizontal: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.userSlash,
                                              size: headings4,
                                            ),
                                            SizedBox(
                                              width: headings3,
                                            ),
                                            Text(
                                              "Re-Evaluation Complete",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings4),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: (headings1 + headings2)),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.2,
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Follow - Up Details",
                                    style: GoogleFonts.exo2(
                                        fontSize: headings2,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: headings4),
                                    child: Container(
                                      padding: EdgeInsets.all(headings2),
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100
                                              .withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400)),
                                      child: TextField(
                                        maxLines: 100,
                                        style: GoogleFonts.exo2(
                                            fontSize: headings3),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Details Here",
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(0),
                                        ),
                                        controller: folloup,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: headings5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Medicines",
                                    style: GoogleFonts.exo2(
                                        fontSize: headings2,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Container(
                                      padding: EdgeInsets.all(headings2),
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              10,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100
                                              .withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400)),
                                      child: TextField(
                                        maxLines: 100,
                                        style: GoogleFonts.exo2(
                                            fontSize: headings3),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Medicines Here",
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(0),
                                        ),
                                        controller: medicines,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: headings2),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Charges: ",
                                          style: GoogleFonts.exo2(
                                              fontSize: headings3,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Colors.grey.shade900),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextField(
                                            style: GoogleFonts.exo2(
                                                fontSize: headings4),
                                            controller: charges,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.only(
                                                    left: headings5,
                                                    top: (headings5),
                                                    bottom: headings5,
                                                    right: headings5),
                                                border: InputBorder.none,
                                                hintText: "eg: 1300/-",
                                                hintStyle: GoogleFonts.exo2(
                                                    fontSize: headings4)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: headings1,
                                        ),
                                        Text(
                                          "Course Suggested: ",
                                          style: GoogleFonts.exo2(
                                              fontSize: headings3,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Colors.grey.shade900),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextField(
                                            onEditingComplete:
                                                _calculateFollowUpDate,
                                            style: GoogleFonts.exo2(
                                                fontSize: headings4),
                                            controller: courseSuggested,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.only(
                                                    left: headings5,
                                                    top: (headings5),
                                                    bottom: headings5,
                                                    right: headings5),
                                                border: InputBorder.none,
                                                hintText: "1DR ....",
                                                hintStyle: GoogleFonts.exo2(
                                                    fontSize: headings4)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 0, top: 0),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                paid = 0;
                                                pending ^= 1;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (pending == 1)
                                                  ? Colors.green
                                                  : Colors.deepPurple,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.hourglass,
                                                  size: headings4,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  "Pending",
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
                                              setState(() {
                                                paid ^= 1;
                                                pending = 0;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (paid == 1)
                                                  ? Colors.green
                                                  : Colors.deepPurple,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .clipboardCheck,
                                                  size: headings4,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  "Paid",
                                                  style: GoogleFonts.exo2(
                                                      fontSize: headings4),
                                                )
                                              ],
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        (pending == 0)
                                            ? Row(
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          method = 0;
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            (method == 0)
                                                                ? Colors.green
                                                                : Colors
                                                                    .deepPurple,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .cashRegister,
                                                            size: headings4,
                                                          ),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(
                                                            "Cash",
                                                            style: GoogleFonts
                                                                .exo2(
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
                                                          method = 1;
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            (method == 1)
                                                                ? Colors.green
                                                                : Colors
                                                                    .deepPurple,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .mobile,
                                                            size: headings4,
                                                          ),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(
                                                            "Online",
                                                            style: GoogleFonts
                                                                .exo2(
                                                                    fontSize:
                                                                        headings4),
                                                          )
                                                        ],
                                                      )),
                                                ],
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        _selectDate(context, followupDate);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                21,
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.calendarDay,
                                              size: headings4,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Select Date",
                                              style: GoogleFonts.exo2(
                                                  fontSize: headings4),
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "(" + followupDate.text + ")",
                                    style: GoogleFonts.exo2(
                                        fontSize: headings5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: headings4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              21,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Colors.grey.shade600),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextField(
                                            controller: _starttimeslot,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.only(
                                                    left: headings5 / 2,
                                                    top: headings5 / 2,
                                                    bottom: headings5 / 2,
                                                    right: headings5 / 2),
                                                border: InputBorder.none,
                                                hintText: "10:00 AM",
                                                hintStyle: GoogleFonts.exo2(
                                                    fontSize: headings4)),
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
                                              21,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Colors.grey.shade600),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: TextField(
                                            controller: _endtimeslot,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.only(
                                                    left: headings5 / 2,
                                                    top: headings5 / 2,
                                                    bottom: headings5 / 2,
                                                    right: headings5 / 2),
                                                border: InputBorder.none,
                                                hintText: "10:00 AM",
                                                hintStyle: GoogleFonts.exo2(
                                                    fontSize: headings4)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Padding(
                              //       padding: EdgeInsets.only(
                              //           left: 0, top: headings2),
                              //       child: Text(
                              //         "Time Slot for Appointment",
                              //         style: GoogleFonts.exo2(
                              //           color: Colors.black,
                              //           fontSize: headings3,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),

                              //   ],
                              // ),

                              // ElevatedButton(
                              //     onPressed: () {
                              //       _updatePatient();
                              //     },
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Row(
                              //         children: [
                              //           Icon(
                              //             FontAwesomeIcons.cloudArrowUp,
                              //             size: headings4,
                              //           ),
                              //           SizedBox(
                              //             width: 10,
                              //           ),
                              //           Text(
                              //             "Save Data",
                              //             style: GoogleFonts.exo2(
                              //                 fontSize: headings4),
                              //           )
                              //         ],
                              //       ),
                              //     )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }
}




/*
ElevatedButton(
                                            onPressed: () {
                                              _selectDate(
                                                  context, followupDate);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 5),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons
                                                        .calendarDay,
                                                    size: headings4,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Select Date",
                                                    style: GoogleFonts.exo2(
                                                        fontSize: headings4),
                                                  )
                                                ],
                                              ),
                                            ))

*/