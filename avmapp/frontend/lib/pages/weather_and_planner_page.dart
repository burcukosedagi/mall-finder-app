import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';
import 'package:frontend/services/weather_service.dart';
import 'package:frontend/models/weather.dart';

class WeatherAndPlannerPage extends StatefulWidget {
  const WeatherAndPlannerPage({super.key});

  @override
  State<WeatherAndPlannerPage> createState() => _WeatherAndPlannerPageState();
}

final _logger = Logger('WeatherAndPlanner');

class _WeatherAndPlannerPageState extends State<WeatherAndPlannerPage> {
  final _weatherService = WeatherService('424a822d89e402f3b2e223be3fcaa6b8');
  Weather? _weather;
  int _selectedDayIndex = 0;

  final TextEditingController _controller = TextEditingController();
  static const String _noteKey = 'day_plan_note';
  bool isBulletMode = false;

  @override
  void initState() {
    super.initState();
    _updateWeatherForDay(0);
    _loadNote();
  }

  Future<void> _updateWeatherForDay(int offset) async {
    try {
      final cityName = await _weatherService.getCurrentCity();
      if (cityName.isEmpty) {
        _logger.warning('Şehir adı boş.');
        setState(() => _weather = null);
        return;
      }

      final weather = await _weatherService.getWeather(
        cityName,
        dayOffset: offset,
      );
      setState(() {
        _selectedDayIndex = offset;
        _weather = weather;
      });
    } catch (e) {
      _logger.severe("Veri alınamadı", e);
      setState(() => _weather = null);
    }
  }

  String translateCondition(String? condition) {
    if (condition == null) return "";
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Güneşli';
      case 'clouds':
        return 'Bulutlu';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'Yağmurlu';
      case 'snow':
        return 'Karlı';
      case 'thunderstorm':
        return 'Fırtına';
      case 'mist':
      case 'fog':
      case 'smoke':
        return 'Sisli';
      default:
        return condition;
    }
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/sunny.json';
    final now = DateTime.now().hour;
    final isNight = now >= 19 || now < 5;

    if (isNight) {
      switch (condition.toLowerCase()) {
        case 'clear':
          return 'assets/sunny_night.json';
        case 'clouds':
          return 'assets/cloud_night.json';
        case 'rain':
          return 'assets/rain_night.json';
        default:
          return 'assets/mist.json';
      }
    }

    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'snow':
        return 'assets/snow.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/mist.json';
    }
  }

  String _getDayLabelFromOffset(int offset) {
    final date = DateTime.now().add(Duration(days: offset));
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return '${days[date.weekday - 1]} | ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getDayShortLabel(int offset) {
    if (offset == 0) return "Bugün";
    if (offset == 1) return "Yarın";
    return "";
  }

  void _loadNote() {
    final box = Hive.box<String>('notesBox');
    _controller.text = box.get(_noteKey) ?? '';
  }

  void _saveNote(String value) {
    Hive.box<String>('notesBox').put(_noteKey, value);
  }

  void _clearNote() {
    Hive.box<String>('notesBox').delete(_noteKey);
    _controller.clear();
  }

  void _onTextChanged(String value) {
    if (isBulletMode) {
      List<String> lines = value.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.isEmpty) {
          lines[i] = '';
        } else if (!line.startsWith('• ')) {
          lines[i] = '• $line';
        }
      }
      final newText = lines.join('\n');
      if (newText != _controller.text) {
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
    _saveNote(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(249, 124, 26, 72),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Gününü Planla",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              if (_weather != null)
                Lottie.asset(
                  getWeatherAnimation(_weather!.mainCondition),
                  width: 200,
                  height: 200,
                )
              else
                const CircularProgressIndicator(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.black54),
                  Text(
                    _weather?.cityName ?? "Yükleniyor...",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedDayIndex > 0)
                    IconButton(
                      onPressed:
                          () => _updateWeatherForDay(_selectedDayIndex - 1),
                      icon: const Icon(Icons.chevron_left),
                    )
                  else
                    const SizedBox(width: 40),
                  Text(
                    '${_weather?.temperature.round()}°C | ${translateCondition(_weather?.mainCondition)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_selectedDayIndex < 6)
                    IconButton(
                      onPressed:
                          () => _updateWeatherForDay(_selectedDayIndex + 1),
                      icon: const Icon(Icons.chevron_right),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),

              Text(
                _getDayLabelFromOffset(_selectedDayIndex),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),

              // EKLENEN KÜÇÜK GRİ BUGÜN/YARIN YAZISI
              if (_getDayShortLabel(_selectedDayIndex).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _getDayShortLabel(_selectedDayIndex),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Alışveriş Listem",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 188, 71, 139),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Stack(
                children: [
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 160, 126, 167),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: _onTextChanged,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: "Bugün neler yapacaksın?",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 155, 155, 155),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(top: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isBulletMode = !isBulletMode);
                        _onTextChanged(_controller.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isBulletMode
                                  ? Colors.purple.shade100
                                  : Colors.transparent,
                          border: Border.all(color: Colors.purple.shade200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "• Madde Ekle",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.black54,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Emin misin?"),
                                content: const Text(
                                  "Bu not kalıcı olarak silinecek.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text("İptal"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text("Sil"),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) _clearNote();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
