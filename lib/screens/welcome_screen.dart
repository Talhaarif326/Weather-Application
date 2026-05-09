import 'package:flutter/material.dart';
import 'package:weather/database/db_helper.dart';
import 'package:weather/screens/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late TextEditingController inputControler;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    inputControler = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    inputControler.dispose();
    super.dispose();
  }

  // Save name to DB then navigate — never shows welcome again
  Future<void> _onLetsGo() async {
    if (_formKey.currentState!.validate()) {
      final name = inputControler.text.trim();
      await DbHelper.instance.saveUser(name); // persisted to SQLite
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(name: name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color.fromARGB(198, 31, 59, 115),
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
                    'assets/images/welcomeScreenIcon.png',
                    height: 200,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withAlpha(30),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
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

                GestureDetector(
                  onTap: _onLetsGo, // now async, saves to DB
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
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
