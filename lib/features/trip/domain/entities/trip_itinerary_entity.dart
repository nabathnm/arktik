import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../destination/domain/entities/destination_entity.dart';

class TripItineraryEntity extends Equatable {
  final String id;
  final String tripId;
  final String destinationId;
  final DestinationEntity? destination; // Populated by JOIN
  final DateTime visitDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int orderIndex;
  final DateTime createdAt;

  const TripItineraryEntity({
    required this.id,
    required this.tripId,
    required this.destinationId,
    this.destination,
    required this.visitDate,
    this.startTime,
    this.endTime,
    required this.orderIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        destinationId,
        destination,
        visitDate,
        startTime,
        endTime,
        orderIndex,
        createdAt,
      ];
}
