import 'dart:ffi';

class ProductDetails {
  var id;
  final String productName;
  final String image;
  final String price;
  bool isSelected;
  var countNumber;

  ProductDetails({
    this.id,
    required this.productName,
    required this.image,
    required this.price,
    required this.isSelected,
    this.countNumber,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'],
      productName: json['productName'],
      image: json['image'],
      isSelected: json['isSelected'] ?? false,
      price: json['price'],
      countNumber: json['countNumber'],
    );
  }

  static List<ProductDetails> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <ProductDetails>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          ProductDetails.fromJson(json),
        );
      }
    }

    return transactionDetailsList;
  }
}

class CartProduct {
  final int id;
  final String productName;
  final String price;
  var image;
  var countNumber;

  CartProduct(
      {required this.id,
      required this.productName,
      this.countNumber,
      this.image,
      required this.price});
}

class ReceiptProduct {
  final String productName;
  final String price;
  final String countNumber;

  ReceiptProduct(
      {required this.productName,
      required this.countNumber,
      required this.price});
}
