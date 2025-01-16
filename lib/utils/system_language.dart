enum SystemLanguage {
  ko(code: 'ko', name: '한국', flag: '🇰🇷'),
  enUS(code: 'en-US', name: 'United States', flag: '🇺🇸'),
  enGB(code: 'en-GB', name: 'United Kingdom', flag: '🇬🇧');

  // th(code: 'th', name: 'ประเทศไทย', flag: '🇹🇭'),
  // ms(code: 'ms', name: 'Malaysia', flag: '🇲🇾'),
  // fil(code: 'fil', name: 'Pilipinas', flag: '🇵🇭'),
  // ru(code: 'ru', name: 'Россия', flag: '🇷🇺'),
  // ja(code: 'ja', name: '日本', flag: '🇯🇵'),
  // zh(code: 'zh', name: '中国', flag: '🇨🇳'),
  // my(code: 'my', name: 'မြန်မာ', flag: '🇲🇲'),
  // hi(code: 'hi', name: 'भारत', flag: '🇮🇳');

  final String code;
  final String name;
  final String flag;

  const SystemLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}
