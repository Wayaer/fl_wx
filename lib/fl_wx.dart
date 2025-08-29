import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluwx/fluwx.dart';

export 'package:fluwx/fluwx.dart';

typedef FlWeChatResponseCallback = void Function(WeChatResponse response);

/// 支持成功
typedef FlWeChatPayResponseResultCallback = void Function();

/// 支付结果回调
typedef FlWeChatPayResponseCallback = void Function(WeChatPaymentResponse response);

/// LaunchFromWX 回调
typedef FlWeChatLaunchFromWXRequestCallback = void Function(WeChatLaunchFromWXRequest response);

/// OpenBusinessWebView 回调
typedef FlWeChatOpenBusinessWebViewResponseCallback = void Function(WeChatOpenBusinessWebviewResponse response);

/// WeChatOpenBusinessView 回调
typedef FlWeChatOpenBusinessViewResponseCallback = void Function(WeChatOpenBusinessViewResponse response);

/// Share 回调
typedef FlWeChatShareResponseCallback = void Function(WeChatShareResponse response);

/// Auth 回调
typedef FlWeChatAuthResponseCallback = Function(WeChatAuthResponse response);

/// Auth token 回调
typedef FlWeChatAuthResponseTokenCallback = Function(WeChatAuthResponse response, WXTokenModel token);

/// Auth userinfo 回调
typedef FlWeChatAuthResponseUserinfoCallback = Function(
    WeChatAuthResponse response, WXTokenModel token, WXUserModel userInfo);

typedef FlWXCallbackString = void Function(String msg);

/// http 请求
typedef FlWXHTTPCallback = Future<String?> Function(String url);

class FlWX {
  factory FlWX() => _singleton ??= FlWX._();

  FlWX._();

  static FlWX? _singleton;

  static FlWX get instance => FlWX();

  final Fluwx _fluwx = Fluwx();

  Fluwx get fluwx => _fluwx;

  String? _appId;

  /// 获取当前设置的 appId
  String? get appId => _appId;

  String? _appSecret;

  /// 获取当前设置的 appSecret
  String? get appSecret => _appSecret;

  String _appName = '';

  /// callback params
  FlWXCallbackParams? _params;

  /// 分享时的缩略图
  Uint8List? _shareThumbnail;

  /// register
  bool _isRegister = false;

