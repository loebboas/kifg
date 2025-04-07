import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_short_model.dart';
import '../providers/data_provider.dart';

class SearchableArticleDropdown extends StatelessWidget {
  final void Function(ArticleShortModel) onSelected;

  const SearchableArticleDropdown({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final articles = context.watch<DataProvider>().articleShortList;

    return Autocomplete<ArticleShortModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return articles.where(
          (article) =>
              article.title.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) ||
              article.text.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
        );
      },
      displayStringForOption: (article) => article.title,
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Suche Artikel / Absatz / Ziffer',
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4.0,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final article = options.elementAt(index);
              return ListTile(
                title: Text(article.title),
                subtitle: Text(
                  article.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => onSelected(article),
              );
            },
          ),
        );
      },
    );
  }
}
