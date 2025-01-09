import 'dart:io';

import 'package:eng_word_storage/ads/interstitial_ad_widget.dart';
import 'package:eng_word_storage/pages/group_page.dart';
import 'package:eng_word_storage/services/purchase_service.dart';
import 'package:eng_word_storage/utils/content_language.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  static const String _adWordCountKey = 'ad_word_count';
  static const int _adWordThreshold = 3;
  InterstitialAd? _interstitialAd;
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

        await _handleAdWordCount();

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

        final isFirstRun = await _checkFirstRun();

        if (isFirstRun && mounted) {
          Navigator.pop(context, true);
        }
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

  Future<void> _handleAdWordCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_adWordCountKey) ?? 0;
    currentCount++;
    if (currentCount >= _adWordThreshold) {
      await prefs.setInt(_adWordCountKey, 0);
      await _showInterstitialAd();
    } else {
      await prefs.setInt(_adWordCountKey, currentCount);
    }
  }

  Future<void> _showInterstitialAd() async {
    bool adLoaded = await InterstitialAdService().loadInterstitialAd();

    if (adLoaded) {
      InterstitialAdService().showInterstitialAd();
    } else {
      ToastUtils.show(
        message: 'Ad is not loaded yet.',
        type: ToastType.error,
      );
    }
  }

  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(FIRST_RUN_KEY) ?? true;
  }

  @override
  void dispose() {
    _wordFocusNode.dispose();
    _wordController.dispose();
    _meaningController.dispose();
    _memoController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool autofocus = false,
    required String hintText,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
  }) {
    if (Platform.isIOS) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 1, // 그림자 추가
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            // 테두리 추가
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          placeholder: hintText,
          placeholderStyle: const TextStyle(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          autocorrect: false,
          enableSuggestions: false,
        ),
      );
    } else {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 16),
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            enableIMEPersonalizedLearning: true,
            enableSuggestions: true,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.wordToEdit == null ? 'New Word' : 'Edit Word',
          style: const TextStyle(
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
                fontSize: 15,
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
              _buildTextField(
                controller: _wordController,
                focusNode: _wordFocusNode,
                autofocus: true,
                hintText: 'Word',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _meaningController,
                hintText: 'Meaning',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _memoController,
                hintText: 'Memo (optional)',
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
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
