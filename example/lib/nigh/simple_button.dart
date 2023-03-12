import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  const SimpleButton({
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function() onTap;

  static const textStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontFamily: 'Rubik',
    fontWeight: FontWeight.normal,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
