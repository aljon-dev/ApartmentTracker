import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Tenant/homePage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    String _selectedRole = 'tenant';
    final _formKey = GlobalKey<FormState>();
  final _fireAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
   bool _isPasswordVisible = false;


  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _verificationId;



  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
     
      final userCredential = await _fireAuth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

        DocumentSnapshot documentSnapshot = await _firestore
        .collection('tenants')
        .doc(userCredential.user!.uid)
        .get();

        if(documentSnapshot.exists){
          Map<String,dynamic> userData = documentSnapshot.data() as Map<String,dynamic>;

        await _fireAuth.verifyPhoneNumber(
        phoneNumber: '+63${userData['contact']}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _handlePhoneVerificationComplete(credential, userCredential.user!.uid);
        },
        verificationFailed: _handleVerificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          _handleCodeSent(verificationId, userCredential.user!.uid);
        },
        codeAutoRetrievalTimeout: _handleCodeAutoRetrievalTimeout,
      );
    } 

    
      // Then start phone verification
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _handlePhoneVerificationComplete(PhoneAuthCredential credential, String userId) async {
    try {
      await _fireAuth.currentUser?.updatePhoneNumber(credential);
     
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification Complete')),
        );
          Navigator.push(context, MaterialPageRoute(builder: (context)=> homePage(userid: userId)));

      }
    } catch (e) {
      _showErrorSnackBar('Error completing verification: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleVerificationFailed(FirebaseAuthException e) {
    setState(() {
      _isLoading = false;
    });
    _showErrorSnackBar('Verification failed: ${e.message}');
  }

  void _handleCodeSent(String verificationId, String userId) {
    setState(() {
      _verificationId = verificationId;
      _isLoading = false;
    });
    
    _showVerificationDialog(userId);
  }

  void _handleCodeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _verificationId = verificationId;
      _isLoading = false;
    });
  }

  
  void _showVerificationDialog(String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the verification code sent to your phone:'),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '000000',
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  _verifyCode(value, userId);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clean up if user cancels verification
              _fireAuth.currentUser?.delete();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCode(String code, String userId) async {
    if (_verificationId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await _handlePhoneVerificationComplete(credential, userId);
    } catch (e) {
      _showErrorSnackBar('Invalid verification code');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email not found':
        return 'email not found';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      default:
        return 'An error occurred during registration';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/img/bogsmila.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Your Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 30),
                  const Text("Login as:"),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedRole,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['tenant', 'Sub-account']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Email:"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Password:"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Forgot your password?'),
                      TextButton(
                        onPressed: () {
                          // Implement password reset functionality
                          if (_emailController.text.isNotEmpty) {
                            _fireAuth.sendPasswordResetEmail(
                              email: _emailController.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent'),
                              ),
                            );
                          } else {
                            _showErrorSnackBar('Please enter your email first');
                          }
                        },
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}