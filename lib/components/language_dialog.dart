import 'package:easy_localization/easy_localization.dart';
import 'package:eng_word_storage/utils/system_language.dart';
import 'package:flutter/material.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = EasyLocalization.of(context)!.currentLocale!;
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: SystemLanguage.values.length,
                itemBuilder: (context, index) {
                  final locale = SystemLanguage.values[index];
                  String compareCode = '';
                  if (currentLocale.countryCode != null) {
                    compareCode =
                        '${currentLocale.languageCode}-${currentLocale.countryCode}';
                  } else {
                    compareCode = currentLocale.languageCode;
                  }
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final parts = locale.code.split('-');
                        if (parts.length == 2) {
                          context.setLocale(Locale(parts[0], parts[1]));
                        } else {
                          context.setLocale(Locale(locale.code));
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: locale.code == compareCode
                              ? Theme.of(context).primaryColor.withOpacity(0.5)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              locale.flag,
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              locale.name,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
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
