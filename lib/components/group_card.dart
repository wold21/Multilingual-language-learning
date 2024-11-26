import 'package:flutter/material.dart';
import '../models/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GroupCard({
    super.key,
    required this.group,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected
            ? theme.primaryColor.withOpacity(0.5)
            : null, // 선택 시 배경색 변경
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white, // 선택 시 텍스트 색상도 변경
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
