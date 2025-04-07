import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kifg/models/answer_feedback_model.dart';
import 'package:kifg/models/comment_model.dart';
import 'package:kifg/providers/user_provider.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import 'package:kifg/widgets/user_progress.dart';
import 'package:provider/provider.dart';
import '../models/case_model.dart';
import '../models/case_example_model.dart';
import '../models/answer_model.dart';
import '../services/firestore_service.dart';

const geminiApiKey = 'your_api_key_here';

class QuizRunnerPage extends StatefulWidget {
  final CaseModel caseModel;

  const QuizRunnerPage({super.key, required this.caseModel});

  @override
  State<QuizRunnerPage> createState() => _QuizRunnerPageState();
}

class _QuizRunnerPageState extends State<QuizRunnerPage> {
  final TextEditingController answerController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  List<CaseExampleModel> examples = [];
  int currentIndex = 0;
  String? feedback;
  bool startedDiscussion = false;
  bool loading = true;
  bool submitting = false;
  User? user;
  AnswerFeedbackModel? currentFeedback;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadExamples();
  }

  Future<void> _loadExamples() async {
    final raw = await firestoreService.getCaseExamples(widget.caseModel.id);
    raw.shuffle(Random());
    setState(() {
      examples = raw;
      loading = false;
    });
  }

  Future<void> _submitAnswer() async {
    final example = examples[currentIndex];
    final userAnswer = answerController.text.trim();

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib eine Antwort ein.')),
      );
      return;
    }

    setState(() => submitting = true);

    final prompt = '''
Du bist ein KI-Coach. Analysiere die folgende Antwort eines Nutzers und gib ein strukturiertes Feedback im JSON-Format.

Hier ist die korrekte Antwort:
 ${example.answer ?? 'Keine Antwort gegeben'}

 Hier sind die Kriterien für das Feedback:
${example.expectations ?? 'Keine spezifischen Kriterien gegeben'}

Hier ist die Antwort des Nutzers:
"$userAnswer"

Gib dein Feedback im folgenden JSON-Format zurück:

{
  "score": 0.0 bis 1.0,
  "positives": ["..."],
  "negatives": ["..."],
  "feedback": "Zusammenfassender Satz oder Absatz"
}
''';

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    try {
      final result = await model.generateContent([Content.text(prompt)]);
      final jsonStr = result.text?.trim();
      if (jsonStr == null) throw Exception('Kein Feedback vom Modell.');

      final parsed = jsonDecode(jsonStr);
      final feedbackText = parsed['feedback'] ?? 'Kein Text erhalten.';

      final answer = AnswerModel(
        userId: user!.uid,
        userName: user!.email ?? 'Unbekannt',
        text: userAnswer,
        timestamp: DateTime.now(),
        feedback: feedbackText,
      );

      final answerRef = await firestoreService.saveAnswerAndReturnRef(
        example,
        answer,
      );

      final feedbackModel = AnswerFeedbackModel(
        answerId: answerRef.id,
        score: (parsed['score'] as num).toDouble(),
        positives: List<String>.from(parsed['positives'] ?? []),
        negatives: List<String>.from(parsed['negatives'] ?? []),
        timestamp: DateTime.now(),
        feedback: feedbackText,
      );

      await firestoreService.saveAnswerFeedback(answerRef.id, feedbackModel);

      final addedPoints = (feedbackModel.score * 100).round();
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final current = userProvider.userModel;
        if (current != null) {
          int newPoints = (current.points ?? 0) + addedPoints;
          current.points = newPoints;
          print("User points updated: ${current.points}");
          await firestoreService.updateUserPoints(
            userProvider.firebaseUser!.uid,
            newPoints,
          );
          userProvider.setUserModel(current);
        }
      }

      setState(() {
        feedback = feedbackText;
        submitting = false;
        currentFeedback = feedbackModel;
      });
    } catch (e) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Feedback: $e')));
    }
  }

  Future<void> _startDiscussion() async {
    final example = examples[currentIndex];
    final answerText = answerController.text.trim();

    final textController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Diskussion starten'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Was stimmt deiner Meinung nach nicht oder was möchtest du diskutieren?',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Dein Kommentar',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Absenden'),
              ),
            ],
          ),
    );

    if (confirmed == true && textController.text.trim().isNotEmpty) {
      final fullComment = '''
📘 *Fallbeispiel:*
${example.description}

🧑 *Meine Antwort:*
$answerText

🤖 *Feedback der KI:*
${currentFeedback?.feedback ?? "Noch kein KI-Feedback erhalten."}

🗣️ *Mein Kommentar:*
${textController.text.trim()}
''';

      final comment = CommentModel(
        id: '',
        parentId:
            example.id!, // this still links to the example, not another comment
        caseTitle: widget.caseModel.topic,
        exampleTitle: example.title,
        answerId: '', // optional
        text: fullComment,
        userId: user!.uid,
        userName: user!.email ?? 'Unbekannt',
        timestamp: DateTime.now(),
        requiresTeacherResponse: true,
        resolved: false,
      );

      await firestoreService.saveComment(comment);

      if (mounted) {
        setState(() {
          startedDiscussion = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diskussion wurde gestartet.')),
        );
      }
    }
  }

  Future<void> _vote(bool isUpvote) async {
    final example = examples[currentIndex];
    final updated = await firestoreService.toggleVote(
      example,
      user!.uid,
      isUpvote,
    );
    setState(() => examples[currentIndex] = updated);
  }

  void _next() {
    if (currentIndex == examples.length - 1) {
      Navigator.pop(context, true);
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      answerController.clear();
      feedback = null;
      startedDiscussion = false;
      currentFeedback = null;
      currentIndex = min(currentIndex + 1, examples.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final example = examples[currentIndex];
    final hasUpvoted = example.upvotes.contains(user!.uid);
    final hasDownvoted = example.downvotes.contains(user!.uid);

    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.caseModel.topic}'),
        actions: [
          UserLevelProgressBar(points: userProvider.userModel?.points ?? 0),
        ],
      ),
      body: BodyWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.caseModel.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              LinearProgressIndicator(
                value: (currentIndex + 1) / examples.length,
                backgroundColor: Colors.grey.shade300,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Frage ${currentIndex + 1} von ${examples.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Text(
                example.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(example.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      color: hasUpvoted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _vote(true),
                  ),
                  Text('${example.upvotes.length}'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down,
                      color: hasDownvoted ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _vote(false),
                  ),
                  Text('${example.downvotes.length}'),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Deine Antwort',
                  border: OutlineInputBorder(),
                ),
                minLines: 5,
                maxLines: null,
              ),
              const SizedBox(height: 12),
              if (currentFeedback != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(currentFeedback!.feedback),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: currentFeedback!.score,
                      minHeight: 6,
                      color: Colors.green,
                      backgroundColor: Colors.green.shade100,
                    ),
                    const SizedBox(height: 16),
                    if (currentFeedback!.positives.isNotEmpty) ...[
                      const Text('✅ Positives:'),
                      ...currentFeedback!.positives
                          .map((p) => Text('• $p'))
                          .toList(),
                      const SizedBox(height: 8),
                    ],
                    if (currentFeedback!.negatives.isNotEmpty) ...[
                      const Text('⚠️ Verbesserungspotenzial:'),
                      ...currentFeedback!.negatives
                          .map((n) => Text('• $n'))
                          .toList(),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      const Text(
                        '🧠 Musterlösung:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(height: 4),
                            if (example.answer != null &&
                                example.answer!.isNotEmpty)
                              Text(
                                example.answer ??
                                    "Keine Musterantwort vorhanden",
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              Row(
                children: [
                  if (feedback == null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitting ? null : _submitAnswer,
                        child:
                            submitting
                                ? const CircularProgressIndicator()
                                : const Text('Antwort absenden'),
                      ),
                    ),

                  if (feedback != null)
                    Expanded(
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: _next,
                            child: Text(
                              currentIndex == examples.length - 1
                                  ? 'Fertig'
                                  : 'Nächste Frage',
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.forum_outlined),
                            label: const Text("Diskussion starten"),
                            onPressed:
                                startedDiscussion ? null : _startDiscussion,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
