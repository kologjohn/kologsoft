import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TotalDebtWidget extends StatefulWidget {
  final double cwidth;
  final double totalDebt;

  const TotalDebtWidget({
    super.key,
    required this.cwidth,
    required this.totalDebt,
  });

  @override
  State<TotalDebtWidget> createState() => _TotalDebtWidgetState();
}

class _TotalDebtWidgetState extends State<TotalDebtWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Color get debtColor {
    if (widget.totalDebt < 5000) return Colors.greenAccent;
    if (widget.totalDebt < 20000) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get debtStatus {
    if (widget.totalDebt < 5000) return "Healthy";
    if (widget.totalDebt < 20000) return "Moderate";
    return "High Risk";
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.totalDebt,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  List<FlSpot> get _trendSpots => const [
    FlSpot(0, 3),
    FlSpot(1, 4),
    FlSpot(2, 3.5),
    FlSpot(3, 5),
    FlSpot(4, 6),
    FlSpot(5, 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.cwidth,
      height: 235,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL DEBT",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: debtColor,
              ),
            ],
          ),

          const SizedBox(height: 12),


          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FittedBox(
                child: Text(
                  "GHS ${_animation.value.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: debtColor,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 6),


          Text(
            debtStatus,
            style: TextStyle(
              fontSize: 12,
              color: debtColor.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 12),


          SizedBox(
            height: 70,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _trendSpots,
                    isCurved: true,
                    color: debtColor,
                    barWidth: 2.5,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: debtColor.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),


          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: debtColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "Last 7 days trend",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
