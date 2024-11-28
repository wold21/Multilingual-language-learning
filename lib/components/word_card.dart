import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word.dart';

class WordCard extends StatefulWidget {
  final Word word;

  const WordCard({
    super.key,
    required this.word,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final FlutterTts flutterTts = FlutterTts();
  bool isExpanded = false;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage(widget.word.language);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak() async {
    try {
      await flutterTts.speak(widget.word.word);
    } catch (e) {
      if (mounted) {
        ToastUtils.show(
          message: 'TTS Error',
          type: ToastType.error,
        );
      }
    }
  }

  void _handleExpand() {
    if (isExpanded) {
      setState(() {
        _showContent = false;
      });
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() {
          isExpanded = false;
        });
      });
    } else {
      setState(() {
        isExpanded = true;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _showContent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            _handleExpand();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.word.word,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${widget.word.groupName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_down_rounded, size: 28),
                        onPressed: _speak,
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _showContent ? 1.0 : 0.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.word.meaning,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.word.memo != null &&
                                  widget.word.memo!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    widget.word.memo!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
