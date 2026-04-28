class Student {
  final int? studentID;
  final String fullName;
  final String nationalCode;
  final String? phone;
  final String? email;

  Student({
    this.studentID,
    required this.fullName,
    required this.nationalCode,
    this.phone,
    this.email,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentID: map['studentID'] ?? map['StudentID'],
      fullName: map['fullName'] ?? map['FullName'] ?? '',
      nationalCode: map['nationalCode'] ?? map['NationalCode'] ?? '',
      phone: map['phone'] ?? map['Phone'],
      email: map['email'] ?? map['Email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'StudentID': studentID,
      'FullName': fullName,
      'NationalCode': nationalCode,
      'Phone': phone,
      'Email': email,
    };
  }
}
