import 'package:eng_word_storage/ads/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eng_word_storage/services/purchase_service.dart';

enum SortType {
  createdDesc('Newest', 'created_at DESC'),
  createdAsc('Oldest', 'created_at ASC'),
  alphabeticalAsc('Alphabetical A-Z', 'word COLLATE NOCASE ASC'),
  alphabeticalDesc('Alphabetical Z-A', 'word COLLATE NOCASE DESC'),
  lengthAsc('Short', 'word_length ASC, word COLLATE NOCASE ASC'),
  lengthDesc('Long', 'word_length DESC, word COLLATE NOCASE ASC');

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
  bool isAdRemoved = false;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _checkAdRemovalStatus();
  }

  Future<void> _checkAdRemovalStatus() async {
    isAdRemoved = await PurchaseService.instance.isAdRemoved();
    setState(() {});
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
          'Sort By',
          style: TextStyle(
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
          BannerAdWidget(isAdRemoved: isAdRemoved),
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
                    title: Text(sortType.label),
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
