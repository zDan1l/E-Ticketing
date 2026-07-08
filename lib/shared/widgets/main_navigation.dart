import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/components/components.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/ticket/presentation/pages/ticket_list_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../providers/notification_provider.dart';
import '../../providers/ticket_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.loadNotifications();
      notifProvider.startPeriodicFetch();
      
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      ticketProvider.startPeriodicFetch();
    });
  }

  @override
  void dispose() {
    try {
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.stopPeriodicFetch();
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      ticketProvider.stopPeriodicFetch();
    } catch (_) {}
    super.dispose();
  }

  final _pages = [
    DashboardPage(key: DashboardPage.dashboardKey),
    const TicketListPage(),
    const SizedBox(), // Structural placeholder matching the center FAB position
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _pages,
      ),
      // Clean flat central FAB anchoring
      floatingActionButton: ClayFab(
        icon: Icons.add_rounded,
        tooltip: 'Create Ticket',
        backgroundColor: AppColors.primary, //
        iconColor: AppColors.onPrimary, //
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/create-ticket');
          if (result == true && mounted) {
            final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
            ticketProvider.loadTickets(silent: true);
            ticketProvider.loadStats(silent: true);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _StyleGuideBottomNav(
        currentIndex: _currentIndex,
        unreadCount: unreadCount,
        onIndexChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _StyleGuideBottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onIndexChange;

  const _StyleGuideBottomNav({
    required this.currentIndex,
    required this.unreadCount,
    required this.onIndexChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E2F).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: AppColors.bottomNavShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home / Dashboard Tab
                  _StyleGuideNavTab(
                    icon: Icons.dashboard_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onIndexChange(0),
                  ),
                  // Tickets Tab
                  _StyleGuideNavTab(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Tickets',
                    isSelected: currentIndex == 1,
                    onTap: () => onIndexChange(1),
                  ),
                  // Structural layout spacing separation block for the center docked FAB
                  const SizedBox(width: 48),
                  // Notifications Tab
                  _StyleGuideNavTab(
                    icon: Icons.notifications_rounded,
                    label: 'Notif',
                    isSelected: currentIndex == 3,
                    badgeCount: unreadCount,
                    onTap: () => onIndexChange(3),
                  ),
                  // Profile Tab
                  _StyleGuideNavTab(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isSelected: currentIndex == 4,
                    onTap: () => onIndexChange(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleGuideNavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _StyleGuideNavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? AppColors.glowShadow : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryContainer : AppColors.primary,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: AppColors.softShadow,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 9,
                        color: isSelected ? AppColors.onSecondaryContainer : AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
