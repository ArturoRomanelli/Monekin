import 'package:finlytics/app/categories/category_form.dart';
import 'package:finlytics/app/categories/subcategory_selector.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

enum CategoriesListMode {
  page,
  modalSelectSubcategory,
  modalSelectCategory,
  modalSelectMultiCategory
}

Future<List<Category>?> showCategoryListModal(
    BuildContext context, CategoriesList page) {
  return showModalBottomSheet<List<Category>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.85,
          minChildSize: 0.85,
          initialChildSize: 0.85,
          builder: (context, scrollController) {
            return page;
          });
    },
  );
}

class CategoriesList extends StatefulWidget {
  const CategoriesList(
      {super.key, required this.mode, this.selectedCategories = const []});

  final CategoriesListMode mode;

  final List<Category> selectedCategories;

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  /// Only used when multi-selection
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();

    selectedCategories = [...widget.selectedCategories];
  }

  Widget buildCategoryList(CategoryType type, List<Category> mainCategories) {
    if (type != CategoryType.E && type != CategoryType.I) {
      throw Exception('Incorrect category type');
    }

    final categoriesToDisplay = (type.isExpense
            ? mainCategories.where((cat) => cat.type.isExpense)
            : mainCategories.where((cat) => cat.type.isIncome))
        .toList();

    return ListView.builder(
        itemCount: categoriesToDisplay.length,
        itemBuilder: (context, index) {
          final category = categoriesToDisplay[index];

          if (widget.mode != CategoriesListMode.modalSelectMultiCategory) {
            return ListTile(
              title: Text(category.name),
              leading: category.icon
                  .displayFilled(size: 25, color: ColorHex.get(category.color)),
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
                      showDragHandle: true,
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
          } else {
            return CheckboxListTile(
                title: Text(category.name),
                secondary: category.icon.displayFilled(
                    size: 25, color: ColorHex.get(category.color)),
                value:
                    selectedCategories.map((e) => e.id).contains(category.id),
                onChanged: (value) {
                  if (value == true) {
                    selectedCategories.add(category);
                  } else {
                    selectedCategories
                        .removeWhere((element) => element.id == category.id);
                  }

                  setState(() {});
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: StreamBuilder(
          stream: CategoryService.instance.getMainCategories(),
          builder: (context, categoriesSnapshot) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                bottom: TabBar(tabs: [
                  Tab(text: t.general.incomes),
                  Tab(text: t.general.expenses),
                ]),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.general.categories),
                    if (categoriesSnapshot.hasData &&
                        widget.mode ==
                            CategoriesListMode.modalSelectMultiCategory)
                      Builder(builder: (context) {
                        if (categoriesSnapshot.data!.length ==
                            selectedCategories.length) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                selectedCategories = [];
                              });
                            },
                            icon: const Icon(Icons.deselect),
                            tooltip: t.general.deselect_all,
                          );
                        }

                        return IconButton(
                          onPressed: () {
                            setState(() {
                              selectedCategories = categoriesSnapshot.data!;
                            });
                          },
                          icon: const Icon(Icons.select_all),
                          tooltip: t.general.select_all,
                        );
                      })
                  ],
                ),
                automaticallyImplyLeading:
                    widget.mode == CategoriesListMode.page,
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
                      PersistentFooterButton(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoryFormPage()));
                          },
                          icon: const Icon(Icons.add),
                          label: Text(t.categories.create),
                        ),
                      )
                    ]
                  : null,
              body: Column(
                children: [
                  Builder(builder: (context) {
                    if (!categoriesSnapshot.hasData) {
                      return const LinearProgressIndicator();
                    } else {
                      return Expanded(
                        child: TabBarView(children: [
                          buildCategoryList(
                              CategoryType.I, categoriesSnapshot.data!),
                          buildCategoryList(
                              CategoryType.E, categoriesSnapshot.data!),
                        ]),
                      );
                    }
                  }),
                  if (widget.mode ==
                      CategoriesListMode.modalSelectMultiCategory)
                    ListView(shrinkWrap: true, children: [
                      const SizedBox(height: 14),
                      BottomSheetFooter(
                          onSaved: selectedCategories.isNotEmpty
                              ? () =>
                                  Navigator.of(context).pop(selectedCategories)
                              : null)
                    ])
                ],
              ),
            );
          }),
    );
  }
}
