import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/bilingual.dart';
import '../../data/repositories/transaction_repository.dart';
import '../navigation/log_bottom_bar.dart';
import 'widgets/home_charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _repository = TransactionRepository();
  List<Map<String, dynamic>> _recentTransactions = [];
  Map<String, double> _todaySplit = {
    'credit': 1200.0,
    'expenditure': 680.0,
    'profit': 2940.0,
    'totalSales': 4820.0,
  };
  List<double> _weeklyRevenue = [3600.0, 3200.0, 4100.0, 3800.0, 4700.0, 4300.0, 4820.0];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final txns = await _repository.getRecentTransactions();
      final split = await _repository.getTodaySplit();
      final weekly = await _repository.getWeeklyRevenue();

      if (mounted) {
        setState(() {
          _recentTransactions = txns;
          _todaySplit = split;
          _weeklyRevenue = weekly;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[now.weekday % 7];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppConstants.primaryDark : AppConstants.primaryLight;
    final bg = isDark ? const Color(0xFF090E0D) : const Color(0xFFF7FAF9);
    final cardBg = isDark ? const Color(0xFF131D1B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF283A36) : const Color(0xFFDAE3E1);
    final textCol = isDark ? const Color(0xFFE5EFEA) : const Color(0xFF141E1C);
    final mutedCol = isDark ? const Color(0xFF93A6A1) : const Color(0xFF5C6D69);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(primary, textCol, mutedCol, isDark),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Today's Business Heading
                    Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: mutedCol,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "Today's business",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ఈ రోజు వ్యాపారం',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: mutedCol,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Side-by-Side Chart Tiles
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: WeeklyRevenueChartCard(
                            revenueData: _weeklyRevenue,
                            primaryColor: primary,
                            cardColor: cardBg,
                            borderColor: borderCol,
                            textPrimary: textCol,
                            textMuted: mutedCol,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TodaySplitDonutCard(
                            credit: _todaySplit['credit'] ?? 1200.0,
                            expenditure: _todaySplit['expenditure'] ?? 680.0,
                            profit: _todaySplit['profit'] ?? 2940.0,
                            cardColor: cardBg,
                            borderColor: borderCol,
                            textPrimary: textCol,
                            textMuted: mutedCol,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Recent activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textCol,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ఇటీవలి',
                              style: TextStyle(
                                fontSize: 14,
                                color: mutedCol,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/transactions');
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Recent Activity List
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildRecentActivityList(borderCol, textCol, mutedCol),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const LogBottomBar(currentIndex: 0),
    );
  }

  Widget _buildTopAppBar(
    Color primary,
    Color textCol,
    Color mutedCol,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOG',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Bilingual.label(AppConstants.shopNameTe, AppConstants.shopNameEn),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: mutedCol,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings_outlined, size: 24),
            tooltip: 'Settings · సెట్టింగ్‌లు',
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF16221F) : const Color(0xFFEDF2F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(
    Color borderCol,
    Color textCol,
    Color mutedCol,
  ) {
    if (_recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No transactions yet · ఇంకా లావాదేవీలు లేవు',
            style: TextStyle(color: mutedCol),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: borderCol.withValues(alpha: 0.7),
      ),
      itemBuilder: (context, index) {
        final item = _recentTransactions[index];
        return _buildActivityTile(item, textCol, mutedCol);
      },
    );
  }

  Widget _buildActivityTile(
    Map<String, dynamic> item,
    Color textCol,
    Color mutedCol,
  ) {
    final type = (item['type'] as String?) ?? 'cash_sale';
    final amount = ((item['amount'] as num?) ?? 0).toDouble();
    final rawText = (item['raw_text'] as String?) ?? '';
    final customerName = (item['customer_name'] as String?) ?? '';
    final itemName = (item['item_name_en'] as String?) ?? '';
    final qty = (item['qty'] as num?)?.toDouble();
    final unit = (item['item_unit'] as String?) ?? 'kg';

    Color categoryColor;
    IconData icon;
    String typeTag;
    String title;

    switch (type) {
      case 'credit_sale':
        categoryColor = const Color(0xFFB85A00); // Orange
        icon = Icons.access_time_rounded;
        typeTag = 'ఉధార్ · Credit';
        final custClean = customerName.replaceAll(RegExp(r'\(.*?\)'), '').trim();
        title = '$custClean · $itemName ${qty != null ? '(${qty.toInt()} $unit)' : ''}'.trim();
        break;
      case 'cash_sale':
        categoryColor = const Color(0xFF0B6E5F); // Green
        icon = Icons.payments_outlined;
        typeTag = 'నగదు · Cash';
        title = '$itemName ${qty != null ? '(${qty.toInt()} $unit)' : ''}'.trim();
        break;
      case 'payment_received':
        categoryColor = const Color(0xFF1D5CB8); // Blue
        icon = Icons.south_west_rounded;
        typeTag = 'జమ · Received';
        title = customerName.replaceAll(RegExp(r'\(.*?\)'), '').trim();
        break;
      case 'expense':
        categoryColor = const Color(0xFFB3261E); // Red
        icon = Icons.bolt_rounded;
        typeTag = 'ఖర్చు · Expense';
        title = rawText.contains('కరెంటు') ? 'Electricity' : 'Expense';
        break;
      default:
        categoryColor = const Color(0xFF7A3FB0);
        icon = Icons.inventory_2_outlined;
        typeTag = 'స్టాక్ · Stock';
        title = itemName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Circular Category Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: categoryColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 14),

          // Title & Telugu Spoken Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : 'Transaction',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (rawText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '“$rawText”',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: mutedCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Amount & Category Tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toInt()}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                typeTag,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
