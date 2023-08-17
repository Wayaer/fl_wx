library fl_wx;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';

export 'package:fluwx/fluwx.dart';

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

class FlWX {
  factory FlWX() => _singleton ??= FlWX._();

  FlWX._();

  static FlWX? _singleton;

  final Fluwx fluWX = Fluwx();

  String? _appId;

  /// 获取当前设置的 appId
  String? get appId => _appId;

  String? _appSecret;

  /// 获取当前设置的 appSecret
  String? get appSecret => _appSecret;

  String _appName = '';
  FlWXBuilderParams? _params;
  WeChatImage? _shareThumbnail;

  /// register
  bool _isRegister = false;

  Future<bool> register({
    required String appId,
    required FlWXBuilderParams params,
    String? universalLink,
    bool doOnIOS = true,
    bool doOnAndroid = true,

    /// 用于获取用户信息
    String? appSecret,
    String appName = '',
    WeChatImage? shareThumbnail,
  }) {
    assert(appId.isNotEmpty);
    if (universalLink != null) assert(universalLink.isNotEmpty);
    if (appSecret != null) {
      assert(appSecret.isNotEmpty);
    }
    _isRegister = true;
    _appId = appId;
    _appSecret = appSecret;
    _appName = appName;
    _shareThumbnail = shareThumbnail;
    _params = params;
    return fluWX.registerApi(
        appId: appId,
        doOnAndroid: doOnAndroid,
        doOnIOS: doOnIOS,
        universalLink: universalLink);
  }

  /// 获取微信 用户token
  String _getTokenUrl(String code) {
    assert(_appId != null &&
        _appId!.isNotEmpty &&
        _appSecret != null &&
        _appSecret!.isNotEmpty);
    return 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=$_appId&secret=$_appSecret&code=$code&grant_type=authorization_code';
  }

  /// 获取微信 用户信息
  String _getUserInfoUrl(String openId, String token) =>
      'https://api.weixin.qq.com/sns/userinfo?access_token=$token&openid=$openId';

  /// 是否安装微信
  Future<bool> get isInstalled async {
    assert(_isRegister, '请先调用 FlWX().register()');
    final installed = await fluWX.isWeChatInstalled;
    if (!installed) _params!.toastBuilder?.call('该服务需要先安装微信');
    return installed;
  }

  /// isSupportOpenBusinessView
  Future<bool> get isSupportOpenBusinessView async {
    if (!await isInstalled) return false;
    return await fluWX.isSupportOpenBusinessView;
  }

  /// 添加移除监听
  FluwxCancelable _onListener(FlWXWeChatResponse onResult) {
    late FluwxCancelable cancelable;
    subscriber(response) {
      onResult(response);
      Future.delayed(const Duration(milliseconds: 500), () {
        cancelable.cancel();
      });
    }

    return cancelable = fluWX.addSubscriber(subscriber);
  }

  Future<String?> getExtMsg() async {
    if (!await isInstalled) return null;
    return await fluWX.getExtMsg();
  }

  Future<void> attemptToResumeMsgFromWx(
      {Function(WeChatShowMessageFromWXRequest response)? onResult}) async {
    if (!await isInstalled) return;
    await fluWX.attemptToResumeMsgFromWx();
    if (onResult != null) {
      _onListener((response) {
        if (response is WeChatShowMessageFromWXRequest) onResult(response);
      });
    }
  }

