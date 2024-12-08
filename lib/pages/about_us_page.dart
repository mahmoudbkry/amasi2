import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AboutUsPage extends StatelessWidget {
  final Box aboutUsBox = Hive.box('app_info');

  @override
  Widget build(BuildContext context) {
    var aboutUsData = aboutUsBox.get('about_us');

    String textContent = '';
    String? imageUrl;

    if (aboutUsData == null) {
      textContent = 'لا توجد معلومات متاحة حاليًا';
    } else if (aboutUsData is String) {
      textContent =
          aboutUsData.isNotEmpty ? aboutUsData : 'لا توجد معلومات متاحة حاليًا';
    } else if (aboutUsData is Map) {
      textContent =
          (aboutUsData['text'] ?? 'لا توجد معلومات متاحة حاليًا').toString();
      imageUrl = aboutUsData['image']?.toString();
    }

    bool hasNetworkImage = (imageUrl != null && imageUrl.startsWith('http'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'من نحن',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // إذا كانت هناك صورة، أظهرها
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
                // البطاقة في منتصف الصفحة مع خلفية بيضاء
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
