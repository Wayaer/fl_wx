import 'package:example/demo/demo_utils.dart';
import 'package:example/demo/samples.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: 'token、用户信息、微信响应模型、回调参数、回调类型与枚举。',
      actions: [
        ApiAction(
          icon: Icons.key_rounded,
          title: 'WeChatToken.fromJson',
          description: '解析授权 token，并判断是否有效。',
          code: r'''final token = WeChatToken.fromJson(sampleTokenJson);
final valid = token.isValid;
final map = token.toMap();''',
          action: () async {
            final token = WeChatToken.fromJson(sampleTokenJson);
            return (valid: token.isValid, expiresIn: token.expiresIn, openid: token.openid, unionId: token.unionId);
          },
        ),
        ApiAction(
          icon: Icons.person_outline_rounded,
          title: 'WeChatUserInfo.fromJson',
          description: '解析授权用户信息，并判断是否有效。',
          code: r'''final userInfo = WeChatUserInfo.fromJson(sampleUserInfoJson);
final valid = userInfo.isValid;
final map = userInfo.toMap();''',
          action: () async {
            final userInfo = WeChatUserInfo.fromJson(sampleUserInfoJson);
            return (valid: userInfo.isValid, nickname: userInfo.nickname, headImgUrl: userInfo.headImgUrl);
          },
        ),
        ApiAction(
          icon: Icons.receipt_rounded,
          title: 'WeChatAuthResponse.fromMap',
          description: '构造授权响应，读取 code、state 和错误信息。',
          code: r'''final response = WeChatAuthResponse.fromMap(sampleAuthResponseMap);
final record = response.toRecord();
final success = response.isSuccessful;''',
          action: () async {
            final response = WeChatAuthResponse.fromMap(sampleAuthResponseMap);
            return (
              success: response.isSuccessful,
              code: response.code,
              state: response.state,
              record: response.toRecord(),
            );
          },
        ),
        ApiAction(
          icon: Icons.share_rounded,
          title: 'WeChatShareResponse + 类型回调',
          description: '把响应传给 FlWxResponseCallback。',
          code: r'''final response = WeChatShareResponse.fromMap(sampleShareResponseMap);
final FlWxResponseCallback<WeChatShareResponse> callback = logResponse;
callback(response);
final success = response.isSuccessful;''',
          action: () async {
            final response = WeChatShareResponse.fromMap(sampleShareResponseMap);
            final FlWxResponseCallback<WeChatShareResponse> callback = logResponse;
            callback(response);
            return response.isSuccessful;
          },
        ),
        ApiAction(
          icon: Icons.tune_rounded,
          title: 'FlWxCallbackParams',
          description: '注册时使用的日志、Toast 和 HTTP 回调配置。',
          code: r'''final params = FlWxCallbackParams(
  onLog: (message) => debugPrint('LOG $message'),
  onToast: (message) => debugPrint('TOAST $message'),
  onHttp: (url) async => null,
);''',
          action: () async {
            final params = FlWxCallbackParams(
              onLog: (message) => debugPrint('LOG $message'),
              onToast: (message) => debugPrint('TOAST $message'),
              onHttp: (url) async => null,
            );
            return (hasLog: params.onLog != null, hasToast: params.onToast != null, hasHttp: params.onHttp != null);
          },
        ),
        ApiAction(
          icon: Icons.list_alt_rounded,
          title: '枚举一览',
          description: '分享场景、小程序类型和扫码授权错误码。',
          code: r'''final scenes = WeChatScene.values.map((e) => e.name).toList();
final types = WXMiniProgramType.values.map((e) => e.name).toList();
final qrErrors = AuthByQRCodeErrorCode.values.map((e) => e.name).toList();''',
          action: () async => (
            scenes: WeChatScene.values.map((value) => value.name).toList(),
            miniProgramTypes: WXMiniProgramType.values.map((value) => value.name).toList(),
            qrErrors: AuthByQRCodeErrorCode.values.map((value) => value.name).toList(),
          ),
        ),
        ApiAction(
          icon: Icons.play_circle_outline_rounded,
          title: '回调类型调用',
          description: 'Message、Success、Http 回调都可以直接作为函数调用。',
          code: r'''final FlWxMessageCallback message = logMessage;
final FlWxSuccessCallback success = logDone;
final FlWxHttpCallback http = httpRequest;

message('hello');
success();
await http('https://example.com');''',
          action: () async {
            final FlWxMessageCallback message = logMessage;
            final FlWxSuccessCallback success = logDone;
            final FlWxHttpCallback http = httpRequest;
            message('hello');
            success();
            await http('https://example.com');
            return '回调已执行';
          },
        ),
        ApiAction(
          icon: Icons.code_rounded,
          title: '回调 typedef 一览',
          description: 'fl_wx 提供的全部回调类型。',
          code: r'''typedef FlWxResponseCallback<T extends WeChatResponse> =
    FutureOr<void> Function(T response);
typedef FlWxSuccessCallback = FutureOr<void> Function();
typedef FlWxAuthTokenCallback = FutureOr<void> Function(
  WeChatAuthResponse response,
  WeChatToken token,
);
typedef FlWxAuthUserInfoCallback = FutureOr<void> Function(
  WeChatAuthResponse response,
  WeChatToken token,
  WeChatUserInfo userInfo,
);
typedef FlWxMessageCallback = FutureOr<void> Function(String message);
typedef FlWxHttpCallback = FutureOr<String?> Function(String url);''',
          action: () async => 'typedef 见上方代码',
        ),
      ],
    );
  }
}
