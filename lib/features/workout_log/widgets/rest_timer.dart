import 'package:flutter/material.dart';

class RestTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onComplete;

  const RestTimer({
    Key? key,
    required this.initialSeconds,
    this.onComplete,
  }) : super(key: key);

  @override
  _RestTimerState createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _countdownAnimation;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.initialSeconds),
    );
    _countdownAnimation = StepTween(
      begin: widget.initialSeconds,
      end: 0,
    ).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isRunning = false);
          widget.onComplete?.call();
        }
      });
  }

  void _start() {
    if (!_isRunning) {
      setState(() => _isRunning = true);
      _controller.forward(from: 0);
    }
  }

  void _reset() {
    _controller.reset();
    setState(() => _isRunning = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildTimerText(),
            const SizedBox(height: 16),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Rest Timer',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildTimerText() {
    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, child) {
        final seconds = _countdownAnimation.value;
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        return Text(
          '$minutes:${secs.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isRunning ? null : _start,
          child: const Text('Start'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _reset,
          child: const Text('Reset'),
        ),
      ],
    );
  }
} 