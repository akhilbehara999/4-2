import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/kirana_provider.dart';
import 'features/assistant/assistant_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/home/home_screen.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stock/stock_screen.dart';

class LogApp extends StatelessWidget {
  const LogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KiranaProvider>(
      create: (_) => KiranaProvider()..loadData(),
      child: MaterialApp(
        title: 'LOG',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(
      onNavigateToStock: () {
        setState(() {
          _currentIndex = 2; // Stock tab
        });
      },
    ),
    const LedgerScreen(),
    const StockScreen(),
    const DashboardScreen(),
    const AssistantScreen(),
  ];

  final List<String> _titles = const [
    'LOG',
    'Udhar',
    'Stock',
    'Dashboard',
    'Ask',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 28),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Udhar',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            selectedIcon: Icon(Icons.record_voice_over),
            label: 'Ask',
          ),
        ],
      ),
    );
  }
}
