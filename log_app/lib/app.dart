import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/more/more_screen.dart';
import 'features/udhar/udhar_screen.dart';
import 'features/udhar/udhar_customer_detail_screen.dart';
import 'features/stock/stock_screen.dart';
import 'features/stock/stock_item_detail_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/ask/ask_screen.dart';
import 'features/transactions/all_transactions_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/items/items_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/setup/first_time_setup_screen.dart';
import 'features/speak/listening_screen.dart';
import 'features/speak/confirm_entry_screen.dart';
import 'features/recount/weekly_recount_screen.dart';

class LogApp extends StatelessWidget {
  const LogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOG · ${AppConstants.shopNameEn}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/setup',
      routes: {
        // Main screens
        '/': (context) => const HomeScreen(),
        '/more': (context) => const MoreScreen(),
        '/udhar': (context) => const UdharScreen(),
        '/stock': (context) => const StockScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/ask': (context) => const AskScreen(),

        // Supporting screens
        '/transactions': (context) => const AllTransactionsScreen(),
        '/udhar/customer-detail': (context) => const UdharCustomerDetailScreen(),
        '/stock/item-detail': (context) => const StockItemDetailScreen(),
        '/customers': (context) => const CustomersScreen(),
        '/items': (context) => const ItemsScreen(),
        '/settings': (context) => const SettingsScreen(),

        // Hidden screens (no bottom bar)
        '/setup': (context) => const FirstTimeSetupScreen(),
        '/listening': (context) => const ListeningScreen(),
        '/confirm-entry': (context) => const ConfirmEntryScreen(),
        '/recount': (context) => const WeeklyRecountScreen(),
      },
    );
  }
}
