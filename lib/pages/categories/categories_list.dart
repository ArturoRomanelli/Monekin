import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/category/categoryService.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key});

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  Widget buildCategoryList(String type, List<MainCategory> mainCategories) {
    if (type != "E" && type != "I") throw Exception("Incorrect category type");

    final categoriesToDisplay = (type == "E"
            ? mainCategories.where((cat) => cat.type == "E" || cat.type == "B")
            : mainCategories.where((cat) => cat.type == "I" || cat.type == "B"))
        .toList();

    return ListView.builder(
        itemCount: categoriesToDisplay.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = categoriesToDisplay[index];

          return ListTile(
            title: Text(category.name),
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    SupportedIconService.instance
                        .getIconByID(category.icon)
                        .urlToAssets,
                    colorFilter: ColorFilter.mode(
                        Color(int.parse('0xff${category.color}')),
                        BlendMode.srcIn),
                    height: 25,
                    width: 25,
                  )
                ]),
            onTap: () {},
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Categories"),
        ),
        body: Column(
          children: [
            const TabBar(tabs: [
              Tab(text: "Incomes"),
              Tab(text: "Expenses"),
            ]),
            FutureBuilder(
                future: context.watch<CategoryService>().getMainCategories(),
                builder: (context, categories) {
                  if (!categories.hasData) {
                    return const LinearProgressIndicator();
                  } else {
                    return Expanded(
                      child: TabBarView(children: [
                        buildCategoryList("I", categories.data!),
                        buildCategoryList("E", categories.data!),
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
