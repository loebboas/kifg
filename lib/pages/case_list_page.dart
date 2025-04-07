import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kifg/models/case_model.dart';
import 'package:kifg/pages/create_case_page.dart';
import 'package:kifg/services/firestore_service.dart';
import 'package:kifg/widgets/body_wrapper.dart';

class CaseListPage extends StatefulWidget {
  const CaseListPage({super.key});

  @override
  State<CaseListPage> createState() => _CaseListPageState();
}

class _CaseListPageState extends State<CaseListPage> {
  Future<List<CaseModel>> _fetchCases() async {
    final snapshot = await FirebaseFirestore.instance.collection('cases').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CaseModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> _confirmAndDelete(BuildContext context, CaseModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Fall löschen?'),
            content: Text('Möchtest du "${model.topic}" wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Löschen'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirestoreService().deleteCase(model.id);
      setState(() {}); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fallbeispiele verwalten')),
      body: BodyWrapper(
        child: FutureBuilder<List<CaseModel>>(
          future: _fetchCases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cases = snapshot.data ?? [];

            if (cases.isEmpty) {
              return const Center(child: Text('Keine Themen gefunden.'));
            }

            return Column(
              children:
                  cases.map((c) {
                    return ListTile(
                      title: Text(c.topic),
                      subtitle: Text(c.question),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CreateCasePage(existingCase: c),
                                ),
                              );
                            },
                          ),
                          IconTheme(
                            data: const IconThemeData(color: Colors.red),
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmAndDelete(context, c),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}
