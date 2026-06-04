import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../theme.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer przerwy')),
      body: const _TimerBody(),
    );
  }
}

class _TimerBody extends StatelessWidget {
  const _TimerBody();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Column(
      children: [
        const SizedBox(height: 32),
        // Circular timer
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background track
                SizedBox.expand(
                  child: CustomPaint(
                    painter: _ArcPainter(
                      progress: 1.0,
                      color: AppTheme.surfaceHigh,
                      strokeWidth: 16,
                    ),
                  ),
                ),
                // Progress arc
                AnimatedBuilder(
                  animation: const AlwaysStoppedAnimation(0),
                  builder: (_, __) => SizedBox.expand(
                    child: CustomPaint(
                      painter: _ArcPainter(
                        progress: timer.state == TimerState.idle
                            ? 1.0
                            : timer.progress,
                        color: timer.state == TimerState.finished
                            ? AppTheme.success
                            : timer.state == TimerState.paused
                                ? AppTheme.accentDim
                                : AppTheme.accent,
                        strokeWidth: 16,
                      ),
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timer.timeString,
                      style: GoogleFonts.spaceGrotesk(
                        color: timer.state == TimerState.finished
                            ? AppTheme.success
                            : AppTheme.text,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      _stateLabel(timer.state),
                      style: TextStyle(
                        color: _stateColor(timer.state),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleBtn(
              icon: Icons.refresh,
              color: AppTheme.textMid,
              size: 52,
              onTap: timer.reset,
            ),
            const SizedBox(width: 20),
            _CircleBtn(
              icon: timer.state == TimerState.running
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppTheme.accent,
              size: 72,
              iconSize: 36,
              onTap: () {
                if (timer.state == TimerState.running) {
                  timer.pause();
                } else {
                  timer.start();
                }
              },
            ),
            const SizedBox(width: 20),
            _CircleBtn(
              icon: Icons.add,
              color: AppTheme.textMid,
              size: 52,
              onTap: () {
                // Add 15 seconds
                final newTotal = timer.totalSeconds + 15;
                timer.setPreset(newTotal > 600 ? 600 : newTotal);
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Preset buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text('SZYBKI WYBÓR',
                    style: TextStyle(
                        color: AppTheme.textMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TimerProvider.presets.map((s) {
                  final selected = timer.totalSeconds == s;
                  final label = s < 60
                      ? '${s}s'
                      : s % 60 == 0
                          ? '${s ~/ 60}min'
                          : '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
                  return GestureDetector(
                    onTap: () => timer.setPreset(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.accent : AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(label,
                          style: TextStyle(
                            color: selected ? AppTheme.bg : AppTheme.textMid,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (timer.state == TimerState.finished)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppTheme.success, size: 20),
                const SizedBox(width: 8),
                Text('Przerwa zakończona! Czas na kolejną serię 💪',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ],
            ),
          ),
      ],
    );
  }

  String _stateLabel(TimerState s) {
    return switch (s) {
      TimerState.idle => 'GOTOWY',
      TimerState.running => 'ODLICZANIE',
      TimerState.paused => 'PAUZA',
      TimerState.finished => 'KONIEC!',
    };
  }

  Color _stateColor(TimerState s) {
    return switch (s) {
      TimerState.idle => AppTheme.textLow,
      TimerState.running => AppTheme.accentDim,
      TimerState.paused => AppTheme.textMid,
      TimerState.finished => AppTheme.success,
    };
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.color,
    required this.size,
    this.iconSize = 26,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAccent = color == AppTheme.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAccent ? AppTheme.accent : AppTheme.surfaceHigh,
        ),
        child: Icon(icon,
            color: isAccent ? AppTheme.bg : AppTheme.textMid, size: iconSize),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter(
      {required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
