import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HowWeMakeBlog extends StatelessWidget {
  const HowWeMakeBlog({super.key});

  @override
  Widget build(BuildContext context) {
    const blogUrl = 'https://puvipure.com/blog/how-we-make';

    return Scaffold(
      appBar: AppBar(
        title: const Text('How PuviPure Oils Are Cold Pressed Without Chemicals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Take a peek at our traditional oil-making process: $blogUrl');
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
            const SizedBox(height: 10),

            const Text(
              'Ever wondered how your oil is made? At PuviPure, we stick to our roots—literally—with the traditional wooden Ghani method.',
              style: TextStyle(fontSize: 18, height: 1.6),
            ),

            const SizedBox(height: 20),
            _sectionTitle('🛠 Traditional Wooden Ghani'),
            _sectionBody(
              'We use the age-old method of cold pressing oils using a wooden Ghani (a type of traditional mill). '
              'Unlike modern extraction, it retains the natural aroma, taste, and nutrients.',
            ),

            const SizedBox(height: 20),
            _sectionTitle('🌡 No External Heat Applied'),
            _sectionBody(
              'Cold pressing means the seeds are crushed at room temperature—so no nutritional value is lost. '
              'You get oil in its purest form, unrefined and untouched by chemicals.',
            ),

            const SizedBox(height: 20),
            _sectionTitle('🧪 No Chemicals, Ever'),
            _sectionBody(
              'We do not bleach, refine, or deodorize our oils. Instead, natural sedimentation is used to separate particles—just like our ancestors did.',
            ),

            const SizedBox(height: 20),
            _sectionTitle('🔬 Lab-Tested for Purity'),
            _sectionBody(
              'To ensure the highest quality, every batch is lab-tested for chemical-free assurance and meets safety standards.',
            ),

            const SizedBox(height: 30),
            const Divider(),

            Wrap(
              spacing: 12,
              children: const [
                Chip(label: Text('Cold Pressed')),
                Chip(label: Text('Oil Extraction')),
                Chip(label: Text('Traditional Methods')),
                Chip(label: Text('Natural')),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              '👉 Explore our oils collection: https://puvipure.com',
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
