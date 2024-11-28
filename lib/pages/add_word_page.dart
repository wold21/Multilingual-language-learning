import 'package:eng_word_storage/pages/group_page.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/group.dart';
import '../services/database_service.dart';

class AddWordPage extends StatefulWidget {
  final Word? wordToEdit;
  const AddWordPage({super.key, this.wordToEdit});

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
    if (widget.wordToEdit != null) {
      // 그룹 목록 로드 후 편집 모드 초기화
      _wordController.text = widget.wordToEdit!.word;
      _meaningController.text = widget.wordToEdit!.meaning;
      _memoController.text = widget.wordToEdit!.memo ?? '';
      _selectedGroup = Group(
        id: widget.wordToEdit!.groupId,
        name: '', // 임시로 빈 이름 설정
        createdAt: 0,
        updatedAt: 0,
      );
    }
    _loadGroups().then((_) {
      if (widget.wordToEdit != null) {
        setState(() {
          _selectedGroup = groups.firstWhere(
            (group) => group.id == widget.wordToEdit!.groupId,
            orElse: () => Group(
              id: 2,
              name: 'Not specified',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
        });
      }
    });
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
      final int groupId;
      if (_selectedGroup?.id != null) {
        groupId = _selectedGroup!.id!;
      } else if (widget.wordToEdit?.groupId != null) {
        groupId = widget.wordToEdit!.groupId;
      } else {
        groupId = 2; // Not specified 그룹
      }
      final word = Word(
        id: widget.wordToEdit?.id,
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        memo: _memoController.text.isEmpty ? null : _memoController.text.trim(),
        groupId: groupId,
        language: 'en',
        createdAt: widget.wordToEdit?.createdAt ??
            DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      if (widget.wordToEdit == null) {
        // 새 단어 추가
        await _databaseService.createWord(word);

        if (mounted) {
          ToastUtils.show(
            message: 'Saved',
            type: ToastType.success,
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
          );
        });

        // 키보드 포커스 재설정
        FocusScope.of(context).requestFocus(FocusNode());
        Future.delayed(const Duration(milliseconds: 50), () {
          FocusScope.of(context).requestFocus(_wordFocusNode);
        });
      } else {
        // 기존 단어 수정
        await _databaseService.updateWord(word);
        print('Updated word groupId: ${word.groupId}');

        if (mounted) {
          ToastUtils.show(
            message: 'Updated',
            type: ToastType.success,
          );
        }

        if (mounted) {
          Navigator.pop(context, word);
        }
      }
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
          onPressed: () => Navigator.pop(context, true),
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
                fontSize: 17,
                fontWeight: FontWeight.bold,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 추가
                children: [
                  const Text(
                    'Group',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      // 그룹명과 화살표를 묶어주는 Row 추가
                      mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                      children: [
                        Text(
                          _selectedGroup?.name ?? 'Not specified',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onPressed: () async {
                            final selectedGroup = await Navigator.push<Group>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GroupPage(
                                    mode: GroupSelectionMode.single,
                                    selectedGroupIds: []),
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
