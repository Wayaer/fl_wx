import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

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
      Button('res', onPressed: () {
        FlWX().register(
            appId: '',
            params: FlWXBuilderParams(
                httpBuilder: (url) async {
                  return '';
                },
                logBuilder: (v) => log(v),
                toastBuilder: (v) => showToast(v)));
      }),
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
