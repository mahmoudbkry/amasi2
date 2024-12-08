import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginAdminPage extends StatefulWidget {
  @override
  _LoginAdminPageState createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // فتح صندوق المستخدمين
      var box = await Hive.openBox<Map>('users');

      // البحث عن اسم المستخدم وكلمة المرور
      final user = box.values.cast<Map>().firstWhere(
            (user) =>
                user['username'] == usernameController.text &&
                user['password'] == passwordController.text,
            orElse: () => {},
          );

      setState(() {
        isLoading = false;
      });

      if (user.isNotEmpty) {
        // نجاح تسجيل الدخول، الانتقال إلى صفحة المدير
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        // فشل تسجيل الدخول، عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // عرض رسالة خطأ في حالة وجود مشكلة في قاعدة البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء محاولة تسجيل الدخول: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل دخول المدير'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'اسم المستخدم'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'كلمة المرور'),
            ),
            SizedBox(height: 32),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text('تسجيل الدخول'),
                  ),
          ],
        ),
      ),
    );
  }
}
