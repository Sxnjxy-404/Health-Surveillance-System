import 'package:flutter/material.dart';

class RadioGroupWidget extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onChanged;

  const RadioGroupWidget({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: title,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedOption,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

