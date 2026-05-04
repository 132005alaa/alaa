import 'package:flutter/material.dart';
import 'package:healthy_food/features/on_boarding/Onboarding3Page.dart';

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                'تخطي',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),

          Spacer(),

          // ✅ تصحيح assets واسم الصورة
          Image.asset('assests/onbording2.jpeg', height: 300),

          SizedBox(height: 40),

          Text(
            'خلي اكلك دوائك',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Color(0xffB7D957),
            ),
          ),

          SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'وجبه متوازنه كل يوم تكون اقوي وقايه\nلجسمك من التعب والامراض',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey, height: 1.5),
            ),
          ),

          SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Onboarding3Page()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffB7D957),
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'التالي',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
