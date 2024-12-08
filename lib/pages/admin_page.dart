// admin_page.dart

import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة التحكم',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            _buildAdminOption(
              context,
              title: 'إدارة الإعلانات',
              icon: Icons.ad_units,
              route: '/manage_ads',
            ),
            _buildAdminOption(
              context,
              title: 'إدارة الإنجازات',
              icon: Icons.star,
              route: '/manage_achievements',
            ),
            _buildAdminOption(
              context,
              title: 'إدارة فريق العمل',
              icon: Icons.group,
              route: '/manage_team',
            ),
            _buildAdminOption(
              context,
              title: 'إدارة الأخبار',
              icon: Icons.newspaper,
              route: '/manage_news',
            ),
            _buildAdminOption(
              context,
              title: 'من نحن',
              icon: Icons.info,
              route: '/edit_about_us',
            ),
            _buildAdminOption(
              context,
              title: 'حول التطبيق',
              icon: Icons.app_settings_alt,
              route: '/edit_about_app',
            ),
            _buildAdminOption(
              context,
              title: 'إدارة المديرين',
              icon: Icons.admin_panel_settings,
              route: '/manage_admins_page',
            ),
            _buildAdminOption(
              context,
              title: 'الإحصائيات',
              icon: Icons.bar_chart,
              route: '/statistics', // مسار صفحة الإحصائيات
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOption(BuildContext context,
      {required String title, required IconData icon, required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.green,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
