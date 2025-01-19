import 'package:easy_localization/easy_localization.dart';
import 'package:eng_word_storage/ads/banner_ad_widget.dart';
import 'package:eng_word_storage/components/confirm_dialog.dart';
import 'package:eng_word_storage/components/language_dialog.dart';
import 'package:eng_word_storage/services/app_info_service.dart';
import 'package:eng_word_storage/services/data_backup_service.dart';
import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/services/feedback_service.dart';
import 'package:eng_word_storage/services/legal_service.dart';
import 'package:eng_word_storage/services/purchase_service.dart';
import 'package:eng_word_storage/utils/system_language.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'setting.title.resetData'.tr(),
      content: 'setting.massages.resetData'.tr(),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteAllWords();
        await DatabaseService.instance.deleteAllGroups();

        ToastUtils.show(
          message: 'setting.massages.resetSuccess'.tr(),
          type: ToastType.success,
        );
      } catch (e) {
        ToastUtils.show(
          message: 'setting.massages.resetFailed'.tr(),
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentLocale = EasyLocalization.of(context)!
        .currentLocale!
        .toString()
        .replaceAll('_', "-");
    SystemLanguage currentLanguage = SystemLanguage.values.firstWhere(
      (lang) => lang.code == currentLocale,
      orElse: () => SystemLanguage.enUS,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'setting.title.settings'.tr(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 70,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: ListView(
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
          const SizedBox(height: 12),
          _SettingsSection(
            title: 'setting.menu.premium'.tr(),
            children: [
              FutureBuilder<bool>(
                future: PurchaseService.instance.isAdRemoved(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                        title: Text(
                          'common.message.loading'.tr(),
                          style: const TextStyle(fontSize: 15),
                        ),
                        subtitle: Text(
                          'common.message.premiumLoadMessage'.tr(),
                          style: const TextStyle(fontSize: 13),
                        ),
                        leading: const Icon(
                          Icons.watch_later_outlined,
                        ));
                  }

                  final initialAdRemoved = futureSnapshot.data ?? false;

                  return StreamBuilder<bool>(
                    stream: PurchaseService.instance.adsRemovedStream,
                    initialData: initialAdRemoved,
                    builder: (context, snapshot) {
                      bool isAdRemoved = snapshot.data ?? false;
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              isAdRemoved
                                  ? 'setting.title.premiumActive'.tr()
                                  : 'setting.title.removeAds'.tr(),
                              style: const TextStyle(fontSize: 15),
                            ),
                            subtitle: Text(
                              isAdRemoved
                                  ? 'setting.subtitle.premiumActive'.tr()
                                  : 'setting.subtitle.removeAds'.tr(),
                              style: const TextStyle(fontSize: 13),
                            ),
                            leading: Icon(
                              isAdRemoved
                                  ? Icons.workspace_premium
                                  : Icons.ads_click,
                              color: isAdRemoved ? Colors.amber : null,
                            ),
                            trailing: isAdRemoved
                                ? null
                                : TextButton(
                                    onPressed: () async {
                                      try {
                                        await PurchaseService.instance
                                            .buyRemoveAds();
                                      } catch (e) {
                                        ToastUtils.show(
                                          message:
                                              'common.errorMessage.purchaseError'
                                                  .tr(args: [e.toString()]),
                                          type: ToastType.error,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'common.button.buy'.tr(),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                          ),
                          if (Platform.isIOS)
                            ListTile(
                              title: Text(
                                'restorePurchases'.tr(),
                                style: const TextStyle(fontSize: 15),
                              ),
                              leading: const Icon(Icons.restore),
                              onTap: () async {
                                await PurchaseService.instance
                                    .restorePurchases();
                                // setState 필요 없음, StreamBuilder가 자동으로 업데이트
                              },
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'setting.menu.language'.tr(),
            children: [
              ListTile(
                title: Text('setting.title.selectLanguage'.tr(),
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text('setting.subtitle.selectLanguage'.tr(),
                    style: const TextStyle(fontSize: 13)),
                leading: Text(currentLanguage.flag,
                    style: const TextStyle(fontSize: 20)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => {
                  showDialog(
                    context: context,
                    builder: (context) => const LanguageDialog(),
                  )
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'setting.menu.appearance'.tr(),
            children: [
              _buildThemeSelector(),
            ],
          ),
          _SettingsSection(
            title: 'setting.menu.dataManagement'.tr(),
            children: [
              ListTile(
                title: Text('setting.title.importData'.tr(),
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text('setting.subtitle.importData'.tr(),
                    style: const TextStyle(fontSize: 13)),
                leading: const Icon(Icons.download_rounded),
                onTap: () => DataBackupService.instance.importData(),
              ),
              ListTile(
                title: Text('setting.title.exportData'.tr(),
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text('setting.subtitle.exportData'.tr(),
                    style: const TextStyle(fontSize: 13)),
                leading: const Icon(Icons.upload_file),
                onTap: () => DataBackupService.instance.exportData(),
              ),
              ListTile(
                title: Text('setting.title.resetData'.tr(),
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text('setting.subtitle.resetData'.tr(),
                    style: const TextStyle(fontSize: 13)),
                leading: const Icon(Icons.delete_forever),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _resetData(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'setting.menu.about'.tr(),
            children: [
              FutureBuilder<String>(
                future: AppInfoService.instance.getAppVersion(),
                builder: (context, snapshot) {
                  return ListTile(
                    title: Text('setting.title.version'.tr(),
                        style: const TextStyle(fontSize: 15)),
                    subtitle: Text(snapshot.data ?? 'Loading...',
                        style: const TextStyle(fontSize: 13)),
                    leading: const Icon(Icons.info_outline),
                  );
                },
              ),
              ListTile(
                title: Text('setting.title.sendFeedback'.tr(),
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text('setting.subtitle.sendFeedback'.tr(),
                    style: const TextStyle(fontSize: 13)),
                leading: const Icon(Icons.feedback_outlined),
                onTap: () => FeedbackService.instance.sendFeedback(),
              ),
              ListTile(
                title: Text('setting.title.privacyPolicy'.tr(),
                    style: const TextStyle(fontSize: 15)),
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () => LegalService.instance.showPrivacyPolicy(context),
              ),
              ListTile(
                title: Text('setting.title.termsOfService'.tr(),
                    style: const TextStyle(fontSize: 15)),
                leading: const Icon(Icons.description_outlined),
                onTap: () => LegalService.instance.showTermsOfService(context),
              ),
              ListTile(
                title: Text('setting.title.openSourceLicenses'.tr(),
                    style: const TextStyle(fontSize: 15)),
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
        title: Text('setting.title.theme'.tr(),
            style: const TextStyle(fontSize: 15)),
        subtitle: Text(
            themeMode.name.substring(0, 1).toUpperCase() +
                themeMode.name.substring(1),
            style: const TextStyle(fontSize: 13)),
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
      title: Text('setting.title.selectTheme'.tr(),
          style: const TextStyle(fontSize: 18)),
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
