import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../models/facility.dart';
import '../widgets/filter_selection.dart';
import '../widgets/filter_reset_tile.dart';
import '../controllers/filter_controller.dart';

class FilterPage extends StatefulWidget {
  final Set<int> initialSelectedBrandIds;
  final Set<int> initialSelectedFacilityIds;

  const FilterPage({
    super.key,
    required this.initialSelectedBrandIds,
    required this.initialSelectedFacilityIds,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final FilterController _controller = FilterController();

  List<Brand> brands = [];
  List<Facility> facilities = [];
  Set<int> selectedBrandIds = {};
  Set<int> selectedFacilityIds = {};

  @override
  void initState() {
    super.initState();
    selectedBrandIds = {...widget.initialSelectedBrandIds};
    selectedFacilityIds = {...widget.initialSelectedFacilityIds};
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final b = await _controller.fetchBrands();
      final f = await _controller.fetchFacilities();
      setState(() {
        brands = b;
        facilities = f;
      });
    } catch (_) {}
  }

  void toggleSelection(Set<int> selectedSet, int id) {
    setState(() {
      if (selectedSet.contains(id)) {
        selectedSet.remove(id);
      } else {
        selectedSet.add(id);
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedBrandIds.clear();
      selectedFacilityIds.clear();
    });
    Navigator.pop(context);
  }

  void applyFilters() {
    Navigator.pop(context, {
      'brandIds': selectedBrandIds.toList(),
      'facilityIds': selectedFacilityIds.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtrele")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const FilterResetTile(),
            const SizedBox(height: 8),
            FilterSection<Brand>(
              title: "Mağazalar",
              items: brands,
              selectedIds: selectedBrandIds,
              getId: (b) => b.id,
              getName: (b) => b.name,
              onToggle: (id) => toggleSelection(selectedBrandIds, id),
            ),
            const SizedBox(height: 12),
            FilterSection<Facility>(
              title: "Olanaklar",
              items: facilities,
              selectedIds: selectedFacilityIds,
              getId: (f) => f.id,
              getName: (f) => f.name,
              onToggle: (id) => toggleSelection(selectedFacilityIds, id),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: applyFilters,
              child: const Text("Filtrele"),
            ),
          ],
        ),
      ),
    );
  }
}
