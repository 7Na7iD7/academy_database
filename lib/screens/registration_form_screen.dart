import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/student.dart';
import '../models/course.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  List<Course> courses = [];
  Course? selectedCourse;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    var data = await DatabaseService.getCourses();
    setState(() {
      courses = data;
    });
  }

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCourse == null) {
      _showSnackBar('لطفاً یک دوره انتخاب کنید', const Color(0xFFfa709a));
      return;
    }

    setState(() {
      isLoading = true;
    });

    var existingStudent = await DatabaseService.getStudentByNationalCode(
      _nationalCodeController.text,
    );

    int studentID;

    if (existingStudent == null) {
      Student newStudent = Student(
        fullName: _nameController.text,
        nationalCode: _nationalCodeController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );

      bool added = await DatabaseService.addStudent(newStudent);

      if (!added) {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('خطا در ثبت دانشجو', const Color(0xFFfa709a));
        return;
      }

      var addedStudent = await DatabaseService.getStudentByNationalCode(
        _nationalCodeController.text,
      );
      studentID = addedStudent!.studentID!;
    } else {
      studentID = existingStudent.studentID!;
    }

    String result = await DatabaseService.enrollStudent(
      studentID,
      selectedCourse!.courseID!,
    );

    setState(() {
      isLoading = false;
    });

    if (result.contains('موفقیت')) {
      _showSnackBar(result, const Color(0xFF43e97b));
      _showSuccessDialog();
      _clearForm();
      loadCourses();
    } else {
      _showSnackBar(result, const Color(0xFFfa709a));
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _nationalCodeController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      selectedCourse = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => FadeIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'موفق!',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ثبت‌نام با موفقیت انجام شد',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43e97b),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'باشه',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF11998e),
              Color(0xFF38ef7d),
              Color(0xFF43e97b),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ثبت‌نام دانشجو',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'اطلاعات را با دقت وارد کنید',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 200),
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'نام و نام خانوادگی',
                              icon: Icons.person,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              validator: (v) => v!.isEmpty ? 'نام را وارد کنید' : null,
                            ),
                          ),
                          const SizedBox(height: 15),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 300),
                            child: _buildTextField(
                              controller: _nationalCodeController,
                              label: 'کد ملی',
                              icon: Icons.credit_card,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              validator: (v) {
                                if (v!.isEmpty) return 'کد ملی را وارد کنید';
                                if (v.length != 10) return 'کد ملی باید 10 رقم باشد';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 400),
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'شماره تماس',
                              icon: Icons.phone,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              ),
                              keyboardType: TextInputType.phone,
                              maxLength: 11,
                            ),
                          ),
                          const SizedBox(height: 15),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 500),
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'ایمیل',
                              icon: Icons.email,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 600),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF11998e).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonFormField<Course>(
                                  value: selectedCourse,
                                  decoration: InputDecoration(
                                    labelText: 'دوره مورد نظر',
                                    labelStyle: GoogleFonts.cairo(),
                                    prefixIcon: ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                                      ).createShader(bounds),
                                      child: const Icon(Icons.school, color: Colors.white),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                  ),
                                  items: courses.map((course) {
                                    return DropdownMenuItem(
                                      value: course,
                                      child: Text(
                                        '${course.title} (ظرفیت: ${course.capacity})',
                                        style: GoogleFonts.cairo(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCourse = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 700),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF11998e).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : registerStudent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  'ثبت‌نام',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Gradient gradient,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.cairo(),
            prefixIcon: ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: Icon(icon, color: Colors.white),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            counterText: '',
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}