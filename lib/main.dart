import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}


Below is your complete Master Development Prompt for Google Antigravity. You can copy and paste it directly.

MASTER PROJECT PROMPT — EXCELCRAFT

Project Name: ExcelCraft
Project Type: Desktop Application
Target Platform: Windows Desktop
Frontend: Flutter (Dart)
Backend: Node.js (Express.js)
Database: SQLite
Excel Generation: ExcelJS
Architecture: Modular Clean Architecture


---

1. Project Overview

I want to develop a professional desktop application named ExcelCraft.

The primary purpose of this application is to collect structured data through forms and automatically convert that data into professionally formatted Excel files.

The application will have two main modules:

1. Teacher Data Management


2. Student Data Management



This is NOT a School Management System.

It is strictly a data entry, data management, ID card generation, and Excel export application.

Users will manually enter teacher and student information, upload photographs, manage existing records, and export the information into separate Excel files.

The application should have a modern, premium, professional user interface.

2. Technology Stack

Use the following technologies strictly:

Component	Technology

Frontend	Flutter
Programming Language	Dart
Backend	Node.js
Backend Framework	Express.js
Database	SQLite
Excel Generation	ExcelJS
API Communication	REST API
Image Processing	Sharp (if required)
ID Card Generation	PDF/Image generation
Target Platform	Windows Desktop


Important:

Do NOT use Next.js.

Do NOT use React.js.

Do NOT use HTML/CSS/JavaScript for the frontend.

Flutter must handle the entire frontend.

Node.js must handle backend operations.

Maintain a proper separation between frontend and backend.


3. Application Architecture

Follow a modular, scalable, and maintainable architecture.

Organize the project into separate modules.

Frontend Structure (Flutter)

lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   ├── services/
│   ├── routing/
│   └── widgets/
│
├── models/
│
├── modules/
│   │
│   ├── dashboard/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── teachers/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   │
│   ├── students/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   │
│   ├── id_cards/
│   │   ├── screens/
│   │   ├── templates/
│   │   └── services/
│   │
│   └── excel_export/
│       ├── screens/
│       ├── widgets/
│       └── services/
│
└── shared/
    ├── widgets/
    └── components/

Backend Structure (Node.js)

backend/
│
├── src/
│   ├── config/
│   ├── database/
│   ├── middleware/
│   │
│   ├── modules/
│   │   ├── teachers/
│   │   │   ├── teacher.controller.js
│   │   │   ├── teacher.service.js
│   │   │   ├── teacher.repository.js
│   │   │   ├── teacher.routes.js
│   │   │   └── teacher.validation.js
│   │   │
│   │   ├── students/
│   │   │   ├── student.controller.js
│   │   │   ├── student.service.js
│   │   │   ├── student.repository.js
│   │   │   ├── student.routes.js
│   │   │   └── student.validation.js
│   │   │
│   │   ├── excel/
│   │   ├── id_cards/
│   │   └── uploads/
│   │
│   ├── utils/
│   ├── app.js
│   └── server.js
│
├── storage/
│   ├── photos/
│   │   ├── teachers/
│   │   └── students/
│   │
│   └── signatures/
│
├── exports/
│
└── package.json

Keep modules independent and follow separation of concerns.

4. Dashboard Module

Create a beautiful and professional dashboard.

Display:

Total Teachers.

Total Students.

Recently Added Teachers.

Recently Added Students.

Quick Add Teacher button.

Quick Add Student button.

Export Teacher Excel.

Export Student Excel.

Recent Activity.


The dashboard should have a clean sidebar navigation.

5. Teacher Data Entry Module

Create a comprehensive teacher registration form.

Required Fields

Personal Information

1. Teacher ID (Auto-generated)


2. Full Name


3. Father's Name


4. Mother's Name


5. Date of Birth


6. Gender


7. Blood Group


8. Mobile Number


9. Alternate Contact Number


10. Email Address


11. Complete Residential Address


12. Teacher Photograph



Professional Information 13. School Name 14. School Address 15. Designation 16. Subject 17. Date of Joining 18. Block Name 19. District Name 20. State 21. UDISE Code 22. Qualification

Authorization Information 23. Headmaster Name 24. Headmaster Signature 25. Official Seal (Optional)

