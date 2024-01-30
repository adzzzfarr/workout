import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final void Function() onPressed;

  const CommonButton({
    required this.height,
    required this.width,
    required this.text,
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
          shape: const StadiumBorder(),
          elevation: 10,
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
