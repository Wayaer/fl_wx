# fl_wx 简单封装 [fluwx](https://pub.dev/packages/fluwx)

```dart

void func() {
  /// 启动注册
  FlWX().register(
      appId: '',
      params: FlWXCallbackParams(
          onHttp: (url) async {
            return '';
          },
          onLog: (v) => log(v),
          onToast: (v) => showToast(v)));

  /// 安装判断
  FlWX().isInstalled;

  /// 授权登录
  FlWX().authBy(NormalAuth(scope: ''));

  /// 签名数据
  final pay = {}.toPayment();
  if (pay != null) FlWX().pay(pay);

  /// 打开微信
  FlWX().open(WeChatApp());

  /// 分享
  FlWX().share(WeChatShareTextModel('share'));
}

```