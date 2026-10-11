import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/bilingual.dart';

class LogBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const LogBottomBar({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppConstants.primaryDark : AppConstants.primaryLight;
    final containerColor = isDark ? const Color(0xFF16221F) : const Color(0xFFEDF2F1);

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF26352F) : const Color(0xFFDAE3E1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  // 1. Home Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      isSelected: currentIndex == 0,
                      icon: Icons.home_rounded,
                      labelEn: 'Home',
                      labelTe: 'హోమ్',
                      onTap: () {
                        if (currentIndex != 0) {
                          if (onTabSelected != null) {
                            onTabSelected!(0);
                          } else {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        }
                      },
                    ),
                  ),

                  // Centre gap for the raised Speak button
                  const SizedBox(width: 84),

                  // 3. More Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      isSelected: currentIndex == 1,
                      icon: Icons.grid_view_rounded,
                      labelEn: 'More',
                      labelTe: 'మరిన్ని',
                      onTap: () {
                        if (currentIndex != 1) {
                          if (onTabSelected != null) {
                            onTabSelected!(1);
                          } else {
                            Navigator.pushNamed(context, '/more');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),

              // 2. Speak Button (Raised Centre Mic)
              Positioned(
                top: -18,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/listening');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 32,
                          color: isDark ? const Color(0xFF04201A) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        Bilingual.label('మాట్లాడండి', 'Speak'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF141E1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required String labelEn,
    required String labelTe,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppConstants.primaryDark : AppConstants.primaryLight;
    final activeBg = isDark ? const Color(0xFF15403A) : const Color(0xFFD3ECE6);
    final inactiveColor = isDark ? const Color(0xFF93A6A1) : const Color(0xFF5C6D69);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? primaryColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Bilingual.label(labelTe, labelEn),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
