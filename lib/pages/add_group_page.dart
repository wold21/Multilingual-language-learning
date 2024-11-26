import 'package:flutter/material.dart';
import '../models/group.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _textController = TextEditingController();
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateSaveButton);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateSaveButton() {
    setState(() {
      _canSave = _textController.text.isNotEmpty;
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
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _canSave
                ? () {
                    final newGroup = Group(
                      name: _textController.text,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    );
                    Navigator.pop(context, newGroup);
                  }
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _canSave ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Group Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter group name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
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
