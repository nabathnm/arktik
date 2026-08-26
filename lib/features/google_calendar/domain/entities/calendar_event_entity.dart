class CalendarEventEntity {
  final String id;
  final String? title;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? htmlLink;

  const CalendarEventEntity({
    required this.id,
    this.title,
    this.description,
    this.start,
    this.end,
    this.htmlLink,
  });
}
