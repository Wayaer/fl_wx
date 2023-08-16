import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'FlWX',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
        appBar: AppBar(title: const Text('FlWX')), body: const _HomePage()),
  ));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Button('res', onPressed: () {}),
    ]);
  }
}

class Button extends ElevatedButton {
  Button(
    String text, {
    super.key,
    required super.onPressed,
  }) : super(child: Text(text));
}
