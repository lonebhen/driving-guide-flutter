import 'package:driving_guide/providers/otp_provider.dart';
import 'package:driving_guide/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../../providers/user_profile.dart';
import 'numeric_pad.dart'; // Update with your correct import

class VerifyPhone extends StatefulWidget {
  final String phoneNumber;

  VerifyPhone({super.key, required this.phoneNumber});

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  String code = "";
  final OtpProvider _apiService = OtpProvider();
  final UserProfile _userProfile = UserProfile(); // Create an instance of UserProfile
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    if (code.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.validateOtp(code, widget.phoneNumber);
    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      await _userProfile.setUserId(widget.phoneNumber); // Save the user ID
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to home page
      );
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Verify phone",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "Code is sent to ${widget.phoneNumber}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF818181),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildCodeNumberBox(code.length > 0 ? code.substring(0, 1) : ""),
                          buildCodeNumberBox(code.length > 1 ? code.substring(1, 2) : ""),
                          buildCodeNumberBox(code.length > 2 ? code.substring(2, 3) : ""),
                          buildCodeNumberBox(code.length > 3 ? code.substring(3, 4) : ""),
                          buildCodeNumberBox(code.length > 4 ? code.substring(4, 5) : ""),
                          buildCodeNumberBox(code.length > 5 ? code.substring(5, 6) : ""),
                        ],
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Didn't receive code? ",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF818181),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Implement resend code functionality
                              print("Resend the code to the user");
                            },
                            child: const Text(
                              "Request again",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.13,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _verifyOtp,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFDC3D),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Verify and Create Account",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NumericPad(
              onNumberSelected: (value) {
                setState(() {
                  if (value != -1) {
                    if (code.length < 6) {
                      code = code + value.toString();
                    }
                  } else {
                    code = code.substring(0, code.length - 1);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCodeNumberBox(String codeNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F5FA),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black26,
                blurRadius: 25.0,
                spreadRadius: 1,
                offset: Offset(0.0, 0.75),
              )
            ],
          ),
          child: Center(
            child: Text(
              codeNumber,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
