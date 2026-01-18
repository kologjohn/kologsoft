
import 'package:kologsoft/screens/branch_reg.dart';
import 'package:kologsoft/screens/login_screen.dart';
import 'package:kologsoft/screens/newstock.dart';
import 'package:kologsoft/screens/payment_duration_reg.dart';
import 'package:kologsoft/screens/payment_duration_view.dart';
import 'package:kologsoft/screens/product_category_reg.dart';
import 'package:kologsoft/screens/productcategory_view.dart';

import '../screens/branch_view.dart';
import '../screens/companylist.dart';
import '../screens/companyreg.dart';
import '../screens/customer_registration.dart';
import '../screens/home_dashboard.dart';
import '../screens/itemlist.dart';
import '../screens/itemreg.dart';
import '../screens/staff.dart';
import '../screens/stocking_mode.dart';
import '../screens/supplierlist.dart';
import '../screens/supplierscreen.dart';
import '../screens/warehousereg.dart';


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
  static const String itemreg = '/itemreg';
  static const String itemlist = '/itemlist';
  static const String branchview = '/branchview';
  static const String customerreg = '/customerreg';
  static const String productcatereg = '/productcatereg';
  static const String productcateview = '/productcateview';
  static const String paymentdurationreg = '/paymentdurationreg';
  static const String paymentdurationview = '/paymentdurationview';
  static const String newstock = '/newstock';
  static const String staffreg = '/staffreg';
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
  Routes.warehousereg: (context) =>  WarehouseRegistration(),
  Routes.warehousereg: (context) =>  WarehouseRegistration(),
  Routes.itemreg: (context) =>  ItemRegPage (),
  Routes.itemlist: (context) =>  ItemListPage (),
  Routes.branchview: (context) =>  BranchView (),
  Routes.customerreg: (context) =>  CustomerRegistration(),
  Routes.productcatereg: (context) =>  ProductCategoryReg(),
  Routes.productcateview: (context) =>  ProductCategoryView(),
  Routes.paymentdurationreg: (context) =>  PaymentDurationReg(),
  Routes.paymentdurationview: (context) =>  PaymentDurationView(),
  Routes.newstock: (context) =>  NewStock(),
  Routes.staffreg: (context) =>  Staff(),
};