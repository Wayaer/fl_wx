import 'dart:convert';
import 'dart:typed_data';

/// 分享示例使用的 256x256 PNG 图片。
const String sampleImageBase64 =
    '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';

/// 示例图片字节。
final Uint8List sampleImageBytes = base64Decode(sampleImageBase64);

/// 示例支付参数，可直接通过 toPayment() 转换。
const Map<String, dynamic> samplePaymentMap = {
  'appId': 'test',
  'partnerId': '1900000109',
  'prepayId': 'wx201410272009395522657a690389285100',
  'packageValue': 'Sign=WXPay',
  'nonceStr': '5K8264ILTKCH16CQ2502SI8ZNMTM67VS',
  'timeStamp': '1414561699',
  'sign': 'ABCDEF0123456789',
  'signType': 'MD5',
};

/// 示例 token JSON。
const Map<String, dynamic> sampleTokenJson = {
  'access_token': 'ACCESS_TOKEN',
  'expires_in': 7200,
  'refresh_token': 'REFRESH_TOKEN',
  'openid': 'OPENID',
  'scope': 'snsapi_userinfo',
  'unionid': 'UNIONID',
};

/// 示例用户信息 JSON。
const Map<String, dynamic> sampleUserInfoJson = {
  'openid': 'OPENID',
  'nickname': 'FlWx',
  'sex': 1,
  'language': 'zh_CN',
  'city': 'Shenzhen',
  'province': 'Guangdong',
  'country': 'CN',
  'headimgurl': 'https://example.com/avatar.png',
  'privilege': <String>['one', 'two'],
  'unionid': 'UNIONID',
};

/// 示例授权响应。
const Map<String, dynamic> sampleAuthResponseMap = {
  'errCode': 0,
  'errStr': 'ok',
  'code': 'CODE',
  'state': 'STATE',
  'type': 1,
  'country': 'CN',
  'lang': 'zh_CN',
};

/// 示例分享响应。
const Map<String, dynamic> sampleShareResponseMap = {'errCode': 0, 'errStr': 'ok', 'type': 0};
