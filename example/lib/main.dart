import 'dart:async';

import 'package:example/demo/demo_utils.dart';
import 'package:example/pages/auth_page.dart';
import 'package:example/pages/basic_page.dart';
import 'package:example/pages/models_page.dart';
import 'package:example/pages/open_page.dart';
import 'package:example/pages/pay_page.dart';
import 'package:example/pages/share_page.dart';
import 'package:example/state/app_state.dart';
import 'package:example/widgets/hero_banner.dart';
import 'package:example/widgets/log_sheet.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _FlWxExampleApp());
  WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(registerDemo()));
}

class _FlWxExampleApp extends StatelessWidget {
  const _FlWxExampleApp();

  ThemeData theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF07C160), brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF4F7F5) : const Color(0xFF0D1210),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlWx Playground',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('FlWx Playground', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('fluwx 6 · WeChat SDK', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
            ],
          ),
          actions: const [_LogButton(), SizedBox(width: 8)],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: const Column(
              children: [
                HeroBanner(),
                SizedBox(height: 10),
                _Tabs(),
                SizedBox(height: 2),
                Expanded(
                  child: TabBarView(
                    children: [BasicPage(), AuthPage(), PayPage(), SharePage(), OpenPage(), ModelsPage()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(999)),
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        tabs: const [
          Tab(height: 34, text: '基础'),
          Tab(height: 34, text: '授权'),
          Tab(height: 34, text: '支付'),
          Tab(height: 34, text: '分享'),
          Tab(height: 34, text: '打开'),
          Tab(height: 34, text: '模型'),
        ],
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  const _LogButton();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final count = AppState.instance.logs.length;
        final button = IconButton(
          tooltip: '运行日志',
          onPressed: () => LogSheet.show(context),
          icon: const Icon(Icons.terminal_rounded),
        );
        return count == 0 ? button : Badge.count(count: count, child: button);
      },
    );
  }
}
