import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kifg/models/answer_feedback_model.dart';
import 'package:kifg/models/answer_model.dart';
import 'package:kifg/models/case_example_model.dart';
import 'package:kifg/models/case_model.dart';
import 'package:kifg/models/user_model.dart';
import 'package:kifg/models/comment_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────

  Future<void> createUser(String uid, UserModel user) async {
    await _db.collection('users').doc(uid).set(user.toJson());
  }

  Future<void> updateUserPoints(String uid, int points) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'points': points,
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─────────────────────────────────────────────
  // CASES
  // ─────────────────────────────────────────────

  Future<String> createOrUpdateCase(CaseModel caseData) async {
    if (caseData.id.isEmpty) {
      final newDoc = _db.collection('cases').doc();
      caseData.id = newDoc.id;
      await newDoc.set(caseData.toJson());
      return newDoc.id;
    } else {
      final ref = _db.collection('cases').doc(caseData.id);
      await ref.set(caseData.toJson(), SetOptions(merge: true));
      return ref.id;
    }
  }

  Future<void> deleteCase(String caseId) async {
    // Delete examples
    final exampleSnap =
        await _db
            .collection('examples')
            .where('parentId', isEqualTo: caseId)
            .get();
    for (final doc in exampleSnap.docs) {
      await doc.reference.delete();
    }

    // Delete the case
    await _db.collection('cases').doc(caseId).delete();
  }

  Future<List<CaseModel>> getAllCases() async {
    final snapshot = await _db.collection('cases').get();
    return snapshot.docs
        .map((doc) => CaseModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> deleteCaseExample(String exampleId) async {
    await _db.collection('examples').doc(exampleId).delete();
  }

  Future<CaseExampleModel?> getCaseExampleByAnswerId(String answerId) async {
    final snapshot = await _db.collection('answers').doc(answerId).get();

    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null || !data.containsKey('parentId')) return null;

    final parentId = data['parentId'] as String;
    final exampleId = data['exampleId'] as String;

    final exampleDoc =
        await _db.collection('caseExamples').doc(exampleId).get();

    if (!exampleDoc.exists) return null;
    return CaseExampleModel.fromFirestore(exampleDoc);
  }

  /// Get [AnswerModel] by ID
  Future<AnswerModel?> getAnswerById(String answerId) async {
    final snapshot = await _db.collection('answers').doc(answerId).get();
    if (!snapshot.exists) return null;

    return AnswerModel.fromFirestore(snapshot);
  }

  // ─────────────────────────────────────────────
  // CASE EXAMPLES (Flat)
  // ─────────────────────────────────────────────

  Future<void> saveOrUpdateCaseExample(CaseExampleModel example) async {
    final ref = _db.collection('examples').doc(example.id);
    if (example.id == null || example.id!.isEmpty) {
      await ref.set(example.toJson());
    } else {
      await ref.set(example.toJson(), SetOptions(merge: true));
    }
  }

  Future<List<CaseExampleModel>> getCaseExamples(String caseId) async {
    final snapshot =
        await _db
            .collection('examples')
            .where('parentId', isEqualTo: caseId)
            .get();

    return snapshot.docs
        .map((doc) => CaseExampleModel.fromFirestore(doc))
        .toList();
  }

  Future<CaseExampleModel> toggleVote(
    CaseExampleModel example,
    String uid,
    bool isUpvote,
  ) async {
    final docRef = _db.collection('examples').doc(example.id);
    final updated = Map<String, dynamic>.from(example.toJson());

    final upvotes = List<String>.from(example.upvotes);
    final downvotes = List<String>.from(example.downvotes);

    if (isUpvote) {
      if (upvotes.contains(uid)) {
        upvotes.remove(uid); // remove vote
      } else {
        upvotes.add(uid);
        downvotes.remove(uid); // prevent both
      }
    } else {
      if (downvotes.contains(uid)) {
        downvotes.remove(uid);
      } else {
        downvotes.add(uid);
        upvotes.remove(uid);
      }
    }

    updated['upvotes'] = upvotes;
    updated['downvotes'] = downvotes;

    await docRef.set(updated, SetOptions(merge: true));

    return CaseExampleModel.fromJson({...updated, 'id': example.id});
  }

  Future<void> deleteExample(String exampleId) async {
    await _db.collection('examples').doc(exampleId).delete();
  }

  // ─────────────────────────────────────────────
  // ANSWERS (Flat)
  // ─────────────────────────────────────────────

  Future<void> saveAnswer(CaseExampleModel example, AnswerModel answer) async {
    final ref = _db.collection('answers').doc(); // auto ID

    await ref.set({...answer.toJson(), 'exampleId': example.id});
  }

  Future<List<AnswerModel>> getAnswersForExample(String exampleId) async {
    final snapshot =
        await _db
            .collection('answers')
            .where('exampleId', isEqualTo: exampleId)
            .orderBy('timestamp')
            .get();

    return snapshot.docs
        .map((doc) => AnswerModel.fromJson(doc.data()))
        .toList();
  }

  // ─────────────────────────────────────────────
  // COMMENTS (Flat, Threaded)
  // ─────────────────────────────────────────────

  Future<void> saveComment(CommentModel comment) async {
    final ref = _db.collection('comments').doc(); // flat collection
    await ref.set({...comment.toJson(), 'id': ref.id});
  }

  Future<List<CommentModel>> getCommentsForExample(String exampleId) async {
    final snapshot =
        await _db
            .collection('comments')
            .where('exampleId', isEqualTo: exampleId)
            .orderBy('timestamp')
            .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<DocumentReference> saveAnswerAndReturnRef(
    CaseExampleModel example,
    AnswerModel answer,
  ) async {
    final ref = _db.collection('answers').doc();
    await ref.set({...answer.toJson(), 'exampleId': example.id});
    return ref;
  }

  Future<void> saveAnswerFeedback(
    String answerId,
    AnswerFeedbackModel feedback,
  ) async {
    final ref = _db.collection('answerFeedback').doc(); // Or use answerId
    await ref.set({...feedback.toJson(), 'answerId': answerId});
  }

  Future<List<CommentModel>> getRepliesForComment(String parentId) async {
    final snapshot =
        await _db
            .collection('comments')
            .where('parentId', isEqualTo: parentId)
            .orderBy('timestamp')
            .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }
}
