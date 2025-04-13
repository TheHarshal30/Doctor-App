// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PrintingPage extends StatefulWidget {
  const PrintingPage({super.key});

  @override
  State<PrintingPage> createState() => _PrintingPageState();
}

class _PrintingPageState extends State<PrintingPage> {
  TextEditingController _nameController = TextEditingController();

  // personal information
  TextEditingController _ageController = TextEditingController();
  TextEditingController _sexController = TextEditingController();

  TextEditingController _consultantController = TextEditingController();
  TextEditingController __paymentMethodController = TextEditingController();
  TextEditingController _registrationNumberController = TextEditingController();
  TextEditingController _caseTakenByController = TextEditingController();
  TextEditingController _remarksContrloller = TextEditingController();
  TextEditingController _caseTakenDateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  TextEditingController _billNoController = TextEditingController();
  TextEditingController _amtWordsController = TextEditingController();

  TextEditingController _doctorsCharges = TextEditingController(text: "0");
  TextEditingController _medicinalCharges = TextEditingController(text: "0");
  TextEditingController _otherserviceCharges = TextEditingController(text: "0");

  var selec = 0;
  calc() {
    var temp1 = double.parse(_doctorsCharges.text);
    var temp2 = double.parse(_medicinalCharges.text);
    var temp3 = double.parse(_otherserviceCharges.text);
    return (temp1 + temp2 + temp3).toString();
  }

