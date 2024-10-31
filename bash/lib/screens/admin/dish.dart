class Dish {
  final int id;
  String name;
  double price;
  String description;

  Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  // Factory method to create a Dish object from JSON
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
    );
  }

  // Convert a Dish object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}
