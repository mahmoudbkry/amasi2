import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final String whatsappNumber = "966598992228"; // ضع رقم واتساب هنا
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<String?> _getLocationDetails() async {
    try {
      // التأكد من أن خدمة الموقع مفعلة
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خدمة الموقع غير مفعلة. يرجى تفعيلها.')),
        );
        return null;
      }

      // طلب الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم رفض إذن الوصول إلى الموقع.')),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض إذن الموقع نهائيًا.')),
        );
        return null;
      }

      // جلب الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // استرداد اسم المدينة والدولة
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return "${placemark.locality}, ${placemark.country}"; // المدينة والدولة
      } else {
        return "موقع غير معروف";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب الموقع: $e')),
      );
      return null;
    }
  }

  void _handleSend() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    try {
      String? locationDetails = await _getLocationDetails();

      String formattedMessage = "تحية طيبة،\n\n"
          "الاسم: ${nameController.text}\n"
          "البريد الإلكتروني: ${emailController.text}\n"
          "محتوى الرسالة:\n${messageController.text}\n\n"
          "الموقع: ${locationDetails ?? 'غير متوفر'}";

      String url =
          "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(formattedMessage)}";

      if (await canLaunch(url)) {
        await launch(url);
        _clearFields();
      } else {
        throw 'لا يمكن فتح WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الإرسال: $e')),
      );
    }
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تواصل معنا',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات الاتصال',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'رقم الهاتف: $whatsappNumber',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'البريد الإلكتروني: info@example.com',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'الموقع: الرياض، السعودية',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'أرسل لنا رسالة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'الرسالة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    'إرسال عبر واتساب',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
