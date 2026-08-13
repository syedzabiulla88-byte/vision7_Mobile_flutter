import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../domain/facility.dart';
import '../../domain/facility_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mode_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  final List<String> _categoryKeys = ['all', 'padel', 'football', 'v7arena', 'birthday'];
  String _selectedCategoryKey = 'all';
  bool _isGrid = true;
  bool _isLoading = true;
  String? _error;
  List<Facility> _allFacilities = [];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<FacilityRepository>();
      final facilities = await repo.listPublic();
      if (mounted) {
        setState(() {
          _allFacilities = facilities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _selectedCategorySlug() {
    final t = context.read<LanguageProvider>().t;
    final map = {
      'all': 'All',
      'padel': t('explore.category.padel'),
      'football': t('explore.category.football'),
      'v7arena': t('explore.category.v7arena'),
      'birthday': t('explore.category.birthday'),
    };
    return map[_selectedCategoryKey] ?? 'All';
  }

  List<Facility> _getFilteredFacilities() {
    final lang = context.read<LanguageProvider>().lang;
    final selectedSlug = _selectedCategorySlug();
    List<Facility> results;
    if (_selectedCategoryKey == 'all') {
      results = List.from(_allFacilities);
    } else {
      results = _allFacilities
          .where((f) => f.category == selectedSlug)
          .toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return results;
    return results.where((f) {
      final name = f.getName(lang).toLowerCase();
      final category = f.category.toLowerCase();
      return name.contains(query) || category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final facilities = _getFilteredFacilities();

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t('explore.title'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                    icon: Icon(
                      _isGrid
                          ? Icons.view_list_outlined
                          : Icons.grid_view_outlined,
                      color: isAcademy ? AppColors.cream : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: t('explore.search'),
                  hintStyle: TextStyle(color: isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
                  prefixIcon: Icon(Icons.search, color: isAcademy ? AppColors.cream : AppColors.muted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.clear, color: isAcademy ? AppColors.cream : AppColors.muted),
                        )
                      : null,
                  filled: true,
                  fillColor: isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isAcademy ? AppColors.cream : AppColors.text),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _categoryKeys.length,
                itemBuilder: (context, index) {
                  final key = _categoryKeys[index];
                  final isSelected = _selectedCategoryKey == key;
                  final label = _categoryLabel(key, t);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategoryKey = key);
                      },
                      backgroundColor: isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white,
                      selectedColor: AppColors.gold,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.navy
                            : (isAcademy ? AppColors.cream : AppColors.text),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      checkmarkColor: AppColors.navy,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildResults(facilities, t, isAcademy)),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String key, String Function(String, {String? fallback}) t) {
    switch (key) {
      case 'all': return t('explore.all');
      case 'padel': return t('explore.category.padel');
      case 'football': return t('explore.category.football');
      case 'v7arena': return t('explore.category.v7arena');
      case 'birthday': return t('explore.category.birthday');
      default: return key;
    }
  }

  Widget _buildResults(List<Facility> facilities, String Function(String, {String? fallback}) t, bool isAcademy) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: isAcademy ? AppColors.gold : AppColors.gold),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _loadFacilities,
              child: Text(t('common.retry')),
            ),
          ],
        ),
      );
    }

    if (facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: isAcademy ? AppColors.cream.withValues(alpha: 0.5) : AppColors.muted),
            const SizedBox(height: AppSpacing.md),
            Text(
              t('explore.noResults'),
              style: TextStyle(color: isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted),
            ),
          ],
        ),
      );
    }

    if (_isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: facilities.length,
        itemBuilder: (context, index) =>
            _FacilityCard(facility: facilities[index], isAcademy: isAcademy),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: facilities.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _FacilityCard(facility: facilities[index], isList: true, isAcademy: isAcademy),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  final bool isList;
  final bool isAcademy;

  const _FacilityCard({required this.facility, this.isList = false, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : null;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    if (isList) {
      return InkWell(
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(facility.category),
                  size: 36,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.getName(lang),
                      style: Theme.of(context).textTheme.h4.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facility.category,
                      style: TextStyle(color: AppColors.gold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (facility.pricePerSlot != null)
                      Text(
                        'SAR ${facility.pricePerSlot!.toStringAsFixed(0)}/slot',
                        style: Theme.of(context).textTheme.caption.copyWith(color: mutedColor),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedColor),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(
                  _categoryIcon(facility.category),
                  size: 40,
                  color: AppColors.gold,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.getName(lang),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facility.category,
                      style: TextStyle(color: AppColors.gold, fontSize: 11),
                    ),
                    const Spacer(),
                    if (facility.pricePerSlot != null)
                      Text(
                        'SAR ${facility.pricePerSlot!.toStringAsFixed(0)}/slot',
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    context.push('/facility/${facility.id}', extra: facility);
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Padel':
        return Icons.sports_tennis;
      case 'Football':
        return Icons.sports_soccer;
      case 'V7 Arena':
        return Icons.stadium;
      case 'Birthday':
        return Icons.cake;
      default:
        return Icons.fitness_center;
    }
  }
}
