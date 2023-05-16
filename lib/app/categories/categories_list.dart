import 'package:finlytics/app/categories/category_form.dart';
import 'package:finlytics/app/categories/subcategory_selector.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:flutter/material.dart';

enum CategoriesListMode {
  page,
  modalSelectSubcategory,
  modalSelectCategory,
  modalSelectMultiCategory
}

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key, required this.mode});

  final CategoriesListMode mode;

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  Widget buildCategoryList(String type, List<Category> mainCategories) {
    if (type != 'E' && type != 'I') throw Exception('Incorrect category type');

    final categoriesToDisplay = (type == 'E'
            ? mainCategories.where((cat) => cat.type == 'E' || cat.type == 'B')
            : mainCategories.where((cat) => cat.type == 'I' || cat.type == 'B'))
        .toList();

    return ListView.builder(
        itemCount: categoriesToDisplay.length,
        itemBuilder: (context, index) {
          final category = categoriesToDisplay[index];

          return ListTile(
            title: Text(category.name),
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  category.icon.display(
                      size: 25,
                      color: Color(int.parse('0xff${category.color}')))
                ]),
            onTap: () async {
              if (widget.mode == CategoriesListMode.page) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryFormPage(
                              categoryUUID: category.id,
                            )));
              } else if (widget.mode ==
                  CategoriesListMode.modalSelectCategory) {
                category.type = type;

                Navigator.of(context).pop([category]);
              } else if (widget.mode ==
                  CategoriesListMode.modalSelectSubcategory) {
                final modalRes = await showModalBottomSheet<Category?>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SubcategorySelector(parentCategory: category);
                    });

                if (modalRes != null) {
                  if (modalRes.isChildCategory) {
                    modalRes.parentCategory!.type = type;
                  } else {
                    modalRes.type = type;
                  }

                  Navigator.of(context).pop([modalRes]);
                }
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          automaticallyImplyLeading: widget.mode == CategoriesListMode.page,
          leading: Navigator.canPop(context) &&
                  widget.mode != CategoriesListMode.page
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        persistentFooterButtons: widget.mode == CategoriesListMode.page
            ? [
                Container(
                  padding: const EdgeInsets.all(4),
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryFormPage()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir categoría'),
                  ),
                )
              ]
            : null,
        body: Column(
          children: [
            const TabBar(tabs: [
              Tab(text: 'Incomes'),
              Tab(text: 'Expenses'),
            ]),
            StreamBuilder(
                stream: CategoryService.instance.getMainCategories(),
                builder: (context, categories) {
                  if (!categories.hasData) {
                    return const LinearProgressIndicator();
                  } else {
                    return Expanded(
                      child: TabBarView(children: [
                        buildCategoryList('I', categories.data!),
                        buildCategoryList('E', categories.data!),
                      ]),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
