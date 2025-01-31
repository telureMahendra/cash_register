import 'dart:ffi';

import 'package:flutter/foundation.dart';

class CalculatorItem {
  var itemName;
  var price;
  CalculatorItem({this.itemName, this.price});
}

class ProductDetails {
  var id;
  final String productName;
  final String image;
  final String price;
  bool isSelected;
  var countNumber;
  var productCategory;
  var measurementUnit;
  var gstSlab;
  var qty;

  ProductDetails({
    this.id,
    required this.productName,
    required this.image,
    required this.price,
    required this.isSelected,
    this.countNumber,
    this.productCategory,
    this.measurementUnit,
    this.gstSlab,
    this.qty,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'],
      productName: json['productName'],
      image: json['image'],
      isSelected: json['isSelected'] ?? false,
      price: json['price'],
      countNumber: json['countNumber'],
      productCategory: json['productCategory'],
      measurementUnit: json['measurementUnit'],
      gstSlab: json['gstSlab'],
      qty: json['qty'],
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
  var price;
  var image;
  var countNumber;

  CartProduct(
      {required this.id,
      required this.productName,
      this.countNumber,
      this.image,
      this.price});
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
