import 'dart:ui';

import 'package:flutter/material.dart';
import 'main_page.dart';
import 'settings_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MainPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: isDark
                  ? const Color(0xFF121212).withOpacity(0.7)
                  : Colors.white.withOpacity(0.5),
              elevation: 0,
              indicatorColor: Colors.transparent,
              height: 60,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.collections_bookmark_outlined,
                    color: _currentIndex == 0
                        ? Theme.of(context)
                            .primaryColor
                            .withOpacity(0.7) // 선택된 상태
                        : Colors.grey.withOpacity(0.7),
                  ),
                  selectedIcon: Icon(Icons.collections_bookmark,
                      color: Theme.of(context).primaryColor),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: _currentIndex == 1
                        ? Theme.of(context)
                            .primaryColor
                            .withOpacity(0.7) // 선택된 상태
                        : Colors.grey.withOpacity(0.7),
                  ),
                  selectedIcon: Icon(Icons.settings_rounded,
                      color: Theme.of(context).primaryColor),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
