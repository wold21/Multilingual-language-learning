import 'dart:async';

import 'package:eng_word_storage/components/check_dialog.dart';
import 'package:eng_word_storage/components/indicator/indicator.dart';
import 'package:eng_word_storage/pages/root_page.dart';
import 'package:eng_word_storage/services/version_check_service.dart';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _versionCheckService = VersionCheckService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCheck();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateCheck() async {
    await _versionCheckService.initialize();
    bool needUpdate = await _versionCheckService.checkForUpdate(context);
    if (needUpdate) {
      final confirmed = await CheckDialog.show(
        context: context,
        title: 'New Update',
        content:
            'A new update has been released! Please update for smooth usage.',
        text: 'Update',
      );

      if (confirmed == true) {
        bool isStoreOpen =
            await _versionCheckService.launchStore(context, needUpdate);
        if (!isStoreOpen) {
          ToastUtils.show(
            message: 'common.toast.errorOpenStore'.tr(),
            type: ToastType.error,
          );
          await _moveToMain();
        }
      }
    } else {
      await _moveToMain();
    }
  }

  Future _moveToMain() async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dog.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Laboca',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 40),
              const SizedBox(
                width: 150,
                height: 80,
                child: BouncingDotsIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
