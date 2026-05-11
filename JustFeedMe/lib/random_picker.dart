
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/restaurant_card.dart';
import 'package:forkit_mobile/services/ai_service.dart';
import 'package:forkit_mobile/services/place_service.dart';
import 'package:forkit_mobile/services/settings_service.dart';
import 'package:forkit_mobile/services/storage_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RandomPicker extends StatefulWidget {
  final Coordinates userLocation;
  final FilterState filter;

  const RandomPicker({super.key, required this.userLocation, required this.filter});

  @override
  State<RandomPicker> createState() => _RandomPickerState();
}

class _RandomPickerState extends State<RandomPicker> with SingleTickerProviderStateMixin {
  List<Place> _places = [];
  Place? _currentPlace;
  bool _spinning = false;
  bool _hasResult = false;
  String _aiComment = '';
  int _retryCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print('🎰 RandomPicker Initialized');
    _loadAndSpin();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndSpin() async {
    print('🔍 Fetching places for random picker...');
    try {
      final results = await PlaceService.fetchNearbyPlaces(widget.userLocation, widget.filter);
      if (mounted) {
        setState(() => _places = results);
        if (_places.isNotEmpty) {
          _startSpin();
        } else {
          // No places
          print('⚠️ No places found for random picker');
        }
      }
    } catch (e) {
      print('❌ Error fetching places: $e');
    }
  }

  void _startSpin() {
    if (_places.isEmpty) return;
    print('🔄 Spinning...');
    setState(() {
      _spinning = true;
      _hasResult = false;
      _aiComment = '';
    });

    int index = 0;
    // Fast spin effect
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentPlace = _places[index % _places.length];
      });
      index++;
      
      // Stop after 2 seconds
      if (timer.tick > 20) {
        timer.cancel();
        _stopSpin();
      }
    });
  }

  void _stopSpin() {
    print('🛑 Stop spin');
    final random = Random();
    final winner = _places[random.nextInt(_places.length)];
    setState(() {
      _currentPlace = winner;
      _spinning = false;
      _hasResult = true;
    });
    
    // Save to history
    StorageService.addToHistory(winner);
    
    _generateComment(winner);
  }

  Future<void> _generateComment(Place place) async {
    print('🤖 Generating AI comment...');
    // Show placeholder first
    setState(() {
      _aiComment = 'AI 正在思考...';
    });

    final tone = await SettingsService.getTone();
    // Default to strict if angry mode is triggered by retries? 
    // User requested tone settings, let's respect the setting even if retrying.
    // Or maybe "Strict" tone gets angrier? For now, just use the selected tone.
    
    final comment = await AiService.generateCommentary(place, tone);
    if (mounted) {
      setState(() {
        _aiComment = comment;
      });
    }
  }

  void _retry() {
    print('🔁 User requested retry. Count: $_retryCount');
    setState(() {
      _retryCount++;
    });
    _startSpin();
  }

  @override
  Widget build(BuildContext context) {
    // Angry Mode red tint
    final bgColor = (_retryCount > 3) ? Colors.red.shade50 : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('隨機推薦', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_places.isEmpty && !_spinning) 
               const Expanded(child: Center(child: Text('正在尋找附近的餐廳，請稍等...'))),

            if (_places.isNotEmpty) ...[
               const SizedBox(height: 20),
               // Slot Machine Display
               Expanded(
                 child: Center(
                   child: _currentPlace != null 
                       ? RestaurantCard(
                           place: _currentPlace!,
                           onBlacklist: () {
                             setState(() {
                               _places.removeWhere((p) => p.id == _currentPlace!.id);
                               _currentPlace = null;
                               _hasResult = false;
                               _aiComment = '';
                             });
                             if (_places.isNotEmpty) {
                               _startSpin();
                             }
                           },
                         ) 
                       : const SizedBox(),
                 ),
               ),
               
               const SizedBox(height: 24),

               // AI Commentary Bubble
               if (_hasResult && !_spinning)
                 Container(
                   padding: const EdgeInsets.all(16),
                   margin: const EdgeInsets.only(bottom: 24),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.orange.withOpacity(0.3)),
                     boxShadow: [
                       BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                     ],
                   ),
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Icon(LucideIcons.bot, color: Colors.orange),
                       const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: SingleChildScrollView(
                              child: Text(
                                _aiComment,
                                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                     ],
                   ),
                 ),

               // Buttons
               if (_hasResult && !_spinning)
                 Column(
                   children: [
                     if (_retryCount <= 3)
                       SizedBox(
                         width: double.infinity,
                         height: 56,
                         child: OutlinedButton.icon(
                           onPressed: _retry,
                           icon: const Icon(LucideIcons.refreshCw), 
                           label: const Text('再轉一次'),
                           style: OutlinedButton.styleFrom(
                             foregroundColor: Colors.black87,
                             side: const BorderSide(color: Colors.black12),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                           ),
                         ),
                       )
                     else
                       const Text(
                         '🔥 不要再挑了！就是這家！', 
                         style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)
                       ),
                   ],
                 )
            ]
          ],
        ),
      )
    );
  }


}
