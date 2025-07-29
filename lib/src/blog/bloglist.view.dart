import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blogs = [
      {
        'title': 'Why PuviPure is Committed to 100% Natural Living',
        'slug': 'why-puvipure',
        'desc': 'A deep look into our natural promise and purity principles.',
      },
      {
        'title': 'Health Benefits of Cold Pressed Oils',
        'slug': 'benefits-cold-pressed-oils',
        'desc': 'Learn why cold-pressed oils are essential for a healthy life.',
      },
      {
        'title': 'How to Use Herbal Powders for Skin & Hair',
        'slug': 'herbal-powders-uses',
        'desc': 'Tips to naturally glow using herbal powders.',
      },
      {
        'title': 'How PuviPure Oils Are Cold Pressed Without Chemicals',
        'slug': 'how-we-make',
        'desc': 'Discover our traditional wooden cold press method.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('PuviPure Blog')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final blog = blogs[i];
          return ListTile(
            title: Text(blog['title']!),
            subtitle: Text(blog['desc']!),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.go('/blog/${blog['slug']}');
            },
          );
        },
      ),
    );
  }
}
