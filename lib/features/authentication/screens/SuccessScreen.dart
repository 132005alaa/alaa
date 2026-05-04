import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 120),

              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xff9ACD32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),

              const SizedBox(height: 30),

              const Text(
                'تهانينا',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff9ACD32),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'يسعدنا ان تكون جزء من مجتمع يهتم\nبصحته ! مستعد لنبدأ رحلتنا سوا؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.grey.shade500,
                  height: 1,
                ),
              ),

              const SizedBox(height: 60),

              Image.asset('assests/congratolation.jpg', height: 250),

              const SizedBox(height: 80),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/info');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff9ACD32),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'هيا بنا',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
