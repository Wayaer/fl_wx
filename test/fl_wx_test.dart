import 'package:fl_wx/fl_wx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeChatPaymentMapExtension', () {
    test('转换驼峰命名的支付参数', () {
      final payment = {
        'appId': 'wx123',
        'partnerId': '1900000109',
        'prepayId': 'wx201410272009395522657a690389285100',
        'packageValue': 'Sign=WXPay',
        'nonceStr': '5K8264ILTKCH16CQ2502SI8ZNMTM67VS',
        'timeStamp': '1414561699',
        'sign': 'ABCDEF',
        'signType': 'MD5',
      }.toPayment();

      expect(payment, isNotNull);
      expect(payment!.appId, 'wx123');
      expect(payment.partnerId, '1900000109');
      expect(payment.packageValue, 'Sign=WXPay');
      expect(payment.timestamp, 1414561699);
      expect(payment.signType, 'MD5');
    });

    test('转换微信返回的小写支付参数', () {
      final payment = {
        'appid': 'wx123',
        'partnerid': '1900000109',
        'prepayid': 'prepay',
        'package': 'Sign=WXPay',
        'noncestr': 'nonce',
        'timestamp': 1414561699,
        'sign': 'ABCDEF',
      }.toPayment();

      expect(payment, isNotNull);
      expect(payment!.prepayId, 'prepay');
      expect(payment.timestamp, 1414561699);
    });

    test('缺少必要参数时返回 null', () {
      final payment = {'appId': 'wx123', 'sign': 'ABCDEF'}.toPayment();
      expect(payment, isNull);
    });

    test('时间戳非法时返回 null', () {
      final payment = {
        'appId': 'wx123',
        'partnerId': '1900000109',
        'prepayId': 'prepay',
        'packageValue': 'Sign=WXPay',
        'nonceStr': 'nonce',
        'timestamp': 'not-a-number',
        'sign': 'ABCDEF',
      }.toPayment();

      expect(payment, isNull);
    });
  });

  group('WeChatToken', () {
    test('解析 token 并判断有效性', () {
      final token = WeChatToken.fromJson({
        'access_token': 'access',
        'expires_in': 7200,
        'refresh_token': 'refresh',
        'openid': 'openid',
        'scope': 'snsapi_userinfo',
        'unionid': 'unionid',
      });

      expect(token.isValid, isTrue);
      expect(token.expiresIn, 7200);
      expect(token.unionId, 'unionid');
    });

    test('解析微信错误信息', () {
      final token = WeChatToken.fromJson({'errcode': 40029, 'errmsg': 'invalid code'});

      expect(token.isValid, isFalse);
      expect(token.errCode, 40029);
      expect(token.errMsg, 'invalid code');
    });
  });

  group('WeChatUserInfo', () {
    test('解析用户信息', () {
      final userInfo = WeChatUserInfo.fromJson({
        'openid': 'openid',
        'nickname': 'nickname',
        'sex': 1,
        'language': 'zh_CN',
        'city': 'Shenzhen',
        'province': 'Guangdong',
        'country': 'China',
        'headimgurl': 'https://example.com/avatar.png',
        'privilege': <Object>['one', 'two'],
        'unionid': 'unionid',
      });

      expect(userInfo.isValid, isTrue);
      expect(userInfo.nickname, 'nickname');
      expect(userInfo.headImgUrl, 'https://example.com/avatar.png');
      expect(userInfo.privilege, <String>['one', 'two']);
    });

    test('解析微信错误信息', () {
      final userInfo = WeChatUserInfo.fromJson({'errcode': 40003, 'errmsg': 'invalid openid'});

      expect(userInfo.isValid, isFalse);
      expect(userInfo.errCode, 40003);
    });
  });
}
