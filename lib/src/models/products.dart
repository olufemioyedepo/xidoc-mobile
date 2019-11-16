class Product {
  String productNumber;
  String productName;

  Product({this.productNumber, this.productName});

  factory Product.fromJson(Map<String, dynamic> json) {
    return new Product(
      productNumber: json['productNumber'],
      productName: json['productName']
    );
  }
}

class ProductsList {
  List<Product> products;

  ProductsList({this.products});

  factory ProductsList.fromJson(List<dynamic> json){
    List<Product> productsOrderList = new List<Product>();
    productsOrderList = json.map((i) => Product.fromJson(i)).toList();
    return new ProductsList(
      products: productsOrderList
    );
  }
}