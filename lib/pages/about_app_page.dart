import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AboutAppPage extends StatelessWidget {
  final Box appInfoBox = Hive.box('app_info');

  @override
  Widget build(BuildContext context) {
    var aboutAppData = appInfoBox.get('about_app');

    // قد يكون نصاً أو خريطة
    String textContent = '';
    String? imageUrl;

    if (aboutAppData == null) {
      textContent = 'لا توجد معلومات متاحة حاليًا';
    } else if (aboutAppData is String) {
      textContent = aboutAppData.isNotEmpty
          ? aboutAppData
          : 'لا توجد معلومات متاحة حاليًا';
    } else if (aboutAppData is Map) {
      textContent =
          (aboutAppData['text'] ?? 'لا توجد معلومات متاحة حاليًا').toString();
      imageUrl = aboutAppData['image']?.toString();
    }

    bool hasNetworkImage = (imageUrl != null && imageUrl.startsWith('http'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حول التطبيق',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: hasNetworkImage
                          ? FadeInImage(
                              placeholder:
                                  AssetImage('assets/images/placeholder.png'),
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/default_image.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    textContent,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  label: Text('رجوع', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
