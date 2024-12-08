import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ManageAdminsPage extends StatefulWidget {
  @override
  _ManageAdminsPageState createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late Box adminsBox;
  bool _isLoading = true; // حالة التحميل

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // تأكد من فتح صندوق الـadmins
    if (!Hive.isBoxOpen('admins')) {
      await Hive.openBox('admins');
    }

    adminsBox = Hive.box('admins');
    setState(() {
      _isLoading = false;
    });
  }

  void _addAdmin() {
    // التحقق من أن اسم المستخدم وكلمة المرور غير فارغين
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      adminsBox.add({
        'username': usernameController.text.trim(), // إزالة الفراغات الزائدة
        'password': passwordController.text.trim(),
        'permissions': {
          'manage_ads': false,
          'manage_news': false,
          'manage_achievements': false,
          'manage_team': false,
        },
      });

      // إغلاق النافذة المنبثقة
      Navigator.of(context).pop();

      // تحديث حالة الواجهة
      setState(() {});
    } else {
      // عرض رسالة خطأ إذا كانت الحقول فارغة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال اسم المستخدم وكلمة المرور'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updatePermissions(int index, String permission, bool value) {
    var admin = adminsBox.getAt(index);
    // التأكد من وجود permissions وإن لم توجد نهيئها
    if (admin['permissions'] == null || admin['permissions'] is! Map) {
      admin['permissions'] = {
        'manage_ads': false,
        'manage_news': false,
        'manage_achievements': false,
        'manage_team': false,
      };
    }

    admin['permissions'][permission] = value;
    adminsBox.putAt(index, admin);
    setState(() {});
  }

  void _showAddAdminDialog() {
    usernameController.clear();
    passwordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة مدير جديد'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, 'اسم المستخدم'),
                SizedBox(height: 10),
                _buildTextField(passwordController, 'كلمة المرور',
                    obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addAdmin,
              child: Text('إضافة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // إذا ما زالت البيانات قيد التحميل
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Row(
            children: [
              NavigationRail(
                backgroundColor: Colors.black.withOpacity(0.7),
                selectedIconTheme: IconThemeData(color: Colors.white),
                unselectedIconTheme: IconThemeData(color: Colors.grey),
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('الرئيسية'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('الإعدادات'),
                  ),
                ],
                selectedIndex: 0,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: adminsBox.isNotEmpty
                          ? ListView.builder(
                              itemCount: adminsBox.length,
                              itemBuilder: (context, index) {
                                var admin = adminsBox.getAt(index);

                                // التأكد من وجود الحقل permissions
                                Map<String, dynamic> permissions = {
                                  'manage_ads': false,
                                  'manage_news': false,
                                  'manage_achievements': false,
                                  'manage_team': false,
                                };

                                if (admin['permissions'] is Map) {
                                  // دمج القيم القديمة مع الافتراضية
                                  permissions.addAll(Map<String, dynamic>.from(
                                      admin['permissions']));
                                } else {
                                  admin['permissions'] = permissions;
                                  adminsBox.putAt(index, admin);
                                }

                                return Card(
                                  margin: EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 4,
                                  child: ExpansionTile(
                                    title: Text(
                                      admin['username'] ?? 'بدون اسم مستخدم',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    children: [
                                      _buildPermissionSwitch(index, permissions,
                                          'manage_ads', 'إدارة الإعلانات'),
                                      _buildPermissionSwitch(index, permissions,
                                          'manage_news', 'إدارة الأخبار'),
                                      _buildPermissionSwitch(
                                          index,
                                          permissions,
                                          'manage_achievements',
                                          'إدارة الإنجازات'),
                                      _buildPermissionSwitch(index, permissions,
                                          'manage_team', 'إدارة فريق العمل'),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'لا يوجد مدراء بعد',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddAdminDialog,
                      icon: Icon(Icons.add),
                      label: Text('إضافة مدير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch(
      int index, Map<String, dynamic> permissions, String key, String label) {
    return SwitchListTile(
      title: Text(label),
      value: permissions[key] ?? false,
      onChanged: (value) => _updatePermissions(index, key, value),
    );
  }
}
