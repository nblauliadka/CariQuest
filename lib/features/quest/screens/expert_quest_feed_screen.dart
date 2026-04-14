// lib/features/quest/screens/expert_quest_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/quest_controller.dart';

class ExpertQuestFeedScreen extends ConsumerStatefulWidget {
  const ExpertQuestFeedScreen({super.key});

  @override
  ConsumerState<ExpertQuestFeedScreen> createState() =>
      _ExpertQuestFeedScreenState();
}

class _ExpertQuestFeedScreenState extends ConsumerState<ExpertQuestFeedScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Akademik',
    'Desain',
    'Digital Marketing',
    'Programming',
    'Penulisan',
    'Video',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(expertQuestFeedProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cari Quest'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ─── Search & Filter ───────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari quest berdasarkan judul...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isActive = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ─── Quest List ────────────────────────────────────────────────
          Expanded(
            child: questsAsync.when(
              data: (quests) {
                // Filter by search
                var filtered = quests.where((q) {
                  final matchSearch = _searchQuery.isEmpty ||
                      q.title.toLowerCase().contains(_searchQuery) ||
                      q.description.toLowerCase().contains(_searchQuery);

                  // Filter by category (match title/description keywords)
                  final matchCategory = _selectedCategory == 'Semua' ||
                      q.title
                          .toLowerCase()
                          .contains(_selectedCategory.toLowerCase()) ||
                      q.description
                          .toLowerCase()
                          .contains(_selectedCategory.toLowerCase()) ||
                      q.jobdeskDetail
                          .toLowerCase()
                          .contains(_selectedCategory.toLowerCase());

                  return matchSearch && matchCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _selectedCategory != 'Semua'
                              ? 'Tidak ada quest yang cocok'
                              : 'Belum ada lowongan baru',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return QuestCard(
                      quest: filtered[index],
                      onTap: () {
                        context.pushNamed(
                          'expertQuestDetail',
                          pathParameters: {'questId': filtered[index].questId},
                        );
                      },
                      showSeeker: true,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
