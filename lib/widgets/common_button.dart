import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CommonButton extends StatelessWidget {
  final double height;
  final double width;
  IconData? leading;
  Color? color;
  final String text;
  final void Function() onPressed;

  CommonButton({
    required this.height,
    required this.width,
    required this.text,
    this.leading,
    this.color,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: leading == null
            ? Text(
                text,
                style: TextStyle(fontSize: screenHeight / 40),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(leading),
                  SizedBox(width: screenHeight / 80),
                  Text(
                    text,
                    style: TextStyle(fontSize: screenHeight / 40),
                  )
                ],
              ),
      ),
    );
  }
}
