enum ContentLanguage {
  enUS(code: 'en-US', name: 'English (US)', flag: '🇺🇸', ttsCode: 'en-US'),
  enGB(code: 'en-GB', name: 'English (UK)', flag: '🇬🇧', ttsCode: 'en-GB'),
  ja(code: 'ja', name: 'Japanese', flag: '🇯🇵', ttsCode: 'ja-JP'),
  zh(code: 'zh', name: 'Chinese', flag: '🇨🇳', ttsCode: 'zh-CN'),
  ko(code: 'ko', name: 'Korean', flag: '🇰🇷', ttsCode: 'ko-KR'),
  ph(code: 'ph', name: 'Filipino', flag: '🇵🇭', ttsCode: 'fil-PH');

  final String code;
  final String name;
  final String flag;
  final String ttsCode; // TTS용 언어 코드 추가

  const ContentLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.ttsCode,
  });

  static ContentLanguage fromCode(String code) {
    return ContentLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => ContentLanguage.enUS,
    );
  }

  // TTS 코드로 언어 찾기
  static ContentLanguage fromTtsCode(String ttsCode) {
    return ContentLanguage.values.firstWhere(
      (language) => language.ttsCode == ttsCode,
      orElse: () => ContentLanguage.enUS,
    );
  }

  static String getTtsCode(String code) {
    return ContentLanguage.values
        .firstWhere(
          (language) => language.code == code,
          orElse: () => ContentLanguage.enUS,
        )
        .ttsCode;
  }
}
