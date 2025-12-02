class ProductEntity {
  final int? id;         
  final int? remoteId;   
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;

  ProductEntity({
    this.id,
    this.remoteId,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });
}
