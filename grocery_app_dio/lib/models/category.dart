import 'dart:ui';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  sweets,
  carbs,
  spices,
  convenience,
  hygiene,
  other
}

class Category {
  final String title;
  final Color color;

  const Category(this.title, this.color);
}

