import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 深色代码块，支持横向滚动和复制。
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.55, color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          IconButton(
            tooltip: '复制代码',
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制代码')));
            },
            icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
