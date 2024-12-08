import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ManageNewsPage extends StatefulWidget {
  @override
  _ManageNewsPageState createState() => _ManageNewsPageState();
}

class _ManageNewsPageState extends State<ManageNewsPage> {
  final Box newsBox = Hive.box('news');

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الأخبار',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: newsBox.length,
                itemBuilder: (context, index) {
                  var news = newsBox.getAt(index);

                  // تأمين القيم
                  String title = (news['title'] ?? 'بدون عنوان').toString();
                  String desc = (news['description'] ?? '').toString();
                  String shortDesc = desc.isNotEmpty
                      ? (desc.length > 20 ? desc.substring(0, 20) : desc)
                      : 'لا يوجد محتوى';

                  // التحقق من وجود الصورة
                  String imagePath = (news['image_url'] ?? '').toString();
                  bool hasImage =
                      imagePath.isNotEmpty && File(imagePath).existsSync();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: hasImage
                          ? Image.file(
                              File(imagePath),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                      title: Text(title),
                      subtitle: Text(shortDesc),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditNewsDialog(index, news),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNews(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _showAddNewsDialog,
              icon: Icon(Icons.add),
              label: Text('إضافة خبر'),
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

  void _deleteNews(int index) {
    setState(() {
      newsBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف الخبر بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddNewsDialog() {
    titleController.clear();
    contentController.clear();
    selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة خبر جديد'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الخبر',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'محتوى الخبر',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                SizedBox(height: 10),
                selectedImage != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              selectedImage!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'تم اختيار الصورة بنجاح!',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text('لم يتم اختيار صورة'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera),
                      label: Text('الكاميرا'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text('المكتبة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addNews,
              child: Text('إضافة'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ],
        );
      },
    );
  }

  void _addNews() {
    if (titleController.text.isNotEmpty &&
        contentController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        newsBox.add({
          'title': titleController.text,
          'description': contentController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الخبر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال العنوان والمحتوى واختيار صورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditNewsDialog(int index, Map<String, dynamic> news) {
    titleController.text = news['title']?.toString() ?? '';
    contentController.text = news['description']?.toString() ?? '';
    String imagePath = (news['image_url'] ?? '').toString();
    selectedImage = imagePath.isNotEmpty ? File(imagePath) : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الخبر'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الخبر',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'محتوى الخبر',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                SizedBox(height: 10),
                selectedImage != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              selectedImage!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'تم اختيار الصورة بنجاح!',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text('لم يتم اختيار صورة'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera),
                      label: Text('الكاميرا'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text('المكتبة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => _editNews(index),
              child: Text('تحديث'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ],
        );
      },
    );
  }

  void _editNews(int index) {
    if (titleController.text.isNotEmpty &&
        contentController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        newsBox.putAt(index, {
          'title': titleController.text,
          'description': contentController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الخبر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال العنوان والمحتوى واختيار صورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }
}
