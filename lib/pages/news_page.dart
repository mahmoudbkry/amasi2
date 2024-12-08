import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final Box newsBox = Hive.box('news');
  List<bool> expandedStates = [];

  @override
  void initState() {
    super.initState();
    expandedStates = List<bool>.filled(newsBox.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأخبار'),
      ),
      body: newsBox.isEmpty
          ? Center(
              child: Text(
                'لا توجد أخبار لعرضها',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // بطاقتان في السطر الواحد
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // نسبة العرض إلى الطول
                ),
                itemCount: newsBox.length,
                itemBuilder: (context, index) {
                  var news = newsBox.getAt(index);

                  // تأمين القيم
                  String title = (news['title'] ?? 'بدون عنوان').toString();
                  String desc = (news['description'] ?? '').toString();
                  String imagePath = (news['image_url'] ?? '').toString();
                  bool hasImage =
                      imagePath.isNotEmpty && File(imagePath).existsSync();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedStates[index] = !expandedStates[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // الصورة (ثابتة)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasImage
                                ? Image.file(
                                    File(imagePath),
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 8),
                          // العنوان
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          // النص القابل للتمدد
                          Expanded(
                            child: SingleChildScrollView(
                              physics: expandedStates[index]
                                  ? AlwaysScrollableScrollPhysics()
                                  : NeverScrollableScrollPhysics(),
                              child: Text(
                                desc,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: expandedStates[index] ? null : 3,
                                overflow: expandedStates[index]
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
