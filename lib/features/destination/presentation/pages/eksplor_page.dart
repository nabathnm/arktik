import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../providers/destination_provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/destination_entity.dart';

class EksplorPage extends StatefulWidget {
  const EksplorPage({super.key});

  @override
  State<EksplorPage> createState() => _EksplorPageState();
}

class _EksplorPageState extends State<EksplorPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                'Rekomendasi Tempat Wisata',
                style: LivestTypography.textLg.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<DestinationProvider>().fetchDestinations();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [_buildSearchBox(), _buildContent()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<DestinationProvider>().search(value);
            },
            decoration: InputDecoration(
              hintText: 'Cari wisata',
              hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DestinationProvider>(
      builder: (context, provider, _) {
        if (provider.state == DestinationState.loading &&
            provider.destinations.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.state == DestinationState.error) {
          return SliverFillRemaining(
            child: AppError(
              message: 'Gagal memuat destinasi\n${provider.errorMessage}',
              onRetry: () => provider.fetchDestinations(),
            ),
          );
        }

        if (provider.state == DestinationState.empty ||
            provider.displayedDestinations.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                'Tidak ada destinasi yang ditemukan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final dest = provider.displayedDestinations[index];
            return _buildListItem(context, dest);
          }, childCount: provider.displayedDestinations.length),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DestinationEntity dest) {
    return InkWell(
      onTap: () => context.push('/destination/${dest.id}'),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: LivestTypography.bodyLgMedium.copyWith(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 (2.021)', // Mock rating
                            style: LivestTypography.caption.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dest.type == DestinationType.tourism
                            ? 'Wisata dan alam'
                            : 'Hotel dan restoran',
                        style: LivestTypography.caption.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    dest.imageUrl,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
