import 'dart:math';

import 'package:eng_word_storage/models/word.dart';
import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';

class WordGenerator {
  static final _random = Random();

  // 영어 단어스러운 문자열 생성을 위한 음절
  static const _syllables = [
    'al',
    'an',
    'ar',
    'as',
    'at',
    'ea',
    'ed',
    'en',
    'er',
    'es',
    'ha',
    'he',
    'hi',
    'in',
    'is',
    'it',
    'le',
    'me',
    'nd',
    'ne',
    'ng',
    'nt',
    'on',
    'or',
    're',
    'se',
    'st',
    'te',
    'th',
    'ti',
    'to',
    've',
    'wa',
  ];

  // 한글 의미처럼 보이게 하기 위한 음절
  static const _koreanSyllables = [
    '가',
    '나',
    '다',
    '라',
    '마',
    '바',
    '사',
    '아',
    '자',
    '차',
    '카',
    '타',
    '파',
    '하',
    '기',
    '니',
    '디',
    '리',
    '미',
    '비',
    '시',
    '이',
    '지',
    '치',
    '키',
    '티',
    '피',
    '히',
  ];

  static String _generateWord() {
    final syllableCount = _random.nextInt(2) + 2; // 2-3음절
    final syllables = List.generate(
      syllableCount,
      (_) => _syllables[_random.nextInt(_syllables.length)],
    );
    return syllables.join('');
  }

  static String _generateMeaning() {
    final syllableCount = _random.nextInt(3) + 2; // 2-4음절
    final syllables = List.generate(
      syllableCount,
      (_) => _koreanSyllables[_random.nextInt(_koreanSyllables.length)],
    );
    return syllables.join('');
  }

  static Future<void> generateDummyData(DatabaseService db) async {
    final groups = await db.getAllGroups();
    final userGroups = groups.where((group) => group.id! >= 2).toList();

    if (userGroups.isEmpty) {
      ToastUtils.show(
        message: 'Please create a group first.',
        type: ToastType.error,
      );
      return;
    }

    final now = DateTime.now();

    try {
      for (int i = 0; i < 1000; i++) {
        final word = Word(
          word: _generateWord(),
          meaning: _generateMeaning(),
          memo: _random.nextBool() ? '메모 #$i' : null,
          groupId: userGroups[_random.nextInt(userGroups.length)].id!,
          language: 'en',
          createdAt: now
              .subtract(Duration(days: _random.nextInt(30)))
              .millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        );

        await db.createWord(word);

        // 진행상황 출력 (선택사항)
        if (i % 100 == 0) {
          ToastUtils.show(
            message: 'Generated ${i + 1} words',
            type: ToastType.info,
          );
        }
      }

      ToastUtils.show(
        message: 'Completed generating 1000 dummy words',
        type: ToastType.success,
      );
    } catch (e) {
      ToastUtils.show(
        message: 'Error generating dummy data: $e',
        type: ToastType.error,
      );
    }
  }
}
