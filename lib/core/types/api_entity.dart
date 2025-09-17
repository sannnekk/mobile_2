class ApiEntity {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ApiEntity({required this.id, required this.createdAt, this.updatedAt});
}
