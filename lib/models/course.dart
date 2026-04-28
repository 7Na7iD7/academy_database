class Course {
  final int? courseID;
  final String title;
  final int? teacherID;
  final String? teacherName;
  final int? capacity;
  final double? price;

  Course({
    this.courseID,
    required this.title,
    this.teacherID,
    this.teacherName,
    this.capacity,
    this.price,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseID: map['courseID'] ?? map['CourseID'],
      title: map['title'] ?? map['Title'] ?? '',
      teacherID: map['teacherID'] ?? map['TeacherID'],
      teacherName: map['teacherName'] ?? map['TeacherName'],
      capacity: map['capacity'] ?? map['Capacity'] ?? 0,
      price: map['price']?.toDouble() ?? map['Price']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CourseID': courseID,
      'Title': title,
      'TeacherID': teacherID,
      'Capacity': capacity,
      'Price': price,
    };
  }
}
