import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kifg/models/article_short_model.dart';
import 'package:kifg/models/case_example_model.dart';
import 'package:kifg/models/case_model.dart';
import 'package:kifg/providers/data_provider.dart';
import 'package:kifg/services/firestore_service.dart';
import 'package:kifg/widgets/article_selector.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import 'package:kifg/widgets/case_example_editor.dart';
import 'package:provider/provider.dart';

const geminiApiKey = 'your_api_key_here';

class CreateCasePage extends StatefulWidget {
  final CaseModel? existingCase;

  const CreateCasePage({super.key, this.existingCase});

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  final topicController = TextEditingController();
  final contextController = TextEditingController();
  final questionController = TextEditingController();
  final numberController = TextEditingController(text: '3');

  List<ArticleShortModel> selectedArticles = [];
  List<CaseExampleModel> generatedCases = [];
  String? caseId;
  bool isGenerating = false;
  bool caseSaved = false;

  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).loadArticles();

    if (widget.existingCase != null) {
      topicController.text = widget.existingCase!.topic;
      contextController.text = widget.existingCase!.context;
      questionController.text = widget.existingCase!.question;
      numberController.text = widget.existingCase!.numberOfExamples.toString();
      caseId = widget.existingCase!.id;
      caseSaved = true;

      FirestoreService().getCaseExamples(widget.existingCase!.id).then((
        savedExamples,
      ) {
        setState(() {
          generatedCases = savedExamples;
        });
      });
    }
  }

  Future<void> _saveCase() async {
    final topic = topicController.text.trim();
    final contextText = contextController.text.trim();
    final question = questionController.text.trim();
    final number = int.tryParse(numberController.text.trim()) ?? 1;

    if (topic.isEmpty || question.isEmpty || number < 1 || number > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle alle Felder korrekt aus.')),
      );
      return;
    }

    final model = CaseModel(
      id: caseId ?? '',
      topic: topic,
      context: contextText,
      question: question,
      numberOfExamples: number,
    );

    final newId = await FirestoreService().createOrUpdateCase(model);
    setState(() {
      caseId = newId;
      caseSaved = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fall gespeichert!')));
  }

  Future<void> _generateExamples() async {
    if (caseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte speichere zuerst den Fall.')),
      );
      return;
    }

    String existingExamplesString = "";

    if (generatedCases.isNotEmpty) {
      existingExamplesString +=
          "\nHier sind die bereits vorhandenen Beispiele:\n";
      for (final e in generatedCases) {
        existingExamplesString += '- ${e.title} (${e.answer})\n';
      }
      existingExamplesString +=
          "\nBitte generiere neue Beispiele, die sich von diesen unterscheiden.";
    }
    final articles = selectedArticles;
    final articleList = articles.map((a) => '- ${a.title}').join('\n');
    final prompt = '''
Du bist ein AI Fallbeispielsgenerator für das Schweizerische Recht.

Hier ist der Kontext: ${contextController.text.trim()}

$existingExamplesString

Hier ist die Frage, die Studierende beantworten müssen:
${questionController.text.trim()}

Hier sind die Artikel, die relevant sind:
$articleList

Generiere ${numberController.text.trim()} Fallbeispiele und gib sie in folgendem JSON-Format zurück:

[
  {
    "title": "Titel",
    "description": "Beschreibung des Falles",
    "answer": "Antwort mit Begründung",
    "expectations": "Kurz was von der Antwort der studierenden erwartet wird",
  }
]

''';

    try {
      setState(() => isGenerating = true);

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonStr = response.text?.trim();

      if (jsonStr == null) throw Exception('Keine Antwort vom Modell');

      final parsed = jsonDecode(jsonStr) as List;
      final service = FirestoreService();

      for (final e in parsed) {
        final m = Map<String, dynamic>.from(e);
        m['parentId'] = caseId!;
        final example = CaseExampleModel.fromJson(m);
        await service.saveOrUpdateCaseExample(example);
      }

      // Refresh list
      final refreshed = await service.getCaseExamples(caseId!);
      setState(() {
        generatedCases = refreshed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fälle automatisch gespeichert!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler bei der Generierung: $e')));
    } finally {
      setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingArticles =
        context.watch<DataProvider>().articleShortList.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Fallbeispiel erstellen')),
      body:
          loadingArticles
              ? const Center(child: CircularProgressIndicator())
              : BodyWrapper(
                child: Column(
                  children: [
                    TextField(
                      controller: topicController,
                      decoration: const InputDecoration(
                        labelText: 'Thema der Fallgruppe',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ArticleChipSelector(
                      initialSelection: selectedArticles,
                      onChanged:
                          (articles) =>
                              setState(() => selectedArticles = articles),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contextController,
                      decoration: const InputDecoration(
                        labelText: 'Kontext',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 5,
                      maxLines: null,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Frage für Studierende',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: null,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Anzahl Fälle (max 10)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveCase,
                            child: const Text('Fall speichern'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isGenerating ? null : _generateExamples,
                            child:
                                isGenerating
                                    ? const CircularProgressIndicator()
                                    : const Text('Fälle generieren'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (generatedCases.isNotEmpty)
                      ...generatedCases.map(
                        (e) => CaseExampleEditor(example: e),
                      ),
                  ],
                ),
              ),
    );
  }
}
