import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Education'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          EducationCard(
            title: 'Proper Hand Hygiene',
            icon: Feather.sunrise, // A more thematic icon
            content: 'Washing hands frequently with soap and water is crucial. Follow these five steps: Wet, Lather, Scrub (for at least 20 seconds), Rinse, and Dry. This helps prevent the spread of most diarrheal diseases.',
          ),
          EducationCard(
            title: 'Safe Drinking Water',
            icon: Feather.droplet,
            content: 'Always use water from a safe source. If unsure, treat it first. You can boil the water for at least one minute, use chlorine tablets as directed, or use a certified water filter.',
          ),
          EducationCard(
            title: 'Recognizing Cholera Symptoms',
            icon: Feather.activity,
            content: 'Key symptoms include severe watery diarrhea (often described as "rice-water stool"), vomiting, and rapid dehydration leading to muscle cramps. Seek medical help immediately if these are observed.',
          ),
           EducationCard(
            title: 'Food Safety Practices',
            icon: Feather.coffee, // Placeholder icon
            content: 'Cook food thoroughly, especially meat. Keep raw and cooked foods separate to avoid cross-contamination. Wash fruits and vegetables with safe water before eating.',
          ),
        ],
      ),
    );
  }
}

// A reusable widget for the expandable education cards
class EducationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const EducationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
