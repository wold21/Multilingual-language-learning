import 'package:eng_word_storage/ads/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eng_word_storage/services/purchase_service.dart';
import 'package:easy_localization/easy_localization.dart';

enum SortType {
  createdDesc('newest', 'created_at DESC'),
  createdAsc('oldest', 'created_at ASC'),
  alphabeticalAsc('alphabeticalAZ', 'word COLLATE NOCASE ASC'),
  alphabeticalDesc('alphabeticalZA', 'word COLLATE NOCASE DESC'),
  lengthAsc('short', 'word_length ASC, word COLLATE NOCASE ASC'),
  lengthDesc('long', 'word_length DESC, word COLLATE NOCASE ASC');

  final String label;
  final String query;

  const SortType(this.label, this.query);
}

class SortPage extends StatefulWidget {
  final SortType currentSort;

  const SortPage({
    super.key,
    required this.currentSort,
  });

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  late SortType _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
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
          'mainPage.sortBy.title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedSort);
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
                itemCount: SortType.values.length,
                itemBuilder: (context, index) {
                  final sortType = SortType.values[index];
                  return ListTile(
                    title: Text(
                        'mainPage.sortBy.attributes.${sortType.label}'.tr()),
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      setState(() {
                        _selectedSort = sortType;
                      });
                    },
                    leading: Checkbox(
                      value: _selectedSort == sortType,
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            _selectedSort = sortType;
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
