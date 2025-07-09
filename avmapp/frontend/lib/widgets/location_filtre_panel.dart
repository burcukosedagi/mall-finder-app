import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/district.dart';

class LocationFilterPanel extends StatelessWidget {
  final List<City> cities;
  final List<District> districts;
  final int? selectedCityId;
  final int? selectedDistrictId;
  final ValueChanged<int?> onCityChanged;
  final ValueChanged<int?> onDistrictChanged;
  final VoidCallback onFilterPressed;

  const LocationFilterPanel({
    super.key,
    required this.cities,
    required this.districts,
    required this.selectedCityId,
    required this.selectedDistrictId,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Şehir'),
            value: selectedCityId,
            items:
                cities
                    .map(
                      (city) => DropdownMenuItem(
                        value: city.id,
                        child: Text(city.name),
                      ),
                    )
                    .toList(),
            onChanged: onCityChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            decoration: const InputDecoration(labelText: 'İlçe'),
            value: selectedDistrictId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...districts.map((district) {
                return DropdownMenuItem(
                  value: district.id,
                  child: Text(district.name),
                );
              }).toList(),
            ],
            onChanged: onDistrictChanged,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onFilterPressed,
            child: const Text('Filtrele'),
          ),
        ],
      ),
    );
  }
}
