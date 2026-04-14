// lib/features/profile/screens/edit_profile_screen.dart
// firebase_storage removed — demo mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_controller.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../auth/providers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;
  final UserModel? user;
  const EditProfileScreen({super.key, required this.profile, this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _skillInputCtrl;
  late List<String> _skills;

  String? _avatarUrl;
  bool _uploadingAvatar = false;
  bool _saving = false;

  late TabController _tabCtrl;

  // Kategori skill populer untuk quick-add
  static const _popularSkills = [
    'Desain Grafis',
    'Desain Logo',
    'UI/UX Design',
    'Ilustrasi',
    'Video Editing',
    'Motion Graphics',
    'Fotografi',
    'Konten Kreator',
    'Web Development',
    'Mobile App',
    'Flutter',
    'React',
    'Laravel',
    'Data Analysis',
    'Machine Learning',
    'Cyber Security',
    'Penulisan Artikel',
    'Copywriting',
    'Translasi',
    'Presentasi',
    'Social Media',
    'Digital Marketing',
    'SEO',
    'Spreadsheet',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.displayName);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _skillInputCtrl = TextEditingController();
    _skills = List.from(widget.profile.skillTags);
    _avatarUrl = widget.profile.avatarUrl;
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _skillInputCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─── Pick & Upload Avatar (Mock) ─────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    setState(() => _uploadingAvatar = true);
    try {
      // Demo MVP: simulate upload with a placeholder
      await Future.delayed(const Duration(milliseconds: 600));
      const mockAvatarUrl =
          'https://ui-avatars.com/api/?name=Demo+User&background=6C5CE7&color=fff&size=200';
      setState(() => _avatarUrl = mockAvatarUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil diperbarui! 📸 (Demo Mode)')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  // ─── Save Profile ─────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong!')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            displayName: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            skillTags: _skills,
            avatarUrl: _avatarUrl,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui! ✨')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() => _skills.add(s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = widget.user?.rank ?? ExpertRank.newcomer;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Keahlian'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ProfileTab(
            nameCtrl: _nameCtrl,
            bioCtrl: _bioCtrl,
            avatarUrl: _avatarUrl,
            uploading: _uploadingAvatar,
            onPickAvatar: _pickAvatar,
            user: widget.user,
            rank: rank,
          ),
          _SkillsTab(
            skills: _skills,
            popularSkills: _popularSkills,
            inputCtrl: _skillInputCtrl,
            onAdd: _addSkill,
            onRemove: (s) => setState(() => _skills.remove(s)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1: Profil ────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final TextEditingController nameCtrl, bioCtrl;
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback onPickAvatar;
  final UserModel? user;
  final ExpertRank rank;

  const _ProfileTab({
    required this.nameCtrl,
    required this.bioCtrl,
    required this.avatarUrl,
    required this.uploading,
    required this.onPickAvatar,
    required this.user,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Avatar Section ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                const Text('Foto Profil',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onPickAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12)
                          ],
                        ),
                        child: ClipOval(
                          child: uploading
                              ? const Center(child: CircularProgressIndicator())
                              : (avatarUrl != null && avatarUrl!.isNotEmpty)
                                  ? Image.network(avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _AvatarPlaceholder())
                                  : _AvatarPlaceholder(),
                        ),
                      ),
                      // Overlay kamera
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text('Ganti Foto',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Klik untuk upload foto dari galeri',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                Text('Format: JPG, PNG (max 5MB)',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Info Profil ─────────────────────────────────────────────
          _FormCard(
            title: '✏️ Informasi Dasar',
            children: [
              _EditField(
                label: 'Nama Lengkap',
                controller: nameCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'Nama yang akan tampil di profil',
              ),
              const SizedBox(height: 16),
              _EditField(
                label: 'Bio / Deskripsi Diri',
                controller: bioCtrl,
                icon: Icons.notes_rounded,
                hint:
                    'Ceritakan tentang dirimu, pengalaman, dan keahlian utama...',
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Info Akademik (readonly dari data registrasi) ───────────
          if (user != null)
            _FormCard(
              title: '🎓 Info Akademik',
              subtitle: 'Data dari registrasi — hubungi admin untuk mengubah',
              children: [
                _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'NIM',
                    value: user!.nim ?? '-'),
                _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Fakultas',
                    value: user!.faculty ?? '-'),
                _InfoRow(
                    icon: Icons.menu_book_outlined,
                    label: 'Jurusan',
                    value: user!.major ?? '-'),
                _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user!.email),
              ],
            ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primaryContainer,
        child: const Icon(Icons.person_rounded,
            color: AppColors.primary, size: 50),
      );
}

// ─── Tab 2: Skills ────────────────────────────────────────────────────────────
class _SkillsTab extends StatelessWidget {
  final List<String> skills, popularSkills;
  final TextEditingController inputCtrl;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _SkillsTab({
    required this.skills,
    required this.popularSkills,
    required this.inputCtrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Custom skill input ──────────────────────────────────────
          _FormCard(
            title: '⚡ Skill Kamu',
            children: [
              // Input manual
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tambah skill manual...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF3F2F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (v) {
                        onAdd(v);
                        inputCtrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      onAdd(inputCtrl.text);
                      inputCtrl.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Skills yang sudah ditambah
              if (skills.isEmpty)
                Text('Belum ada skill. Tambahkan dari bawah!',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => onRemove(s),
                                  child: const Icon(Icons.close_rounded,
                                      size: 14, color: Colors.white70),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Quick add popular skills ────────────────────────────────
          _FormCard(
            title: '🔥 Skill Populer',
            subtitle: 'Ketuk untuk langsung tambah',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popularSkills.map((s) {
                  final added = skills.contains(s);
                  return GestureDetector(
                    onTap: () => added ? onRemove(s) : onAdd(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: added
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: added
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (added)
                            const Icon(Icons.check_rounded,
                                size: 12, color: Colors.white),
                          if (added) const SizedBox(width: 4),
                          Text(s,
                              style: TextStyle(
                                  color: added
                                      ? Colors.white
                                      : AppColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Form Components ──────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const _FormCard({required this.title, required this.children, this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E))),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );
}

class _EditField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon,
                  color: AppColors.primary.withValues(alpha: 0.6), size: 18),
              filled: true,
              fillColor: const Color(0xFFF3F2F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Text('$label:',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}
