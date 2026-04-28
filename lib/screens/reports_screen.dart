import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/database_service.dart';
import '../models/enrollment.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Enrollment> enrollments = [];
  List<Enrollment> filteredEnrollments = [];
  bool isLoading = true;
  String filterStatus = 'all'; // all, paid, unpaid

  @override
  void initState() {
    super.initState();
    loadEnrollments();
  }

  Future<void> loadEnrollments() async {
    setState(() {
      isLoading = true;
    });

    var data = await DatabaseService.getAllEnrollments();

    setState(() {
      enrollments = data;
      filteredEnrollments = data;
      isLoading = false;
    });
  }

  void _filterEnrollments(String status) {
    setState(() {
      filterStatus = status;
      if (status == 'all') {
        filteredEnrollments = enrollments;
      } else if (status == 'paid') {
        filteredEnrollments = enrollments.where((e) => e.isPaid).toList();
      } else {
        filteredEnrollments = enrollments.where((e) => !e.isPaid).toList();
      }
    });
  }

  int get paidCount => enrollments.where((e) => e.isPaid).length;
  int get unpaidCount => enrollments.where((e) => !e.isPaid).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a2a6c),
              Color(0xFFb21f1f),
              Color(0xFFfdbb2d),
            ],
            stops: [0.0, 0.5, 1.0],
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'گزارش ثبت‌نام‌ها',
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${filteredEnrollments.length} ثبت‌نام',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: loadEnrollments,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Summary Cards
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.list_alt,
                              title: 'کل',
                              value: enrollments.length.toString(),
                              color: Colors.white,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildStatItem(
                              icon: Icons.check_circle,
                              title: 'پرداخت شده',
                              value: paidCount.toString(),
                              color: Color(0xFF43e97b),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildStatItem(
                              icon: Icons.pending,
                              title: 'در انتظار',
                              value: unpaidCount.toString(),
                              color: Color(0xFFfa709a),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterChip('همه', 'all'),
                      const SizedBox(width: 10),
                      _buildFilterChip('پرداخت شده', 'paid'),
                      const SizedBox(width: 10),
                      _buildFilterChip('پرداخت نشده', 'unpaid'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Enrollments List
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : filteredEnrollments.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'هیچ ثبت‌نامی یافت نشد',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: loadEnrollments,
                  color: Color(0xFFfdbb2d),
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredEnrollments.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: _buildEnrollmentCard(
                                filteredEnrollments[index],
                                index,
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterStatus == value;
    return GestureDetector(
      onTap: () => _filterEnrollments(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [Color(0xFFfdbb2d), Color(0xFFb21f1f)],
          )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment, int index) {
    final gradients = [
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFF5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0],
            gradient[1],
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with student name and status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enrollment.studentName ?? 'نامشخص',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  enrollment.courseTitle ?? 'دوره نامشخص',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: enrollment.isPaid
                            ? Color(0xFF43e97b).withOpacity(0.3)
                            : Color(0xFFfa709a).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: enrollment.isPaid
                              ? Color(0xFF43e97b)
                              : Color(0xFFfa709a),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            enrollment.isPaid
                                ? Icons.check_circle
                                : Icons.pending,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            enrollment.isPaid ? 'پرداخت شده' : 'در انتظار',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Date info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تاریخ ثبت‌نام:',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        enrollment.enrollDate != null
                            ? '${enrollment.enrollDate!.year}/${enrollment.enrollDate!.month}/${enrollment.enrollDate!.day}'
                            : 'تاریخ نامشخص',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}