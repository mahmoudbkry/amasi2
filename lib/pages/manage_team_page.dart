// manage_team_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ManageTeamPage extends StatefulWidget {
  @override
  _ManageTeamPageState createState() => _ManageTeamPageState();
}

class _ManageTeamPageState extends State<ManageTeamPage> {
  final Box teamBox = Hive.box('team');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة فريق العمل',
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
                itemCount: teamBox.length,
                itemBuilder: (context, index) {
                  var member = teamBox.getAt(index);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: member['image_url'] != null
                          ? CircleAvatar(
                              backgroundImage:
                                  FileImage(File(member['image_url'])),
                              radius: 30,
                            )
                          : CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 30),
                            ),
                      title: Text(member['name'] ?? 'اسم غير متوفر'),
                      subtitle:
                          Text('الوظيفة: ${member['job'] ?? 'غير محددة'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditMemberDialog(index, member),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMember(index),
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
              onPressed: _showAddMemberDialog,
              icon: Icon(Icons.add),
              label: Text('إضافة عضو'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMember(int index) {
    setState(() {
      teamBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف العضو بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddMemberDialog() {
    nameController.clear();
    jobController.clear();
    phoneController.clear();
    joinDateController.clear();
    selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة عضو جديد'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, 'اسم العضو'),
                  SizedBox(height: 10),
                  _buildTextField(jobController, 'الوظيفة'),
                  SizedBox(height: 10),
                  _buildTextField(phoneController, 'رقم الهاتف'),
                  SizedBox(height: 10),
                  _buildTextField(joinDateController, 'تاريخ الانضمام'),
                  SizedBox(height: 10),
                  selectedImage != null
                      ? Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(selectedImage!),
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
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('لم يتم اختيار صورة')),
                        ),
                  SizedBox(height: 10),
                  Text(
                    'اختر صورة للعضو',
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
              onPressed: _addMember,
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

  void _addMember() {
    if (nameController.text.isNotEmpty &&
        jobController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        joinDateController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        teamBox.add({
          'name': nameController.text,
          'job': jobController.text,
          'phone': phoneController.text,
          'joinDate': joinDateController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة العضو بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال جميع المعلومات واختيار صورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditMemberDialog(int index, Map<String, dynamic> member) {
    nameController.text = member['name'] ?? '';
    jobController.text = member['job'] ?? '';
    phoneController.text = member['phone'] ?? '';
    joinDateController.text = member['joinDate'] ?? '';
    selectedImage = File(member['image_url']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل معلومات العضو'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, 'اسم العضو'),
                  SizedBox(height: 10),
                  _buildTextField(jobController, 'الوظيفة'),
                  SizedBox(height: 10),
                  _buildTextField(phoneController, 'رقم الهاتف'),
                  SizedBox(height: 10),
                  _buildTextField(joinDateController, 'تاريخ الانضمام'),
                  SizedBox(height: 10),
                  selectedImage != null
                      ? Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(selectedImage!),
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
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('لم يتم اختيار صورة')),
                        ),
                  SizedBox(height: 10),
                  Text(
                    'اختر صورة للعضو',
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
              onPressed: () => _editMember(index),
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

  void _editMember(int index) {
    if (nameController.text.isNotEmpty &&
        jobController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        joinDateController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        teamBox.putAt(index, {
          'name': nameController.text,
          'job': jobController.text,
          'phone': phoneController.text,
          'joinDate': joinDateController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث معلومات العضو بنجاح!'),
          backgroundColor: Colors.green,
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
