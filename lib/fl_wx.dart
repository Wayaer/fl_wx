import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluwx/fluwx.dart';

export 'package:fluwx/fluwx.dart';

/// 微信响应回调。
///
/// [T] 为需要接收的响应类型，例如 [WeChatShareResponse]。
/// 回调可以返回 `Future`，框架会等待其执行完成后再释放监听。
typedef FlWxResponseCallback<T extends WeChatResponse> = FutureOr<void> Function(T response);

/// 无参数回调，例如支付成功、签约成功等场景。
typedef FlWxSuccessCallback = FutureOr<void> Function();

/// 授权成功后拿到 token 的回调。
///
/// [response] 为本次授权响应，[token] 为通过 [FlWxCallbackParams.onHttp] 获取到的 token。
typedef FlWxAuthTokenCallback = FutureOr<void> Function(WeChatAuthResponse response, WeChatToken token);

/// 授权成功后拿到用户信息的回调。
///
/// [response] 为本次授权响应，[token] 为 token，[userInfo] 为通过
/// [FlWxCallbackParams.onHttp] 获取到的用户信息。
typedef FlWxAuthUserInfoCallback =
    FutureOr<void> Function(WeChatAuthResponse response, WeChatToken token, WeChatUserInfo userInfo);

/// 字符串消息回调，用于 Toast、日志等场景。
///
/// [message] 为要显示或记录的内容。
typedef FlWxMessageCallback = FutureOr<void> Function(String message);

/// HTTP 请求回调，用于获取微信 token 和用户信息。
///
/// [url] 为已经编码好的请求地址，返回响应体字符串；返回 null 表示请求失败。
typedef FlWxHttpCallback = FutureOr<String?> Function(String url);

/// [fluwx](https://pub.dev/packages/fluwx) 的简单封装，支持 Android、iOS 和 HarmonyOS（鸿蒙）。
///
/// FlWx 是单例，所有方法共享同一份注册配置。
/// 统一处理了微信是否安装的判断、响应监听的注册与释放、授权后 token 与用户信息的获取，
/// 以及默认的 Toast / 日志回调。
///
/// ```dart
/// FlWx().register(
///   appId: 'wx1234567890',
///   universalLink: 'https://example.com/app/',
///   params: FlWxCallbackParams(
///     onLog: (message) => debugPrint(message),
///     onToast: (message) => debugPrint(message),
///   ),
/// );
/// ```
class FlWx {
  /// 获取 [FlWx] 单例，等价于 [FlWx.instance]。
  factory FlWx() => instance;

  FlWx._();

  /// 全局单例，所有调用共享同一份注册信息和响应监听。
  static final FlWx instance = FlWx._();

  /// 底层 fluwx 实例，首次访问 [FlWx] 时创建。
  final Fluwx _fluwx = Fluwx();

  /// 底层 fluwx 实例，用于调用本封装未覆盖的能力。
  Fluwx get fluwx => _fluwx;

  String? _appId;

  /// 当前设置的 appId，未调用 [register] 时为 null。
  String? get appId => _appId;

  String? _appSecret;

  /// 当前设置的 appSecret，用于授权后获取 token；未设置时为 null。
  String? get appSecret => _appSecret;

  String _appName = '';

  /// 当前设置的 appName，分享时作为默认标题；未设置时为空字符串。
  String get appName => _appName;

  /// 当前回调配置，未调用 [register] 时使用空配置。
  FlWxCallbackParams _params = const FlWxCallbackParams();

  /// 分享时使用的默认缩略图，未设置时为 null。
  Uint8List? _shareThumbnail;

  /// 分享时使用的默认标题，未设置 appName 时返回 null，交给 fluwx 使用默认值。
  String? get _shareTitle => _appName.isEmpty ? null : _appName;

  /// 注册微信开放平台应用。
  ///
  /// 重复调用是安全的，后一次会覆盖前一次的配置。
  ///
  /// - [appId]：微信开放平台申请的应用 ID，不能为空。
  /// - [params]：日志、Toast、HTTP 回调配置。
  /// - [universalLink]：iOS Universal Link，iOS 注册时必填。
  /// - [doOnIOS]：是否在 iOS 端执行注册，默认 true。
  /// - [doOnAndroid]：是否在 Android 端执行注册，默认 true。
  /// - [appSecret]：应用密钥，授权后获取 token 和用户信息时使用。
  /// - [appName]：应用名称，分享时作为默认标题。
  /// - [shareThumbnail]：默认分享缩略图字节。
  ///
  /// 返回是否注册成功；[appId]、[universalLink]、[appSecret] 为空时会抛出 [ArgumentError]。
  Future<bool> register({
    required String appId,
    FlWxCallbackParams params = const FlWxCallbackParams(),
    String? universalLink,
    bool doOnIOS = true,
    bool doOnAndroid = true,
    String? appSecret,
    String appName = '',
    Uint8List? shareThumbnail,
  }) {
    if (appId.isEmpty) {
      throw ArgumentError.value(appId, 'appId', '不能为空');
    }
    if (universalLink != null && universalLink.isEmpty) {
      throw ArgumentError.value(universalLink, 'universalLink', '不能为空');
    }
    if (appSecret != null && appSecret.isEmpty) {
      throw ArgumentError.value(appSecret, 'appSecret', '不能为空');
    }
    _appId = appId;
    _appSecret = appSecret;
    _appName = appName;
    _shareThumbnail = shareThumbnail;
    _params = params;
    return _fluwx.registerApi(appId: appId, doOnAndroid: doOnAndroid, doOnIOS: doOnIOS, universalLink: universalLink);
  }

