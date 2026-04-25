// lib/screens/settings_screen.dart
// Settings: Dark Mode, Unit Switch, Notifications

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useMetric = true; // true = kg/cm, false = lbs/ft
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useMetric = prefs.getBool('use_metric') ?? true;
      _notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _saveMetric(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_metric', val);
    setState(() => _useMetric = val);
  }

  Future<void> _saveNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notificationsEnabled = val);
    // NOTE: To actually schedule notifications, add flutter_local_notifications
    // and call NotificationService.schedule() here
    if (val) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily reminder enabled!',
              style: GoogleFonts.nunito()),
          backgroundColor: const Color(0xFF0E9F6E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF374151), Color(0xFF1A56DB)],
                  ),
                ),
              ),
              title: Text(
                'Settings',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 20),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance
                  _GroupLabel(label: 'Appearance', isDark: isDark),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _ToggleTile(
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        label: 'Dark Mode',
                        subtitle: isDark ? 'Currently dark' : 'Currently light',
                        value: isDark,
                        color: const Color(0xFF374151),
                        onChanged: (_) => widget.onThemeToggle(),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // Units
                  _GroupLabel(label: 'Units', isDark: isDark),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _UnitSelector(
                        useMetric: _useMetric,
                        onChanged: _saveMetric,
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // Notifications
                  _GroupLabel(label: 'Reminders', isDark: isDark),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _ToggleTile(
                        icon: Icons.notifications_rounded,
                        label: 'Daily BMI Reminder',
                        subtitle: 'Get reminded to check your BMI',
                        value: _notificationsEnabled,
                        color: const Color(0xFFF6A723),
                        onChanged: _saveNotifications,
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // About
                  _GroupLabel(label: 'About', isDark: isDark),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: '1.0.0',
                        color: const Color(0xFF1A56DB),
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.calculate_rounded,
                        label: 'Formula',
                        value: 'Mifflin-St Jeor',
                        color: const Color(0xFF0E9F6E),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

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

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _GroupLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness ==
                                Brightness.dark
                            ? Colors.white
                            : const Color(0xFF111928))),
                Text(subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  final bool useMetric;
  final ValueChanged<bool> onChanged;

  const _UnitSelector({required this.useMetric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.straighten_rounded,
                    color: Color(0xFF1A56DB), size: 22),
              ),
              const SizedBox(width: 14),
              Text('Measurement Units',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF111928))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _UnitChip(
                label: 'Metric (kg, cm)',
                isSelected: useMetric,
                color: const Color(0xFF1A56DB),
                onTap: () => onChanged(true),
              ),
              const SizedBox(width: 10),
              _UnitChip(
                label: 'Imperial (lbs, ft)',
                isSelected: !useMetric,
                color: const Color(0xFF0E9F6E),
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _UnitChip({
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF111928))),
          const Spacer(),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
