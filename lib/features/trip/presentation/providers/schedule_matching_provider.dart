import 'package:flutter/material.dart';
import '../../domain/entities/candidate_date_entity.dart';
import '../../domain/usecases/find_available_dates_usecase.dart';
import '../../domain/usecases/select_trip_date_usecase.dart';

enum ScheduleMatchingStatus { initial, loading, loaded, error }

class ScheduleMatchingProvider extends ChangeNotifier {
  final FindAvailableDatesUseCase findAvailableDatesUseCase;
  final SelectTripDateUseCase selectTripDateUseCase;

  ScheduleMatchingProvider({
    required this.findAvailableDatesUseCase,
    required this.selectTripDateUseCase,
  });

  ScheduleMatchingStatus _status = ScheduleMatchingStatus.initial;
  ScheduleMatchingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CandidateDateEntity> _candidateDates = [];
  List<CandidateDateEntity> get candidateDates => _candidateDates;

  DateTime? _searchStartDate;
  DateTime? get searchStartDate => _searchStartDate;

  DateTime? _searchEndDate;
  DateTime? get searchEndDate => _searchEndDate;

  void _setStatus(ScheduleMatchingStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  void setSearchPeriod(DateTime start, DateTime end) {
    _searchStartDate = start;
    _searchEndDate = end;
    notifyListeners();
  }

  Future<void> findAvailableDates(String tripId) async {
    if (_searchStartDate == null || _searchEndDate == null) {
      _setStatus(ScheduleMatchingStatus.error, error: 'Search period not set.');
      return;
    }

    _setStatus(ScheduleMatchingStatus.loading);
    try {
      _candidateDates = await findAvailableDatesUseCase.execute(
        tripId: tripId,
        searchStartDate: _searchStartDate!,
        searchEndDate: _searchEndDate!,
      );
      _setStatus(ScheduleMatchingStatus.loaded);
    } catch (e) {
      _setStatus(ScheduleMatchingStatus.error, error: e.toString());
    }
  }

  Future<void> selectTripDateRange(String tripId, DateTime startDate, DateTime endDate) async {
    _setStatus(ScheduleMatchingStatus.loading);
    try {
      await selectTripDateUseCase.execute(
        tripId: tripId,
        startDate: startDate,
        endDate: endDate,
      );
      _setStatus(ScheduleMatchingStatus.loaded);
    } catch (e) {
      _setStatus(ScheduleMatchingStatus.error, error: e.toString());
      rethrow;
    }
  }
}
