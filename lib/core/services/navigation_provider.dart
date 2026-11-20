import 'package:flutter/material.dart';

enum AppTab {
  dashboard,
  teacherList,
  teacherAdd,
  teacherIdCards,
  studentList,
  studentAdd,
  studentIdCards,
  excelExport,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.dashboard;
  int? _selectedTeacherIdForEdit;
  int? _selectedStudentIdForEdit;
  int? _selectedTeacherIdForCard;
  int? _selectedStudentIdForCard;

  AppTab get currentTab => _currentTab;
  int? get selectedTeacherIdForEdit => _selectedTeacherIdForEdit;
  int? get selectedStudentIdForEdit => _selectedStudentIdForEdit;
  int? get selectedTeacherIdForCard => _selectedTeacherIdForCard;
  int? get selectedStudentIdForCard => _selectedStudentIdForCard;

  void navigateTo(AppTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void openTeacherEdit(int id) {
    _selectedTeacherIdForEdit = id;
    _currentTab = AppTab.teacherAdd;
    notifyListeners();
  }

  void openStudentEdit(int id) {
    _selectedStudentIdForEdit = id;
    _currentTab = AppTab.studentAdd;
    notifyListeners();
  }

  void clearEditSelections() {
    _selectedTeacherIdForEdit = null;
    _selectedStudentIdForEdit = null;
  }

  void openTeacherCardPreview(int id) {
    _selectedTeacherIdForCard = id;
    _currentTab = AppTab.teacherIdCards;
    notifyListeners();
  }

  void openStudentCardPreview(int id) {
    _selectedStudentIdForCard = id;
    _currentTab = AppTab.studentIdCards;
    notifyListeners();
  }
}
