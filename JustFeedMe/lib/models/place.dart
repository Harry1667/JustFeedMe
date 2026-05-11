
// ignore_for_file: constant_identifier_names

enum MealTime {
  BREAKFAST('早餐'),
  LUNCH('午餐'),
  AFTERNOON_TEA('下午茶'),
  DINNER('晚餐'),
  LATE_NIGHT('宵夜'),
  SNACK('點心');

  final String label;
  const MealTime(this.label);
}

enum BudgetLevel {
  CHEAP(1), // $ (<100)
  MEDIUM(2), // $$ (100-300)
  EXPENSIVE(3); // $$$ (>300)

  final int value;
  const BudgetLevel(this.value);
}

enum DistanceRange {
  NEARBY(300, '走兩步就到'),    // < 300m
  HUNDRED(100, '100公尺'),     // 100m
  FIVE_HUNDRED(500, '500公尺'), // 500m
  ONE_KM(1000, '1公里'),       // 1km
  UNLIMITED(10000, '1公里外'); // > 1km

  final int meters;
  final String label;
  const DistanceRange(this.meters, this.label);
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(lat: json['lat'], lng: json['lng']);
  }
}

class Place {
  final String id;
  final String name;
  final int matchScore; // AI Match Score (0-100)
  final Coordinates location;
  final String address;
  final bool isOpen;
  final BudgetLevel budget;
  final List<String> categories;
  final String photoUrl;
  double? distance; // Calculated at runtime

  Place({
    required this.id,
    required this.name,
    required this.matchScore,
    required this.location,
    required this.address,
    required this.isOpen,
    required this.budget,
    required this.categories,
    required this.photoUrl,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'matchScore': matchScore,
      'location': location.toJson(),
      'address': address,
      'isOpen': isOpen,
      'budget': budget.index,
      'categories': categories,
      'photoUrl': photoUrl,
      'distance': distance,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      matchScore: json['matchScore'],
      location: Coordinates.fromJson(json['location']),
      address: json['address'],
      isOpen: json['isOpen'],
      budget: BudgetLevel.values[json['budget']],
      categories: List<String>.from(json['categories']),
      photoUrl: json['photoUrl'],
      distance: json['distance'],
    );
  }
}

// CoordinatesSerialization extension removed

class FilterState {
  MealTime mealTime;
  List<String> cuisineTypes; // Renamed from categories for clarity
  String? customCuisine;
  BudgetLevel? budget;
  DistanceRange distance;
  bool onlyOpen;
  // deprecated: minRating/minMatchScore

  FilterState({
    required this.mealTime,
    this.cuisineTypes = const [],
    this.customCuisine,
    this.budget,
    required this.distance,
    this.onlyOpen = true,
  });
}
