import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_data_model.dart';
import '../../services/user_data_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  String _name = '';
  String _gender = '';
  int _age = 0;
  double _height = 0;
  double _weight = 0;
  String _goal = '';

  final List<String> _genders = ['ذكر', 'أنثى'];
  final List<String> _goals = [
    'خسارة وزن',
    'زيادة وزن',
    'زيادة عضلات',
    'تثبيت الوزن',
  ];
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataService = UserDataService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        UserData? data = await userDataService.getUserData();
        if (data != null) {
          setState(() {
            _name = user.displayName ?? '';
            _gender = data.gender;
            _age = data.age;
            _height = data.height;
            _weight = data.weight;
            _goal = _goals.contains(data.goal) ? data.goal : '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userDataService = UserDataService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updateDisplayName(_name);

        UserData updatedData = UserData(
          userId: user.uid,
          gender: _gender,
          age: _age,
          height: _height,
          weight: _weight,
          goal: _goal,
        );

        await userDataService.saveUserData(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم تحديث البيانات بنجاح'),
              backgroundColor: Color(0xff6BAF1A),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'بياناتي الشخصية',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff6BAF1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF1F8E9), Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffD6EFA0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xff6BAF1A),
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        onChanged: (value) => _name = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'الاسم مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _gender.isEmpty ? null : _gender,
                        decoration: const InputDecoration(
                          labelText: 'النوع',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        items: _genders
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _gender = value!),
                        validator: (value) => value == null || value.isEmpty
                            ? 'النوع مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: _age == 0 ? '' : _age.toString(),
                        decoration: const InputDecoration(
                          labelText: 'العمر',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _age = int.tryParse(value) ?? 0,
                        validator: (value) => value == null || value.isEmpty
                            ? 'العمر مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: _height == 0 ? '' : _height.toString(),
                        decoration: const InputDecoration(
                          labelText: 'الطول (سم)',
                          prefixIcon: Icon(Icons.height),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _height = double.tryParse(value) ?? 0,
                        validator: (value) => value == null || value.isEmpty
                            ? 'الطول مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: _weight == 0 ? '' : _weight.toString(),
                        decoration: const InputDecoration(
                          labelText: 'الوزن (كجم)',
                          prefixIcon: Icon(Icons.monitor_weight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _weight = double.tryParse(value) ?? 0,
                        validator: (value) => value == null || value.isEmpty
                            ? 'الوزن مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _goals.contains(_goal) ? _goal : null,
                        decoration: const InputDecoration(
                          labelText: 'الهدف',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        items: _goals
                            .map(
                              (goal) => DropdownMenuItem(
                                value: goal,
                                child: Text(goal),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _goal = value);
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'الهدف مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6BAF1A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'حفظ البيانات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
