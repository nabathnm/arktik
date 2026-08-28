import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      imagePath: 'assets/images/onboarding/onboarding_1.jpg',
      title: 'Mau Liburan bareng tapi\nbingung mau kemana?',
      subtitle:
          'Pilih destinasi impianmu, biar kami bantu susun perjalanan yang lebih terarah.',
      buttonText: 'Lanjut',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding/onboarding_2.jpg',
      title: 'Kapan & bareng siapa?',
      subtitle:
          'Atur jadwal dan teman perjalananmu, lalu biarkan kami siapkan rencananya.',
      buttonText: 'Lanjut',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding/onboarding_3.jpg',
      title: 'Ready for take off?',
      subtitle: 'Saatnya tinggalkan rutinitas dan mulai perjalanan baru',
      buttonText: 'Mulai',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/auth');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for swipeable slides
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Back button (visible on page 2 & 3)
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: GestureDetector(
                onTap: _previousPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: AppColors.yellowNormal,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kembali',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Column(
      children: [
        // Background image - takes upper ~60% of screen
        Expanded(
          flex: 3,
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(data.imagePath, fit: BoxFit.cover),
          ),
        ),

        // White bottom card
        Container(
          height: 340,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          // Use transform to overlap with image
          transform: Matrix4.translationValues(0, -32, 0),
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                data.subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Dot indicators
              Container(
                width: double.infinity,
                alignment: .center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: index == _currentPage ? 42 : 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.yellowNormal
                            : AppColors.primaryNormal,
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellowNormal,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    data.buttonText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;

  _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
