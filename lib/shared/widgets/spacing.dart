import 'package:flutter/widgets.dart';

class VSpace extends StatelessWidget {
  const VSpace(this.height, {super.key});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class HSpace extends StatelessWidget {
  const HSpace(this.width, {super.key});
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
