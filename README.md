# fl_wx

[![pub package](https://img.shields.io/pub/v/fl_wx.svg)](https://pub.dev/packages/fl_wx)
[![license](https://img.shields.io/github/license/Wayaer/fl_wx)](https://github.com/Wayaer/fl_wx/blob/main/LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20harmonyos-blue)](https://github.com/Wayaer/fl_wx)

[fluwx](https://pub.dev/packages/fluwx) 的简单封装，支持 Android、iOS 和 HarmonyOS（鸿蒙）。在保留 fluwx 全部能力的同时，
统一处理了微信安装判断、响应监听的生命周期、授权后 token 与用户信息的获取，以及默认的日志与 Toast 回调。

## 特性

- 支持 Android、iOS、HarmonyOS（鸿蒙），原生能力由 fluwx 6 提供。
- 单例调用，所有方法均为强类型，并直接导出 fluwx 的类型与模型。
- 自动判断微信是否安装，扫码授权除外。
- 自动注册和释放微信响应监听，避免重复回调与内存泄漏。
- 授权后可通过 `onHttp` 自动获取 token 和用户信息。
- 支持文本、图片、音乐、视频、网页、小程序、文件分享。
- 支持微信支付、自动续费签约、打开小程序、客服、发票、订阅消息等。
- 提供 `Map.toPayment()`，快速把服务端支付参数转换为 `Payment`。

## 环境要求

| 项目 | 版本 |
| --- | --- |
| Flutter | >= 3.41.0 |
| Dart | >= 3.11.0 |
| fluwx | ^6.0.6 |
| Android | minSdk 24 |
| iOS | >= 13.0（示例工程使用 Flutter 默认的 15.0） |
| HarmonyOS（鸿蒙） | fluwx 6 原生支持，需使用支持 OHOS 的 Flutter 分支；示例 `compatibleSdkVersion` 为 `5.0.0(12)` |

## 安装

```yaml
dependencies:
  fl_wx: ^1.0.0
```

## 平台配置

### Android

fluwx 会通过 manifest 合并自动注册 `WXEntryActivity` 和 `WXPayEntryActivity`，无需在项目中重复创建。请确认：

- 已在微信开放平台填写正确的应用包名和签名。
- `minSdk` 不低于 24（微信 SDK 要求，Flutter 3.41+ 默认值已满足）。
- 调试签名与正式签名都能在微信开放平台正常使用。

### iOS

1. 在微信开放平台配置 Universal Link，并在 Xcode 中开启 `Associated Domains`：

   ```xml
   <key>com.apple.developer.associated-domains</key>
   <array>
     <string>applinks:your.universal.link</string>
   </array>
   ```

2. 在 `Info.plist` 中添加微信 App ID 对应的 URL Scheme：

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLName</key>
       <string>weixin</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>wx1234567890</string>
       </array>
     </dict>
   </array>
   ```

3. 在 `Info.plist` 中添加微信相关白名单：

   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>weixin</string>
     <string>wechat</string>
     <string>weixinULAPI</string>
     <string>weixinURLParamsAPI</string>
   </array>
   ```

fluwx 6 同时支持 Swift Package Manager 和 CocoaPods，示例原生工程使用 Flutter 3.47 模板的 SPM 集成方式。

### HarmonyOS（鸿蒙）

fl_wx 依赖的 fluwx 6 已提供 HarmonyOS 原生实现，无需额外接入插件，需使用支持 OHOS 的 Flutter 分支。
为了判断微信是否安装，在 `entry/src/main/module.json5` 的 `module` 节点中添加：

```json5
{
  "module": {
    "querySchemes": [
      "weixin"
    ]
  }
}
```

## 快速开始

```dart
import 'package:fl_wx/fl_wx.dart';

final wx = FlWx();

await wx.register(
  appId: 'wx1234567890',
  universalLink: 'https://example.com/app/',
  appSecret: 'your-app-secret',
  appName: 'My App',
  params: FlWxCallbackParams(
    onLog: debugPrint,
    onToast: (message) => debugPrint(message),
    // 使用项目已有的 HTTP 客户端请求 url，并返回响应体字符串。
    onHttp: (url) async => null,
  ),
);
```

### 登录授权

```dart
final started = await wx.authBy(
  NormalAuth(scope: 'snsapi_userinfo', state: 'your-state'),
  onAuthResponse: (response) {
    // 拿到授权 code。
  },
  onToken: (response, token) {
    // 已通过 onHttp 获取 token。
  },
  onUserInfo: (response, token, userInfo) {
    // 已通过 onHttp 获取用户信息。
  },
);
```

未安装微信时可以使用扫码授权：

```dart
await wx.authBy(
  QRCode(
    appId: 'wx1234567890',
    scope: 'snsapi_userinfo',
    nonceStr: 'nonceStr',
    timestamp: 'timestamp',
    signature: 'signature',
  ),
  onAuthByQRCodeFinishedResponse: (response) {},
);
```

### 支付

```dart
final payment = paymentMap.toPayment();
if (payment != null) {
  await wx.pay(
    payment,
    onSuccess: () {
      // 支付成功。
    },
  );
}
```

`paymentMap` 支持微信服务端返回的 `appId`、`partnerId`、`prepayId`、`packageValue`、`nonceStr`、
`timeStamp`、`sign`、`signType`，同时兼容 `appid`、`partnerid`、`prepayid`、`package` 等小写字段。

### 分享

```dart
await wx.shareText('Hello fl_wx');
await wx.shareWebPage('https://example.com', title: '标题', description: '描述');
await wx.shareImage(WeChatImageToShare(localImagePath: '/path/to/image.png'));
await wx.shareMiniProgram(
  webPageUrl: 'https://example.com',
  userName: 'gh_xxxxxxxx',
  path: '/pages/index',
);
await wx.shareFile(File('/path/to/file.pdf'), suffix: '.pdf');
```

### 打开微信

```dart
await wx.open(WeChatApp());
await wx.openMiniProgram('gh_xxxxxxxx', path: '/pages/index');
await wx.openCustomerServiceChat(corpId: 'corpId', url: 'https://work.weixin.qq.com/...');
```

### 回调

| 回调 | 说明 |
| --- | --- |
| `onToast` | 默认的 Toast 提示 |
| `onLog` | 日志输出，包含授权、支付、数据解析等错误信息 |
| `onHttp` | 授权后请求 token 和用户信息时使用，返回响应体字符串 |

## 从 0.5.x 迁移

1.0.0 统一了命名，旧版本到新版本的主要变化如下：

| 0.5.x | 1.0.0 |
| --- | --- |
| `FlWX` | `FlWx` |
| `FlWXCallbackParams` | `FlWxCallbackParams` |
| `FlWXCallbackString` | `FlWxMessageCallback` |
| `FlWXHTTPCallback` | `FlWxHttpCallback` |
| `FlWeChatResponseCallback` | `FlWxResponseCallback` |
| `FlWeChatPayResponseResultCallback` | `FlWxSuccessCallback` |
| `FlWeChatAuthResponseTokenCallback` | `FlWxAuthTokenCallback` |
| `FlWeChatAuthResponseUserinfoCallback` | `FlWxAuthUserInfoCallback` |
| `WXTokenModel` | `WeChatToken` |
| `WXUserModel` | `WeChatUserInfo` |
| `ExtensionMap` | `WeChatPaymentMapExtension` |

同时移除了未使用的 `FlWeChatResponseTokenCallback` 和 `FlWeChatResponseUserinfoCallback`。

`shareMiniProgram` 移除了未使用的第一个位置参数，改为必填命名参数：

```dart
await wx.shareMiniProgram(
  webPageUrl: 'https://example.com',
  userName: 'gh_xxxxxxxx',
);
```

## 示例

完整示例见 [example](https://github.com/Wayaer/fl_wx/tree/main/example)。示例仅依赖 Flutter 与 `fl_wx`，Dart 代码兼容 Flutter 3.41+，
按基础、授权、支付、分享、打开、模型分组展示全部公开 API 与调用代码，内置运行日志面板。
原生工程包含 Android、iOS、HarmonyOS（鸿蒙）配置。

## License

[MIT](https://github.com/Wayaer/fl_wx/blob/main/LICENSE)
