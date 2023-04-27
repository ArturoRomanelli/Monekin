import 'package:finlytics/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tab3Page extends StatefulWidget {
  const Tab3Page({Key? key}) : super(key: key);

  @override
  State<Tab3Page> createState() => _Tab3PageState();
}

class _Tab3PageState extends State<Tab3Page> {
  List<DateTime?>? currentDateRange;

  int initialIndex = 500;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: initialIndex);

    final DateRangeService dateRangeService = context.read<DateRangeService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hello Tab 2'), elevation: 3, actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Do something
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Do something
          },
        ),
      ]),
      body: Column(
        children: [
          AppBar(
            title: Text(
                DateRangeService.instance.startDate?.toIso8601String() ?? ''),
          ),
          Expanded(
            child: PageView.builder(
              //  physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                    child: Column(children: [
                  ...List.generate(10, (i) => Text(index.toString())),
                  Text(context
                          .read<DateRangeService>()
                          .getDateRange(index - initialIndex)[0]
                          ?.toIso8601String() ??
                      '')
                ]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
