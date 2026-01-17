
import 'package:kologsoft/screens/branch_reg.dart';
import 'package:kologsoft/screens/login_screen.dart';

import '../screens/companylist.dart';
import '../screens/companyreg.dart';
import '../screens/customer_registration.dart';
import '../screens/home_dashboard.dart';
import '../screens/stocking_mode.dart';
import '../screens/supplierlist.dart';
import '../screens/supplierscreen.dart';


class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String adduser = '/adduser';
  static const String branchreg = '/branchreg';
  static const String supplierreg = '/supplierreg';
  static const String stockingmode = '/stockingmode';
  static const String supplierlist = '/supplierlist';
  static const String warehousereg = '/warehousereg';
  static const String warehouselist = '/warehouselist';
  static const String companyreg = '/companyreg';
  static const String companylist = '/companylist';
  static const String customerreg = '/customerreg';
}
final pages = {
  Routes.home: (context) => const HomeDashboard(),
  Routes.login: (context) => const LoginScreen(),
  Routes.branchreg: (context) => const BranchRegistration(),
  Routes.supplierreg: (context) => const SupplierRegistration(),
  Routes.stockingmode: (context) => const StockingMode(),
  Routes.supplierlist: (context) => const SupplierListPage(),
  Routes.companyreg: (context) => const CompanyRegPage(),
  Routes.companylist: (context) =>  CompanyListPage(),
  Routes.customerreg: (context) =>  CustomerRegistration(),
};