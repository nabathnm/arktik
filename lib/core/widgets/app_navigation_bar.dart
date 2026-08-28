import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rantau/core/constants/app_colors.dart';
import 'package:rantau/core/constants/app_typography.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppNavigationBar extends StatelessWidget {
  final Widget child;

  const AppNavigationBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context, bool isAdmin) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (isAdmin) {
      if (location.startsWith('/admin/dashboard')) return 0;
      if (location.startsWith('/admin/destinations')) return 1;
    } else {
      if (location.startsWith('/user/home')) return 0;
      if (location.startsWith('/user/explore')) return 1;
      if (location.startsWith('/user/my-trips')) return 2;
      if (location.startsWith('/user/profile')) return 3;
    }
    return 0;
  }

  void _onAdminTap(BuildContext context, int index) {
    if (index == 0) {
      context.go('/admin/dashboard');
    } else if (index == 1) {
      context.go('/admin/destinations');
    } else if (index == 2) {
      // Show logout confirmation dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthProvider>().signOut();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  void _onUserTap(BuildContext context, int index) {
    if (index == 0) context.go('/user/home');
    if (index == 1) context.go('/user/explore');
    if (index == 2) context.go('/user/my-trips');
    if (index == 3) context.go('/user/profile');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == UserRole.admin;

    final adminItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Destinations'),
      BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
    ];

    final userItems = [
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/navbar/beranda.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/navbar/beranda_acrive.png',
          width: 30,
          height: 30,
        ),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/navbar/eksplor.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/navbar/eksplor_active.png',
          width: 30,
          height: 30,
        ),
        label: 'Eksplor',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/navbar/my_trip.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/navbar/my_trip_active.png',
          width: 30,
          height: 30,
        ),
        label: 'My trip',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/navbar/profil.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/navbar/profil.png',
          width: 30,
          height: 30,
        ),
        label: 'Profil',
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 32),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryNormalActive,
              unselectedItemColor: AppColors.primaryNormal,
              selectedLabelStyle: AppTypography.navBarSelected,
              unselectedLabelStyle: AppTypography.navBarUnselected,
              currentIndex: _calculateSelectedIndex(context, isAdmin),
              items: isAdmin ? adminItems : userItems,
              onTap: (index) => isAdmin
                  ? _onAdminTap(context, index)
                  : _onUserTap(context, index),
            ),
          ),
        ),
      ),
    );
  }
}
