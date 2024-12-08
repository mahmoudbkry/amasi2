import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Pages
import 'pages/admin_page.dart';
import 'pages/manage_achievements_page.dart';
import 'pages/manage_team_page.dart';
import 'pages/manage_news_page.dart';
import 'pages/about_us_page.dart';
import 'pages/about_app_page.dart';
import 'pages/contact_us_page.dart';
import 'pages/team_page.dart';
import 'pages/achievements_page.dart';
import 'pages/edit_about_app_page.dart';
import 'pages/edit_about_us_page.dart';
import 'pages/manage_admins_page.dart';
import 'pages/new_home_page.dart';
import 'pages/news_page.dart';
import 'pages/manage_ads_page.dart';
import 'pages/statistics_page.dart';
import 'pages/login_admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox('ads'),
    Hive.openBox('achievements'),
    Hive.openBox('team'),
    Hive.openBox('news'),
    Hive.openBox('app_info'),
    Hive.openBox('slider_ads'),
    Hive.openBox('manage_news'),
    Hive.openBox('manage_admins'),
    Hive.openBox('manage_ads_page'),
    Hive.openBox('login_admin_page'),
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('ar'), Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: Locale('ar'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/Login': (context) => BaseScaffold(
              title: tr('login'),
              body: LoginAdminPage(),
            ),
        '/home': (context) => BaseScaffold(
              title: tr('home'),
              body: NewHomePage(),
            ),
        '/news': (context) => BaseScaffold(
              title: tr('news'),
              body: NewsPage(),
            ),
        '/admin': (context) => BaseScaffold(
              title: tr('admin'),
              body: AdminPage(),
            ),
        '/manage_ads': (context) => BaseScaffold(
              title: tr('manage_ads'),
              body: ManageAdsPage(),
            ),
        '/manage_achievements': (context) => BaseScaffold(
              title: tr('manage_achievements'),
              body: ManageAchievementsPage(),
            ),
        '/manage_team': (context) => BaseScaffold(
              title: tr('manage_team'),
              body: ManageTeamPage(),
            ),
        '/manage_news': (context) => BaseScaffold(
              title: tr('manage_news'),
              body: ManageNewsPage(),
            ),
        '/about_us': (context) => BaseScaffold(
              title: tr('about_us'),
              body: AboutUsPage(),
            ),
        '/about_app': (context) => BaseScaffold(
              title: tr('about_app'),
              body: AboutAppPage(),
            ),
        '/contact_us': (context) => BaseScaffold(
              title: tr('contact_us'),
              body: ContactUsPage(),
            ),
        '/team': (context) => BaseScaffold(
              title: tr('team'),
              body: TeamPage(),
            ),
        '/achievements': (context) => BaseScaffold(
              title: tr('achievements'),
              body: AchievementsPage(),
            ),
        '/edit_about_us': (context) => BaseScaffold(
              title: tr('edit_about_us'),
              body: EditAboutUsPage(),
            ),
        '/edit_about_app': (context) => BaseScaffold(
              title: tr('edit_about_app'),
              body: EditAboutAppPage(),
            ),
        '/manage_admins_page': (context) => BaseScaffold(
              title: tr('manage_admins'),
              body: ManageAdminsPage(),
            ),
        '/statistics': (context) => BaseScaffold(
              title: tr('statistics'),
              body: StatisticsPage(),
            ),
      },
    );
  }
}

// تصميم شامل للصفحات باستخدام BaseScaffold
class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  BaseScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: CustomDrawer(), // القائمة الجانبية
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: body,
      ),
    );
  }
}

// القائمة الجانبية مع زر اللغة
class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 10),
                Text(
                  tr('app_title'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.article,
            label: tr('news'),
            route: '/news',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            label: tr('achievements'),
            route: '/achievements',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            label: tr('team'),
            route: '/team',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.contact_mail,
            label: tr('contact_us'),
            route: '/contact_us',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            label: tr('about_us'),
            route: '/about_us',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            label: tr('about_app'),
            route: '/about_app',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            label: tr('settings'),
            route: '/Login',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.admin_panel_settings,
            label: tr('settings2'),
            route: '/admin',
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(tr('language')),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              items: [
                DropdownMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  context.setLocale(locale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
