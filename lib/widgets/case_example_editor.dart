import 'package:flutter/material.dart';
import '../models/case_example_model.dart';
import '../services/firestore_service.dart';

class CaseExampleEditor extends StatefulWidget {
  final CaseExampleModel example;

  const CaseExampleEditor({super.key, required this.example});

  @override
  State<CaseExampleEditor> createState() => _CaseExampleEditorState();
}

class _CaseExampleEditorState extends State<CaseExampleEditor> {
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController answer;
  late TextEditingController expectations;

  bool saved = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.example.title);
    description = TextEditingController(text: widget.example.description);
    answer = TextEditingController(text: widget.example.answer ?? '');

    expectations = TextEditingController(
      text:
          widget.example.expectations ??
          'Eine kurze Antwort mit Begründung ist erforderlich.',
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Beispiel löschen'),
            content: const Text(
              'Möchtest du dieses Fallbeispiel wirklich löschen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Löschen'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirestoreService().deleteCaseExample(widget.example.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fallbeispiel gelöscht.')));
      }
      // Optional: remove this card from parent list?
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  Future<void> _save() async {
    final updated = CaseExampleModel(
      id: widget.example.id,
      parentId: widget.example.parentId,
      title: title.text,
      description: description.text,
      answer: answer.text.isNotEmpty ? answer.text : null,

      expectations: expectations.text.isNotEmpty ? expectations.text : null,
    );

    await FirestoreService().saveOrUpdateCaseExample(updated);
    setState(() {
      saved = true;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: _buildPreviewView(),
          secondChild: _buildEditView(),
        ),
      ),
    );
  }

  Widget _labeledText(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.text, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _labeledText('Beschreibung', description.text),
        _labeledText('Muster Antwort', answer.text),
        _labeledText('Erwartungen an die Antwort', expectations.text),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Bearbeiten'),
              onPressed: () => setState(() => isEditing = true),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Löschen', style: TextStyle(color: Colors.red)),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditView() {
    return Column(
      children: [
        TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Titel'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Beschreibung'),
          minLines: 2,
          maxLines: null,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: answer,
          decoration: const InputDecoration(labelText: 'Kurze Antwort'),
          minLines: 3,
          maxLines: null,
        ),
        const SizedBox(height: 10),

        const SizedBox(height: 10),
        TextField(
          controller: expectations,
          decoration: const InputDecoration(labelText: 'Lange Antwort'),
          minLines: 2,
          maxLines: null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _save, child: const Text('Speichern')),
          ],
        ),
      ],
    );
  }
}
