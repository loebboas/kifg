import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kifg/pages/quizz_runner_page.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import '../models/case_model.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  Future<List<CaseModel>> _loadCases() async {
    final snapshot = await FirebaseFirestore.instance.collection('cases').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CaseModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz-Modus')),
      body: BodyWrapper(
        child: FutureBuilder<List<CaseModel>>(
          future: _loadCases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cases = snapshot.data ?? [];

            if (cases.isEmpty) {
              return const Center(child: Text('Keine Themen gefunden.'));
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Wähle ein Thema aus, um das Quiz zu starten.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  ...cases.map((c) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(c.topic),
                        subtitle: Text(c.question),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizRunnerPage(caseModel: c),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
