import 'dart:math';

import 'package:eng_word_storage/components/confirm_dialog.dart';
import 'package:eng_word_storage/components/guide/intro_dialog.dart';
import 'package:eng_word_storage/components/guide/outro_dialog.dart';
import 'package:eng_word_storage/components/indicator/indicator.dart';
import 'package:eng_word_storage/components/sheet/common_bottom_sheet.dart';
import 'package:eng_word_storage/components/sheet/search_sheet.dart';
import 'package:eng_word_storage/components/word_card.dart';
import 'package:eng_word_storage/pages/add_word_page.dart';
import 'package:eng_word_storage/pages/group_page.dart';
import 'package:eng_word_storage/pages/sort_page.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:eng_word_storage/utils/word_generator.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/word.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const String SORT_KEY = 'current_sort';
  static const String GROUP_IDS_KEY = 'selected_group_ids';
  static const String FIRST_RUN_KEY = 'is_first_run';

  final List<String> emptyMessages = [
    'Woof! Let\'s add some words! 🐾',
    'Your word list is empty... Ruff! 🐕',
    'Bark bark! Time to learn new words! 🐶',
  ];

  final DatabaseService _databaseService = DatabaseService.instance;
  final ScrollController _scrollController = ScrollController();
  List<Word> words = [];

  /// 검색 관련 ///
  // 정렬 기준
  late SortType currentSort;
  List<int> selectedGroupIds = [];

  bool isLoading = false;
  int offset = 0;
  static const int limit = 300;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _scrollController.addListener(_scrollListener);
    _initializeApp();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadWords();
    }
  }

  String getRandomEmptyMessage() {
    final random = Random();
    return emptyMessages[random.nextInt(emptyMessages.length)];
  }

  void _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool(FIRST_RUN_KEY) ?? true;

    if (!mounted) return;

    if (isFirstRun) {
      final needsRefresh = await Navigator.of(context).push<bool>(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) => const IntroGuide(),
        ),
      );

      if (needsRefresh == true) {
        setState(() {
          words.clear();
          offset = 0;
        });
        _loadWords();
      }
    } else {
      _loadWords();
    }
  }

  Future<void> _initializePreferences() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 정렬 조건 불러오기
      currentSort = SortType.createdDesc;
      final savedSortIndex = prefs.getInt(SORT_KEY);
      if (savedSortIndex != null && savedSortIndex < SortType.values.length) {
        currentSort = SortType.values[savedSortIndex];
      }

      // 선택된 그룹 ID들 불러오기
      final savedGroupIds = prefs.getStringList(GROUP_IDS_KEY);
      if (savedGroupIds != null) {
        selectedGroupIds = savedGroupIds
            .map((e) => int.tryParse(e))
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
      }

      setState(() {});
    } catch (e) {
      ToastUtils.show(
        message: 'Error loading preferences',
        type: ToastType.error,
      );
    }
  }

  // 정렬 조건 저장
  Future<void> _saveSortPreference(SortType sort) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(SORT_KEY, sort.index);
    } catch (e) {
      ToastUtils.show(
        message: 'Error saving sort preference',
        type: ToastType.error,
      );
    }
  }

  // 선택된 그룹 ID들 저장
  Future<void> _saveGroupIdsPreference(List<int> groupIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        GROUP_IDS_KEY,
        groupIds.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      ToastUtils.show(
        message: 'Error saving group IDs',
        type: ToastType.error,
      );
    }
  }

  Future<void> _loadWords() async {
    if (isLoading) return;
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final loadedWords = await _databaseService.getAllWords(
        limit: limit,
        offset: offset,
        orderBy: currentSort.query,
        groupIds: selectedGroupIds.isEmpty ? null : selectedGroupIds,
        query: searchQuery,
      );

      setState(() {
        if (offset == 0) {
          words = loadedWords;
        } else {
          words.addAll(loadedWords);
        }
        offset += loadedWords.length;
      });

      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool(FIRST_RUN_KEY) ?? true;

      // 조건을 더 명확하게 체크
      if (isFirstRun && mounted) {
        // 약간의 딜레이를 주어 화면 전환이 완료된 후 표시
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => const OutroGuide(),
              ),
            );
          }
        });
      }
    } catch (e) {
      ToastUtils.show(
        message: 'Error loading words',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dog.png',
                width: 45,
                height: 45,
              ),
              const Text(
                ' Laboca',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 15, top: 10),
          //   child: Text(
          //     '${words.length} words', // 단어 수 표시
          //     style: TextStyle(
          //       fontSize: 14,
          //       color: Theme.of(context).textTheme.bodyMedium?.color,
          //     ),
          //   ),
          // ),
        ]),
        toolbarHeight: 80,
        scrolledUnderElevation: 0, // 스크롤 시 그림자 효과 제거
        elevation: 0,
        actions: [
          if (kDebugMode) ...[
            IconButton(
              icon: const Icon(Icons.folder_delete_rounded),
              onPressed: () async {
                ToastUtils.show(
                  message: 'Delete All Words',
                  type: ToastType.info,
                );

                await _databaseService.deleteAllWords();

                ToastUtils.show(
                  message: 'Complated!',
                  type: ToastType.success,
                );

                setState(() {
                  words.clear();
                  offset = 0;
                });
                _loadWords();
              },
            ),
            IconButton(
              icon: const Icon(Icons.bug_report_rounded),
              onPressed: () async {
                ToastUtils.show(
                  message: 'Generating dummy data...',
                  type: ToastType.info,
                );

                await WordGenerator.generateDummyData(DatabaseService.instance);

                ToastUtils.show(
                  message: 'Dummy data generated!',
                  type: ToastType.success,
                );

                setState(() {
                  words.clear();
                  offset = 0;
                });
                _loadWords();
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.sort, size: 28), // 정렬 아이콘
            onPressed: () async {
              final result = await Navigator.push<SortType>(
                context,
                MaterialPageRoute(
                  builder: (context) => SortPage(
                    currentSort: currentSort, // 현재 정렬 조건 전달
                  ),
                ),
              );

              if (result != null && result != currentSort) {
                setState(() {
                  currentSort = result;
                  words.clear();
                  offset = 0;
                });
                await _saveSortPreference(result);
                _loadWords(); // 새로운 정렬 조건으로 데이터 다시 로드
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined, size: 28),
            onPressed: () async {
              final selectedIds = await Navigator.push<List<int>>(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupPage(
                    mode: GroupSelectionMode.multiple,
                    selectedGroupIds: selectedGroupIds,
                  ),
                ),
              );

              if (selectedIds != null) {
                setState(() {
                  selectedGroupIds = selectedIds;
                  words.clear();
                  offset = 0;
                });
                await _saveGroupIdsPreference(selectedIds);
                _loadWords();
              }
            },
          ),
          IconButton(
            icon: Icon(
                searchQuery?.isNotEmpty == true
                    ? Icons.search_off_rounded
                    : Icons.search,
                size: 28),
            onPressed: () async {
              if (searchQuery?.isNotEmpty == true) {
                setState(() {
                  searchQuery = null;
                  words.clear();
                  offset = 0;
                });
                _loadWords();
              } else {
                final result = await showGeneralDialog<Map<String, dynamic>>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: '',
                  barrierColor: Colors.black.withOpacity(0.3),
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation1, animation2) => Container(),
                  transitionBuilder: (context, animation1, animation2, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -1),
                              end: Offset.zero,
                            ).animate(animation1),
                            child: SearchSheet(
                              selectedGroupIds: selectedGroupIds,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (result != null) {
                  setState(() {
                    searchQuery = result['query'] as String;
                    if (result['searchInAllGroups'] as bool) {
                      selectedGroupIds.clear();
                    }
                    words.clear();
                    offset = 0;
                  });
                  await _loadWords();
                }
              }
            },
          ),
        ],
      ),
      body: words.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.paw,
                      size: 35,
                      color: Color.fromARGB(255, 234, 161, 72),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      getRandomEmptyMessage(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: words.length + 1,
              itemBuilder: (context, index) {
                if (index == words.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: isLoading
                          ? const BouncingDotsIndicator()
                          : const SizedBox(),
                    ),
                  );
                }
                return _buildWordCard(words[index]);
              },
            ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          onPressed: () async {
            await HapticFeedback.mediumImpact();
            final needsRefresh = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const AddWordPage(),
                fullscreenDialog: true,
              ),
            );

            if (needsRefresh == true) {
              setState(() {
                words.clear();
                offset = 0;
              });
              _loadWords();
            }
          },
          child: const FaIcon(
            FontAwesomeIcons.paw,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWordCard(Word word) {
    return GestureDetector(
      onLongPress: () async {
        await HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => CommonBottomSheet(
            title: word.word,
            onEdit: () async {
              final updatedWord = await Navigator.push<Word>(
                // bool 대신 Word를 반환받음
                context,
                MaterialPageRoute(
                  builder: (context) => AddWordPage(wordToEdit: word),
                  fullscreenDialog: true,
                ),
              );
              if (updatedWord != null) {
                setState(() {
                  final index = words.indexWhere((w) => w.id == updatedWord.id);
                  if (index != -1) {
                    words[index] = updatedWord;
                  }
                });
                setState(() {
                  words.clear();
                  offset = 0;
                });
                _loadWords();
              }
            },
            onDelete: () => _showDeleteConfirmDialog(word),
          ),
        );
      },
      child: WordCard(word: word),
    );
  }

  Future<void> _showDeleteConfirmDialog(Word word) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Word',
      content: 'Are you sure you want to delete this word?',
    );

    if (confirmed == true) {
      await _databaseService.deleteWord(word.id!);
      ToastUtils.show(
        message: 'Word deleted',
        type: ToastType.success,
      );
      setState(() {
        words.clear();
        offset = 0;
      });
      _loadWords();
    }
  }
}
