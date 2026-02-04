import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dream_entry.dart';

class StorageService {
  static const String _dreamsKey = 'dream_entries';

  /// Save a single dream entry to local storage
  Future<void> saveDream(DreamEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing dreams
    final List<DreamEntry> dreams = await getDreams();

    // Add new dream
    dreams.add(entry);

    // Convert to JSON and save
    final List<String> jsonList = dreams.map((dream) => jsonEncode(dream.toJson())).toList();
    await prefs.setStringList(_dreamsKey, jsonList);
  }

  /// Get all dream entries from local storage
  Future<List<DreamEntry>> getDreams() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_dreamsKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      return jsonList
          .map((jsonString) => DreamEntry.fromJson(jsonDecode(jsonString)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending (newest first)
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Get dream entries for a specific date
  Future<List<DreamEntry>> getDreamsByDate(DateTime date) async {
    final List<DreamEntry> allDreams = await getDreams();

    // Normalize the date to compare only year, month, day
    final targetDate = DateTime(date.year, date.month, date.day);

    return allDreams.where((dream) {
      final dreamDate = DateTime(dream.date.year, dream.date.month, dream.date.day);
      return dreamDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Delete a specific dream entry by ID
  Future<void> deleteDream(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing dreams
    final List<DreamEntry> dreams = await getDreams();

    // Remove the dream with matching ID
    dreams.removeWhere((dream) => dream.id == id);

    // Save updated list
    final List<String> jsonList = dreams.map((dream) => jsonEncode(dream.toJson())).toList();
    await prefs.setStringList(_dreamsKey, jsonList);
  }

  /// Clear all dream entries (useful for testing)
  Future<void> clearAllDreams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dreamsKey);
  }

  /// Get all dates that have dream entries (for calendar markers)
  Future<List<DateTime>> getDreamDates() async {
    final List<DreamEntry> dreams = await getDreams();

    return dreams
        .map((dream) => DateTime(dream.date.year, dream.date.month, dream.date.day))
        .toSet() // Remove duplicates
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }
}
