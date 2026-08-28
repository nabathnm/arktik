import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class BerandaHeader extends StatelessWidget {
  final String firstName;
  final String? avatarUrl;

  const BerandaHeader({
    super.key,
    required this.firstName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Curved Violet Background
        Container(
          height: 296,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.blueNormalActive,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/splash/bird.png",
                        height: 30,
                        width: 40,
                      ),
                      Image.asset(
                        "assets/images/splash/arktik.png",
                        height: 40,
                        width: 50,
                      ),
                    ],
                  ),
                  // Notification & Avatar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: avatarUrl == null
                            ? const Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  children: [
                    const TextSpan(text: 'Halo, '),
                    TextSpan(
                      text: '$firstName!\n',
                      style: const TextStyle(
                        color: AppColors.yellowNormal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: 'Siap menjelajah Dunia?'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Cards Overlapping
        Positioned(
          top: 150,
          left: 24,
          right: 24,
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'Buat\nTrip',
                  imagePath: 'assets/images/icon/buat_trip.png',
                  color: AppColors.yellowNormal,
                  textColor: Colors.white,
                  onTap: () => context.push('/user/create-trip'),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _ActionCard(
                  title: 'Join Trip',
                  imagePath: 'assets/images/icon/join_trip.png',
                  color: const Color(0xff6b6eb2),
                  textColor: Colors.white,
                  onTap: () => context.push('/user/join-invitation'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.imagePath,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 179,
        width: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(imagePath, width: 64, height: 64),
          ],
        ),
      ),
    );
  }
}