  /// 微信是否已安装。
  ///
  /// 返回 true 表示设备已安装微信。iOS 需要在 Info.plist 中配置
  /// `LSApplicationQueriesSchemes`，否则可能始终返回 false。
  Future<bool> get isInstalled => _fluwx.isWeChatInstalled;

  /// 是否支持打开微信业务视图。
  ///
  /// 返回 true 表示当前微信版本支持业务视图（如发票、线下支付等）。
  Future<bool> get isSupportOpenBusinessView => _fluwx.isSupportOpenBusinessView;

  /// 获取微信打开 App 时携带的扩展消息。
  ///
  /// 未安装微信或没有扩展消息时返回 null。读取后微信侧的消息会被清空。
  Future<String?> getExtMsg() async {
    if (!await isInstalled) return null;
    return _fluwx.getExtMsg();
  }

  /// 冷启动时尝试恢复微信打开 App 时携带的消息。
  ///
  /// [onResponse] 接收 [WeChatShowMessageFromWXRequest]，仅在 App 被微信拉起时触发。
  Future<void> attemptToResumeMsgFromWx({FlWxResponseCallback<WeChatShowMessageFromWXRequest>? onResponse}) async {
    _subscribeFor(onResponse);
    await _fluwx.attemptToResumeMsgFromWx();
  }

  /// 调用微信授权。
  ///
  /// [which] 支持三种授权方式：
  /// - [NormalAuth]：拉起微信原生授权，可设置 scope、state 和 nonAutomatic。
  /// - [QRCode]：扫码授权，适用于未安装微信的设备，不需要判断微信是否安装。
  /// - [PhoneLogin]：手机号授权，目前仅支持 iOS。
  ///
  /// 回调说明：
  /// - [onResponse]：接收全部授权相关响应，包括扫码过程中的中间响应。
  /// - [onAuthResponse]：仅接收 [WeChatAuthResponse]。
  /// - [onAuthByQRCodeFinishedResponse]：仅接收 [WeChatAuthByQRCodeFinishedResponse]。
  /// - [onToken]：授权成功后自动获取 token 时触发，需要在 [register] 时传入 [appSecret]，
  ///   并配置 [FlWxCallbackParams.onHttp]。
  /// - [onUserInfo]：获取用户信息时触发，同样依赖 [appSecret] 和
  ///   [FlWxCallbackParams.onHttp]。
  ///
  /// 返回是否成功向微信发起授权请求。
  Future<bool> authBy(
    AuthType which, {
    FlWxResponseCallback<WeChatResponse>? onResponse,
    FlWxResponseCallback<WeChatAuthResponse>? onAuthResponse,
    FlWxResponseCallback<WeChatAuthByQRCodeFinishedResponse>? onAuthByQRCodeFinishedResponse,
    FlWxAuthTokenCallback? onToken,
    FlWxAuthUserInfoCallback? onUserInfo,
  }) async {
    // 扫码授权用于未安装微信的场景，不需要判断是否安装。
    if (which is! QRCode && !await isInstalled) return false;
    final hasAuthCallback = onResponse != null || onAuthResponse != null || onToken != null || onUserInfo != null;
    final hasQrCodeCallback = onAuthByQRCodeFinishedResponse != null;
    // 只监听授权响应和扫码完成响应，收到终止响应后自动释放监听。
    final cancelable = hasAuthCallback || hasQrCodeCallback
        ? _subscribe((response) async {
            await onResponse?.call(response);
            if (response is WeChatAuthResponse) {
              await onAuthResponse?.call(response);
              if (!response.isSuccessful || response.code == null) {
                _log('授权失败 ${response.errCode} ${response.errStr}');
                return;
              }
              await _loadAuthInfo(response, onToken: onToken, onUserInfo: onUserInfo);
            } else if (response is WeChatAuthByQRCodeFinishedResponse) {
              await onAuthByQRCodeFinishedResponse?.call(response);
            }
          }, cancelWhen: (response) => response is WeChatAuthResponse || response is WeChatAuthByQRCodeFinishedResponse)
        : const _NoopCancelable();
    final result = await _fluwx.authBy(which: which);
    if (!result) {
      cancelable.cancel();
      _toast('微信授权失败');
    }
    return result;
  }

