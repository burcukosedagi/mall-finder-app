import 'package:flutter/material.dart';

class FilterSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Set<int> selectedIds;
  final int Function(T) getId;
  final String Function(T) getName;
  final void Function(int id) onToggle;

  const FilterSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.getId,
    required this.getName,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false, // 🔧 Artık kapalı başlıyor
      children:
          items.map((item) {
            final id = getId(item);
            return CheckboxListTile(
              value: selectedIds.contains(id),
              title: Text(getName(item)),
              onChanged: (_) => onToggle(id),
            );
          }).toList(),
    );
  }
}
