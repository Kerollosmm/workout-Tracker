import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rest_timer_provider.dart';
import '../widgets/rest_timer_widget.dart';

class RestTimerScreen extends StatelessWidget {
  const RestTimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestTimerProvider(),
      child: Scaffold(
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: RestTimerWidget(),
          ),
        ),
      ),
    );
  }
}