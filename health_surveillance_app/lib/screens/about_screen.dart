import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About this App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Feather.activity,
                    size: 64,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Health Surveillance System',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Developed by Team SAFEDROPS@',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            Text(
              'Abstract',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              "Water-borne diseases pose a significant threat to public health in rural and semi-urban regions, where challenges like delayed outbreak detection and limited internet connectivity hinder effective medical response. This project introduces the Smart Health Surveillance System, a comprehensive mobile application designed to bridge this gap. Developed using Flutter and powered by a robust Firebase backend, the system provides a reliable tool for health workers in the field. Key innovations include AI-powered image analysis, automated push notifications, offline-first data collection, and in-app analytics to enhance the capability for early disease detection and improve data-driven decision-making for health officials.",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

