class TaxModel {
  TaxModel({
    this.id,
    required this.name,
    required this.shortName,
    required this.taxPercentage,
  });
  int? id;
  String name;
  String shortName;
  double taxPercentage;

  factory TaxModel.fromJson(Map<String, dynamic> json) => TaxModel(
        name: json["name"],
        id: json['id'],
        shortName: json["short_name"],
        taxPercentage: json["tax_percentage"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "short_name": shortName,
        "tax_percentage": taxPercentage,
      };
}
