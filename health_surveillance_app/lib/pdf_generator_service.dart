import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw; // Corrected this import line
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class PdfGeneratorService {
  static Future<void> generateAndSavePdf(Map<String, dynamic> reportData) async {
    // 1. Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    
    // 2. Create the PDF document
    final pdf = pw.Document();
    
    // --- FIX: Corrected the paths to the font files ---
    final font = await pw.Font.ttf(await rootBundle.load("assets/fonts/Poppins/Poppins-Regular.ttf"));
    final boldFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Poppins/Poppins-Bold.ttf"));

    final timestamp = reportData['createdAt'] as Timestamp?;
    final dateString = timestamp != null ? DateFormat('dd MMM, yyyy - hh:mm a').format(timestamp.toDate()) : 'N/A';

    // Helper function for creating styled rows
    pw.Widget buildRow(String title, String? value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 150,
              child: pw.Text(title, style: pw.TextStyle(font: boldFont)),
            ),
            pw.Expanded(
              child: pw.Text(value ?? 'N/A', style: pw.TextStyle(font: font)),
            ),
          ],
        ),
      );
    }
    
    // 3. Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Health Surveillance Report',
                style: pw.TextStyle(font: boldFont, fontSize: 24),
              ),
              pw.Text(
                'Village: ${reportData['village'] ?? 'N/A'}',
                style: pw.TextStyle(font: font, fontSize: 18),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Generated on: $dateString', style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic)),
              pw.Divider(height: 20),
              
              buildRow('Reported By:', reportData['reporterEmail']),
              buildRow('Affected Cases:', reportData['caseCount']?.toString()),
              buildRow('Total Population:', reportData['totalPopulation']?.toString()),
              pw.Divider(height: 10),

              buildRow('Symptoms:', (reportData['symptoms'] as List<dynamic>?)?.join(', ')),
              buildRow('Symptom Severity:', reportData['symptomSeverity']),
              pw.Divider(height: 10),
              
              buildRow('Primary Water Source:', reportData['waterSource']),
              buildRow('Water Odor:', reportData['waterOdor']),
              buildRow('Water Appearance:', reportData['waterAppearance']),
              pw.Divider(height: 10),

              buildRow('Notes:', reportData['notes']),
            ],
          );
        },
      ),
    );

    // 4. Save the PDF to the device
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/report-${reportData['village']}-${timestamp?.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    // 5. Open the saved PDF
    await OpenFile.open(file.path);
  }
}

