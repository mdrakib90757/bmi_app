// lib/widgets/share_result_widget.dart
// Share BMI Result as Image

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/bmi_calculator.dart';

class ShareResultWidget extends StatefulWidget {
  final BMICalculator calculator;

  const ShareResultWidget({super.key, required this.calculator});

  @override
  State<ShareResultWidget> createState() => _ShareResultWidgetState();
}

class _ShareResultWidgetState extends State<ShareResultWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareResult() async {
    setState(() => _sharing = true);
    try {
      // Capture widget as image
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bmi_result.png');
      await file.writeAsBytes(pngBytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'My BMI is ${widget.calculator.bmiString} — ${widget.calculator.category}! Checked with BMI Calculator App 💪',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share. Try again.',
                style: GoogleFonts.nunito()),
            backgroundColor: const Color(0xFFF05252),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calc = widget.calculator;

    return Column(
      children: [
        // Hidden shareable card (captured as image)
        RepaintBoundary(
          key: _repaintKey,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [calc.categoryColor, calc.categoryColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My BMI Result',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  calc.bmiString,
                  style: GoogleFonts.nunito(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'kg/m²',
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    calc.category.toUpperCase(),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShareStat(
                        label: 'Height', value: '${calc.height} cm'),
                    const SizedBox(width: 24),
                    _ShareStat(
                        label: 'Weight', value: '${calc.weight} kg'),
                    const SizedBox(width: 24),
                    _ShareStat(label: 'Age', value: '${calc.age}'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'BMI Calculator App',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Share Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _sharing ? null : _shareResult,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A56DB),
                    ),
                  )
                : const Icon(Icons.share_rounded, size: 20),
            label: Text(
              _sharing ? 'Sharing...' : 'Share Result',
              style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A56DB),
              side: const BorderSide(color: Color(0xFF1A56DB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareStat extends StatelessWidget {
  final String label;
  final String value;
  const _ShareStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}
