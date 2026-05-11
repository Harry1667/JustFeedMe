import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forkit_mobile/history_screen.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/random_picker.dart';
import 'package:forkit_mobile/results_screen.dart';
import 'package:forkit_mobile/services/settings_service.dart';
import 'package:forkit_mobile/widgets/advanced_filter_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationName = '定位中...';
  Position? _currentPosition;
  late FilterState _filters;

  @override
  void initState() {
    super.initState();
    print('🚀 HomeScreen Initialized');
    _initializeFilters();
    _determinePosition();
  }

  void _initializeFilters() {
    final hour = DateTime.now().hour;
    MealTime currentMeal = MealTime.LUNCH;
    if (hour >= 5 && hour < 10) currentMeal = MealTime.BREAKFAST;
    else if (hour >= 11 && hour < 14) currentMeal = MealTime.LUNCH;
    else if (hour >= 14 && hour < 17) currentMeal = MealTime.AFTERNOON_TEA;
    else if (hour >= 17 && hour < 21) currentMeal = MealTime.DINNER;
    else if (hour >= 21 || hour < 4) currentMeal = MealTime.LATE_NIGHT;
    else currentMeal = MealTime.SNACK; // For other times (e.g. 10-11, 4-5am) or fallback

    // Default distance logic
    _filters = FilterState(
      mealTime: currentMeal,
      distance: DistanceRange.FIVE_HUNDRED, // Default 500m
    );
    print('🕒 Initial MealTime: $currentMeal');
  }

  Future<void> _determinePosition() async {
    print('🔧 Starting location check...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationName = '定位服務未開啟');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationName = '權限被拒決');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationName = '權限被永久拒決');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    print('📍 Current Position: ${position.latitude}, ${position.longitude}');
    setState(() {
      _currentPosition = position;
      _locationName = '已定位 (目前位置)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(LucideIcons.mapPin, color: Colors.black87, size: 16),
             const SizedBox(width: 8),
             Text(
               _locationName,
               style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
             ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black87),
            onPressed: _showSettingsDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'JustFeedMe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '今天吃什麼？只需一秒決定',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            
            // 1. Filter Search Button
            _buildMainButton(
               title: '篩選搜尋',
               subtitle: '想吃特定的？設好條件我們幫你找',
               icon: LucideIcons.sliders,
               color: Colors.black,
               textColor: Colors.white,
               onTap: _onFilterSearch,
            ),
            
            const SizedBox(height: 16),
            
            // 2. Random Recommendation
            _buildMainButton(
               title: '隨機推薦',
               subtitle: '選擇困難？交給命運決定！',
               icon: LucideIcons.zap,
               color: Colors.white,
               textColor: Colors.black,
               borderColor: Colors.grey[300],
               onTap: _onRandomSearch,
            ),
            
            const SizedBox(height: 16),

            // 3. History Button
            _buildMainButton(
               title: '歷史紀錄',
               subtitle: '回顧你的美食足跡',
               icon: LucideIcons.history,
               color: Colors.white,
               textColor: Colors.black,
               borderColor: Colors.grey[300],
               onTap: _onHistory,
            ),
            
            const Spacer(flex: 2),
            // Version removed from here
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: borderColor != null ? Border.all(color: borderColor) : null,
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 20,
               offset: const Offset(0, 10),
             ),
           ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Future<void> _onFilterSearch() async {
    print('User tapped Filter Search');
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('定位中...請稍後')));
       await _determinePosition(); // Retry
       if (_currentPosition == null) return;
    }

    // Show Custom Filter Dialog
    final result = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdvancedFilterDialog(initialFilter: _filters),
    );

    if (result != null) {
       if (!mounted) return;
       setState(() {
         _filters = result;
       });
       // Go to results
       Navigator.of(context).push(
         MaterialPageRoute(builder: (_) => ResultsScreen(
           userLocation: Coordinates(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude),
           filter: _filters,
         ))
       );
    }
  }

  void _onRandomSearch() {
    print('User tapped Random Search');
     if (_currentPosition == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('定位中...請稍後')));
       return;
     }
     
     Navigator.of(context).push(
       MaterialPageRoute(builder: (_) => RandomPicker(
         userLocation: Coordinates(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude),
         filter: _filters,
       ))
     );
  }

  void _onHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen())
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(LucideIcons.settings, size: 20),
            SizedBox(width: 8),
            Text('設定'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI 評論風格', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<AiTone>(
              future: SettingsService.getTone(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                
                // Using DropdownButtonFormField for better styling
                 return DropdownButtonFormField<AiTone>(
                   value: snapshot.data,
                   decoration: InputDecoration(
                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   items: AiTone.values.map((tone) {
                     return DropdownMenuItem<AiTone>(
                       value: tone,
                       child: Text(SettingsService.getToneLabel(tone)),
                     );
                   }).toList(),
                   onChanged: (value) async {
                     if (value != null) {
                        await SettingsService.saveTone(value);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已切換為：${SettingsService.getToneLabel(value)}'))
                        );
                     }
                   },
                 );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'v1.1.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

