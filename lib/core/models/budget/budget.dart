import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/utils/date_getter.dart';

class Budget extends BudgetInDB {
  List<String> categories;
  List<String> accounts;

  Budget(
      {required super.id,
      required super.name,
      required super.limitAmount,
      required this.categories,
      required this.accounts,
      super.intervalPeriod,
      super.startDate,
      super.endDate})
      : assert(categories.isNotEmpty && accounts.isNotEmpty);

  List<DateTime> get currentDateRange {
    if (intervalPeriod != null) {
      if (intervalPeriod == TransactionPeriodicity.day) {
        return [
          DateTime(currentYear, currentMonth, currentDayOfMonth),
          DateTime(currentYear, currentMonth, currentDayOfMonth + 1)
        ];
      }

      final dateRangeServ = DateRangeService(
          selectedDateRange: intervalPeriod == TransactionPeriodicity.month
              ? DateRange.monthly
              : intervalPeriod == TransactionPeriodicity.year
                  ? DateRange.annualy
                  : DateRange.weekly);

      final dates = dateRangeServ.getCurrentDateRange();

      return [dates[0]!, dates[1]!];
    }

    return [startDate!, endDate!];
  }

  int get daysLeft {
    return DateTime.now().difference(currentDateRange[1]).inDays;
  }

  Stream<double> get currentValue {
    return AccountService.instance
        .getAccountsData(
      accountIds: accounts,
      accountDataFilter: AccountDataFilter.balance,
      categoriesIds: categories,
      startDate: currentDateRange[0],
      endDate: currentDateRange[1],
    )
        .map((res) {
      res = res * -1;

      if (res <= 0) {
        return 0;
      }

      return res;
    });
  }

  Stream<double> get percentageAlreadyUsed {
    return currentValue.map((event) => event / limitAmount);
  }
}