  /// 调用微信登录
  Future<bool> authBy(
    AuthType which, {
    /// 原始数据回调
    FlWXWeChatAuthResponse? onResult,

    /// 获取token回调
    FlWXWeChatAuthResponseToken? onToken,

    /// 获取userinfo回调
    FlWXWeChatAuthResponseUserinfo? onUserinfo,
    bool getUserInfo = false,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) async {
      if (response is WeChatAuthResponse) {
        onResult?.call(response);
        if (response.isSuccessful && response.code != null) {
          if (onToken != null || onUserinfo != null) {
            try {
              final tokenData = await _params!.httpBuilder
                  ?.call(_getTokenUrl(response.code!));
              if (tokenData == null) {
                _params!.logBuilder?.call('Token 数据获取失败 $tokenData');
                return;
              }
              final token = WXTokenModel.fromJson(jsonDecode(tokenData));
              onToken?.call(response, token);
              if (token.openid == null ||
                  token.openid!.isEmpty ||
                  token.accessToken == null ||
                  token.accessToken!.isEmpty) {
                _params!.logBuilder
                    ?.call('没有获取到 openid 和 accessToken  ${token.toMap()}');
                return;
              }

              if (onUserinfo != null) {
                final userInfoData = await _params!.httpBuilder
                    ?.call(_getUserInfoUrl(token.openid!, token.accessToken!));
                if (userInfoData == null) {
                  _params!.logBuilder?.call('UserInfo 数据获取失败 $userInfoData');
                  return;
                }
                final userInfo = WXUserModel.fromJson(jsonDecode(userInfoData));
                onUserinfo(response, token, userInfo);
              }
            } catch (e) {
              _params!.logBuilder?.call('数据解析失败 $e');
            }
          }
        }
      } else if (response is WeChatAuthByQRCodeFinishedResponse) {}
    });
    final result = await fluWX.authBy(which: which);
    if (!result) {
      cancelable.cancel();
      _params!.toastBuilder?.call('微信授权失败');
    }
    return result;
  }

  Future<bool> autoDeduct(AutoDeduct data,
      {Function(WeChatResponse response)? onResult}) async {
    final cancelable = _onListener((response) {
      onResult?.call(response);
    });
    final result = await fluWX.autoDeduct(data: data);
    if (!result) {
      cancelable.cancel();
      _params!.toastBuilder?.call('微信签约失败');
    }
    return result;
  }

  /// 调用微信支付
  Future<bool> pay(
    PayType which, {
    Function()? onSuccess,
    Function(WeChatPaymentResponse response)? onResult,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatPaymentResponse) {
        onResult?.call(response);
        _params!.logBuilder?.call('微信支付 result code: ${response.errCode} ');
        if (response.errCode == 0) {
          _params!.toastBuilder?.call('支付成功');
          onSuccess?.call();
        } else if (response.errCode == -2) {
          _params!.toastBuilder?.call('已取消支付');
        } else {
          _params!.toastBuilder?.call('支付失败');
        }
      }
    });
    final result = await fluWX.pay(which: which);
    if (!result) {
      cancelable.cancel();
      _params!.toastBuilder?.call('支付失败');
    }
    return result;
  }

  /// ****************** open ****************** ///

  Future<bool> open(OpenType target) async {
    if (!await isInstalled) return false;
    return fluWX.open(target: target);
  }

  Future<bool> openWeChatApp({
    Function(WeChatLaunchFromWXRequest response)? onResult,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatLaunchFromWXRequest) onResult?.call(response);
    });
    final result = await fluWX.open(target: WeChatApp());
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openBrowser(String url) async {
    if (!await isInstalled) return false;
    return fluWX.open(target: Browser(url));
  }

  Future<bool> openRankList() async {
    if (!await isInstalled) return false;
    return fluWX.open(target: RankList());
  }

  Future<bool> openBusinessView({
    required String businessType,
    required String query,
    Function(WeChatOpenBusinessViewResponse response)? onResult,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenBusinessViewResponse) {
        onResult?.call(response);
      }
    });
    final result = await fluWX.open(
        target: BusinessView(businessType: businessType, query: query));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openInvoice({
    required String appId,
    required String cardType,
    String locationId = '',
    String cardId = '',
    String canMultiSelect = '',
    Function(WeChatOpenInvoiceResponse response)? onResult,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenInvoiceResponse) onResult?.call(response);
    });
    final result = await fluWX.open(
        target: Invoice(
            appId: appId,
            cardType: cardType,
            locationId: locationId,
            cardId: cardId,
            canMultiSelect: canMultiSelect));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openCustomerServiceChat({
    required String corpId,
    required String url,
    Function(WeChatOpenCustomerServiceChatResponse response)? onResult,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenCustomerServiceChatResponse) {
        onResult?.call(response);
      }
    });
    final result =
        await fluWX.open(target: CustomerServiceChat(corpId: corpId, url: url));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openMiniProgram(String username,
      {String? path,
      Function(WeChatLaunchMiniProgramResponse response)? onResult}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatLaunchMiniProgramResponse) onResult?.call(response);
    });
    final result =
        await fluWX.open(target: MiniProgram(username: username, path: path));
    if (!result) {
      cancelable.cancel();
      _params?.toastBuilder?.call('小程序打开失败');
    }
    return result;
  }

  Future<bool> openSubscribeMessage(
      {required String appId,
      required int scene,
      required String templateId,
      String? reserved,
      Function(WeChatSubscribeMsgResponse response)? onResult}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatSubscribeMsgResponse) onResult?.call(response);
    });
    final result = await fluWX.open(
        target: SubscribeMessage(
            appId: appId,
            scene: scene,
            templateId: templateId,
            reserved: reserved));
    if (!result) cancelable.cancel();
    return result;
  }

  /// ****************** share ****************** ///

  Future<bool> share(WeChatShareModel what,
      {FlWXWeChatShareResponse? onResult}) async {
    if (!await isInstalled) return false;
    return _shareResponse(fluWX.share(what), onResult: onResult);
  }

  Future<bool> shareText(
    String source, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareTextModel(source,
            title: title ?? _appName,
            description: description ?? _appName,
            scene: scene,
            messageExt: messageExt,
            messageAction: messageAction,
            mediaTagName: mediaTagName,
            msgSignature: msgSignature)),
        onResult: onResult);
  }

  Future<bool> shareMiniProgram(
    String webPage, {
    required String webPageUrl,
    WXMiniProgramType miniProgramType = WXMiniProgramType.release,
    required String userName,
    String path = "/",
    WeChatImage? hdImagePath,
    String? title,
    String? description,
    WeChatImage? thumbnail,
    bool withShareTicket = false,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    assert(thumbnail != null || _shareThumbnail != null);
    if (thumbnail == null && _shareThumbnail == null) return false;
    return _shareResponse(
        fluWX.share(WeChatShareMiniProgramModel(
            webPageUrl: webPageUrl,
            userName: userName,
            title: title ?? _appName,
            description: description ?? _appName,
            thumbnail: (thumbnail ?? _shareThumbnail)!,
            messageExt: messageExt,
            messageAction: messageAction,
            mediaTagName: mediaTagName,
            compressThumbnail: compressThumbnail,
            msgSignature: msgSignature)),
        onResult: onResult);
  }

  Future<bool> shareImage(
    WeChatImage source, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    WeChatImage? thumbnail,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareImageModel(
          source,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          thumbnail: thumbnail ?? _shareThumbnail,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          compressThumbnail: compressThumbnail,
          msgSignature: msgSignature,
        )),
        onResult: onResult);
  }

  Future<bool> shareMusic({
    String? musicUrl,
    String? musicDataUrl,
    String? musicLowBandUrl,
    String? musicLowBandDataUrl,
    WeChatImage? thumbnail,
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareMusicModel(
          musicUrl: musicUrl,
          musicDataUrl: musicDataUrl,
          musicLowBandUrl: musicLowBandUrl,
          musicLowBandDataUrl: musicLowBandDataUrl,
          thumbnail: thumbnail ?? _shareThumbnail,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          compressThumbnail: compressThumbnail,
          msgSignature: msgSignature,
        )),
        onResult: onResult);
  }

  Future<bool> shareVideo(
    String videoUrl, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    WeChatImage? thumbnail,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareVideoModel(
            title: title ?? _appName,
            videoUrl: videoUrl,
            description: description ?? _appName,
            thumbnail: thumbnail ?? _shareThumbnail,
            scene: scene,
            messageExt: messageExt,
            messageAction: messageAction,
            mediaTagName: mediaTagName,
            compressThumbnail: compressThumbnail,
            msgSignature: msgSignature)),
        onResult: onResult);
  }

  Future<bool> shareWebPage(
    String webPage, {
    String? title,
    String? description,
    WeChatImage? thumbnail,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareWebPageModel(webPage,
            title: title ?? _appName,
            description: description ?? _appName,
            thumbnail: thumbnail ?? _shareThumbnail,
            scene: scene,
            messageExt: messageExt,
            messageAction: messageAction,
            mediaTagName: mediaTagName,
            compressThumbnail: compressThumbnail,
            msgSignature: msgSignature)),
        onResult: onResult);
  }

  Future<bool> shareFile(
    File source, {
    required String suffix,
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    WeChatImage? thumbnail,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    bool compressThumbnail = true,
    String? msgSignature,
    FlWXWeChatShareResponse? onResult,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluWX.share(WeChatShareFileModel(
            WeChatFile.file(source, suffix: suffix),
            title: title ?? _appName,
            description: description ?? _appName,
            thumbnail: thumbnail ?? _shareThumbnail,
            scene: scene,
            messageExt: messageExt,
            messageAction: messageAction,
            mediaTagName: mediaTagName,
            compressThumbnail: compressThumbnail,
            msgSignature: msgSignature)),
        onResult: onResult);
  }

  Future<bool> _shareResponse(
    Future<bool> share, {
    FlWXWeChatShareResponse? onResult,
  }) async {
    final cancelable = _onListener((response) {
      if (response is WeChatShareResponse) onResult?.call(response);
    });
    final result = await share;
    if (!result) cancelable.cancel();
    return result;
  }
}

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
