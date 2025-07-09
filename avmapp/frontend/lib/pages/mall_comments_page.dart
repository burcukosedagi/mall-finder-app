import 'package:flutter/material.dart';
import '../controllers/mall_comments_controller.dart';

class MallCommentsPage extends StatefulWidget {
  final int mallId;
  final String mallName;

  const MallCommentsPage({required this.mallId, required this.mallName});

  @override
  _MallCommentsPageState createState() => _MallCommentsPageState();
}

class _MallCommentsPageState extends State<MallCommentsPage> {
  List<Map<String, dynamic>> allComments = [];
  List<Map<String, dynamic>> filteredComments = [];
  bool isLoading = true;
  FocusNode _focusNode = FocusNode();

  final Map<String, String> sortOptions = {
    'Yeniden Eskiye': 'newest',
    'Eskiden Yeniye': 'oldest',
    'En Yüksek Puan': 'highest',
    'En Düşük Puan': 'lowest',
  };

  String _sortByLabel = 'Yeniden Eskiye';
  String searchQuery = '';
  String? selectedRatingFilter;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final fetched = await MallCommentsController.fetchAndSortComments(
        widget.mallId,
        sortOptions[_sortByLabel]!,
      );
      setState(() {
        allComments = fetched;
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print("Yorumlar yüklenemedi: $e");
    }
  }

  void applyFilters() {
    final result = MallCommentsController.filterComments(
      comments: allComments,
      query: searchQuery,
      ratingFilter: selectedRatingFilter,
    );

    setState(() => filteredComments = result);
  }

  Widget buildStarRow(int rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.orange, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.mallName} - Yorumlar')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        applyFilters();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Yorum veya kullanıcı adı ara...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Sırala: "),
                            const SizedBox(width: 5),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                focusNode: _focusNode,
                                value: _sortByLabel,
                                style: const TextStyle(fontSize: 10),
                                items:
                                    sortOptions.keys.map((label) {
                                      return DropdownMenuItem(
                                        value: label,
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors
                                                    .grey, // 🔹 Gri renk eklendi
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (selected) async {
                                  if (selected == null) return;
                                  _sortByLabel = selected;
                                  await _loadComments();
                                  _focusNode.unfocus();
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('4+'),
                              selected: selectedRatingFilter == '4+',
                              onSelected: (selected) {
                                setState(() {
                                  selectedRatingFilter = selected ? '4+' : null;
                                });
                                applyFilters();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('1–2'),
                              selected: selectedRatingFilter == '1-2',
                              onSelected: (selected) {
                                setState(() {
                                  selectedRatingFilter =
                                      selected ? '1-2' : null;
                                });
                                applyFilters();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredComments.length,
                      itemBuilder: (context, index) {
                        final comment = filteredComments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(comment['name'] ?? 'Anonim'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildStarRow(comment['rating'] ?? 0),
                                const SizedBox(height: 4),
                                Text(comment['comment'] ?? ''),
                                if (comment['created_at'] != null)
                                  Text(
                                    'Tarih: ${DateTime.tryParse(comment['created_at'])?.toLocal().toString().substring(0, 16) ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
