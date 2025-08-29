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
      home: Scaffold(appBar: AppBar(title: const Text('FlWX')), body: const Center(child: _HomePage()))));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, alignment: WrapAlignment.center, children: [
      Button('register', onPressed: () {
        FlWX().register(
                appId: '11',
                universalLink: '11',
                params: FlWXCallbackParams(
                    onHttp: (url) async {
                      return '';
                    },
                    onLog: log,
                    onToast: showToast))
            .then((value) {
          showToast('$value');
        });
      }),
      Button('isInstalled', onPressed: () {
        FlWX().isInstalled.then((value) {
          showToast('$value');
        });
      }),
      Button('isSupportOpenBusinessView', onPressed: () {
        FlWX().isSupportOpenBusinessView.then((value) {
          showToast('$value');
        });
      }),
      Button('authBy', onPressed: () {
        FlWX()
            .authBy(
                NormalAuth(scope: 'snsapi_userinfo', state: 'wechat_sdk_demo'))
            .then((value) {
          showToast('$value');
        });
      }),
      Button('pay', onPressed: () {
        final pay = {}.toPayment();
        if (pay != null) {
          FlWX().pay(pay).then((value) {
            showToast('$value');
          });
        }
      }),
      Button('open', onPressed: () {
        FlWX().open(WeChatApp()).then((value) {
          showToast('$value');
        });
      }),
      Button('shareText', onPressed: () {
        FlWX().shareText('shareText').then((value) {
          showToast('$value');
        });
      }),
      Button('share', onPressed: () {
        FlWX().share(WeChatShareTextModel('share')).then((value) {
          showToast('$value');
        });
      }),
      Button('getExtMsg', onPressed: () {
        FlWX().getExtMsg().then((value) {
          if (value != null) showToast(value);
        });
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
