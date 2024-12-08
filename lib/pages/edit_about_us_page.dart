import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditAboutUsPage extends StatefulWidget {
  @override
  _EditAboutUsPageState createState() => _EditAboutUsPageState();
}

class _EditAboutUsPageState extends State<EditAboutUsPage> {
  final _controller = TextEditingController();
  late Box aboutUsBox;

  @override
  void initState() {
    super.initState();
    aboutUsBox = Hive.box('app_info');

    // جلب البيانات السابقة إذا وجدت، وإلا يكون الحقل فارغاً
    _controller.text = aboutUsBox.get('about_us', defaultValue: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة/تعديل "من نحن"'),
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
                labelText: 'من نحن',
                border: OutlineInputBorder(),
                hintText: 'أدخل معلومات "من نحن" هنا...',
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
      aboutUsBox.put('about_us', newData);

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
