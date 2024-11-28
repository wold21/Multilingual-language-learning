import 'package:eng_word_storage/components/confirm_dialog.dart';
import 'package:eng_word_storage/components/sheet/common_bottom_sheet.dart';
import 'package:eng_word_storage/pages/add_group_page.dart';
import 'package:eng_word_storage/pages/edit_group_page.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/database_service.dart';
import '../components/group_card.dart';

enum GroupSelectionMode {
  single,
  multiple,
}

class GroupPage extends StatefulWidget {
  final GroupSelectionMode mode;
  final List<int> selectedGroupIds;

  const GroupPage({
    super.key,
    this.mode = GroupSelectionMode.single,
    required this.selectedGroupIds,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Group> groups = [];
  Group? selectedGroup;
  List<int> selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.mode == GroupSelectionMode.multiple) {
      selectedGroupIds = widget.selectedGroupIds?.isEmpty == true
          ? []
          : List.from(widget.selectedGroupIds!);
    }
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
      backgroundColor: Colors.transparent,
      builder: (context) => CommonBottomSheet(
        title: group.name,
        onEdit: () async {
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
        onDelete: () => _showDeleteConfirmDialog(group),
      ),
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
                  ToastUtils.show(
                    message: 'updated',
                    type: ToastType.success,
                  );
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
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Group',
      content: 'Are you sure you want to delete this group?',
    );

    if (confirmed == true) {
      await _databaseService.deleteGroup(group.id!);

      setState(() {
        selectedGroupIds.remove(group.id);
      });

      ToastUtils.show(
        message: 'Deleted',
        type: ToastType.success,
      );

      _loadGroups();
    }
  }

  void _handleSelection(Group group) {
    setState(() {
      if (widget.mode == GroupSelectionMode.single) {
        // 단일 선택 모드
        if (selectedGroup?.id == group.id) {
          selectedGroup = null;
        } else {
          selectedGroup = group;
        }
      } else {
        // 다중 선택 모드
        if (group.name == 'All') {
          selectedGroupIds.clear();
        } else {
          if (selectedGroupIds.contains(group.id)) {
            selectedGroupIds.remove(group.id);
          } else {
            selectedGroupIds.add(group.id!);
          }
        }
      }
    });
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
              if (widget.mode == GroupSelectionMode.single) {
                Navigator.pop(context, selectedGroup);
              } else {
                Navigator.pop(context, selectedGroupIds);
              }
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
          final isSelected = widget.mode == GroupSelectionMode.single
              ? selectedGroup?.id == group.id
              : (group.name == 'All'
                  ? selectedGroupIds.isEmpty
                  : selectedGroupIds.contains(group.id));

          return GroupCard(
            group: group,
            isSelected: isSelected,
            onTap: () => _handleSelection(group),
            onLongPress:
                group.name != 'All' ? () => _showBottomSheet(group) : () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Group>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGroupPage(),
              fullscreenDialog: true,
            ),
          );

          if (result != null) {
            await _databaseService.createGroup(result);
            ToastUtils.show(
              message: 'Group created',
              type: ToastType.success,
            );
            _loadGroups();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
