import 'package:finlytics/pages/categories/subcategory_form.dart';
import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/supported_icon/supported_icon.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/services/utils/colorFromHex.dart';
import 'package:finlytics/widgets/icon_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key, this.categoryUUID});

  /// Account UUID to edit (if any)
  final String? categoryUUID;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  Category? categoryToEdit;

  final TextEditingController _nameController = TextEditingController();

  SupportedIcon _icon =
      SupportedIconService.instance.getIconByID('question_mark');

  String _color = '000000';
  String _type = 'E';

  final colorOptions = [
    'B71C1C',
    'D50000',
    'E53935',
    'EF5350',
    '880E4F',
    'C51162',
    'D81B60',
    'EC407A',
    '4A148C',
    'AA00FF',
    '8E24AA',
    'AB47BC',
    '1A237E',
    '2962FF',
    '2979FF',
    '42A5F5',
    '006064',
    '00897B',
    '00BFA5',
    '4DB6AC',
    '1B5E20',
    '388E3C',
    '8BC34A',
    'D4E157',
    'BF360C',
    'F4511E',
    'FB8C00',
    'FFA726',
    'E65100',
    'FFA000',
    'FFAB00',
    'FFCA28',
    '546E7A',
    '90A4AE',
    '795548',
    '757575',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.categoryUUID != null) {
      _fillForm();
    }
  }

  void _fillForm() {
    context
        .read<CategoryService>()
        .getMainCategories()
        .then((categories) async {
      categoryToEdit =
          categories.firstWhere((cat) => cat.id == widget.categoryUUID);

      setState(() {
        _icon = categoryToEdit!.icon;
        _color = categoryToEdit!.color;
        _type = categoryToEdit!.type;
      });

      _nameController.value = TextEditingValue(text: categoryToEdit!.name);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  deleteCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove category'),
          content: const SingleChildScrollView(
              child: Text(
                  'This action will irreversibly delete all transactions <b>({{x}})</b> related to this category.')),
          actions: [
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                context
                    .read<CategoryService>()
                    .deleteCategory(categoryId)
                    .then((value) async {
                  if (categoryId == widget.categoryUUID) {
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Subcategoría borrada con exito')));
                  }
                }).catchError((error) {});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  makeMainCategory(Category category) {
    if (category.isMainCategory) return;

    context.read<CategoryService>().updateCategory(Category.mainCategory(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: categoryToEdit!.color,
        type: categoryToEdit!.type));

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría creada con exito')));
  }

  openSubcategoryForm(void Function(String, SupportedIcon) onSubmit) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SubcategoryFormDialog(
            color: Color(int.parse('0xff$_color')),
            icon: SupportedIconService.instance.defaultSupportedIcon,
            onSubmit: onSubmit,
          );
        });
  }

  submitForm() {
    if (categoryToEdit != null) {
      categoryToEdit!.color = _color;
      categoryToEdit!.icon = _icon;
      categoryToEdit!.name = _nameController.text;

      context
          .read<CategoryService>()
          .updateCategory(categoryToEdit!)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría editada con exito')));
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else {
      context
          .read<CategoryService>()
          .insertCategory(Category.mainCategory(
              id: const Uuid().v4(),
              name: _nameController.text,
              icon: _icon,
              type: _type,
              color: _color))
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría creada con exito')));
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        persistentFooterButtons: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  submitForm();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Guardar cambios'),
            ),
          )
        ],
        appBar: AppBar(
            title: Text(widget.categoryUUID != null
                ? 'Edit category'
                : 'Create category'),
            actions: [
              if (widget.categoryUUID != null)
                PopupMenuButton(
                  itemBuilder: (context) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem(
                          value: 'to_subcategory',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.login),
                            minLeadingWidth: 26,
                            title: Text('Make a subcategory'),
                          )),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'merge',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.merge_type),
                            minLeadingWidth: 26,
                            title: Text('Merge with another category'),
                          )),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.delete),
                            minLeadingWidth: 26,
                            title: Text('Delete'),
                          ))
                    ];
                  },
                  onSelected: (String value) {
                    if (value == 'delete') deleteCategory(widget.categoryUUID!);
                  },
                ),
            ]),
        body: widget.categoryUUID != null && categoryToEdit == null
            ? const LinearProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return IconSelectorModal(
                                                preselectedIconID: _icon.id,
                                                onIconSelected: (selectedIcon) {
                                                  setState(() {
                                                    _icon = selectedIcon;
                                                  });
                                                },
                                              );
                                            });
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                              color: Color(
                                                      int.parse('0xff$_color'))
                                                  .withOpacity(0.05),
                                              border: Border.all(
                                                  width: 1.625,
                                                  color: Color(int.parse(
                                                      '0xff$_color'))),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(6))),
                                          child: _icon.display(
                                              size: 48,
                                              color: Color(
                                                  int.parse('0xff$_color')))),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameController,
                                        maxLength: 20,
                                        decoration: const InputDecoration(
                                          labelText: 'Category name *',
                                          hintText: 'Ex.: Food',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a name';
                                          }
                                          return null;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de categoría *',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'I', child: Text('Income')),
                                    DropdownMenuItem(
                                        value: 'E', child: Text('Expense')),
                                    DropdownMenuItem(
                                        value: 'B', child: Text('Both'))
                                  ],
                                  value: _type,
                                  onChanged: widget.categoryUUID != null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            if (value != null) {
                                              _type = value;
                                            }
                                          });
                                        },
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                const Text('Color')
                              ],
                            ))),

                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: colorOptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final colorItem = colorOptions[index];

                          return Container(
                            clipBehavior: Clip.hardEdge,
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            margin: EdgeInsets.only(
                                left: index == 0 ? 16 : 4,
                                right:
                                    index == colorOptions.length - 1 ? 16 : 4),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(int.parse('0xff$colorItem')),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(onTap: () {
                                      setState(() {
                                        _color = colorItem;
                                      });
                                    }),
                                  ),
                                ),
                                if (colorItem == _color)
                                  Container(
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(47, 255, 255, 255),
                                      ),
                                      child: const Center(
                                          child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )))
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 16, vertical: 8),
                    //   child: const Text("Tipo de categoría"),
                    // ),
                    // CheckboxListTile(
                    //   title: const Text('Ingreso'),
                    //   value: true,
                    //   onChanged: (value) {},
                    //   controlAffinity: ListTileControlAffinity.leading,
                    // ),
                    // CheckboxListTile(
                    //   title: const Text('Gasto'),
                    //   value: true,
                    //   onChanged: (value) {},
                    //   controlAffinity: ListTileControlAffinity.leading,
                    // ),

                    if (widget.categoryUUID != null)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Subcategories'),
                      ),
                    if (widget.categoryUUID != null)
                      FutureBuilder(
                        initialData: const <Category>[],
                        future: context
                            .watch<CategoryService>()
                            .getChildCategories(parentId: widget.categoryUUID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final List<Category> childCategories =
                                snapshot.data!;

                            return Column(
                                children: List.generate(childCategories.length,
                                    (index) {
                              final subcategory = childCategories[index];

                              return ListTile(
                                  leading: subcategory.icon
                                      .display(color: ColorHex.get(_color)),
                                  trailing: PopupMenuButton(
                                    offset: const Offset(0, 48),
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry<String>>[
                                        const PopupMenuItem(
                                            value: 'to_category',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(Icons.login),
                                              minLeadingWidth: 26,
                                              title: Text('Make to category'),
                                            )),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                            value: 'merge',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(Icons.merge_type),
                                              minLeadingWidth: 26,
                                              title: Text(
                                                  'Merge with another category'),
                                            )),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(Icons.edit),
                                              minLeadingWidth: 26,
                                              title: Text('Edit'),
                                            )),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(Icons.delete),
                                              minLeadingWidth: 26,
                                              title: Text('Delete'),
                                            ))
                                      ];
                                    },
                                    onSelected: (String value) {
                                      if (value == 'delete') {
                                        deleteCategory(subcategory.id);
                                      } else if (value == 'to_category') {
                                        makeMainCategory(subcategory);
                                      } else if (value == 'edit') {
                                        openSubcategoryForm((name, icon) {
                                          subcategory.icon = icon;
                                          subcategory.name = name;

                                          context
                                              .read<CategoryService>()
                                              .updateCategory(subcategory);
                                        });
                                      }
                                    },
                                  ),
                                  title: Text(subcategory.name));
                            }));
                          }

                          return const LinearProgressIndicator();
                        },
                      ),

                    if (widget.categoryUUID != null)
                      ListTile(
                          leading: const Icon(Icons.add),
                          onTap: () {
                            openSubcategoryForm((name, icon) {
                              context.read<CategoryService>().insertCategory(
                                  Category.childCategory(
                                      id: const Uuid().v4(),
                                      name: name,
                                      icon: icon,
                                      parentCategory: categoryToEdit!));
                            });
                          },
                          title: const Text('Add subcategory'))
                  ],
                ),
              ));
  }
}
