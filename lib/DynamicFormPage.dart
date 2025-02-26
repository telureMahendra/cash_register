import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  // Define the list of categories
  List<String> categories = [
    'Department Store',
    'Specialty stores',
    'Clothing',
    'Furniture',
    'Book Store',
    'Art Craft',
    'Beauty Stores',
    'Food',
    'Super Market',
    'Automobile Parts',
    'Boutiques',
    'Hardware Store',
    'Catalog retailing',
    'E-Commerce store',
    'Retailers',
    'Florist',
    'Vegetable Market Shop',
    'Electronics',
  ];

  // A map to store TextFormField controllers dynamically
  Map<String, TextEditingController> controllers = {};

  // A key to identify the form
  final _formKey = GlobalKey<FormState>();

  // Selected category
  String selectedCategory = 'Department Store';

  // Function to handle the form submission
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> formData = {};

      // Collect form data
      controllers.forEach((key, controller) {
        formData[key] = controller.text;
      });

      // Send data to API (example endpoint)
      final response = await http.post(
        Uri.parse('https://example.com/api/submit'),
        body: json.encode(formData),
        headers: {'Content-Type': 'application/json'},
      );
      print(formData);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit form')));
      }
    }
  }

  // Function to generate dynamic form fields based on category
  List<Widget> generateDynamicFields(String category) {
    List<Widget> fields = [];

    // Add fields based on category
    switch (category) {
      case 'Department Store':
        fields.add(createTextField('Product Type'));
        fields.add(createTextField('Brand'));
        fields.add(createTextField('Price Range'));
        fields.add(createTextField('Size/Dimensions'));
        break;
      case 'Clothing':
        fields.add(createTextField('Size'));
        fields.add(createTextField('Color'));
        fields.add(createTextField('Material'));
        break;
      case 'Electronics':
        fields.add(createTextField('Warranty'));
        fields.add(createTextField('Brand'));
        fields.add(createTextField('Model'));
        break;
      // Add more cases for other categories if needed
      default:
        fields.add(createTextField('Additional Info'));
    }

    return fields;
  }

  // Function to create a TextFormField widget
  Widget createTextField(String label) {
    TextEditingController controller = TextEditingController();
    controllers[label] = controller;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Form Based on Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown button for category selection
              DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                    controllers
                        .clear(); // Clear controllers when category changes
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Dynamic fields based on selected category
              ...generateDynamicFields(selectedCategory),

              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
