import 'package:flutter/material.dart';
import '../../core/utils/bilingual.dart';

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF141E1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'తెలుగు · Telugu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B6E5F),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Listening',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF141E1C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'వింటున్నాను...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF5C6D69),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B6E5F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B6E5F).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                Bilingual.label('చెప్పండి: బియ్యం 5 కిలోలు...', 'Speak now...'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5C6D69),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/confirm-entry');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: const Color(0xFF0B6E5F),
                ),
                child: Text(
                  Bilingual.label('సరిచూడండి', 'Go to Confirm Entry'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
