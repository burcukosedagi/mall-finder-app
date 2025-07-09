import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../controllers/lucky_pick_controller.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/mall.dart';
import '../pages/mall_detail_page.dart';
import '../services/api/location_api.dart';
import 'home_page.dart';

class LuckyPickPage extends StatefulWidget {
  @override
  _LuckyPickPageState createState() => _LuckyPickPageState();
}

class _LuckyPickPageState extends State<LuckyPickPage> {
  int? selectedA, selectedB, selectedC;
  int? selectedCityId, selectedDistrictId;

  bool loading = false;
  String? errorMessage;
  Mall? suggestedMall;

  List<City> cities = [];
  List<District> districts = [];

  final List<Map<String, dynamic>> categoryA = [
    {'id': 1, 'name': "Tiyatro"},
    {'id': 2, 'name': "Sinema"},
    {'id': 3, 'name': "Spor"},
  ];
  final List<Map<String, dynamic>> categoryB = [
    {'id': 4, 'name': "Oyun"},
    {'id': 5, 'name': "Alışveriş"},
    {'id': 6, 'name': "Cilt Bakımı"},
  ];
  final List<Map<String, dynamic>> categoryC = [
    {'id': 7, 'name': "Yemek"},
    {'id': 8, 'name': "Tatlı"},
    {'id': 9, 'name': "Kahve"},
  ];

  late List<Map<String, dynamic>> shuffledCategoryA;
  late List<Map<String, dynamic>> shuffledCategoryB;
  late List<Map<String, dynamic>> shuffledCategoryC;

  @override
  void initState() {
    super.initState();
    _shuffleCategories();
    _loadCities();
  }

  void _shuffleCategories() {
    shuffledCategoryA = List<Map<String, dynamic>>.from(categoryA)..shuffle();
    shuffledCategoryB = List<Map<String, dynamic>>.from(categoryB)..shuffle();
    shuffledCategoryC = List<Map<String, dynamic>>.from(categoryC)..shuffle();
  }

  Future<void> _loadCities() async {
    final result = await LocationApi.fetchCities();
    setState(() => cities = result);
  }

  Future<void> _loadDistricts(int cityId) async {
    final result = await LocationApi.fetchDistricts(cityId);
    setState(() {
      districts = result;
      selectedDistrictId = null;
    });
  }

  Future<void> fetchMallSuggestion() async {
    if (selectedA == null ||
        selectedB == null ||
        selectedC == null ||
        selectedCityId == null) {
      setState(() {
        errorMessage = "Şehir ve her kategoriden bir seçim yapmalısın.";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      suggestedMall = null;
    });

    try {
      final selectedIds = [
        shuffledCategoryA[selectedA!]['id'],
        shuffledCategoryB[selectedB!]['id'],
        shuffledCategoryC[selectedC!]['id'],
      ];

      final results = await LuckyPickController.getMallSuggestion(
        selectedIds.cast<int>(),
        cityId: selectedCityId!,
        districtId: selectedDistrictId,
      );

      if (results.isEmpty) {
        errorMessage = "Uygun AVM bulunamadı.";
      } else {
        suggestedMall = (results..shuffle()).first;
      }
    } catch (e) {
      errorMessage = "Bir hata oluştu: $e";
    }

    setState(() => loading = false);
  }

  Widget buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Konum Seçimi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<int>(
          hint: const Text("Şehir seçin"),
          value: selectedCityId,
          isExpanded: true,
          items:
              cities
                  .map(
                    (city) => DropdownMenuItem(
                      value: city.id,
                      child: Text(city.name),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              selectedCityId = value;
              selectedDistrictId = null;
              suggestedMall = null;
              districts.clear();
            });
            _loadDistricts(value!);
          },
        ),
        if (districts.isNotEmpty)
          DropdownButton<int>(
            hint: const Text("Tümü"),
            value: selectedDistrictId,
            isExpanded: true,
            items:
                districts
                    .map(
                      (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => selectedDistrictId = value),
          ),
      ],
    );
  }

  Widget buildGiftBox(int index, String label, String group) {
    final isSelected =
        (group == "A" && selectedA == index) ||
        (group == "B" && selectedB == index) ||
        (group == "C" && selectedC == index);

    final baseBox = Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pink[700] : Colors.pink[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Container(height: 12, color: Colors.yellow[700]),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 45,
            child: Container(width: 12, color: Colors.yellow[700]),
          ),
          const Positioned(
            top: 20,
            child: Text('🎀', style: TextStyle(fontSize: 35)),
          ),
          Positioned(
            bottom: 10,
            left: 6,
            right: 6,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          if (group == "A") selectedA = index;
          if (group == "B") selectedB = index;
          if (group == "C") selectedC = index;
        });
      },
      child:
          isSelected
              ? ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.5),
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: baseBox,
              )
              : baseBox,
    );
  }

  Widget categoryBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildRefreshButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.refresh, size: 28),
          tooltip: 'Yeniden karıştır',
          onPressed: () {
            setState(() {
              selectedA = null;
              selectedB = null;
              selectedC = null;
              suggestedMall = null;
              errorMessage = null;
              _shuffleCategories();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Şansına Ne Çıkarsa?",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(249, 124, 26, 72),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
      floatingActionButton:
          suggestedMall != null
              ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ), // İstediğin yüksekliği ayarlayabilirsin
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MallDetailPage(mall: suggestedMall!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.business),
                  label: const Text("AVM'yi Gör"),
                  backgroundColor: const Color.fromARGB(146, 255, 255, 255),
                ),
              )
              : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildLocationSelector(),
              if (suggestedMall != null) buildRefreshButton(),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (suggestedMall == null) ...[
                const Text(
                  "🎭 Eğlence Seç",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    shuffledCategoryA.length,
                    (i) => buildGiftBox(i, shuffledCategoryA[i]['name'], "A"),
                  ),
                ),
                const Text(
                  "🛍 Aktivite Seç",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    shuffledCategoryB.length,
                    (i) => buildGiftBox(i, shuffledCategoryB[i]['name'], "B"),
                  ),
                ),
                const Text(
                  "🍰 Tat Seç",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    shuffledCategoryC.length,
                    (i) => buildGiftBox(i, shuffledCategoryC[i]['name'], "C"),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: fetchMallSuggestion,
                  child: const Text("AVM Getir"),
                ),
              ] else ...[
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/confetti.json',
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 30,
                        child: Text(
                          suggestedMall!.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    categoryBubble(shuffledCategoryA[selectedA!]['name']),
                    categoryBubble(shuffledCategoryB[selectedB!]['name']),
                    categoryBubble(shuffledCategoryC[selectedC!]['name']),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
