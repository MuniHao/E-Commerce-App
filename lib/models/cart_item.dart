class CartItem {
  final String? id;
  final String productId; // Lưu thêm sản phẩm, thay vì chỉ lưu image sản phẩm
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;
  final String size; // Thêm thuộc tính size
  final String state; //Quản lý trạng thái

  CartItem({
    this.id,
    required this.productId,
    required this.title,
    this.imageUrl = '',
    required this.quantity,
    required this.price,
    required this.size,
    this.state = 'waiting' //complete 
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    int? quantity,
    double? price,
    String? size,
    String? state,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      size: size ?? this.size,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
      'size': size,
      'state': state,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      title: json['title'],
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'],
      price: json['price'],
      size: json['size'],
      state: json['state'] ?? 'waiting',
    );
  }

}