  String amountToWords(String amount) {
    // Define word lists for numbers and scales
    final units = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine'
    ];
    final teens = [
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen'
    ];
    final tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety'
    ];
    final scales = ['', 'thousand', 'million', 'billion', 'trillion'];

    // Helper function to convert a group of three digits
    String convertGroup(int number) {
      String result = '';

      if (number >= 100) {
        result += '${units[number ~/ 100]} hundred ';
        number %= 100;
      }

      if (number >= 20) {
        result += '${tens[number ~/ 10]} ';
        number %= 10;
      }

      if (number >= 10) {
        result += '${teens[number - 10]} ';
      } else if (number > 0) {
        result += '${units[number]} ';
      }

      return result.trim();
    }

    // Main conversion logic
    try {
      // Remove any commas and split into integer and decimal parts
      List<String> parts = amount.replaceAll(',', '').split('.');
      int integerPart = int.parse(parts[0]);

      if (integerPart == 0) return 'zero';

      String result = '';
      int scaleIndex = 0;

      while (integerPart > 0) {
        if (integerPart % 1000 != 0) {
          result =
              '${convertGroup(integerPart % 1000)} ${scales[scaleIndex]} $result';
        }
        integerPart ~/= 1000;
        scaleIndex++;
      }

      // Add cents if present
      if (parts.length > 1) {
        int cents = int.parse(parts[1].padRight(2, '0').substring(0, 2));
        if (cents > 0) {
          result += 'and ${convertGroup(cents)} cent${cents != 1 ? 's' : ''}';
        }
      }

      return result.trim();
    } catch (e) {
      return 'Invalid input';
    }
  }

  List<String> getTextFromControllers() {
    return [
      _registrationNumberController.text,
      _nameController.text,
      _ageController.text + "/" + _sexController.text,
      _caseTakenDateController.text,
      _billNoController.text,
      _consultantController.text,
      _caseTakenByController.text,
      _doctorsCharges.text,
      _medicinalCharges.text,
      _otherserviceCharges.text,
      calc(),
      _remarksContrloller.text,
      __paymentMethodController.text,
      _amtWordsController.text,
    ];
  }

  @override
  Widget build(BuildContext context) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.only(left: headings2, top: headings2 * 2),
          child: Container(
              // decoration: BoxDecoration(border: Border.all(width: 1)),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Printing",
                style: GoogleFonts.exo2(
                    fontSize: headings1, fontWeight: FontWeight.bold),
              )),
        ),
        Padding(
          padding: EdgeInsets.only(left: headings2, top: headings2 * 2),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selec = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: (selec == 0)
                                    ? Colors.deepPurple
                                    : Colors.white))),
                    padding: EdgeInsets.only(bottom: headings5),
                    child: Text(
                      "Basic Details",
                      style: GoogleFonts.exo2(
                          fontSize: headings3, color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: headings2),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selec = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: (selec == 1)
                                    ? Colors.deepPurple
                                    : Colors.white))),
                    padding: EdgeInsets.only(bottom: headings5),
                    child: Text(
                      "Service Charges",
                      style: GoogleFonts.exo2(
                          fontSize: headings3, color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: headings2),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selec = 2;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: (selec == 2)
                                    ? Colors.deepPurple
                                    : Colors.white))),
                    padding: EdgeInsets.only(bottom: headings5),
                    child: Text(
                      "Remarks",
                      style: GoogleFonts.exo2(
                          fontSize: headings3, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        (selec == 0)
            ? _buildBasicDetailsForm()
            : (selec == 1)
                ? _buildServiceChargesForm()
                : _buildRemarksForm(),
        Padding(
          padding: EdgeInsets.only(left: headings2 * 2),
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _amtWordsController.text = amountToWords(calc());
                });
                runPythonScript(getTextFromControllers());
              },
              child: Text(
                "Print Receipt",
                style:
                    GoogleFonts.exo2(fontSize: headings3, color: Colors.white),
              )),
        )
      ]),
    );
  }

  Widget _buildBasicDetailsForm() {
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
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: Icons.person,
                    controller: _nameController,
                    hintText: 'Name',
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
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.idCard,
                    controller: _registrationNumberController,
                    hintText: 'Registration Number',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: FontAwesomeIcons.fileInvoice,
                    controller: _billNoController,
                    hintText: 'Bill Number',
                  ),
                ],
              ),
              SizedBox(height: headings2),
              Row(
                children: [
                  _buildTextFieldWithIcon(
                    icon: Icons.person,
                    controller: _consultantController,
                    hintText: 'Consultant',
                  ),
                  SizedBox(width: headings1),
                  _buildTextFieldWithIcon(
                    icon: Icons.person,
                    controller: _caseTakenByController,
                    hintText: 'Case Taken By',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChargesForm() {
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
              SizedBox(height: headings2),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Row(
                  children: [
                    _buildTextFieldWithIcon(
                      icon: FontAwesomeIcons.wallet,
                      controller: _doctorsCharges,
                      hintText: "Doctor's consultation charges",
                    ),
                  ],
                ),
              ),
              SizedBox(height: headings2),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Row(
                  children: [
                    _buildTextFieldWithIcon(
                      icon: FontAwesomeIcons.wallet,
                      controller: _medicinalCharges,
                      hintText: 'Medicinal Charges',
                    ),
                  ],
                ),
              ),
              SizedBox(height: headings2),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Row(
                  children: [
                    _buildTextFieldWithIcon(
                      icon: FontAwesomeIcons.wallet,
                      controller: _otherserviceCharges,
                      hintText: 'Other service Charges',
                    ),
                  ],
                ),
              ),
              SizedBox(height: headings2),
              Padding(
                padding: EdgeInsets.only(left: 0.0, top: headings2),
                child: Text(
                  "Total: " + calc(),
                  style: GoogleFonts.exo2(
                      fontSize: headings3,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemarksForm() {
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
              SizedBox(height: headings2),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Row(
                  children: [
                    _buildTextFieldWithIcon(
                      icon: FontAwesomeIcons.person,
                      controller: _remarksContrloller,
                      hintText: "Received with thanks from .....",
                    ),
                  ],
                ),
              ),
              SizedBox(height: headings2),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                child: Row(
                  children: [
                    _buildTextFieldWithIcon(
                      icon: FontAwesomeIcons.wallet,
                      controller: __paymentMethodController,
                      hintText: 'Payment Method(Cash / Online)',
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
              onTap: () {},
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
                onSubmitted: (value) {
                  setState(() {
                    controller.text = value;
                  });
                },
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
}

void runPythonScript(List<String> args) async {
  // Absolute path to your .bat file
  String tgt1 = path.join("scripts", "run_print.bat");
  String tgt2 = path.join("scripts", "run_print2.bat");
  String scritpsDIR = path.join(Directory.current.path, 'scripts');

  String batFilePath = path.join(Directory.current.path, tgt1);
  // print(batFilePath);
  String batFilePath2 = path.join(Directory.current.path, tgt2);
  List<String> args1 = args.sublist(0, 7);
  List<String> args2 = args.sublist(7);
  // print(curr);
  print(args1);
  print(args2);

  // Run the batch file with arguments
  ProcessResult result =
      await Process.run(batFilePath, args1, workingDirectory: scritpsDIR);
  if (result.exitCode == 0) {
    ProcessResult result2 =
        await Process.run(batFilePath2, args2, workingDirectory: scritpsDIR);
    if (result2.exitCode == 0) {
      print("woohooo");
    }
  }

  // Check the result
  if (result.exitCode == 0) {
    print('Python script executed successfully.');
  } else {
    print('Error: ${result.stderr}');
  }
}
