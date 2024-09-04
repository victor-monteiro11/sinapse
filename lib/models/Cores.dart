import 'package:flutter/material.dart';
import 'dart:math' as math;

class Cores {
  // Function to retrieve a Color from a hex string
  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add alpha if not provided
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Function to convert a Color to a hex string
  static String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  // Function to get Random Color
  static Color getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

}
