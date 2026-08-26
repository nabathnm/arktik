enum AvailabilityStatus {
  free,
  busy,
}

class AvailabilityEntity {
  final DateTime start;
  final DateTime end;
  final AvailabilityStatus status;

  const AvailabilityEntity({
    required this.start,
    required this.end,
    required this.status,
  });

  @override
  String toString() => 'AvailabilityEntity(start: $start, end: $end, status: $status)';
}
