import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isBackendOnline = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    final online = await ApiService.checkBackendHealth();
    if (mounted) {
      setState(() {
        _isBackendOnline = online;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title & Subtitle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Right side actions & Server status indicator
          Row(
            children: [
              if (widget.actions != null) ...widget.actions!,
              const SizedBox(width: 16),
              // Backend Status Indicator
              Tooltip(
                message: _checking
                    ? 'Checking Node.js API status...'
                    : _isBackendOnline
                        ? 'Backend API Connected (Port 5050)'
                        : 'Backend API Offline. Click to retry.',
                child: InkWell(
                  onTap: () {
                    setState(() => _checking = true);
                    _checkHealth();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isBackendOnline
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isBackendOnline
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _checking
                                ? AppColors.warning
                                : _isBackendOnline
                                    ? AppColors.success
                                    : AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _checking
                              ? 'Checking...'
                              : _isBackendOnline
                                  ? 'API Online'
                                  : 'API Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isBackendOnline ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
