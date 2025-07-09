class Mall {
  final int id;
  final String name;
  double rating;
  int commentCount;
  final String? city;
  final String? district;
  final String? photoUrl;
  final String? address;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  Mall({
    required this.id,
    required this.name,
    required this.rating,
    required this.commentCount,
    this.city,
    this.district,
    this.photoUrl,
    this.address,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  factory Mall.fromJson(Map<String, dynamic> json) {
    return Mall(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      commentCount: int.tryParse(json['comment_count'].toString()) ?? 0,
      city: json['city'],
      district: json['district'],
      photoUrl: json['photo_url'],
      address: json['address'],
      websiteUrl: json['website_url'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }
}
