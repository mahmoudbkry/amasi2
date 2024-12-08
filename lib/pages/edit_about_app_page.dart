import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditAboutAppPage extends StatefulWidget {
  @override
  _EditAboutAppPageState createState() => _EditAboutAppPageState();
}

class _EditAboutAppPageState extends State<EditAboutAppPage> {
  final _controller = TextEditingController();
  late Box aboutAppBox;

  @override
  void initState() {
    super.initState();
    aboutAppBox = Hive.box('app_info');

    // جلب البيانات السابقة إذا وجدت، وإلا يكون الحقل فارغاً
    _controller.text = aboutAppBox.get('about_app', defaultValue: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة/تعديل "حول التطبيق"'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'حول التطبيق',
                border: OutlineInputBorder(),
                hintText: 'أدخل معلومات حول التطبيق هنا...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() {
    String newData = _controller.text.trim();

    if (newData.isNotEmpty) {
      aboutAppBox.put('about_app', newData);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ البيانات بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );

      // تفريغ الحقل بعد الحفظ
      setState(() {
        _controller.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال بعض المعلومات قبل الحفظ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
