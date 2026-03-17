import 'package:flutter/material.dart';

class SimpleInfoScreen extends StatelessWidget {
  const SimpleInfoScreen({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(body, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}
