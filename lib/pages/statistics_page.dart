import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // بيانات الإحصائيات
    final Map<String, int> stats = {
      'الإعلانات': 25,
      'الإنجازات': 40,
      'الأخبار': 35,
      'الزوار': 120,
      'المراسلات': 15,
      'المديرين': 5,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('الإحصائيات'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'إحصائيات التطبيق',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // الرسم البياني الدائري
                  _buildPieChart(stats),
                  SizedBox(height: 20),
                  // قائمة الإحصائيات
                  ...stats.entries
                      .map((entry) => _buildStatItem(entry.key, entry.value))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // مكون الرسم البياني الدائري
  Widget _buildPieChart(Map<String, int> stats) {
    final total = stats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) {
      return Center(
        child: Text(
          'لا توجد بيانات لعرضها',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(200, 200),
            painter: PieChartPainter(stats, total),
          ),
          Text(
            'الإحصائيات',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // مكون عنصر الإحصائيات
  Widget _buildStatItem(String title, int value) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            value.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// الرسام المخصص للرسم البياني الدائري
class PieChartPainter extends CustomPainter {
  final Map<String, int> stats;
  final int total;

  PieChartPainter(this.stats, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -90; // الزاوية الابتدائية

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.teal,
    ];

    int index = 0;
    stats.forEach((key, value) {
      if (value == 0) return; // تخطي القيم الصفرية
      final sweepAngle = (value / total) * 360; // الزاوية الخاصة بالقسم
      paint.color = colors[index % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle * (3.14 / 180), // تحويل الزاوية إلى راديان
        sweepAngle * (3.14 / 180),
        true,
        paint,
      );
      startAngle += sweepAngle; // تحديث الزاوية الابتدائية للقسم التالي
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
