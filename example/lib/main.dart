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
          appBar: AppBar(title: const Text('FlWX')),
          body: const Center(child: _HomePage()))));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, alignment: WrapAlignment.center, children: [
      Button('register', onPressed: () {
        FlWX().register(
            appId: '',
            params: FlWXBuilderParams(
                httpBuilder: (url) async {
                  return '';
                },
                logBuilder: (v) => v.log(),
                toastBuilder: (v) => showToast(v)));
      }),
      Button('isInstalled', onPressed: () {
        FlWX().isInstalled;
      }),
      Button('isSupportOpenBusinessView', onPressed: () {
        FlWX().isSupportOpenBusinessView;
      }),
      Button('authBy', onPressed: () {
        FlWX().authBy(NormalAuth(scope: ''));
      }),
      Button('pay', onPressed: () {
        final pay = {}.toPayment();
        if (pay != null) FlWX().pay(pay);
      }),
      Button('open', onPressed: () {
        FlWX().open(WeChatApp());
      }),
      Button('share', onPressed: () {
        FlWX().share(WeChatShareTextModel('share'));
      }),
      Button('getExtMsg', onPressed: () async {
        final result = await FlWX().getExtMsg();
        if (result != null) showToast(result);
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
