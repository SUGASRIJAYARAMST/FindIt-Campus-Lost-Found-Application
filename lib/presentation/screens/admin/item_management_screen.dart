import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../domain/models/item_model.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = context.watch<AdminProvider>();

    var displayItems = _searchQuery.isEmpty
        ? adminProvider.items
        : adminProvider.searchItems(_searchQuery);

    if (_filterType == 'lost') {
      displayItems = displayItems.where((i) => i.type == 'lost').toList();
    } else if (_filterType == 'found') {
      displayItems = displayItems.where((i) => i.type == 'found').toList();
    } else if (_filterType == 'recovered') {
      displayItems = displayItems.where((i) => i.status == 'recovered' || i.status == 'returned').toList();
    }

    if (_sortBy == 'newest') {
      displayItems.sort((a, b) {
        final aDate = a.createdAt ?? a.itemDate;
        final bDate = b.createdAt ?? b.itemDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    } else {
      displayItems.sort((a, b) {
        final aDate = a.createdAt ?? a.itemDate;
        final bDate = b.createdAt ?? b.itemDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Item Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, isDark),
          _buildFilterChips(theme, isDark, adminProvider),
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayItems.isEmpty
                    ? _buildEmptyState(theme, isDark)
                    : _buildItemList(displayItems, adminProvider, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark, AdminProvider provider) {
    final lostCount = provider.items.where((i) => i.type == 'lost').length;
    final foundCount = provider.items.where((i) => i.type == 'found').length;
    final resolvedCount = provider.items.where((i) => i.status == 'recovered' || i.status == 'returned').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip('All (${provider.items.length})', _filterType == 'all', () {
                  setState(() => _filterType = 'all');
                }, isDark),
                const SizedBox(width: 8),
                _buildChip('Lost ($lostCount)', _filterType == 'lost', () {
                  setState(() => _filterType = 'lost');
                }, isDark),
                const SizedBox(width: 8),
                _buildChip('Found ($foundCount)', _filterType == 'found', () {
                  setState(() => _filterType = 'found');
                }, isDark),
                const SizedBox(width: 8),
                _buildChip('Resolved ($resolvedCount)', _filterType == 'recovered', () {
                  setState(() => _filterType = 'recovered');
                }, isDark),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.sort_rounded, size: 16, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 4),
              Text('Sort:', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              const SizedBox(width: 8),
              _buildChip('Newest', _sortBy == 'newest', () {
                setState(() => _sortBy = 'newest');
              }, isDark),
              const SizedBox(width: 8),
              _buildChip('Oldest', _sortBy == 'oldest', () {
                setState(() => _sortBy = 'oldest');
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF43A047).withAlpha(25) : (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF43A047).withAlpha(80) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF43A047) : (isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26),
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2636) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No items found', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildItemList(List<ItemModel> items, AdminProvider provider, ThemeData theme, bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index], provider, theme, isDark),
    );
  }

  Widget _buildItemCard(ItemModel item, AdminProvider provider, ThemeData theme, bool isDark) {
    final isLost = item.type == 'lost';
    final accentColor = isLost ? const Color(0xFFE53935) : const Color(0xFF43A047);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 15 : 5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: accentColor.withAlpha(25)),
                            errorWidget: (_, _, _) => Icon(
                              isLost ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                              color: accentColor,
                              size: 22,
                            )),
                      )
                    : Icon(
                        isLost ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                        color: accentColor,
                        size: 22,
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
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category} • ${item.location}',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (ctx) => [
                  if (item.status != 'returned' && item.status != 'recovered')
                    const PopupMenuItem(value: 'return', child: Text('Mark as Returned')),
                  if (item.status != 'returned' && item.status != 'recovered')
                    const PopupMenuItem(value: 'recover', child: Text('Mark as Recovered')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Color(0xFFE53935)))),
                ],
                onSelected: (value) => _handleItemAction(value, item, provider),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatusChip(item.statusDisplay, _getStatusColor(item.status)),
              const SizedBox(width: 8),
              _buildTypeChip(item.typeDisplay, accentColor),
              const Spacer(),
              Text(
                _formatDate(item.createdAt),
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildTypeChip(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lost':
        return const Color(0xFFE53935);
      case 'Found':
        return const Color(0xFF43A047);
      case 'Matched':
      case 'Claimed':
        return const Color(0xFFFFA726);
      case 'Recovered':
      case 'Returned':
        return const Color(0xFF4FC3F7);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleItemAction(String action, ItemModel item, AdminProvider provider) {
    switch (action) {
      case 'return':
        _confirmAction('Mark as Returned?', () async {
          final success = await provider.updateItemStatus(item.id, 'returned');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Status updated' : 'Failed to update')),
            );
          }
        });
        break;
      case 'recover':
        _confirmAction('Mark as Recovered?', () async {
          final success = await provider.updateItemStatus(item.id, 'recovered');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Status updated' : 'Failed to update')),
            );
          }
        });
        break;
      case 'delete':
        _confirmAction('Delete this item? This cannot be undone.', () async {
          final success = await provider.deleteItem(item.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Item deleted' : 'Failed to delete')),
            );
          }
        });
        break;
    }
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
