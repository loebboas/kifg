import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_short_model.dart';
import '../providers/data_provider.dart';

class ArticleChipSelector extends StatefulWidget {
  final List<ArticleShortModel> initialSelection;
  final void Function(List<ArticleShortModel>) onChanged;

  const ArticleChipSelector({
    super.key,
    required this.initialSelection,
    required this.onChanged,
  });

  @override
  State<ArticleChipSelector> createState() => _ArticleChipSelectorState();
}

class _ArticleChipSelectorState extends State<ArticleChipSelector> {
  late List<ArticleShortModel> selected;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    selected = List.of(widget.initialSelection);
    controller = TextEditingController();
  }

  void _addArticle(ArticleShortModel article) {
    if (!selected.any((a) => a.id == article.id)) {
      setState(() {
        selected.add(article);
        widget.onChanged(selected);
      });
    }
    controller.clear();
  }

  void _removeArticle(ArticleShortModel article) {
    setState(() {
      selected.removeWhere((a) => a.id == article.id);
      widget.onChanged(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final articles = context.watch<DataProvider>().articleShortList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<ArticleShortModel>(
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) return const Iterable.empty();
            return articles.where(
              (a) =>
                  a.title.toLowerCase().contains(value.text.toLowerCase()) ||
                  a.text.toLowerCase().contains(value.text.toLowerCase()),
            );
          },
          displayStringForOption: (a) => a.title,
          onSelected: _addArticle,
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            controller = textEditingController;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Artikel suchen und hinzufügen',
                border: OutlineInputBorder(),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Material(
              elevation: 4,
              child: ListView.builder(
                shrinkWrap: true,
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
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              selected.map((article) {
                return InputChip(
                  label: Text(article.title),
                  onDeleted: () => _removeArticle(article),
                );
              }).toList(),
        ),
      ],
    );
  }
}
