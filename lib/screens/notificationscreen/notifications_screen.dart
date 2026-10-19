import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wanzani/screens/Home/home_screen.dart';
import 'package:wanzani/screens/searchscreen/search_screen.dart';
import 'package:wanzani/screens/settingscreen/settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int selectedTabIndex = 0;
  int currentIndex = 2;
  final db = FirebaseDatabase.instance.ref();
  final currentUser = FirebaseAuth.instance.currentUser;

  final List<String> tabs = [
    "all".tr(),
    "unread".tr(),
    "likes".tr(),
    "comments".tr(),
  ];

  Stream<List<Map<String, dynamic>>> get notificationsStream {
    final uid = currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return db
        .child('notifications')
        .orderByChild('toUserId')
        .equalTo(uid)
        .onValue
        .map((e) {
      final map = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return map.entries.map((e2) {
        final m = Map<String, dynamic>.from(e2.value as Map);
        m['key'] = e2.key;
        return m;
      }).toList()
        ..sort(
            (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    });
  }

  void _navigateTo(int index) {
    setState(() => currentIndex = index);
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const SearchScreen();
        break;
      case 3:
        target = const SettingsScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  void _markAsRead(String key) {
    db.child('notifications/$key/unread').set(false);
  }

  Widget _buildAvatar(String? photoUrl) {
    ImageProvider avatar = const AssetImage('assets/avatar.png');
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        avatar = NetworkImage(photoUrl);
      } else if (File(photoUrl).existsSync()) {
        avatar = FileImage(File(photoUrl));
      }
    }
    return CircleAvatar(radius: 22, backgroundImage: avatar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "notifications".tr(),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateTo(1),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (c, i) {
                final isSelected = i == selectedTabIndex;
                return GestureDetector(
                  onTap: () => setState(() => selectedTabIndex = i),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          tabs[i],
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSelected)
                          Container(height: 3, width: 24, color: Colors.blue),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: notificationsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allNotifications = snapshot.data!;

                final filteredNotifications =
                    switch (tabs[selectedTabIndex].toLowerCase()) {
                  'likes' =>
                    allNotifications.where((n) => n['type'] == 'like').toList(),
                  'comments' => allNotifications
                      .where((n) => n['type'] == 'comment')
                      .toList(),
                  'unread' =>
                    allNotifications.where((n) => n['unread'] == true).toList(),
                  _ => allNotifications,
                };

                if (filteredNotifications.isEmpty) {
                  return Center(child: Text('no notifications'.tr()));
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, i) =>
                      _notificationTile(filteredNotifications[i]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildBottomNav() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            color: Colors.white,
          ),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: "home".tr(),
                isActive: currentIndex == 0,
                onTap: () => _navigateTo(0),
              ),
              _buildNavItem(
                icon: Icons.search,
                label: "search".tr(),
                isActive: currentIndex == 1,
                onTap: () => _navigateTo(1),
              ),
              const SizedBox(width: 60),
              Stack(
                children: [
                  _buildNavItem(
                    icon: Icons.notifications,
                    label: "alerts".tr(),
                    isActive: currentIndex == 2,
                    onTap: () => _navigateTo(2),
                  ),
                  Positioned(
                    right: 12,
                    top: 6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              _buildNavItem(
                icon: Icons.person,
                label: "profile".tr(),
                isActive: currentIndex == 3,
                onTap: () => _navigateTo(3),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.blue : Colors.grey;
    final isProfile = icon == Icons.person;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isProfile
                ? const CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  )
                : Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile(Map<String, dynamic> n) {
    final bool isUnread = n['unread'] == true;
    final String type = n['type'] as String? ?? '';
    final String action = type == 'like'
        ? 'liked your post'
        : type == 'comment'
            ? 'commented:'
            : n['action'] as String? ?? 'did something';

    final String name = n['fromUserName'] as String? ?? 'Someone';
    final String? avatarUrl = n['fromUserPhoto'] as String?;
    final String? commentText = n['commentText'] as String?;

    return InkWell(
      onTap: () {
        if (isUnread) {
          _markAsRead(n['key'] as String);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildAvatar(avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: ' $action',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  if (commentText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        commentText,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
