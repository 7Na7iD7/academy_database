import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';

class DatabaseService {
  static String get _baseUrl {
    if (kIsWeb || !Platform.isAndroid) {
      return "localhost";
    } else {
      return "------";
    }
  }

  static Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/courses'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Course.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Student?> getStudentByNationalCode(String nationalCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/students'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        var students = body.map((item) => Student.fromMap(item)).toList();
        try {
          return students.firstWhere((s) => s.nationalCode == nationalCode);
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> addStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/students'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(student.toMap()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<String> enrollStudent(int studentID, int courseID) async {
    try {
      final Map<String, dynamic> data = {
        'StudentID': studentID,
        'CourseID': courseID,
        'EnrollDate': DateTime.now().toIso8601String(),
        'IsPaid': true
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/enrollments'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return "ثبت‌نام با موفقیت انجام شد";
      } else {
        return "خطا در ثبت‌نام: ${response.body}";
      }
    } catch (e) {
      return "خطا در ارتباط با سرور";
    }
  }

  static Future<List<Enrollment>> getAllEnrollments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/enrollments'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Enrollment.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, int>> getDashboardStats() async {
    try {
      final sRes = await http.get(Uri.parse('$_baseUrl/students'));
      final cRes = await http.get(Uri.parse('$_baseUrl/courses'));
      final eRes = await http.get(Uri.parse('$_baseUrl/enrollments'));

      int s = sRes.statusCode == 200 ? (jsonDecode(sRes.body) as List).length : 0;
      int c = cRes.statusCode == 200 ? (jsonDecode(cRes.body) as List).length : 0;
      int e = eRes.statusCode == 200 ? (jsonDecode(eRes.body) as List).length : 0;

      return {'students': s, 'courses': c, 'enrollments': e};
    } catch (ex) {
      return {'students': 0, 'courses': 0, 'enrollments': 0};
    }
  }
}