
import 'package:kologsoft/screens/branch_reg.dart';
import 'package:kologsoft/screens/branch_view.dart';
import 'package:kologsoft/screens/login_screen.dart';

import '../screens/home_dashboard.dart';
import '../screens/stocking_mode.dart';
import '../screens/supplierlist.dart';
import '../screens/supplierscreen.dart';
import '../screens/warehouselist.dart';
import '../screens/warehousereg.dart';


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
  static const String branchreg = '/branchreg';
  static const String supplierreg = '/supplierreg';
  static const String stockingmode = '/stockingmode';
  static const String supplierlist = '/supplierlist';
  static const String warehousereg = '/warehousereg';
  static const String warehouselist = '/warehouselist';
  static const String branchview = '/branchview';
}
final pages = {
  Routes.home: (context) => const HomeDashboard(),
  Routes.login: (context) => const LoginScreen(),
  Routes.branchreg: (context) => const BranchRegistration(),
  Routes.supplierreg: (context) => const SupplierRegistration(),
  Routes.stockingmode: (context) => const StockingMode(),
  Routes.supplierlist: (context) => const SupplierListPage(),
  Routes.warehousereg: (context) => const WarehouseRegistration(),
  Routes.warehouselist: (context) =>  WarehouseListPage (),
  Routes.branchview: (context) =>  BranchView (),
};