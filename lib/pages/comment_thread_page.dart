import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kifg/models/comment_model.dart';
import 'package:kifg/services/firestore_service.dart';

class CommentThreadPage extends StatefulWidget {
  final CommentModel comment;

  const CommentThreadPage({super.key, required this.comment});

  @override
  State<CommentThreadPage> createState() => _CommentThreadPageState();
}

class _CommentThreadPageState extends State<CommentThreadPage> {
  final TextEditingController replyController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  late Future<List<CommentModel>> _repliesFuture;

  @override
  void initState() {
    super.initState();
    _repliesFuture = _fetchReplies();
  }

  Future<List<CommentModel>> _fetchReplies() async {
    final snapshot =
        await _firestore
            .collection('comments')
            .where('parentId', isEqualTo: widget.comment.id)
            .orderBy('timestamp')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CommentModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> _submitReply() async {
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    final comment = CommentModel(
      id: '',
      parentId: widget.comment.id,
      caseTitle: widget.comment.caseTitle,
      exampleTitle: widget.comment.exampleTitle,
      answerId: null,
      text: text,
      userId: user!.uid,
      userName: user!.email ?? 'Unbekannt',
      timestamp: DateTime.now(),
      requiresTeacherResponse: false,
      resolved: false,
    );

    await FirestoreService().saveComment(comment);

    replyController.clear();
    setState(() {
      _repliesFuture = _fetchReplies();
    });
  }

  Future<void> _markAsResolved() async {
    await _firestore.collection('comments').doc(widget.comment.id).update({
      'resolved': true,
      'requiresTeacherResponse': false,
    });

    if (mounted) {
      setState(() {
        widget.comment.resolved = true;
      });

      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kommentar als gelöst markiert')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diskussion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCommentCard(widget.comment, isMain: true),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<CommentModel>>(
                future: _repliesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: SelectableText(
                        'Fehler beim Laden: ${snapshot.error}',
                      ),
                    );
                  }

                  final replies = snapshot.data ?? [];

                  if (replies.isEmpty) {
                    return const Center(
                      child: Text('Noch keine Antworten auf diesen Kommentar.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      return _buildCommentCard(replies[index]);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    decoration: const InputDecoration(
                      hintText: 'Antwort schreiben...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitReply,
                ),
              ],
            ),
            if (widget.comment.requiresTeacherResponse &&
                !widget.comment.resolved)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Als gelöst markieren'),
                  onPressed: _markAsResolved,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, {bool isMain = false}) {
    final isTeacher =
        comment.userName.contains('@') &&
        comment.userName.contains('.'); // Optional logic

    return Card(
      color:
          isMain
              ? Colors.amber.shade50
              : comment.userName.contains('teacher')
              ? Colors.blue.shade50
              : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMain)
              Text(
                'Fall: ${comment.caseTitle} • Beispiel: ${comment.exampleTitle}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Text(comment.text),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Von ${comment.userName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!isMain)
                  Text(
                    '${comment.timestamp.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
