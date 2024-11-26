import 'package:flutter/material.dart';
import '../models/group.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage({
    super.key,
    required this.group,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  late final TextEditingController _textController;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.group.name);
    _textController.addListener(_updateSaveButton);
    _updateSaveButton();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateSaveButton() {
    setState(() {
      _canSave = _textController.text.isNotEmpty &&
          _textController.text != widget.group.name;
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
        title: const Text('Edit Group'),
        actions: [
          TextButton(
            onPressed: _canSave
                ? () {
                    final updatedGroup = Group(
                      id: widget.group.id,
                      name: _textController.text,
                      createdAt: widget.group.createdAt,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    );
                    Navigator.pop(context, updatedGroup);
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
