import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'MyHomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // Added variable for password visibility

  Future<void> _login() async {
    final url = Uri.parse('http://15.207.142.254:8000/auth/login/');
    final body = {
      'username': _usernameController.text,
      'password': _passwordController.text
    };
    final headers = {'Content-Type': 'application/json'};

    final response =
    await http.post(url, headers: headers, body: json.encode(body));
    if (response.statusCode == 200) {
      // Login successful, extract access token from response
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['token']['access'].toString();
      // print(accessToken);

      // Login successful, navigate to home page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: 'Fish Data Collection',
            accessToken: accessToken,
          ),
        ),
      );
    } else {
      // Login failed, show error message
      final message = json.decode(response.body)['message'];
      final errorMessage = message ?? 'Please check your credentials';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: Center(
            child: Image.asset(
              'assets/logo.jpg',
              width: 150.0,
              height: 80.0,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background image
            Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Let\'s get started',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Enter your login credentials below',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          const Divider(height: 1, color: Colors.grey),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible, // Update obscureText property based on visibility
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                child: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    MaterialButton(
                      color: const Color(0xFF27485D),
                      minWidth: double.infinity,
                      height: 50,
                      textColor: Colors.white,
                      onPressed: _login, // Call the _login function when the button is pressed
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
