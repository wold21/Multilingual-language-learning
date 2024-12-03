import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  Widget _buildTextField({
    required TextEditingController controller,
    bool autofocus = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoTextField(
        controller: controller,
        autofocus: autofocus,
        placeholder: 'Enter group name',
        placeholderStyle: const TextStyle(color: Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        style: const TextStyle(fontSize: 16),
        maxLength: 20, // 20글자 제한
        autocorrect: false,
        enableSuggestions: false,
      );
    } else {
      return TextField(
        controller: controller,
        autofocus: autofocus,
        maxLength: 20, // 20글자 제한
        decoration: const InputDecoration(
          hintText: 'Enter group name',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          counterText: '', // 글자 수 카운터 숨기기
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
      );
    }
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
          'Edit Group',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
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
                _buildTextField(
                  controller: _textController,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
