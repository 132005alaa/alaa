import 'package:flutter/material.dart';
import 'package:healthy_food/features/authentication/screens/LoginScreen.dart';

class Onboarding3Page extends StatelessWidget {
  const Onboarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            const Spacer(),
            Image.asset(
              'assests/onbording3.jpeg',
              height: screenHeight * 0.35,
              width: screenWidth * 0.85,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              'المياه سر الحياة',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                color: const Color(0xffB7D957),
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                'جسمك محتاج ترطيب علشان يفضل\nنشيط وقوي دائما',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.047,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(Colors.grey.shade300, screenWidth),
                SizedBox(width: screenWidth * 0.02),
                _dot(Colors.grey.shade300, screenWidth),
                SizedBox(width: screenWidth * 0.02),
                _dot(Colors.grey, screenWidth),
              ],
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.04,
                left: screenWidth * 0.07,
                right: screenWidth * 0.07,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffB7D957),
                  minimumSize: Size(double.infinity, screenHeight * 0.065),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                  ),
                ),
                child: Text(
                  'التالي',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, double screenWidth) {
    return Container(
      width: screenWidth * 0.025,
      height: screenWidth * 0.025,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
