import 'package:flutter/material.dart';
import 'package:healthy_food/features/on_boarding/Onboarding2Page.dart';

class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  void _goToNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Onboarding2Page()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.02,
                  right: screenWidth * 0.05,
                ),
                child: GestureDetector(
                  onTap: () => _goToNext(context),
                  child: Text(
                    'تخطي',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
            Image.asset(
              'assests/onbording1.jpeg',
              height: screenHeight * 0.35,
              width: screenWidth * 0.85,
              fit: BoxFit.contain,
            ),

            SizedBox(height: screenHeight * 0.04),
            Text(
              'الصحه تبدا من طبقك',
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
                'اكتشف وصفات سهله :مغذيه :ولذيذه\nكل يوم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.047,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(Colors.grey, screenWidth),
                SizedBox(width: screenWidth * 0.02),
                _dot(Colors.grey.shade300, screenWidth),
                SizedBox(width: screenWidth * 0.02),
                _dot(Colors.grey.shade300, screenWidth),
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
                onPressed: () => _goToNext(context),
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
