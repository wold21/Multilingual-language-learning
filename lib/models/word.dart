class Word {
  final int? id;
  final String word;
  final int wordLength;
  final String meaning;
  final String? memo;
  final int groupId;
  final String? groupName;
  final String language;
  final String? audioPath;
  final int? audioLastUpdated;
  final int createdAt;
  final int updatedAt;

  Word({
    this.id,
    required this.word,
    int? wordLength,
    required this.meaning,
    this.memo,
    required this.groupId,
    this.groupName,
    this.language = 'en',
    this.audioPath,
    this.audioLastUpdated,
    required this.createdAt,
    required this.updatedAt,
  }) : wordLength = wordLength ?? word.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'word_length': wordLength,
      'meaning': meaning,
      'memo': memo,
      'group_id': groupId,
      'language': language,
      'audio_path': audioPath,
      'audio_last_updated': audioLastUpdated,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      wordLength: map['word_length'] as int,
      meaning: map['meaning'],
      memo: map['memo'],
      groupId: map['group_id'],
      language: map['language'],
      audioPath: map['audio_path'],
      audioLastUpdated: map['audio_last_updated'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Word copyWith({
    int? id,
    String? word,
    int? wordLength,
    String? meaning,
    String? memo,
    int? groupId,
    String? groupName,
    String? language,
    String? audioPath,
    int? audioLastUpdated,
    int? createdAt,
    int? updatedAt,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      wordLength: wordLength ?? this.wordLength,
      meaning: meaning ?? this.meaning,
      memo: memo ?? this.memo,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      language: language ?? this.language,
      audioPath: audioPath ?? this.audioPath,
      audioLastUpdated: audioLastUpdated ?? this.audioLastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
