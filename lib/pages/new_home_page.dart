import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'custom_drawer.dart'; // استيراد القائمة الجانبية

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  Box? adsBox;
  Box? achievementsBox;
  Box? newsBox;

  PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _sliderTimer;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    adsBox = await Hive.openBox('ads');
    achievementsBox = await Hive.openBox('achievements');
    newsBox = await Hive.openBox('news');

    setState(() {
      // بعد فتح الصناديق
    });

    // بدء مؤقت للسلايدر بعد فتح البيانات
    _startSliderTimer();
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      List<dynamic> sliderItems = _getSliderItems();
      if (sliderItems.isEmpty) return;

      if (currentPage < sliderItems.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  List<dynamic> _getSliderItems() {
    if (adsBox == null || achievementsBox == null || newsBox == null) return [];
    List<dynamic> ads = adsBox!.values.toList();
    List<dynamic> news = newsBox!.values.toList();

    List<dynamic> sliderItems = [];
    sliderItems.addAll(news.take(3));
    sliderItems.addAll(ads.take(3));
    return sliderItems;
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (adsBox == null || achievementsBox == null || newsBox == null) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    List<dynamic> ads = adsBox!.values.toList();
    List<dynamic> achievements = achievementsBox!.values.toList();
    List<dynamic> news = newsBox!.values.toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  _buildSlider(),
                  SizedBox(height: 10),
                  _buildLogoSection(context),
                  SizedBox(height: 10),
                  _buildSectionTitle(tr('latest_achievements')),
                  SizedBox(height: 10),
                  _buildGridSection(achievements, context, Colors.green[100]),
                  SizedBox(height: 10),
                  _buildSectionTitle(tr('latest_news')),
                  SizedBox(height: 10),
                  _buildGridSection(news, context, Colors.orange[100]),
                  SizedBox(height: 10),
                  _buildSectionTitle(tr('latest_ads')),
                  SizedBox(height: 10),
                  _buildGridSection(ads, context, Colors.purple[100]),
                  SizedBox(height: 20),
                  _buildSocialIconsRow(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget _buildSlider() {
    List<dynamic> sliderItems = _getSliderItems();
    if (sliderItems.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات لعرضها في السلايدر',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: sliderItems.length,
        itemBuilder: (context, index) {
          var item = sliderItems[index];
          String title = (item['title'] ?? 'غير متوفر').toString();
          String imageUrl = (item['image_url'] ?? '').toString();

          Widget imageWidget = _buildImageWidget(imageUrl, fit: BoxFit.cover);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageWidget,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.all(8),
                      child: Text(
                        title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    if (imageUrl.startsWith('http')) {
      return FadeInImage.assetNetwork(
        placeholder: 'assets/images/placeholder.png',
        image: imageUrl,
        fit: fit,
      );
    } else if (imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        fit: fit,
      );
    } else {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.image, color: Colors.grey, size: 50),
      );
    }
  }

  Widget _buildLogoSection(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: AspectRatio(
          aspectRatio: 1.7,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildGridSection(
      List<dynamic> items, BuildContext context, Color? bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: items.isNotEmpty
          ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                String title = (items[index]['title'] ?? '').toString();
                String description =
                    (items[index]['description'] ?? '').toString();
                String imageUrl = (items[index]['image_url'] ?? '').toString();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      print("تم الضغط على البطاقة: $title");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child:
                                _buildImageWidget(imageUrl, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title.isNotEmpty ? title : 'بدون عنوان',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              description.isNotEmpty ? description : 'بدون وصف',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'لا يوجد بيانات',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Widget _buildSocialIconsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(FontAwesomeIcons.whatsapp, Colors.green),
            SizedBox(width: 15),
            _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue),
            SizedBox(width: 15),
            _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pinkAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color bgColor) {
    return CircleAvatar(
      backgroundColor: bgColor,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 10),
                Text(
                  tr(' welcome '),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('news'),
            onTap: () {
              Navigator.pushNamed(context, '/news');
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text(tr('achievements')),
            onTap: () {
              Navigator.pushNamed(context, '/achievements');
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text(tr('team')),
            onTap: () {
              Navigator.pushNamed(context, '/team');
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text(tr('contact_us')),
            onTap: () {
              Navigator.pushNamed(context, '/contact_us');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(tr('about_us')),
            onTap: () {
              Navigator.pushNamed(context, '/about_us');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(tr('about_app')),
            onTap: () {
              Navigator.pushNamed(context, '/about_app');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(tr('settings')),
            onTap: () {
              Navigator.pushNamed(context, '/Login');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(tr('settings2')),
            onTap: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<Locale>(
              value: context.locale,
              items: [
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              ],
              onChanged: (locale) {
                if (locale != null) context.setLocale(locale);
              },
            ),
          ),
        ],
      ),
    );
  }
}
