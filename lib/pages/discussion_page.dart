import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kifg/models/comment_model.dart';
import 'package:kifg/pages/comment_thread_page.dart';
import 'package:kifg/widgets/body_wrapper.dart';

class Thread {
  final CommentModel root;
  final List<CommentModel> replies;

  Thread(this.root, this.replies);
}

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  late Future<List<CommentModel>> _commentsFuture;
  final Set<String> expandedPanels = {};

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<CommentModel>> _fetchComments() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CommentModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diskussionen')),
      body: BodyWrapper(
        child: FutureBuilder<List<CommentModel>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data ?? [];

            final unresolved =
                comments
                    .where((c) => c.requiresTeacherResponse && !c.resolved)
                    .toList();

            // Threading logic
            final allIds = comments.map((c) => c.id).toSet();
            final childrenMap = <String, List<CommentModel>>{};
            for (final c in comments) {
              if (c.parentId.isNotEmpty) {
                childrenMap.putIfAbsent(c.parentId, () => []).add(c);
              }
            }

            final topLevel =
                comments
                    .where((c) => !allIds.contains(c.parentId))
                    .where((c) => !c.requiresTeacherResponse || c.resolved)
                    .toList();

            final threadsByCase = <String, Map<String, List<Thread>>>{};
            for (final c in topLevel) {
              final thread = Thread(c, childrenMap[c.id] ?? []);
              threadsByCase
                  .putIfAbsent(c.caseTitle, () => {})
                  .putIfAbsent(c.exampleTitle, () => [])
                  .add(thread);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unresolved.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '🔔 Kommentare, die eine Antwort erfordern',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...unresolved.map(_buildCommentTile),
                    const Divider(),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '💬 Alle Diskussionen',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...threadsByCase.entries.map((caseEntry) {
                    final caseTitle = caseEntry.key;
                    final exampleMap = caseEntry.value;

                    return ExpansionPanelList(
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          if (expandedPanels.contains(caseTitle)) {
                            expandedPanels.remove(caseTitle);
                          } else {
                            expandedPanels.add(caseTitle);
                          }
                        });
                      },
                      expandedHeaderPadding: EdgeInsets.zero,
                      animationDuration: const Duration(milliseconds: 300),
                      children: [
                        ExpansionPanel(
                          isExpanded: expandedPanels.contains(caseTitle),
                          headerBuilder:
                              (_, __) => ListTile(
                                title: Text(
                                  caseTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          body: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  exampleMap.entries.map((exampleEntry) {
                                    final exampleTitle = exampleEntry.key;
                                    final threads = exampleEntry.value;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        bottom: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exampleTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...threads.map(
                                            (t) => _buildShortenedCommentTile(
                                              t.root,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel c) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(c.text),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fall: ${c.caseTitle}'),
            Text('Beispiel: ${c.exampleTitle}'),
            Text('Von: ${c.userName} • ${c.timestamp.toLocal()}'),
            if (c.requiresTeacherResponse && !c.resolved)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Antwort erforderlich',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CommentThreadPage(comment: c)),
          );
        },
      ),
    );
  }

  Widget _buildShortenedCommentTile(CommentModel c) {
    final split = c.text.split('*Mein Kommentar:*');
    final shortText = split.length > 1 ? split[1].trim() : c.text;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(shortText),
        subtitle: Text('Von: ${c.userName} • ${c.timestamp.toLocal()}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CommentThreadPage(comment: c)),
          );
        },
      ),
    );
  }
}
