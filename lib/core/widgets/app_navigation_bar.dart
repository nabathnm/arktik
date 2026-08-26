import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

    final userItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
      BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Eksplor'),
      BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'My trip'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xff2f2373), // AppColors.primary
            unselectedItemColor: const Color(0xff52488b).withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            currentIndex: _calculateSelectedIndex(context, isAdmin),
            items: isAdmin ? adminItems : userItems,
            onTap: (index) =>
                isAdmin ? _onAdminTap(context, index) : _onUserTap(context, index),
          ),
        ),
      ),
    );
  }
}
