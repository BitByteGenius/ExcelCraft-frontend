import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/navigation_provider.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Container(
      width: 250,
      color: AppColors.primary,
      child: Column(
        children: [
          // Brand Logo & Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.table_view_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Text(
                        'Data & Excel Suite',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _navItem(
                  context,
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  isSelected: nav.currentTab == AppTab.dashboard,
                  onTap: () => nav.navigateTo(AppTab.dashboard),
                ),

                const SizedBox(height: 18),
                _sectionHeader('TEACHER DATA'),
                _navItem(
                  context,
                  title: 'Add New Teacher',
                  icon: Icons.person_add_outlined,
                  isSelected: nav.currentTab == AppTab.teacherAdd && nav.selectedTeacherIdForEdit == null,
                  onTap: () {
                    nav.clearEditSelections();
                    nav.navigateTo(AppTab.teacherAdd);
                  },
                ),
                _navItem(
                  context,
                  title: 'All Teachers List',
                  icon: Icons.people_alt_outlined,
                  isSelected: nav.currentTab == AppTab.teacherList,
                  onTap: () => nav.navigateTo(AppTab.teacherList),
                ),
                _navItem(
                  context,
                  title: 'Teacher ID Cards',
                  icon: Icons.badge_outlined,
                  isSelected: nav.currentTab == AppTab.teacherIdCards,
                  onTap: () => nav.navigateTo(AppTab.teacherIdCards),
                ),

                const SizedBox(height: 18),
                _sectionHeader('STUDENT DATA'),
                _navItem(
                  context,
                  title: 'Add New Student',
                  icon: Icons.school_outlined,
                  isSelected: nav.currentTab == AppTab.studentAdd && nav.selectedStudentIdForEdit == null,
                  onTap: () {
                    nav.clearEditSelections();
                    nav.navigateTo(AppTab.studentAdd);
                  },
                ),
                _navItem(
                  context,
                  title: 'All Students List',
                  icon: Icons.groups_outlined,
                  isSelected: nav.currentTab == AppTab.studentList,
                  onTap: () => nav.navigateTo(AppTab.studentList),
                ),
                _navItem(
                  context,
                  title: 'Student ID Cards',
                  icon: Icons.card_membership_outlined,
                  isSelected: nav.currentTab == AppTab.studentIdCards,
                  onTap: () => nav.navigateTo(AppTab.studentIdCards),
                ),

                const SizedBox(height: 18),
                _sectionHeader('EXPORTS'),
                _navItem(
                  context,
                  title: 'Excel Workbooks',
                  icon: Icons.file_download_outlined,
                  isSelected: nav.currentTab == AppTab.excelExport,
                  onTap: () => nav.navigateTo(AppTab.excelExport),
                ),
              ],
            ),
          ),

          // Footer version info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primaryLight, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'v1.0.0 • SQLite & ExcelJS',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Desktop',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.primaryLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
