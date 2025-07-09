import 'package:flutter/material.dart';

class FilterResetTile extends StatelessWidget {
  const FilterResetTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: const Icon(Icons.refresh, color: Colors.red),
      title: const Text(
        'Filtreleri Sıfırla',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      onTap: () {
        Navigator.pop(context); // Sıfırlama üst componentte yapılacak
      },
    );
  }
}
