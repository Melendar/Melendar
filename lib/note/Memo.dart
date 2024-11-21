import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MemoEditScreen.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Memo(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
// const IconData note_add = IconData(0xe44a, fontFamily: 'MaterialIcons');

class Memo extends StatefulWidget {
  const Memo({Key? key}) : super(key: key);

  @override
  _MemoState createState() => _MemoState();
}

class _MemoState extends State<Memo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  /// FirebaseAuth에서 로그인한 사용자 ID를 가져오는 함수
  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      print("로그인되지 않은 사용자입니다.");
    }
  }

  /// Firestore에서 메모 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> fetchMemosByUserId(String userId) async {
    if (userId.isEmpty) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Memos')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final date =
        timestamp != null ? timestamp.toDate().toString() : 'No Date';

        return {
          'memoId': doc.id,
          'title': data['title'] ?? '제목 없음',
          'content': data['content'] ?? '내용 없음',
          'date': date,
        };
      }).toList();
    } catch (e) {
      print('Error fetching memos: $e');
      return [];
    }
  }

  void _showAction(BuildContext context, String action) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(action),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 정보가 없으면 로딩 화면 표시
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 관리'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMemosByUserId(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                '저장된 메모가 없습니다!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final memos = snapshot.data!;

          return ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              final memoId = memo['memoId'];
              final title = memo['title'];
              final content = memo['content'];
              final date = memo['date'];

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.black45),
                    onPressed: () async {
                      await _firestore
                          .collection('Users')
                          .doc(_userId)
                          .collection('Memos')
                          .doc(memoId)
                          .delete();
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoEditScreen(userId: _userId!),
                ),
              );
              if (result == true) {
                // 새로 고침 트리거
                setState(() {});
              }
            },
            icon: const Icon(Icons.note_add),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 'Edit memo'),
            icon: const Icon(Icons.check_circle_outline_sharp),
          ),
        ],
      ),
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.distance,
    required this.children,
  });

  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 60.0 / (count - 1);
    for (var i = 0, angleInDegrees = 15.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.edit_note_rounded),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}
