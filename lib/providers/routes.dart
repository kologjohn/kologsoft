import 'package:kologsoft/screens/branch_reg.dart';
import 'package:kologsoft/screens/login_screen.dart';
import 'package:kologsoft/screens/newstock.dart';
import 'package:kologsoft/screens/payment_duration_reg.dart';
import 'package:kologsoft/screens/payment_duration_view.dart';
import 'package:kologsoft/screens/product_category_reg.dart';
import 'package:kologsoft/screens/productcategory_view.dart';
import 'package:kologsoft/screens/sales_page.dart';
import 'package:kologsoft/screens/staff_profile.dart';
import 'package:kologsoft/providers/route_guard.dart';
import 'package:kologsoft/screens/transfer_page.dart';
import 'package:kologsoft/screens/transfers.dart';

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
  static const String staffprofile = '/staffprofile';
  static const String sales = '/sales';
  static const String transfers = '/transfers';
  static const String transferpage = '/transferpage';
}

final pages = {
  Routes.login: (context) => const LoginScreen(),
  Routes.home: (context) => const RouteGuard(child: HomeDashboard()),
  Routes.branchreg: (context) => const RouteGuard(child: BranchRegistration()),
  Routes.supplierreg: (context) =>
      const RouteGuard(child: SupplierRegistration()),
  Routes.stockingmode: (context) => const RouteGuard(child: StockingMode()),
  Routes.supplierlist: (context) => const RouteGuard(child: SupplierListPage()),
  Routes.companyreg: (context) => RouteGuard(
    child: CompanyRegPage(),
    allowedAccessLevels: ['admin', 'manager','super admin'],
  ),
  Routes.companylist: (context) => RouteGuard(child: CompanyListPage()),
  Routes.warehousereg: (context) => RouteGuard(child: WarehouseRegistration()),
  Routes.itemreg: (context) => RouteGuard(child: ItemRegPage()),
  Routes.itemlist: (context) => RouteGuard(child: ItemListPage()),
  Routes.branchview: (context) => RouteGuard(child: BranchView()),
  Routes.customerreg: (context) => RouteGuard(child: CustomerRegistration()),
  Routes.productcatereg: (context) => RouteGuard(child: ProductCategoryReg()),
  Routes.productcateview: (context) => RouteGuard(child: ProductCategoryView()),
  Routes.paymentdurationreg: (context) =>
      RouteGuard(child: PaymentDurationReg()),
  Routes.paymentdurationview: (context) =>
      RouteGuard(child: PaymentDurationView()),
  Routes.newstock: (context) => RouteGuard(child: NewStock()),
  Routes.staffreg: (context) => RouteGuard(child: Staff(), allowedAccessLevels: ['admin', 'manager','super admin']),
  Routes.staffprofile: (context) => const RouteGuard(child: StaffProfile()),
  Routes.sales: (context) => const RouteGuard(child: SalesPage()),
  Routes.transfers: (context) => const RouteGuard(child: Transfers()),
  Routes.transferpage: (context) => const RouteGuard(child: TransferPage()),
};
