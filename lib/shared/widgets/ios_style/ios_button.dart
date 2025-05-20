import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

// Updated 2025-05-20: Fixed imports to correctly reference AppColors

// Updated 2025-05-20: Created iOS-style button component for consistent iOS look and feel
enum IOSButtonType { filled, outlined, text }

class IOSButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IOSButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;
  final double height;
  final double borderRadius;

  const IOSButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = IOSButtonType.filled,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.color,
    this.height = 44.0,
    this.borderRadius = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode 
        ? AppColors.primaryDark 
        : AppColors.primaryLight
    
    final buttonColor = color ?? primaryColor;
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CupertinoActivityIndicator(
              color: type == IOSButtonType.filled 
                  ? Colors.white 
                  : buttonColor,
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              icon,
              size: 18,
              color: type == IOSButtonType.filled 
                  ? Colors.white 
                  : buttonColor,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: type == IOSButtonType.filled 
                ? Colors.white 
                : buttonColor,
          ),
        ),
      ],
    );
    
    Widget button;
    
    switch (type) {
      case IOSButtonType.filled:
        button = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isLoading ? null : onPressed,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buttonChild,
          ),
        );
        break;
      case IOSButtonType.outlined:
        button = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isLoading ? null : onPressed,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: buttonColor),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buttonChild,
          ),
        );
        break;
      case IOSButtonType.text:
        button = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isLoading ? null : onPressed,
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buttonChild,
          ),
        );
        break;
    }
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
}
