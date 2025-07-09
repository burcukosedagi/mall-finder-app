import 'package:flutter/material.dart';

class CommentForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController commentController;
  final int rating;
  final Function(int) onRatingChanged;
  final VoidCallback onSubmit;

  const CommentForm({
    Key? key,
    required this.nameController,
    required this.emailController,
    required this.commentController,
    required this.rating,
    required this.onRatingChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yorum Ekle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Adınız',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: commentController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Yorum',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              ...List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () => onRatingChanged(index + 1),
                );
              }),
              Text('$rating/5'),
            ],
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: const Text("Yorumu Gönder"),
            ),
          ),
        ],
      ),
    );
  }
}
