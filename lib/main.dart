import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kifg/services/firestore_service.dart';
import 'firebase_options.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/user_provider.dart';
import 'providers/data_provider.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const MaterialApp(title: 'My App', home: AuthGate()),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final firebaseUser = snapshot.data!;

          // Step 1: Delay provider update until after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.setFirebaseUser(firebaseUser);
          });

          // Step 2: Load Firestore UserModel
          return FutureBuilder(
            future: FirestoreService().getUser(firebaseUser.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userModel = snapshot.data!;

              // Step 3: Delay setting userModel too
              WidgetsBinding.instance.addPostFrameCallback((_) {
                userProvider.setUserModel(userModel);
              });

              return const HomePage();
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
