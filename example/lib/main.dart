import 'package:fl_extended/fl_extended.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'FlWX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      navigatorKey: FlExtended().navigatorKey,
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
            appId: '1111',
            params: FlWXCallbackParams(
                onHttp: (url) async {
                  return '';
                },
                onLog: (v) => log(v),
                onToast: (v) => showToast(v)));
      }),
      Button('isInstalled', onPressed: () {
        FlWX().isInstalled.then((value) {
          showToast(value.toString());
        });
      }),
      Button('isSupportOpenBusinessView', onPressed: () {
        FlWX().isSupportOpenBusinessView.then((value) {
          showToast(value.toString());
        });
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
      Button('shareText', onPressed: () {
        FlWX().shareText('shareText');
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
