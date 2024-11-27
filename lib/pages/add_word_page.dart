import 'package:eng_word_storage/pages/main_page.dart';
import 'package:eng_word_storage/pages/select_group_page.dart';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/group.dart';
import '../services/database_service.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _memoController = TextEditingController();
  final _wordFocusNode = FocusNode();
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Group> groups = [];
  bool _canSave = false;

  Group? _selectedGroup = Group(
    id: 2,
    name: 'Not specified',
    createdAt: 0,
    updatedAt: 0,
  );

  @override
  void initState() {
    super.initState();
    _updateSaveButton();
    _wordController.addListener(_updateSaveButton);
    _meaningController.addListener(_updateSaveButton);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userGroups = await _databaseService.getUserGroups();
    setState(() {
      groups = userGroups;
    });
  }

  void _updateSaveButton() {
    setState(() {
      _canSave =
          _wordController.text.isNotEmpty && _meaningController.text.isNotEmpty;
    });
  }

  Future<void> _saveWord() async {
    if (_canSave) {
      final word = Word(
        word: _wordController.text,
        meaning: _meaningController.text,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        groupId: _selectedGroup?.id,
        language: 'en',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // 단어 저장
      await _databaseService.createWord(word);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          // 새로운 페이지로 교체
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }

      // 입력 필드 초기화
      setState(() {
        _wordController.clear();
        _meaningController.clear();
        _memoController.clear();
        _selectedGroup = Group(
          id: 2,
          name: 'Not specified',
          createdAt: 0,
          updatedAt: 0,
        ); // 그룹을 Not specified로 초기화
      });

      // 키보드 포커스를 단어 입력 필드로 이동
      FocusScope.of(context).requestFocus(
        FocusNode(),
      );
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).requestFocus(_wordFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _wordFocusNode.dispose();
    _wordController.dispose();
    _meaningController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _canSave
                ? () {
                    _saveWord();
                  }
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: _canSave ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 0.0),
                  child: TextField(
                    controller: _wordController,
                    focusNode: _wordFocusNode,
                    autofocus: true, // 자동 포커스 설정
                    decoration: const InputDecoration(
                      hintText: 'Word',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 0.0),
                  child: TextField(
                    controller: _meaningController,
                    decoration: const InputDecoration(
                      hintText: 'Meaning',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 0.0),
                  child: TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(
                      hintText: 'Memo (optional)',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.done,
                    maxLines: null, // 여러 줄 입력 가능
                  ),
                ),
              ),
              const SizedBox(height: 24), // 간격 좀 더 늘림
              Row(
                children: [
                  const Text(
                    'Select Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedGroup?.name ?? 'Not specified',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final selectedGroup = await Navigator.push<Group>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectGroupPage(),
                        ),
                      );
                      if (selectedGroup != null) {
                        setState(() {
                          _selectedGroup = selectedGroup;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
