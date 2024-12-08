import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TeamPage extends StatelessWidget {
  final Box teamBox = Hive.box('team');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فريق العمل',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: teamBox.listenable(),
          builder: (context, Box box, _) {
            // إذا كان الصندوق فارغاً
            if (box.isEmpty) {
              return Center(
                child: Text(
                  'لا يوجد أعضاء فريق حتى الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            } else {
              // عرض القائمة
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  var member = box.getAt(index);

                  // التأكد من وجود القيم قبل عرضها
                  String imageUrl = member['image'] ?? '';
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : AssetImage('assets/images/logo.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        member['name'] ?? 'اسم غير متوفر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الوظيفة: ${member['job'] ?? 'غير محددة'}',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'الهاتف: ${member['phone'] ?? 'غير متوفر'}',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'تاريخ الانضمام: ${member['joinDate'] ?? 'غير متوفر'}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.more_vert),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
