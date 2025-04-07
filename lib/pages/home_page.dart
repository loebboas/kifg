import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kifg/pages/case_list_page.dart';
import 'package:kifg/pages/create_case_page.dart';
import 'package:kifg/pages/discussion_page.dart';
import 'package:kifg/pages/quizz_page.dart';
import 'package:kifg/providers/user_provider.dart';
import 'package:kifg/widgets/body_logo.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import 'package:kifg/widgets/menu_button.dart';
import 'package:kifg/widgets/user_progress.dart';
import 'package:provider/provider.dart';
import '../pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final email = userProvider.userModel?.email ?? 'User';
    final isTeacher = userProvider.userModel?.isTeacher ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          UserLevelProgressBar(points: userProvider.userModel?.points ?? 0),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              userProvider.clear();
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: BodyWrapper(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BodyLogoWidget(),
                  Text('Willkommen $email!'),
                  const SizedBox(height: 24),
                  if (isTeacher) ...[
                    MenuButton(
                      title: 'Neues Thema Erstellen',
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateCasePage(),
                            ),
                          ),
                    ),
                    MenuButton(
                      title: 'Themen verwalten',
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CaseListPage(),
                            ),
                          ),
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 32,
                    ),
                  ],
                  MenuButton(
                    title: 'Quizz Modus',
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizPage()),
                        ),
                  ),
                  MenuButton(
                    title: 'Diskussion',
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiscussionPage(),
                          ),
                        ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Open Legal Lab 2025 - Prototyp',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SelectableText(
                          'Fragen? Feedback? loebboas@gmail.com',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
