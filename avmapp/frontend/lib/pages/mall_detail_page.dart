import 'package:flutter/material.dart';
import 'package:frontend/services/api/comment_api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/mall.dart';
import '../controllers/mall_detail_controller.dart';
import '../pages/mall_comments_page.dart';
import '../widgets/comment_form.dart';

class MallDetailPage extends StatefulWidget {
  final Mall mall;

  const MallDetailPage({Key? key, required this.mall}) : super(key: key);

  @override
  State<MallDetailPage> createState() => _MallDetailPageState();
}

class _MallDetailPageState extends State<MallDetailPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();
  final _storeSearchController = TextEditingController();

  final MallDetailController _mallDetailController = MallDetailController();

  int _userRating = 3;
  bool showStores = false;
  List<String> allStores = [];
  List<String> filteredStores = [];
  bool _isHovering = false;
  bool _isTapped = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    _storeSearchController.dispose();
    super.dispose();
  }

  Future<void> fetchStores() async {
    final stores = await _mallDetailController.fetchStores(widget.mall.id);
    setState(() {
      allStores = stores;
      filteredStores = stores;
    });
  }

  void filterStores(String query) {
    setState(() {
      filteredStores =
          allStores
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> handleSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || email.isEmpty || comment.isEmpty) {
      _showSnackbar("Lütfen tüm alanları doldurun.");
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackbar("Geçerli bir e-posta adresi girin.");
      return;
    }

    final success = await CommentApi.submitComment(
      name: name,
      email: email,
      comment: comment,
      rating: _userRating,
      mallId: widget.mall.id,
    );

    if (success) {
      _showSnackbar("✅ Yorum başarıyla gönderildi");

      setState(() {
        widget.mall.commentCount += 1;
        widget.mall.rating =
            ((widget.mall.rating * (widget.mall.commentCount - 1)) +
                _userRating) /
            widget.mall.commentCount;
        _nameController.clear();
        _emailController.clear();
        _commentController.clear();
        _userRating = 3;
      });
    } else {
      _showSnackbar("❌ Gönderim sırasında hata oluştu");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> openWebsite(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar('Web sitesine ulaşılamadı');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mall = widget.mall;

    return Scaffold(
      appBar: AppBar(title: Text(mall.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mall.photoUrl != null)
              Image.network(mall.photoUrl!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(
              mall.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (mall.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  mall.address!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            if (mall.city != null && mall.district != null)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  '${mall.city} / ${mall.district}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: List.generate(5, (i) {
                    if (i < mall.rating.floor()) {
                      return const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      );
                    } else if (i < mall.rating) {
                      return const Icon(
                        Icons.star_half,
                        color: Colors.orange,
                        size: 20,
                      );
                    } else {
                      return const Icon(
                        Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      );
                    }
                  }),
                ),
                const SizedBox(width: 8),
                Text(mall.rating.toStringAsFixed(1)),
                const SizedBox(width: 8),
                const Text('|'),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (_, __, ___) => MallCommentsPage(
                              mallId: mall.id,
                              mallName: mall.name,
                            ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text('(${mall.commentCount} yorum)'),
                      const Icon(Icons.comment, size: 18),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!showStores && allStores.isEmpty) {
                  fetchStores();
                }
                setState(() => showStores = !showStores);
              },
              child: Text(
                showStores ? 'Mağazaları Gizle' : 'Mağazaları Göster',
              ),
            ),
            if (showStores) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _storeSearchController,
                onChanged: filterStores,
                decoration: const InputDecoration(
                  hintText: 'Mağaza ara...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ...filteredStores
                  .map((store) => ListTile(title: Text(store)))
                  .toList(),
            ],
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keyifli vakit geçirmeye hazır ol!'),
                const SizedBox(height: 4),
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovering = true),
                  onExit:
                      (_) => setState(() {
                        _isHovering = false;
                        _isTapped = false;
                      }),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _isTapped = true);
                      await openWebsite(widget.mall.websiteUrl);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (mounted) setState(() => _isTapped = false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _isTapped ? Colors.grey[300] : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'detaylı bilgi için tıkla!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _isHovering || _isTapped
                                  ? const Color.fromARGB(255, 83, 131, 170)
                                  : Colors.grey[800],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            CommentForm(
              nameController: _nameController,
              emailController: _emailController,
              commentController: _commentController,
              rating: _userRating,
              onRatingChanged: (val) => setState(() => _userRating = val),
              onSubmit: handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
