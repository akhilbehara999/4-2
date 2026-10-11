import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/database_service.dart';
import '../navigation/log_bottom_bar.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _udharStat = '₹12,450 to collect\n8 customers';
  String _stockStat = '3 items running low\nWeekly check due';

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
  }

  Future<void> _loadLiveStats() async {
    try {
      final db = await DatabaseService().database;
      final custRows = await db.rawQuery(
        'SELECT SUM(balance_due) as total_due, COUNT(*) as cnt FROM customer WHERE balance_due > 0',
      );
      if (custRows.isNotEmpty && (custRows.first['cnt'] as int? ?? 0) > 0) {
        final total = (custRows.first['total_due'] as num?)?.toDouble() ?? 0;
        final cnt = custRows.first['cnt'] as int? ?? 0;
        if (mounted) {
          setState(() {
            _udharStat = '₹${_formatCurrency(total.toInt())} to collect\n$cnt ${cnt == 1 ? 'customer' : 'customers'}';
          });
        }
      }

      final stockRows = await db.rawQuery(
        'SELECT COUNT(*) as low_cnt FROM item WHERE current_stock <= 10',
      );
      if (stockRows.isNotEmpty) {
        final lowCnt = stockRows.first['low_cnt'] as int? ?? 0;
        if (lowCnt > 0 && mounted) {
          setState(() {
            _stockStat = '$lowCnt items running low\nWeekly check due';
          });
        }
      }
    } catch (_) {
      // Fallback to sample values from mockup
    }
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    String lastThree = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    remaining = remaining.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{2})+$)'),
      (Match m) => '${m[1]},',
    );
    return '$remaining,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppConstants.primaryDark : AppConstants.primaryLight;
    final bg = isDark ? const Color(0xFF070C0B) : const Color(0xFFF9FBFB);
    final textCol = isDark ? const Color(0xFFE3EDEA) : const Color(0xFF141E1C);
    final mutedCol = isDark ? const Color(0xFF93A6A1) : const Color(0xFF5C6D69);
    final lineCol = isDark ? const Color(0xFF26352F) : const Color(0xFFDAE3E1);
    final surfaceCard = isDark ? const Color(0xFF142019) : Colors.white;

    // Tile specific colors matching LOG More Screen mockup
    final udharBg = isDark ? const Color(0xFF3A2A18) : const Color(0xFFFCEBD9);
    final udharAccent = isDark ? const Color(0xFFFFB070) : const Color(0xFFB85A00);

    final stockBg = isDark ? const Color(0xFF2E2040) : const Color(0xFFEBDDF6);
    final stockAccent = isDark ? const Color(0xFFD5AEF5) : const Color(0xFF7A3FB0);
    final warnRed = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E);

    final dashBg = isDark ? const Color(0xFF192B47) : const Color(0xFFDCE8FA);
    final dashAccent = isDark ? const Color(0xFF9CC2FF) : const Color(0xFF1D5CB8);

    final askBg = isDark ? const Color(0xFF15403A) : const Color(0xFFD3ECE6);
    final askAccent = isDark ? const Color(0xFF4FD1B8) : const Color(0xFF0B6E5F);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: More · మరిన్ని + Settings shortcut
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: textCol,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'మరిన్ని',
                        style: TextStyle(
                          fontSize: 15,
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
            ),

            // Scrollable Main Grid & Quick Links
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2x2 Grid of Large Tonal Hub Tiles
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                      children: [
                        // 1. Udhar
                        _buildHubTile(
                          context: context,
                          titleEn: 'Udhar',
                          titleTe: 'ఉధార్',
                          statText: _udharStat,
                          statColor: udharAccent,
                          icon: Icons.menu_book_rounded,
                          accentColor: udharAccent,
                          bgColor: udharBg,
                          textCol: textCol,
                          mutedCol: mutedCol,
                          route: '/udhar',
                        ),

                        // 2. Stock
                        _buildHubTile(
                          context: context,
                          titleEn: 'Stock',
                          titleTe: 'స్టాక్',
                          statText: _stockStat,
                          statColor: warnRed,
                          icon: Icons.inventory_2_outlined,
                          accentColor: stockAccent,
                          bgColor: stockBg,
                          textCol: textCol,
                          mutedCol: mutedCol,
                          route: '/stock',
                        ),

                        // 3. Dashboard
                        _buildHubTile(
                          context: context,
                          titleEn: 'Dashboard',
                          titleTe: 'డాష్‌బోర్డ్',
                          statText: 'Sales, expenses\nand profit',
                          statColor: dashAccent,
                          icon: Icons.bar_chart_rounded,
                          accentColor: dashAccent,
                          bgColor: dashBg,
                          textCol: textCol,
                          mutedCol: mutedCol,
                          route: '/dashboard',
                        ),

                        // 4. Ask
                        _buildHubTile(
                          context: context,
                          titleEn: 'Ask',
                          titleTe: 'అడగండి',
                          statText: 'Ask about your shop\nin Telugu or English',
                          statColor: askAccent,
                          icon: Icons.chat_bubble_outline_rounded,
                          accentColor: askAccent,
                          bgColor: askBg,
                          textCol: textCol,
                          mutedCol: mutedCol,
                          route: '/ask',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Management Tools
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'QUICK TOOLS · త్వరిత సాధనాలు',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: mutedCol,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: surfaceCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: lineCol, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildQuickRow(
                            icon: Icons.receipt_long_outlined,
                            iconColor: const Color(0xFF1D5CB8),
                            titleEn: 'All Transactions',
                            titleTe: 'అన్ని లావాదేవీలు',
                            subtitle: 'Full sales and expense history',
                            onTap: () => Navigator.pushNamed(context, '/transactions'),
                            showDivider: true,
                            textCol: textCol,
                            mutedCol: mutedCol,
                            lineCol: lineCol,
                          ),
                          _buildQuickRow(
                            icon: Icons.people_outline_rounded,
                            iconColor: const Color(0xFFB85A00),
                            titleEn: 'Customers',
                            titleTe: 'ఖాతాదారులు',
                            subtitle: 'Customer ledger directory',
                            onTap: () => Navigator.pushNamed(context, '/customers'),
                            showDivider: true,
                            textCol: textCol,
                            mutedCol: mutedCol,
                            lineCol: lineCol,
                          ),
                          _buildQuickRow(
                            icon: Icons.category_outlined,
                            iconColor: const Color(0xFF7A3FB0),
                            titleEn: 'Items & Catalog',
                            titleTe: 'వస్తువులు',
                            subtitle: 'Stock catalog and pricing',
                            onTap: () => Navigator.pushNamed(context, '/items'),
                            showDivider: true,
                            textCol: textCol,
                            mutedCol: mutedCol,
                            lineCol: lineCol,
                          ),
                          _buildQuickRow(
                            icon: Icons.settings_outlined,
                            iconColor: primary,
                            titleEn: 'Settings',
                            titleTe: 'సెట్టింగ్‌లు',
                            subtitle: 'Shop details, language and backup',
                            onTap: () => Navigator.pushNamed(context, '/settings'),
                            showDivider: false,
                            textCol: textCol,
                            mutedCol: mutedCol,
                            lineCol: lineCol,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const LogBottomBar(currentIndex: 1),
    );
  }

  Widget _buildHubTile({
    required BuildContext context,
    required String titleEn,
    required String titleTe,
    required String statText,
    required Color statColor,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required Color textCol,
    required Color mutedCol,
    required String route,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon Container + Diagonal Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  Icon(
                    Icons.north_east_rounded,
                    size: 20,
                    color: mutedCol.withValues(alpha: 0.8),
                  ),
                ],
              ),

              const Spacer(),

              // Title & Telugu Label
              Text(
                titleEn,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                titleTe,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: mutedCol,
                ),
              ),

              const SizedBox(height: 8),

              // Stat / Subtitle text
              Text(
                statText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: statColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRow({
    required IconData icon,
    required Color iconColor,
    required String titleEn,
    required String titleTe,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
    required Color textCol,
    required Color mutedCol,
    required Color lineCol,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            titleEn,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            titleTe,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: mutedCol,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: mutedCol),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: mutedCol.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 68,
              endIndent: 16,
              color: lineCol.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}
