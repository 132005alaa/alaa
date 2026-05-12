import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.13),

              Container(
                width: screenWidth * 0.22,
                height: screenWidth * 0.22,
                decoration: const BoxDecoration(
                  color: Color(0xff9ACD32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: screenWidth * 0.12,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              Text(
                'تهانينا',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff9ACD32),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              Text(
                'يسعدنا ان تكون جزء من مجتمع يهتم\nبصحته ! مستعد لنبدأ رحلتنا سوا؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.052,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              SizedBox(height: screenHeight * 0.055),

              Image.asset(
                'assests/congratolation.jpg',
                height: screenHeight * 0.3,
                width: screenWidth * 0.85,
                fit: BoxFit.contain,
              ),

              SizedBox(height: screenHeight * 0.07),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/info');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff9ACD32),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.022,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.09),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'هيا بنا',
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
