import 'package:flutter/material.dart';
import '../../shared/components/components.dart';
import '../../core/constants/app_colors.dart';
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
    const SizedBox(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _pages,
      ),
      floatingActionButton: ClayFab(
        icon: Icons.add_rounded,
        tooltip: 'Create Ticket',
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed('/create-ticket');
          if (result == true && mounted) {
            final dashboardState = DashboardPage.dashboardKey.currentState;
            if (dashboardState != null) {
              dashboardState.refreshDashboard();
            }
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _FloatingBottomNav(
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

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onIndexChange;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.unreadCount,
    required this.onIndexChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.inverseSurface,
          borderRadius: BorderRadius.circular(
            24,
          ), // matching style guide default tracking (1.5rem)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.dashboard_outlined,
              isSelected: currentIndex == 0,
              onTap: () => onIndexChange(0),
            ),
            _NavIcon(
              icon: Icons.confirmation_number_outlined,
              isSelected: currentIndex == 1,
              onTap: () => onIndexChange(1),
            ),
            const SizedBox(width: 64),
            _NavIcon(
              icon: Icons.notifications_outlined,
              isSelected: currentIndex == 3,
              badgeCount: unreadCount,
              onTap: () => onIndexChange(3),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              isSelected: currentIndex == 4,
              onTap: () => onIndexChange(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.secondaryContainer
                    : AppColors.inverseOnSurface.withValues(alpha: 0.5),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 4,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
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
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 9,
                        color: AppColors.onError,
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
