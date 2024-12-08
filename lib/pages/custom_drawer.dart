import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BaseScaffold extends StatelessWidget {
  final String title; // عنوان AppBar
  final Widget body; // محتوى الصفحة

  BaseScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: CustomDrawer(), // القائمة الجانبية الموحدة
      body: body,
    );
  }
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
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
          ListTile(
            leading: Icon(Icons.article),
            title: Text('news').tr(),
            onTap: () {
              Navigator.pushNamed(context, '/news');
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text(tr('achievements')),
            onTap: () {
              Navigator.pushNamed(context, '/achievements');
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text(tr('team')),
            onTap: () {
              Navigator.pushNamed(context, '/team');
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text(tr('contact_us')),
            onTap: () {
              Navigator.pushNamed(context, '/contact_us');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(tr('about_us')),
            onTap: () {
              Navigator.pushNamed(context, '/about_us');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(tr('about_app')),
            onTap: () {
              Navigator.pushNamed(context, '/about_app');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(tr('settings')),
            onTap: () {
              Navigator.pushNamed(context, '/Login');
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text(tr('settings2')),
            onTap: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ],
      ),
    );
  }
}
