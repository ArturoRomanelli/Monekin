import 'package:finlytics/core/models/account/account.dart';
import 'package:flutter/material.dart';

class AccountTypeSelector extends StatefulWidget {
  const AccountTypeSelector(
      {super.key,
      required this.onSelected,
      this.selectedType = AccountType.normal});

  final AccountType selectedType;

  final Function(AccountType) onSelected;

  @override
  State<AccountTypeSelector> createState() => _AccountTypeSelectorState();
}

class _AccountTypeSelectorState extends State<AccountTypeSelector> {
  late AccountType selectedItem;

  @override
  void initState() {
    super.initState();

    selectedItem = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        AccountType.values.length,
        (index) {
          final AccountType item = AccountType.values[index];
          return Flexible(
            child: FinlyticsFilterChip(
              title: item.name,
              onPressed: () {
                setState(() {
                  selectedItem = item;
                  widget.onSelected(item);
                });
              },
              isSelected: item == selectedItem,
              icon: item.icon,
            ),
          );
        },
      ),
    );
  }
}

class FinlyticsFilterChip extends StatelessWidget {
  const FinlyticsFilterChip({
    super.key,
    required this.title,
    required this.onPressed,
    required this.isSelected,
    required this.icon,
  });

  final String title;
  final VoidCallback onPressed;
  final bool isSelected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            width: 1.25,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed.call,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Text(
                    "Useful to record your day-to-day finances. It is the most common account, it allows you to add expenses, income...",
                    softWrap: true,
                    style:
                        TextStyle(fontWeight: FontWeight.w300, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
