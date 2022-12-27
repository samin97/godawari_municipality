import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final Color textColour;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Widget? icon;
  final Function()? onTap;
  final double? textSize;

  const AppButton(
      {Key? key,
      required this.textColour,
      required this.backgroundColor,
      required this.borderColor,
      required this.text,
      this.textSize,
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
        height: 100,
        width: 100,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.icon != null)
                    Padding(
                      padding: const EdgeInsets.all(1),
                      child: widget.icon,
                    ),
                  if (widget.textSize != null)
                    Text(
                      widget.text,
                      style: TextStyle(
                          color: widget.textColour, fontSize: widget.textSize),
                    )
                  else
                    Text(
                      widget.text,
                      style: TextStyle(
                          color: widget.textColour, fontSize: 14),
                    )
                ]),
          ),
        ),
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: widget.borderColor, width: 1.0)),
      ),
    );
  }
}
