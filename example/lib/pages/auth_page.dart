import 'package:example/demo/demo_utils.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: '微信登录授权、扫码授权、手机号授权，以及授权后的 token 与用户信息获取。',
      actions: [
        ApiAction(
          icon: Icons.login_rounded,
          title: 'authBy(NormalAuth)',
          description: '拉起微信授权，并注册完整的授权回调。',
          code: r'''final result = await FlWx().authBy(
  NormalAuth(scope: 'snsapi_userinfo', state: 'fl_wx_example'),
  onResponse: logResponse,
  onAuthResponse: logResponse,
  onToken: logToken,
  onUserInfo: logUserInfo,
);''',
          action: () async => await FlWx().authBy(
            NormalAuth(scope: 'snsapi_userinfo', state: 'fl_wx_example'),
            onResponse: logResponse,
            onAuthResponse: logResponse,
            onToken: logToken,
            onUserInfo: logUserInfo,
          ),
        ),
        ApiAction(
          icon: Icons.lock_person_outlined,
          title: 'NormalAuth.nonAutomatic',
          description: '非自动授权模式，用户可以决定是否授权。',
          code: r'''final result = await FlWx().authBy(
  NormalAuth(
    scope: 'snsapi_userinfo',
    state: 'state',
    nonAutomatic: true,
  ),
  onAuthResponse: logResponse,
);''',
          action: () async => await FlWx().authBy(
            NormalAuth(scope: 'snsapi_userinfo', state: 'state', nonAutomatic: true),
            onAuthResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.qr_code_2_rounded,
          title: 'authBy(QRCode)',
          description: '未安装微信时使用扫码授权，完成后回调。',
          code: r'''final result = await FlWx().authBy(
  QRCode(
    appId: 'test',
    scope: 'snsapi_userinfo',
    nonceStr: 'nonceStr',
    timestamp: 'timestamp',
    signature: 'signature',
    schemeData: 'schemeData',
  ),
  onAuthByQRCodeFinishedResponse: logResponse,
);''',
          action: () async => await FlWx().authBy(
            QRCode(
              appId: 'test',
              scope: 'snsapi_userinfo',
              nonceStr: 'nonceStr',
              timestamp: '${DateTime.now().millisecondsSinceEpoch}',
              signature: 'signature',
              schemeData: 'schemeData',
            ),
            onAuthByQRCodeFinishedResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.phone_iphone_rounded,
          title: 'authBy(PhoneLogin)',
          description: '手机号授权，目前仅支持 iOS。',
          code: r'''final result = await FlWx().authBy(
  PhoneLogin(scope: 'snsapi_userinfo', state: 'state'),
  onAuthResponse: logResponse,
);''',
          action: () async => await FlWx().authBy(
            PhoneLogin(scope: 'snsapi_userinfo', state: 'state'),
            onAuthResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.key_outlined,
          title: '只获取 token',
          description: '传入 onToken，授权成功后自动请求 token。',
          code: r'''final result = await FlWx().authBy(
  NormalAuth(scope: 'snsapi_userinfo', state: 'state'),
  onToken: logToken,
);''',
          action: () async => await FlWx().authBy(
            NormalAuth(scope: 'snsapi_userinfo', state: 'state'),
            onToken: logToken,
          ),
        ),
        ApiAction(
          icon: Icons.badge_outlined,
          title: 'token + 用户信息',
          description: '同时传入 onToken 和 onUserInfo，自动串行请求。',
          code: r'''final result = await FlWx().authBy(
  NormalAuth(scope: 'snsapi_userinfo', state: 'state'),
  onToken: logToken,
  onUserInfo: logUserInfo,
);''',
          action: () async => await FlWx().authBy(
            NormalAuth(scope: 'snsapi_userinfo', state: 'state'),
            onToken: logToken,
            onUserInfo: logUserInfo,
          ),
        ),
        ApiAction(
          icon: Icons.stop_circle_outlined,
          title: 'stopAuthByQRCode',
          description: '停止扫码授权流程，来自底层 fluwx。',
          code: r'''final result = await FlWx().fluwx.stopAuthByQRCode();''',
          action: () async => await FlWx().fluwx.stopAuthByQRCode(),
        ),
      ],
    );
  }
}
