import 'dart:async';
import 'package:flutter/material.dart';

/// Color constants used across this file
const Color _black = Color(0xFF000000);
const Color _white = Color(0xFFFFFFFF);
const Color _mediumGray = Color(0xFF9E9E9E);
const Color _lightGray = Color(0xFFE0E0E0);
const Color _backgroundGray = Color(0xFFF5F5F5);

enum PomodoroState { idle, focus, shortBreak }

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with SingleTickerProviderStateMixin {
  static const int focusDuration = 25 * 60; // 25 minutes
  static const int breakDuration = 5 * 60; // 5 minutes

  PomodoroState _state = PomodoroState.idle;
  int _secondsLeft = focusDuration;
  Timer? _timer;
  int _completedPomodoros = 0;
  late AnimationController _pulseController;

  // Color constants moved to top-level for use by helper widgets

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _state = PomodoroState.focus);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onTimerEnd();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _state = PomodoroState.idle);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _state = PomodoroState.idle;
      _secondsLeft = focusDuration;
    });
  }

  void _startBreak() {
    setState(() {
      _state = PomodoroState.shortBreak;
      _secondsLeft = breakDuration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() {
          _state = PomodoroState.idle;
          _secondsLeft = focusDuration;
        });
      }
    });
  }

  void _onTimerEnd() {
    _timer?.cancel();
    setState(() {
      _completedPomodoros++;
      _state = PomodoroState.idle;
      _secondsLeft = focusDuration;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Focus session done!',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'You completed $_completedPomodoros pomodoro${_completedPomodoros > 1 ? "s" : ""} today!\nTake a 5-minute break.',
          style: const TextStyle(color: _mediumGray),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child:
                const Text('Skip break', style: TextStyle(color: _mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startBreak();
            },
            child: const Text('Start break'),
          ),
        ],
      ),
    );
  }

  String get _timeDisplay {
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  double get _progress {
    final total = _state == PomodoroState.shortBreak
        ? breakDuration.toDouble()
        : focusDuration.toDouble();
    return 1 - (_secondsLeft / total);
  }

  Color get _stateColor {
    switch (_state) {
      case PomodoroState.focus:
        return _black;
      case PomodoroState.shortBreak:
        return Colors.green;
      case PomodoroState.idle:
        return _mediumGray;
    }
  }

  String get _stateLabel {
    switch (_state) {
      case PomodoroState.focus:
        return 'FOCUS';
      case PomodoroState.shortBreak:
        return 'BREAK';
      case PomodoroState.idle:
        return 'READY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lightGray),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🍅 Pomodoro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
              if (_completedPomodoros > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_completedPomodoros done',
                    style: const TextStyle(color: _white, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress ring
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: _lightGray,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    color: _stateColor,
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _timeDisplay,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: _stateColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: _stateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _stateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _stateColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mode selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _ModeChip(label: '25 / 5', isSelected: true),
              const SizedBox(width: 8),
              const _ModeChip(label: '50 / 10', isSelected: false),
            ],
          ),
          const SizedBox(height: 20),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              GestureDetector(
                onTap: _reset,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _backgroundGray,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.refresh, color: _black),
                ),
              ),
              const SizedBox(width: 20),

              // Main button
              GestureDetector(
                onTap: _state == PomodoroState.idle ? _start : _pause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _stateColor,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: _stateColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _state == PomodoroState.idle
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: _white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Skip to break
              GestureDetector(
                onTap: _startBreak,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _backgroundGray,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.coffee_outlined, color: _black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tip
          Text(
            _state == PomodoroState.focus
                ? '🔥 Stay focused! Put your phone down.'
                : _state == PomodoroState.shortBreak
                    ? '☕ Rest your eyes, stretch a bit.'
                    : 'Start a 25-min focus session',
            style: const TextStyle(
              fontSize: 12,
              color: _mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _ModeChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? _black : _backgroundGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? _white : _mediumGray,
        ),
      ),
    );
  }
}
