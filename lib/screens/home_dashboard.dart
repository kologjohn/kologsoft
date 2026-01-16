import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/screens/sidebar.dart';

import '../providers/routes.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth <= 512;
    bool isSmallTablet = screenWidth < 774;
    bool isTablet = screenWidth < 900;
    bool isMediumTablet = screenWidth < 1087;
    bool isBigTablet = screenWidth < 1200;
    print(screenWidth);

    return Scaffold(
      backgroundColor: const Color(0xFF101A23),
      appBar: AppBar(
        title: const Text('NWC SMS Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1A26),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer:Sidebar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                runSpacing: 15,
                spacing: 15,
                children: [
                  WorkPlaceWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.47
                        : isMediumTablet
                        ? screenWidth * 0.30
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.24
                        : screenWidth * 0.23,
                  ),
                  RespWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.47
                        : isMediumTablet
                        ? screenWidth * 0.21
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.15
                        : screenWidth * 0.16,
                  ),
                  MiddleWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.47
                        : isMediumTablet
                        ? screenWidth * 0.21
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.15
                        : screenWidth * 0.16,
                  ),
                  CsatWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.47
                        : isMediumTablet
                        ? screenWidth * 0.21
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.15
                        : screenWidth * 0.16,
                  ),
                  TopWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isTablet
                        ? screenWidth * 0.98
                        : isMediumTablet
                        ? screenWidth * 0.98
                        : isBigTablet
                        ? screenWidth * 0.24
                        : screenWidth * 0.22,
                  )
                ],
              ),
              SizedBox(height: 15),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  PieChartWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isTablet
                        ? screenWidth * 0.98
                        : isBigTablet
                        ? screenWidth * 0.98
                        : screenWidth * 0.40,
                  ),
                  FeedbackWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.97
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.49
                        : screenWidth * 0.33,
                  ),
                  MonthlyRevenueWidget(
                    cwidth: isMobile
                        ? screenWidth * 0.95
                        : isSmallTablet
                        ? screenWidth * 0.97
                        : isTablet
                        ? screenWidth * 0.48
                        : isBigTablet
                        ? screenWidth * 0.48
                        : screenWidth * 0.23,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackWidget extends StatelessWidget {
  final double cwidth;
  const FeedbackWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Feedback',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
                child: ListView.separated(
                    itemCount: 6,
                  separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white24, height: 1),
                  itemBuilder: (context, index){
                    final feedback = [
                      {
                        'message': 'Thanks for exchanging my item so promptly',
                        'time': 'an hour ago'
                      },
                      {
                        'message': 'Super fast resolution, thank you!',
                        'time': 'an hour ago'
                      },
                      {    'message': 'Great service as always',
                        'time': '3 hours ago',},
                      {
                        'message': 'Helpful and efficient. Great service!',
                        'time': '4 hours ago',
                      },
                      {
                        'message': 'Fast and efficient, thanks.',
                        'time': '2 days ago',
                      },
                      {
                        'message': 'Super fast resolution, thank you!',
                        'time': 'an hour ago'
                      },
                    ][index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3A6FF8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback['message']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feedback['time']!,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                  },
                )
            )

          ],
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final double cwidth;
  const PieChartWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistics',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: const [
                  _LegendDot(color: Color(0xFF4FC3F7), text: 'Current'),
                  SizedBox(width: 12),
                  _LegendDot(color: Color(0xFFF5D76E), text: 'Previous'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 9,
                maxX: 15,
                minY: 0,
                maxY: 35,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 9:
                            return const Text('09:00',
                                style: TextStyle(color: Colors.white60));
                          case 12:
                            return const Text('12:00',
                                style: TextStyle(color: Colors.white60));
                          case 15:
                            return const Text('15:00',
                                style: TextStyle(color: Colors.white60));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [

                  LineChartBarData(
                    spots: const [
                      FlSpot(9, 19),
                      FlSpot(10, 15),
                      FlSpot(11, 11),
                      FlSpot(12, 23),
                      FlSpot(13, 24),
                      FlSpot(14, 30),
                      FlSpot(15, 31),
                    ],
                    isCurved: true,
                    color: const Color(0xFF4FC3F7),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),


                  LineChartBarData(
                    spots: const [
                      FlSpot(9, 11),
                      FlSpot(10, 20),
                      FlSpot(11, 12),
                      FlSpot(12, 15),
                      FlSpot(13, 20),
                      FlSpot(14, 26),
                      FlSpot(15, 24),
                    ],
                    isCurved: true,
                    color: const Color(0xFFF5D76E),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyRevenueWidget extends StatelessWidget {
  final double cwidth;
  const MonthlyRevenueWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Month',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Amount',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),

            Expanded(
              child: ListView.separated(
                itemCount: 12,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.white24, height: 1),
                itemBuilder: (context, index) {
                  final data = [
                    {'name': 'January', 'amount': '37'},
                    {'name': 'February', 'amount': '34'},
                    {'name': 'March', 'amount': '27'},
                    {'name': 'April', 'amount': '24'},
                    {'name': 'May', 'amount': '23'},
                    {'name': 'June', 'amount': '21'},
                    {'name': 'July', 'amount': '21'},
                    {'name': 'August', 'amount': '21'},
                    {'name': 'September', 'amount': '21'},
                    {'name': 'October', 'amount': '21'},
                    {'name': 'November', 'amount': '21'},
                    {'name': 'December', 'amount': '21'},
                  ][index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data['amount']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopWidget extends StatelessWidget {
  final double cwidth;
  const TopWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Compliance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Business Name',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Score',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),

            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.white24, height: 1),
                itemBuilder: (context, index) {
                  final data = [
                    {'name': 'Reece Martin', 'solved': '37'},
                    {'name': 'Robyn Mers', 'solved': '34'},
                    {'name': 'Julia Smith', 'solved': '27'},
                    {'name': 'Ebeneezer Grey', 'solved': '24'},
                    {'name': 'Marlon Brown', 'solved': '23'},
                    {'name': 'Heather Banks', 'solved': '21'},
                  ][index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data['solved']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),


    );
  }
}

class CsatWidget extends StatelessWidget {
  final double cwidth;
  const CsatWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cwidth,
      height: 235,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF182232),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Row(
            children: [
              Text(
                "CSAT",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                ),
              )
            ],
          ),

          // Progress indicator (simplified version)
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Filled portion (84%)
                FractionallySizedBox(
                  widthFactor: 0.84,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Percentage
          Text(
            '84%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),

          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MiddleWidget extends StatelessWidget {
  final double cwidth;
  const MiddleWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 235,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "95",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "%\n",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: "CSAT today",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RespWidget extends StatelessWidget {
  final double cwidth;
  const RespWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 235,
      width: cwidth,
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resp. time today",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "9",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "m\n",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: "FRT",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: const [
              Icon(Icons.arrow_drop_up, color: Colors.redAccent, size: 22),
              SizedBox(width: 4),
              Text(
                "11%",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
              SizedBox(width: 4),
              Text(
                "vs yesterday",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "95",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "%\n",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: "Within SLA",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkPlaceWidget extends StatelessWidget {
  final double cwidth;
  const WorkPlaceWidget({
    super.key, required this.cwidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cwidth,
      //height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Workplaces",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          //const SizedBox(height: 12),

          const Text(
            "23",
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            "Assigned",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),

          //const SizedBox(height: 14),

          //  Unassigned Box
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A2C4F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "16",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unassigned",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              //  Alert Badge
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

