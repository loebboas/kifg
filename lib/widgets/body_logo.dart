import 'package:flutter/material.dart';

class BodyLogoWidget extends StatelessWidget {
  const BodyLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/kifg.png', width: 200, height: 200),
        Text(
          "KI Fallbeispiele Tutorium",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
