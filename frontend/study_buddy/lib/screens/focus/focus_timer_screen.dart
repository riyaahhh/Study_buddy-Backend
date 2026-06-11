import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/pomodoro_timer.dart';

class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Focus Timer')),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: PomodoroTimer(),
        ),
      ),
    );
  }
}
