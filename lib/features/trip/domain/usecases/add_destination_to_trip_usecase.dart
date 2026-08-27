import 'package:flutter/material.dart';
import '../entities/trip_itinerary_entity.dart';
import '../repositories/trip_repository.dart';

class AddDestinationToTripUseCase {
  final TripRepository repository;

  AddDestinationToTripUseCase(this.repository);

  Future<TripItineraryEntity> execute({
    required String tripId,
    required String destinationId,
    required DateTime visitDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    // Check for overlap if both times are provided
    if (startTime != null && endTime != null) {
      final existingItineraries = await repository.getTripItineraries(tripId);
      final sameDateItineraries = existingItineraries.where((itinerary) {
        return itinerary.visitDate.year == visitDate.year &&
               itinerary.visitDate.month == visitDate.month &&
               itinerary.visitDate.day == visitDate.day;
      }).toList();

      final newStartMinutes = startTime.hour * 60 + startTime.minute;
      final newEndMinutes = endTime.hour * 60 + endTime.minute;

      if (newEndMinutes <= newStartMinutes) {
        throw Exception('End time must be after start time.');
      }

      for (var itinerary in sameDateItineraries) {
        if (itinerary.startTime != null && itinerary.endTime != null) {
          final existingStartMinutes = itinerary.startTime!.hour * 60 + itinerary.startTime!.minute;
          final existingEndMinutes = itinerary.endTime!.hour * 60 + itinerary.endTime!.minute;

          // Check if overlapping
          bool overlaps = (newStartMinutes < existingEndMinutes) && (newEndMinutes > existingStartMinutes);
          
          if (overlaps) {
            final destName = itinerary.destination?.name ?? 'destinasi lain';
            throw Exception('Jadwal bertabrakan dengan $destName.');
          }
        }
      }
    }

    return repository.addDestinationToTrip(
      tripId: tripId,
      destinationId: destinationId,
      visitDate: visitDate,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
