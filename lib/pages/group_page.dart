import 'package:eng_word_storage/pages/add_group_page.dart';
import 'package:eng_word_storage/pages/edit_group_page.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/database_service.dart';
import '../components/group_card.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Group> groups = [];
  Set<int> selectedGroupIds = {};

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final loadedGroups = await _databaseService.getAllGroups();
    setState(() {
      groups = loadedGroups;
    });
  }

  void _showBottomSheet(Group group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // 카드 배경색과 동일하게
      shape: const RoundedRectangleBorder(
        // 상단 모서리를 둥글게
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
              const SizedBox(height: 8), // 상단 여백 추가
              ListTile(
                leading: Icon(
                  Icons.edit_rounded,
                  color: primaryColor,
                ),
                title: const Text(
                  'Edit',
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
                  Icons.delete_rounded, // rounded 스타일 아이콘
                  color: primaryColor,
                ),
                title: const Text(
                  'Delete',
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
              const SizedBox(height: 8), // 하단 여백 추가
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditGroupDialog(Group group) async {
    final textController = TextEditingController(text: group.name);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter group name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  final updatedGroup = Group(
                    id: group.id,
                    name: textController.text,
                    createdAt: group.createdAt,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );
                  await _databaseService.updateGroup(updatedGroup);
                  _loadGroups();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
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
        title: const Text(
          'Select Group',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedGroupIds.toList());
            },
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupCard(
            group: group,
            isSelected: selectedGroupIds.contains(group.id),
            onTap: () {
              setState(() {
                if (selectedGroupIds.contains(group.id)) {
                  selectedGroupIds.remove(group.id);
                } else {
                  selectedGroupIds.add(group.id!);
                }
              });
            },
            onLongPress: () => _showBottomSheet(group),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Group>(
            context,
            MaterialPageRoute(builder: (context) => const AddGroupPage()),
          );

          if (result != null) {
            await _databaseService.createGroup(result);
            _loadGroups();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
