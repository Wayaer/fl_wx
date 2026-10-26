import 'package:example/state/app_state.dart';
import 'package:fl_wx/fl_wx.dart';

/// 示例中复用的单例。
final FlWx wx = FlWx();

/// 注册示例应用，使用占位参数。
Future<bool> registerDemo() async {
  final result = await wx.register(
    appId: 'test',
    universalLink: 'https://test/app/',
    appSecret: 'test-secret',
    appName: 'FlWx Example',
    params: FlWxCallbackParams(onLog: logMessage, onToast: logToast, onHttp: httpRequest),
  );
  AppState.instance.setRegistered(result);
  return result;
}

/// 供 FlWxCallbackParams.onHttp 使用的示例请求。
Future<String?> httpRequest(String url) async {
  AppState.instance.log('HTTP $url', level: LogLevel.action);
  return null;
}

/// 记录普通消息。
void logMessage(String message) {
  AppState.instance.log(message);
}

/// 记录 Toast 消息。
void logToast(String message) {
  AppState.instance.log('TOAST $message', level: LogLevel.action);
}

/// 记录成功消息。
void logSuccess(String message) {
  AppState.instance.log(message, level: LogLevel.success);
}

/// 无参数成功回调示例。
void logDone() => logSuccess('done');

/// 记录微信响应。
void logResponse(WeChatResponse response) {
  AppState.instance.log('RESPONSE ${response.toRecord()}', level: LogLevel.action);
}

/// 记录授权 token。
void logToken(WeChatAuthResponse response, WeChatToken token) {
  AppState.instance.log('TOKEN $token', level: LogLevel.action);
}

/// 记录授权用户信息。
void logUserInfo(WeChatAuthResponse response, WeChatToken token, WeChatUserInfo userInfo) {
  AppState.instance.log('USER $userInfo', level: LogLevel.action);
}
