part of 'fl_wx.dart';

typedef FlWXWeChatResponse = void Function(WeChatResponse response);

/// Share 回调
typedef FlWXWeChatShareResponse = void Function(WeChatShareResponse response);

/// Auth 回调
typedef FlWXWeChatAuthResponse = Function(WeChatAuthResponse response);

/// Auth token 回调
typedef FlWXWeChatAuthResponseToken = Function(
    WeChatAuthResponse response, WXTokenModel token);

/// Auth userinfo 回调
typedef FlWXWeChatAuthResponseUserinfo = Function(
    WeChatAuthResponse response, WXTokenModel token, WXUserModel userInfo);

/// 显示 toast
typedef FlWXToastBuilder = void Function(String msg);

/// 日志 打印
typedef FlWXLogBuilder = void Function(String msg);

/// http 请求
typedef FlWXHTTPBuilder = Future<String?> Function(String url);

class FlWXBuilderParams {
  FlWXBuilderParams({this.toastBuilder, this.logBuilder, this.httpBuilder});

  /// toast 显示
  final FlWXToastBuilder? toastBuilder;

  /// 日志 打印
  final FlWXLogBuilder? logBuilder;

  /// http 请求 返回 json
  final FlWXHTTPBuilder? httpBuilder;
}

class WXUserModel {
  final String? openid;
  final String? nickname;
  final int? sex;
  final String? language;
  final String? city;
  final String? province;
  final String? country;
  final String? headImgUrl;
  final List<dynamic>? privilege;
  final String? unionId;

  WXUserModel.fromJson(Map<String, dynamic> json)
      : openid = json['openid'] as String?,
        nickname = json['nickname'] as String?,
        sex = json['sex'] as int?,
        language = json['language'] as String?,
        city = json['city'] as String?,
        province = json['province'] as String?,
        country = json['country'] as String?,
        headImgUrl = json['headimgurl'] as String?,
        privilege = json['privilege'] as List<dynamic>?,
        unionId = json['unionid'] as String?;

  Map<String, dynamic> toMap() => {
        'openid': openid,
        'unionId': unionId,
        'nickname': nickname,
        'sex': sex,
        'headImgUrl': headImgUrl,
        'privilege': privilege,
        'language': language,
        'city': city,
        'province': province,
        'country': country,
      };
}

class WXTokenModel {
  final String? accessToken;
  final int? expiresIn;
  final String? refreshToken;
  final String? openid;
  final String? scope;
  final String? unionId;

  WXTokenModel.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'] as String?,
        expiresIn = json['expires_in'] as int?,
        refreshToken = json['refresh_token'] as String?,
        openid = json['openid'] as String?,
        scope = json['scope'] as String?,
        unionId = json['unionid'] as String?;

  Map<String, dynamic> toMap() => {
        'openid': openid,
        'unionId': unionId,
        'accessToken': accessToken,
        'expiresIn': expiresIn,
        'refreshToken': refreshToken,
        'scope': scope
      };
}

extension ExtensionMap on Map {
  Payment? toPayment() {
    try {
      final appId = (this['appId'] ?? this['appid']);
      final partnerId = (this['partnerId'] ??
          this['partnerid'] ??
          this['partner']) as String?;
      final prepayId = (this['prepayId'] ?? this['prepayid'] ?? this['prepay']);
      final packageValue =
          (this['packageValue'] ?? this['packagevalue'] ?? this['package']);
      final nonceStr = (this['nonceStr'] ?? this['noncestr'] ?? this['nonce']);
      final timestamp = (this['timestamp'] ?? this['timeStamp']);
      final sign = (this['sign'] ?? this['sign']);
      if (appId != null &&
          partnerId != null &&
          prepayId != null &&
          packageValue != null &&
          nonceStr != null &&
          timestamp != null &&
          sign != null) {
        return Payment(
            appId: appId.toString(),
            partnerId: partnerId.toString(),
            prepayId: prepayId.toString(),
            packageValue: packageValue.toString(),
            nonceStr: nonceStr.toString(),
            timestamp: int.parse(timestamp!.toString()),
            sign: sign.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
