import 'package:eng_word_storage/components/sheet/common_alert_dialog.dart';
import 'package:eng_word_storage/services/app_info_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LegalService {
  static final LegalService instance = LegalService._internal();
  LegalService._internal();

  void showPrivacyPolicy(BuildContext context) {
    CommonAlertDialog.show(
      context: context,
      title: 'setting.title.privacyPolicy'.tr(),
      content: 'This app does not collect any personal information. '
          'All data is stored only on the user\'s device and '
          'is not transmitted externally.\n\n'
          'Vocabulary data is stored locally on the user\'s device and '
          'will not be shared externally unless '
          'the user explicitly uses the export feature.',
      confirmText: 'Close',
    );
  }

  void showTermsOfService(BuildContext context) {
    CommonAlertDialog.show(
      context: context,
      title: 'setting.title.termsOfService'.tr(),
      content: 'All responsibility for the use of this app lies with the user.',
      confirmText: 'Close',
    );
  }

  void showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppInfoService.instance.appName,
      applicationVersion: '1.0.0',
    );
  }
}
