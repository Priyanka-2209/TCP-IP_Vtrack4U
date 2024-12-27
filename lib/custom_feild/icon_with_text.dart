import 'package:flutter/material.dart';

class IconWithText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontweight;
  final double? fontsize;
  final TextAlign? txtalign;
  final IconData? icon;

  const IconWithText(
      {super.key,
      required this.text,
      this.color,
      this.fontweight,
      this.fontsize,
      this.txtalign,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(icon, size: 16,),
          SizedBox(width: 8.0,),
          Text(text, style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }
}
