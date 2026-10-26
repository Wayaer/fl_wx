# fl_wx example

`fl_wx` 的示例工程，包含 Android、iOS、HarmonyOS（鸿蒙）三端配置。Dart 代码仅依赖 Flutter 与 `fl_wx`，
兼容 Flutter 3.41+；原生工程使用 Flutter 3.47 模板。

示例按「基础、授权、支付、分享、打开、模型」分组，覆盖 `fl_wx` 的全部公开 API。每张 API 卡片
都会展示调用代码，点击「运行」即可执行，结果会写入右上角的运行日志面板。

## 运行

```bash
flutter pub get
flutter run
```

## 平台说明

- Android：使用 Flutter 3.47 默认的 Kotlin DSL、AGP 9.1.0、Kotlin 2.4.0，包名为 `com.fl.wx.example`。
- iOS：使用 Flutter 3.47 默认的 Swift Package Manager 和 SceneDelegate，Bundle ID 为 `com.fl.wx.example`。
  已配置微信 URL Scheme、`LSApplicationQueriesSchemes` 和 Associated Domains。
- HarmonyOS（鸿蒙）：由 fluwx 6 原生支持，需使用支持 OHOS 的 Flutter 分支；示例在 `module.json5` 中声明了 `weixin` 查询白名单。

示例中的 `appId`、`universalLink`、`CFBundleURLSchemes`、Associated Domains 均为占位值，
接入真实应用时请替换为微信开放平台申请到的信息。
