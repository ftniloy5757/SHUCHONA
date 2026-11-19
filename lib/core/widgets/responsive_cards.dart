import 'package:flutter/material.dart';

/// Cards stack on narrow screens and grow vertically as text wraps.
class ResponsiveCards extends StatelessWidget {
  const ResponsiveCards({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final minimumWidth =
            560 * MediaQuery.textScalerOf(context).scale(16) / 16;
        final width = constraints.maxWidth >= minimumWidth
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
