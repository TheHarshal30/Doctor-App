// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_import, avoid_unnecessary_containers, sized_box_for_whitespace

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medigine/components/Navigation.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:medigine/main.dart';
import 'package:medigine/screens/PatientTable.dart';
import 'package:medigine/screens/addpatient.dart';
import 'package:medigine/screens/enquiry.dart';
import 'package:medigine/screens/followopDetails.dart';
import 'package:medigine/screens/home.dart';
import 'package:medigine/screens/messaage.dart';
import 'package:medigine/screens/patientProfile.dart';
import 'package:medigine/screens/pendingPayments.dart';
import 'package:medigine/screens/printing.dart';
import 'package:medigine/screens/reevaluationTable.dart';
import 'package:medigine/screens/schedule.dart';
import 'package:medigine/screens/testing.dart';
import 'package:medigine/screens/todaystally.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:medigine/screens/testing.dart';
ValueNotifier<String?> followUpPageArgument = ValueNotifier<String?>(null);
ValueNotifier<String?> PatientProfilePageArgument =
    ValueNotifier<String?>(null);

PageController pageController = PageController();
SideMenuController sideMenu = SideMenuController();

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  @override
  void initState() {
    // Connect SideMenuController and PageController together
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  static const platform = MethodChannel('com.example.app/close');

  @override
  Widget build(BuildContext context) {
    var headings1 = MediaQuery.of(context).size.height / 40;
    var headings2 = MediaQuery.of(context).size.height / 50;
    var headings3 = MediaQuery.of(context).size.height / 60;
    var headings4 = MediaQuery.of(context).size.height / 80;
    var headings5 = MediaQuery.of(context).size.height / 90;
    var headings6 = MediaQuery.of(context).size.height / 200;
    List<SideMenuItem> items = [
      SideMenuItem(
        title: 'Home',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(
          FontAwesomeIcons.houseMedical,
          size: headings1,
        ),
      ),
      SideMenuItem(
        title: 'Patients',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.userGroup),
      ),
      SideMenuItem(
        title: 'New Patient',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.userPlus),
      ),
      SideMenuItem(
        title: 'Schedule',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.calendarCheck),
      ),
      SideMenuItem(
        title: 'Pending Payments',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.hourglassHalf),
      ),
      SideMenuItem(
        title: 'Re-Evaluations',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.eye),
      ),
      SideMenuItem(
        title: 'Enquiry',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.magnifyingGlass),
      ),
      SideMenuItem(
        title: 'Daily Tally',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.coins),
      ),
      SideMenuItem(
        title: 'Receipt Printing',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(FontAwesomeIcons.print),
      ),
      // SideMenuItem(
      //     title: 'Testing',
      //     onTap: (index, _) {
      //       sideMenu.changePage(index);
      //     },
      //     icon: Icon(FontAwesomeIcons.user)),
    ];
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SideMenu(
              footer: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    const url = 'https://wooohooo.netlify.app';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 20,
                    // decoration: BoxDecoration(border: Border.all()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Made with ❤️ by",
                          style: GoogleFonts.exo2(fontSize: headings5),
                        ),
                        Text(
                          " Harshal Rudra",
                          style: GoogleFonts.exo2(
                              fontSize: headings5,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: headings6,
                        ),
                        Icon(
                          FontAwesomeIcons.arrowUpRightFromSquare,
                          color: Colors.deepPurple,
                          size: headings5,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              title: Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: headings2, bottom: headings2),
                child: Container(
                  // decoration: BoxDecoration(border: Border.all()),
                  height: MediaQuery.of(context).size.height / 8,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        // decoration: BoxDecoration(border: Border.all()),
                        child: Image(
                          image: AssetImage("assets/image.png"),
                          height: MediaQuery.of(context).size.height / 15,
                          width: MediaQuery.of(context).size.width / 30,
                        ),
                      ),
                      Text(
                        "Medigene Care",
                        style: GoogleFonts.exo2(
                            fontSize: getResponsiveTextSize(context, 20),
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              style: SideMenuStyle(
                openSideMenuWidth: MediaQuery.of(context).size.width / 7,
                iconSize: headings4,
                itemOuterPadding: EdgeInsets.symmetric(horizontal: headings5),
                displayMode: SideMenuDisplayMode.auto,
                hoverColor: Colors.black.withOpacity(0.1),
                selectedColor: Color.fromRGBO(83, 22, 107, 1),
                unselectedTitleTextStyle: GoogleFonts.ubuntu(
                    fontSize: headings3, color: Colors.deepPurple.shade300),
                unselectedIconColor: Colors.deepPurple.shade300,
                selectedIconColor: Colors.white,
                selectedTitleTextStyle: GoogleFonts.ubuntu(
                    fontSize: headings3, color: Colors.white),
                showHamburger: false,
                // backgroundColor: Color.fromRGBO(34, 32, 69, 1)
                backgroundColor: Colors.white,
                // openSideMenuWidth: 200
              ),
              controller: sideMenu,
              items: items,
            ),
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  HomePage(), //0
                  PaginatedTableDemo(), //1
                  AddPatientPage(), //2
                  SchedulePage(), //3
                  PendingPayment(),
                  //4
                  ReEvaluationTable(), //5
                  EnquiryPatients(), //6
                  TodaysTally(), // 7
                  PrintingPage(), //8
                  ValueListenableBuilder<String?>(
                    //9
                    valueListenable: followUpPageArgument,
                    builder: (context, argument, child) {
                      return FollowUpPage(docID: argument!);
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    //10
                    valueListenable: PatientProfilePageArgument,
                    builder: (context, argument, child) {
                      return PatientProfile(docID: argument!);
                    },
                  ),
                  FollowUps(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
