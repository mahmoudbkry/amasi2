import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManageAdsPage extends StatefulWidget {
  @override
  _ManageAdsPageState createState() => _ManageAdsPageState();
}

class _ManageAdsPageState extends State<ManageAdsPage> {
  late Box adsBox;
  bool _isLoading = true;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController =
      TextEditingController(); // لم تعد مستخدمة، ولكنها متوفرة إذا احتجتها مستقبلاً
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!Hive.isBoxOpen('ads')) {
      await Hive.openBox('ads');
    }
    adsBox = Hive.box('ads');

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'إدارة الإعلانات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.green.shade700,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> ads = adsBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الإعلانات',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdDialog,
        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ads.isEmpty
            ? Center(
                child: Text(
                  'لا توجد إعلانات متاحة حالياً',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: ads.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // عدد الأعمدة
                    childAspectRatio: 0.8, // نسبة العرض إلى الارتفاع للكارت
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    var ad = ads[index];
                    String title = (ad['title'] ?? 'بدون عنوان').toString();
                    String desc = (ad['description'] ?? '').toString();
                    String imagePath = (ad['image_url'] ?? '').toString();
                    bool hasLocalImage =
                        imagePath.isNotEmpty && File(imagePath).existsSync();

                    String shortDesc = desc.isNotEmpty
                        ? (desc.length > 20
                            ? desc.substring(0, 20) + '...'
                            : desc)
                        : 'لا يوجد وصف';

                    return GestureDetector(
                      onTap: () => _showEditAdDialog(index, ad),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: hasLocalImage
                                    ? Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  shortDesc,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      _showEditAdDialog(index, ad);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteAd(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _deleteAd(int index) {
    setState(() {
      adsBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف الإعلان بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddAdDialog() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return _buildAdDialog(
          title: 'إضافة إعلان جديد',
          onConfirm: _addAd,
        );
      },
    );
  }

  void _showEditAdDialog(int index, dynamic ad) {
    titleController.text = ad['title']?.toString() ?? '';
    descriptionController.text = ad['description']?.toString() ?? '';
    priceController.text = ad['price']?.toString() ?? '';
    String imagePath = ad['image_url']?.toString() ?? '';
    selectedImage = imagePath.isNotEmpty ? File(imagePath) : null;

    showDialog(
      context: context,
      builder: (context) {
        return _buildAdDialog(
          title: 'تعديل الإعلان',
          onConfirm: () => _editAd(index),
        );
      },
    );
  }

  Widget _buildAdDialog(
      {required String title, required VoidCallback onConfirm}) {
    return AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(titleController, 'عنوان الإعلان'),
            SizedBox(height: 10),
            _buildTextField(descriptionController, 'وصف الإعلان', maxLines: 3),
            SizedBox(height: 10),
            // لم نعد نعرض السعر، ولكن إذا احتجت له مستقبلاً فهو متاح
            // _buildTextField(priceController, 'السعر', keyboardType: TextInputType.number),
            // SizedBox(height: 10),
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
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
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
              'اختر صورة للإعلان',
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(title.contains('إضافة') ? 'إضافة' : 'تحديث'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  void _addAd() {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        adsBox.add({
          'title': titleController.text,
          'description': descriptionController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الإعلان بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال العنوان والوصف واختيار صورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editAd(int index) {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedImage != null) {
      setState(() {
        adsBox.putAt(index, {
          'title': titleController.text,
          'description': descriptionController.text,
          'image_url': selectedImage!.path,
        });
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الإعلان بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال العنوان والوصف واختيار صورة'),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
