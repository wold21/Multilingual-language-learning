import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Appearance',
            children: [
              _buildThemeSelector(),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildThemeSelector() {
  return ValueListenableBuilder(
    valueListenable: ThemeService.instance.themeMode,
    builder: (context, ThemeMode themeMode, child) {
      return ListTile(
        title: const Text('Theme'),
        subtitle: Text(
          themeMode.name.substring(0, 1).toUpperCase() +
              themeMode.name.substring(1),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _ThemeSelectorDialog(
              currentTheme: themeMode,
            ),
          );
        },
      );
    },
  );
}

class _ThemeSelectorDialog extends StatelessWidget {
  final ThemeMode currentTheme;

  const _ThemeSelectorDialog({
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Theme'),
      children: ThemeMode.values.map((mode) {
        return SimpleDialogOption(
          onPressed: () {
            ThemeService.instance.setThemeMode(mode);
            Navigator.pop(context);
          },
          child: Row(
            children: [
              if (mode == currentTheme)
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                )
              else
                const SizedBox(width: 24),
              const SizedBox(width: 8),
              Text(
                mode.name.substring(0, 1).toUpperCase() +
                    mode.name.substring(1),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
