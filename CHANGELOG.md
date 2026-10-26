## 1.0.0

* 升级 `fluwx` 到 `^6.0.6`，适配 fluwx 6 的 Android、iOS、HarmonyOS（鸿蒙）原生配置。
* SDK 最低要求降至 Dart `^3.11.0`、Flutter `>=3.41.0`，与 fluwx 6 保持一致。
* 破坏性变更：`FlWX` 更名为 `FlWx`，`FlWXCallbackParams` 更名为 `FlWxCallbackParams`。
* 破坏性变更：`WXTokenModel`、`WXUserModel` 分别更名为 `WeChatToken`、`WeChatUserInfo`。
* 破坏性变更：回调类型统一为 `FlWxResponseCallback`、`FlWxSuccessCallback`、`FlWxAuthTokenCallback`、
  `FlWxAuthUserInfoCallback`、`FlWxMessageCallback`、`FlWxHttpCallback`，并移除未使用的
  `FlWeChatResponseTokenCallback`、`FlWeChatResponseUserinfoCallback`。
* 破坏性变更：`shareMiniProgram` 移除未使用的第一个位置参数，改为必填命名参数 `webPageUrl`、`userName`。
* 优化响应监听：收到终止响应后立即释放监听，修复扫码授权过程中监听被提前取消的问题。
* 修复未安装微信时无法发起扫码授权的问题。`openInvoice` 的 `canMultiSelect` 默认值改为 `'1'`，与 fluwx 保持一致。
* 优化授权流程：使用 `Uri` 构造微信接口地址，正确处理参数编码，并补充 `errcode`、`errmsg` 日志。
* 优化支付参数解析：支持大小写字段、`signType`、`extData`，非法时间戳返回 `null` 而不是抛出异常。
* 优化分享默认值：未设置 `appName` 时不再用空字符串覆盖 fluwx 的默认标题。
* 新增 `openMiniProgram` 的 `miniProgramType` 参数，`shareMiniProgram` 的 `miniProgramType`、`hdImageData` 参数，
  以及 `shareImage` 的小程序入口参数。
* 示例升级到 Flutter 3.47.0，Android 使用 Kotlin DSL、AGP 9.1.0、Kotlin 2.4.0，iOS 使用 SPM 与 SceneDelegate。
* 示例 Dart 代码重写为仅依赖 Flutter 与 `fl_wx`，移除 `fl_extended`，按基础、授权、支付、分享、打开、模型分组
  展示全部公开 API 与调用代码，兼容 Flutter 3.41+。
* 补充 README、平台配置说明与单元测试。

## 0.5.1

* 更新版本 `fluwx: ^5.7.5`
* 优化部分回调方法

## 0.4.1

* 更新版本 `fluwx: ^5.7.2`
* 移除 `FlWX().isInstalled` Toast 提示

## 0.4.0

* 更新版本 `fluwx: ^5.7.1`
* 所有回调添加异步等待
* 添加 HarmonyOS（鸿蒙）示例

## 0.2.1

* 更新版本 `fluwx: ^5.3.1`

## 0.2.0

* 更新版本 `fluwx: ^5.0.0`
* 修改部分变量名
* 增加部分参数

## 0.1.0

* Update dependencies

## 0.0.3

* The first version
