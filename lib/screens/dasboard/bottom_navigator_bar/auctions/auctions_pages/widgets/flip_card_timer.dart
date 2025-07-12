import 'package:flutter/material.dart';

import '../../../../../../utils/colors.dart';

class FlipCardTimer extends StatelessWidget {
  final Duration remainingTime;

  const FlipCardTimer({required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    final hours = remainingTime.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'İhalenin Bitişine Kalan Süre',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.primaryColor),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeCard(hours, 'SAAT', context),
            const SizedBox(width: 8),
            _buildTimeCard(minutes, 'DAKİKA', context),
            const SizedBox(width: 8),
            _buildTimeCard(seconds, 'SANİYE', context),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard(String time, String label, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ...time.split('').map((digit) => _buildFlipCard(digit, context)).toList(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFlipCard(String digit, BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final flipAnimation = TweenSequence<double>([
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: -0.5),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: -0.5, end: 0),
            weight: 50,
          ),
        ]).animate(animation);

        return AnimatedBuilder(
          animation: flipAnimation,
          child: child,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(flipAnimation.value * 3.1415),
              child: child,
            );
          },
        );
      },
      child: Container(
        key: ValueKey<String>(digit),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}