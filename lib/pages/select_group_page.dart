import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/database_service.dart';
import '../components/group_card.dart';
import 'add_group_page.dart';
import 'edit_group_page.dart';

class SelectGroupPage extends StatefulWidget {
  const SelectGroupPage({super.key});

  @override
  State<SelectGroupPage> createState() => _SelectGroupPageState();
}

class _SelectGroupPageState extends State<SelectGroupPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Group> groups = [];
  Group? selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userGroups = await _databaseService.getUserGroups();
    setState(() {
      groups = userGroups; // getUserGroups()가 이미 필터링된 결과를 반환
    });
  }

  void _showBottomSheet(Group group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (context) {
        final primaryColor = Theme.of(context).primaryColor;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.edit_rounded,
                  color: primaryColor,
                ),
                title: const Text(
                  'Edit Group',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push<Group>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGroupPage(group: group),
                    ),
                  );

                  if (result != null) {
                    await _databaseService.updateGroup(result);
                    _loadGroups();
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_rounded,
                  color: primaryColor,
                ),
                title: const Text(
                  'Delete Group',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(group);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(Group group) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Delete Group',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _databaseService.deleteGroup(group.id!);
              _loadGroups();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Select Group'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedGroup); // 선택된 그룹 반환
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupCard(
            group: group,
            isSelected: selectedGroup?.id == group.id, // 현재 그룹이 선택되었는지 확인
            onTap: () {
              setState(() {
                // 이미 선택된 그룹을 다시 탭하면 선택 해제
                if (selectedGroup?.id == group.id) {
                  selectedGroup = null;
                } else {
                  selectedGroup = group; // 새로운 그룹 선택
                }
              });
            },
            onLongPress: () {
              _showBottomSheet(group);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 그룹 추가 버튼을 FAB로 변경
        onPressed: () async {
          final newGroup = await Navigator.push<Group>(
            // Group 타입으로 받기
            context,
            MaterialPageRoute(
              builder: (context) => const AddGroupPage(),
              fullscreenDialog: true, // 아래에서 위로 올라오는 애니메이션
            ),
          );

          if (newGroup != null) {
            await _databaseService.createGroup(newGroup); // 새 그룹 저장
            _loadGroups(); // 그룹 목록 새로고침
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
