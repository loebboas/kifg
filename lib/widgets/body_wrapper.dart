import 'package:flutter/material.dart';

class BodyWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const BodyWrapper({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