  Future<bool> register({
    required String appId,
    required FlWXCallbackParams params,
    String? universalLink,
    bool doOnIOS = true,
    bool doOnAndroid = true,

    /// 用于获取用户信息
    String? appSecret,

    /// app名称（用于分享时使用）
    String appName = '',

    /// 分享时的缩略图
    Uint8List? shareThumbnail,
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
    return fluwx.registerApi(appId: appId, doOnAndroid: doOnAndroid, doOnIOS: doOnIOS, universalLink: universalLink);
  }

  /// 获取微信 用户token
  String _getTokenUrl(String code) {
    assert(_appId != null && _appId!.isNotEmpty && _appSecret != null && _appSecret!.isNotEmpty);
    return 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=$_appId&secret=$_appSecret&code=$code&grant_type=authorization_code';
  }

  /// 获取微信 用户信息
  String _getUserInfoUrl(String openId, String token) =>
      'https://api.weixin.qq.com/sns/userinfo?access_token=$token&openid=$openId';

  /// 是否安装微信
  Future<bool> get isInstalled async {
    assert(_isRegister, '请先调用 FlWX().register()');
    final installed = await fluwx.isWeChatInstalled;
    if (!installed) _params!.onToast?.call('该服务需要先安装微信');
    return installed;
  }

  /// isSupportOpenBusinessView
  Future<bool> get isSupportOpenBusinessView async {
    if (!await isInstalled) return false;
    return await fluwx.isSupportOpenBusinessView;
  }

  /// 添加移除监听
  FluwxCancelable _onListener(FlWeChatResponseCallback onResponse) {
    late FluwxCancelable cancelable;
    subscriber(response) {
      onResponse(response);
      Future.delayed(const Duration(milliseconds: 500), () {
        cancelable.cancel();
      });
    }

    return cancelable = fluwx.addSubscriber(subscriber);
  }

  Future<String?> getExtMsg() async {
    if (!await isInstalled) return null;
    return await fluwx.getExtMsg();
  }

  Future<void> attemptToResumeMsgFromWx({Function(WeChatShowMessageFromWXRequest response)? onResponse}) async {
    if (!await isInstalled) return;
    await fluwx.attemptToResumeMsgFromWx();
    if (onResponse != null) {
      _onListener((response) {
        if (response is WeChatShowMessageFromWXRequest) onResponse(response);
      });
    }
  }

  /// 调用微信登录
  Future<bool> authBy(
    AuthType which, {
    /// 原始数据回调
    FlWeChatAuthResponseCallback? onResponse,

    /// 获取token回调
    FlWeChatAuthResponseTokenCallback? onToken,

    /// 获取userinfo回调
    FlWeChatAuthResponseUserinfoCallback? onUserinfo,
    bool getUserInfo = false,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) async {
      if (response is WeChatAuthResponse) {
        onResponse?.call(response);
        if (response.isSuccessful && response.code != null) {
          if (onToken != null || onUserinfo != null) {
            try {
              final tokenData = await _params!.onHttp?.call(_getTokenUrl(response.code!));
              if (tokenData == null) {
                _params!.onLog?.call('Token 数据获取失败 $tokenData');
                return;
              }
              final token = WXTokenModel.fromJson(jsonDecode(tokenData));
              onToken?.call(response, token);
              if (token.openid == null ||
                  token.openid!.isEmpty ||
                  token.accessToken == null ||
                  token.accessToken!.isEmpty) {
                _params!.onLog?.call('没有获取到 openid 和 accessToken ${token.toMap()}');
                return;
              }

              if (onUserinfo != null) {
                final userInfoData = await _params!.onHttp?.call(_getUserInfoUrl(token.openid!, token.accessToken!));
                if (userInfoData == null) {
                  _params!.onLog?.call('UserInfo 数据获取失败 $userInfoData');
                  return;
                }
                final userInfo = WXUserModel.fromJson(jsonDecode(userInfoData));
                onUserinfo(response, token, userInfo);
              }
            } catch (e) {
              _params!.onLog?.call('数据解析失败 $e');
            }
          }
        }
      } else if (response is WeChatAuthByQRCodeFinishedResponse) {}
    });
    final result = await fluwx.authBy(which: which);
    if (!result) {
      cancelable.cancel();
      _params!.onToast?.call('微信授权失败');
    }
    return result;
  }

  Future<bool> autoDeduct(AutoDeduct data, {FlWeChatResponseCallback? onResponse}) async {
    final cancelable = _onListener((response) {
      onResponse?.call(response);
    });
    final result = await fluwx.autoDeduct(data: data);
    if (!result) {
      cancelable.cancel();
      _params!.onToast?.call('微信签约失败');
    }
    return result;
  }

