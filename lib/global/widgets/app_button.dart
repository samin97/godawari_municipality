import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final Color textColour;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Widget? icon;
  final Function()? onTap;

  const AppButton({Key? key,
    required this.textColour,
    required this.backgroundColor,
    required this.borderColor,
    required this.text,
    this.icon,
    required this.onTap})
      : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(widget.icon != null)
                    Padding(padding: const EdgeInsets.all(1),
                      child: widget.icon,),
                  Text(
                      widget.text,
                      style: TextStyle(color: widget.textColour),
                    ),
                ]
            ),
          ),),
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: widget.borderColor, width: 1.0)),
      ),
    );
  }
}

