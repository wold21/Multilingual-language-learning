import 'package:eng_word_storage/ads/banner_ad_widget.dart';
import 'package:eng_word_storage/components/confirm_dialog.dart';
import 'package:eng_word_storage/components/sheet/common_bottom_sheet.dart';
import 'package:eng_word_storage/pages/add_group_page.dart';
import 'package:eng_word_storage/pages/edit_group_page.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:eng_word_storage/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/group.dart';
import '../services/database_service.dart';
import '../components/group_card.dart';
import 'package:easy_localization/easy_localization.dart';

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
      selectedGroupIds = widget.selectedGroupIds.isEmpty == true
          ? []
          : List.from(widget.selectedGroupIds);
    } else {
      if (widget.selectedGroupIds.isNotEmpty) {
        selectedGroup = Group(
          id: widget.selectedGroupIds.first,
          name: '',
          createdAt: 0,
          updatedAt: 0,
        );
      }
    }
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final loadedGroups = await _databaseService.getAllGroups();
    setState(() {
      if (widget.mode == GroupSelectionMode.single) {
        groups = loadedGroups.where((group) => group.id! >= 2).toList();

        if (selectedGroup != null) {
          final actualGroup = groups.firstWhere(
            (g) => g.id == selectedGroup!.id,
            orElse: () => Group(
              id: 2,
              name: 'Not specified',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
          selectedGroup = actualGroup;
        }
      } else {
        // 다중 선택 모드: 모든 그룹 표시
        groups = loadedGroups;
      }
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
        selectedGroup = group;
      } else {
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
        title: Text(
          'mainPage.selectGroup.title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.mode == GroupSelectionMode.single) {
                if (selectedGroup != null) {
                  Navigator.pop(context, selectedGroup);
                } else {
                  ToastUtils.show(
                    message:
                        'mainPage.seelctGroup.errorMassage.groupSelect'.tr(),
                    type: ToastType.error,
                  );
                }
              } else {
                Navigator.pop(context, selectedGroupIds);
              }
            },
            child: Text(
              'common.button.done'.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        FutureBuilder<bool>(
          future: PurchaseService.instance.isAdRemoved(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            final initialAdRemoved = futureSnapshot.data ?? false;

            return StreamBuilder<bool>(
              stream: PurchaseService.instance.adsRemovedStream,
              initialData: initialAdRemoved,
              builder: (context, snapshot) {
                bool isAdRemoved = snapshot.data ?? false;
                return isAdRemoved
                    ? const SizedBox.shrink()
                    : BannerAdWidget(isAdRemoved: isAdRemoved);
              },
            );
          },
        ),
        Expanded(
          child: ListView.builder(
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
                onTap: () async {
                  await HapticFeedback.lightImpact();
                  _handleSelection(group);
                },
                onLongPress: () async {
                  await HapticFeedback.mediumImpact();
                  if (group.id != 1 && group.id != 2) {
                    _showBottomSheet(group);
                  }
                },
              );
            },
          ),
        )
      ]),
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
