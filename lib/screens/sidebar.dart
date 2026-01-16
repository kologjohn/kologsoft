import 'package:flutter/material.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';

import '../providers/routes.dart';

class Sidebar extends StatelessWidget {


  const Sidebar({
    Key? key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Datafeed>(
      builder: (BuildContext context, Datafeed value, Widget? child) {
        return  Drawer(
          backgroundColor: const Color(0xFF0D1A26),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF0D1A26)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.factory, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'NWC SMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // User Management ExpansionTile directly under DrawerHeader
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white,
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF1976D2),
                    onPrimary: Colors.white,
                    background: Color(0xFF0D1A26),
                    onBackground: Colors.white,
                  ),
                ),
                child:ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white),
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(color: Colors.white),
                  ),
                  selectedTileColor: const Color(0xFF1976D2),
                  onTap: () {
                    //onSelectScreen(0);
                    Navigator.pop(context);
                  },
                ),
              ),
              ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                leading: const Icon(Icons.people, color: Colors.white),
                title: const Text(
                  'User Management',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.white),
                    title: const Text(
                      'Register Staff',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.branchreg);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'View Staff',
                      style: TextStyle(color: Colors.white),
                    ),
                   // onTap: onViewStaff,
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                leading: const Icon(Icons.people, color: Colors.white),
                title: const Text(
                  'System Setup',
                  style: TextStyle(color: Colors.white),
                ),
                children: [

                  ListTile(
                    leading: const Icon(Icons.add_business, color: Colors.white),
                    title: const Text(
                      'Stocking Mode ',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.stockingmode);

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.white),
                    title: const Text(
                      'Supplier Registration',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.supplierreg);
                    },
                  ),


                ],
              ),
              const Divider(color: Colors.white24),
              ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                leading: const Icon(Icons.people, color: Colors.white),
                title: const Text(
                  'Survey Setup',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_business, color: Colors.white),
                    title: const Text(
                      'Admin Setup ',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.adminsurvey);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_business, color: Colors.white),
                    title: const Text(
                      'Survey ',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.usersurvey);
                    },
                  ),




                ],
              ),
              const Divider(color: Colors.white24),
              ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                leading: const Icon(Icons.business, color: Colors.white),
                title: const Text(
                  'Workspace',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_business, color: Colors.white),
                    title: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.registerworkspace);

                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.add_business, color: Colors.white),
                    title: const Text(
                      'Certificate',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.cert);

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.white),
                    title: const Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.workspace);
                    },
                  ),
                  // ExpansionTile(
                  //   leading: const Icon(Icons.attach_money, color: Colors.white),
                  //   title: const Text(
                  //     'Revenue',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   children: [
                  //     ListTile(
                  //       leading: const Icon(Icons.add, color: Colors.white),
                  //       title: const Text(
                  //         'Register',
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //       onTap: onRevenueRegister,
                  //     ),
                  //     ListTile(
                  //       leading: const Icon(Icons.list, color: Colors.white),
                  //       title: const Text(
                  //         'View',
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //       onTap: onRevenueView,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const Divider(color: Colors.white24),
              ListTile(

                leading: const Icon(Icons.login, color: Colors.white),
                title: const Text(
                  'logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async  {
                  await value.logout(context);
                  // Navigator.pushNamed(context, Routes.homedashboard);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
