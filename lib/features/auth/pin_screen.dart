import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinScreen({super.key, required this.onSuccess});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController controller = TextEditingController();

  final String correctPin = "1234"; // 🔥 change this

  String error = "";

  void checkPin() {
    if (controller.text == correctPin) {
      widget.onSuccess();
    } else {
      setState(() {
        error = "Wrong PIN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter PIN",
                style: TextStyle(color: Colors.white, fontSize: 20)),

            const SizedBox(height: 20),

            SizedBox(
              width: 200,
              child: TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(error, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: checkPin,
              child: const Text("Unlock"),
            )
          ],
        ),
      ),
    );
  }
}