  /// 调用微信支付
  Future<bool> pay(
    PayType which, {
    FlWeChatPayResponseResultCallback? onSuccess,
    FlWeChatPayResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatPaymentResponse) {
        onResponse?.call(response);
        _params!.onLog?.call('微信支付 result code: ${response.errCode} ');
        if (response.errCode == 0) {
          _params!.onToast?.call('支付成功');
          onSuccess?.call();
        } else if (response.errCode == -2) {
          _params!.onToast?.call('已取消支付');
        } else {
          _params!.onToast?.call('支付失败');
        }
      }
    });
    final result = await fluwx.pay(which: which);
    if (!result) {
      cancelable.cancel();
      _params!.onToast?.call('支付失败');
    }
    return result;
  }

  /// ****************** open ****************** ///

  Future<bool> open(OpenType target) async {
    if (!await isInstalled) return false;
    return fluwx.open(target: target);
  }

  Future<bool> openWeChatApp({FlWeChatLaunchFromWXRequestCallback? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatLaunchFromWXRequest) onResponse?.call(response);
    });
    final result = await fluwx.open(target: WeChatApp());
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openBrowser(String url, {FlWeChatOpenBusinessWebViewResponseCallback? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenBusinessWebviewResponse) {
        onResponse?.call(response);
      }
    });
    final result = await fluwx.open(target: Browser(url));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openRankList() async {
    if (!await isInstalled) return false;
    return fluwx.open(target: RankList());
  }

  Future<bool> openBusinessView({
    required String businessType,
    required String query,
    FlWeChatOpenBusinessViewResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenBusinessViewResponse) {
        onResponse?.call(response);
      }
    });
    final result = await fluwx.open(target: BusinessView(businessType: businessType, query: query));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openInvoice({
    required String appId,
    required String cardType,
    String locationId = '',
    String cardId = '',
    String canMultiSelect = '',
    Function(WeChatOpenInvoiceResponse response)? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenInvoiceResponse) onResponse?.call(response);
    });
    final result = await fluwx.open(
        target: Invoice(
            appId: appId, cardType: cardType, locationId: locationId, cardId: cardId, canMultiSelect: canMultiSelect));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openCustomerServiceChat({
    required String corpId,
    required String url,
    Function(WeChatOpenCustomerServiceChatResponse response)? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatOpenCustomerServiceChatResponse) {
        onResponse?.call(response);
      }
    });
    final result = await fluwx.open(target: CustomerServiceChat(corpId: corpId, url: url));
    if (!result) cancelable.cancel();
    return result;
  }

  Future<bool> openMiniProgram(String username,
      {String? path, Function(WeChatLaunchMiniProgramResponse response)? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatLaunchMiniProgramResponse) {
        onResponse?.call(response);
      }
    });
    final result = await fluwx.open(target: MiniProgram(username: username, path: path));
    if (!result) {
      cancelable.cancel();
      _params?.onToast?.call('小程序打开失败');
    }
    return result;
  }

  Future<bool> openSubscribeMessage(
      {required String appId,
      required int scene,
      required String templateId,
      String? reserved,
      Function(WeChatSubscribeMsgResponse response)? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _onListener((response) {
      if (response is WeChatSubscribeMsgResponse) onResponse?.call(response);
    });
    final result = await fluwx.open(
        target: SubscribeMessage(appId: appId, scene: scene, templateId: templateId, reserved: reserved));
    if (!result) cancelable.cancel();
    return result;
  }

  /// ****************** share ****************** ///

  Future<bool> share(WeChatShareModel what, {FlWeChatShareResponseCallback? onResponse}) async {
    if (!await isInstalled) return false;
    return _shareResponse(fluwx.share(what), onResponse: onResponse);
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
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareTextModel(
          source,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareMiniProgram(
    String webPage, {
    required String webPageUrl,
    WXMiniProgramType miniProgramType = WXMiniProgramType.release,
    required String userName,
    String path = "/",
    String? title,
    String? description,
    bool withShareTicket = false,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareMiniProgramModel(
          webPageUrl: webPageUrl,
          userName: userName,
          title: title ?? _appName,
          description: description ?? _appName,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareImage(
    WeChatImageToShare source, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareImageModel(
          source,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareMusic({
    String? musicUrl,
    String? musicDataUrl,
    String? musicLowBandUrl,
    String? musicLowBandDataUrl,
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareMusicModel(
          musicUrl: musicUrl,
          musicDataUrl: musicDataUrl,
          musicLowBandUrl: musicLowBandUrl,
          musicLowBandDataUrl: musicLowBandDataUrl,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareVideo(
    String videoUrl, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareVideoModel(
          title: title ?? _appName,
          videoUrl: videoUrl,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareWebPage(
    String webPage, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareWebPageModel(
          webPage,
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> shareFile(
    File source, {
    required String suffix,
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
        fluwx.share(WeChatShareFileModel(
          WeChatFile.file(source, suffix: suffix),
          title: title ?? _appName,
          description: description ?? _appName,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        )),
        onResponse: onResponse);
  }

  Future<bool> _shareResponse(
    Future<bool> share, {
    FlWeChatShareResponseCallback? onResponse,
  }) async {
    final cancelable = _onListener((response) {
      if (response is WeChatShareResponse) onResponse?.call(response);
    });
    final result = await share;
    if (!result) cancelable.cancel();
    return result;
  }
}

class FlWXCallbackParams {
  FlWXCallbackParams({this.onToast, this.onLog, this.onHttp});

  /// toast 显示
  final FlWXCallbackString? onToast;

  /// 日志 打印
  final FlWXCallbackString? onLog;

  /// http 请求 返回 json
  final FlWXHTTPCallback? onHttp;
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
      final partnerId = (this['partnerId'] ?? this['partnerid'] ?? this['partner']) as String?;
      final prepayId = (this['prepayId'] ?? this['prepayid'] ?? this['prepay']);
      final packageValue = (this['packageValue'] ?? this['packagevalue'] ?? this['package']);
      final nonceStr = (this['nonceStr'] ?? this['noncestr'] ?? this['nonce']);
      final timestamp = (this['timestamp'] ?? this['timeStamp']);
      final sign = this['sign'];
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
      FlWX()._params?.onLog?.call(e.toString());
    }
    return null;
  }
}
