class Enrollment {
  final int? enrollmentID;
  final int? studentID;    // ✅ nullable شد
  final int? courseID;     // ✅ nullable شد
  final DateTime? enrollDate;  // ✅ nullable شد
  final bool isPaid;
  final String? studentName;
  final String? courseTitle;

  Enrollment({
    this.enrollmentID,
    this.studentID,      // ✅ required برداشته شد
    this.courseID,       // ✅ required برداشته شد
    this.enrollDate,     // ✅ required برداشته شد
    required this.isPaid,
    this.studentName,
    this.courseTitle,
  });

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      enrollmentID: map['enrollmentID'] ?? map['EnrollmentID'],
      studentID: map['studentID'] ?? map['StudentID'],
      courseID: map['courseID'] ?? map['CourseID'],
      enrollDate: map['enrollDate'] != null
          ? DateTime.parse(map['enrollDate'])
          : (map['EnrollDate'] != null ? DateTime.parse(map['EnrollDate']) : null),
      isPaid: map['isPaid'] == true || map['IsPaid'] == 1 || map['IsPaid'] == true,
      studentName: map['studentName'] ?? map['StudentName'],
      courseTitle: map['courseTitle'] ?? map['CourseTitle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'EnrollmentID': enrollmentID,
      'StudentID': studentID,
      'CourseID': courseID,
      'EnrollDate': enrollDate?.toIso8601String(),
      'IsPaid': isPaid ? 1 : 0,
    };
  }
}
