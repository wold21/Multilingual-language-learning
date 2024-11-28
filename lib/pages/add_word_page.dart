import 'package:eng_word_storage/pages/group_page.dart';
import 'package:eng_word_storage/pages/select_group_page.dart';
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
    _loadGroups().then((_) {
      if (widget.wordToEdit != null) {
        // 그룹 목록 로드 후 편집 모드 초기화
        _wordController.text = widget.wordToEdit!.word;
        _meaningController.text = widget.wordToEdit!.meaning;
        _memoController.text = widget.wordToEdit!.memo ?? '';
        _selectedGroup = groups.firstWhere(
          (group) => group.id == widget.wordToEdit!.groupId,
          orElse: () => Group(
            id: 2,
            name: 'Not specified',
            createdAt: 0,
            updatedAt: 0,
          ),
        );
        setState(() {}); // UI 업데이트
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
      final word = Word(
        id: widget.wordToEdit?.id, // 편집 모드일 때 기존 ID 유지
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        memo: _memoController.text.isEmpty ? null : _memoController.text.trim(),
        groupId: _selectedGroup?.id,
        language: 'en',
        createdAt: widget.wordToEdit?.createdAt ??
            DateTime.now().millisecondsSinceEpoch, // 편집 시 생성일 유지
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

        if (mounted) {
          ToastUtils.show(
            message: 'Updated',
            type: ToastType.success,
          );
        }

        // 수정 완료 후 이전 화면으로 돌아가기
        if (mounted) {
          Navigator.pop(context, true); // true를 반환하여 목록 새로고침 트리거
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
                      color: Colors.white,
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
                            color: Colors.white,
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
