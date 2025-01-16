import 'package:easy_localization/easy_localization.dart';
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
        title: Text(
          'mainPage.languageFilter.title'.tr(),
          style: const TextStyle(
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
              'common.button.done'.tr(),
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
          const AdSection(),
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
              child: LanguageList(
                isAllSelected: _isAllSelected,
                currentLanguages: _currentLanguages,
                onChanged: (allSelected, langs) {
                  setState(() {
                    _isAllSelected = allSelected;
                    _currentLanguages = langs;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdSection extends StatelessWidget {
  const AdSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
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
    );
  }
}

class LanguageList extends StatefulWidget {
  final bool isAllSelected;
  final List<String> currentLanguages;
  final Function(bool, List<String>) onChanged;

  const LanguageList({
    Key? key,
    required this.isAllSelected,
    required this.currentLanguages,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late bool _localAllSelected;
  late List<String> _localLanguages;

  @override
  void initState() {
    super.initState();
    _localAllSelected = widget.isAllSelected;
    _localLanguages = List.from(widget.currentLanguages);
  }

  void _toggleAll() {
    setState(() {
      _localAllSelected = !_localAllSelected;
      if (_localAllSelected) {
        _localLanguages.clear();
      }
      widget.onChanged(_localAllSelected, _localLanguages);
    });
  }

  void _toggleLanguage(String code) {
    setState(() {
      _localAllSelected = false;
      if (_localLanguages.contains(code)) {
        _localLanguages.remove(code);
      } else {
        _localLanguages.add(code);
      }
      if (_localLanguages.isEmpty) {
        _localAllSelected = true;
      }
      widget.onChanged(_localAllSelected, _localLanguages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ContentLanguage.values.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: const Text('🌎 All Languages'),
            onTap: () async {
              await HapticFeedback.lightImpact();
              _toggleAll();
            },
            leading: Checkbox(
              value: _localAllSelected,
              onChanged: (bool? value) {
                if (value != null) _toggleAll();
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
            _toggleLanguage(lang.code);
          },
          leading: Checkbox(
            value: !_localAllSelected && _localLanguages.contains(lang.code),
            onChanged: (bool? value) {
              if (value != null) _toggleLanguage(lang.code);
            },
            activeColor: Theme.of(context).primaryColor,
            checkColor: Colors.white,
          ),
          splashColor: Colors.transparent,
        );
      },
    );
  }
}
