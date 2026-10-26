import 'package:example/state/app_state.dart';
import 'package:example/widgets/code_block.dart';
import 'package:flutter/material.dart';

/// API 卡片执行的异步回调。
typedef ApiActionCallback = Future<Object?> Function();

/// 一个可运行的 API 示例。
class ApiAction {
  const ApiAction({
    required this.title,
    required this.description,
    required this.code,
    required this.action,
    this.icon = Icons.bolt_rounded,
  });

  final String title;
  final String description;
  final String code;
  final ApiActionCallback action;
  final IconData icon;
}

/// API 列表面板。
class ApiList extends StatelessWidget {
  const ApiList({super.key, required this.actions, this.intro});

  final List<ApiAction> actions;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intro = this.intro;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (intro != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  intro,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ),
            for (final action in actions) ApiCard(action: action),
          ],
        ),
      ),
    );
  }
}

/// 展示调用代码并提供运行按钮的卡片。
class ApiCard extends StatefulWidget {
  const ApiCard({super.key, required this.action});

  final ApiAction action;

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  bool running = false;

  Future<void> run() async {
    if (running) return;
    setState(() => running = true);
    AppState.instance.log('▶ ${widget.action.title}', level: LogLevel.action);
    try {
      final result = await widget.action.action();
      AppState.instance.log('✓ ${widget.action.title} → $result', level: LogLevel.success);
    } catch (error) {
      AppState.instance.log('✗ ${widget.action.title} → $error', level: LogLevel.error);
    } finally {
      if (mounted) setState(() => running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = widget.action;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        action.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CodeBlock(code: action.code),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${action.code.split('\n').length} 行示例代码',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: running ? null : run,
                  icon: running
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(running ? '运行中' : '运行'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
