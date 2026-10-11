import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeeklyRevenueChartCard extends StatefulWidget {
  final List<double> revenueData;
  final Color primaryColor;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textMuted;

  const WeeklyRevenueChartCard({
    super.key,
    required this.revenueData,
    required this.primaryColor,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  State<WeeklyRevenueChartCard> createState() => _WeeklyRevenueChartCardState();
}

class _WeeklyRevenueChartCardState extends State<WeeklyRevenueChartCard> {
  int? _selectedIndex;
  static const List<String> _daysShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final total = widget.revenueData.fold<double>(0.0, (acc, item) => acc + item);
    final displayValue = _selectedIndex != null
        ? widget.revenueData[_selectedIndex!]
        : total;
    final displayLabel = _selectedIndex != null
        ? _dayNames[_selectedIndex!]
        : '7 days';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY REVENUE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: widget.textMuted,
            ),
          ),
          Text(
            'వారపు ఆదాయం',
            style: TextStyle(
              fontSize: 11,
              color: widget.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${displayValue.toInt()}',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (details) => _handleTouch(details.localPosition.dx, constraints.maxWidth),
                  onPanUpdate: (details) => _handleTouch(details.localPosition.dx, constraints.maxWidth),
                  onTapUp: (_) => setState(() => _selectedIndex = null),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 94),
                    painter: _WeeklyLinePainter(
                      data: widget.revenueData,
                      selectedIndex: _selectedIndex,
                      primaryColor: widget.primaryColor,
                      textColor: widget.textMuted,
                      days: _daysShort,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(double dx, double width) {
    if (widget.revenueData.isEmpty) return;
    final segment = width / (widget.revenueData.length);
    final index = (dx / segment).floor().clamp(0, widget.revenueData.length - 1);
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _WeeklyLinePainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;
  final Color primaryColor;
  final Color textColor;
  final List<String> days;

  _WeeklyLinePainter({
    required this.data,
    required this.selectedIndex,
    required this.primaryColor,
    required this.textColor,
    required this.days,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartH = size.height - 20;
    const maxVal = 6000.0;
    const x0 = 8.0;
    final x1 = size.width - 8.0;

    // Grid lines (3k, 6k)
    final gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final yGrid3k = chartH - (3000 / maxVal * chartH);
    final yGrid6k = chartH - (6000 / maxVal * chartH);
    canvas.drawLine(Offset(x0, yGrid3k), Offset(x1, yGrid3k), gridPaint);
    canvas.drawLine(Offset(x0, yGrid6k), Offset(x1, yGrid6k), gridPaint);

    // Compute Points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = x0 + i * (x1 - x0) / (data.length - 1);
      final y = chartH - (data[i] / maxVal * chartH);
      points.add(Offset(x, y.clamp(4.0, chartH)));
    }

    // Path for line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Gradient Area Fill
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartH)
      ..lineTo(points.first.dx, chartH)
      ..close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.26),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartH));

    canvas.drawPath(areaPath, gradientPaint);

    // Draw Line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Active selection dot / vertical guideline
    final activeIndex = selectedIndex ?? (data.length - 1);
    final activePt = points[activeIndex];

    if (selectedIndex != null) {
      final dashedPaint = Paint()
        ..color = textColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(activePt.dx, 4), Offset(activePt.dx, chartH), dashedPaint);
    }

    final outerDotPaint = Paint()..color = primaryColor;
    final innerDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(activePt, 4.5, outerDotPaint);
    canvas.drawCircle(activePt, 2.2, innerDotPaint);

    // Draw Day Labels at bottom
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < days.length; i++) {
      final x = points[i].dx;
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: i == activeIndex ? FontWeight.bold : FontWeight.w500,
          color: i == activeIndex ? primaryColor : textColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), chartH + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyLinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class TodaySplitDonutCard extends StatelessWidget {
  final double credit;
  final double expenditure;
  final double profit;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textMuted;

  const TodaySplitDonutCard({
    super.key,
    required this.credit,
    required this.expenditure,
    required this.profit,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final total = credit + expenditure + profit;
    const creditColor = Color(0xFF3B73C9);
    const expColor = Color(0xFFD9731A);
    const profitColor = Color(0xFF0B8F7A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textMuted,
            ),
          ),
          Text(
            'ఈ రోజు',
            style: TextStyle(
              fontSize: 11,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  credit: credit,
                  expenditure: expenditure,
                  profit: profit,
                  creditColor: creditColor,
                  expColor: expColor,
                  profitColor: profitColor,
                  total: total,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildLegendRow('Credit', '₹${credit.toInt()}', creditColor),
          const SizedBox(height: 3),
          _buildLegendRow('Expenditure', '₹${expenditure.toInt()}', expColor),
          const SizedBox(height: 3),
          _buildLegendRow('Profit', '₹${profit.toInt()}', profitColor),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 10.5, color: textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double credit;
  final double expenditure;
  final double profit;
  final Color creditColor;
  final Color expColor;
  final Color profitColor;
  final double total;
  final Color textPrimary;
  final Color textMuted;

  _DonutChartPainter({
    required this.credit,
    required this.expenditure,
    required this.profit,
    required this.creditColor,
    required this.expColor,
    required this.profitColor,
    required this.total,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeW = 10.0;

    final bgPaint = Paint()
      ..color = textMuted.withValues(alpha: 0.12)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0) return;

    double startAngle = -math.pi / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    void drawSegment(double val, Color col) {
      if (val <= 0) return;
      final sweepAngle = (val / total) * 2 * math.pi;
      final segmentPaint = Paint()
        ..color = col
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw slightly padded arc for rounded ends
      canvas.drawArc(arcRect, startAngle, sweepAngle - 0.08, false, segmentPaint);
      startAngle += sweepAngle;
    }

    drawSegment(credit, creditColor);
    drawSegment(expenditure, expColor);
    drawSegment(profit, profitColor);

    // Center text: Sales + ₹4,820
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'Sales',
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, center.dy - 12),
    );

    final amtPainter = TextPainter(
      text: TextSpan(
        text: '₹${total.toInt()}',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    amtPainter.paint(
      canvas,
      Offset(center.dx - amtPainter.width / 2, center.dy + 1),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.credit != credit ||
        oldDelegate.expenditure != expenditure ||
        oldDelegate.profit != profit ||
        oldDelegate.total != total;
  }
}
