import 'package:example/demo/demo_utils.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class BasicPage extends StatelessWidget {
  const BasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: '注册应用、读取全局配置，以及通过 fluwx 底层实例调用未封装的能力。',
      actions: [
        ApiAction(
          icon: Icons.app_registration_rounded,
          title: 'register',
          description: '注册微信开放平台应用，并配置日志、Toast 和 HTTP 回调。示例使用占位 appId，替换真实配置后才能注册成功。',
          code: r'''final result = await FlWx().register(
  appId: 'test',
  universalLink: 'https://test/app/',
  appSecret: 'test-secret',
  appName: 'FlWx Example',
  params: FlWxCallbackParams(
    onLog: (message) => debugPrint('LOG $message'),
    onToast: (message) => debugPrint('TOAST $message'),
    onHttp: (url) async => null,
  ),
);''',
          action: registerDemo,
        ),
        ApiAction(
          icon: Icons.fingerprint_rounded,
          title: 'FlWx() / FlWx.instance',
          description: 'FlWx 是单例，两种写法返回同一个实例。',
          code: r'''final a = FlWx();
final b = FlWx.instance;
final same = identical(a, b);''',
          action: () async => identical(FlWx(), FlWx.instance),
        ),
        ApiAction(
          icon: Icons.info_outline_rounded,
          title: 'appId / appSecret / appName',
          description: '读取 register 时保存的配置。',
          code: r'''final info = (
  appId: FlWx().appId,
  appSecret: FlWx().appSecret,
  appName: FlWx().appName,
);''',
          action: () async => (appId: FlWx().appId, appSecret: FlWx().appSecret, appName: FlWx().appName),
        ),
        ApiAction(
          icon: Icons.download_done_rounded,
          title: 'isInstalled',
          description: '判断设备是否安装微信。',
          code: r'''final installed = await FlWx().isInstalled;''',
          action: () async => await FlWx().isInstalled,
        ),
        ApiAction(
          icon: Icons.storefront_outlined,
          title: 'isSupportOpenBusinessView',
          description: '判断是否支持打开微信业务视图。',
          code: r'''final supported = await FlWx().isSupportOpenBusinessView;''',
          action: () async => await FlWx().isSupportOpenBusinessView,
        ),
        ApiAction(
          icon: Icons.mark_email_unread_outlined,
          title: 'getExtMsg',
          description: '读取微信拉起 App 时携带的扩展消息。',
          code: r'''final message = await FlWx().getExtMsg();''',
          action: () async => await FlWx().getExtMsg() ?? '没有扩展消息',
        ),
        ApiAction(
          icon: Icons.restore_rounded,
          title: 'attemptToResumeMsgFromWx',
          description: '冷启动时恢复微信拉起 App 的消息。',
          code: r'''await FlWx().attemptToResumeMsgFromWx(
  onResponse: logResponse,
);''',
          action: () async {
            await FlWx().attemptToResumeMsgFromWx(onResponse: logResponse);
            return '已注册恢复监听';
          },
        ),
        ApiAction(
          icon: Icons.extension_rounded,
          title: 'fluwx 底层实例',
          description: '通过 fluwx 调用 fl_wx 未封装的能力。',
          code: r'''final Fluwx fluwx = FlWx().fluwx;
final installed = await fluwx.isWeChatInstalled;''',
          action: () async => await FlWx().fluwx.isWeChatInstalled,
        ),
        ApiAction(
          icon: Icons.wifi_tethering_rounded,
          title: 'addSubscriber',
          description: '直接订阅微信响应，示例中订阅后立即取消。',
          code: r'''final cancelable = FlWx().fluwx.addSubscriber(
  (response) => logResponse(response),
);
cancelable.cancel();''',
          action: () async {
            final cancelable = FlWx().fluwx.addSubscriber(logResponse);
            cancelable.cancel();
            return '已添加并取消监听';
          },
        ),
        ApiAction(
          icon: Icons.verified_outlined,
          title: 'selfCheck',
          description: 'iOS 调试模式下检查微信接入是否正常。',
          code: r'''await FlWx().fluwx.selfCheck();''',
          action: () async {
            await FlWx().fluwx.selfCheck();
            return 'selfCheck 已触发';
          },
        ),
      ],
    );
  }
}
