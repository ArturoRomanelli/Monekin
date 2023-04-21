import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/widgets/bottomSheetFooter.dart';
import 'package:finlytics/widgets/bottomSheetHeader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubcategorySelector extends StatefulWidget {
  const SubcategorySelector({super.key, required this.parentCategory});

  final Category parentCategory;

  @override
  State<SubcategorySelector> createState() => _SubcategorySelectorState();
}

class _SubcategorySelectorState extends State<SubcategorySelector> {
  late Category selectedCategory;

  List<Category>? childCategories;

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.parentCategory;

    context
        .read<CategoryService>()
        .getChildCategories(parentId: widget.parentCategory.id)
        .then((value) {
      setState(() {
        childCategories = value;
      });
    });
  }

  Widget subcategoryChip(Category category) {
    final isSelected = selectedCategory.id == category.id;

    final isSubcategorySelected = category.id != widget.parentCategory.id;

    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: ActionChip(
          avatar: isSubcategorySelected
              ? category.icon.display(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onBackground)
              : Icon(
                  Icons.hide_source,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onBackground,
                ),
          backgroundColor: isSelected
              ? Color(int.parse('0xff${widget.parentCategory.color}'))
              : null,
          onPressed: () {
            if (!isSelected) {
              setState(() {
                selectedCategory = category;
              });
            }
          },
          label: Text(
            isSubcategorySelected ? category.name : 'Sin categoría',
            style: isSelected ? const TextStyle(color: Colors.white) : null,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHeader(),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select a subcategory',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Builder(
                      builder: (_) {
                        if (childCategories == null) {
                          return const LinearProgressIndicator();
                        } else {
                          return Wrap(
                            children: [
                              subcategoryChip(widget.parentCategory),
                              ...List.generate(
                                  childCategories!.length,
                                  (index) =>
                                      subcategoryChip(childCategories![index]))
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              BottomSheetFooter(
                  submitText: 'Continue',
                  submitIcon: Icons.arrow_forward_ios,
                  onSaved: () {
                    Navigator.of(context).pop(selectedCategory);
                  })
            ]),
      ),
    );
  }
}
