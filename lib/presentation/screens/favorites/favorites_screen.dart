import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/models/item_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<FavoriteProvider>().startListening(uid);
        context.read<FavoriteProvider>().loadFavorites(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favProvider.isLoading && favProvider.favoriteItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : favProvider.favoriteItems.isEmpty
              ? _buildEmptyState(theme, isDark)
              : RefreshIndicator(
                  onRefresh: () async {
                    final uid = context.read<AuthProvider>().user?.uid;
                    if (uid != null) {
                      await context.read<FavoriteProvider>().loadFavorites(uid);
                    }
                  },
                  child: _buildFavoritesList(favProvider, theme, isDark),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any item to add it to favorites',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoriteProvider favProvider, ThemeData theme, bool isDark) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: favProvider.favoriteItems.length,
      itemBuilder: (context, index) {
        final item = favProvider.favoriteItems[index];
        return _buildFavoriteCard(item, theme, isDark);
      },
    );
  }

  Widget _buildFavoriteCard(ItemModel item, ThemeData theme, bool isDark) {
    final isLost = item.type == 'lost';
    final accentColor = isLost ? const Color(0xFFE53935) : const Color(0xFF43A047);
    final uid = context.read<AuthProvider>().user?.uid;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.itemDetail,
        arguments: item.id,
      ),
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
                        errorWidget: (_, _, _) =>
                            Icon(item.type == 'lost' ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded, color: accentColor, size: 26),
                      ),
                    )
                  : Icon(
                      item.type == 'lost'
                          ? Icons.help_outline_rounded
                          : Icons.check_circle_outline_rounded,
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
                      Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white38 : Colors.black38),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: uid != null
                  ? () async {
                      // Extract context before async operation
                      final favoriteProvider = context.read<FavoriteProvider>();
                      await favoriteProvider.toggleFavorite(uid, item.id);
                      if (mounted && uid.isNotEmpty) {
                        await favoriteProvider.loadFavorites(uid);
                      }
                    }
                  : null,
              icon: Icon(
                Icons.favorite_rounded,
                color: const Color(0xFFE53935),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
