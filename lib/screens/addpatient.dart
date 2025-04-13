// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:timelines_plus/timelines_plus.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final List indices = [
    "Patient Information",
    "Medical Information",
    "Case Description"
  ];
  int _selec = 0;
  final _formKey = GlobalKey<FormState>();
  var paid = 0;
  var pending = 0;
  var enquiry = 0;
  var physical = 0;
  var oncall = 0;
  var active = 0;
  var inactive = 0;

  TextEditingController _nameController = TextEditingController(text: '');
  TextEditingController _dobController = TextEditingController(text: '');
  TextEditingController _contactNumberController =
      TextEditingController(text: '');
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _qualificationController =
      TextEditingController(text: '');
  TextEditingController _martialStatusController =
      TextEditingController(text: '');
  TextEditingController _addressController = TextEditingController(text: '');

// personal information
  TextEditingController _ageController = TextEditingController(text: '');
  TextEditingController _sexController = TextEditingController(text: '');
  TextEditingController _occupationController = TextEditingController(text: '');

// case information
  TextEditingController _consultantController = TextEditingController(text: '');
  TextEditingController _diagnosisController = TextEditingController(text: '');
  TextEditingController _registrationNumberController =
      TextEditingController(text: '');
  TextEditingController _caseTakenByController =
      TextEditingController(text: '');
  TextEditingController _referredByController = TextEditingController(text: '');
  TextEditingController _courseSuggestedController =
      TextEditingController(text: '');
  TextEditingController _caseTakenDateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  TextEditingController _followUpDateController =
      TextEditingController(text: '');
  TextEditingController _chargesController = TextEditingController(text: '0');
  TextEditingController _medicinesController = TextEditingController(text: '');

