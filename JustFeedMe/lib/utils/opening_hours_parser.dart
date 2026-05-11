import 'package:flutter/material.dart';

class OpeningHoursParser {
  /// Checks if the place is open right now based on OSM opening_hours string.
  /// Returns null if unknown/unparsable.
  static bool? isOpenNow(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) return null;
    
    final now = DateTime.now();
    final dayStr = _getDayString(now.weekday); // Mo, Tu, We...
    final timeNow = TimeOfDay.fromDateTime(now);

    final raw = openingHours.replaceAll(' ', ''); // Remove spaces for easier parsing

    // Case 1: "24/7"
    if (raw.contains('24/7')) return true;

    // Case 2: Daily range "09:00-21:00" (Implicit every day)
    // Matches "09:00-21:00" or "09:00-21:00,10:00-14:00"
    // But we need to be careful not to match "Mo-Fr09:00-21:00" if today is Sat
    
    // Split by semicolon for rules: "Mo-Fr 08:00-12:00; Sa 10:00-14:00"
    final rules = openingHours.split(';');
    
    for (var rule in rules) {
      rule = rule.trim();
      if (rule.isEmpty) continue;

      // Check date part "Mo-Fr" or "Sa"
      // If no date part, assume everyday
      bool matchesDay = false;
      String timePart = rule;

      if (_hasDaySpecification(rule)) {
        if (_ruleMatchesToday(rule, dayStr)) {
          matchesDay = true;
          // Extract time part: remove the day part
          // Simple heuristic: split by space, take the last part usually? 
          // OSM format is tricky. Let's try to find the time range pattern.
        }
      } else {
        matchesDay = true; // No day specified = every day
      }

      if (matchesDay) {
        // Parse time ranges: "09:00-14:00,17:00-20:00"
        final timeRanges = _extractTimeRanges(rule);
        for (var range in timeRanges) {
          if (_isTimeInRange(timeNow, range)) return true;
        }
        
        // If we matched the day but no time range matched, and there ARE time ranges, then it's closed for this rule.
        // But there might be other rules? Usually rules are additive or override.
        // Simplification: if we found a rule for Today, and time doesn't match, we assume closed?
        // Let's safe bet: returns false if we found strictly matching day rule but wrong time.
        if (timeRanges.isNotEmpty) {
           // We found a rule for today, but current time didn't match any range in it.
           // Check if there are other rules for today? Usually not in simple OSM tags.
           return false;
        }
      }
    }

    // If we parsed rules but none matched today (e.g. only "Mo-Fr" and today is Su), return false?
    // Or return null (unknown)?
    // If the string had distinct day rules and none matched today, it's likely closed.
    if (_hasDaySpecification(openingHours)) return false;

    // Fallback
    return null;
  }

  static String _getDayString(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }

  static bool _hasDaySpecification(String rule) {
    return rule.contains(RegExp(r'(Mo|Tu|We|Th|Fr|Sa|Su|PH)'));
  }

  static bool _ruleMatchesToday(String rule, String activeDay) {
    // "Mo-Fr"
    if (rule.contains('-')) {
       // Range logic is complex (Mo-Fr), simplifying:
       // If it contains exact day string, good.
       // We need a proper range parser or regex.
       
       // Regex for ranges like Mo-Fr, Mo-Sa
       final match = RegExp(r'([A-Za-z]{2})-([A-Za-z]{2})').firstMatch(rule);
       if (match != null) {
         final start = _dayToInt(match.group(1)!);
         final end = _dayToInt(match.group(2)!);
         final current = _dayToInt(activeDay);
         if (start <= end) {
           return current >= start && current <= end;
         } else {
           // Wrap around? Su-Tu
           return current >= start || current <= end;
         }
       }
    }
    
    // "Mo,We,Fr"
    return rule.contains(activeDay);
  }

  static int _dayToInt(String day) {
    switch (day) {
      case 'Mo': return 1;
      case 'Tu': return 2;
      case 'We': return 3;
      case 'Th': return 4;
      case 'Fr': return 5;
      case 'Sa': return 6;
      case 'Su': return 7;
      default: return 0;
    }
  }

  static List<String> _extractTimeRanges(String rule) {
    // Matches 09:00-17:00 or 09:00-17:00+
    final regex = RegExp(r'\d{1,2}:\d{2}-\d{1,2}:\d{2}');
    return regex.allMatches(rule).map((m) => m.group(0)!).toList();
  }

  static bool _isTimeInRange(TimeOfDay now, String range) {
    // "09:30-14:00"
    final parts = range.split('-');
    final start = _parseTime(parts[0]);
    final end = _parseTime(parts[1]);

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    var endMinutes = end.hour * 60 + end.minute;

    if (endMinutes < startMinutes) {
      // Crosses midnight, e.g. 23:00-02:00
      // If now is 23:30 (start <= now) OR now is 01:00 (now <= end)
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
