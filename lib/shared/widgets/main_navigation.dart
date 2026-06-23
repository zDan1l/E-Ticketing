import 'package:flutter/material.dart';
import '../../shared/components/components.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/ticket/presentation/pages/ticket_list_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../services/notification_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final NotificationService _notifService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notifService.getUnreadNotificationsCount().timeout(
        const Duration(seconds: 5),
        onTimeout: () => 0,
      );
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
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
    return Scaffold(
      backgroundColor: AppColors.canvas, //
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
            final dashboardState = DashboardPage.dashboardKey.currentState;
            if (dashboardState != null) {
              dashboardState.refreshDashboard();
            }
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _StyleGuideBottomNav(
        currentIndex: _currentIndex,
        unreadCount: _unreadCount,
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
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface, //
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2), //
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home / Dashboard Tab
            _StyleGuideNavTab(
              icon: Icons.dashboard_outlined,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => onIndexChange(0),
            ),
            // Tickets Tab
            _StyleGuideNavTab(
              icon: Icons.confirmation_number_outlined,
              label: 'Tickets',
              isSelected: currentIndex == 1,
              onTap: () => onIndexChange(1),
            ),
            // Structural layout spacing separation block for the center docked FAB
            const SizedBox(width: 60),
            // Notifications Tab
            _StyleGuideNavTab(
              icon: Icons.notifications_outlined,
              label: 'Stats',
              isSelected: currentIndex == 3,
              badgeCount: unreadCount,
              onTap: () => onIndexChange(3),
            ),
            // Profile Tab
            _StyleGuideNavTab(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              isSelected: currentIndex == 4,
              onTap: () => onIndexChange(4),
            ),
          ],
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          // Active state turns into a clean flat pill capsule highlight from your style sheet
          color: isSelected ? AppColors.secondaryContainer : Colors.transparent, //
          borderRadius: BorderRadius.circular(12), // rounded-xl scale
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
                  size: 22,
                  color: isSelected 
                      ? AppColors.onSecondaryContainer //
                      : AppColors.onSurfaceVariant, //
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans', //
                    fontSize: 11, // text-label-sm
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.500, //
                    color: isSelected 
                        ? AppColors.onSecondaryContainer //
                        : AppColors.onSurfaceVariant, //
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Using clean solid brand blue
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans', //
                        fontSize: 9,
                        color: AppColors.onPrimary, //
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