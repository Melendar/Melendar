import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/memo_service.dart';
import 'MemoEditScreen.dart';


class Memo extends StatefulWidget {
  const Memo({Key? key}) : super(key: key);

  @override
  _MemoState createState() => _MemoState();
}
class _MemoState extends State<Memo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  bool _isSelectionMode = false;
  final Set<String> _selectedMemos = {};
  String _searchQuery = ''; // 검색어 저장
  bool _isSearching = false; // 검색 활성화 상태

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedMemos.clear();
    });
  }

  void _onMemoSelected(String memoId, bool selected) {
    setState(() {
      if (selected) {
        _selectedMemos.add(memoId);
      } else {
        _selectedMemos.remove(memoId);
      }
    });
  }

  /// 검색창 생성
  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: '메모 검색',
        border: InputBorder.none,
      ),
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }

  /// AppBar의 액션 변경
  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _isSearching = false;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        if (_isSelectionMode)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedMemos.isEmpty
                ? null
                : () async {
              for (var memoId in _selectedMemos) {
                await _firestore
                    .collection('Users')
                    .doc(_userId)
                    .collection('Memos')
                    .doc(memoId)
                    .delete();
              }
              _toggleSelectionMode();
            },
          ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('메모 관리'),
        actions: _buildActions(),
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

          // 검색 적용
          final memos = snapshot.data!
              .where((memo) => memo['title']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
              memo['content']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              final memoId = memo['memoId'];
              final title = memo['title'];
              final content = memo['content'];
              final date = memo['date'];
              final isSelected = _selectedMemos.contains(memoId);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: _isSelectionMode
                      ? Checkbox(
                    value: isSelected,
                    onChanged: (selected) =>
                        _onMemoSelected(memoId, selected ?? false),
                  )
                      : null,
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
                  onTap: () async {
                    if (_isSelectionMode) {
                      _onMemoSelected(memoId, !isSelected);
                    } else {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemoEditScreen(
                            userId: _userId!,
                            memoId: memoId,
                            initialTitle: title,
                            initialContent: content,
                          ),
                        ),
                      );
                      if (result == true) {
                        setState(() {});
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ExpandableFab(
        distance: 100,
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
                setState(() {});
              }
            },
            icon: const Icon(Icons.edit),
          ),
          ActionButton(
            onPressed: _toggleSelectionMode,
            icon: Icon(_isSelectionMode ? Icons.close : Icons.check_circle_outline_sharp),
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
// 펼쳐지는 두 아이콘의 각도 조절 가능
  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
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
          _open ? 0.5 : 1.0,
          _open ? 0.5 : 1.0,
          1.0,
        ), //아이콘 애니메이션

        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutQuad),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOutQuad),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: Colors.white, // 버튼 배경 색상
            foregroundColor: Colors.black, // 아이콘 색상
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
