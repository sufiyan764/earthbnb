class Property {
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

  Property({
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
    required this.rating, required checkIn,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
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
      rating: List<int>.from(json['rating']), checkIn: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
