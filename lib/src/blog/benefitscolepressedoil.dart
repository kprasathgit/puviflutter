import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BenefitsColdPressedOilsBlog extends StatelessWidget {
  const BenefitsColdPressedOilsBlog({super.key});

  @override
  Widget build(BuildContext context) {
    const blogUrl = 'https://puvipure.com/blog/benefits-cold-pressed-oils';

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Health Benefits of Cold Pressed Oils',
            style: const TextStyle(fontSize: 18), // smaller on mobile
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Check this out: $blogUrl');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⏱ Estimated Read Time
            const Text(
              'Estimated read time: 4 min',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // 📰 Subtitle
            const Text(
              'Why cold-pressed oils are a healthy choice for your kitchen and your heart.',
              style: TextStyle(fontSize: 18, height: 1.6),
            ),
            const SizedBox(height: 20),

            // 📚 Section 1
            _sectionTitle('🥥 What Are Cold Pressed Oils?'),
            _sectionBody(
              'Cold pressed oils are extracted at low temperatures without applying any external heat or chemicals. This method retains all essential nutrients and antioxidants.',
            ),
            const SizedBox(height: 20),

            // 📚 Section 2
            _sectionTitle('💚 Full of Healthy Fats & Nutrients'),
            _sectionBody(
              'These oils are rich in unsaturated fats, vitamin E, and natural antioxidants, which promote better skin, hair, and overall cardiovascular health.',
            ),
            const SizedBox(height: 20),

            // 📚 Section 3
            _sectionTitle('🔥 Better Cooking & Taste'),
            _sectionBody(
              'Unlike refined oils, cold-pressed oils enhance the flavor of your food while being more stable at medium heat.',
            ),
            const SizedBox(height: 20),

            // 📚 Section 4
            _sectionTitle('🚫 No Preservatives or Additives'),
            _sectionBody(
              'They are free from chemicals, deodorizing agents, or artificial colors, making them ideal for people seeking natural nutrition.',
            ),

            const SizedBox(height: 30),
            const Divider(),

            // 🏷 Tags & Categories
            Wrap(
              spacing: 12,
              children: const [
                Chip(label: Text('Cold Pressed')),
                Chip(label: Text('Healthy Oils')),
                Chip(label: Text('Nutrition')),
                Chip(label: Text('Cooking')),
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

  Widget _sectionBody(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, height: 1.5));
  }
}
