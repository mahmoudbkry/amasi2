import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class AchievementsPage extends StatelessWidget {
  final Box achievementsBox = Hive.box('achievements');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إنجازاتنا',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: achievementsBox.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: achievementsBox.length,
                itemBuilder: (context, index) {
                  var achievement = achievementsBox.getAt(index);

                  String title = (achievement['title'] ?? '').toString();
                  String description =
                      (achievement['description'] ?? '').toString();
                  String imagePath =
                      (achievement['image_url'] ?? '').toString();
                  bool hasImage =
                      imagePath.isNotEmpty && File(imagePath).existsSync();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: hasImage
                                ? Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image,
                                        color: Colors.grey, size: 50),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            title.isNotEmpty ? title : 'بدون عنوان',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            description.isNotEmpty ? description : 'بدون وصف',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // عرض سطرين فقط من الوصف
                            overflow: TextOverflow
                                .ellipsis, // وضع ... في نهاية النص إذا طال
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'لا توجد إنجازات حتى الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}
