import 'package:eng_word_storage/components/confirm_dialog.dart';
import 'package:eng_word_storage/services/app_info_service.dart';
import 'package:eng_word_storage/services/data_backup_service.dart';
import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/services/feedback_service.dart';
import 'package:eng_word_storage/services/legal_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Reset Data',
      content:
          'This will delete all words and groups. This action cannot be undone. Are you sure you want to continue?',
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteAllWords();
        await DatabaseService.instance.deleteAllGroups();

        ToastUtils.show(
          message: 'All data has been reset',
          type: ToastType.success,
        );
      } catch (e) {
        ToastUtils.show(
          message: 'Failed to reset data',
          type: ToastType.error,
        );
      }
    }
  }

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
        toolbarHeight: 70,
        scrolledUnderElevation: 0, // 스크롤 시 그림자 효과 제거
        elevation: 0,
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
          _SettingsSection(
            title: 'Data Management',
            children: [
              ListTile(
                title: const Text('Import Data'),
                subtitle: const Text('Load words from a file'),
                leading: const Icon(Icons.download_rounded),
                onTap: () => DataBackupService.instance.importData(),
              ),
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Save your words as a file'),
                leading: const Icon(Icons.upload_file),
                onTap: () => DataBackupService.instance.exportData(),
              ),
              ListTile(
                title: const Text('Reset Data'),
                subtitle: const Text('Delete all words and groups'),
                leading: const Icon(Icons.delete_forever),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _resetData(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              FutureBuilder<String>(
                future: AppInfoService.instance.getAppVersion(),
                builder: (context, snapshot) {
                  return ListTile(
                    title: const Text('Version'),
                    subtitle: Text(snapshot.data ?? 'Loading...'),
                    leading: const Icon(Icons.info_outline),
                  );
                },
              ),
              ListTile(
                title: const Text('Send Feedback'),
                subtitle: const Text('Report bugs or suggest features'),
                leading: const Icon(Icons.feedback_outlined),
                onTap: () => FeedbackService.instance.sendFeedback(),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () => LegalService.instance.showPrivacyPolicy(context),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description_outlined),
                onTap: () => LegalService.instance.showTermsOfService(context),
              ),
              ListTile(
                title: const Text('Open Source Licenses'),
                leading: const Icon(Icons.source_outlined),
                onTap: () => LegalService.instance.showLicenses(context),
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 25),
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
          margin: const EdgeInsets.symmetric(horizontal: 25),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Select Theme', style: TextStyle(fontSize: 18)),
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
