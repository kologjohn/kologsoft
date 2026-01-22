import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:kologsoft/screens/sidebar.dart';
import 'package:kologsoft/widgets/offline_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/routes.dart';
import 'debtpage.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Datafeed>().getdata();
    });
  }

  void _showLogoutDialog(BuildContext context, Datafeed datafeed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                datafeed.logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, Datafeed datafeed) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.lock_reset,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Update your account password',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: !showCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showCurrentPassword = !showCurrentPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !showNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showNewPassword = !showNewPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          helperText: 'Must be at least 6 characters',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() => isLoading = true);
                                      try {
                                        await datafeed.changePassword(
                                          currentPasswordController.text,
                                          newPasswordController.text,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password changed successfully',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() => isLoading = false);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Update Password'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth <= 512;
    bool isSmallTablet = screenWidth < 774;
    bool isTablet = screenWidth < 900;
    bool isMediumTablet = screenWidth < 1087;
    bool isBigTablet = screenWidth < 1200;
    print(screenWidth);

    return Consumer<Datafeed>(
      builder: (BuildContext context, Datafeed value, Widget? child) {
        return Scaffold(
          backgroundColor: const Color(0xFF101A23),
          appBar: AppBar(
            title: Text(value.company.toString().toUpperCase()),
            centerTitle: true,
            backgroundColor: const Color(0xFF0D1A26),
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              // User menu
              PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 16,
                      child: Text(
                        value.staff.isNotEmpty
                            ? value.staff[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (screenWidth > 600)
                      Text(
                        value.staff.isNotEmpty ? value.staff : 'User',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                offset: const Offset(0, 50),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.staff.isNotEmpty ? value.staff : 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        if (value.companyemail.isNotEmpty)
                          Text(
                            value.companyemail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        const Divider(),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'My Profile',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 20, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20, color: Colors.red),
                        const SizedBox(width: 12),
                        const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (String selectedValue) async {
                  if (selectedValue == 'logout') {
                    _showLogoutDialog(context, value);
                  } else if (selectedValue == 'password') {
                    _showChangePasswordDialog(context, value);
                  } else if (selectedValue == 'profile') {
                    Navigator.pushNamed(context, Routes.staffprofile);
                  }
                },
              ),
            ],
          ),
          drawer: Sidebar(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OfflineIndicator(),
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
                      MomoKpiWidget(
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
                        todayAmount: 2890.70,
                        yesterdayAmount: 1980.00,
                      ),

                      // MiddleWidget(
                      //   cwidth: isMobile
                      //       ? screenWidth * 0.95
                      //       : isSmallTablet
                      //       ? screenWidth * 0.47
                      //       : isMediumTablet
                      //       ? screenWidth * 0.21
                      //       : isTablet
                      //       ? screenWidth * 0.48
                      //       : isBigTablet
                      //       ? screenWidth * 0.15
                      //       : screenWidth * 0.16,
                      // ),
                      // CsatWidget(
                      //   cwidth: isMobile
                      //       ? screenWidth * 0.95
                      //       : isSmallTablet
                      //       ? screenWidth * 0.47
                      //       : isMediumTablet
                      //       ? screenWidth * 0.21
                      //       : isTablet
                      //       ? screenWidth * 0.48
                      //       : isBigTablet
                      //       ? screenWidth * 0.15
                      //       : screenWidth * 0.16,
                      // ),
                      TotalDebtWidget(
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
                            totalDebt: 18850.50,
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 85,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        enlargeCenterPage: false,
                        viewportFraction: isMobile ? 0.45 : isSmallTablet ? 0.30 : isTablet ? 0.25 : 0.15,
                        enableInfiniteScroll: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: [
                        _statCard(
                          title: "Stock value",
                          value: "41000",
                          subtitle: "+12% from yesterday",
                          icon: Icons.trending_up,
                          iconColor: Colors.green,
                        ),
                        _statCard(
                          title: "Total discount",
                          value: "0.00",
                          subtitle: "+8% from yesterday",
                          icon: Icons.people_outline,
                          iconColor: Colors.blue,
                        ),
                        _statCard(
                          title: "Re-order",
                          value: "7",
                          subtitle: "Requires attention",
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange,
                        ),
                        _statCard(
                          title: "Expiring Soon",
                          value: "12",
                          subtitle: "Within 30 days",
                          icon: Icons.schedule,
                          iconColor: Colors.redAccent,
                        ),
                        _statCard(
                          title: "Finished Stock",
                          value: "12",
                          subtitle: "Within 30 days",
                          icon: Icons.security_update_good_sharp,
                          iconColor: Colors.lightBlue,
                        ),
                        _statCard(
                          title: "Available",
                          value: "12",
                          subtitle: "Within 30 days",
                          icon: Icons.new_label_sharp,
                          iconColor: Colors.lightGreen,
                        ),
                        _statCard(
                          title: "VAT",
                          value: "12",
                          subtitle: "Within 30 days",
                          icon: Icons.schedule,
                          iconColor: Colors.redAccent,
                        ),
                      ],
                    ),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FeedbackWidget extends StatelessWidget {
  final double cwidth;
  const FeedbackWidget({super.key, required this.cwidth});

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
                itemBuilder: (context, index) {
                  final feedback = [
                    {
                      'message': 'Thanks for exchanging my item so promptly',
                      'time': 'an hour ago',
                    },
                    {
                      'message': 'Super fast resolution, thank you!',
                      'time': 'an hour ago',
                    },
                    {
                      'message': 'Great service as always',
                      'time': '3 hours ago',
                    },
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
                      'time': 'an hour ago',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final double cwidth;
  const PieChartWidget({super.key, required this.cwidth});

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
                'Last week and current sales comparison',
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
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: 35,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
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
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final style = const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        );

                        switch (value.toInt()) {
                          case 1:
                            return Text('Mon', style: style);
                          case 2:
                            return Text('Tue', style: style);
                          case 3:
                            return Text('Wed', style: style);
                          case 4:
                            return Text('Thu', style: style);
                          case 5:
                            return Text('Fri', style: style);
                          case 6:
                            return Text('Sat', style: style);
                          case 7:
                            return Text('Sun', style: style);
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 19), // Mon
                      FlSpot(2, 15), // Tue
                      FlSpot(3, 11), // Wed
                      FlSpot(4, 23), // Thu
                      FlSpot(5, 24), // Fri
                      FlSpot(6, 30), // Sat
                      FlSpot(7, 31), // Sun
                    ],

                    isCurved: true,
                    color: const Color(0xFF4FC3F7),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),

                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 11),
                      FlSpot(2, 20),
                      FlSpot(3, 12),
                      FlSpot(4, 15),
                      FlSpot(5, 20),
                      FlSpot(6, 26),
                      FlSpot(7, 24),
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
  const MonthlyRevenueWidget({super.key, required this.cwidth});

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
              'Best 10 financial performing Items',
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
                  'Item Name',
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
                itemCount: 10,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white24, height: 1),
                itemBuilder: (context, index) {
                  final data = [
                    {'name': 'Milk', 'amount': 'GHC 37'},
                    {'name': 'Malt', 'amount': 'GHC 34'},
                    {'name': 'Cooker', 'amount': 'GHC 27'},
                    {'name': 'Kettle', 'amount': 'GHC 24'},
                    {'name': 'Detergents', 'amount': 'GHC 23'},
                    {'name': 'Milk', 'amount': 'GHC 37'},
                    {'name': 'Malt', 'amount': 'GHC 34'},
                    {'name': 'Cooker', 'amount': 'GHC 27'},
                    {'name': 'Kettle', 'amount': 'GHC 24'},
                    {'name': 'Detergents', 'amount': 'GHC 23'},

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
  const TopWidget({super.key, required this.cwidth});

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
              'Best 10 qtys Performing Items',
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
                  'Item Name',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Qty',
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
                    {'name': 'Milk', 'solved': '37'},
                    {'name': 'Bread', 'solved': '34'},
                    {'name': 'Electric Stove', 'solved': '27'},
                    {'name': 'Malt', 'solved': '24'},
                    {'name': 'Brown Sugar', 'solved': '23'},
                    {'name': 'Detergents', 'solved': '21'},
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
  const CsatWidget({super.key, required this.cwidth});

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
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '100%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
  const MiddleWidget({super.key, required this.cwidth});

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
                  text: "950",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "GHC\n",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                TextSpan(
                  text: "MOMO today",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
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
  const RespWidget({super.key, required this.cwidth});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Expense",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.receipt_long, color: Colors.blue,)
            ],
          ),

          const SizedBox(height: 16),

          FittedBox(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "90,000,00.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "GHC\n",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  TextSpan(
                    text: "January",
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
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
                "vs last month",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "5",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "%\n",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                TextSpan(
                  text: "Within this month",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
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
  const WorkPlaceWidget({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cwidth,
      height: 235,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales Today",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.shopping_cart, color: Colors.greenAccent)
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              "30,000,088.00",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Text(
            "Total Sales",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),

          const SizedBox(height: 8),

          //  Unassigned Box
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent, width: 1),
                ),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "10,023,000.00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Cash Sales",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.bookmark_added_outlined, color: Colors.white, size: 12,),
                  ),
                ),
              ),

            ],
          ),
          Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:  Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Credit Sales",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    Text(
                      "10,023,000.00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                  height: 20,
                  width: 20,
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}


class MomoKpiWidget extends StatefulWidget {
  final double cwidth;
  final double todayAmount;
  final double yesterdayAmount;

  const MomoKpiWidget({
    super.key,
    required this.cwidth,
    required this.todayAmount,
    required this.yesterdayAmount,
  });

  @override
  State<MomoKpiWidget> createState() => _MomoKpiWidgetState();
}

class _MomoKpiWidgetState extends State<MomoKpiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _amountAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _amountAnim = Tween<double>(
      begin: 0,
      end: widget.todayAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  double get difference => widget.todayAmount - widget.yesterdayAmount;

  double get percentage =>
      widget.yesterdayAmount == 0
          ? 0
          : (difference / widget.yesterdayAmount) * 100;

  bool get isIncrease => difference >= 0;

  Color get trendColor => isIncrease ? Colors.greenAccent : Colors.redAccent;

  IconData get trendIcon =>
      isIncrease ? Icons.trending_up : Icons.trending_down;

  String get percentLabel =>
      "${isIncrease ? '+' : '-'}${percentage.abs().toStringAsFixed(1)}%";

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
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
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
              Text(
                "Total MOMO",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.phone_android, color: Colors.greenAccent),
            ],
          ),

          const SizedBox(height: 14),

          AnimatedBuilder(
            animation: _amountAnim,
            builder: (context, child) {
              return FittedBox(
                child: Text(
                  "GHS ${_amountAnim.value.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 6),

          const Text(
            "Today",
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),

          const Spacer(),


          Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 18),
              const SizedBox(width: 4),
              Text(
                percentLabel,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "vs yesterday",
                style: TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),

          const SizedBox(height: 10),


          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: min(percentage.abs() / 100, 1),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(trendColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

Widget _statCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color iconColor,
}) {
  return Container(
    width: 200,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Color(0xFF182232),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70
              ),
            ),
            Icon(icon, color: iconColor, size: 20),
          ],
        ),

        const SizedBox(height: 4),

        // Value
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    ),
  );
}
