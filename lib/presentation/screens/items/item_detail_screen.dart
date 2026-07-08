import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/providers/item_provider.dart';
import '../../../core/providers/timeline_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/models/item_model.dart';
import '../../../domain/models/timeline_event.dart';
import '../../widgets/image_viewer_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final TimelineProvider _timelineProvider;

  @override
  void initState() {
    super.initState();
    _timelineProvider = context.read<TimelineProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemId = ModalRoute.of(context)?.settings.arguments as String?;
      if (itemId != null) {
        context.read<ItemProvider>().getItemById(itemId);
        _timelineProvider.startListening(itemId);
        final uid = context.read<AuthProvider>().user?.uid;
        if (uid != null) {
          context.read<FavoriteProvider>().startListening(uid);
        }
      }
    });
  }

  @override
  void dispose() {
    _timelineProvider.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemProvider = context.watch<ItemProvider>();
    final authProvider = context.watch<AuthProvider>();
    final item = itemProvider.selectedItem;

    if (itemProvider.isLoading && item == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item')),
        body: const Center(child: Text('Item not found')),
      );
    }

    final isLost = item.type == 'lost';
    final accentColor = isLost ? const Color(0xFFE53935) : const Color(0xFF43A047);
    final isOwner = authProvider.user?.uid == item.createdByUid;
    final uid = authProvider.user?.uid;
    final favProvider = context.watch<FavoriteProvider>();
    final isFavorited = uid != null && favProvider.isFavorited(item.id);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(item, theme, isDark, accentColor, uid),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(item, accentColor, theme, isDark),
                  const SizedBox(height: 20),
                  _buildInfoCard(item, theme, isDark),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(item, theme, isDark),
                  const SizedBox(height: 16),
                  _buildContactCard(item, theme, isDark),
                  const SizedBox(height: 24),
                  _buildActionButtons(item, authProvider, itemProvider, theme, isDark, isOwner),
                  const SizedBox(height: 24),
                  _buildTimelineSection(theme, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: uid != null
          ? FloatingActionButton(
              heroTag: 'detail_fav_fab',
              onPressed: () async {
                await context.read<FavoriteProvider>().toggleFavorite(uid, item.id);
              },
              backgroundColor: isFavorited ? const Color(0xFFE53935) : theme.colorScheme.primary,
              child: Icon(
                isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(ItemModel item, ThemeData theme, bool isDark, Color accentColor, String? uid) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _shareItem,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: item.imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(imageUrl: item.imageUrl, heroTag: 'detail_image'),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'detail_image',
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _buildPlaceholderImage(accentColor),
                        errorWidget: (_, _, _) => _buildPlaceholderImage(accentColor),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(180),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildPlaceholderImage(accentColor),
      ),
    );
  }

  Widget _buildPlaceholderImage(Color accentColor) {
    return Container(
      color: accentColor.withAlpha(30),
      child: Icon(
        Icons.inventory_2_outlined,
        color: accentColor.withAlpha(100),
        size: 80,
      ),
    );
  }

  Widget _buildStatusRow(ItemModel item, Color accentColor, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.type == 'lost' ? Icons.report_problem_rounded : Icons.search_off_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                item.statusDisplay,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.category,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ItemModel item, ThemeData theme, bool isDark) {
    return _buildCard(
      theme: theme,
      isDark: isDark,
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: item.type == 'lost' ? 'Lost Location' : 'Found Location',
            value: item.location,
            theme: theme,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: item.type == 'lost' ? 'Lost Date' : 'Found Date',
            value: _formatFullDate(item.itemDate),
            theme: theme,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Reported by',
            value: item.createdBy,
            theme: theme,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Posted',
            value: _formatFullDate(item.createdAt),
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ItemModel item, ThemeData theme, bool isDark) {
    return _buildCard(
      theme: theme,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description.isNotEmpty ? item.description : 'No description provided.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ItemModel item, ThemeData theme, bool isDark) {
    final authProvider = context.read<AuthProvider>();
    final currentUid = authProvider.user?.uid ?? '';
    final isOwner = item.createdByUid == currentUid;

    return _buildCard(
      theme: theme,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.phone_rounded, color: Color(0xFF43A047), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.contactNumber.isNotEmpty ? item.contactNumber : 'No contact provided',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isOwner && item.createdByUid.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final chatProvider = context.read<ChatProvider>();
                  final chatId = await chatProvider.getOrCreateChatRoom(
                    currentUid: currentUid,
                    otherUid: item.createdByUid,
                    itemId: item.id,
                    itemName: item.title,
                    itemImage: item.imageUrl,
                    itemType: item.type,
                  );
                  if (mounted) {
                    Navigator.pushNamed(context, AppRouter.conversation, arguments: {
                      'chatId': chatId,
                      'otherUid': item.createdByUid,
                      'itemName': item.title,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: const Text('Message Owner', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required ThemeData theme, required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
    );
  }

  Widget _buildActionButtons(
    ItemModel item,
    AuthProvider authProvider,
    ItemProvider itemProvider,
    ThemeData theme,
    bool isDark,
    bool isOwner,
  ) {
    final uid = authProvider.user?.uid;

    if (isOwner) {
      return Column(
        children: [
          if (item.status != 'recovered' && item.status != 'returned')
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Mark as Recovered'),
                      content: const Text('Mark this item as recovered?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    final success = item.type == 'lost'
                        ? await itemProvider.markAsRecovered(item.id)
                        : await itemProvider.markAsReturned(item.id);
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status updated!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  item.type == 'lost' ? 'Mark as Recovered' : 'Mark as Returned',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (item.status != 'recovered' && item.status != 'returned') const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Delete Report'),
                    content: const Text('Are you sure you want to delete this report?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935))),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  final success = await itemProvider.deleteItem(item.id);
                  if (mounted && success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report deleted')),
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    if (item.status == 'claimed' || item.status == 'returned' || item.status == 'recovered') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: uid != null ? () => _handleClaim(item, uid, itemProvider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.handshake_rounded),
        label: Text(
          item.type == 'lost' ? 'I Found This Item' : 'This Is My Item',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _handleClaim(ItemModel item, String uid, ItemProvider itemProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item.type == 'lost' ? 'Claim Item' : 'Confirm Ownership'),
        content: Text(
          item.type == 'lost'
              ? 'Are you sure you found this item? The owner will be notified.'
              : 'Are you sure this is your item? The finder will be notified.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await itemProvider.claimItem(item.id, uid);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item claimed successfully!')),
        );
      }
    }
  }

  Widget _buildTimelineSection(ThemeData theme, bool isDark) {
    final timelineProvider = context.watch<TimelineProvider>();
    final events = timelineProvider.events;
    final item = context.read<ItemProvider>().selectedItem;

    return _buildCard(
      theme: theme,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (timelineProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (events.isEmpty && item != null)
            _buildTimelineEvent(
              TimelineEvent(
                id: '',
                itemId: item.id,
                eventType: 'created',
                description: '${item.type == 'lost' ? 'Lost' : 'Found'} item "${item.title}" reported',
                performedBy: item.createdByUid,
                performedByName: item.createdBy,
                timestamp: item.createdAt,
              ),
              true,
              theme,
              isDark,
            )
          else if (events.isEmpty)
            Text(
              'No events yet',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            )
          else
            ...events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == events.length - 1;
              return _buildTimelineEvent(event, isLast, theme, isDark);
            }),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(TimelineEvent event, bool isLast, ThemeData theme, bool isDark) {
    IconData icon;
    Color color;

    switch (event.eventType) {
      case 'created':
        icon = Icons.add_circle_outline_rounded;
        color = const Color(0xFF43A047);
        break;
      case 'claimed':
        icon = Icons.handshake_rounded;
        color = const Color(0xFFFFA726);
        break;
      case 'matched':
        icon = Icons.compare_arrows_rounded;
        color = const Color(0xFF5C6BC0);
        break;
      case 'recovered':
      case 'returned':
        icon = Icons.check_circle_outline_rounded;
        color = const Color(0xFF43A047);
        break;
      default:
        icon = Icons.circle_outlined;
        color = isDark ? Colors.white38 : Colors.black38;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 20),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.performedByName} · ${_formatTimelineDate(event.timestamp)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimelineDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareItem() {
    final item = context.read<ItemProvider>().selectedItem;
    if (item == null) return;

    final text = '${item.type == 'lost' ? 'Lost' : 'Found'} Item on FindIt!\n\n'
        'Title: ${item.title}\n'
        'Category: ${item.category}\n'
        'Location: ${item.location}\n'
        '${item.itemDate != null ? 'Date: ${_formatFullDate(item.itemDate)}\n' : ''}'
        'Status: ${item.statusDisplay}\n\n'
        '${item.description.isNotEmpty ? '${item.description}\n\n' : ''}'
        'Open FindIt to help!';

    Share.share(text);
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }
}
