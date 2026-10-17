import 'package:flutter/material.dart';

class ProductIconHelper {
  static String getEmojiForProduct(String name, String category) {
    final lowerName = name.toLowerCase();
    final normalizedCategory = category.trim().toLowerCase();

    switch (normalizedCategory) {
      case 'helados':
        return '🍦';
      case 'paletas':
        return '🍭';
      case 'aguas':
        return '🥤';
      case 'vasos':
      case 'vasos de helado':
        return '🍨';
    }

    if (lowerName.contains('agua') ||
        lowerName.contains('aguas') ||
        lowerName.contains('rompope') ||
        lowerName.contains('jamaica') ||
        lowerName.contains('horchata')) {
      return '🥤';
    }

    if (lowerName.contains('paleta')) {
      return '🍭';
    }

    if (lowerName.contains('cono')) {
      return '🍦';
    }

    if (lowerName.contains('vaso') ||
        lowerName.contains('litro') ||
        lowerName.contains('botella') ||
        lowerName.contains('bote')) {
      return '🥛';
    }

    return '🏪';
  }

  static Widget buildProductEmoji(
    String name,
    String category, {
    double size = 24,
  }) {
    return Text(
      getEmojiForProduct(name, category),
      style: TextStyle(fontSize: size),
    );
  }
}