The form should support:

Photograph upload.

Signature upload.

Image preview.

Edit existing information.

Delete records.

Search teachers.

Filter teachers.

Form validation.


6. Student Data Entry Module

Create a separate student registration form.

Required Fields

Personal Information

1. Student ID (Auto-generated)


2. Student Full Name


3. Father's Name


4. Mother's Name


5. Date of Birth


6. Gender


7. Blood Group


8. Student Photograph


9. Mobile Number


10. Complete Residential Address



Academic Information

11. School Name


12. School Address


13. Class


14. Section


15. Roll Number


16. Admission Number


17. Admission Date


18. Academic Session



School Information

19. Block Name


20. District Name


21. State


22. UDISE Code


23. Headmaster Name


24. Headmaster Signature


25. Official Seal (Optional)



Include all standard CRUD operations:

Create.

Read.

Update.

Delete.


7. Photograph and Signature Management

This is one of the most important requirements.

The application must support uploading photographs and signatures.

Requirements:

1. Support JPG, JPEG and PNG.


2. Display image previews before saving.


3. Maintain original image quality.


4. Avoid unnecessary cropping.


5. Avoid stretching or distorting images.


6. Store image files locally.


7. Maintain image paths in the database.


8. Associate every image with its respective teacher or student record.



Important: Uploaded photographs must be embedded directly into Excel files, not replaced with image URLs or file paths.

8. Excel Export Module

This is the core functionality of ExcelCraft.

Use the ExcelJS library in Node.js.

Teacher Excel Export

Generate a separate Excel workbook containing all teacher records.

Suggested columns:

ID	Photograph	Name	Father's Name	DOB	Blood Group	Contact	Address	Designation	Subject	Joining Date	School	Block	UDISE Code	Headmaster



Student Excel Export

Generate a completely separate Excel workbook.

Suggested columns:

ID	Photograph	Student Name	Father's Name	Mother's Name	DOB	Gender	Contact	Address	Class	Section	Roll No.	School	Block	UDISE Code



Critical Excel Requirements

1. Teacher and student exports must be separate.


2. Every record must have its own row.


3. Photographs must be embedded directly into Excel cells.


4. Photographs must remain visible when the Excel file is opened on another computer.


5. Signatures should also be embedded where applicable.


6. Use proper column widths and row heights.


7. Use professional formatting.


8. Add borders and appropriate alignment.


9. Use bold column headers.


10. Enable filters.


11. Freeze the header row.


12. Support large datasets without freezing the application.



Photograph Quality

Photographs should maintain their original aspect ratio and visual quality.

Do not crop, stretch, or distort uploaded images.

If the original image is large, maintain its proportions while displaying it clearly within the Excel cell area.

Do not unnecessarily reduce image resolution.

The exported Excel file should contain actual embedded image files.

9. ID Card Generation Module

Create a dedicated ID card generation module.

Support:

Teacher ID Card

Teacher Photograph.

Teacher Name.

Teacher ID.

Designation.

Subject.

School Name.

Contact Number.

UDISE Code.

Headmaster Signature.

School Logo (Optional).


Student ID Card

Student Photograph.

Student Name.

Student ID.

Father's Name.

Class.

Section.

Roll Number.

School Name.

Contact Number.

Academic Session.


Features:

Professional ID card templates.

Preview before generation.

Download as PDF.

Print ID cards.

Support front and back designs.


10. Data Management

All entered information must be saved in SQLite.

Implement:

Create records.

Update records.

Delete records.

Search records.

Pagination.

Sorting.

Filtering.

Duplicate validation.

Automatic ID generation.


Deleting a record should also handle its associated image files safely.

Add confirmation dialogs before permanent deletion.

11. User Interface and Experience

The application must look premium, modern, and professional.

Avoid a basic or outdated desktop application design.

Design Direction

Use:

Modern dashboard layout.

Clean sidebar.

Professional typography.

Consistent spacing.

Attractive cards.

Rounded corners.

Subtle shadows.

Beautiful data tables.

Modern form components.

Smooth transitions.

Light theme.

Optional dark theme.


Suggested Navigation

