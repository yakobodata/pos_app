class MenuItem {
  final String id;
  String name;
  double price;
  String barcode;          // important for scanning
  String category;
  int stockQuantity;       // linked to inventory
  bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.category,
    this.stockQuantity = 0,
    this.isAvailable = true,
  });


  //change the object to a json format
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'barcode': barcode,
        'category': category,
        'stockQuantity': stockQuantity,
        'isAvailable': isAvailable,
      };

  //change the json format to an object
  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        barcode: json['barcode'],
        category: json['category'],
        stockQuantity: json['stockQuantity'] ?? 0,
        isAvailable: json['isAvailable'] ?? true,
      );
}