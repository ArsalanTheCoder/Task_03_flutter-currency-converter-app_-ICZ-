import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

// Entry point of the app
void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatefulWidget {
  const CurrencyConverterApp({super.key});

  @override
  State<CurrencyConverterApp> createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp> {
  String? selectedCurrency;   // variable for storing the selected currency
  String conversionResult = "";  // string variable for storing the final result and displaying it
  Map<String, dynamic>? currencyRates; // create a map to store the currency rate fetched from the API
  bool isLoading = true;
  bool isDarkMode = false; // for toggling the theme (light or dark mode)
  final TextEditingController pkrController = TextEditingController(); // Controller for storing value from the text field
  double? convertedAmount;

  // Fetches currency rates from the API
  Future<void> fetchDataFromAPI() async {
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/b76c1ea37ac6198c4689ba5c/latest/USD'); // API URL
    final response = await http.get(url); // Get or fetch currency rates from the API

    if (response.statusCode == 200) {
      final Map<String, dynamic> completeApiData = jsonDecode(response.body); // Store data into a map
      setState(() {
        currencyRates = completeApiData['conversion_rates'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to fetch data: ${response.body}");
    }
  }

  // Calculates the converted amount
  void calculateConversion() {
    // Check if the text field is empty or currency is not selected
    if (pkrController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Field is Empty!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.black,
      );
      return;
    }

    if (selectedCurrency == null) {
      Fluttertoast.showToast(
        msg: "Please select a currency!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.black,
      );
      return;
    }

    try {
      // Attempt to parse the input to a double
      final double pkrAmount = double.parse(pkrController.text.trim());

      if (currencyRates != null && currencyRates![selectedCurrency] != null) {
        final double rate = currencyRates![selectedCurrency]!;
        setState(() {
          convertedAmount = pkrAmount / rate;
          conversionResult =
          "${pkrAmount.toStringAsFixed(2)} PKR = ${convertedAmount!.toStringAsFixed(2)} $selectedCurrency";
        });
      } else {
        Fluttertoast.showToast(
          msg: "Error fetching conversion rates. Try again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Handle invalid input gracefully
      Fluttertoast.showToast(
        msg: "Please enter a valid numeric value!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Clears the input field and conversion result
  void clearFields() {
    setState(() {
      pkrController.clear();
      conversionResult = "";
      selectedCurrency = null;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Dark and light mode
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Currency Converter App"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
              activeColor: Colors.yellow,
              inactiveThumbColor: Colors.grey,
            ),
          ],
        ),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(), // Circle indicator until data is fetched from API
        )
            : Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField( // Text field
                controller: pkrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter amount in PKR",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>( // Drop down button
                  hint: const Text('Select Currency'),
                  value: selectedCurrency,
                  isExpanded: true,
                  items: currencyRates?.keys.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCurrency = newValue!;
                      conversionResult = ""; // Clear previous result
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: calculateConversion,
                    child: const Text('Convert'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: clearFields,
                    child: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  conversionResult.isEmpty
                      ? "Conversion result will appear here."
                      : conversionResult,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
