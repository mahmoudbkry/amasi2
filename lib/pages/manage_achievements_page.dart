// manage_achievements_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ManageAchievementsPage extends StatefulWidget {
  @override
  _ManageAchievementsPageState createState() => _ManageAchievementsPageState();
}

class _ManageAchievementsPageState extends State<ManageAchievementsPage> {
  final Box achievementsBox = Hive.box('achievements');

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController(); // حقل وصف الإنجاز
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الإنجازات',
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
                itemCount: achievementsBox.length,
                itemBuilder: (context, index) {
                  var achievement = achievementsBox.getAt(index);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: achievement['image_url'] != null
                          ? Image.file(
                              File(achievement['image_url']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                      title: Text(achievement['title'] ?? 'بدون عنوان'),
                      subtitle: Text(
                        achievement['description'] ?? 'بدون وصف',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditAchievementDialog(index, achievement),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAchievement(index),
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
              onPressed: _showAddAchievementDialog,
              icon: Icon(Icons.add),
              label: Text('إضافة إنجاز'),
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

  void _deleteAchievement(int index) {
    setState(() {
      achievementsBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف الإنجاز بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddAchievementDialog() {
    titleController.clear();
    descriptionController.clear(); // إفراغ حقل الوصف
    selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة إنجاز جديد'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الإنجاز',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'وصف الإنجاز',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 10),
                  selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            selectedImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('لم يتم اختيار صورة')),
                        ),
                  SizedBox(height: 10),
                  Text(
                    'اختر صورة للإنجاز',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addAchievement,
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

  void _addAchievement() {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        achievementsBox.add({
          'title': titleController.text,
          'description': descriptionController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الإنجاز بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال عنوان ووصف واختيار صورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAchievementDialog(int index, Map<String, dynamic> achievement) {
    titleController.text = achievement['title'] ?? '';
    descriptionController.text = achievement['description'] ?? '';
    selectedImage = File(achievement['image_url']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الإنجاز'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الإنجاز',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'وصف الإنجاز',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 10),
                  selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            selectedImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('لم يتم اختيار صورة')),
                        ),
                  SizedBox(height: 10),
                  Text(
                    'اختر صورة للإنجاز',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => _editAchievement(index),
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

  void _editAchievement(int index) {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        achievementsBox.putAt(index, {
          'title': titleController.text,
          'description': descriptionController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الإنجاز بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال عنوان ووصف واختيار صورة'),
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
