import 'package:flutter/material.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdvancedFilterDialog extends StatefulWidget {
  final FilterState initialFilter;

  const AdvancedFilterDialog({super.key, required this.initialFilter});

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  late DistanceRange _distance;
  late MealTime _mealTime;
  BudgetLevel? _budget;
  final List<String> _selectedCuisines = [];
  final TextEditingController _customCuisineController = TextEditingController();

  // Predefined popular cuisines
  final List<String> _cuisineOptions = [
    '中餐', '日式', '韓式', '台式', '義式', '法式', '美式', '泰式'
  ];

  @override
  void initState() {
    super.initState();
    _distance = widget.initialFilter.distance;
    _mealTime = widget.initialFilter.mealTime;
    _budget = widget.initialFilter.budget;
    _selectedCuisines.addAll(widget.initialFilter.cuisineTypes);
    if (widget.initialFilter.customCuisine != null) {
      _customCuisineController.text = widget.initialFilter.customCuisine!;
    }
  }

  @override
  void dispose() {
    _customCuisineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('篩選搜尋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                   setState(() {
                     _distance = DistanceRange.FIVE_HUNDRED; // Default
                     _mealTime = _getAutoMealTime();
                     _budget = null;
                     _selectedCuisines.clear();
                     _customCuisineController.clear();
                   });
                }, 
                child: const Text('重置', style: TextStyle(color: Colors.grey))
              )
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Location (Distance)
                  _buildSectionTitle('距離範圍'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DistanceRange.values.map((d) {
                      final isSelected = _distance == d;
                      return ChoiceChip(
                        label: Text(d.label),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _distance = d),
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 2. Meal Time
                  _buildSectionTitle('時間餐點 (預設當前)'),
                  DropdownButtonFormField<MealTime>(
                    value: _mealTime,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: MealTime.values.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.label),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _mealTime = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Budget
                  _buildSectionTitle('預算範圍'),
                  Row(
                    children: [
                      _buildBudgetChip(null, '不限'),
                      const SizedBox(width: 8),
                      _buildBudgetChip(BudgetLevel.CHEAP, '\$'),
                      const SizedBox(width: 8),
                      _buildBudgetChip(BudgetLevel.MEDIUM, '\$\$'),
                      const SizedBox(width: 8),
                      _buildBudgetChip(BudgetLevel.EXPENSIVE, '\$\$\$'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Cuisine Type
                  _buildSectionTitle('餐點類型 (可多選)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cuisineOptions.map((c) {
                      final isSelected = _selectedCuisines.contains(c);
                      return FilterChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) _selectedCuisines.add(c);
                            else _selectedCuisines.remove(c);
                          });
                        },
                        selectedColor: Colors.orange[100],
                        checkmarkColor: Colors.orange,
                        labelStyle: TextStyle(color: isSelected ? Colors.orange[900] : Colors.black87),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customCuisineController,
                    decoration: InputDecoration(
                      hintText: '其他 (例如：越南河粉)',
                      prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),

                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),

          // Search Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final filter = FilterState(
                  distance: _distance,
                  mealTime: _mealTime,
                  budget: _budget,
                  cuisineTypes: _selectedCuisines,
                  customCuisine: _customCuisineController.text.isNotEmpty ? _customCuisineController.text : null,
                  onlyOpen: widget.initialFilter.onlyOpen, // Preserve original setting or default
                );
                Navigator.pop(context, filter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('確認搜尋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _buildBudgetChip(BudgetLevel? level, String label) {
    final isSelected = _budget == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _budget = level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.black : Colors.transparent),
          ),
          child: Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isSelected ? Colors.white : Colors.black87
            )
          ),
        ),
      ),
    );
  }

  MealTime _getAutoMealTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return MealTime.BREAKFAST;
    if (hour >= 11 && hour < 14) return MealTime.LUNCH;
    if (hour >= 14 && hour < 17) return MealTime.AFTERNOON_TEA;
    if (hour >= 17 && hour < 21) return MealTime.DINNER;
    if (hour >= 21 || hour < 2) return MealTime.LATE_NIGHT;
    return MealTime.SNACK;
  }
}
