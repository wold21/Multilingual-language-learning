import 'package:eng_word_storage/ads/banner_ad_widget.dart';
import 'package:eng_word_storage/utils/content_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eng_word_storage/services/purchase_service.dart';

class LanguageConditionPage extends StatefulWidget {
  final List<String> currentLanguages;
  const LanguageConditionPage({
    super.key,
    required this.currentLanguages,
  });

  @override
  State<LanguageConditionPage> createState() => _LanguageConditionPageState();
}

class _LanguageConditionPageState extends State<LanguageConditionPage> {
  late List<String> _currentLanguages;
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _isAllSelected = widget.currentLanguages.isEmpty;
    _currentLanguages =
        _isAllSelected ? [] : List.from(widget.currentLanguages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Language Filter',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _currentLanguages);
            },
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<bool>(
            future: PurchaseService.instance.isAdRemoved(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final initialAdRemoved = futureSnapshot.data ?? false;

              return StreamBuilder<bool>(
                stream: PurchaseService.instance.adsRemovedStream,
                initialData: initialAdRemoved,
                builder: (context, snapshot) {
                  bool isAdRemoved = snapshot.data ?? false;
                  return isAdRemoved
                      ? const SizedBox.shrink()
                      : BannerAdWidget(isAdRemoved: isAdRemoved);
                },
              );
            },
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: Color(0x8C4E4E4E),
                    width: 1.5,
                  ),
                ),
              ),
              child: ListView.builder(
                itemCount: ContentLanguage.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('🌎 All Languages'),
                      onTap: () async {
                        await HapticFeedback.lightImpact();
                        setState(() {
                          _isAllSelected = !_isAllSelected;
                          if (_isAllSelected) {
                            _currentLanguages.clear();
                          }
                        });
                      },
                      leading: Checkbox(
                        value: _isAllSelected,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              _isAllSelected = value;
                              if (_isAllSelected) {
                                _currentLanguages.clear();
                              }
                            });
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                        checkColor: Colors.white,
                      ),
                      splashColor: Colors.transparent,
                    );
                  }

                  final lang = ContentLanguage.values[index - 1];
                  return ListTile(
                    title: Text('${lang.flag} ${lang.name}'),
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      setState(() {
                        _isAllSelected = false;
                        if (_currentLanguages.contains(lang.code)) {
                          _currentLanguages.remove(lang.code);
                        } else {
                          _currentLanguages.add(lang.code);
                        }

                        if (_currentLanguages.isEmpty) {
                          _isAllSelected = true;
                        }
                      });
                    },
                    leading: Checkbox(
                      value: !_isAllSelected &&
                          _currentLanguages.contains(lang.code),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _isAllSelected = false;
                            if (value) {
                              if (!_currentLanguages.contains(lang.code)) {
                                _currentLanguages.add(lang.code);
                              }
                            } else {
                              _currentLanguages.remove(lang.code);
                            }

                            if (_currentLanguages.isEmpty) {
                              _isAllSelected = true;
                            }
                          });
                        }
                      },
                      activeColor: Theme.of(context).primaryColor,
                      checkColor: Colors.white,
                    ),
                    splashColor: Colors.transparent,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
