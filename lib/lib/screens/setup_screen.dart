import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String pin = "";
  String confirmPin = "";
  bool isConfirming = false;
  String error = "";

  void _onNumberTap(String num) {
    if (!isConfirming) {
      if (pin.length >= 4) return;
      setState(() => pin += num);
      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => isConfirming = true);
        });
      }
    } else {
      if (confirmPin.length >= 4) return;
      setState(() => confirmPin += num);
      if (confirmPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), _savePassword);
      }
    }
  }

  void _onBackspace() {
    setState(() {
      if (isConfirming) {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        }
      } else {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
      }
    });
  }

  Future<void> _savePassword() async {
    if (pin != confirmPin) {
      setState(() {
        error = "Password match nahi hua, dobara try karo";
        pin = "";
        confirmPin = "";
        isConfirming = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('real_password', pin);
    await prefs.setBool('master_on', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = isConfirming ? confirmPin : pin;
    final title = isConfirming ? "Confirm Password" : "Set Your Password";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0a0a0a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 70, color: Colors.white70),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(error,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 14)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          i < current.length ? Colors.white : Colors.white24,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              _keypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 80);
            return GestureDetector(
              onTap: () => key == '⌫' ? _onBackspace() : _onNumberTap(key),
              child: Container(
                width: 75,
                height: 75,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Text(key,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
