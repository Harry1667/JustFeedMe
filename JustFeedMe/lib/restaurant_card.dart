
import 'package:flutter/material.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/services/storage_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onBlacklist;

  const RestaurantCard({super.key, required this.place, this.onBlacklist});

  @override
  Widget build(BuildContext context) {
    // Determine color based on match score
    Color scoreColor = Colors.green;
    if (place.matchScore >= 90) scoreColor = Colors.redAccent;
    else if (place.matchScore >= 80) scoreColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 16, 
            offset: const Offset(0, 8),
            spreadRadius: 2
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              // Image (with explicit empty check)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: place.photoUrl.isEmpty 
                  ? _buildNoImagePlaceholder()
                  : Image.network(
                      place.photoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _buildNoImagePlaceholder(),
                      loadingBuilder: (ctx, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
              ),
              // Match Score Badge (Glassmorphism)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                       BoxShadow(color: scoreColor.withOpacity(0.4), blurRadius: 8)
                    ]
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.flame, color: scoreColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${place.matchScore}% Match',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 13,
                          letterSpacing: 0.5
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Open/Closed Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.isOpen ? Colors.green.withOpacity(0.9) : Colors.grey.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    place.isOpen ? '營業中' : '休息中',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w800,
                          height: 1.2
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (place.distance != null)
                       Padding(
                         padding: const EdgeInsets.only(left: 8, top: 2),
                         child: Row(
                           children: [
                             const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                             const SizedBox(width: 4),
                             Text(
                               '${(place.distance! / 1000).toStringAsFixed(1)} km',
                               style: const TextStyle(
                                 color: Colors.grey, 
                                 fontWeight: FontWeight.w600,
                                 fontSize: 13
                               ),
                             ),
                           ],
                         ),
                       )
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tags Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Budget Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          List.generate(place.budget.value, (index) => '\$').join(),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Categories Tags
                      ...place.categories.take(3).map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(color: Colors.grey[700], fontSize: 11),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 12),
                           backgroundColor: Colors.grey[50],
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          print('🚀 Blacklisting ${place.id}: ${place.name}');
                          await StorageService.addToBlacklist(place.id);
                          if (onBlacklist != null) {
                            onBlacklist!();
                          }
                        },
                        icon: const Icon(LucideIcons.ban, size: 18, color: Colors.grey),
                        label: const Text('沒興趣', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16), // Taller button
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _launchMaps(place),
                        icon: const Icon(LucideIcons.navigation, size: 18), 
                        label: const Text('出發導航', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchMaps(Place place) async {
    // Add to History
    StorageService.addToHistory(place);

    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${place.location.lat},${place.location.lng}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch maps');
      }
    } catch (e) {
      print('Error launching maps: $e');
    }
  }
  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.imageOff, color: Colors.grey[400], size: 48),
          const SizedBox(height: 8),
          Text('暫無圖片', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
