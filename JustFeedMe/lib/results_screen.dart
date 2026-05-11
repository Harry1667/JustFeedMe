
import 'package:flutter/material.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/restaurant_card.dart';
import 'package:forkit_mobile/services/place_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResultsScreen extends StatefulWidget {
  final Coordinates userLocation;
  final FilterState filter;

  const ResultsScreen({super.key, required this.userLocation, required this.filter});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Place> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    print('📂 ResultsScreen Initialized');
    _loadData();
  }

  Future<void> _loadData() async {
    print('🔍 Fetching places...');
    setState(() => _loading = true);
    
    try {
      final results = await PlaceService.fetchNearbyPlaces(widget.userLocation, widget.filter);
      if (mounted) {
        setState(() {
          _places = results;
          _loading = false;
        });
        print('✅ Found ${_places.length} places');
      }
    } catch (e) {
      print('❌ Error fetching places: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('搜尋結果', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('雷達掃描中...', style: TextStyle(color: Colors.grey))
                ],
              ),
            )
          : _places.isEmpty
              ? const Center(child: Text('附近沒有符合條件的餐廳 🥲'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _places.length,
                  itemBuilder: (ctx, index) {
                    return RestaurantCard(
                      place: _places[index],
                      onBlacklist: () {
                        setState(() {
                          _places.removeAt(index);
                        });
                      },
                    );
                  },
                ),
    );
  }
}
