import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/models/city.dart';
import 'package:frontend/models/district.dart';
import 'package:frontend/models/mall.dart';
import 'package:frontend/pages/filter_page.dart';
import 'package:frontend/services/api/location_api.dart';
import 'package:frontend/widgets/animated_bottom_navbar.dart';
import 'package:frontend/widgets/filter_sort_bar.dart';
import 'package:frontend/widgets/location_filtre_panel.dart';
import 'package:frontend/widgets/mall_card.dart';
import '../controllers/search_controller.dart' as my;

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Mall> mallList = [];
  List<Mall> filteredMallList = [];
  List<City> cities = [];
  List<District> districts = [];

  int? selectedCityId;
  int? selectedDistrictId;
  Set<int> selectedBrandIds = {};
  Set<int> selectedFacilityIds = {};

  bool isLoading = true;
  bool showSortOptions = false;
  bool showLocationFilter = false;
  bool filtersApplied = false;

  Timer? _debounce;
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final malls = await my.SearchController.fetchMalls();
      final cityList = await LocationApi.fetchCities();

      setState(() {
        mallList = malls;
        cities = cityList;
        isLoading = false;

        if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
          filteredMallList = my.SearchController.searchMalls(
            mallList,
            widget.initialQuery!,
          );
        } else {
          filteredMallList = malls;
        }
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchDistricts(int cityId) async {
    final result = await LocationApi.fetchDistricts(cityId);
    setState(() {
      districts = result;
      selectedDistrictId = null;
    });
  }

  void filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredMallList = my.SearchController.searchMalls(mallList, query);
      });
    });
  }

  Future<void> sortMalls(String by, String order) async {
    final results = await my.SearchController.sortMalls(by, order);
    setState(() {
      filteredMallList = results;
      showSortOptions = false;
    });
  }

  Future<void> applyLocationFilter() async {
    final results = await my.SearchController.filterMalls(
      cityId: selectedCityId,
      districtId: selectedDistrictId,
      brandIds: selectedBrandIds.toList(),
      facilityIds: selectedFacilityIds.toList(),
    );
    setState(() {
      filteredMallList = results;
      showLocationFilter = false;
      filtersApplied = true;
    });
  }

  void clearAllFilters() async {
    setState(() {
      selectedCityId = null;
      selectedDistrictId = null;
      selectedBrandIds.clear();
      selectedFacilityIds.clear();
      filtersApplied = false;
      _searchController.clear();
    });
    final malls = await my.SearchController.fetchMalls();
    setState(() {
      mallList = malls;
      filteredMallList = malls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AnimatedBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        title: const Text('AVM Ara'),
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: filterSearch,
                          decoration: InputDecoration(
                            hintText: 'AVM Ara...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (filtersApplied)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: clearAllFilters,
                              icon: const Icon(Icons.clear),
                              label: const Text('Filtreleri Temizle'),
                            ),
                          ),
                        ),
                      FilterSortBar(
                        onSortToggle: () {
                          setState(() {
                            showSortOptions = !showSortOptions;
                            showLocationFilter = false;
                          });
                        },
                        onLocationToggle: () {
                          setState(() {
                            showLocationFilter = !showLocationFilter;
                            showSortOptions = false;
                          });
                        },
                        onFilterTap: () async {
                          final filters = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (_, __, ___) => FilterPage(
                                    initialSelectedBrandIds: selectedBrandIds,
                                    initialSelectedFacilityIds:
                                        selectedFacilityIds,
                                  ),
                              transitionsBuilder: (_, animation, __, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );

                          if (filters == null) {
                            clearAllFilters();
                            return;
                          }

                          selectedBrandIds = Set<int>.from(filters['brandIds']);
                          selectedFacilityIds = Set<int>.from(
                            filters['facilityIds'],
                          );

                          final results = await my.SearchController.filterMalls(
                            cityId: selectedCityId,
                            districtId: selectedDistrictId,
                            brandIds: selectedBrandIds.toList(),
                            facilityIds: selectedFacilityIds.toList(),
                          );

                          setState(() {
                            filteredMallList = results;
                            filtersApplied = true;
                          });
                        },
                      ),
                      if (showLocationFilter)
                        LocationFilterPanel(
                          cities: cities,
                          districts: districts,
                          selectedCityId: selectedCityId,
                          selectedDistrictId: selectedDistrictId,
                          onCityChanged: (id) {
                            setState(() {
                              selectedCityId = id;
                              selectedDistrictId = null;
                            });
                            fetchDistricts(id!);
                          },
                          onDistrictChanged:
                              (id) => setState(() => selectedDistrictId = id),
                          onFilterPressed: applyLocationFilter,
                        ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            filteredMallList.isEmpty
                                ? const Center(child: Text("Sonuç bulunamadı"))
                                : ListView.builder(
                                  itemCount: filteredMallList.length,
                                  itemBuilder: (context, index) {
                                    final mall = filteredMallList[index];
                                    return MallCard(mall: mall);
                                  },
                                ),
                      ),
                    ],
                  ),
                  if (showSortOptions)
                    Positioned(
                      left: 16,
                      top: 110,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 228, 228, 228),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () => sortMalls('name', 'asc'),
                                child: const Text('Alfabetik (A-Z)'),
                              ),
                              TextButton(
                                onPressed: () => sortMalls('rating', 'desc'),
                                child: const Text('Puan (Yüksekten Düşüğe)'),
                              ),
                              TextButton(
                                onPressed:
                                    () => sortMalls('comment_count', 'desc'),
                                child: const Text('Yorum Sayısı (Çoktan Aza)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
