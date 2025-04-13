// ignore_for_file: prefer_const_constructors, unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, unused_field, unused_element, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/NewFirebaseServices.dart';
import 'package:medigine/screens/navigation.dart' as navv;

class TodaysTally extends StatefulWidget {
  @override
  _TodaysTallyState createState() => _TodaysTallyState();
}

class _TodaysTallyState extends State<TodaysTally> {
  DateTime? _selectedDate;
  late List<Map<String, dynamic>> _data = [];
  late List<Map<String, dynamic>> _filteredData = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsOffset = 0;
  String _searchQuery = '';
  String _searchType = 'Reg No'; // Default search type
  List<Map<String, dynamic>> data = [];
  final List<String> _searchTypes = ['Reg No', 'Name', 'Charges'];
  TextEditingController expense = TextEditingController();
  TextEditingController password = TextEditingController();
  String correctPass = "1234";
  String total = "0";

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    fetchData();
  }

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();
    String correctPassword = '1234'; // Set your desired password here

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog without entering a password
      builder: (BuildContext context) {
        return Dialog(
          child: BlurredBackground(
            child: AlertDialog(
              title: const Text('Enter Password'),
              content: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    // Close the app or handle it accordingly
                    navv.pageController.jumpToPage(0);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_passwordController.text == correctPassword) {
                      Navigator.of(context).pop(); // Close the dialog
                      // Allow access to the page
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect Password'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchData() async {
    if (_selectedDate == null) return;

    String documentId =
        DateFormat('ddMMAyyyy').format(_selectedDate!).replaceAll('/', 'A');
    print(documentId);

    final snapshot = await FirebaseFirestore.instance
        .collection('todays_tally')
        .doc(documentId)
        .collection('IDs')
        .get();
    DocumentSnapshot expenseDoc = await FirebaseFirestore.instance
        .collection('todays_tally')
        .doc(documentId)
        .collection('IDs')
        .doc('expense')
        .get();

    // Populate the expense controller if the expense document exists
    if (expenseDoc.exists && expenseDoc.data() != null) {
      var data = expenseDoc.data() as Map<String, dynamic>;
      if (data.containsKey('expense')) {
        setState(() {
          expense.text = data['expense'].toString();
        });
      }
    } else {
      setState(() {
        expense.text = "0";
      });
    }

    _data = snapshot.docs
        .where((doc) =>
            doc.id != 'init' &&
            doc.id != 'expense') // Exclude the document with ID 'init'
        .map((doc) => {
              'id': doc.id,
              'data': doc.data(),
            })
        .toList();

    double totalCharges = 0.0;

    for (var item in _data) {
      var charges = item['data']['charges'];
      if (charges != null && charges.isNotEmpty) {
        totalCharges += double.tryParse(charges) ??
            0.0; // Convert to double, add 0 if parsing fails
      }
    }

    setState(() {
      _filteredData = List.from(_data);
      total = totalCharges.toString();
    });
  }

  Future<void> addEntryToTodaysTallyExpenditure(
      String expenditure, BuildContext context) async {
    // Get today's date and format it with "A" instead of "/"
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    var headings6 = MediaQuery.of(context).size.height / 70;

    String todayDate =
        DateFormat('ddMMAyyyy').format(_selectedDate!).replaceAll('/', 'A');

    // Reference to the "IDs" sub-collection under today's document in the "todays_tally" collection
    DocumentReference idDocRef = FirebaseFirestore.instance
        .collection('todays_tally')
        .doc(todayDate)
        .collection('IDs')
        .doc("expense");

    try {
      // Check if the document exists
      DocumentSnapshot docSnapshot = await idDocRef.get();

      if (!docSnapshot.exists) {
        // If the document does not exist, create it with the initial data
        await idDocRef.set({
          'expense': expenditure,
        });
      } else {
        // If the document exists, update the expenditure
        await idDocRef.update({
          'expense': expenditure,
        });
      }

      // Show success Snackbar notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expenditure saved successfully!',
            style: GoogleFonts.exo2(fontSize: headings3),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // If an error occurs, show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save expenditure: $e',
            style: GoogleFonts.exo2(fontSize: headings3),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      // Reference to the specific document in the collection
      String todayDate =
          DateFormat('ddMMAyyyy').format(DateTime.now()).replaceAll('/', 'A');
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('todays_tally')
          .doc(todayDate)
          .collection('IDs')
          .doc(documentId);

      // Delete the document
      await documentReference.delete();
      fetchData();
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
                  "ARE YOU SURE YOU WANT TO DELETE THIS ENTRY",
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      fetchData(); // Fetch the data for the selected date
    }
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredData = List.from(_data);
      } else {
        _filteredData = _data.where((entryData) {
          var entry = entryData['data'];
          switch (_searchType) {
            case 'Reg No':
              return entry['regno']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Name':
              return entry['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Charges':
              return entry['charges']
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
              "Daily Tally",
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
                            hintText: "Search",
                            hintStyle: GoogleFonts.exo2(fontSize: headings3),
                            border: InputBorder.none),
                        onChanged: _filterData,
                      ),
                    ),
                    SizedBox(width: headings2 * 2),
                    Container(
                      height: MediaQuery.of(context).size.height / 20,
                      child: DropdownButton<String>(
                        focusColor: Colors.white,
                        underline: SizedBox.shrink(),
                        style:
                            GoogleFonts.exo2(fontSize: 14, color: Colors.black),
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
                    Text(
                      _selectedDate != null
                          ? "Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"
                          : "No Date Selected",
                      style: GoogleFonts.exo2(fontSize: headings4),
                    ),
                    Padding(
                      padding: EdgeInsets.all(headings2),
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text("Select Date",
                            style: GoogleFonts.exo2(fontSize: headings4)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: headings2 * 2),
                      child: ElevatedButton(
                        onPressed: () {
                          fetchData();
                        },
                        child: Text(
                          "Refresh",
                          style: GoogleFonts.exo2(fontSize: headings4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: headings2, right: headings2, top: headings2),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(headings5),
                height: MediaQuery.of(context).size.height / 1.5,
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
                          "Charges",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.exo2(
                              color: Colors.deepPurple,
                              fontSize: headings3,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Course Suggested",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.exo2(
                              color: Colors.deepPurple,
                              fontSize: headings3,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Payment Method",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.exo2(
                              color: Colors.deepPurple,
                              fontSize: headings3,
                              fontWeight: FontWeight.w500),
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
                          "Delete Entry",
                          style: GoogleFonts.exo2(
                              color: Colors.deepPurple,
                              fontSize: headings3,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    rows: _filteredData.map((entryData) {
                      var entry = entryData['data'];
                      var id = entryData['id'];
                      return DataRow(cells: [
                        DataCell(Text(
                          entry['regno'].toString(),
                          style: GoogleFonts.exo2(
                              color: Colors.black, fontSize: headings3),
                        )),
                        DataCell(Text(
                          entry['name'].toString(),
                          style: GoogleFonts.exo2(
                              color: Colors.black, fontSize: headings3),
                        )),
                        DataCell(Text(
                          entry['charges'].toString(),
                          style: GoogleFonts.exo2(
                              color: Colors.black, fontSize: headings3),
                        )),
                        DataCell(Text(
                          (entry['course'] != null)
                              ? entry['course'].toString()
                              : 'NA',
                          style: GoogleFonts.exo2(
                              color: Colors.black, fontSize: headings3),
                        )),
                        DataCell(Text(
                          entry['paymentMethod'].toString(),
                          style: GoogleFonts.exo2(
                              color: Colors.black, fontSize: headings3),
                        )),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              navv.PatientProfilePageArgument.value =
                                  entryData['id'];
                              navv.pageController.jumpToPage(10);
                            },
                            child: Text(
                              "View Profile",
                              style: GoogleFonts.exo2(
                                  color: Colors.white, fontSize: headings4),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                _showConfirmationDialog(context, id);
                              },
                              child: Text(
                                "Delete",
                                style: GoogleFonts.exo2(
                                    color: Colors.white, fontSize: headings4),
                              )),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: headings2, left: headings2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: headings2, left: headings2),
                  child: Row(
                    children: [
                      Text(
                        "Today's Expenditure: ",
                        style: GoogleFonts.exo2(
                            fontSize: headings3, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: headings5),
                      // Conditional Rendering Based on Date
                      if (_selectedDate != null &&
                          _selectedDate!.day == DateTime.now().day &&
                          _selectedDate!.month == DateTime.now().month &&
                          _selectedDate!.year == DateTime.now().year)
                        // Show TextField and Button if today's date is selected
                        Row(
                          children: [
                            Container(
                              width: headings2 * 5,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border:
                                      Border.all(color: Colors.grey.shade900),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextField(
                                style: GoogleFonts.exo2(fontSize: headings4),
                                controller: expense,
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: headings5,
                                        top: headings5,
                                        bottom: headings5,
                                        right: headings5),
                                    border: InputBorder.none,
                                    hintText: "eg: 1300/-",
                                    hintStyle:
                                        GoogleFonts.exo2(fontSize: headings4)),
                              ),
                            ),
                            SizedBox(width: headings2),
                            ElevatedButton(
                              onPressed: () {
                                addEntryToTodaysTallyExpenditure(
                                    expense.text, context);
                              },
                              child: Text(
                                "Save Expense",
                                style: GoogleFonts.exo2(
                                    color: Colors.white, fontSize: headings4),
                              ),
                            ),
                          ],
                        )
                      else
                        // If another date is selected, just show the expense text
                        Text(
                          expense.text, // Replace with actual data
                          style: GoogleFonts.exo2(
                              fontSize: headings3, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: headings2, right: headings1),
                  child: Text(
                    "Today's Income: " + total,
                    style: GoogleFonts.exo2(
                        fontSize: headings3, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlurredBackground extends StatelessWidget {
  final Widget child;

  const BlurredBackground({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        // The actual content
        child,
      ],
    );
  }
}
