import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/item_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/models/item_model.dart';

enum SortOption { newest, oldest, titleAsc, titleDesc }

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  String _selectedType = 'all';
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ItemProvider>().loadMyItems(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemProvider = context.watch<ItemProvider>();

    final filteredItems = _applyFilters(itemProvider.myItems);
    final pagedItems = _applyPagination(filteredItems);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Report History', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(theme, isDark),
          _buildSearchBar(theme, isDark),
          Expanded(
            child: itemProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildItemsList(pagedItems, theme, isDark),
          ),
          if (filteredItems.length > _pageSize)
            _buildPagination(filteredItems.length, theme, isDark),
        ],
      ),
    );
  }

  List<ItemModel> _applyFilters(List<ItemModel> items) {
    var filtered = List<ItemModel>.from(items);

    if (_selectedType != 'all') {
      filtered = filtered.where((i) => i.type == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.title.toLowerCase().contains(query) ||
            i.description.toLowerCase().contains(query) ||
            i.category.toLowerCase().contains(query);
      }).toList();
    }

    switch (_sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
        break;
      case SortOption.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filtered;
  }

  List<ItemModel> _applyPagination(List<ItemModel> items) {
    final start = _currentPage * _pageSize;
    if (start >= items.length) return [];
    final end = (start + _pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  Widget _buildFilterBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', _selectedType == 'all', (v) {
            setState(() {
              _selectedType = 'all';
              _currentPage = 0;
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip('Lost', _selectedType == 'lost', (v) {
            setState(() {
              _selectedType = 'lost';
              _currentPage = 0;
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip('Found', _selectedType == 'found', (v) {
            setState(() {
              _selectedType = 'found';
              _currentPage = 0;
            });
          }),
          const Spacer(),
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort_rounded, color: isDark ? Colors.white54 : Colors.black54),
            onSelected: (option) {
              setState(() {
                _sortOption = option;
                _currentPage = 0;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: SortOption.newest, child: Text('Newest First')),
              const PopupMenuItem(value: SortOption.oldest, child: Text('Oldest First')),
              const PopupMenuItem(value: SortOption.titleAsc, child: Text('Title A-Z')),
              const PopupMenuItem(value: SortOption.titleDesc, child: Text('Title Z-A')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, ValueChanged<bool> onTap) {
    return GestureDetector(
      onTap: () => onTap(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 0;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2636) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded, size: 80, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 20),
          Text(
            'No reports found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<ItemModel> items, ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryCard(item, theme, isDark);
      },
    );
  }

  Widget _buildHistoryCard(ItemModel item, ThemeData theme, bool isDark) {
    final isLost = item.type == 'lost';
    final accentColor = isLost ? const Color(0xFFE53935) : const Color(0xFF43A047);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.itemDetail, arguments: item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: item.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: accentColor.withAlpha(25)),
                        errorWidget: (_, _, _) => Icon(
                          isLost ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                          color: accentColor,
                          size: 26,
                        ),
                      ),
                    )
                  : Icon(
                      isLost ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                      color: accentColor,
                      size: 26,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.statusDisplay,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalItems, ThemeData theme, bool isDark) {
    final totalPages = (totalItems / _pageSize).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${_currentPage + 1} / $totalPages',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
