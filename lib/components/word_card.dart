import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:eng_word_storage/ads/interstitial_ad_widget.dart';
import 'package:eng_word_storage/services/tts_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TtsService _tts = TtsService();
  bool isExpanded = false;
  bool _showContent = false;

  static const String _adTtsCountKey = 'ad_tts_count';
  static const int _adTtsThreshold = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _speak(double speechRate) async {
    try {
      // _tts.init();
      await _tts.speak(
        widget.word.word,
        widget.word.language,
        speechRate,
      );

      await _handleAdWordCount();
    } catch (e) {
      if (mounted) {
        ToastUtils.show(
          message: 'common.errorMessage.ttsError'.tr(),
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleAdWordCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_adTtsCountKey) ?? 0;
    currentCount++;

    if (currentCount >= _adTtsThreshold) {
      await prefs.setInt(_adTtsCountKey, 0);
      await _showInterstitialAd();
    } else {
      await prefs.setInt(_adTtsCountKey, currentCount);
    }
  }

  Future<void> _showInterstitialAd() async {
    bool adLoaded = await InterstitialAdService().loadInterstitialAd();

    if (adLoaded) {
      InterstitialAdService().showInterstitialAd();
    } else {
      ToastUtils.show(
        message: 'common.ad.errorMassage.loadYet'.tr(),
        type: ToastType.error,
      );
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  if (Platform.isIOS) {
                                    _speak(0.1);
                                  } else {
                                    _speak(0.25);
                                  }
                                },
                                child: const Center(
                                    child: Text(
                                  '🐢',
                                  style: TextStyle(fontSize: 18.0),
                                )),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  if (Platform.isIOS) {
                                    _speak(0.35);
                                  } else {
                                    _speak(0.5);
                                  }
                                },
                                child: const Center(
                                  child: Text(
                                    '🐇',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  if (Platform.isIOS) {
                                    _speak(0.5);
                                  } else {
                                    _speak(0.75);
                                  }
                                },
                                child: const Center(
                                  child: Text(
                                    '🐆',
                                    style: TextStyle(fontSize: 22.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        // Row 안에 Expanded 추가
                        child: Padding(
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
                                  softWrap: true, // 자동 줄바꿈 활성화
                                  overflow:
                                      TextOverflow.visible, // 오버플로우 시 잘리지 않고 표시
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
                                      softWrap: true, // 자동 줄바꿈 활성화
                                      overflow: TextOverflow
                                          .visible, // 오버플로우 시 잘리지 않고 표시
                                    ),
                                  ),
                              ],
                            ),
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
