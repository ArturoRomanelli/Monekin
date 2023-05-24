import 'package:finlytics/app/stats/footer_segmented_calendar_button.dart';
import 'package:finlytics/app/tabs/widgets/chart_by_categories.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:flutter/material.dart';

class MovementsByCategoryPage extends StatefulWidget {
  const MovementsByCategoryPage({super.key});

  @override
  State<MovementsByCategoryPage> createState() =>
      _MovementsByCategoryPageState();
}

class _MovementsByCategoryPageState extends State<MovementsByCategoryPage> {
  final dateRangeService = DateRangeService();

  late DateTime? currentStartDate;
  late DateTime? currentEndDate;
  late DateRange? currentDateRange;

  @override
  void initState() {
    super.initState();

    final dates = dateRangeService.getDateRange(0);

    currentStartDate = dates[0];
    currentEndDate = dates[1];
    currentDateRange = dateRangeService.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movimientos por categoría")),
      persistentFooterButtons: [
        FooterSegmentedCalendarButton(
          onDateRangeChanged: (newStartDate, newEndDate, newDateRange) {
            setState(() {
              currentStartDate = newStartDate;
              currentEndDate = newEndDate;
              currentDateRange = newDateRange;
            });
          },
        )
      ],
      body: SingleChildScrollView(
        child: ChartByCategories(
            startDate: currentStartDate,
            endDate: currentEndDate,
            showList: true),
      ),
    );
  }
}
