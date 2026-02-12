import 'package:flutter/material.dart';
import 'package:weather/screens/main_screen.dart';

// WelcomeScreen: App ka entry point jahan user apna naam enter karta hai
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // inputControler: User ka naam text field se read karne ke liye
  late TextEditingController inputControler;
  // _formKey: Form validation (empty check) ke liye zaroori hai
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    inputControler =
        TextEditingController(); // Controller ko initialize kiya
    super.initState();
  }

  // namePassing: User ka naam le kar MainScreen par navigate karne ka function
  void namePassing(String name) {
    setState(() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainScreen(name: name),
        ),
      );
    });
  }

  @override
  void dispose() {
    inputControler
        .dispose(); // Memory leak se bachne ke liye controller ko dispose kiya
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          // Background Gradient: Blue theme jo weather app par suit karti hai
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2), // Halka Blue (Top)
              Color.fromARGB(198, 31, 59, 115), // Gehra Blue (Bottom)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 25,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Icon ke niche white glow/shadow effect ka container
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/welcomeScreenIcon.png', // Main Logo
                    height: 200,
                  ),
                ),

                const SizedBox(height: 30),

                // Name Input Field with Glassmorphism Effect
                Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(
                      20,
                    ), // Glass effect opacity
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withAlpha(30),
                    ),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey, // Validation key
                    child: TextFormField(
                      controller: inputControler,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your name...',
                        hintStyle: TextStyle(color: Colors.white70),
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                        ),
                      ),
                      // Validation: Check karna ke naam empty na ho
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // "LET'S GO" Custom Button
                GestureDetector(
                  onTap: () {
                    // Agar form valid hai to hi next screen par jao
                    if (_formKey.currentState!.validate()) {
                      namePassing(inputControler.text);
                    }
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(
                        20,
                      ), // Glass effect
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(19),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'LET\'S GO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
