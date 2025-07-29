import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class WhyPuviPureBlog extends StatelessWidget {
  const WhyPuviPureBlog({super.key});

  @override
  Widget build(BuildContext context) {
    const blogUrl = 'https://puvipure.com/blog/why-puvipure';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Why PuviPure is Committed to 100% Natural Living'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Discover how PuviPure stays truly natural: $blogUrl');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimated read time: 3 min', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // ✅ Placeholder image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('🖼 Blog Image (Coming Soon)', style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 20),

            const Text(
              'At PuviPure, we’re not just selling natural products — we’re leading a movement towards a more conscious, healthy lifestyle. Here’s why we stand apart.',
              style: TextStyle(fontSize: 18, height: 1.6),
            ),

            const SizedBox(height: 20),

            _sectionTitle('🌿 Rooted in Nature'),
            _sectionBody(
              'From farms to your kitchen, every PuviPure product is a journey through nature. '
              'We work closely with local farmers who grow ingredients using traditional, sustainable methods.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🚫 No Preservatives or Additives'),
            _sectionBody(
              'We never use artificial colors, fragrances, refined sugar, or preservatives. '
              'Just pure, honest ingredients — as they’re meant to be.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🔬 Lab Tested for Purity'),
            _sectionBody(
              'Each batch of honey, oil, and powder undergoes strict lab testing. '
              'You get only the cleanest, safest products for your family.',
            ),

            const SizedBox(height: 30),
            const Divider(),

            Wrap(
              spacing: 12,
              children: const [
                Chip(label: Text('Natural Living')),
                Chip(label: Text('No Chemicals')),
                Chip(label: Text('Traditional Methods')),
                Chip(label: Text('Wellness')),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              '👉 Shop our wellness range now: https://puvipure.com',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _sectionBody(String content) {
    return Text(content, style: const TextStyle(fontSize: 16, height: 1.5));
  }
}
