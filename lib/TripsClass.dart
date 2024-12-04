class Trips {
  final int id;
  final String title;
  final String location;
  final String description;
  final int rooms;
  final int guests;
  final int bathrooms;
  final int price;
  final String hostName;
  final List<String> amenities;
  final List<String> images;
  final String dates;
  final String address;
  final String checkin;
  final String checkout;
  final String status;
  final List<int> rating;
  final Map<String, dynamic>? tripInfo;

  Trips({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.rooms,
    required this.guests,
    required this.bathrooms,
    required this.price,
    required this.hostName,
    required this.amenities,
    required this.images,
    required this.dates,
    required this.address,
    required this.checkin,
    required this.checkout,
    required this.status,
    required this.rating,
    this.tripInfo
  });

  factory Trips.fromJson(Map<String, dynamic> json) {
    return Trips(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      description: json['description'],
      rooms: json['rooms'],
      guests: json['guests'],
      bathrooms: json['bathrooms'],
      price: json['price'],
      hostName: json['hostname'],
      amenities: List<String>.from(json['amenities']),
      images: List<String>.from(json['images']),
      dates: json['dates'],
      address: json['address'],
      checkin: json['checkin'],
      checkout: json['checkout'],
      status: json['status'],
      rating: List<int>.from(json['rating']),
      tripInfo: json.containsKey('tripInfo') ? Map<String, dynamic>.from(json['tripInfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'rooms': rooms,
      'guests': guests,
      'bathrooms': bathrooms,
      'price': price,
      'hostname': hostName,
      'amenities': amenities,
      'images': images,
      'dates': dates,
      'address': address,
      'checkin': checkin,
      'checkout': checkout,
      'status': status,
      'rating': rating,
    };

    if (tripInfo != null) {
      data['tripInfo'] = tripInfo as Object;
    }

    return data;
  }
}
