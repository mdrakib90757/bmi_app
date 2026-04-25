// lib/screens/profile_screen.dart
// Multiple Profile Manager

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<UserProfile>> _future;
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ProfileService.getProfiles();
    });
    ProfileService.getActiveProfileId()
        .then((id) => setState(() => _activeId = id));
  }

  void _showAddProfileDialog({UserProfile? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    File? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null ? 'Add Profile' : 'Edit Profile',
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              // Photo
              GestureDetector(
                onTap: () async {
                  final xfile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 256,
                    imageQuality: 80,
                  );
                  if (xfile != null) {
                    setModal(() => pickedImage = File(xfile.path));
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEBF5FF),
                    border: Border.all(
                        color: const Color(0xFF1A56DB), width: 2),
                    image: pickedImage != null
                        ? DecorationImage(
                            image: FileImage(pickedImage!),
                            fit: BoxFit.cover)
                        : existing?.photoPath != null
                            ? DecorationImage(
                                image:
                                    FileImage(File(existing!.photoPath!)),
                                fit: BoxFit.cover)
                            : null,
                  ),
                  child: pickedImage == null && existing?.photoPath == null
                      ? const Icon(Icons.add_a_photo_rounded,
                          color: Color(0xFF1A56DB), size: 28)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Name
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle:
                      GoogleFonts.nunito(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF1A56DB), width: 2),
                  ),
                ),
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final profile = UserProfile(
                      id: existing?.id ??
                          DateTime.now().millisecondsSinceEpoch
                              .toString(),
                      name: nameCtrl.text.trim(),
                      photoPath: pickedImage?.path ?? existing?.photoPath,
                      createdAt: existing?.createdAt ?? DateTime.now(),
                    );
                    await ProfileService.saveProfile(profile);
                    Navigator.pop(ctx);
                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Save',
                      style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    colors: [Color(0xFFF05252), Color(0xFF1A56DB)],
                  ),
                ),
              ),
              title: Text(
                'Profiles',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 20),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => _showAddProfileDialog(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<UserProfile>>(
              future: _future,
              builder: (ctx, snap) {
                final profiles = snap.data ?? [];

                if (profiles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Icon(Icons.group_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No profiles yet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: Colors.grey.shade400,
                                height: 1.6)),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: profiles.asMap().entries.map((e) {
                      final p = e.value;
                      final isActive = _activeId == p.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () async {
                            await ProfileService.setActiveProfile(p.id);
                            setState(() => _activeId = p.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.name} selected',
                                    style: GoogleFonts.nunito()),
                                backgroundColor:
                                    const Color(0xFF0E9F6E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1A56DB)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFF1A56DB)
                                    : Colors.grey.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? const Color(0xFF1A56DB)
                                          .withOpacity(0.25)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFEBF5FF),
                                    image: p.photoPath != null &&
                                            File(p.photoPath!)
                                                .existsSync()
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(p.photoPath!)),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: p.photoPath == null
                                      ? Icon(Icons.person_rounded,
                                          color: isActive
                                              ? Colors.white
                                              : const Color(0xFF1A56DB),
                                          size: 28)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? Colors.white
                                                : isDark
                                                    ? Colors.white
                                                    : const Color(
                                                        0xFF111928),
                                          )),
                                      if (isActive)
                                        Text('Active Profile',
                                            style: GoogleFonts.nunito(
                                                fontSize: 11,
                                                color: Colors.white70)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit_rounded,
                                      color: isActive
                                          ? Colors.white70
                                          : Colors.grey.shade400,
                                      size: 18),
                                  onPressed: () =>
                                      _showAddProfileDialog(existing: p),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded,
                                      color: isActive
                                          ? Colors.white70
                                          : const Color(0xFFF05252),
                                      size: 18),
                                  onPressed: () async {
                                    await ProfileService.deleteProfile(
                                        p.id);
                                    _load();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(
                                  milliseconds: e.key * 60),
                              duration: 300.ms,
                            ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
