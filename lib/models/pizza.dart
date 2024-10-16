// pizza size
enum Size { small, medium, large }

// type of pizza sauce
enum Sauce { white, red }

class Pizza {
  const Pizza(
      {required this.pizzaSize,
      required this.toppings,
      required this.sauce,
      required this.thinCrust});

  final Size pizzaSize;
  final List<String> toppings;
  final Sauce sauce;
  final bool thinCrust;
}
