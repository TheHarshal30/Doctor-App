// ignore_for_file: prefer_const_constructors, unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, unused_field, unused_element, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:medigine/screens/navigation.dart' as navv;
// import 'firebase_service.dart'; // Ensure this import matches the location of your FirebaseService class

class EnquiryPatients extends StatefulWidget {
  @override
  _EnquiryPatientsState createState() => _EnquiryPatientsState();
}

class _EnquiryPatientsState extends State<EnquiryPatients> {
  late List<Map<String, dynamic>> _data;
  late List<Map<String, dynamic>> _filteredData;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsOffset = 0;
  String _searchQuery = '';
  String _searchType = 'Name'; // Default search type
  List<Map<String, dynamic>> data = [];
  final List<String> _searchTypes = [
    'Reg No',
    'Name',
    'Contact No',
    'Follow Up',
    'Email'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    data = FirebaseService.globalDocs;
    setState(() {
      _data = data.where((patient) {
        return patient['data']['patientStatus'] == 'Enquiry';
      }).toList();
      _filteredData = List.from(_data);
    });
  }

  Future<void> refreshData() async {
    await FirebaseService().temp();
    await fetchData();
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredData = List.from(_data);
      } else {
        _filteredData = _data.where((patientData) {
          var patient = patientData['data'];
          switch (_searchType) {
            case 'Reg No':
              return patient['registrationNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Name':
              return patient['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Contact No':
              return patient['contactNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Follow Up':
              return patient['followUpDate']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Email':
              return patient['email']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            default:
              return false;
          }
        }).toList();
      }
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _updateEnquiryStatus(
      String docId, bool add, BuildContext context) async {
    try {
      // Update the patient status in Firestore
      await _firestore
          .collection(db)
          .doc(docId)
          .update({'patientStatus': (add) ? 'active' : 'deactivated'});

      // Refresh the data after updating
      refreshData();

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Patient status updated to ${(add) ? 'active' : 'deactivated'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error Snackbar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String docId, bool add) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to mark this patient as done?'),
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
                _updateEnquiryStatus(docId, add, context);
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
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: headings2 * 2, left: headings2),
              child: Text(
                "Enquiry Patients",
                style: GoogleFonts.exo2(
                    fontSize: headings1, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: headings2, top: headings2 * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.only(left: headings2, bottom: headings5),
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextField(
                          style: GoogleFonts.exo2(fontSize: headings3),
                          decoration: InputDecoration(
                              // contentPadding: EdgeInsets.v(bottom: 12),
                              hintText: "Search",
                              hintStyle: GoogleFonts.exo2(fontSize: headings3),
                              // prefixIcon: Icon(Icons.search),
                              border: InputBorder.none),
                          onChanged: _filterData,
                        ),
                      ),
                      SizedBox(width: 40),
                      Container(
                        height: MediaQuery.of(context).size.height / 20,
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          underline: SizedBox.shrink(),
                          style: GoogleFonts.exo2(
                              fontSize: 14, color: Colors.black),
                          padding: EdgeInsets.all(headings5),
                          borderRadius: BorderRadius.circular(10),
                          value: _searchType,
                          onChanged: (String? newValue) {
                            setState(() {
                              _searchType = newValue!;
                            });
                          },
                          items: _searchTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: headings2 * 2),
                    child: ElevatedButton(
                        onPressed: () {
                          refreshData();
                        },
                        child: Text(
                          "Refresh",
                          style: GoogleFonts.exo2(fontSize: headings4),
                        )),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: headings2, right: headings2, top: headings2),
              child: Card(
                child: Container(
                    padding: EdgeInsets.all(headings5),
                    // decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.grey.shade500)),
                    height: MediaQuery.of(context).size.height / 1.35,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              "Reg No",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Name",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Phone Number",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Enquiry Date",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Appointment",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Charges",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "View Details",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Confirm Patient",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        rows: _filteredData.map((patientData) {
                          var patient = patientData['data'];
                          return DataRow(cells: [
                            DataCell(Text(
                              patient['registrationNumber'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(Text(patient['name'].toString())),
                            DataCell(Text(
                              patient['contactNumber'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(Text(
                              patient['caseTakenDate'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(Text(
                              patient['followUpDate'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(Text(
                              patient['charges'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(
                              ElevatedButton(
                                  onPressed: () {
                                    navv.PatientProfilePageArgument.value =
                                        patientData['id'];
                                    navv.pageController.jumpToPage(10);
                                  },
                                  child: Text(
                                    "View Profile",
                                    style: GoogleFonts.exo2(
                                        color: Colors.white,
                                        fontSize: headings4),
                                  )),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog(
                                            context, patientData['id'], true);
                                        print(patientData['id']);
                                      },
                                      child: Text(
                                        "Add",
                                        style: GoogleFonts.exo2(
                                            color: Colors.white,
                                            fontSize: headings4),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog(
                                            context, patientData['id'], false);
                                        print(patientData['id']);
                                      },
                                      child: Text(
                                        "Delete",
                                        style: GoogleFonts.exo2(
                                            color: Colors.white,
                                            fontSize: headings4),
                                      )),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    )),
              ),
            ),
          ],
        ));
  }
}
