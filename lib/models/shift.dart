class Shift {
  final int? id;
  final int employeeId;
  final String? employeeName;
  final String date;       // "yyyy-MM-dd"
  final String startTime;  // "HH:mm:ss"
  final String endTime;
  final String? description;
  final double? durationHours;

  Shift({
    this.id,
    required this.employeeId,
    this.employeeName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.description,
    this.durationHours,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      description: json['Description'],
      durationHours: json['durationHours'] != null
          ? (json['durationHours'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'Description': description ?? '',
    };
  }

  // display helper — "08:00" from "08:00:00"
  String get startDisplay => startTime.substring(0, 5);
  String get endDisplay => endTime.substring(0, 5);
}