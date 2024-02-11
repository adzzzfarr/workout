import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final double height;
  final double width;
  Color? color;
  final String text;
  final void Function() onPressed;

  CommonButton({
    required this.height,
    required this.width,
    required this.text,
    this.color,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const StadiumBorder(),
          elevation: 10,
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