ExcelCraft
│
├── Dashboard
│
├── Teacher Management
│   ├── Add Teacher
│   ├── All Teachers
│   └── Teacher ID Cards
│
├── Student Management
│   ├── Add Student
│   ├── All Students
│   └── Student ID Cards
│
├── Excel Export
│   ├── Export Teachers
│   └── Export Students
│
└── Settings

12. Backend API Architecture

Create REST APIs with proper validation and error handling.

Example:

Teacher APIs

POST /api/teachers

GET /api/teachers

GET /api/teachers/:id

PUT /api/teachers/:id

DELETE /api/teachers/:id


Student APIs

POST /api/students

GET /api/students

GET /api/students/:id

PUT /api/students/:id

DELETE /api/students/:id


Excel APIs

GET /api/export/teachers

GET /api/export/students


ID Card APIs

GET /api/id-cards/teacher/:id

GET /api/id-cards/student/:id


Use proper HTTP status codes and standardized API responses.

13. Important Development Requirements

Follow these rules throughout development:

1. Maintain clean architecture.


2. Keep frontend and backend completely separate.


3. Every feature must have its own module.


4. Avoid unnecessary code duplication.


5. Use reusable Flutter widgets.


6. Use reusable backend services.


7. Implement proper error handling.


8. Implement input validation.


9. Maintain database consistency.


10. Use environment variables where required.


11. Write readable and maintainable code.


12. Do not put the entire application logic inside one file.


13. Do not create dummy functionality for buttons.


14. Every button and feature must actually work.


15. Test every module before moving forward.



14. Development Strategy — Follow Phases

Do not attempt to build the entire application in one step.

Develop it phase by phase.

Phase 1: Project Foundation

Set up Flutter desktop.

Set up Node.js backend.

Configure SQLite.

Establish API communication.

Create folder structures.

Configure application theme.


Phase 2: UI Development

Create dashboard.

Create sidebar navigation.

Create teacher forms.

Create student forms.

Create data tables.

Implement responsive desktop layouts.


Phase 3: Backend Development

Implement database schemas.

Develop teacher APIs.

Develop student APIs.

Implement image uploads.

Implement CRUD operations.


Phase 4: Excel Export

Integrate ExcelJS.

Generate teacher Excel.

Generate student Excel.

Embed photographs.

Embed signatures.

Apply professional Excel formatting.

Test exported files on another computer.


Phase 5: ID Card Generation

Design teacher ID cards.

Design student ID cards.

Implement previews.

Generate PDF files.

Implement printing.


Phase 6: Testing and Optimization

Test all forms.

Test image uploads.

Test CRUD operations.

Test Excel exports.

Test image embedding.

Fix bugs.

Optimize performance.


Phase 7: Final Desktop Build

Build Windows executable.

Configure backend startup.

Configure local database storage.

Ensure all required files are packaged.

Create a professional installer.


15. Final Instructions to Google Antigravity

Act as a senior software architect, Flutter desktop developer, Node.js backend developer, and UI/UX designer.

Your responsibility is to build a complete, production-quality desktop application named ExcelCraft.

Before writing code:

1. Analyze the complete requirements.


2. Prepare the architecture.


3. Create a development roadmap.


4. Identify all required dependencies.


5. Define database schemas.


6. Define API contracts.


7. Plan the UI components.



Then begin development phase by phase.

IMPORTANT RULES:

Never skip architectural planning.

Never mix frontend and backend responsibilities.

Never compromise on UI quality.

Never use Next.js or React.

Flutter must be the only frontend framework.

Node.js must be used for backend development.

ExcelJS must handle Excel generation.

Actual photographs must be embedded in Excel.

Teacher and student data must remain separate.

All modules must be fully functional.

Do not move to the next phase until the current phase is properly implemented and tested.


Most importantly, prioritize clean architecture, modular development, beautiful UI, reliable data storage, and accurate Excel generation.

The final application should feel like a polished commercial desktop software product, not a basic data entry application.


---

My recommendation for starting with Antigravity

After pasting the master prompt, give it this first instruction:

"Start with Phase 1. First analyze the requirements, prepare the complete technical architecture, create the project folder structure, and establish the Flutter frontend and Node.js backend. Do not rush into implementing all features. Follow the development phases strictly."