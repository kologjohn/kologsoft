class Productcategorymodel {
  String id = '';
  String productname;

  Productcategorymodel({
    this.id = '',
    this.productname = ''
});
  Map<String, dynamic> toMap (){
    return {
      'id': id,
      'productname': productname,
    };
  }
  factory Productcategorymodel.fromJson(Map<String, dynamic> json) {
    return Productcategorymodel(
      id: json['id'] ?? '',
      productname: json['productname'] ?? '',

    );
  }
}