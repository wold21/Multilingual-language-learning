import 'dart:io';

import 'package:eng_word_storage/models/group.dart';
import 'package:eng_word_storage/models/word.dart';
import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataBackupService {
  static final DataBackupService instance = DataBackupService._internal();
  DataBackupService._internal();

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> exportData() async {
    try {
      final words = await DatabaseService.instance.getAllWords();
      final groups = await DatabaseService.instance.getAllGroups();

      // CSV 형식으로 변환 (필수 필드만)
      final StringBuffer csv = StringBuffer();
      csv.writeln('단어,의미,그룹'); // 헤더 간소화

      for (final word in words) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final group = groups.firstWhere(
          (g) => g.id == word.groupId,
          orElse: () => Group(
            name: '미분류',
            createdAt: now,
            updatedAt: now,
          ),
        );

        // CSV 형식으로 데이터 작성 (필수 필드만)
        csv.writeln(
            '${_escapeCsv(word.word)},${_escapeCsv(word.meaning)},${_escapeCsv(group.name)}');
      }

      // 파일 저장 및 공유
      final now = DateTime.now();
      final fileName = '단어장_${now.year}${now.month}${now.day}.csv';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv.toString());

      // 공유하기
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Export Vocabulary',
      );

      if (result.status == ShareResultStatus.success) {
        ToastUtils.show(
          message: '${words.length} words exported',
          type: ToastType.success,
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        ToastUtils.show(
          message: 'Export cancelled',
          type: ToastType.info,
        );
      }
    } catch (e) {
      ToastUtils.show(
        message: 'Failed to export data: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  Future<void> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Import Vocabulary',
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final lines = await file.readAsLines();

      if (lines.isEmpty || lines.length == 1) {
        throw Exception('No data to import');
      }

      // 첫 줄은 헤더이므로 제외
      final dataLines = lines.skip(1);
      int importCount = 0;

      for (final line in dataLines) {
        final parts = line.split(',');
        if (parts.length >= 3) {
          // 단어, 의미, 그룹 필수
          final word = parts[0].trim();
          final meaning = parts[1].trim();
          final groupName = parts[2].trim();

          // 그룹 찾기 또는 생성
          var group = await DatabaseService.instance.findGroupByName(groupName);
          if (group == null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            group = await DatabaseService.instance.createGroup(
              Group(
                name: groupName,
                createdAt: now,
                updatedAt: now,
              ),
            );
          }

          // 단어 추가
          final now = DateTime.now().millisecondsSinceEpoch;
          await DatabaseService.instance.createWord(
            Word(
              word: word,
              meaning: meaning,
              groupId: group.id!,
              createdAt: now,
              updatedAt: now,
            ),
          );
          importCount++;
        }
      }

      ToastUtils.show(
        message: '$importCount words imported',
        type: ToastType.success,
      );
    } catch (e) {
      ToastUtils.show(
        message: 'Failed to import data: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}
