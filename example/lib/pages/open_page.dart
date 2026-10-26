import 'package:example/demo/demo_utils.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class OpenPage extends StatelessWidget {
  const OpenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: '打开微信、内置浏览器、排行榜、业务视图、发票、客服、小程序和订阅消息。',
      actions: [
        ApiAction(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'open(WeChatApp())',
          description: '使用通用 open 方法打开微信。',
          code: r'''final result = await FlWx().open(WeChatApp());''',
          action: () async => await FlWx().open(WeChatApp()),
        ),
        ApiAction(
          icon: Icons.open_in_new_rounded,
          title: 'openWeChatApp',
          description: '打开微信，并监听微信拉起 App 时的参数。',
          code: r'''final result = await FlWx().openWeChatApp(
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openWeChatApp(onResponse: logResponse),
        ),
        ApiAction(
          icon: Icons.public_rounded,
          title: 'openBrowser',
          description: '使用微信内置浏览器打开网页。',
          code: r'''final result = await FlWx().openBrowser(
  'https://github.com/Wayaer/fl_wx',
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openBrowser('https://github.com/Wayaer/fl_wx', onResponse: logResponse),
        ),
        ApiAction(
          icon: Icons.leaderboard_outlined,
          title: 'openRankList',
          description: '打开微信排行榜。',
          code: r'''final result = await FlWx().openRankList();''',
          action: () async => await FlWx().openRankList(),
        ),
        ApiAction(
          icon: Icons.store_mall_directory_outlined,
          title: 'openBusinessView',
          description: '打开微信业务视图。',
          code: r'''final result = await FlWx().openBusinessView(
  businessType: 'test',
  query: '{"key":"value"}',
  onResponse: logResponse,
);''',
          action: () async =>
              await FlWx().openBusinessView(businessType: 'test', query: '{"key":"value"}', onResponse: logResponse),
        ),
        ApiAction(
          icon: Icons.receipt_long_rounded,
          title: 'openInvoice',
          description: '打开微信发票，包含全部可选参数。',
          code: r'''final result = await FlWx().openInvoice(
  appId: 'test',
  cardType: 'test',
  locationId: 'test',
  cardId: 'test',
  canMultiSelect: '1',
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openInvoice(
            appId: 'test',
            cardType: 'test',
            locationId: 'test',
            cardId: 'test',
            onResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.support_agent_rounded,
          title: 'openCustomerServiceChat',
          description: '打开微信客服会话。',
          code: r'''final result = await FlWx().openCustomerServiceChat(
  corpId: 'test',
  url: 'https://work.weixin.qq.com/',
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openCustomerServiceChat(
            corpId: 'test',
            url: 'https://work.weixin.qq.com/',
            onResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.grid_view_rounded,
          title: 'openMiniProgram',
          description: '打开微信小程序，并指定版本类型。',
          code: r'''final result = await FlWx().openMiniProgram(
  'gh_xxxxxxxx',
  path: '/pages/index',
  miniProgramType: WXMiniProgramType.preview,
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openMiniProgram(
            'gh_xxxxxxxx',
            path: '/pages/index',
            miniProgramType: WXMiniProgramType.preview,
            onResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.notifications_active_outlined,
          title: 'openSubscribeMessage',
          description: '打开微信订阅消息。',
          code: r'''final result = await FlWx().openSubscribeMessage(
  appId: 'test',
  scene: 1,
  templateId: 'test',
  reserved: 'test',
  onResponse: logResponse,
);''',
          action: () async => await FlWx().openSubscribeMessage(
            appId: 'test',
            scene: 1,
            templateId: 'test',
            reserved: 'test',
            onResponse: logResponse,
          ),
        ),
        ApiAction(
          icon: Icons.category_outlined,
          title: 'OpenType 一览',
          description: '所有可传给 open 的目标类型。',
          code: r'''final targets = <OpenType>[
  WeChatApp(),
  Browser('https://example.com'),
  RankList(),
  BusinessView(businessType: 'test', query: '{}'),
  Invoice(appId: 'test', cardType: 'test'),
  CustomerServiceChat(
    corpId: 'test',
    url: 'https://work.weixin.qq.com/',
  ),
  MiniProgram(username: 'gh_xxxxxxxx'),
  SubscribeMessage(
    appId: 'test',
    scene: 1,
    templateId: 'test',
  ),
];''',
          action: () async {
            final targets = <OpenType>[
              WeChatApp(),
              Browser('https://example.com'),
              RankList(),
              BusinessView(businessType: 'test', query: '{}'),
              Invoice(appId: 'test', cardType: 'test'),
              CustomerServiceChat(corpId: 'test', url: 'https://work.weixin.qq.com/'),
              MiniProgram(username: 'gh_xxxxxxxx'),
              SubscribeMessage(appId: 'test', scene: 1, templateId: 'test'),
            ];
            return targets.map((target) => target.runtimeType.toString()).toList();
          },
        ),
      ],
    );
  }
}
