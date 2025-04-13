// ignore_for_file: file_names

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  String name;
  int age;
  String sex;
  String address;
  String contactNumber;
  String consultant;
  String diagnosis;
  String registrationNumber;
  String qualification;
  String occupation;
  String martialStatus;
  DateTime dob;
  String email;
  String caseTakenBy;
  String referredBy;
  String courseSuggested;
  DateTime caseTakenDate;
  DateTime followUpDate;
  String additionalDescription;
  List<DateTime> present; // List to hold dates of visits

  Patient({
    required this.name,
    required this.age,
    required this.sex,
    required this.address,
    required this.contactNumber,
    required this.consultant,
    required this.diagnosis,
    required this.registrationNumber,
    required this.qualification,
    required this.occupation,
    required this.martialStatus,
    required this.dob,
    required this.email,
    required this.caseTakenBy,
    required this.referredBy,
    required this.courseSuggested,
    required this.caseTakenDate,
    required this.followUpDate,
    required this.additionalDescription,
    required this.present, // Initialize in the constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'address': address,
      'contactNumber': contactNumber,
      'consultant': consultant,
      'diagnosis': diagnosis,
      'registrationNumber': registrationNumber,
      'qualification': qualification,
      'occupation': occupation,
      'martialStatus': martialStatus,
      'dob': dob,
      'email': email,
      'caseTakenBy': caseTakenBy,
      'referredBy': referredBy,
      'courseSuggested': courseSuggested,
      'caseTakenDate': caseTakenDate,
      'followUpDate': followUpDate,
      'additionalDescription': additionalDescription,
      'present': present.map((date) => date.toIso8601String()).toList(),
    };
  }
}

Patient generatePatient(int index) {
  final random = Random();
  List<DateTime> visits = List.generate(
    random.nextInt(10) + 1, // Random number of visits between 1 and 10
    (i) => DateTime(
      2023,
      random.nextInt(12) + 1,
      random.nextInt(28) + 1,
    ),
  );

  return Patient(
    name: "Patient $index",
    age: 18 + random.nextInt(50), // Random age between 18 and 67
    sex: random.nextBool() ? "Male" : "Female",
    address: "Address $index",
    contactNumber: "123456789${index % 10}",
    consultant: "Dr. Consultant $index",
    diagnosis: "Diagnosis $index",
    registrationNumber: "RegNum$index",
    qualification: "Qualification $index",
    occupation: "Occupation $index",
    martialStatus: random.nextBool() ? "Married" : "Single",
    dob: DateTime(1970 + random.nextInt(50), random.nextInt(12) + 1,
        random.nextInt(28) + 1),
    email: "patient$index@example.com",
    caseTakenBy: "CaseTaker $index",
    referredBy: "ReferredBy $index",
    courseSuggested: "CourseSuggested $index",
    caseTakenDate:
        DateTime(2023, random.nextInt(12) + 1, random.nextInt(28) + 1),
    followUpDate:
        DateTime(2024, random.nextInt(12) + 1, random.nextInt(28) + 1),
    additionalDescription: "AdditionalDescription $index",
    present: visits,
  );
}

class PatientInfo {
  String name;
  int age;
  String sex;
  String address;
  String contactNumber;
  String consultant;
  String diagnosis;
  String registrationNumber;
  String qualification;
  String occupation;
  String maritalStatus;
  DateTime dob;
  String email;
  String caseTakenBy;
  String referredBy;
  String courseSuggested;
  DateTime caseTakenDate;
  DateTime followUpDate;
  String additionalDescription;
  List<DateTime> present;

  PatientInfo({
    required this.name,
    required this.age,
    required this.sex,
    required this.address,
    required this.contactNumber,
    required this.consultant,
    required this.diagnosis,
    required this.registrationNumber,
    required this.qualification,
    required this.occupation,
    required this.maritalStatus,
    required this.dob,
    required this.email,
    required this.caseTakenBy,
    required this.referredBy,
    required this.courseSuggested,
    required this.caseTakenDate,
    required this.followUpDate,
    required this.additionalDescription,
    required this.present,
  });

  factory PatientInfo.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PatientInfo(
      name: data['name'],
      age: data['age'],
      sex: data['sex'],
      address: data['address'],
      contactNumber: data['contactNumber'],
      consultant: data['consultant'],
      diagnosis: data['diagnosis'],
      registrationNumber: data['registrationNumber'],
      qualification: data['qualification'],
      occupation: data['occupation'],
      maritalStatus: data['maritalStatus'],
      dob: (data['dob'] as Timestamp).toDate(),
      email: data['email'],
      caseTakenBy: data['caseTakenBy'],
      referredBy: data['referredBy'],
      courseSuggested: data['courseSuggested'],
      caseTakenDate: (data['caseTakenDate'] as Timestamp).toDate(),
      followUpDate: (data['followUpDate'] as Timestamp).toDate(),
      additionalDescription: data['additionalDescription'],
      present: (data['present'] as List)
          .map((e) => (e as Timestamp).toDate())
          .toList(),
    );
  }
}
