import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/results_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<BMIResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = ResultsStorage.getResults();
  }

  void _reload() => setState(() => _future = ResultsStorage.getResults());

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Underweight':
        return const Color(0xFF1A56DB);
      case 'Normal':
        return const Color(0xFF0E9F6E);
      case 'Overweight':
        return const Color(0xFFF6A723);
      default:
        return const Color(0xFFF05252);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A56DB), Color(0xFF0E9F6E)],
                  ),
                ),
              ),
              title: Text(
                'BMI History',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                onPressed: () => _showClearDialog(),
                tooltip: 'Clear all',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<BMIResult>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No saved results yet',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final reversed = results.reversed.toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      reversed.length,
                      (i) {
                        final r = reversed[i];
                        final color = _colorForCategory(r.category);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryCard(
                            result: r,
                            color: color,
                            dateStr: _formatDate(r.savedDate),
                            onDelete: () => _deleteResult(r),
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: i * 60),
                                duration: 300.ms,
                              ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteResult(BMIResult r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete this result?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content:
            Text('BMI ${r.bmi} — ${r.category}', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.nunito()),
          ),
          TextButton(
            onPressed: () async {
              await ResultsStorage.deleteResult(r);
              Navigator.pop(context);
              _reload();
            },
            child: Text('Delete', style: GoogleFonts.nunito(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear all results?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('This cannot be undone.', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.nunito()),
          ),
          TextButton(
            onPressed: () async {
              await ResultsStorage.clearResults();
              Navigator.pop(context);
              _reload();
            },
            child:
                Text('Clear all', style: GoogleFonts.nunito(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BMIResult result;
  final Color color;
  final String dateStr;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.result,
    required this.color,
    required this.dateStr,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
            image: result.profileImagePath.isNotEmpty &&
                    File(result.profileImagePath).existsSync()
                ? DecorationImage(
                    image: FileImage(File(result.profileImagePath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: result.profileImagePath.isEmpty ||
                  !File(result.profileImagePath).existsSync()
              ? Icon(Icons.person_rounded, color: color, size: 26)
              : null,
        ),
        title: Row(
          children: [
            Text(
              'BMI ${result.bmi}',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.category,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${result.height} cm  •  ${result.weight} kg  •  Age ${result.age}',
              style:
                  GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              dateStr,
              style:
                  GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: Color(0xFFF05252), size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
