
import 'package:kologsoft/screens/login_screen.dart';

import '../screens/home_dashboard.dart';
import '../screens/supplierscreen.dart';


class Routes {
  static const String home = '/home';
  static const String workspace = '/workspace';
  static const String registerworkspace = '/registerworkspace';
  static const String revenueModelForm = '/revenueModelForm';
  static const String login = '/login';
   static const String supplierreg = '/supplierreg';
}
final pages = {
  Routes.home: (context) => const HomeDashboard(),
  Routes.login: (context) => const LoginScreen(),
  Routes.supplierreg: (context) => const SupplierRegistration(),

};