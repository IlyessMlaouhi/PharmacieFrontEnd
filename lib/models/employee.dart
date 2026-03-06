class Employee {
  final int? id;
  final String name;
  final String occupation;
  final String email;
  final String phone;
  final double weeklyHours;

  Employee({
    this.id,
    required this.name,
    required this.occupation,
    required this.email,
    required this.phone,
    required this.weeklyHours,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      occupation: json['occupation'],
      email: json['email'],
      phone: json['phone'],
      weeklyHours: (json['weeklyHours'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'occupation': occupation,
      'email': email,
      'phone': phone,
      'weeklyHours': weeklyHours,
    };
  }
}