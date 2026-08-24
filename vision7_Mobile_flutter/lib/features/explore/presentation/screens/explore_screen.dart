import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../domain/facility.dart';
import '../../domain/facility_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/widgets/pressable_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
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

  // Leisure gets its own tab set (Padel/Gym/Wellness/Rooftop) — Academy's
  // tabs are untouched. The underlying keys for the renamed tabs stay the
  // same ('v7arena', 'birthday') so _selectedCategorySlug's facility
  // filtering is unaffected; only the label and rendered content differ.
  List<String> _categoryKeysFor(bool isAcademy) => isAcademy
      ? const ['all', 'padel', 'football', 'v7arena', 'birthday']
      : const ['all', 'padel', 'v7arena', 'swimming', 'birthday', 'rooftop'];

  // Raw category values as stored on Facility records from the backend —
  // intentionally NOT the translated display label (see _categoryLabel),
  // so renaming a chip's visible text can never silently break filtering.
  String _selectedCategorySlug() {
    const map = {
      'all': 'All',
      'padel': 'Padel',
      'football': 'Football',
      'v7arena': 'V7 Arena',
      'birthday': 'Birthday',
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
                itemCount: _categoryKeysFor(isAcademy).length,
                itemBuilder: (context, index) {
                  final key = _categoryKeysFor(isAcademy)[index];
                  final isSelected = _selectedCategoryKey == key;
                  final label = _categoryLabel(key, t, isAcademy);
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategoryKey = key);
                      },
                      backgroundColor: isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white,
                      selectedColor: isAcademy ? AppColors.gold : AppColors.black,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isAcademy ? AppColors.navy : AppColors.cream)
                            : (isAcademy ? AppColors.cream : AppColors.text),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      checkmarkColor: isAcademy ? AppColors.navy : AppColors.cream,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildBody(facilities, t, isAcademy)),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String key, String Function(String, {String? fallback}) t, bool isAcademy) {
    switch (key) {
      case 'all': return t('explore.all');
      case 'padel':
        return isAcademy ? t('explore.category.padel') : t('explore.category.padel.leisure', fallback: 'Padel');
      case 'football': return t('explore.category.football');
      case 'v7arena':
        return isAcademy ? t('explore.category.v7arena') : t('explore.category.gym', fallback: 'Gym');
      case 'swimming':
        return t('explore.category.swimming', fallback: 'Swimming');
      case 'birthday':
        return isAcademy ? t('explore.category.birthday') : t('explore.category.wellness', fallback: 'Wellness');
      case 'rooftop':
        return t('explore.category.rooftop', fallback: 'Rooftop');
      default: return key;
    }
  }

  // ─── Static package content per category ──────────────────────────────
  // Each returns the widgets for its own section (feature grid, if any, plus
  // package cards) so standalone category views and the combined "All" view
  // can share the exact same content instead of duplicating it.

  List<Widget> _padelContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    final benefits = [
      t('explore.package.benefit1'),
      t('explore.package.benefit2'),
    ];
    final packages = [
      t('explore.package.oneMonthAdult'),
      t('explore.package.oneMonthJunior'),
      t('explore.package.threeMonthAdult'),
      t('explore.package.threeMonthJunior'),
    ];
    return [
      // Academy's "Indoor Performance Hub" tab shares this method and keeps
      // the original membership packages; Leisure's Padel tab shows only the
      // 3 standalone court-booking cards below instead.
      if (isAcademy)
        for (final package in packages)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _PackageCard(name: package, benefits: benefits, isAcademy: isAcademy),
          )
      else ...[
        _sectionHeader(t('explore.padelCourt.facilitiesHeading', fallback: 'Padel Facilities'), isAcademy),
        const SizedBox(height: AppSpacing.md),
        _FacilityGrid(
          isAcademy: isAcademy,
          items: [
            (
              Icons.grid_view_outlined,
              t('explore.padelCourt.facility.courts', fallback: 'Premium Courts'),
              t('explore.padelCourt.facility.courts.sub', fallback: 'High quality courts'),
            ),
            (
              Icons.dry_cleaning_outlined,
              t('explore.padelCourt.facility.towels', fallback: 'Towel Service'),
              t('explore.padelCourt.facility.towels.sub', fallback: 'Complimentary towels'),
            ),
            (
              Icons.local_cafe_outlined,
              t('explore.padelCourt.facility.refreshments', fallback: 'Refreshments'),
              t('explore.padelCourt.facility.refreshments.sub', fallback: 'Drinks & light snacks'),
            ),
            (
              Icons.weekend_outlined,
              t('explore.padelCourt.facility.lounge', fallback: 'Player Lounge'),
              t('explore.padelCourt.facility.lounge.sub', fallback: 'Lounge & social area'),
            ),
            (
              Icons.sports_outlined,
              t('explore.padelCourt.facility.coaching', fallback: 'Private Coaching'),
              t('explore.padelCourt.facility.coaching.sub', fallback: 'Guidance from experts'),
            ),
            (
              Icons.badge_outlined,
              t('explore.padelCourt.facility.memberships', fallback: 'Padel Memberships'),
              t('explore.padelCourt.facility.memberships.sub', fallback: 'Exclusive member benefits'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeader(t('explore.padelCourt.bookACourt', fallback: 'Book a Court'), isAcademy),
        const SizedBox(height: AppSpacing.md),
        for (final minutes in const [60, 90, 120])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _PackageCard(
              name: t('explore.padelCourt.name', fallback: 'Padel Court'),
              benefits: ['${t('explore.padelCourt.sessionLength', fallback: 'Session Length')}: $minutes ${t('explore.padelCourt.mins', fallback: 'mins')}'],
              isAcademy: isAcademy,
              showCheckmark: false,
            ),
          ),
      ],
    ];
  }

  List<Widget> _footballContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    final features = [
      t('explore.football.feature1'),
      t('explore.football.feature2'),
      t('explore.football.feature3'),
      t('explore.football.feature4'),
      t('explore.football.feature5'),
      t('explore.football.feature6'),
    ];
    final duration60 = t('explore.football.duration60');
    final duration90 = t('explore.football.duration90');
    final duration2h = t('explore.football.duration2h');
    final packages = [
      (t('explore.football.package5'), [duration60, duration2h]),
      (t('explore.football.package7'), [duration60, duration2h]),
      (t('explore.football.package9'), [duration60, duration2h]),
      (t('explore.football.package11'), [duration90]),
    ];
    return [
      _FeatureGrid(features: features, isAcademy: isAcademy),
      const SizedBox(height: AppSpacing.lg),
      for (final package in packages)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PackageCard(
            name: package.$1,
            benefits: package.$2,
            isAcademy: isAcademy,
            showCheckmark: false,
          ),
        ),
    ];
  }

  List<Widget> _arenaContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    final features = [
      t('explore.arena.feature1'),
      t('explore.arena.feature2'),
      t('explore.arena.feature3'),
      t('explore.arena.feature4'),
      t('explore.arena.feature5'),
    ];
    final duration = t('explore.arena.gameDuration');
    final packages = [
      (t('explore.arena.membersGame'), [duration]),
      (t('explore.arena.nonMembersGame'), [duration]),
    ];
    return [
      _FeatureGrid(features: features, isAcademy: isAcademy),
      const SizedBox(height: AppSpacing.lg),
      for (final package in packages)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PackageCard(
            name: package.$1,
            benefits: package.$2,
            isAcademy: isAcademy,
            showCheckmark: false,
          ),
        ),
    ];
  }

  List<Widget> _birthdayContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    return [
      _PackageCard(
        name: t('explore.birthday.packageName'),
        benefits: [t('explore.birthday.packageDesc')],
        isAcademy: isAcademy,
        showCheckmark: false,
      ),
    ];
  }

  // Leisure-only tabs (Gym, Wellness, Rooftop) have no package content yet —
  // this placeholder is shared by all three rather than duplicated.
  List<Widget> _comingSoonContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isAcademy ? AppColors.gold : AppColors.black).withValues(alpha: 0.35)),
        ),
        child: Text(
          t('explore.comingSoon', fallback: 'Coming Soon'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isAcademy ? AppColors.cream : AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    ];
  }

  // Leisure-only Gym tab content: Powered by Technogym + training
  // environment heading + 3 feature cards.
  List<Widget> _gymContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;

    return [
      Center(
        child: Column(
          children: [
            Text(
              t('explore.gym.poweredBy', fallback: 'POWERED BY'),
              style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2),
            ),
            const SizedBox(height: AppSpacing.md),
            SvgPicture.asset('assets/images/technogym-logo.svg', height: 36),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(
        t('explore.gym.heading', fallback: 'THE TRAINING ENVIRONMENT'),
        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: 0.3),
      ),
      const SizedBox(height: 4),
      Text(
        t('explore.gym.subtitle', fallback: 'Train harder. Recover better.'),
        style: TextStyle(color: mutedColor, fontSize: 14),
      ),
      const SizedBox(height: AppSpacing.lg),
      for (final item in const [
        ('01', 'explore.gym.feature1', 'State-of-the-art Technogym equipment'),
        ('02', 'explore.gym.feature2', 'AI powered training programs'),
        ('03', 'explore.gym.feature3', 'Personal training'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _GymFeatureCard(number: item.$1, label: t(item.$2, fallback: item.$3)),
        ),
      const SizedBox(height: AppSpacing.xl),
      _sectionHeader(t('explore.gym.membershipsHeading', fallback: 'Gym Memberships'), isAcademy),
      const SizedBox(height: AppSpacing.md),
      for (final plan in const [
        ('explore.gym.plan.oneMonth', '1 Month', true),
        ('explore.gym.plan.threeMonths', '3 Months', true),
        ('explore.gym.plan.sixMonths', '6 Months', true),
        ('explore.gym.plan.annual', 'Annual Health & Leisure Package', true),
        ('explore.gym.plan.dailyPass', 'Daily Pass', false),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _GymPlanCard(
            name: t(plan.$1, fallback: plan.$2),
            amenities: plan.$3
                ? [
                    for (final key in const ['gymAccess', 'steam', 'sauna', 'jacuzzi', 'pool'])
                      t('explore.gym.amenity.$key', fallback: _amenityFallback(key)),
                  ]
                : const [],
            isAcademy: isAcademy,
            onEnquire: () => context.push('/enquiry', extra: t(plan.$1, fallback: plan.$2)),
          ),
        ),
    ];
  }

  static String _amenityFallback(String key) {
    switch (key) {
      case 'gymAccess': return 'Gym Access';
      case 'steam': return 'Steam';
      case 'sauna': return 'Sauna';
      case 'jacuzzi': return 'Jacuzzi';
      case 'pool': return 'Pool';
      default: return key;
    }
  }

  // Leisure-only Wellness tab: heading + subtitle + 6-card facility grid
  // (reuses _FacilityGrid, same widget as Padel Facilities).
  List<Widget> _wellnessContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    return [
      Text(
        t('explore.wellness.heading', fallback: 'THE WELLNESS JOURNEY'),
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 21, letterSpacing: 1),
      ),
      const SizedBox(height: 8),
      Text(
        t('explore.wellness.subtitle', fallback: 'Experience a holistic wellness journey tailor-made for relaxation and revitalisation.'),
        textAlign: TextAlign.center,
        style: TextStyle(color: mutedColor, fontSize: 13),
      ),
      const SizedBox(height: AppSpacing.lg),
      _FacilityGrid(
        isAcademy: isAcademy,
        items: [
          (
            Icons.water_drop_outlined,
            t('explore.wellness.hydrotherapy', fallback: 'Hydrotherapy'),
            t('explore.wellness.hydrotherapy.sub', fallback: 'Revitalising hydro pools'),
          ),
          (
            Icons.spa_outlined,
            t('explore.wellness.spa', fallback: 'Spa'),
            t('explore.wellness.spa.sub', fallback: 'Luxury curated spa'),
          ),
          (
            Icons.thermostat_outlined,
            t('explore.wellness.sauna', fallback: 'Sauna'),
            t('explore.wellness.sauna.sub', fallback: 'State-of-the-art sauna'),
          ),
          (
            Icons.ac_unit_outlined,
            t('explore.wellness.coldPlunge', fallback: 'Cold Plunge'),
            t('explore.wellness.coldPlunge.sub', fallback: 'Invigorating cold plunge'),
          ),
          (
            Icons.healing_outlined,
            t('explore.wellness.treatments', fallback: 'Treatments'),
            t('explore.wellness.treatments.sub', fallback: 'Personalised healing'),
          ),
          (
            Icons.face_outlined,
            t('explore.wellness.therapists', fallback: 'Therapists'),
            t('explore.wellness.therapists.sub', fallback: 'Experienced therapists'),
          ),
        ],
      ),
    ];
  }

  // Leisure-only Swimming tab: 6 class cards, each with its own Enquire Now.
  List<Widget> _swimmingContent(String Function(String, {String? fallback}) t, bool isAcademy) {
    return [
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        children: [
          for (final item in const [
            (Icons.menu_book_outlined, 'explore.swimming.beginner', 'Beginner Program', 'explore.swimming.beginner.sub', 'Learn water safety and basic swimming skills.'),
            (Icons.bolt_outlined, 'explore.swimming.technique', 'Technique Development', 'explore.swimming.technique.sub', 'Improve stroke technique and breathing control.'),
            (Icons.groups_outlined, 'explore.swimming.junior', 'Junior Swim', 'explore.swimming.junior.sub', 'Structured swim development for young swimmers.'),
            (Icons.emoji_events_outlined, 'explore.swimming.performance', 'Performance Squad', 'explore.swimming.performance.sub', 'Advanced training for competitive swimmers.'),
            (Icons.person_outline, 'explore.swimming.coaching', 'Private Coaching', 'explore.swimming.coaching.sub', 'One-on-one sessions with certified swim coaches.'),
            (Icons.favorite_border, 'explore.swimming.adult', 'Adult Swim Training', 'explore.swimming.adult.sub', 'Build confidence and improve endurance.'),
          ])
            _SwimmingClassCard(
              icon: item.$1,
              title: t(item.$2, fallback: item.$3),
              subtitle: t(item.$4, fallback: item.$5),
              isAcademy: isAcademy,
              onEnquire: () => context.push('/enquiry', extra: t(item.$2, fallback: item.$3)),
            ),
        ],
      ),
    ];
  }

  Widget _sectionHeader(String label, bool isAcademy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        label,
        style: Theme.of(context).textTheme.h3,
      ),
    );
  }

  Widget _buildBody(List<Facility> facilities, String Function(String, {String? fallback}) t, bool isAcademy) {
    switch (_selectedCategoryKey) {
      case 'padel':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: _padelContent(t, isAcademy),
        );
      case 'football':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: _footballContent(t, isAcademy),
        );
      case 'v7arena':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: isAcademy ? _arenaContent(t, isAcademy) : _gymContent(t, isAcademy),
        );
      case 'swimming':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: _swimmingContent(t, isAcademy),
        );
      case 'birthday':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: isAcademy ? _birthdayContent(t, isAcademy) : _wellnessContent(t, isAcademy),
        );
      case 'rooftop':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: _comingSoonContent(t, isAcademy),
        );
      case 'all':
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: [
            _sectionHeader(_categoryLabel('padel', t, isAcademy), isAcademy),
            ..._padelContent(t, isAcademy),
            const SizedBox(height: AppSpacing.lg),
            if (isAcademy) ...[
              _sectionHeader(_categoryLabel('football', t, isAcademy), isAcademy),
              ..._footballContent(t, isAcademy),
              const SizedBox(height: AppSpacing.lg),
            ],
            _sectionHeader(_categoryLabel('v7arena', t, isAcademy), isAcademy),
            ...(isAcademy ? _arenaContent(t, isAcademy) : _gymContent(t, isAcademy)),
            const SizedBox(height: AppSpacing.lg),
            if (!isAcademy) ...[
              _sectionHeader(_categoryLabel('swimming', t, isAcademy), isAcademy),
              ..._swimmingContent(t, isAcademy),
              const SizedBox(height: AppSpacing.lg),
            ],
            _sectionHeader(_categoryLabel('birthday', t, isAcademy), isAcademy),
            ...(isAcademy ? _birthdayContent(t, isAcademy) : _wellnessContent(t, isAcademy)),
            if (!isAcademy) ...[
              const SizedBox(height: AppSpacing.lg),
              _sectionHeader(_categoryLabel('rooftop', t, isAcademy), isAcademy),
              ..._comingSoonContent(t, isAcademy),
            ],
          ],
        );
      default:
        return _buildResults(facilities, t, isAcademy);
    }
  }

  Widget _buildResults(List<Facility> facilities, String Function(String, {String? fallback}) t, bool isAcademy) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: isAcademy ? AppColors.gold : AppColors.black),
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
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : null;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;

    if (isList) {
      return PressableCard(
        onTap: () => _openDetail(context),
        isAcademy: isAcademy,
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
                  color: isAcademy ? AppColors.gold : AppColors.black,
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
                      style: TextStyle(color: isAcademy ? AppColors.gold : AppColors.black, fontSize: 12),
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
                  color: isAcademy ? AppColors.gold : AppColors.black,
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
                      style: TextStyle(color: isAcademy ? AppColors.gold : AppColors.black, fontSize: 11),
                    ),
                    const Spacer(),
                    if (facility.pricePerSlot != null)
                      Text(
                        'SAR ${facility.pricePerSlot!.toStringAsFixed(0)}/slot',
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: isAcademy ? AppColors.gold : AppColors.black,
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

/// Dark numbered feature row used on the Gym tab — fixed style regardless
/// of Academy/Leisure mode, matching the reference design directly.
class _GymFeatureCard extends StatelessWidget {
  final String number;
  final String label;

  const _GymFeatureCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            number,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontWeight: FontWeight.w800, fontSize: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gym membership card — amenities shown as pill tabs (not a checkmark
/// list), matching the reference design.
/// Swimming class card — icon circle, title, subtitle, and its own Enquire
/// Now button (unlike _FacilityGrid's info-only cards).
class _SwimmingClassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isAcademy;
  final VoidCallback onEnquire;

  const _SwimmingClassCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isAcademy,
    required this.onEnquire,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white;

    return PressableCard(
      isAcademy: isAcademy,
      onTap: onEnquire,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
              ),
              child: Icon(icon, size: 20, color: textColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 10.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEnquire,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  t('common.enquireNow', fallback: 'Enquire Now').toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymPlanCard extends StatelessWidget {
  final String name;
  final List<String> amenities;
  final bool isAcademy;
  final VoidCallback onEnquire;

  const _GymPlanCard({
    required this.name,
    required this.amenities,
    required this.isAcademy,
    required this.onEnquire,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white;

    return PressableCard(
      isAcademy: isAcademy,
      onTap: onEnquire,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toUpperCase(),
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            if (amenities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final amenity in amenities)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        amenity.toUpperCase(),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEnquire,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Builder(builder: (context) {
                  final t = context.read<LanguageProvider>().t;
                  return Text(
                    t('common.enquireNow', fallback: 'Enquire Now').toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, color: accent),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String name;
  final List<String> benefits;
  final bool isAcademy;
  final bool showCheckmark;

  const _PackageCard({
    required this.name,
    required this.benefits,
    required this.isAcademy,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;

    return PressableCard(
      isAcademy: isAcademy,
      onTap: () => context.push('/enquiry', extra: name),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toUpperCase(),
              style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final benefit in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showCheckmark) ...[
                      Icon(Icons.check, size: 16, color: accent),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(color: textColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/enquiry', extra: name),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  t('common.enquireNow', fallback: 'Enquire Now').toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, color: accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3-per-row grid of facility cards — icon circle, bold title, muted subtitle.
class _FacilityGrid extends StatelessWidget {
  final List<(IconData, String, String)> items;
  final bool isAcademy;

  const _FacilityGrid({required this.items, required this.isAcademy});

  @override
  Widget build(BuildContext context) {
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;
    final mutedColor = isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.66,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: [
        for (final (icon, title, subtitle) in items)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
                  ),
                  child: Icon(icon, size: 20, color: textColor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedColor, fontSize: 10.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Fixed 3-per-row grid of feature tags (e.g. "3 in one line, N in the next").
class _FeatureGrid extends StatelessWidget {
  final List<String> features;
  final bool isAcademy;

  const _FeatureGrid({required this.features, required this.isAcademy});

  @override
  Widget build(BuildContext context) {
    final accent = isAcademy ? AppColors.gold : AppColors.black;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: [
        for (final feature in features)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isAcademy ? AppColors.cream.withValues(alpha: 0) : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
            ),
            child: Text(
              feature.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
    );
  }
}
