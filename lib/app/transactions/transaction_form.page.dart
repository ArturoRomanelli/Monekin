import 'package:finlytics/app/accounts/account_selector.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/home/home.page.dart';
import 'package:finlytics/app/transactions/widgets/interval_selector_help.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/expansion_panel/single_expansion_panel.dart';
import 'package:finlytics/core/presentation/widgets/inline_info_card.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/date_time_picker.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
              builder: (context) => widget.prevPage ?? const HomePage()));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEditMode
              ? t.transaction.edit_success
              : t.transaction.new_success)));
    }

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
          status: date.compareTo(DateTime.now()) > 0
              ? TransactionStatus.pending
              : status,
          isHidden: isHidden,
          notes: notesController.text.isEmpty ? null : notesController.text,
          title: titleController.text.isEmpty ? null : titleController.text,
          recurrentInfo: recurrentRule);
    } else {
      toPush = MoneyTransaction.transfer(
          id: widget.transactionToEdit?.id ?? const Uuid().v4(),
          account: fromAccount!,
          receivingAccount: toAccount!,
          date: date,
          value: valueToNumber!,
          status: date.compareTo(DateTime.now()) > 0
              ? TransactionStatus.pending
              : status,
          isHidden: isHidden,
          notes: notesController.text.isEmpty ? null : notesController.text,
          title: titleController.text.isEmpty ? null : titleController.text,
          recurrentInfo: recurrentRule);
    }

    TransactionService.instance.insertOrUpdateTransaction(toPush).then((value) {
      onSuccess();
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
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
      recurrentRule = transaction.recurrentInfo;
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
            label:
                Text(isEditMode ? t.transaction.create : t.transaction.create),
          ),
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
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
                        final defaultNumberValidatorResult = fieldValidator(
                            value,
                            isRequired: true,
                            validator: ValidatorType.double);

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
                      inputFormatters: [decimalDigitFormatter],
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    selector(
                        title: '${t.general.account} *',
                        inputValue: fromAccount?.name,
                        icon: fromAccount?.icon,
                        iconColor: null,
                        onClick: () async {
                          final modalRes = await showAccountSelectorBottomSheet(
                              context,
                              AccountSelector(
                                allowMultiSelection: false,
                                filterSavingAccounts: widget.mode ==
                                    TransactionFormMode.incomeOrExpense,
                                selectedAccounts: [fromAccount!],
                              ));

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
                                await showAccountSelectorBottomSheet(
                                    context,
                                    AccountSelector(
                                      allowMultiSelection: false,
                                      filterSavingAccounts: widget.mode ==
                                          TransactionFormMode.incomeOrExpense,
                                      selectedAccounts: [toAccount!],
                                    ));

                            if (modalRes != null && modalRes.isNotEmpty) {
                              setState(() {
                                toAccount = modalRes.first;
                              });
                            }
                          }),
                    if (widget.mode == TransactionFormMode.incomeOrExpense)
                      selector(
                          title: '${t.general.category} *',
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
                                    body: CategoriesList(
                                      mode: CategoriesListMode
                                          .modalSelectSubcategory,
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
                        DateTime? pickedDate = await openDateTimePicker(context,
                            showTimePickerAfterDate: true);
                        if (pickedDate == null) return;

                        setState(() {
                          date = pickedDate;
                        });
                      },
                    ),
                    if (date.compareTo(DateTime.now()) > 0) ...[
                      const SizedBox(height: 8),
                      const InlineInfoCard(
                          text:
                              'La fecha seleccionada es posterior a la actual. Se añadirá la transacción como pendiente',
                          mode: InlineInfoCardMode.info),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(
                          text: recurrentRule.formText(context)),
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
                      decoration: InputDecoration(
                        labelText: t.general.time.periodicity.display,
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        labelText: 'Título de la transacción',
                        hintText:
                            'Si no se especifica, se usará el nombre de la categoría',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleExpansionPanel(
              sidePadding: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (recurrentRule.isNoRecurrent)
                            DropdownButtonFormField<TransactionStatus?>(
                              value: date.compareTo(DateTime.now()) > 0
                                  ? TransactionStatus.pending
                                  : status,
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
                                        child: Text(TransactionStatus
                                            .values[index]
                                            .displayName(context))))
                              ],
                              onChanged: date.compareTo(DateTime.now()) > 0
                                  ? null
                                  : (value) {
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
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: CurrencyDisplayer(
                                              amountToConvert:
                                                  valueInDestinyToNumber!,
                                              currency: fromAccount!.currency),
                                        )
                                      : null),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final defaultNumberValidatorResult =
                                    fieldValidator(value,
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                            InlineInfoCard(
                                text:
                                    'Serán transpasados a la cuenta de destino especificada ${NumberFormat.currency(symbol: toAccount!.currency.symbol).format(valueToNumber)}',
                                mode: InlineInfoCardMode.info)
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
                      )),
                  SwitchListTile(
                    value: isHidden,
                    title: const Text('Ocultar transacción'),
                    subtitle: const Text(
                        'No será mostrada en listados ni estadisticas'),
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
