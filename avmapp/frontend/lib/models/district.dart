class District {
  final int id;
  final int cityId;
  final String name;

  District({required this.id, required this.cityId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
    );
  }
}
