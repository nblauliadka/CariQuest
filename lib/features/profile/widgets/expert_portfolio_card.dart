// lib/features/profile/screens/widgets/expert_portfolio_card.dart
// firebase_storage and file_picker removed — mock mode
import 'package:cariquest/features/auth/providers/auth_controller.dart';
import 'package:cariquest/features/profile/providers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/models.dart';
import 'profile_card.dart';

class ExpertPortfolioCard extends StatefulWidget {
  final ProfileModel profile;
  final bool isMe;
  final WidgetRef ref;
  const ExpertPortfolioCard({
    super.key,
    required this.profile,
    required this.isMe,
    required this.ref,
  });

  @override
  State<ExpertPortfolioCard> createState() => _ExpertPortfolioCardState();
}

class _ExpertPortfolioCardState extends State<ExpertPortfolioCard> {
  bool _uploading = false;

  Future<void> _pickPortfolio() async {
    setState(() => _uploading = true);
    try {
      // Demo MVP: simulate upload, add a placeholder image URL
      await Future.delayed(const Duration(milliseconds: 600));
      const mockUrl =
          'https://picsum.photos/seed/portfolio/400/300';

      await widget.ref
          .read(profileControllerProvider.notifier)
          .addPortfolioImage(mockUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Karya berhasil ditambahkan! 🎨 (Demo Mode)')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.profile.albumUrls;
    return ProfileCard(
      title: '🎨 Album Karya',
      action: widget.isMe
          ? GestureDetector(
              onTap: _uploading ? null : _pickPortfolio,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Tambah',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            )
          : null,
      child: urls.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 44, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                        widget.isMe
                            ? 'Tambahkan karya terbaikmu!'
                            : 'Belum ada karya',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13)),
                  ],
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (_, i) {
                final isPdf = urls[i].contains('pdf');
                return GestureDetector(
                  onTap: () => _showPreview(context, urls[i], isPdf),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isPdf
                            ? Container(
                                color: Colors.red.shade50,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf,
                                          color: Colors.red, size: 28),
                                      Text('PDF',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              )
                            : Image.network(urls[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade100,
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey.shade400))),
                      ),
                      if (widget.isMe)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => widget.ref
                                .read(profileControllerProvider.notifier)
                                .removePortfolioImage(urls[i]),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 11, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showPreview(BuildContext context, String url, bool isPdf) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: isPdf
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 12),
                    const Text('File PDF',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup',
                            style: TextStyle(color: Colors.white60))),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(url,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 60)),
                  ),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup',
                          style: TextStyle(color: Colors.white60))),
                ],
              ),
      ),
    );
  }
}
