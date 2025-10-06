import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  // As per instructions, the API key is handled by the environment.
  static const String _apiKey = ""; 
  static const String _model = "gemini-2.5-flash-preview-05-20";
  static const String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey";

  static Future<String> analyzeImage(File image) async {
    try {
      // 1. Read the image file into memory and convert it to a base64 string.
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // 2. Define the prompt for the Gemini API. This tells the AI what to do.
      const prompt = """
      You are a helpful assistant for health workers in remote areas. 
      Analyze the following image. Based ONLY on the visual information, 
      identify potential health risks or diseases associated with what is shown 
      (e.g., skin conditions, contaminated water sources). 
      Provide a brief, bulleted list covering:
      1. **Potential Risks:** (e.g., 'Possible bacterial contamination', 'Symptoms consistent with ringworm')
      2. **Suggested Next Steps:** (e.g., 'Boil water before drinking', 'Consult a doctor for diagnosis')
      3. **General Prevention Measures:** (e.g., 'Improve sanitation around the water source', 'Avoid sharing personal items')
      
      IMPORTANT: Start your response with a clear disclaimer in bold: 
      '**This is an AI analysis and not a medical diagnosis. Always consult a qualified healthcare professional for any health concerns.**'
      """;

      // 3. Construct the body of the API request in the required JSON format.
      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      });

      // 4. Send the POST request to the Gemini API.
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      // 5. Parse the response and return the generated text.
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return decodedResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Error: Failed to get analysis. Status code: ${response.statusCode}\nBody: ${response.body}";
      }
    } catch (e) {
      return "An error occurred while analyzing the image: $e";
    }
  }
}

