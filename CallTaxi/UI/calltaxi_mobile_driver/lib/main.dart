import 'dart:io';

import 'package:calltaxi_mobile_driver/layouts/master_screen.dart';
import 'package:calltaxi_mobile_driver/providers/auth_provider.dart';
import 'package:calltaxi_mobile_driver/providers/city_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:calltaxi_mobile_driver/screens/profile_screen.dart';
import 'package:calltaxi_mobile_driver/utils/text_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  // Stripe.publishableKey=dotenv.env["STRIPE__PUBKEY"]!;
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // Stripe.urlScheme = 'flutterstripe';
  // await Stripe.instance.applySettings();

  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(create: (_) => CityProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Taxi Driver',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFF9800), // Vibrant orange
          primary: Color(0xFFFF6F00), // Deep ora
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            // Header image at the top
            Container(
              height: 380,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/login_header.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Login card and content below the image
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6F00),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _usernameController,
                              decoration: customTextFieldDecoration(
                                "Username",
                                prefixIcon: Icons.account_circle_sharp,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: customTextFieldDecoration(
                                "Password",
                                prefixIcon: Icons.password,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  print("Login button pressed");
                                  UserProvider userProvider = UserProvider();
                                  final username = _usernameController.text;
                                  final password = _passwordController.text;
                                  print("credentials: $username : $password");
                                  AuthProvider.username = username;
                                  AuthProvider.password = password;
                                  try {
                                    print("Calling authenticate...");
                                    final user = await userProvider
                                        .authenticate(username, password);
                                    print("Authenticate returned: $user");
                                    if (user != null) {
                                      print(
                                        "User is not null, checking roles...",
                                      );
                                      final hasDriverRole = user.roles.any((
                                        role,
                                      ) {
                                        print(
                                          "Role: \\${role.id} - \\${role.name}",
                                        );
                                        return role.id == 2;
                                      });
                                      print("Has driver role: $hasDriverRole");
                                      if (!hasDriverRole) {
                                        print("Access denied dialog");
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Access Denied"),
                                            content: Text(
                                              "You do not have permission to access this app.",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      print("Navigating to MasterScreen");
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => MasterScreen(
                                            title: "Call Taxi Driver",
                                            child: ProfileScreen(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      print("Login failed dialog");
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Login Failed"),
                                          content: Text(
                                            "Invalid username or password.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print("Exception: $e");
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Error"),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  backgroundColor: Color(0xFFFF6F00),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
