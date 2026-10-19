import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentScreen extends StatefulWidget {
  final String postKey;
  final String postOwnerId;

  const CommentScreen(
      {super.key, required this.postKey, required this.postOwnerId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final db = FirebaseDatabase.instance.ref();
  final _controller = TextEditingController();

  Stream<List<Map<String, dynamic>>> get _commentsStream {
    return db.child('postComments/${widget.postKey}').onValue.map((e) {
      final mp = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return mp.entries.map((ent) {
        final d = Map<String, dynamic>.from(ent.value as Map);
        d['key'] = ent.key;
        return d;
      }).toList()
        ..sort(
            (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
    });
  }

  Future<void> _postComment(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final now = DateTime.now().millisecondsSinceEpoch;

    final profile = await _fetchUserProfile(uid);
    final name = profile['name'] ?? user.displayName ?? 'Someone';
    final photo = profile['photo'] ?? user.photoURL;

    await _saveComment(uid, name, photo, trimmed, now);
    await _incrementCommentCount();

    if (widget.postOwnerId != uid) {
      await _sendCommentNotification(uid, name, photo, trimmed, now);
    }

    _controller.clear();
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String uid) async {
    final snap = await db.child('users/$uid/profile').get();
    return snap.exists ? Map<String, dynamic>.from(snap.value as Map) : {};
  }

  Future<void> _saveComment(
      String uid, String name, String? photo, String text, int now) async {
    await db.child('postComments/${widget.postKey}').push().set({
      'fromUserId': uid,
      'fromUserName': name,
      'fromUserPhoto': photo,
      'text': text,
      'timestamp': now,
    });
  }

  Future<void> _incrementCommentCount() async {
    await db
        .child('posts/${widget.postKey}/commentCount')
        .runTransaction((current) {
      int count = 0;
      if (current is int)
        count = current;
      else if (current is String) count = int.tryParse(current) ?? 0;
      return Transaction.success(count + 1);
    });
  }

  Future<void> _sendCommentNotification(
      String uid, String name, String? photo, String text, int now) async {
    await db.child('notifications').push().set({
      'type': 'comment',
      'fromUserId': uid,
      'fromUserName': name,
      'fromUserPhoto': photo,
      'toUserId': widget.postOwnerId,
      'postId': widget.postKey,
      'commentText': text,
      'timestamp': now,
      'unread': true,
    });
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
    return CircleAvatar(backgroundImage: avatar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _commentsStream,
              builder: (c, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final list = snap.data!;
                if (list.isEmpty)
                  return const Center(child: Text('No comments yet'));

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final cm = list[i];
                    return ListTile(
                      leading: _buildAvatar(cm['fromUserPhoto'] as String?),
                      title: Text(cm['fromUserName'] ?? 'Someone'),
                      subtitle: Text(cm['text'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Write a comment...'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color:
                      _controller.text.trim().isNotEmpty ? Colors.blue : null,
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () async {
                          await _postComment(_controller.text);
                          FocusScope.of(context).unfocus();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
