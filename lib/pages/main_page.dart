import 'package:eng_word_storage/components/word_card.dart';
import 'package:eng_word_storage/pages/add_word_page.dart';
import 'package:eng_word_storage/pages/group_page.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/word.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ScrollController _scrollController = ScrollController();
  List<Word> words = [];
  bool isLoading = false;
  int offset = 0;
  static const int limit = 300;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _scrollController.addListener(_scrollListener);
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

  Future<void> _loadWords() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final loadedWords = await _databaseService.getAllWords(
        limit: limit,
        offset: offset,
      );

      setState(() {
        words.addAll(loadedWords); // 기존 목록에 새로운 단어들 추가
        offset += loadedWords.length; // 다음 페이지를 위해 offset 증가
      });
    } catch (e) {
      print('Error loading words: $e');
      // TODO: 에러 처리 (예: 스낵바 표시)
    } finally {
      setState(() {
        isLoading = false;
      });
      for (var word in words) {
        print(
            '단어: ${word.word}, 그룹 ID: ${word.groupId}, 그룹명: ${word.groupName}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voca Storage',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${words.length} words', // 단어 수 표시
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        scrolledUnderElevation: 0, // 스크롤 시 그림자 효과 제거
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: words.length + 1,
        itemBuilder: (context, index) {
          if (index == words.length) {
            return _buildLoadingIndicator();
          }
          return _buildWordCard(words[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Word>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWordPage(),
              fullscreenDialog: true, // 아래에서 위로 올라오는 애니메이션
            ),
          );

          if (result != null) {
            await _databaseService.createWord(result);
            setState(() {
              words.clear(); // 기존 목록 초기화
              offset = 0; // offset 초기화
            });
            _loadWords(); // 처음부터 다시 로드
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    return WordCard(word: word);
  }
}
