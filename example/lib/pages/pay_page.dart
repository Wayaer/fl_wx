import 'package:example/demo/demo_utils.dart';
import 'package:example/demo/samples.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: '微信支付、香港钱包支付、自动续费签约，以及支付参数 Map 的解析。',
      actions: [
        ApiAction(
          icon: Icons.transform_rounded,
          title: 'Map.toPayment',
          description: '把服务端返回的支付参数转换成 Payment。',
          code: r'''final payment = samplePaymentMap.toPayment();
final info = payment == null
    ? null
    : (
        appId: payment.appId,
        partnerId: payment.partnerId,
        prepayId: payment.prepayId,
        packageValue: payment.packageValue,
        timestamp: payment.timestamp,
        signType: payment.signType,
      );''',
          action: () async {
            final payment = samplePaymentMap.toPayment();
            if (payment == null) return null;
            return (
              appId: payment.appId,
              partnerId: payment.partnerId,
              prepayId: payment.prepayId,
              packageValue: payment.packageValue,
              timestamp: payment.timestamp,
              signType: payment.signType,
            );
          },
        ),
        ApiAction(
          icon: Icons.report_gmailerrorred_rounded,
          title: 'toPayment 非法参数',
          description: '缺少必要字段时返回 null，而不是抛出异常。',
          code: r'''final payment = <String, dynamic>{}.toPayment();
final isNull = payment == null;''',
          action: () async => <String, dynamic>{}.toPayment() == null,
        ),
        ApiAction(
          icon: Icons.account_balance_wallet_rounded,
          title: 'pay(Payment)',
          description: '使用 Payment 发起微信支付，并监听结果。',
          code: r'''final payment = samplePaymentMap.toPayment();
if (payment == null) return '支付参数无效';
final result = await FlWx().pay(
  payment,
  onSuccess: () => logSuccess('支付成功'),
  onResponse: logResponse,
);''',
          action: () async {
            final payment = samplePaymentMap.toPayment();
            if (payment == null) return '支付参数无效';
            return FlWx().pay(payment, onSuccess: () => logSuccess('支付成功'), onResponse: logResponse);
          },
        ),
        ApiAction(
          icon: Icons.public_rounded,
          title: 'pay(HongKongWallet)',
          description: '发起香港钱包支付。',
          code: r'''final result = await FlWx().pay(
  HongKongWallet(prepayId: 'test'),
  onResponse: logResponse,
);''',
          action: () async => await FlWx().pay(HongKongWallet(prepayId: 'test'), onResponse: logResponse),
        ),
        ApiAction(
          icon: Icons.event_repeat_rounded,
          title: 'autoDeduct(AutoDeduct.detail)',
          description: '使用完整签约参数发起自动续费签约。',
          code: r'''final data = AutoDeduct.detail(
  appId: 'test',
  mchId: 'test',
  planId: 'test',
  contractCode: 'test',
  requestSerial: 'test',
  contractDisplayAccount: 'test',
  notifyUrl: 'https://example.com/notify',
  version: '1.0',
  sign: 'test',
  timestamp: 'timestamp',
);
final result = await FlWx().autoDeduct(
  data,
  onResponse: logResponse,
);''',
          action: () async {
            final data = AutoDeduct.detail(
              appId: 'test',
              mchId: 'test',
              planId: 'test',
              contractCode: 'test',
              requestSerial: 'test',
              contractDisplayAccount: 'test',
              notifyUrl: 'https://example.com/notify',
              version: '1.0',
              sign: 'test',
              timestamp: '${DateTime.now().millisecondsSinceEpoch}',
            );
            return FlWx().autoDeduct(data, onResponse: logResponse);
          },
        ),
        ApiAction(
          icon: Icons.tune_rounded,
          title: 'autoDeduct(AutoDeduct.custom)',
          description: '自定义 queryInfo 的签约方式。',
          code: r'''final data = AutoDeduct.custom(
  queryInfo: {
    'appid': 'test',
    'mch_id': 'test',
  },
  businessType: 12,
);
final result = await FlWx().autoDeduct(
  data,
  onResponse: logResponse,
);''',
          action: () async {
            final data = AutoDeduct.custom(queryInfo: {'appid': 'test', 'mch_id': 'test'}, businessType: 12);
            return FlWx().autoDeduct(data, onResponse: logResponse);
          },
        ),
        ApiAction(
          icon: Icons.construction_rounded,
          title: 'Payment 直接构造',
          description: '不使用 Map 转换时，可以直接构造 Payment。',
          code: r'''final payment = Payment(
  appId: 'test',
  partnerId: 'test',
  prepayId: 'test',
  packageValue: 'Sign=WXPay',
  nonceStr: 'test',
  timestamp: 0,
  sign: 'test',
  signType: 'MD5',
  extData: 'extData',
);''',
          action: () async {
            final payment = Payment(
              appId: 'test',
              partnerId: 'test',
              prepayId: 'test',
              packageValue: 'Sign=WXPay',
              nonceStr: 'test',
              timestamp: 0,
              sign: 'test',
              signType: 'MD5',
              extData: 'extData',
            );
            return (
              appId: payment.appId,
              packageValue: payment.packageValue,
              signType: payment.signType,
              extData: payment.extData,
            );
          },
        ),
      ],
    );
  }
}