// additional information
  TextEditingController _additionalDescriptionController =
      TextEditingController(text: '');

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  DateTime calculateFollowUpDate(String course, DateTime startDate) {
    // Extract the number of DR from the course string
    int numberOfDays = int.parse(course.replaceAll('DR', '')) * 7;
    // Calculate the follow-up date by adding the number of days to the start date
    return startDate.add(Duration(days: numberOfDays));
  }

  void _calculateFollowUpDate() {
    String course = _courseSuggestedController.text;
    DateTime followUpDate = calculateFollowUpDate(course, DateTime.now());
    _followUpDateController.text =
        "${followUpDate.day}/${followUpDate.month}/${followUpDate.year}";
  }

  Future<void> _addPatient() async {
    try {
      // Get the date from _caseTakenDateController
      String caseTakenDate = _caseTakenDateController.text;
      var headings3 = MediaQuery.of(context).size.height / 60;
      // Create patient object
      var patient = {
        'name': _nameController.text.isNotEmpty
            ? _nameController.text
            : 'not available',
        'age': _ageController.text.isNotEmpty
            ? _ageController.text
            : 'not available',
        'sex': _sexController.text.isNotEmpty
            ? _sexController.text
            : 'not available',
        'address': _addressController.text.isNotEmpty
            ? _addressController.text
            : 'not available',
        'contactNumber': _contactNumberController.text.isNotEmpty
            ? _contactNumberController.text
            : 'not available',
        'consultant': _consultantController.text.isNotEmpty
            ? _consultantController.text
            : 'not available',
        'diagnosis': _diagnosisController.text.isNotEmpty
            ? _diagnosisController.text
            : 'not available',
        'registrationNumber': _registrationNumberController.text.isNotEmpty
            ? _registrationNumberController.text
            : 'not available',
        'qualification': _qualificationController.text.isNotEmpty
            ? _qualificationController.text
            : 'not available',
        'martialStatus': _martialStatusController.text.isNotEmpty
            ? _martialStatusController.text
            : 'not available',
        'dob': _dobController.text.isNotEmpty
            ? _dobController.text
            : 'not available',
        'email': _emailController.text.isNotEmpty
            ? _emailController.text
            : 'not available',
        'caseTakenBy': _caseTakenByController.text.isNotEmpty
            ? _caseTakenByController.text
            : 'not available',
        'referredBy': _referredByController.text.isNotEmpty
            ? _referredByController.text
            : 'not available',
        'caseTakenDate': caseTakenDate ?? 'not available',
        'followUpDate': _followUpDateController.text.isNotEmpty
            ? _followUpDateController.text
            : 'not available',
        'additionalDescription':
            _additionalDescriptionController.text.isNotEmpty
                ? _additionalDescriptionController.text
                : 'not available',
        'occupation': _occupationController.text.isNotEmpty
            ? _occupationController.text
            : 'not available',
        'patientStatus': (enquiry == 1) ? "Enquiry" : "Active",
        'appointmentToday': '',
        'appointmentFrom': '',
        'appointmentTo': '',
        'appointmentType': (physical == 1)
            ? "physical"
            : (oncall == 1)
                ? "oncall"
                : 'not available',
        'paymentStatus': (paid == 1)
            ? "paid"
            : (pending == 1)
                ? "pending"
                : 'not available',
        'followUpDetails': [
          {
            caseTakenDate: _additionalDescriptionController.text.isNotEmpty
                ? _additionalDescriptionController.text
                : 'not available',
            // Add more details as needed
          }
        ],
        'charges': [
          _chargesController.text.isNotEmpty ? _chargesController.text : '0'
        ],
        'medicines': [
          {
            _courseSuggestedController.text.isNotEmpty
                    ? _courseSuggestedController.text
                    : 'not available':
                _medicinesController.text.isNotEmpty
                    ? _medicinesController.text
                    : 'not available'
          }
        ]
      };

      // print('Name: ${_nameController.text}');
      // print('Age: ${_ageController.text}');
      // print('Sex: ${_sexController.text}');
      // print('Address: ${_addressController.text}');
      // print('Contact Number: ${_contactNumberController.text}');
      // print('Consultant: ${_consultantController.text}');
      // print('Diagnosis: ${_diagnosisController.text}');
      // print('Registration Number: ${_registrationNumberController.text}');
      // print('Qualification: ${_qualificationController.text}');
      // print('Martial Status: ${_martialStatusController.text}');
      // print('DOB: ${_dobController.text}');
      // print('Email: ${_emailController.text}');
      // print('Case Taken By: ${_caseTakenByController.text}');
      // print('Referred By: ${_referredByController.text}');
      // print('Case Taken Date: ${_caseTakenDateController.text}');
      // print('Follow-Up Date: ${_followUpDateController.text}');
      // print('Additional Description: ${_additionalDescriptionController.text}');
      // print('Occupation: ${_occupationController.text}');
      // print('Charges: ${_chargesController.text}');
      // print('Medicines: ${_medicinesController.text}');
      // print('Follow-Up Details: ${_additionalDescriptionController.text}');

// Add patient to Firestore
      var patientRef = FirebaseFirestore.instance.collection(db).doc();
      await patientRef.set(patient);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Patient added successfully',
            style: GoogleFonts.exo2(
                fontSize: MediaQuery.of(context).size.height / 60),
          ),
          backgroundColor: Colors.green,
        ),
      );

      await FirebaseService().temp();
      // Clear text controllers
      _nameController.clear();
      _ageController.clear();
      _sexController.clear();
      _addressController.clear();
      _contactNumberController.clear();
      _consultantController.clear();
      _diagnosisController.clear();
      _registrationNumberController.clear();
      _qualificationController.clear();
      _martialStatusController.clear();
      _dobController.clear();
      _emailController.clear();
      _caseTakenByController.clear();
      _referredByController.clear();
      _courseSuggestedController.clear();
      _followUpDateController.clear();
      _additionalDescriptionController.clear();

      setState(() {
        _selec = 0;
      });
    } catch (e) {
      print(e);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add patient: $e',
              style: GoogleFonts.exo2(
                  fontSize: MediaQuery.of(context).size.height / 60)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
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
                  "Are you sure you want add this patient",
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
                _addPatient();
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
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    var headings6 = MediaQuery.of(context).size.height / 70;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: headings2, top: headings2 * 2),
            child: Text(
              "Add New Patient",
              style: GoogleFonts.exo2(
                  fontSize: headings2, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 20),
                child: Container(
                    // decoration: BoxDecoration(border: Border.all()),
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width / 7,
                    child: ListView.builder(
                        itemCount: indices.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selec = index;
                              });
                            },
                            child: TimelineTile(
                              nodeAlign: TimelineNodeAlign.start,
                              contents: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height:
                                      MediaQuery.of(context).size.height / 20,
                                  width: MediaQuery.of(context).size.width / 10,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        (_selec == index)
                                            ? BoxShadow(
                                                color:
                                                    Colors.deepPurple.shade200,
                                                spreadRadius: 1,
                                                blurRadius: 10)
                                            : BoxShadow(
                                                color: Colors.transparent)
                                      ],
                                      color: (_selec == index)
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: (_selec == index)
                                          ? Border.all(color: Colors.purple)
                                          : Border.all(
                                              color: Colors.transparent)),
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    indices[index],
                                    style: GoogleFonts.exo2(
                                        fontSize: headings6,
                                        fontWeight: (_selec == index)
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ),
                              ),
                              node: TimelineNode(
                                indicator: (_selec == index)
                                    ? Indicator.outlined(
                                        color: Colors.purple,
                                        size: 20,
                                      )
                                    : Indicator.dot(
                                        color: Colors.purple,
                                        size: 20,
                                      ),
                                startConnector: (index == 0)
                                    ? SizedBox(
                                        height: 30,
                                        child: Connector.transparent())
                                    : SizedBox(
                                        height: 30,
                                        child: DecoratedLineConnector(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.purple,
                                                Colors.purpleAccent
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                endConnector: (index == indices.length - 1)
                                    ? SizedBox(
                                        height: 30,
                                        child: Connector.transparent())
                                    : SizedBox(
                                        height: 30,
                                        child: DecoratedLineConnector(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.purple,
                                                Colors.purpleAccent
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        })),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selec,
                  children: <Widget>[
                    _buildPersonalInformationForm(),
                    _buildMedicalInformationForm(),
                    _buildAddressAndProfessionalInformationForm(),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPersonalInformationForm() {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    return Padding(
      padding: EdgeInsets.all(headings2),
      child: Container(
        // height: MediaQuery.of(context).size.height / 1.25,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(headings2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. Personal Information",
                style:
                    TextStyle(fontSize: headings3, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: Icons.person,
                    controller: _nameController,
                    hintText: 'Name',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.idCard,
                    controller: _registrationNumberController,
                    hintText: 'Registration Number',
                  ),
                ],
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: Icons.phone,
                    controller: _contactNumberController,
                    hintText: 'Contact Number',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: Icons.email,
                    controller: _emailController,
                    hintText: 'Email',
                  ),
                ],
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: Icons.school,
                    controller: _qualificationController,
                    hintText: 'Qualification',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: Icons.people,
                    controller: _martialStatusController,
                    hintText: 'Marital Status',
                  ),
                ],
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.imagePortrait,
                    controller: _ageController,
                    hintText: 'Age',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.venus,
                    controller: _sexController,
                    hintText: 'Sex',
                  ),
                ],
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.locationArrow,
                    controller: _addressController,
                    hintText: 'Address',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.briefcase,
                    controller: _occupationController,
                    hintText: 'Occupation',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFieldWithIcon({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
  }) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 200;
    return Expanded(
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: headings5, horizontal: headings5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _selectDate(context, controller);
              },
              child: Icon(icon),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: hintText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
  }) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 200;
    return Expanded(
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: headings5, horizontal: headings5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: headings2,
            ),
            SizedBox(width: headings5),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: hintText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInformationForm() {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    return Padding(
      padding: EdgeInsets.all(headings2),
      child: Container(
        // height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "2. Medical Information",
                style:
                    TextStyle(fontSize: headings2, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: headings2),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      _buildTextFieldWithIcon(
                        icon: Icons.person,
                        controller: _consultantController,
                        hintText: 'Consultant',
                      ),
                      SizedBox(width: headings1),
                      _buildTextFieldWithIcon(
                        icon: FontAwesomeIcons.stethoscope,
                        controller: _diagnosisController,
                        hintText: 'Diagnosis',
                      ),
                    ],
                  ),
                  SizedBox(height: headings2),
                  Row(
                    children: [
                      _buildTextFieldWithIcon(
                        icon: Icons.person,
                        controller: _caseTakenByController,
                        hintText: 'Case Taken By',
                      ),
                      SizedBox(width: headings1),
                      _buildDateFieldWithIcon(
                        icon: Icons.date_range,
                        controller: _dobController,
                        hintText: 'Date Of Birth',
                      ),
                    ],
                  ),
                  SizedBox(height: headings2),
                  Row(
                    children: [
                      _buildTextFieldWithIcon(
                        icon: Icons.person,
                        controller: _referredByController,
                        hintText: 'Referred By',
                      ),
                      SizedBox(width: headings1),
                      _buildDateFieldWithIcon(
                        icon: Icons.date_range,
                        controller: _caseTakenDateController,
                        hintText: 'Case Taken Date',
                      ),
                    ],
                  ),
                  SizedBox(height: headings2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressAndProfessionalInformationForm() {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    return Padding(
      padding: EdgeInsets.all(headings2),
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(headings2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "3. Case Description ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(right: headings2, top: headings5),
                child: Container(
                  padding: EdgeInsets.only(top: headings2),
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 2,
                  child: SingleChildScrollView(
                      child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      maxLines: 100,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: "Case Description",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      controller: _additionalDescriptionController,
                    ),
                  )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: headings2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enquiry ^= 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (enquiry == 1) ? Colors.green : Colors.deepPurple,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.clipboardQuestion,
                              size: 14,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text("Enquiry",
                                style: GoogleFonts.exo(fontSize: headings4))
                          ],
                        )),
                    SizedBox(
                      width: headings3,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showConfirmationDialog(context);
                        // _addPatient();
                      },
                      child: Text(
                        'Add Patient',
                        style: GoogleFonts.exo(fontSize: headings4),
                      ),
                    )
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
