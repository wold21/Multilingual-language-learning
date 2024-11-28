import 'dart:io';
import 'package:eng_word_storage/services/app_info_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/toast_util.dart';

class FeedbackService {
  static final FeedbackService instance = FeedbackService._internal();
  FeedbackService._internal();

  Future<void> sendFeedback() async {
    final appVersion = await AppInfoService.instance.getAppVersion();
    final Uri emailLaunchUri =
        Uri(scheme: 'mailto', path: 'seohae9513@gmail.com', queryParameters: {
      'subject': 'Voca Storage Feedback',
      'body':
          'App Version: $appVersion\nDevice: ${Platform.operatingSystem}\n\nFeedback:'
    });

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ToastUtils.show(
        message: 'Could not open email client',
        type: ToastType.error,
      );
    }
  }
}
