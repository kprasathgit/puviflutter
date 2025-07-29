import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HerbalPowdersUsesBlog extends StatelessWidget {
  const HerbalPowdersUsesBlog({super.key});

  @override
  Widget build(BuildContext context) {
    const blogUrl = 'https://puvipure.com/blog/herbal-powders-uses';

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'How to Use Herbal Powders for Skin & Hair',
            style: const TextStyle(fontSize: 18), // smaller on mobile
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this blog: $blogUrl');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimated read time: 4 min',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text(
              'Ancient herbs meet modern skincare: Discover how to use traditional herbal powders for glowing skin and healthy hair.',
              style: TextStyle(fontSize: 18, height: 1.6),
            ),
            const SizedBox(height: 20),
            _sectionTitle('🌿 Neem Powder – For Acne & Pimples'),
            _sectionBody(
              'Neem is a powerful antibacterial herb. Mix neem powder with rose water or aloe vera gel and apply it as a face pack. '
              'This helps reduce acne, blackheads, and skin inflammation naturally.',
            ),
            const SizedBox(height: 20),
            _sectionTitle('🌸 Hibiscus Powder – Hair Strengthener'),
            _sectionBody(
              'Hibiscus is rich in amino acids that nourish the hair. Combine hibiscus powder with yogurt or coconut milk to make a hair mask. '
              'Leave it for 30 minutes and rinse for smoother, thicker hair.',
            ),
            const SizedBox(height: 20),
            _sectionTitle('🌾 Multani Mitti – Oil Control'),
            _sectionBody(
              'Popularly known as Fullers Earth, this powder helps control excess oil and unclog pores. Great for oily and combination skin.',
            ),
            const SizedBox(height: 20),
            _sectionTitle('🍃 How Often Should You Use?'),
            _sectionBody(
              'Use 1–2 times a week for best results. Always do a patch test to avoid any allergic reactions.',
            ),
            const SizedBox(height: 30),
            const Divider(),
            Wrap(
              spacing: 12,
              children: const [
                Chip(label: Text('Herbal')),
                Chip(label: Text('Skincare')),
                Chip(label: Text('Haircare')),
                Chip(label: Text('Ayurvedic')),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://puvipure.com'),
                  mode: LaunchMode.platformDefault),
              child: const Text(
                '👉 Shop our wellness range now: https://puvipure.com',
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _sectionBody(String content) {
    return Text(content, style: const TextStyle(fontSize: 16, height: 1.5));
  }
}
