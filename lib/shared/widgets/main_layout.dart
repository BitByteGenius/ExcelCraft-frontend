import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/navigation_provider.dart';
import 'sidebar_navigation.dart';
import 'app_header.dart';
import '../../modules/dashboard/screens/dashboard_screen.dart';
import '../../modules/teachers/screens/teacher_list_screen.dart';
import '../../modules/teachers/screens/teacher_form_screen.dart';
import '../../modules/id_cards/screens/teacher_id_cards_screen.dart';
import '../../modules/students/screens/student_list_screen.dart';
import '../../modules/students/screens/student_form_screen.dart';
import '../../modules/id_cards/screens/student_id_cards_screen.dart';
import '../../modules/excel_export/screens/excel_export_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    String title;
    String subtitle;
    Widget currentScreen;

    switch (nav.currentTab) {
      case AppTab.dashboard:
        title = 'System Dashboard';
        subtitle = 'Real-time overview of teachers, students, database storage, and quick actions';
        currentScreen = const DashboardScreen();
        break;

      case AppTab.teacherList:
        title = 'Teacher Records Roster';
        subtitle = 'Search, filter, view ID cards, and manage all registered faculty members';
        currentScreen = const TeacherListScreen();
        break;

      case AppTab.teacherAdd:
        title = nav.selectedTeacherIdForEdit != null ? 'Edit Teacher Information' : 'New Teacher Registration';
        subtitle = 'Comprehensive 25-field entry with photograph and signature upload';
        currentScreen = TeacherFormScreen(
          key: ValueKey('teacher_form_${nav.selectedTeacherIdForEdit ?? "new"}'),
          editTeacherId: nav.selectedTeacherIdForEdit,
        );
        break;

      case AppTab.teacherIdCards:
        title = 'Teacher ID Card Studio';
        subtitle = 'Preview and print dual-sided official CR80 faculty ID cards';
        currentScreen = TeacherIdCardsScreen(
          key: ValueKey('teacher_card_${nav.selectedTeacherIdForCard ?? "default"}'),
          initialTeacherId: nav.selectedTeacherIdForCard,
        );
        break;

      case AppTab.studentList:
        title = 'Student Records Directory';
        subtitle = 'Search, filter by class/section, view ID cards, and manage enrolled students';
        currentScreen = const StudentListScreen();
        break;

      case AppTab.studentAdd:
        title = nav.selectedStudentIdForEdit != null ? 'Edit Student Information' : 'New Student Admission';
        subtitle = 'Comprehensive 25-field entry with candidate photo and authorization';
        currentScreen = StudentFormScreen(
          key: ValueKey('student_form_${nav.selectedStudentIdForEdit ?? "new"}'),
          editStudentId: nav.selectedStudentIdForEdit,
        );
        break;

      case AppTab.studentIdCards:
        title = 'Student ID Card Studio';
        subtitle = 'Preview and print dual-sided official student identity cards';
        currentScreen = StudentIdCardsScreen(
          key: ValueKey('student_card_${nav.selectedStudentIdForCard ?? "default"}'),
          initialStudentId: nav.selectedStudentIdForCard,
        );
        break;

      case AppTab.excelExport:
        title = 'ExcelJS Export Center';
        subtitle = 'Generate standalone Excel workbooks with embedded photos and signatures';
        currentScreen = const ExcelExportScreen();
        break;

      default:
        title = 'ExcelCraft';
        subtitle = 'Desktop Data Management & Excel Export Suite';
        currentScreen = const DashboardScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left persistent sidebar navigation
          const SidebarNavigation(),

          // Right main content area
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: title,
                  subtitle: subtitle,
                ),
                Expanded(
                  child: currentScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
