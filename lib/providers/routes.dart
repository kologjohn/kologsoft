
import 'package:kologsoft/screens/login_screen.dart';

import '../screens/home_dashboard.dart';
import '../screens/stocking_mode.dart';


class Routes {
  static const String home = '/home';
  static const String workspace = '/workspace';
  static const String registerworkspace = '/registerworkspace';
  static const String revenueModelForm = '/revenueModelForm';
  static const String login = '/login';
  static const String adduser = '/adduser';
  static const String billingsetup = '/billingsetup';
  static const String workspaceclass = '/workspaceclass';
  static const String workspacecategory = '/workspacecategory';
  static const String revenue = '/revenue';
  static const String billingtype = '/billingtype';
  static const String cert = '/cert';
  static const String adminsurvey = '/adminsurvey';
  static const String usersurvey = '/usersurvey';
  static const String stockingmode = '/stockingmode';
}
final pages = {
  Routes.home: (context) => const HomeDashboard(),
  Routes.login: (context) => const LoginScreen(),
  Routes.stockingmode: (context) => const StockingMode(),

};