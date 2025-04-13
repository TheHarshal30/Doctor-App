// ignore_for_file: prefer_const_constructors, unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, unused_field

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/components/fonts.dart';
import 'package:medigine/screens/navigation.dart' as navv;
// import 'firebase_service.dart'; // Ensure this import matches the location of your FirebaseService class

class PaginatedTableDemo extends StatefulWidget {
  @override
  _PaginatedTableDemoState createState() => _PaginatedTableDemoState();
}

class _PaginatedTableDemoState extends State<PaginatedTableDemo> {
  late List<Map<String, dynamic>> _data;
  late List<Map<String, dynamic>> _filteredData;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsOffset = 0;
  int earnings = 0;
  String _searchQuery = '';
  String _searchType = 'Name'; // Default search type
  List<Map<String, dynamic>> data = [];
  final List<String> _searchTypes = [
    'Name',
    'Reg No',
    'Contact No',
    'Case Taken',
    'Follow Up',
    'Email'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
    _data = (data).map((e) => e as Map<String, dynamic>).toList();
    // print(data);
    _filteredData = List.from(_data);
  }

  void fetchData() async {
    data = FirebaseService.globalDocs;
    // print(data);
    setState(() {});
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(db).doc(documentId);

      // Delete the document
      await documentReference.delete();
      await FirebaseService().temp();
      setState(() {
        _filteredData = FirebaseService.globalDocs;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DELETED SUCCESSFULLY'),
          backgroundColor: Colors.green,
        ),
      );
      print('Document with ID $documentId deleted successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR WHILE DELETING'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error deleting document: $e');
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String docID) async {
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
                  "ARE YOU SURE YOU WANT TO DELETE THIS PATIENT",
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
                deleteDocument(docID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            case 'Name':
              return patient['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Reg No':
              return patient['registrationNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());

            case 'Contact No':
              return patient['contactNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Case Taken':
              return patient['caseTakenDate']
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
                "Patient Directory",
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
                      SizedBox(width: headings1),
                      Container(
                        height: MediaQuery.of(context).size.height / 20,
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          underline: SizedBox.shrink(),
                          style: GoogleFonts.exo2(
                              fontSize: headings4, color: Colors.black),
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
                  Row(
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.only(right: headings2),
                      //   child: ElevatedButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           earnings ^= 1;
                      //         });
                      //       },
                      //       child: Text(
                      //         "View Earnings",
                      //         style: GoogleFonts.exo2(),
                      //       )),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(right: headings2 * 2),
                        child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseService().temp();
                              setState(() {
                                _filteredData = FirebaseService.globalDocs;
                              });
                            },
                            child: Text(
                              "Refresh",
                              style: GoogleFonts.exo2(),
                            )),
                      ),
                    ],
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
                              "Case Taken",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Follow-up Date",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              (earnings == 0) ? "Status" : "Total Fees",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Visit Profile",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Delete Patient",
                              style: GoogleFonts.exo2(
                                  color: Colors.deepPurple,
                                  fontSize: headings3,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        rows: _filteredData
                            .where((patientData) =>
                                    patientData['data']['patientStatus'] !=
                                    'Enquiry'
                                // &&
                                //      &&
                                // patientData['data']['patientStatus'] !=
                                //     'reeval'
                                // patientData['data']['reeval'] != 1

                                )
                            .map((patientData) {
                          var patient = patientData['data'];
                          // var totalCharges = patient['charges'].map((charge) {
                          //   double? parsedCharge = double.tryParse(charge);
                          //   return parsedCharge ??
                          //       0.0; // If parsing fails, return 0.0
                          // }).reduce((a, b) => a + b);

                          return DataRow(cells: [
                            DataCell(Text(
                              patient['registrationNumber'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
                            DataCell(Text(
                              patient['name'].toString(),
                              style: GoogleFonts.exo2(
                                  color: Colors.black, fontSize: headings3),
                            )),
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
                              (patient['reeval'] == "1")
                                  ? "Re-Eval"
                                  : patient['patientStatus'].toString(),
                              style: GoogleFonts.exo2(
                                  color: (patient['reeval'] == "1")
                                      ? Colors.orange
                                      : (patient['patientStatus'].toString() ==
                                              "Active")
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: headings3),
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
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    _showConfirmationDialog(
                                        context, patientData['id']);
                                  },
                                  child: Text(
                                    "Delete",
                                    style: GoogleFonts.exo2(
                                        color: Colors.white,
                                        fontSize: headings4),
                                  )),
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
