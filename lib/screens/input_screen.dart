import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/bmi_calculator.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool _isMale = true;
  int _feet = 5;
  int _inches = 7;
  int _weight = 65;
  int _age = 25;
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  int get _heightInCm => (_feet * 30.48 + _inches * 2.54).round();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (xfile != null) {
        setState(() => _profileImage = File(xfile.path));
      }
    } catch (_) {}
  }

  void _showPhotoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Photo',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111928),
                ),
              ),
              const SizedBox(height: 16),
              _SourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                color: const Color(0xFF1A56DB),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _SourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: const Color(0xFF0E9F6E),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null) ...[
                const SizedBox(height: 10),
                _SourceTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: const Color(0xFFF05252),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _profileImage = null);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    final calc = BMICalculator(
      height: _heightInCm,
      weight: _weight,
      age: _age,
      isMale: _isMale,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          calculator: calc,
          profileImage: _profileImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
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
                'BMI Calculator',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                tooltip: 'History',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile photo
                  Center(
                    child: GestureDetector(
                      onTap: _showPhotoDialog,
                      child: Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEBF5FF),
                              border: Border.all(
                                color: const Color(0xFF1A56DB),
                                width: 2.5,
                              ),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: Color(0xFF1A56DB),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A56DB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Gender
                  _SectionLabel(label: 'Gender'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _GenderCard(
                        icon: FontAwesomeIcons.person,
                        label: 'Male',
                        isSelected: _isMale,
                        color: const Color(0xFF1A56DB),
                        onTap: () => setState(() => _isMale = true),
                      ),
                      const SizedBox(width: 14),
                      _GenderCard(
                        icon: FontAwesomeIcons.personDress,
                        label: 'Female',
                        isSelected: !_isMale,
                        color: const Color(0xFFF05252),
                        onTap: () => setState(() => _isMale = false),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Height
                  _SectionLabel(label: 'Height'),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_feet',
                              style: GoogleFonts.nunito(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A56DB),
                              ),
                            ),
                            Text(
                              "' ",
                              style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  color: Colors.grey.shade500),
                            ),
                            Text(
                              '$_inches',
                              style: GoogleFonts.nunito(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A56DB),
                              ),
                            ),
                            Text(
                              '"',
                              style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  color: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($_heightInCm cm)',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _SliderRow(
                          label: 'Feet',
                          value: _feet.toDouble(),
                          min: 4,
                          max: 7,
                          divisions: 3,
                          onChanged: (v) =>
                              setState(() => _feet = v.round()),
                        ),
                        _SliderRow(
                          label: 'Inches',
                          value: _inches.toDouble(),
                          min: 0,
                          max: 11,
                          divisions: 11,
                          onChanged: (v) =>
                              setState(() => _inches = v.round()),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Weight & Age
                  Row(
                    children: [
                      Expanded(
                        child: _Card(
                          child: Column(
                            children: [
                              Text('Weight',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                '$_weight',
                                style: GoogleFonts.nunito(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0E9F6E),
                                ),
                              ),
                              Text('kg',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  )),
                              const SizedBox(height: 8),
                              _PlusMinus(
                                onMinus: () => setState(
                                    () => _weight = (_weight - 1).clamp(20, 300)),
                                onPlus: () => setState(
                                    () => _weight = (_weight + 1).clamp(20, 300)),
                                color: const Color(0xFF0E9F6E),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _Card(
                          child: Column(
                            children: [
                              Text('Age',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                '$_age',
                                style: GoogleFonts.nunito(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF05252),
                                ),
                              ),
                              Text('years',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  )),
                              const SizedBox(height: 8),
                              _PlusMinus(
                                onMinus: () => setState(
                                    () => _age = (_age - 1).clamp(1, 120)),
                                onPlus: () => setState(
                                    () => _age = (_age + 1).clamp(1, 120)),
                                color: const Color(0xFFF05252),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_rounded, size: 22),
                      label: Text(
                        'Calculate BMI',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF374151),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1A56DB),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: const Color(0xFF1A56DB),
              overlayColor: const Color(0xFF1A56DB).withOpacity(0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 24,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A56DB),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlusMinus extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Color color;

  const _PlusMinus({
    required this.onMinus,
    required this.onPlus,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundBtn(icon: Icons.remove_rounded, onTap: onMinus, color: color),
        const SizedBox(width: 16),
        _RoundBtn(icon: Icons.add_rounded, onTap: onPlus, color: color),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _RoundBtn(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111928),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
