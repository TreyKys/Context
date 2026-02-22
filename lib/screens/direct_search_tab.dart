import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DirectSearchTab extends StatefulWidget {
  const DirectSearchTab({super.key});

  @override
  State<DirectSearchTab> createState() => _DirectSearchTabState();
}

class _DirectSearchTabState extends State<DirectSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showResult = false;

  void _performSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _showResult = false; // Reset to trigger animation again if needed
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _showResult = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2E2F),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a definition...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: const Icon(CupertinoIcons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(CupertinoIcons.arrow_right_circle_fill, color: Colors.blueAccent),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(height: 40),

          // Result Card (Animated)
          if (_showResult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F20),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade800),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Icon
                  Row(
                    children: [
                      const Icon(CupertinoIcons.book_fill, color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _searchController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Definition Text
                  const Text(
                    "A placeholder definition that represents the analytical and precise nature of the Direct Search mode. This text would dynamically update based on the API response.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFFE3E3E3),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags / Chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildChip('Noun', CupertinoIcons.tag),
                      _buildChip('Formal', CupertinoIcons.briefcase),
                      _buildChip('Tech', CupertinoIcons.device_laptop),
                      _buildChip('Origin: Latin', CupertinoIcons.globe),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .fade(duration: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade300),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade300)),
        ],
      ),
      backgroundColor: const Color(0xFF2D2E2F),
      selected: false,
      onSelected: (_) {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade700),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
