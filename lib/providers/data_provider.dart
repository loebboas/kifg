import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article_short_model.dart';

class DataProvider with ChangeNotifier {
  List<ArticleShortModel> _articleShortList = [];

  List<ArticleShortModel> get articleShortList => _articleShortList;

  Future<void> loadArticles() async {
    final jsonStr = await rootBundle.loadString('assets/stgb_parsed.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    _articleShortList =
        jsonList.map((e) => ArticleShortModel.fromJson(e)).toList();
    notifyListeners();
  }
}
