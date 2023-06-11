import 'package:finlytics/app/budgets/budget_details_page.dart';
import 'package:finlytics/app/budgets/budget_form_page.dart';
import 'package:finlytics/core/database/services/budget/budget_service.dart';
import 'package:finlytics/core/presentation/widgets/animated_progress_bar.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.budgets.title),
      ),
      persistentFooterButtons: [
        PersistentFooterButton(
            child: FilledButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BudgetFormPage(
                              prevPage: BudgetsPage(),
                            ))),
                icon: const Icon(Icons.add),
                label: Text(t.budgets.form.create)))
      ],
      body: StreamBuilder(
          stream: BudgetServive.instance.getBudgets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            final budgets = snapshot.data!;

            return ListView.separated(
                itemBuilder: (context, index) {
                  final budget = budgets[index];

                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BudgetDetailsPage(budget: budget))),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StreamBuilder(
                                    stream: budget.currentValue,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Skeleton(
                                            width: 25, height: 16);
                                      }

                                      return CurrencyDisplayer(
                                        amountToConvert: snapshot.data!,
                                        showDecimals: false,
                                      );
                                    }),
                                CurrencyDisplayer(
                                  amountToConvert: budget.limitAmount,
                                  showDecimals: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            StreamBuilder(
                                stream: budget.percentageAlreadyUsed,
                                builder: (context, snapshot) {
                                  return AnimatedProgressBar(
                                      value: snapshot.data ?? 0);
                                })
                          ],
                        )),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: budgets.length);
          }),
    );
  }
}
