import 'package:flutter/material.dart';
import '../../core/utils/bilingual.dart';
import 'log_bottom_bar.dart';

class ScreenShell extends StatelessWidget {
  final String titleEn;
  final String titleTe;
  final String? subtitleEn;
  final String? subtitleTe;
  final bool showBottomBar;
  final int bottomBarIndex;
  final Widget? body;
  final List<Widget>? actions;

  const ScreenShell({
    super.key,
    required this.titleEn,
    required this.titleTe,
    this.subtitleEn,
    this.subtitleTe,
    this.showBottomBar = false,
    this.bottomBarIndex = 0,
    this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Bilingual.label(titleTe, titleEn),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (subtitleEn != null || subtitleTe != null)
              Text(
                Bilingual.label(subtitleTe ?? '', subtitleEn ?? ''),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: actions,
      ),
      body: body ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Bilingual.label(titleTe, titleEn),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Setup shell · Setup completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      bottomNavigationBar: showBottomBar
          ? LogBottomBar(currentIndex: bottomBarIndex)
          : null,
    );
  }
}
