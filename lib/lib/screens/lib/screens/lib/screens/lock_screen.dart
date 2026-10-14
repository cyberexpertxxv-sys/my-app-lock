import 'dart:ui';
import 'package:flutter/material.dart';

class LockScreen extends StatefulWidget {
  final String realPassword;
  final VoidCallback onUnlock;
  final VoidCallback onCancel;

  const LockScreen({
    super.key,
    required this.realPassword,
    required this.onUnlock,
    required this.onCancel,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String entered = "";
  int wrongCount = 0;
  String message = "";
  Color messageColor = Colors.red;

  void _onNumberTap(String num) {
    if (entered.length >= 4) return;
    setState(() => entered += num);
    if (entered.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _checkPassword);
    }
  }

  void _onBackspace() {
    if (entered.isNotEmpty) {
      setState(() => entered = entered.substring(0, entered.length - 1));
    }
  }

  void _checkPassword() {
    if (entered == widget.realPassword) {
      widget.onUnlock();
      return;
    }

    wrongCount++;
    if (wrongCount == 1) {
      message = "Wrong Password";
      messageColor = Colors.red;
    } else if (wrongCount == 2) {
      message = "Nikal Yaha Se";
      messageColor = Colors.orange;
    } else if (wrongCount >= 3) {
      message = "Your Password is 0007";
      messageColor = Colors.yellow;
      wrongCount = 0;
    }

    setState(() => entered = "");

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => message = "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.75)),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 60, color: Colors.white),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < entered.length
                              ? Colors.white
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 30,
                    child: Text(
                      message,
                      style: TextStyle(
                        color: messageColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildKeypad(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
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
              onTap: () {
                if (key == '⌫') {
                  _onBackspace();
                } else {
                  _onNumberTap(key);
                }
              },
              child: Container(
                width: 75,
                height: 75,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
