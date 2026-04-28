import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/student.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }


  Future<void> _fetch() async {
    final data = await DatabaseService.getAllEnrollments();
    setState(() {
      final uniqueNames = <String>{};
      students = [];
      for (var e in data) {
        if (e.studentName != null && !uniqueNames.contains(e.studentName)) {
          uniqueNames.add(e.studentName!);
          students.add(Student(fullName: e.studentName!, nationalCode: ''));
        }
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لیست دانشجویان', style: GoogleFonts.cairo())),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(students[index].fullName),
          subtitle: const Text('دانشجوی آکادمی'),
        ),
      ),
    );
  }
}