  /// 自动续费签约。
  ///
  /// [data] 支持 [AutoDeduct.detail] 和 [AutoDeduct.custom] 两种构造方式。
  /// [onResponse] 接收签约结果。
  /// 返回是否成功发起签约请求；未安装微信时直接返回 false。
  Future<bool> autoDeduct(AutoDeduct data, {FlWxResponseCallback<WeChatResponse>? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.autoDeduct(data: data);
    if (!result) {
      cancelable.cancel();
      _toast('微信签约失败');
    }
    return result;
  }

  /// 调用微信支付。
  ///
  /// [which] 支持 [Payment]（普通微信支付）和 [HongKongWallet]（香港钱包支付）。
  /// [onSuccess] 仅在微信返回成功（errCode == 0）时触发。
  /// [onResponse] 接收支付响应，可用于处理取消（errCode == -2）和失败。
  ///
  /// 返回是否成功向微信发起支付请求；未安装微信时直接返回 false。
  Future<bool> pay(
    PayType which, {
    FlWxSuccessCallback? onSuccess,
    FlWxResponseCallback<WeChatPaymentResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribe((response) async {
      if (response is! WeChatPaymentResponse) return;
      await onResponse?.call(response);
      _log('微信支付 result code: ${response.errCode} ${response.errStr}');
      if (response.isSuccessful) {
        _toast('支付成功');
        await onSuccess?.call();
      } else if (response.errCode == -2) {
        _toast('已取消支付');
      } else {
        _toast('支付失败');
      }
    }, cancelWhen: (response) => response is WeChatPaymentResponse);
    final result = await _fluwx.pay(which: which);
    if (!result) {
      cancelable.cancel();
      _toast('支付失败');
    }
    return result;
  }

  /// 打开微信或微信内的目标页面。
  ///
  /// [target] 可以是 [WeChatApp]、[Browser]、[RankList]、[BusinessView]、
  /// [Invoice]、[CustomerServiceChat]、[MiniProgram]、[SubscribeMessage]。
  /// 返回是否成功发起打开请求；未安装微信时直接返回 false。
  Future<bool> open(OpenType target) async {
    if (!await isInstalled) return false;
    return _fluwx.open(target: target);
  }

  /// 打开微信，并监听微信拉起 App 时携带的参数。
  ///
  /// [onResponse] 接收 [WeChatLaunchFromWXRequest]，可用于处理从微信返回 App 的场景。
  /// 返回是否成功打开微信。
  Future<bool> openWeChatApp({FlWxResponseCallback<WeChatLaunchFromWXRequest>? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(target: WeChatApp());
    if (!result) cancelable.cancel();
    return result;
  }

  /// 使用微信内置浏览器打开网页。
  ///
  /// [url] 为要打开的网页地址；[onResponse] 接收 [WeChatOpenBusinessWebviewResponse]。
  /// 返回是否成功打开。
  Future<bool> openBrowser(String url, {FlWxResponseCallback<WeChatOpenBusinessWebviewResponse>? onResponse}) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(target: Browser(url));
    if (!result) cancelable.cancel();
    return result;
  }

  /// 打开微信排行榜。
  ///
  /// 返回是否成功打开；未安装微信时直接返回 false。
  Future<bool> openRankList() async {
    if (!await isInstalled) return false;
    return _fluwx.open(target: RankList());
  }

  /// 打开微信业务视图。
  ///
  /// [businessType] 为业务类型，[query] 为业务参数（通常是 JSON 字符串）。
  /// [onResponse] 接收 [WeChatOpenBusinessViewResponse]。
  /// 返回是否成功打开。
  Future<bool> openBusinessView({
    required String businessType,
    required String query,
    FlWxResponseCallback<WeChatOpenBusinessViewResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(
      target: BusinessView(businessType: businessType, query: query),
    );
    if (!result) cancelable.cancel();
    return result;
  }

  /// 打开微信发票。
  ///
  /// - [appId]：发票 AppID。
  /// - [cardType]：发票类型。
  /// - [locationId]：发票位置 ID，可选。
  /// - [cardId]：发票 Card ID，可选。
  /// - [canMultiSelect]：是否支持多选，默认 "1"。
  /// - [onResponse]：接收 [WeChatOpenInvoiceResponse]。
  ///
  /// 返回是否成功打开。
  Future<bool> openInvoice({
    required String appId,
    required String cardType,
    String locationId = '',
    String cardId = '',
    String canMultiSelect = '1',
    FlWxResponseCallback<WeChatOpenInvoiceResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(
      target: Invoice(
        appId: appId,
        cardType: cardType,
        locationId: locationId,
        cardId: cardId,
        canMultiSelect: canMultiSelect,
      ),
    );
    if (!result) cancelable.cancel();
    return result;
  }

  /// 打开微信客服会话。
  ///
  /// [corpId] 为企业 ID，[url] 为客服链接；[onResponse] 接收
  /// [WeChatOpenCustomerServiceChatResponse]。
  /// 返回是否成功打开。
  Future<bool> openCustomerServiceChat({
    required String corpId,
    required String url,
    FlWxResponseCallback<WeChatOpenCustomerServiceChatResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(
      target: CustomerServiceChat(corpId: corpId, url: url),
    );
    if (!result) cancelable.cancel();
    return result;
  }

  /// 打开微信小程序。
  ///
  /// [username] 为小程序原始 ID，[path] 为页面路径，
  /// [miniProgramType] 指定正式版、测试版或预览版。
  /// [onResponse] 接收 [WeChatLaunchMiniProgramResponse]。
  /// 返回是否成功打开；失败时会触发 Toast。
  Future<bool> openMiniProgram(
    String username, {
    String? path,
    WXMiniProgramType miniProgramType = WXMiniProgramType.release,
    FlWxResponseCallback<WeChatLaunchMiniProgramResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(
      target: MiniProgram(username: username, path: path, miniProgramType: miniProgramType),
    );
    if (!result) {
      cancelable.cancel();
      _toast('小程序打开失败');
    }
    return result;
  }

  /// 打开微信订阅消息。
  ///
  /// - [appId]：订阅消息 AppID。
  /// - [scene]：订阅场景值。
  /// - [templateId]：订阅消息模板 ID。
  /// - [reserved]：保留字段，可选。
  /// - [onResponse]：接收 [WeChatSubscribeMsgResponse]。
  ///
  /// 返回是否成功打开。
  Future<bool> openSubscribeMessage({
    required String appId,
    required int scene,
    required String templateId,
    String? reserved,
    FlWxResponseCallback<WeChatSubscribeMsgResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    final cancelable = _subscribeFor(onResponse);
    final result = await _fluwx.open(
      target: SubscribeMessage(appId: appId, scene: scene, templateId: templateId, reserved: reserved),
    );
    if (!result) cancelable.cancel();
    return result;
  }

  /// 分享任意 [WeChatShareModel]。
  ///
  /// [what] 可以是 [WeChatShareTextModel]、[WeChatShareImageModel]、
  /// [WeChatShareMusicModel]、[WeChatShareVideoModel]、[WeChatShareWebPageModel]、
  /// [WeChatShareMiniProgramModel]、[WeChatShareFileModel]、[WeChatShareEmojiModel]。
  /// [onResponse] 接收 [WeChatShareResponse]。
  /// 返回是否成功向微信发起分享请求。
  Future<bool> share(WeChatShareModel what, {FlWxResponseCallback<WeChatShareResponse>? onResponse}) async {
    if (!await isInstalled) return false;
    return _shareResponse(() => _fluwx.share(what), onResponse: onResponse);
  }

  /// 分享文本。
  ///
  /// [source] 为文本内容。
  /// [title]、[description] 为空时使用 [appName] 作为默认值。
  /// [scene] 为分享目标，默认会话，可选朋友圈、收藏。
  /// [messageExt]、[messageAction]、[mediaTagName]、[msgSignature] 为微信扩展字段。
  /// [thumbData] 为缩略图字节，默认使用 [register] 时传入的 shareThumbnail。
  /// [thumbDataHash] 为缩略图哈希。
  /// [onResponse] 接收 [WeChatShareResponse]。
  /// 返回是否成功发起分享；未安装微信时直接返回 false。
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
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareTextModel(
          source,
          title: title ?? _shareTitle,
          description: description ?? _shareTitle,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享小程序。
  ///
  /// - [webPageUrl]：小程序卡片点击后的网页地址。
  /// - [userName]：小程序原始 ID。
  /// - [path]：小程序页面路径，默认 "/"。
  /// - [miniProgramType]：正式版、测试版或预览版。
  /// - [title]、[description]：卡片标题和描述，默认使用 [appName]。
  /// - [withShareTicket]：是否携带 shareTicket。
  /// - [hdImageData]：高清卡片图字节。
  /// - [messageExt]、[messageAction]、[mediaTagName]、[msgSignature]：微信扩展字段。
  /// - [thumbData]、[thumbDataHash]：缩略图和哈希。
  /// - [onResponse]：接收 [WeChatShareResponse]。
  ///
  /// 返回是否成功发起分享。
  Future<bool> shareMiniProgram({
    required String webPageUrl,
    required String userName,
    String path = '/',
    WXMiniProgramType miniProgramType = WXMiniProgramType.release,
    String? title,
    String? description,
    bool withShareTicket = false,
    Uint8List? hdImageData,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareMiniProgramModel(
          webPageUrl: webPageUrl,
          userName: userName,
          path: path,
          miniProgramType: miniProgramType,
          title: title ?? _shareTitle,
          description: description ?? _shareTitle,
          withShareTicket: withShareTicket,
          hdImageData: hdImageData,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享图片。
  ///
  /// [source] 为 [WeChatImageToShare]，可传 uint8List、localImagePath 等。
  /// [title]、[description] 为空时使用 [appName]。
  /// [scene] 为分享目标。
  /// [entranceMiniProgramUsername]、[entranceMiniProgramPath] 用于配置图片右下角的小程序入口。
  /// [messageExt]、[messageAction]、[mediaTagName]、[msgSignature] 为扩展字段。
  /// [thumbData]、[thumbDataHash] 为缩略图和哈希。
  /// [onResponse] 接收 [WeChatShareResponse]。
  /// 返回是否成功发起分享。
  Future<bool> shareImage(
    WeChatImageToShare source, {
    String? title,
    String? description,
    WeChatScene scene = WeChatScene.session,
    String? entranceMiniProgramUsername,
    String? entranceMiniProgramPath,
    String? messageExt,
    String? messageAction,
    String? mediaTagName,
    String? msgSignature,
    Uint8List? thumbData,
    String? thumbDataHash,
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareImageModel(
          source,
          title: title ?? _shareTitle,
          description: description ?? _shareTitle,
          scene: scene,
          entranceMiniProgramUsername: entranceMiniProgramUsername,
          entranceMiniProgramPath: entranceMiniProgramPath,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享音乐。
  ///
  /// [musicUrl] 和 [musicLowBandUrl] 至少提供一个，否则抛出 [ArgumentError]。
  /// [musicDataUrl]、[musicLowBandDataUrl] 为低带宽数据地址。
  /// [title]、[description]、[scene]、[messageExt]、[messageAction]、
  /// [mediaTagName]、[msgSignature]、[thumbData]、[thumbDataHash]、[onResponse]
  /// 含义同其他分享方法。
  ///
  /// 返回是否成功发起分享。
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
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (musicUrl == null && musicLowBandUrl == null) {
      throw ArgumentError('musicUrl 与 musicLowBandUrl 至少提供一个');
    }
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareMusicModel(
          musicUrl: musicUrl,
          musicDataUrl: musicDataUrl,
          musicLowBandUrl: musicLowBandUrl,
          musicLowBandDataUrl: musicLowBandDataUrl,
          title: title ?? _shareTitle ?? '',
          description: description ?? _shareTitle,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享视频。
  ///
  /// [videoUrl] 为视频地址；[title]、[description]、[scene]、[messageExt]、
  /// [messageAction]、[mediaTagName]、[msgSignature]、[thumbData]、
  /// [thumbDataHash]、[onResponse] 含义同其他分享方法。
  ///
  /// 返回是否成功发起分享。
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
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareVideoModel(
          videoUrl: videoUrl,
          title: title ?? _shareTitle ?? '',
          description: description ?? _shareTitle,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享网页。
  ///
  /// [webPage] 为网页地址；[title]、[description]、[scene]、[messageExt]、
  /// [messageAction]、[mediaTagName]、[msgSignature]、[thumbData]、
  /// [thumbDataHash]、[onResponse] 含义同其他分享方法。
  ///
  /// 返回是否成功发起分享。
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
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareWebPageModel(
          webPage,
          title: title ?? _shareTitle ?? '',
          description: description ?? _shareTitle,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 分享本地文件。
  ///
  /// [source] 为本地文件；[suffix] 为文件后缀，iOS 必须提供（例如 ".pdf"）。
  /// [title]、[description]、[scene]、[messageExt]、[messageAction]、
  /// [mediaTagName]、[msgSignature]、[thumbData]、[thumbDataHash]、[onResponse]
  /// 含义同其他分享方法。
  ///
  /// 返回是否成功发起分享。
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
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    if (!await isInstalled) return false;
    return _shareResponse(
      () => _fluwx.share(
        WeChatShareFileModel(
          WeChatFile.file(source, suffix: suffix),
          title: title ?? _shareTitle ?? '',
          description: description ?? _shareTitle,
          scene: scene,
          messageExt: messageExt,
          messageAction: messageAction,
          mediaTagName: mediaTagName,
          msgSignature: msgSignature,
          thumbData: thumbData ?? _shareThumbnail,
          thumbDataHash: thumbDataHash,
        ),
      ),
      onResponse: onResponse,
    );
  }

  /// 发起分享并注册分享响应监听。
  ///
  /// [share] 为实际的分享调用；[onResponse] 为空时不会注册监听。
  /// 分享请求发起失败时会立即取消监听。
  Future<bool> _shareResponse(
    Future<bool> Function() share, {
    FlWxResponseCallback<WeChatShareResponse>? onResponse,
  }) async {
    final cancelable = _subscribeFor(onResponse);
    final result = await share();
    // 请求发起失败时立即取消监听，避免残留订阅。
    if (!result) cancelable.cancel();
    return result;
  }

  /// 注册一个微信响应监听。
  ///
  /// [handler] 处理每条响应；[cancelWhen] 返回 true 时自动取消监听。
  /// 回调异常会被捕获并通过 onLog 输出，不会中断监听释放。
  FluwxCancelable _subscribe(
    FutureOr<void> Function(WeChatResponse response) handler, {
    required bool Function(WeChatResponse response) cancelWhen,
  }) {
    late final FluwxCancelable cancelable;
    // 用 canceled 保证取消操作幂等，避免重复移除订阅。
    bool canceled = false;
    void cancel() {
      if (canceled) return;
      canceled = true;
      cancelable.cancel();
    }

    cancelable = _fluwx.addSubscriber((response) async {
      try {
        await handler(response);
      } catch (error) {
        _log('微信响应处理失败 $error');
      } finally {
        // 收到终止响应后释放监听，避免重复回调。
        if (cancelWhen(response)) cancel();
      }
    });
    return _FlWxCancelable(cancel);
  }

  /// 只监听 [T] 类型的响应。
  ///
  /// 没有传入 [onResponse] 时返回空实现，不注册监听。
  FluwxCancelable _subscribeFor<T extends WeChatResponse>(FlWxResponseCallback<T>? onResponse) {
    if (onResponse == null) return const _NoopCancelable();
    // 只有目标类型的响应才回调，收到后自动取消。
    return _subscribe((response) async {
      if (response is T) await onResponse(response);
    }, cancelWhen: (response) => response is T);
  }

  /// 授权成功后获取 token，并在需要时继续获取用户信息。
  ///
  /// [response] 为授权响应，[onToken] 和 [onUserInfo] 分别接收 token 和用户信息。
  /// 依赖 [register] 时传入的 appSecret 与 [FlWxCallbackParams.onHttp]。
  Future<void> _loadAuthInfo(
    WeChatAuthResponse response, {
    FlWxAuthTokenCallback? onToken,
    FlWxAuthUserInfoCallback? onUserInfo,
  }) async {
    if (onToken == null && onUserInfo == null) return;
    final code = response.code;
    if (code == null || code.isEmpty) {
      _log('授权 code 为空');
      return;
    }
    final onHttp = _params.onHttp;
    if (onHttp == null) {
      _log('未设置 onHttp，无法获取 token 和用户信息');
      return;
    }
    try {
      // 1. 通过 onHttp 请求 token。
      final tokenData = await onHttp(_tokenUri(code).toString());
      final tokenJson = tokenData == null ? null : _decodeJson(tokenData);
      if (tokenJson == null) {
        _log('Token 数据获取或解析失败 $tokenData');
        return;
      }
      final token = WeChatToken.fromJson(tokenJson);
      if (token.errCode != null) {
        _log('Token 获取失败 ${token.errCode} ${token.errMsg}');
      }
      // 2. 先回调 token，即使 token 无效也让调用方拿到错误信息。
      await onToken?.call(response, token);
      if (onUserInfo == null) return;
      if (!token.isValid) {
        _log('没有获取到 openid 和 accessToken ${token.toMap()}');
        return;
      }
      // 3. 需要用户信息时再请求用户信息。
      final userInfoData = await onHttp(_userInfoUri(token).toString());
      final userInfoJson = userInfoData == null ? null : _decodeJson(userInfoData);
      if (userInfoJson == null) {
        _log('UserInfo 数据获取或解析失败 $userInfoData');
        return;
      }
      final userInfo = WeChatUserInfo.fromJson(userInfoJson);
      if (userInfo.errCode != null) {
        _log('UserInfo 获取失败 ${userInfo.errCode} ${userInfo.errMsg}');
      }
      await onUserInfo(response, token, userInfo);
    } catch (error) {
      _log('授权数据加载失败 $error');
    }
  }

  /// 构造微信 token 请求地址。
  ///
  /// [code] 为授权返回的 code；未设置 appId 或 appSecret 时抛出 [StateError]。
  Uri _tokenUri(String code) {
    final appId = _appId;
    final appSecret = _appSecret;
    if (appId == null || appSecret == null) {
      throw StateError('请先在 register 中设置 appId 和 appSecret');
    }
    // 使用 Uri.https 自动完成 query 参数编码。
    return Uri.https('api.weixin.qq.com', '/sns/oauth2/access_token', {
      'appid': appId,
      'secret': appSecret,
      'code': code,
      'grant_type': 'authorization_code',
    });
  }

  /// 构造微信用户信息请求地址。
  ///
  /// [token] 必须包含有效的 accessToken 和 openid。
  // token.isValid 已在调用前校验，因此这里可以安全使用 !。
  Uri _userInfoUri(WeChatToken token) =>
      Uri.https('api.weixin.qq.com', '/sns/userinfo', {'access_token': token.accessToken!, 'openid': token.openid!});

  /// 将 JSON 字符串解析为 Map，解析失败或类型不符时返回 null。
  Map<String, dynamic>? _decodeJson(String source) {
    try {
      final decoded = jsonDecode(source);
      // 微信接口正常返回 JSON 对象，非 Map 视为解析失败。
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 输出日志；未配置 onLog 时忽略。
  void _log(String message) => _params.onLog?.call(message);

  /// 显示 Toast；未配置 onToast 时忽略。
  void _toast(String message) => _params.onToast?.call(message);
}

/// 基于回调的 [FluwxCancelable] 实现。
class _FlWxCancelable implements FluwxCancelable {
  /// 创建取消器。
  const _FlWxCancelable(this._cancel);

  /// 实际取消逻辑。
  final void Function() _cancel;

  /// 取消监听。
  @override
  void cancel() => _cancel();
}

/// 空取消实现，用于没有注册监听时占位。
class _NoopCancelable implements FluwxCancelable {
  /// 创建空取消器。
  const _NoopCancelable();

  /// 什么都不做。
  @override
  void cancel() {}
}

/// 微信回调配置。
///
/// 在 [FlWx.register] 时传入，所有回调都是可选的。
class FlWxCallbackParams {
  /// 创建回调配置。
  const FlWxCallbackParams({this.onToast, this.onLog, this.onHttp});

  /// Toast 显示回调。
  ///
  /// 封装内部会在支付成功、支付取消、授权失败等场景调用。
  final FlWxMessageCallback? onToast;

  /// 日志打印回调。
  ///
  /// 封装内部会在授权数据获取失败、支付结果、响应处理异常等场景调用。
  final FlWxMessageCallback? onLog;

  /// HTTP 请求回调，返回 JSON 字符串。
  ///
  /// 用于授权后获取 token 和用户信息；[url] 已经编码，直接请求并返回响应体即可。
  final FlWxHttpCallback? onHttp;
}

/// 微信授权接口 `/sns/oauth2/access_token` 返回的 token。
class WeChatToken {
  /// 创建 token 对象，通常通过 [WeChatToken.fromJson] 构建。
  const WeChatToken({
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.openid,
    this.scope,
    this.unionId,
    this.errCode,
    this.errMsg,
  });

  /// 从微信接口返回的 JSON 创建 token。
  ///
  /// 支持 `access_token`、`expires_in`、`refresh_token`、`openid`、`scope`、
  /// `unionid`、`errcode`、`errmsg` 字段。
  factory WeChatToken.fromJson(Map<String, dynamic> json) => WeChatToken(
    accessToken: json['access_token']?.toString(),
    expiresIn: _asInt(json['expires_in']),
    refreshToken: json['refresh_token']?.toString(),
    openid: json['openid']?.toString(),
    scope: json['scope']?.toString(),
    unionId: json['unionid']?.toString(),
    errCode: _asInt(json['errcode']),
    errMsg: json['errmsg']?.toString(),
  );

  /// 接口返回的 access_token。
  final String? accessToken;

  /// access_token 有效期，单位秒。
  final int? expiresIn;

  /// 用于刷新 access_token 的 refresh_token。
  final String? refreshToken;

  /// 用户在当前应用的唯一标识。
  final String? openid;

  /// 授权作用域，例如 `snsapi_userinfo`。
  final String? scope;

  /// 用户在微信开放平台的唯一标识。
  final String? unionId;

  /// 微信返回的错误码，成功时为 null。
  final int? errCode;

  /// 微信返回的错误信息，成功时为 null。
  final String? errMsg;

  /// token 是否包含有效的 [openid] 和 [accessToken]。
  bool get isValid => (openid?.isNotEmpty ?? false) && (accessToken?.isNotEmpty ?? false);

  /// 转换为 Map，便于日志和调试输出。
  Map<String, dynamic> toMap() => {
    'openid': openid,
    'unionId': unionId,
    'accessToken': accessToken,
    'expiresIn': expiresIn,
    'refreshToken': refreshToken,
    'scope': scope,
    'errCode': errCode,
    'errMsg': errMsg,
  };

  /// 调试用字符串。
  @override
  String toString() => 'WeChatToken(${toMap()})';
}

/// 微信授权接口 `/sns/userinfo` 返回的用户信息。
class WeChatUserInfo {
  /// 创建用户信息对象，通常通过 [WeChatUserInfo.fromJson] 构建。
  const WeChatUserInfo({
    this.openid,
    this.nickname,
    this.sex,
    this.language,
    this.city,
    this.province,
    this.country,
    this.headImgUrl,
    this.privilege,
    this.unionId,
    this.errCode,
    this.errMsg,
  });

  /// 从微信接口返回的 JSON 创建用户信息。
  ///
  /// 支持 `openid`、`nickname`、`sex`、`language`、`city`、`province`、`country`、
  /// `headimgurl`、`privilege`、`unionid`、`errcode`、`errmsg` 字段。
  factory WeChatUserInfo.fromJson(Map<String, dynamic> json) => WeChatUserInfo(
    openid: json['openid']?.toString(),
    nickname: json['nickname']?.toString(),
    sex: _asInt(json['sex']),
    language: json['language']?.toString(),
    city: json['city']?.toString(),
    province: json['province']?.toString(),
    country: json['country']?.toString(),
    headImgUrl: json['headimgurl']?.toString(),
    privilege: (json['privilege'] as List?)?.map((item) => item.toString()).toList(),
    unionId: json['unionid']?.toString(),
    errCode: _asInt(json['errcode']),
    errMsg: json['errmsg']?.toString(),
  );

  /// 用户在当前应用的唯一标识。
  final String? openid;

  /// 用户昵称。
  final String? nickname;

  /// 性别，1 为男性，2 为女性，0 为未知。
  final int? sex;

  /// 用户语言，例如 `zh_CN`。
  final String? language;

  /// 用户所在城市。
  final String? city;

  /// 用户所在省份。
  final String? province;

  /// 用户所在国家。
  final String? country;

  /// 用户头像地址。
  final String? headImgUrl;

  /// 用户特权信息。
  final List<String>? privilege;

  /// 用户在微信开放平台的唯一标识。
  final String? unionId;

  /// 微信返回的错误码，成功时为 null。
  final int? errCode;

  /// 微信返回的错误信息，成功时为 null。
  final String? errMsg;

  /// 是否包含有效的 [openid]。
  bool get isValid => openid?.isNotEmpty ?? false;

  /// 转换为 Map，便于日志和调试输出。
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
    'errCode': errCode,
    'errMsg': errMsg,
  };

  /// 调试用字符串。
  @override
  String toString() => 'WeChatUserInfo(${toMap()})';
}

/// 微信支付参数 Map 转换扩展。
///
/// 支持服务端返回的驼峰字段：`appId`、`partnerId`、`prepayId`、`packageValue`、
/// `nonceStr`、`timeStamp`、`sign`、`signType`、`extData`，同时兼容 `appid`、
/// `partnerid`、`prepayid`、`package`、`noncestr`、`timestamp` 等小写字段。
extension WeChatPaymentMapExtension on Map {
  /// 将微信支付参数转换为 [Payment]。
  ///
  /// 必要字段：`appId`、`partnerId`、`prepayId`、`packageValue`、`nonceStr`、
  /// `timestamp`、`sign`。缺少必要字段或 `timestamp` 无法解析为 int 时返回 null，
  /// 不抛出异常。`signType`、`extData` 为可选字段。
  Payment? toPayment() {
    try {
      final appId = this['appId'] ?? this['appid'];
      final partnerId = this['partnerId'] ?? this['partnerid'] ?? this['partner'];
      final prepayId = this['prepayId'] ?? this['prepayid'] ?? this['prepay'];
      final packageValue = this['packageValue'] ?? this['packagevalue'] ?? this['package'];
      final nonceStr = this['nonceStr'] ?? this['noncestr'] ?? this['nonce'];
      final timestamp = this['timestamp'] ?? this['timeStamp'];
      final sign = this['sign'];
      // 必要字段缺失时直接返回 null，避免构造出无效的 Payment。
      if (appId == null ||
          partnerId == null ||
          prepayId == null ||
          packageValue == null ||
          nonceStr == null ||
          timestamp == null ||
          sign == null) {
        return null;
      }
      // timestamp 支持 int、num 和字符串。
      final time = _asInt(timestamp);
      if (time == null) return null;
      return Payment(
        appId: appId.toString(),
        partnerId: partnerId.toString(),
        prepayId: prepayId.toString(),
        packageValue: packageValue.toString(),
        nonceStr: nonceStr.toString(),
        timestamp: time,
        sign: sign.toString(),
        signType: (this['signType'] ?? this['signtype'])?.toString(),
        extData: (this['extData'] ?? this['extdata'])?.toString(),
      );
    } catch (error) {
      FlWx.instance._log('支付参数解析失败 $error');
      return null;
    }
  }
}

/// 将 int、num 或字符串安全转换为 int，失败返回 null。
int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
