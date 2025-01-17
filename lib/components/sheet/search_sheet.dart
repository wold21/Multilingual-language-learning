import 'package:easy_localization/easy_localization.dart';
import 'package:eng_word_storage/models/word.dart';
import 'package:flutter/material.dart';

class SearchSheet extends StatefulWidget {
  final List<int> selectedGroupIds;

  const SearchSheet({
    super.key,
    required this.selectedGroupIds,
  });

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _searchController = TextEditingController();
  List<Word> searchResults = [];
  bool isLoading = false;
  bool _searchInAllGroups = false;

  void _performSearch(String query) {
    if (query.isEmpty) return;

    Navigator.pop(context, {
      'query': query,
      'searchInAllGroups': _searchInAllGroups,
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 28,
                  ),
                  padding: const EdgeInsets.all(12),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _searchController,
                    builder: (context, TextEditingValue value, _) {
                      return TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        onSubmitted: _performSearch,
                        decoration: InputDecoration(
                          hintText: _searchInAllGroups
                              ? 'mainPage.searchBar.placeholderAll'.tr()
                              : 'mainPage.searchBar.placeholderGroup'.tr(),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _searchInAllGroups ? Icons.public : Icons.filter_list,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchInAllGroups = !_searchInAllGroups;
                    });
                  },
                  tooltip: _searchInAllGroups
                      ? 'mainPage.searchBar.placeholderAll'.tr()
                      : 'mainPage.searchBar.placeholderGroup'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
