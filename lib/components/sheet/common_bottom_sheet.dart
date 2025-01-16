import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum ActionType {
  word,
  group,
}

class CommonBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: primaryColor,
              ),
              title: Text(
                'common.button.edit'.tr(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: primaryColor,
              ),
              title: Text(
                'common.button.delete'.tr(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
