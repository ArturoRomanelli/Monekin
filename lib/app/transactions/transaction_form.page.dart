import 'package:finlytics/app/accounts/account_selector.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/app/transactions/widgets/interval_selector_help.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/recurrent-rules/recurrent_rule_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/bottomSheetHeader.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/expansion_panel/single_expansion_panel.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database_impl.dart';

enum TransactionFormMode { transfer, incomeOrExpense }

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({
    super.key,
    this.prevPage,
    this.transactionToEdit,
    this.mode = TransactionFormMode.incomeOrExpense,
    this.fromAccount,
    this.toAccount,
  });

  final Widget? prevPage;
  final MoneyTransaction? transactionToEdit;
  final TransactionFormMode mode;

  final Account? fromAccount;
  final Account? toAccount;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController valueController = TextEditingController();
  double? get valueToNumber => double.tryParse(valueController.text);

  TextEditingController valueInDestinyController = TextEditingController();
  double? get valueInDestinyToNumber =>
      double.tryParse(valueInDestinyController.text);

  Category? selectedCategory;

  Account? fromAccount;
  Account? toAccount;

  DateTime date = DateTime.now();

  TransactionStatus? status;
  bool isHidden = false;

  TextEditingController notesController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  bool get isEditMode => widget.transactionToEdit != null;

  RecurrencyData recurrentRule = const RecurrencyData.noRepeat();

  Widget selector({
    required String title,
    required String? inputValue,
    required SupportedIcon? icon,
    required Color? iconColor,
    required Function onClick,
  }) {
    icon ??= SupportedIconService.instance.defaultSupportedIcon;
    iconColor ??= Theme.of(context).colorScheme.primary;

    return TextFormField(
        controller:
            TextEditingController(text: inputValue ?? 'Sin especificar'),
        readOnly: true,
        validator: (_) => fieldValidator(inputValue, isRequired: true),
        onTap: () => onClick(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: title,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          prefixIcon: Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: icon.displayFilled(color: iconColor),
          ),
        ));
  }

  submitForm() {
    final t = Translations.of(context);

    if (valueToNumber! < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.mode == TransactionFormMode.incomeOrExpense
              ? t.transaction.form.validators.negative_transaction
              : t.transaction.form.validators.negative_transfer)));

      return;
    }

    onSuccess() {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  widget.prevPage ?? const TabsPage(currentPageIndex: 1)));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditMode
              ? t.transaction.edit_success
              : t.transaction.new_success)));
    }

    if (recurrentRule.isNoRecurrent) {
      late MoneyTransaction toPush;

      if (widget.mode == TransactionFormMode.incomeOrExpense) {
        toPush = MoneyTransaction.incomeOrExpense(
          id: widget.transactionToEdit?.id ?? const Uuid().v4(),
          account: fromAccount!,
          date: date,
          value: selectedCategory!.type.isExpense
              ? valueToNumber! * -1
              : valueToNumber!,
          category: selectedCategory!,
          status: status,
          isHidden: isHidden,
          notes: notesController.text.isEmpty ? null : notesController.text,
          title: titleController.text.isEmpty ? null : titleController.text,
        );
      } else {
        toPush = MoneyTransaction.transfer(
            id: widget.transactionToEdit?.id ?? const Uuid().v4(),
            account: fromAccount!,
            receivingAccount: toAccount!,
            date: date,
            value: valueToNumber!,
            status: status,
            isHidden: isHidden,
            notes: notesController.text.isEmpty ? null : notesController.text,
            title: titleController.text.isEmpty ? null : titleController.text);
      }

      TransactionService.instance
          .insertOrUpdateTransaction(toPush)
          .then((value) {
        onSuccess();
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      });
    } else {
      RecurrentRuleInDB toPush = RecurrentRuleInDB(
          id: widget.transactionToEdit?.id ?? const Uuid().v4(),
          nextPaymentDate: date,
          intervalPeriod: recurrentRule.intervalPeriod!,
          intervalEach: recurrentRule.intervalEach!,
          endDate: recurrentRule.ruleRecurrentLimit?.endDate,
          remainingTransactions:
              recurrentRule.ruleRecurrentLimit?.remainingIterations,
          accountID: fromAccount!.id,
          receivingAccountID: widget.mode == TransactionFormMode.transfer
              ? toAccount!.id
              : null,
          categoryID: widget.mode == TransactionFormMode.incomeOrExpense
              ? selectedCategory!.id
              : null,
          valueInDestiny: widget.mode == TransactionFormMode.transfer
              ? valueInDestinyToNumber!
              : null,
          notes: notesController.text.isEmpty ? null : notesController.text,
          title: titleController.text.isEmpty ? null : titleController.text,
          value: widget.mode == TransactionFormMode.incomeOrExpense &&
                  selectedCategory!.type.isExpense
              ? valueToNumber! * -1
              : valueToNumber!);

      RecurrentRuleService.instance
          .insertOrUpdateRecurrentRule(toPush)
          .then((value) {
        onSuccess();
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.transactionToEdit != null) {
      fillForm(widget.transactionToEdit!);
    } else {
      AccountService.instance
          .getAccounts(
              limit: widget.mode == TransactionFormMode.incomeOrExpense ? 1 : 2)
          .first
          .then((acc) {
        fromAccount = widget.fromAccount ?? acc[0];

        if (widget.mode == TransactionFormMode.transfer) {
          toAccount = widget.toAccount ??
              (acc[1].id != fromAccount!.id ? acc[1] : acc[0]);
        }

        setState(() {});
      });
    }
  }

  fillForm(MoneyTransaction transaction) async {
    setState(() {
      fromAccount = transaction.account;
      toAccount = transaction.receivingAccount;
      isHidden = transaction.isHidden;
      date = transaction.date;
      status = transaction.status;
      selectedCategory = transaction.category;
    });

    notesController.text = transaction.notes ?? '';
    titleController.text = transaction.title ?? '';
    valueController.text = transaction.value.abs().toString();
    valueInDestinyController.text =
        transaction.valueInDestiny?.abs().toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? t.transaction.edit : t.transaction.create),
      ),
      persistentFooterButtons: [
        PersistentFooterButton(
          child: FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                submitForm();
              }
            },
            icon: const Icon(Icons.save),
            label: Text(t.transaction.create),
          ),
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(
                        labelText: 'Amount *',
                        hintText: 'Ex.: 200',
                        suffix: fromAccount != null && valueToNumber != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CurrencyDisplayer(
                                    amountToConvert: valueToNumber!,
                                    currency: fromAccount!.currency),
                              )
                            : null),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final defaultNumberValidatorResult = fieldValidator(value,
                          isRequired: true, validator: ValidatorType.double);

                      if (defaultNumberValidatorResult != null) {
                        return defaultNumberValidatorResult;
                      }

                      if (valueToNumber! == 0) {
                        return t.transaction.form.validators.zero;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  selector(
                      title: 'Account *',
                      inputValue: fromAccount?.name,
                      icon: fromAccount?.icon,
                      iconColor: null,
                      onClick: () async {
                        final modalRes =
                            await showModalBottomSheet<List<Account>>(
                          context: context,
                          builder: (context) {
                            return AccountSelector(
                              allowMultiSelection: false,
                              filterSavingAccounts: widget.mode ==
                                  TransactionFormMode.incomeOrExpense,
                              selectedAccounts: [fromAccount!],
                            );
                          },
                        );

                        if (modalRes != null && modalRes.isNotEmpty) {
                          setState(() {
                            fromAccount = modalRes.first;
                          });
                        }
                      }),
                  const SizedBox(height: 16),
                  if (widget.mode == TransactionFormMode.transfer)
                    selector(
                        title: 'Receiving account *',
                        inputValue: toAccount?.name,
                        icon: toAccount?.icon,
                        iconColor: null,
                        onClick: () async {
                          final modalRes =
                              await showModalBottomSheet<List<Account>>(
                            context: context,
                            builder: (context) {
                              return AccountSelector(
                                allowMultiSelection: false,
                                filterSavingAccounts: widget.mode ==
                                    TransactionFormMode.incomeOrExpense,
                                selectedAccounts: [toAccount!],
                              );
                            },
                          );

                          if (modalRes != null && modalRes.isNotEmpty) {
                            setState(() {
                              toAccount = modalRes.first;
                            });
                          }
                        }),
                  if (widget.mode == TransactionFormMode.incomeOrExpense)
                    selector(
                        title: 'Category *',
                        inputValue: selectedCategory?.name,
                        icon: selectedCategory?.icon,
                        iconColor: selectedCategory != null
                            ? ColorHex.get(selectedCategory!.color)
                            : null,
                        onClick: () async {
                          final modalRes =
                              await showModalBottomSheet<List<Category>>(
                            context: context,
                            builder: (context) {
                              return const ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Scaffold(
                                  body: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BottomSheetHeader(),
                                      Expanded(
                                        child: CategoriesList(
                                          mode: CategoriesListMode
                                              .modalSelectSubcategory,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          if (modalRes != null && modalRes.isNotEmpty) {
                            setState(() {
                              selectedCategory = modalRes.first;
                            });
                          }
                        }),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: TextEditingController(
                        text: DateFormat.yMMMMd().add_Hm().format(date)),
                    decoration: const InputDecoration(
                      labelText: 'Fecha y hora *',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(1700),
                          lastDate: DateTime(2099));

                      if (pickedDate == null) return;

                      setState(() {
                        date = pickedDate;
                      });
                    },
                  ),
                  if (!(widget.transactionToEdit != null &&
                      widget.transactionToEdit is! MoneyRecurrentRule)) ...[
                    const SizedBox(height: 16),
                    TextField(
                        controller:
                            TextEditingController(text: recurrentRule.formText),
                        readOnly: true,
                        onTap: () async {
                          final res = await showDialog<RecurrencyData?>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 0),
                                clipBehavior: Clip.hardEdge,
                                content: IntervalSelectorHelp(
                                    selectedRecurrentRule: recurrentRule),
                              );
                            },
                          );

                          if (res == null) return;

                          setState(() {
                            recurrentRule = res;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Repeat",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ))
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    maxLength: 15,
                    decoration: const InputDecoration(
                      labelText: 'Titulo de la transacción',
                      hintText:
                          'Si no se especifica, se usará el nombre de la categoría',
                    ),
                  ),
                ],
              ),
            ),
            SingleExpansionPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: status,
                        decoration: InputDecoration(
                          labelText: t.transaction.form.status,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Ninguno'),
                          ),
                          ...List.generate(
                              TransactionStatus.values.length,
                              (index) => DropdownMenuItem(
                                  value: TransactionStatus.values[index],
                                  child: Text(TransactionStatus.values[index]
                                      .displayName(context))))
                        ],
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });
                        },
                      ),
                      if (widget.mode == TransactionFormMode.transfer) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: valueInDestinyController,
                          decoration: InputDecoration(
                              labelText: 'Amount in destiny *',
                              hintText: 'Ex.: 200',
                              suffix: fromAccount != null &&
                                      valueInDestinyToNumber != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: CurrencyDisplayer(
                                          amountToConvert:
                                              valueInDestinyToNumber!,
                                          currency: fromAccount!.currency),
                                    )
                                  : null),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final defaultNumberValidatorResult = fieldValidator(
                                value,
                                isRequired: false,
                                validator: ValidatorType.double);

                            if (defaultNumberValidatorResult != null) {
                              return defaultNumberValidatorResult;
                            }

                            if (valueToNumber == null) {
                              return null;
                            } else if (valueToNumber! == 0) {
                              return 'Transactions amount can be zero';
                            }

                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                      if (widget.mode == TransactionFormMode.transfer &&
                          valueToNumber != null &&
                          valueInDestinyToNumber == null) ...[
                        const SizedBox(height: 16),
                        Card(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          elevation: 0,
                          margin: const EdgeInsets.all(0),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'Serán transpasados a la cuenta de destino especificada ${NumberFormat.currency(symbol: toAccount!.currency.symbol).format(valueToNumber)}',
                                    style: TextStyle(
                                        fontSize: 12.25,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        minLines: 2,
                        maxLines: 10,
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          alignLabelWithHint: true,
                          hintText:
                              'Escribe información extra acerca de esta transacción',
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    value: isHidden,
                    title: Text('Ocultar transacción'),
                    subtitle:
                        Text('No será mostrada en listados ni estadisticas'),
                    onChanged: (value) {
                      setState(() {
                        isHidden = value;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
