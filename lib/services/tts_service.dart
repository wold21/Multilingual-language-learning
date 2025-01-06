import 'dart:io' show Platform;
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
      if (Platform.isIOS) {
        // iOS 음성 설정
        switch (languageCode) {
          case 'en':
            await _tts.setLanguage('en-US');
            await _tts.setVoice({
              "name": "Samantha",
              "locale": "en-US",
            });
            break;
          case 'gb':
            await _tts.setLanguage('en-GB');
            await _tts.setVoice({
              "name": "Daniel",
              "locale": "en-GB",
            });
            break;
          case 'ja':
            await _tts.setLanguage('ja-JP');
            await _tts.setVoice({
              "name": "Kyoko",
              "locale": "ja-JP",
            });
            break;
          case 'zh':
            await _tts.setLanguage('zh-CN');
            await _tts.setVoice({
              "name": "Tingting",
              "locale": "zh-CN",
            });
            break;
          case 'ko':
            await _tts.setLanguage('ko-KR');
            await _tts.setVoice({
              "name": "Yuna",
              "locale": "ko-KR",
            });
            break;
          case 'ph':
            await _tts.setLanguage('en-US');
            await _tts.setVoice({
              "name": "Samantha",
              "locale": "en-US",
            });
            break;
          default:
            await _tts.setLanguage('en-US');
            await _tts.setVoice({
              "name": "Samantha",
              "locale": "en-US",
            });
        }
      } else {
        // Android 음성 설정
        switch (languageCode) {
          case 'en':
            await _tts.setLanguage('en-US');
            await _tts.setVoice({
              "name": "Samantha",
              "locale": "en-US",
            });
            break;
          case 'gb':
            await _tts.setLanguage('en-GB');
            await _tts
                .setVoice({"name": "en-gb-x-gba-local", "locale": "en-GB"});
            break;
          case 'ja':
            await _tts.setLanguage('ja-JP');
            await _tts.setVoice(
                {"name": "ja-jp-x-htm#female_1-local", "locale": "ja-JP"});
            break;
          case 'zh':
            await _tts.setLanguage('zh-CN');
            await _tts.setVoice({
              "name": "zh-cn-x-ism#female_1-local",
              "locale": "zh-CN",
            });
            break;
          case 'ko':
            await _tts.setLanguage('ko-KR');
            await _tts.setVoice(
                {"name": "ko-kr-x-ism#female_2-local", "locale": "ko-KR"});
            break;
          case 'ph':
            await _tts.setLanguage('fil-PH');
            await _tts.setVoice({
              "name": "fil-ph-x-ism#female_2-local",
              "locale": "fil-PH",
            });
            break;
          default:
            await _tts.setLanguage('en-US');
            await _tts.setVoice({
              "name": "Samantha",
              "locale": "en-US",
            });
        }
      }
    } catch (e) {
      print('Error setting language: $e');
      await _tts.setLanguage('en-US');
      if (Platform.isIOS) {
        await _tts.setVoice({
          "name": "Samantha",
          "locale": "en-US",
        });
      }
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
