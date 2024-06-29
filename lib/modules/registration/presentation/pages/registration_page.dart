import 'dart:io';
import 'package:assignment/modules/dashboard/presentation/pages/dashboard_page.dart';
import 'package:assignment/modules/registration/presentation/widget/app_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageUrl;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadImage(String id) async {
    if (_imageFile == null) return;
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('userImages/$id');
    await imageRef.putFile(File(_imageFile!.path));
    _imageUrl = await imageRef.getDownloadURL();
  }

  Future<void> _registerUser() async {
    setState(() {
      _loading = true;
    });

    String id = _idController.text;
    String name = _nameController.text;
    String email = _emailController.text;

    if (id.isEmpty || name.isEmpty || email.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and attach an image')),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      await _uploadImage(id);
      await FirebaseFirestore.instance.collection('userData').add({
        'id': id,
        'name': name,
        'email': email,
        'imageUrl': _imageUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
      _idController.clear();
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _imageFile = null;
        _imageUrl = null;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/img/bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Registration',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      height: 0,
                      color: Color.fromARGB(255, 93, 38, 212),
                    ),
                  ),
                  const Text(
                    'Enter your details to register',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 93, 38, 212),
                    ),
                  ),
                  const SizedBox(height: 50),
                  AppInputField(
                    controller: _idController,
                    hintText: 'Enter your Id',
                    labelText: 'Id',
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    controller: _nameController,
                    hintText: 'Enter your Name',
                    labelText: 'Name',
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    controller: _emailController,
                    hintText: 'Enter your Email-id',
                    labelText: 'Email-Id',
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          if (_imageFile != null)
                            Image.file(
                              File(_imageFile!.path),
                              height: 100,
                              width: 100,
                            )
                          else
                            const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          const Text("Please tap to select image")
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _loading ? null : _registerUser,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 138, 90, 242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : const Center(child: Text('Register')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 138, 90, 242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Go To DashBoard')),
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
}
