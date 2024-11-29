import 'package:eng_word_storage/pages/group_page.dart';
import 'package:eng_word_storage/utils/content_language.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String FIRST_RUN_KEY = 'is_first_run';
  static const String _lastSelectedLanguageKey = 'last_selected_language';
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _memoController = TextEditingController();
  final _wordFocusNode = FocusNode();
  final DatabaseService _databaseService = DatabaseService.instance;
  ContentLanguage _selectedLanguage = ContentLanguage.enUS;

  List<Group> groups = [];
  bool _canSave = false;
  Word? _editedWord;

  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _updateSaveButton();
    _loadLastSelectedLanguage();
    _wordController.addListener(_updateSaveButton);
    _meaningController.addListener(_updateSaveButton);
    if (widget.wordToEdit != null) {
      _wordController.text = widget.wordToEdit!.word;
      _meaningController.text = widget.wordToEdit!.meaning;
      _memoController.text = widget.wordToEdit!.memo ?? '';
      _selectedLanguage = ContentLanguage.fromCode(widget.wordToEdit!.language);
      _selectedGroup = Group(
        id: widget.wordToEdit!.groupId,
        name: '',
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
          _selectedLanguage =
              ContentLanguage.fromCode(widget.wordToEdit!.language);
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

  Future<void> _loadLastSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLanguageCode = prefs.getString(_lastSelectedLanguageKey);
    if (lastLanguageCode != null) {
      setState(() {
        _selectedLanguage = ContentLanguage.fromCode(lastLanguageCode);
      });
    }
  }

  Future<void> _saveSelectedLanguage(ContentLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedLanguageKey, language.code);
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
        groupId = 2;
      }
      final word = Word(
        id: widget.wordToEdit?.id,
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        memo: _memoController.text.isEmpty ? null : _memoController.text.trim(),
        groupId: groupId,
        language: _selectedLanguage.code,
        createdAt: widget.wordToEdit?.createdAt ??
            DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      if (widget.wordToEdit == null) {
        await _databaseService.createWord(word);

        if (mounted) {
          ToastUtils.show(
            message: 'Saved',
            type: ToastType.success,
          );
        }

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

        FocusScope.of(context).requestFocus(FocusNode());
        FocusScope.of(context).requestFocus(_wordFocusNode);

        Navigator.pop(context, true);
      } else {
        await _databaseService.updateWord(word);
        _editedWord = word;

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
        centerTitle: true,
        title: const Text(
          'New Word',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => {
            if (widget.wordToEdit == null)
              {Navigator.pop(context, true)}
            else
              {Navigator.pop(context, _editedWord)}
          },
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
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Word',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.multiline,
                    enableIMEPersonalizedLearning: true,
                    enableSuggestions: true,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                    ),
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
                    keyboardType: TextInputType.multiline,
                    enableIMEPersonalizedLearning: true,
                    enableSuggestions: true,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                    ),
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
                    keyboardType: TextInputType.multiline,
                    enableIMEPersonalizedLearning: true,
                    enableSuggestions: true,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          onPressed: () async {
                            final selectedGroup = await Navigator.push<Group>(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const GroupPage(
                                  mode: GroupSelectionMode.single,
                                  selectedGroupIds: [],
                                ),
                              ),
                            );
                            if (selectedGroup != null) {
                              setState(() {
                                _selectedGroup = selectedGroup;
                              });
                            }
                          },
                          child: Text(
                            _selectedGroup?.name ?? 'Not specified',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                DropdownButton<ContentLanguage>(
                  value: _selectedLanguage,
                  underline: const SizedBox(),
                  alignment: AlignmentDirectional.centerEnd,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 25,
                  ),
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  items: ContentLanguage.values.map((language) {
                    return DropdownMenuItem<ContentLanguage>(
                      value: language,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${language.name}  ${language.flag}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (ContentLanguage? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    }
                    await _saveSelectedLanguage(newValue!);
                  },
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
