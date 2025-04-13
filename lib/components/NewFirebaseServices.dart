// ignore_for_file: prefer_final_fields, unused_field, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medigine/components/fonts.dart';

class FirebaseService {
  static List<Map<String, dynamic>> globalDocs = [{}];
  static Map<String, dynamic> _globalDocuments = {};
  static Map<String, dynamic> _globalDocuments2 = {};
  static List<Map<String, dynamic>> globalSchedule = [{}];

  // Load the documents and cache them
  static Future<void> loadInitialData(String collectionPath) async {
    _globalDocuments = await getDocumentsWithIds(collectionPath);
  }

  temp() async {
    globalDocs = await returnDocs2();
    globalSchedule = await returnSchedule();
  }

  // Get documents with IDs from Firestore
  static Future<Map<String, dynamic>> getDocumentsWithIds(
      String collectionPath) async {
    Map<String, dynamic> documents = {};
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();
      for (var doc in querySnapshot.docs) {
        try {
          documents[doc.id] = doc.data();
        } catch (e) {
          print('Error getting document with ID ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error getting documents: $e');
    }
    return documents;
  }

  // Get documents with follow-up date tomorrow
  static Future<Map<String, dynamic>>
      getDocumentsWithFollowUpDateTomorrow() async {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));
    String formattedTomorrow = DateFormat('d/M/yyyy').format(tomorrow);
    print(formattedTomorrow);

    Map<String, dynamic> documents = {};
    _globalDocuments.forEach((id, data) {
      if (data['followUpDate'] == formattedTomorrow) {
        documents[id] = data;
      }
    });
    return documents;
  }

  static Future<Map<String, dynamic>> getDocumentsWithPaymentPending() async {
    Map<String, dynamic> documents = {};
    _globalDocuments.forEach((id, data) {
      if (data['paymentStatus'] == 'pending') {
        documents[id] = data;
      }
    });
    return documents;
  }

  static printData() {
    print(_globalDocuments.values);
  }

  static returnDocs() {
    return _globalDocuments;
  }

  Future<List<Map<String, dynamic>>> returnDocs2() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(db).get();

    // Create the list from the querySnapshot
    List<Map<String, dynamic>> docs = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    }).toList();

    // Sort the list based on the tag and numerical part of 'registrationNumber'
    docs.sort((a, b) {
      String regNumA = a['data']['registrationNumber'];
      String regNumB = b['data']['registrationNumber'];

      // Extract the tag and number using a regular expression
      RegExp regex = RegExp(r'([A-Za-z]+)-(\d+)'); // Matches "A-100" format

      Match? matchA = regex.firstMatch(regNumA);
      Match? matchB = regex.firstMatch(regNumB);

      // If matches are found, get the tag and number
      String tagA = matchA?.group(1) ?? '';
      String tagB = matchB?.group(1) ?? '';
      int numA = int.parse(matchA?.group(2) ?? '0');
      int numB = int.parse(matchB?.group(2) ?? '0');

      // First compare by tag
      int tagComparison = tagA.compareTo(tagB);
      if (tagComparison != 0) {
        return tagComparison;
      }

      // If tags are the same, then compare by number
      return numA.compareTo(numB);
    });

    return docs;
  }

  Future<List<Map<String, dynamic>>> returnSchedule() async {
    DateTime now = DateTime.now();
    now = now.add(Duration(days: 1));
    String formattedTomorrow = DateFormat('d/M/yyyy').format(now);
    formattedTomorrow = formattedTomorrow.replaceAll('/', 'A');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc("9A7A2024")
        .collection("todya's schedule")
        .get();
    // print(querySnapshot.docs.first.id);
    return querySnapshot.docs.map((doc) {
      // print(doc.data());
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    }).toList();
  }

  static Map<String, dynamic> get globalDocuments => _globalDocuments;
}

Future<void> checkAndUpdateTodaysDocument() async {
  // Get today's date and format it with "A" instead of "/"
  String todayDate =
      DateFormat('ddMMAyyyy').format(DateTime.now()).replaceAll('/', 'A');

  // Reference to today's document in the "todays_tally" collection
  DocumentReference todaysDocRef =
      FirebaseFirestore.instance.collection('todays_tally').doc(todayDate);

  // Check if today's document exists
  DocumentSnapshot todaysDoc = await todaysDocRef.get();

  // If today's document doesn't exist, create it
  if (!todaysDoc.exists) {
    await todaysDocRef.set({'created_at': FieldValue.serverTimestamp()});
  }

  // Ensure the "IDs" sub-collection exists
  CollectionReference idsCollectionRef = todaysDocRef.collection('IDs');

  // Optionally, you can add an initial document to the "IDs" collection or leave it empty
  await idsCollectionRef.doc('init').set(
      {'init': false}); // Just an example to ensure the collection is created
}

Future<void> addEntryToTodaysTally(String id, String name, String charges,
    String course, String regno, String method) async {
  // Get today's date and format it with "A" instead of "/"
  String todayDate =
      DateFormat('ddMMAyyyy').format(DateTime.now()).replaceAll('/', 'A');

  // Reference to the "IDs" sub-collection under today's document in the "todays_tally" collection
  DocumentReference idDocRef = FirebaseFirestore.instance
      .collection('todays_tally')
      .doc(todayDate)
      .collection('IDs')
      .doc(id);

  // Add the data to the document
  await idDocRef.set({
    'name': name,
    'charges': charges,
    'course': course,
    'regno': regno,
    'paymentMethod': method
  });
}
