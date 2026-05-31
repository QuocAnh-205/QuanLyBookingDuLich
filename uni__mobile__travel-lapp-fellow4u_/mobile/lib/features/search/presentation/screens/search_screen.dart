import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/explore/presentation/widgets/tour_card.dart';
import 'package:mobile/features/explore/presentation/widgets/guide_card.dart';
import 'package:mobile/features/explore/data/models/explore_models.dart';
import 'package:mobile/features/search/data/models/search_models.dart';
import 'package:mobile/features/search/presentation/provider/search_provider.dart';
import 'package:mobile/features/details/presentation/screens/tour_detail_screen.dart';
import 'package:mobile/features/details/presentation/screens/guide_detail_screen.dart';
import 'package:mobile/features/details/presentation/screens/destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<SearchProvider>().fetchSuggestions(token);
    });
  }

  void _onSearch(String val) {
    if (val.isEmpty) {
      context.read<SearchProvider>().clearResults();
      return;
    }
    final token = context.read<AuthProvider>().token;
    context.read<SearchProvider>().performSearch(val, token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tours, guides...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF00CEA6)),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
          }

          if (provider.results == null) {
            return _buildSuggestions(provider);
          }

          if (provider.results!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text('No results found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  TextButton(
                    onPressed: () => provider.clearResults(),
                    child: const Text('Clear Search', style: TextStyle(color: Color(0xFF00CEA6))),
                  ),
                ],
              ),
            );
          }

          return _buildResults(provider);
        },
      ),
    );
  }

  Widget _buildSuggestions(SearchProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (provider.userHistory.isNotEmpty) ...[
          const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: provider.userHistory.take(5).map((h) => ActionChip(
              label: Text(h.keyword),
              onPressed: () {
                _searchController.text = h.keyword;
                _onSearch(h.keyword);
              },
            )).toList(),
          ),
          const SizedBox(height: 30),
        ],
        const Text('Trending Keywords', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: provider.popularKeywords.map((k) => ActionChip(
            label: Text(k),
            backgroundColor: const Color(0xFF00CEA6).withOpacity(0.1),
            onPressed: () {
              _searchController.text = k;
              _onSearch(k);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResults(SearchProvider provider) {
    final results = provider.results!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (results.locations.isNotEmpty) ...[
          const Text('Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...results.locations.map((Location l) => ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFF00CEA6)),
            title: Text(l.name),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => DestinationDetailScreen(locationId: l.id))
            ),
          )).toList(),
          const SizedBox(height: 20),
        ],
        if (results.tours.isNotEmpty) ...[
          const Text('Tours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...results.tours.map((Tour t) => TourCard(
            tour: t, 
            isHorizontal: false,
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => TourDetailScreen(tourId: t.id))
            ),
          )).toList(),
          const SizedBox(height: 20),
        ],
        if (results.guides.isNotEmpty) ...[
          const Text('Guides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: results.guides.length,
            itemBuilder: (context, index) {
              final Guide guide = results.guides[index];
              return GuideCard(
                guide: guide,
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => GuideDetailScreen(guideId: guide.id))
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues _currentRange = const RangeValues(0, 500);
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Price Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RangeSlider(
            values: _currentRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: const Color(0xFF00CEA6),
            labels: RangeLabels('$_currentRange.start', '$_currentRange.end'),
            onChanged: (values) => setState(() => _currentRange = values),
          ),
          const SizedBox(height: 20),
          const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ['Tour', 'Guide', 'Experience'].map((type) => ChoiceChip(
              label: Text(type),
              selected: _selectedType == type,
              onSelected: (val) => setState(() => _selectedType = val ? type : null),
              selectedColor: const Color(0xFF00CEA6).withOpacity(0.2),
            )).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CEA6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<SearchProvider>().updateFilters(
                  min: _currentRange.start,
                  max: _currentRange.end,
                  type: _selectedType,
                );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
