import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:wanzani/screens/auth/login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _loading = false;

  String _countryCode = '+1';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final displayName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final phone = '$_countryCode${_phoneController.text.trim()}';

      // ✅ Create Firebase user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // ✅ Update display name
      await user?.updateDisplayName(displayName);
      await user?.reload();

      // ✅ Save extra data in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'name': displayName,
        'email': email,
        'phone': phone,
        'created_at': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'registration_failed'.tr();

      if (e.code == 'email-already-in-use') {
        message = 'email_already_in_use'.tr();
      } else if (e.code == 'weak-password') {
        message = 'weak_password'.tr();
      } else if (e.code == 'invalid-email') {
        message = 'invalid_email'.tr();
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),

                Center(child: Image.asset('assets/logo.png', height: 70)),
                const SizedBox(height: 32),

                Text(
                  'create_account'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration('first_name'.tr()),
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr() : null,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration('last_name'.tr()),
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr() : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('email'.tr()),
                  validator: (value) =>
                      value!.contains('@') ? null : 'invalid_email'.tr(),
                ),
                const SizedBox(height: 16),

                // Phone
                Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (country) {
                        setState(() {
                          _countryCode = country.dialCode ?? '+1';
                        });
                      },
                      initialSelection: _countryCode,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('phone_number'.tr()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('enter_password'.tr()).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'weak_password'.tr() : null,
                ),
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) =>
                          setState(() => _agreeToTerms = value ?? false),
                    ),
                    Expanded(
                      child: Text('agree_to_terms'.tr()),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _agreeToTerms && !_loading ? _register : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'create_account'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
