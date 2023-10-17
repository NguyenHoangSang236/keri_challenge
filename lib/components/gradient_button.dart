import 'package:flutter/material.dart';

class GradientElevatedButton extends StatefulWidget {
  const GradientElevatedButton({
    Key? key,
    required this.text,
    this.borderColor = Colors.transparent,
    this.borderRadiusIndex = 20,
    this.beginColor = Colors.black,
    this.endColor = const Color(0xff727272),
    this.textColor = Colors.white,
    this.buttonHeight = 30,
    this.buttonWidth = 178,
    this.textWeight = FontWeight.w700,
    this.textSize = 13,
    this.buttonElevation = 0,
    this.borderWidth = 1,
    this.buttonMargin = const EdgeInsets.only(top: 35),
    this.isLoading = false,
    required this.onPress,
    this.textFontStyle = FontStyle.normal,
    this.begin = Alignment.centerRight,
    this.end = Alignment.centerLeft,
    this.border,
    this.splashColor,
    this.backgroundColor,
  }) : super(key: key);

  final Color textColor;
  final FontWeight textWeight;
  final double textSize;
  final Color? beginColor;
  final Color? endColor;
  final Color borderColor;
  final String text;
  final double borderRadiusIndex;
  final double buttonHeight;
  final double buttonWidth;
  final double buttonElevation;
  final double borderWidth;
  final EdgeInsets buttonMargin;
  final bool isLoading;
  final FontStyle textFontStyle;
  final Alignment begin;
  final Alignment end;
  final void Function() onPress;
  final BoxBorder? border;
  final Color? splashColor;
  final Color? backgroundColor;

  @override
  State<StatefulWidget> createState() => _GradientElevatedButtonState();
}

class _GradientElevatedButtonState extends State<GradientElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: widget.buttonHeight,
      width: widget.buttonWidth,
      margin: widget.buttonMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadiusIndex),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        color: widget.backgroundColor,
        gradient: widget.backgroundColor == null
            ? LinearGradient(
                begin: widget.begin,
                end: widget.end,
                colors: [
                  widget.beginColor ?? Colors.white,
                  widget.endColor ?? Colors.white,
                ],
              )
            : null,
      ),
      child: ElevatedButton(
        onPressed: widget.onPress,
        style: ElevatedButton.styleFrom(
          foregroundColor: widget.splashColor,
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
          padding: EdgeInsets.zero,
          fixedSize: Size(widget.buttonWidth, widget.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadiusIndex),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: widget.buttonHeight,
                width: widget.buttonWidth,
                child: CircularProgressIndicator(
                  color: widget.textColor,
                ),
              )
            : Text(
                widget.text,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  color: widget.textColor,
                  fontSize: widget.textSize,
                  fontWeight: widget.textWeight,
                  fontStyle: widget.textFontStyle,
                ),
              ),
      ),
    );
  }
}
