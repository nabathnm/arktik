import 'package:flutter/foundation.dart';
import 'package:rantau/features/google_calendar/domain/entities/availability_entity.dart';
import 'package:rantau/features/google_calendar/domain/usecases/get_availability.dart';

enum AvailabilityState { initial, loading, loaded, empty, error }

class AvailabilityProvider extends ChangeNotifier {
  final GetAvailability getAvailabilityUseCase;

  AvailabilityProvider(this.getAvailabilityUseCase);

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;

  AvailabilityState _state = AvailabilityState.initial;
  AvailabilityState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // In-memory cache for availability
  // Key: "yyyy-MM-dd"
  final Map<String, List<AvailabilityEntity>> _availabilityCache = {};

  List<AvailabilityEntity> get currentAvailability {
    final key = _getDateKey(_selectedDate);
    return _availabilityCache[key] ?? [];
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _currentMonth = DateTime(date.year, date.month, 1);
    
    // Check if we already have cache for this date
    final key = _getDateKey(date);
    if (_availabilityCache.containsKey(key)) {
      _state = _availabilityCache[key]!.isEmpty ? AvailabilityState.empty : AvailabilityState.loaded;
      notifyListeners();
    } else {
      fetchAvailabilityForDate(date);
    }
  }

  void changeMonth(DateTime newMonth) {
    _currentMonth = newMonth;
    notifyListeners();
  }

  Future<void> fetchAvailabilityForDate(DateTime date, {bool forceRefresh = false}) async {
    final key = _getDateKey(date);
    if (!forceRefresh && _availabilityCache.containsKey(key)) {
      return;
    }

    _state = AvailabilityState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Query rentang: 00:00 sampai 23:59 pada hari tersebut (local time, ditangani UseCase/Repo ke UTC)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      final result = await getAvailabilityUseCase(
        start: startOfDay,
        end: endOfDay,
      );

      _availabilityCache[key] = result;
      _state = result.isEmpty ? AvailabilityState.empty : AvailabilityState.loaded;
    } catch (e) {
      _state = AvailabilityState.error;
      _errorMessage = 'Unable to load calendar. Please check your Google Calendar connection.\n\nDetails: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchAvailabilityForDate(_selectedDate, forceRefresh: true);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
