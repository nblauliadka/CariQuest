// lib/features/admin/screens/admin_users_screen.dart
// cloud_firestore removed — mock mode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';

// ─── Provider (Mock) ────────────────────────────────────────────────────────
final adminUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return MockData.instance.usersStream.map((users) {
    final sorted = [...users]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  });
});


// ─── Screen ───────────────────────────────────────────────────────────────────
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;
  bool? _filterSuspended;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      body: Column(
        children: [
          // ── Gradient App Bar ───────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D1B69), AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'Manajemen Users',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    usersAsync.when(
                      data: (users) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${users.length} user',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Filter ────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau UID...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: _filterRole == null &&
                            _filterSuspended == null,
                        onTap: () => setState(() {
                          _filterRole = null;
                          _filterSuspended = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Expert',
                        selected: _filterRole == UserRole.expert,
                        onTap: () => setState(() {
                          _filterRole = UserRole.expert;
                          _filterSuspended = null;
                        }),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Seeker',
                        selected: _filterRole == UserRole.seeker,
                        onTap: () => setState(() {
                          _filterRole = UserRole.seeker;
                          _filterSuspended = null;
                        }),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Suspended',
                        selected: _filterSuspended == true,
                        onTap: () => setState(() {
                          _filterRole = null;
                          _filterSuspended = true;
                        }),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── User List ──────────────────────────────────────────────
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filtered = users.where((u) {
                  final matchSearch = _searchQuery.isEmpty ||
                      u.email.toLowerCase().contains(_searchQuery) ||
                      u.uid.toLowerCase().contains(_searchQuery) ||
                      (u.displayName.toLowerCase().contains(_searchQuery)) ||
                      (u.nim?.toLowerCase().contains(_searchQuery) ?? false);
                  final matchRole =
                      _filterRole == null || u.role == _filterRole;
                  final matchSuspended = _filterSuspended == null ||
                      u.isSuspended == _filterSuspended;
                  return matchSearch && matchRole && matchSuspended;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Tidak ada user ditemukan',
                            style:
                                TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _UserCard(
                    user: filtered[index],
                    onTap: () =>
                        _showUserDetail(context, filtered[index]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(BuildContext context, UserModel user) {
    final isExpert = user.role == UserRole.expert;
    final photoUrl =
        isExpert ? user.ktmPhotoUrl : user.ktpPhotoUrl;
    final docLabel = isExpert ? 'KTM' : 'KTP';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isExpert
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      child: Icon(
                        isExpert ? Icons.school_rounded : Icons.person_rounded,
                        color: isExpert ? AppColors.primary : Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : user.email,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A1A2E)),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isExpert ? 'Expert' : 'Seeker',
                            style: TextStyle(
                                color: isExpert
                                    ? AppColors.primary
                                    : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (user.isSuspended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Text('Suspended',
                            style: TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Detail info
                _DetailRow(label: 'UID', value: user.uid),
                _DetailRow(label: 'Phone', value: user.phone),
                _DetailRow(
                    label: 'Email Verified',
                    value: user.isEmailVerified ? '✅ Ya' : '❌ Belum'),
                if (isExpert) ...[
                  _DetailRow(label: 'NIM', value: user.nim ?? '-'),
                  _DetailRow(
                      label: 'Fakultas', value: user.faculty ?? '-'),
                  _DetailRow(
                      label: 'Jurusan', value: user.major ?? '-'),
                  _DetailRow(
                      label: 'KTM Verified',
                      value: user.isKtmVerified ? '✅ Ya' : '❌ Belum'),
                  _DetailRow(
                      label: 'Rank', value: user.rank.displayName),
                  _DetailRow(
                      label: 'Total Quest',
                      value: '${user.totalQuestsDone}'),
                  _DetailRow(
                      label: 'Rating',
                      value:
                          '${user.ratingAvg.toStringAsFixed(1)} ⭐ (${user.ratingCount}x)'),
                ] else ...[
                  _DetailRow(
                      label: 'KTP Verified',
                      value: user.isKtpVerified ? '✅ Ya' : '❌ Belum'),
                ],
                _DetailRow(
                    label: 'Daftar',
                    value: user.createdAt.toString().substring(0, 10)),
                _DetailRow(
                    label: 'Last Active',
                    value:
                        user.lastActive.toString().substring(0, 10)),

                // ── Foto KTM/KTP ─────────────────────────────────────
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Foto $docLabel',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                photoUrl != null
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(photoUrl,
                                    fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            photoUrl,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, prog) {
                              if (prog == null) return child;
                              return Container(
                                height: 180,
                                color: Colors.grey.shade100,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Text('Gagal load foto',
                                    style: TextStyle(
                                        color: Colors.grey.shade400)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 10),
                            Text(
                              'Foto $docLabel belum diupload',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: user.isSuspended
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Aktifkan Akun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () =>
                              _toggleSuspend(ctx, user, suspend: false),
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.block_rounded),
                          label: const Text('Suspend Akun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () =>
                              _toggleSuspend(ctx, user, suspend: true),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleSuspend(BuildContext ctx, UserModel user,
      {required bool suspend}) async {
    try {
      MockData.instance.updateUser(user.copyWith(isSuspended: suspend));
      if (ctx.mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(suspend
                ? '${user.email} telah di-suspend'
                : '${user.email} telah diaktifkan kembali'),
            backgroundColor: suspend ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpert = user.role == UserRole.expert;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: isExpert
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            isExpert ? Icons.school_rounded : Icons.person_rounded,
            color: isExpert ? AppColors.primary : Colors.orange,
          ),
        ),
        title: Text(
          user.displayName.isNotEmpty ? user.displayName : user.email,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1A1A2E)),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${isExpert ? "Expert" : "Seeker"} • ${user.createdAt.toString().substring(0, 10)}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.isSuspended)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Text('Suspended',
                    style:
                        TextStyle(color: Colors.red, fontSize: 11)),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? c : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1A1A2E)),
            ),
          ),
        ],
      ),
    );
  }
}
