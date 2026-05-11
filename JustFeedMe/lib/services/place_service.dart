import 'dart:convert';
import 'dart:math' show cos, sqrt, asin, Random;
import 'package:http/http.dart' as http;
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/services/storage_service.dart';
import 'package:forkit_mobile/utils/opening_hours_parser.dart';

class PlaceService {
  // Overpass API Endpoint
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Haversine formula to calculate distance in meters
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * 
        (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * 1000 * asin(sqrt(a)); // 2 * R * asin... R = 6371km
  }

  static Future<List<Place>> fetchNearbyPlaces(Coordinates userLocation, FilterState filter) async {
    print('🔍 PlaceService (OSM): Fetching nearby places for ${userLocation.lat}, ${userLocation.lng}');
    
    // Construct Overpass QL Query
    // We fetch nodes with generic amenities
    String types = '"amenity"~"restaurant|cafe|fast_food|bar|pub|ice_cream|food_court|bistro"';
    
    final double radius = filter.distance.meters.toDouble();
    
    // Query: [out:json]; node(around:RADIUS,LAT,LON)[TYPES]; out;
    final String query = '[out:json];node(around:$radius,${userLocation.lat},${userLocation.lng})[$types];out;';
    
    print('ℹ️ Overpass Query: $query');

    try {
      http.Response? response;
      int retries = 0;
      while (retries < 3) {
        try {
          response = await http.post(
            Uri.parse(_overpassUrl),
            body: {'data': query}, 
          ).timeout(const Duration(seconds: 10)); // 10s timeout
          
          if (response.statusCode == 200) break;
          if (response.statusCode == 429 || response.statusCode == 504) {
            // Too many requests or timeout, wait and retry
            print('⚠️ Overpass busy, retrying... ($retries)');
            await Future.delayed(const Duration(seconds: 2));
          }
        } catch (e) {
             print('⚠️ Network error during fetch, retrying... ($retries)');
             await Future.delayed(const Duration(seconds: 1));
        }
        retries++;
      }
      
      if (response == null || response.statusCode != 200) {
        print('❌ PlaceService API Error (Final): ${response?.statusCode} - ${response?.body}');
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes)); 
      final List<dynamic> elements = data['elements'] ?? [];
      final blacklist = await StorageService.getBlacklist();

      print('✅ PlaceService: Received ${elements.length} raw elements from OSM');

      List<Place> results = elements.map((json) {
        final id = json['id'].toString();
        final tags = json['tags'] ?? {};
        
        // --- 1. Basic Info ---
        final name = tags['name'] ?? '未知名稱 (${tags['amenity'] ?? '店'})';
        final lat = json['lat'];
        final lon = json['lon'];
        
        // --- 2. Address Construction ---
        String address = '';
        if (tags['addr:city'] != null) address += tags['addr:city'] + ' ';
        if (tags['addr:street'] != null) address += tags['addr:street'];
        if (tags['addr:housenumber'] != null) address += tags['addr:housenumber'];
        if (address.isEmpty) address = '未知地址';

        // --- 3. Categories / Cuisine Parsing ---
        List<String> categories = [];
        if (tags['cuisine'] != null) {
          categories.addAll(tags['cuisine'].toString().split(';'));
          // Translate common cuisine names to Chinese if possible, or keep English
        } else {
          categories.add(tags['amenity'] ?? 'restaurant');
        }

        // --- 4. Intelligent Photo Matching ---
        // Use the most specific category to map to a photo keyword
        String photoKeyword = 'food';
        if (categories.isNotEmpty) {
           String firstCat = categories.first.toLowerCase().trim();
           if (firstCat.contains('coffee') || firstCat.contains('cafe')) photoKeyword = 'coffee';
           else if (firstCat.contains('burger') || firstCat.contains('fast_food')) photoKeyword = 'burger';
           else if (firstCat.contains('pixel') || firstCat.contains('pizza')) photoKeyword = 'pizza';
           else if (firstCat.contains('noodle') || firstCat.contains('ramen')) photoKeyword = 'ramen';
           else if (firstCat.contains('sushi') || firstCat.contains('japanese')) photoKeyword = 'sushi';
           else if (firstCat.contains('bar') || firstCat.contains('pub')) photoKeyword = 'cocktail';
           else if (firstCat.contains('ice_cream') || firstCat.contains('dessert')) photoKeyword = 'dessert';
           else photoKeyword = firstCat; // Fallback to the category name itself
        }
        
        // Use Unsplash source with specific keywords (still free and better quality than others)
        // Or picsum with seed for consistency
        // Let's use specific resolution from unsplash source for variety
        // --- 4. Photo Logic ---
        // User requested NO random default photos. Only real photos or "No Image".
        // OSM mostly doesn't have photos, but sometimes 'image' tag exists.
        String photoUrl = '';
        if (tags['image'] != null) {
          photoUrl = tags['image'];
        } 
        
        // Note: previous random generator removed as per user request.

        // --- 5. Data Parsing (Opening Hours & Website) ---
        
        bool isOpen = true; // Default to open if unknown
        final rawHours = tags['opening_hours'];
        
        if (rawHours != null) {
           // Try to parse real status
           final realStatus = OpeningHoursParser.isOpenNow(rawHours.toString());
           if (realStatus != null) {
             isOpen = realStatus;
           } else {
             // Failed to parse, assume open to be safe (or maybe we should mark as unknown?)
             // For now, keep as true.
           }
        }

        // Website parsing could be added to the Place model if we had a field for it
        // String? website = tags['website'] ?? tags['contact:website'];

        // --- 6. AI Match Score (Consistent per ID) ---
        // Use ID to seed random number generator so score stays consistent for the same shop
        final seed = int.tryParse(id) ?? name.hashCode;
        final random = Random(seed); 
        
        // Match Score: 75% - 99%
        final matchScore = 75 + random.nextInt(25); 
        
        // Budget Guessing
        BudgetLevel budget = BudgetLevel.MEDIUM; 
        if (tags['amenity'] == 'fast_food' || categories.contains('burger')) budget = BudgetLevel.CHEAP;
        if (categories.contains('steak_house') || categories.contains('fine_dining')) budget = BudgetLevel.EXPENSIVE;

        final place = Place(
          id: id,
          name: name,
          matchScore: matchScore,
          location: Coordinates(lat: lat, lng: lon),
          address: address,
          isOpen: isOpen,
          budget: budget,
          categories: categories,
          photoUrl: photoUrl,
        );

        place.distance = calculateDistance(
          userLocation.lat,
          userLocation.lng,
          place.location.lat,
          place.location.lng,
        );
        
        return place;
      }).where((place) {
        // 1. Blacklist check
        if (blacklist.contains(place.id)) return false;

        // 2. Open now check
        if (filter.onlyOpen && !place.isOpen) return false;

        // 3. Rating check (Deprecated, assumed all are good matches)
        // if (place.matchScore < filter.minMatchScore) return false;

        // 4. Budget check
        if (filter.budget != null && place.budget.value > filter.budget!.value) return false;

        // 5. Category check (Meal Time Compatibility)
        // Check if the place's categories (amenity or cuisine) match the selected MealTime
        final allowedTypes = MEAL_CATEGORY_MAP[filter.mealTime];
        if (allowedTypes != null) {
          bool isMealTimeMatch = place.categories.any((cat) => 
             allowedTypes.any((allowed) => cat.toLowerCase().contains(allowed))
          );
          if (!isMealTimeMatch) return false;
        }

        // 6. Explicit Category Filter (Multi-select)
        if (filter.cuisineTypes.isNotEmpty) {
           // We need to map Chinese UI terms back to OSM tags/categories if possible
           // or just check against place.categories (which we might have translated content in if we did that, but currently they are mostly English/Raw tags)
           // Simple fuzzy match for now.
           
           // Defines a simple map for Chinese -> English keywords
           final kwMap = {
             '中餐': ['chinese', 'asian'],
             '日式': ['japanese', 'sushi', 'ramen', 'izakaya'],
             '韓式': ['korean', 'bibimbap'],
             '台式': ['taiwanese', 'noodle', 'beef_noodle', 'dumpling'],
             '義式': ['italian', 'pizza', 'pasta'],
             '法式': ['french', 'bistro'],
             '美式': ['american', 'burger', 'steak', 'diner'],
             '泰式': ['thai'],
           };

           bool hasMatch = false;
           for (var type in filter.cuisineTypes) {
             final keywords = kwMap[type] ?? [type]; // Fallback to using the type itself
             
             // Check if place categories contain any of these keywords
             if (place.categories.any((cat) => 
                keywords.any((k) => cat.toLowerCase().contains(k.toLowerCase())))) {
               hasMatch = true;
               break;
             }
           }
           if (!hasMatch) return false;
        }

        // 7. Custom Cuisine Filter
        if (filter.customCuisine != null && filter.customCuisine!.isNotEmpty) {
           final query = filter.customCuisine!.toLowerCase();
           // Check name or categories
           bool nameMatch = place.name.toLowerCase().contains(query);
           bool catMatch = place.categories.any((c) => c.toLowerCase().contains(query));
           if (!nameMatch && !catMatch) return false;
        }
        
        return true;
      }).toList();

      // Sort by distance
      results.sort((a, b) => a.distance!.compareTo(b.distance!));

      // Limit to 20
      if (results.length > 20) {
        results = results.sublist(0, 20);
      }

      print('✅ PlaceService: Found ${results.length} valid places');
      return results;
    } catch (e) {
      print('❌ PlaceService Error: $e');
      return [];
    }
  }
}

// Map specific OSM tags (amenity/cuisine) to Meal Times
final Map<MealTime, List<String>> MEAL_CATEGORY_MAP = {
  MealTime.BREAKFAST: [
    'cafe', 'bakery', 'breakfast', 'coffee', 'tea'
  ],
  MealTime.LUNCH: [
    'restaurant', 'fast_food', 'burger', 'pizza', 'noodles', 'diner', 'food_court'
  ],
  MealTime.DINNER: [
    'restaurant', 'steak_house', 'bar', 'pub', 'japanese', 'italian', 'sushi', 'bbq', 'seafood'
  ],
  MealTime.AFTERNOON_TEA: [
    'cafe', 'bakery', 'ice_cream', 'dessert', 'cake', 'sweet'
  ],
  MealTime.SNACK: [
    'fast_food', 'ice_cream', 'bubble_tea', 'snack', 'street_food'
  ],
  MealTime.LATE_NIGHT: [
    'bar', 'pub', 'nightclub', 'izakaya', 'fast_food', 'restaurant', 'cafe', 'convenience'
  ]
};
