class Teacher {
  final int? teacherID;
  final String teacherName;
  final String? expertise;
  final double? salaryPerCourse;

  Teacher({
    this.teacherID,
    required this.teacherName,
    this.expertise,
    this.salaryPerCourse,
  });

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      teacherID: map['TeacherID'],
      teacherName: map['TeacherName'] ?? '',
      expertise: map['Expertise'],
      salaryPerCourse: map['SalaryPerCourse']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'TeacherID': teacherID,
      'TeacherName': teacherName,
      'Expertise': expertise,
      'SalaryPerCourse': salaryPerCourse,
    };
  }
}