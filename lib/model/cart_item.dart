class CartItem {
  final int productId;
  final String productName;
  final String price;
  final int countNumber;
  final String image;

  //   widget.product.id,
  // widget.product.price,
  // widget.product.image,
  // widget.product.countNumber,
  // widget.product.productName,

  CartItem(
      {required this.productId,
      required this.productName,
      required this.countNumber,
      required this.price,
      required this.image});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      productName: json['productName'],
      countNumber: json['countNumber'],
      price: json['price'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'countNumber': countNumber,
      'price': price,
      'image': image,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      countNumber: map['countNumber'],
      price: map['price'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'countNumber': countNumber,
      'price': price,
      'image': image,
    };
  }

  static List<CartItem> fromJsonList(dynamic jsonList) {
    final cartItemList = <CartItem>[];
    if (jsonList == null) return cartItemList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        cartItemList.add(
          CartItem.fromJson(json),
        );
      }
    }

    return cartItemList;
  }
}
