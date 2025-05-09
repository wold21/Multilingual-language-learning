import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

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

  Widget _buildTextField({
    required TextEditingController controller,
    bool autofocus = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoTextField(
        controller: controller,
        autofocus: autofocus,
        placeholder: 'mainPage.group.menu.subtitle.enterGroupName'.tr(),
        placeholderStyle: const TextStyle(color: Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        style: const TextStyle(fontSize: 16),
        maxLength: 20,
        autocorrect: false,
        enableSuggestions: false,
      );
    } else {
      return TextField(
        controller: controller,
        autofocus: autofocus,
        maxLength: 20, // 20글자 제한
        decoration: InputDecoration(
          hintText: 'mainPage.group.menu.subtitle.enterGroupName'.tr(),
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
        title: Text(
          'mainPage.group.menu.title.newGroup'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canSave
                ? () async {
                    Group? findGroup = await DatabaseService.instance
                        .findGroupByName(_textController.text);
                    if (findGroup == null) {
                      final newGroup = Group(
                        name: _textController.text,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );
                      Navigator.pop(context, newGroup);
                    } else {
                      ToastUtils.show(
                        message: 'common.toast.group.success.duplicated'.tr(),
                        type: ToastType.error,
                      );
                    }
                  }
                : null,
            child: Text(
              'common.button.done'.tr(),
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
                Text(
                  'mainPage.group.menu.subtitle.groupName'.tr(),
                  style: const TextStyle(
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
