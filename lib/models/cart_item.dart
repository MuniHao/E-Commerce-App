class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;
  final String size; // Thêm thuộc tính size


  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.size,
  });

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? quantity,
    double? price,
    String? size, 
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      size: size ?? this.size,
    );
  }
}
