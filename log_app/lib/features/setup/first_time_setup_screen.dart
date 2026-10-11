import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/permission_service.dart';
import '../../services/speech_service.dart';

class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Language selection ('both', 'te', 'en')
  String _selectedLanguage = 'both';

  // Step 2: Shop details
  late final TextEditingController _shopNameEnController;
  late final TextEditingController _shopNameTeController;
  late final TextEditingController _ownerNameController;

  // Step 3: Microphone test & wave animation
  bool _micAllowed = false;
  bool _isListening = false;
  String _recognizedText = '';
  final SpeechService _speechService = SpeechService();
  late AnimationController _waveController;

  // Step 4: Weekly stock recount switch
  bool _weeklyCheckEnabled = true;

  @override
  void initState() {
    super.initState();
    _shopNameEnController = TextEditingController(text: AppConstants.shopNameEn);
    _shopNameTeController = TextEditingController(text: AppConstants.shopNameTe);
    _ownerNameController = TextEditingController();

    _shopNameEnController.addListener(_onFieldChanged);
    _shopNameTeController.addListener(_onFieldChanged);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _shopNameEnController.dispose();
    _shopNameTeController.dispose();
    _ownerNameController.dispose();
    _speechService.stopListening();
    _waveController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_currentStep == 1) {
      return _shopNameEnController.text.trim().isNotEmpty;
    }
    return true;
  }

  void _onNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleAllowMic() async {
    await PermissionService.requestMicrophonePermission();
    _speechService.initialize();
    if (mounted) {
      setState(() {
        _micAllowed = true;
      });
    }
  }

  Future<void> _toggleListenTest() async {
    if (_isListening) {
      await _speechService.stopListening();
      _waveController.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '...వింటున్నాను...';
    });
    _waveController.repeat();

    if (_speechService.isAvailable) {
      await _speechService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _recognizedText = text.isNotEmpty
                  ? text
                  : 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు';
            });
          }
        },
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        _waveController.stop();
        setState(() {
          _isListening = false;
          _recognizedText = 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppConstants.primaryDark : AppConstants.primaryLight;
    final bg = isDark ? const Color(0xFF090E0D) : const Color(0xFFF7FAF9);
    final surfaceCard = isDark ? const Color(0xFF131D1B) : Colors.white;
    final containerColor = isDark ? const Color(0xFF192523) : const Color(0xFFEEF4F2);
    final borderCol = isDark ? const Color(0xFF283A36) : const Color(0xFFD6E3DF);
    final textCol = isDark ? const Color(0xFFE5EFEA) : const Color(0xFF111D1A);
    final subText = isDark ? const Color(0xFF90A39E) : const Color(0xFF566B65);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar & Animated 2026 Progress Line
            _buildTopProgressHeader(primary, borderCol, subText, isDark),

            // Step Content with Smooth Animation
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStep),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    child: _buildStepContent(
                      context,
                      primary,
                      surfaceCard,
                      containerColor,
                      borderCol,
                      textCol,
                      subText,
                      isDark,
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Floating Navigation Dock
            _buildBottomNavigationDock(primary, bg, borderCol, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProgressHeader(
    Color primary,
    Color borderCol,
    Color subText,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 22, right: 22, top: 14, bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_rounded, size: 14, color: primary),
                        const SizedBox(width: 5),
                        Text(
                          'LOG KIRANA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Step Counter
              Text(
                '0${_currentStep + 1} / 0$_totalSteps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 4-Segment Animated Progress Pills
          Row(
            children: List.generate(_totalSteps, (index) {
              final isPassed = index <= _currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isPassed ? primary : borderCol.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isPassed
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    Color primary,
    Color surfaceCard,
    Color containerColor,
    Color borderCol,
    Color textCol,
    Color subText,
    bool isDark,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Language(primary, surfaceCard, containerColor, borderCol, textCol, subText, isDark);
      case 1:
        return _buildStep2ShopIdentity(primary, surfaceCard, containerColor, borderCol, textCol, subText, isDark);
      case 2:
        return _buildStep3VoiceStudio(primary, surfaceCard, containerColor, borderCol, textCol, subText, isDark);
      case 3:
        return _buildStep4Launchpad(primary, surfaceCard, containerColor, borderCol, textCol, subText, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // STEP 1: Expressive Welcome & Language
  // ==========================================
  Widget _buildStep1Language(
    Color primary,
    Color surfaceCard,
    Color containerColor,
    Color borderCol,
    Color textCol,
    Color subText,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOG',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: primary,
                  ),
                ),
                Text(
                  'We Listen · Organise · Grow',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                '100% Offline',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textCol,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'స్వాగతం',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: subText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Record udhar, sales, and stock by simply speaking. No typing needed and works 100% offline.',
          style: TextStyle(
            fontSize: 14,
            color: subText,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'SELECT LANGUAGE · భాషను ఎంచుకోండి',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildExpressiveLanguageTile(
          id: 'both',
          title: 'తెలుగు + English',
          subtitle: 'Speak in Telugu or English naturally',
          scriptBadge: 'Aa · అ',
          isRecommended: true,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildExpressiveLanguageTile(
          id: 'te',
          title: 'తెలుగు మాత్రమే',
          subtitle: 'Telugu voice records & displays',
          scriptBadge: 'తె',
          isRecommended: false,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildExpressiveLanguageTile(
          id: 'en',
          title: 'English only',
          subtitle: 'Standard English speech commands',
          scriptBadge: 'EN',
          isRecommended: false,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildExpressiveLanguageTile({
    required String id,
    required String title,
    required String subtitle,
    required String scriptBadge,
    required bool isRecommended,
    required Color primary,
    required Color surfaceCard,
    required Color borderCol,
    required Color textCol,
    required Color subText,
    required bool isDark,
  }) {
    final isSelected = _selectedLanguage == id;
    final activeBg = isDark
        ? primary.withValues(alpha: 0.15)
        : primary.withValues(alpha: 0.08);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : borderCol,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Script Emblem
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary
                    : (isDark ? const Color(0xFF202F2C) : const Color(0xFFEAF2EF)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  scriptBadge,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? const Color(0xFF04201A) : Colors.white)
                        : primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: subText,
                    ),
                  ),
                ],
              ),
            ),
            // Tactile Radio Checkmark
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primary : borderCol,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: isDark ? const Color(0xFF04201A) : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: Modern Shop Identity & Live Board
  // ==========================================
  Widget _buildStep2ShopIdentity(
    Color primary,
    Color surfaceCard,
    Color containerColor,
    Color borderCol,
    Color textCol,
    Color subText,
    bool isDark,
  ) {
    final enteredEn = _shopNameEnController.text.trim().isNotEmpty
        ? _shopNameEnController.text.trim()
        : 'Your Shop Name';
    final enteredTe = _shopNameTeController.text.trim().isNotEmpty
        ? _shopNameTeController.text.trim()
        : 'మీ దుకాణం పేరు';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Your shop',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textCol,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'మీ దుకాణం',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: subText,
          ),
        ),
        const SizedBox(height: 16),

        // Live Shop Signboard Card (Aha! Moment)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF16322C), const Color(0xFF102521)]
                  : [const Color(0xFFE4F2EE), const Color(0xFFD4ECE5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: isDark ? const Color(0xFF04201A) : Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enteredEn,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textCol,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      enteredTe,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We Listen · Organise · Grow',
                      style: TextStyle(
                        fontSize: 11,
                        color: subText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'SHOP NAME IN ENGLISH *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildExpressiveTextField(
          controller: _shopNameEnController,
          hintText: 'e.g. Sri Lakshmi Kirana',
          icon: Icons.store_rounded,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),

        const SizedBox(height: 18),
        Text(
          'SHOP NAME IN TELUGU (OPTIONAL)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildExpressiveTextField(
          controller: _shopNameTeController,
          hintText: 'శ్రీ లక్ష్మి కిరాణా',
          icon: Icons.translate_rounded,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),

        const SizedBox(height: 18),
        Text(
          'OWNER NAME (OPTIONAL)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildExpressiveTextField(
          controller: _ownerNameController,
          hintText: 'e.g. Rama Rao (రామారావు)',
          icon: Icons.person_rounded,
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildExpressiveTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color primary,
    required Color surfaceCard,
    required Color borderCol,
    required Color textCol,
    required Color subText,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primary, size: 22),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 15,
            color: subText.withValues(alpha: 0.7),
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderCol, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderCol, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: Tactile Voice Studio & Permission
  // ==========================================
  Widget _buildStep3VoiceStudio(
    Color primary,
    Color surfaceCard,
    Color containerColor,
    Color borderCol,
    Color textCol,
    Color subText,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Let LOG hear you',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textCol,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'మైక్ అనుమతి',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: subText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'LOG processes your voice on the phone with zero cloud leaks. Allow microphone to try your first spoken record.',
          style: TextStyle(
            fontSize: 14,
            color: subText,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),

        // 2026 Tactile Mic Station Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: surfaceCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderCol, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Permission Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _micAllowed
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                      : const Color(0xFFB3261E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _micAllowed ? Icons.verified_rounded : Icons.lock_clock_rounded,
                      size: 16,
                      color: _micAllowed ? const Color(0xFF2E7D32) : const Color(0xFFB3261E),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _micAllowed ? 'Microphone is on' : 'Microphone is off',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _micAllowed ? const Color(0xFF2E7D32) : const Color(0xFFB3261E),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              if (!_micAllowed) ...[
                // Big Allow Mic Prompt
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.mic_none_rounded, size: 36, color: primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Permission Needed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your audio never leaves this device',
                  style: TextStyle(fontSize: 12.5, color: subText),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _handleAllowMic,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'Allow microphone',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: isDark ? const Color(0xFF04201A) : Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ] else ...[
                // Interactive Mic Trial Box with Equalizer
                Text(
                  'Tap the mic and say:',
                  style: TextStyle(fontSize: 13, color: subText),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '“రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు”',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 22),

                // Tactile Pulsing Mic Station
                GestureDetector(
                  onTap: _toggleListenTest,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      final waveVal = _waveController.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening) ...[
                            Container(
                              width: 104 + (waveVal * 20),
                              height: 104 + (waveVal * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withValues(
                                  alpha: (1.0 - waveVal) * 0.25,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? const Color(0xFFB3261E)
                                  : primary,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening
                                          ? const Color(0xFFB3261E)
                                          : primary)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening
                                  ? Icons.graphic_eq_rounded
                                  : Icons.mic_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // Equalizer Bar Animation when active
                if (_isListening)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) {
                          final height = 10 +
                              18 *
                                  math.sin(
                                    (_waveController.value * 2 * math.pi) +
                                        (index * 0.8),
                                  ).abs();
                          return Container(
                            width: 4,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                const SizedBox(height: 14),

                // Live Spoken Text Output Card
                Container(
                  constraints: const BoxConstraints(minHeight: 38),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2825) : const Color(0xFFEAF5F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recognizedText.isNotEmpty
                        ? _recognizedText
                        : 'Tap mic button to test speaking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _recognizedText.isNotEmpty ? primary : subText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 4: 2026 Ready Launchpad & Tips
  // ==========================================
  Widget _buildStep4Launchpad(
    Color primary,
    Color surfaceCard,
    Color containerColor,
    Color borderCol,
    Color textCol,
    Color subText,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are ready',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textCol,
                  ),
                ),
                Text(
                  'సిద్ధం',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subText,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text(
          'THREE STEPS TO GROW YOUR SHOP · ముఖ్యమైన విషయాలు',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: primary,
          ),
        ),
        const SizedBox(height: 12),

        _buildExpressiveTipTile(
          number: '1',
          icon: Icons.mic_rounded,
          titleEn: 'Tap Speak and say an entry',
          titleTe: 'స్పీక్ నొక్కి చెప్పండి',
          descEn: 'Say sales, credit or restock in natural Telugu anytime.',
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildExpressiveTipTile(
          number: '2',
          icon: Icons.done_all_rounded,
          titleEn: 'Check it on the Confirm screen',
          titleTe: 'సరిచూసి సేవ్ చేయండి',
          descEn: 'Verify recognized fields before saving with instant undo.',
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildExpressiveTipTile(
          number: '3',
          icon: Icons.auto_graph_rounded,
          titleEn: 'See udhar, stock and profit any time',
          titleTe: 'ఉధార్, స్టాక్, లాభం చూడండి',
          descEn: 'Stock-out forecast alerts and daily earnings on the phone.',
          primary: primary,
          surfaceCard: surfaceCard,
          borderCol: borderCol,
          textCol: textCol,
          subText: subText,
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Weekly Stock Check Smart Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderCol, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Weekly stock check',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'వారం వారీ',
                          style: TextStyle(fontSize: 12, color: subText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Every Sunday at 8:00 AM to verify stock drift.',
                      style: TextStyle(fontSize: 12, color: subText),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _weeklyCheckEnabled,
                activeThumbColor: primary,
                onChanged: (val) {
                  setState(() {
                    _weeklyCheckEnabled = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpressiveTipTile({
    required String number,
    required IconData icon,
    required String titleEn,
    required String titleTe,
    required String descEn,
    required Color primary,
    required Color surfaceCard,
    required Color borderCol,
    required Color textCol,
    required Color subText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      titleEn,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: textCol,
                      ),
                    ),
                    Text(
                      titleTe,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: subText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  descEn,
                  style: TextStyle(fontSize: 12, color: subText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Pinned Bottom Navigation Dock
  // ==========================================
  Widget _buildBottomNavigationDock(
    Color primary,
    Color bg,
    Color borderCol,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderCol, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(60, 52),
                  side: BorderSide(color: borderCol, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: _canProceed ? _onNext : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(64, 52),
                backgroundColor: primary,
                foregroundColor: isDark ? const Color(0xFF04201A) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == _totalSteps - 1
                          ? 'Start using LOG · ప్రారంభించండి'
                          : 'Next · తరువాత',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
