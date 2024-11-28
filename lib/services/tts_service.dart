import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  Future<void> init() async {
    await _printAvailableVoices();
  }

  Future<void> _printAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      final languages = await _tts.getLanguages;
      print('Voices: $voices');
      print('Languages: $languages');
    } catch (e) {}
  }

  Future<void> _setVoiceForLanguage(String languageCode) async {
    try {
      switch (languageCode) {
        case 'en':
          // 미국 영어
          await _tts.setLanguage('en-US');
          break;
        case 'gb':
          // 영국 영어 (실제 존재하는 음성 사용)
          await _tts.setLanguage('en-GB');
          await _tts.setVoice({"name": "en-gb-x-gba-local", "locale": "en-GB"});
          break;
        case 'ja':
          // 일본어
          await _tts.setLanguage('ja-JP');
          await _tts.setVoice(
              {"name": "ja-jp-x-htm#female_2-local", "locale": "ja-JP"});
          break;
        case 'zh':
          // 중국어
          await _tts.setLanguage('zh-CN');
          break;
        case 'ko':
          // 한국어
          await _tts.setLanguage('ko-KR');
          await _tts.setVoice(
              {"name": "ko-kr-x-ism#male_2-local", "locale": "ko-KR"});
          break;
        case 'ph':
          // 필리핀어
          await _tts.setLanguage('fil-PH');
          break;
        default:
          await _tts.setLanguage('en-US');
      }
    } catch (e) {
      print('Error setting language: $e');
      // 에러 발생 시 기본 언어로 설정
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> speak(
      String text, String languageCode, double speechRate) async {
    if (_isSpeaking) return;

    try {
      _isSpeaking = true;

      await _setVoiceForLanguage(languageCode);
      await _tts.setSpeechRate(speechRate);
      await _tts.speak(text);

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error speaking: $e');
      rethrow;
    } finally {
      _isSpeaking = false;
    }
  }

  // 음성 중지
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  // 리소스 정리
  Future<void> dispose() async {
    try {
      await stop();
    } catch (e) {
      print('Error disposing TTS: $e');
    }
  }
}
