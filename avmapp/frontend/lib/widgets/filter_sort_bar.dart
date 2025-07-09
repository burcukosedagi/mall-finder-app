import 'package:flutter/material.dart';

class FilterSortBar extends StatelessWidget {
  final VoidCallback onSortToggle;
  final VoidCallback onFilterTap;
  final VoidCallback onLocationToggle;

  const FilterSortBar({
    super.key,
    required this.onSortToggle,
    required this.onFilterTap,
    required this.onLocationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSortToggle,
              icon: const Icon(Icons.sort),
              label: const Text('Sırala'),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onFilterTap,
              icon: const Icon(Icons.filter_alt),
              label: const Text('Filtrele'),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onLocationToggle,
              icon: const Icon(Icons.location_on),
              label: const Text('Konum Seç'),
            ),
          ),
        ],
      ),
    );
  }
}
