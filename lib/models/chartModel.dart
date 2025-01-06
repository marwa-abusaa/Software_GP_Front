// Model for each chart data point
class ProgressData {
  final String month;
  final int count;

  ProgressData(this.month, this.count);

  // Factory constructor to create an instance from JSON
  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      json['month'] as String,
      json['count'] as int,
    );
  }

  // Optional: Method to convert an instance to JSON (useful for POST requests)
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'count': count,
    };
  }
}
