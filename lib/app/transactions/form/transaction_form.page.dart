import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:monekin/app/accounts/account_selector.dart';
import 'package:monekin/app/categories/categories_list.dart';
import 'package:monekin/app/home/home.page.dart';
import 'package:monekin/app/transactions/form/widgets/interval_selector_help.dart';
import 'package:monekin/core/database/services/account/account_service.dart';
import 'package:monekin/core/database/services/transaction/transaction_service.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';
import 'package:monekin/core/models/account/account.dart';
import 'package:monekin/core/models/category/category.dart';
import 'package:monekin/core/models/supported-icon/supported_icon.dart';
import 'package:monekin/core/models/transaction/transaction.dart';
import 'package:monekin/core/presentation/animations/shake/shake_widget.dart';
import 'package:monekin/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:monekin/core/presentation/widgets/currency_displayer.dart';
import 'package:monekin/core/presentation/widgets/expansion_panel/single_expansion_panel.dart';
import 'package:monekin/core/presentation/widgets/inline_info_card.dart';
import 'package:monekin/core/presentation/widgets/persistent_footer_button.dart';
import 'package:monekin/core/presentation/widgets/scrollable_with_bottom_gradient.dart';
import 'package:monekin/core/services/supported_icon/supported_icon_service.dart';
import 'package:monekin/core/utils/color_utils.dart';
import 'package:monekin/core/utils/date_time_picker.dart';
import 'package:monekin/core/utils/text_field_validator.dart';
import 'package:monekin/i18n/translations.g.dart';
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

  TextEditingController notesController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  bool get isEditMode => widget.transactionToEdit != null;

  RecurrencyData recurrentRule = const RecurrencyData.noRepeat();

  final _shakeKey = GlobalKey<ShakeWidgetState>();

  Widget selector({
    required bool isMobile,
    required String title,
    required String? inputValue,
    required SupportedIcon? icon,
    required Color? iconColor,
    required Function onClick,
  }) {
    icon ??= SupportedIconService.instance.defaultSupportedIcon;
    iconColor ??= Theme.of(context).colorScheme.primary;

    final t = Translations.of(context);

    if (isMobile) {
      return InkWell(
        onTap: () => onClick(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              icon.displayFilled(color: iconColor, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w300),
                  ),
                  Text(inputValue ?? t.general.unspecified)
                ],
              )
            ],
          ),
        ),
      );
    }

    return TextFormField(
        controller:
            TextEditingController(text: inputValue ?? t.general.unspecified),
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

  Future<List<Account>?> showAccountSelector(Account account) {
    return showAccountSelectorBottomSheet(
        context,
        AccountSelector(
          allowMultiSelection: false,
          filterSavingAccounts:
              widget.mode == TransactionFormMode.incomeOrExpense,
          selectedAccounts: [account],
        ));
  }

  Future<void> selectCategory() async {
    final modalRes = await showCategoryListModal(
      context,
      const CategoriesList(
        mode: CategoriesListMode.modalSelectSubcategory,
      ),
    );

    if (modalRes != null && modalRes.isNotEmpty) {
      setState(() {
        selectedCategory = modalRes.first;
      });
    }
  }

  fillForm(MoneyTransaction transaction) async {
    setState(() {
      fromAccount = transaction.account;
      toAccount = transaction.receivingAccount;
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

  List<Widget> buildExtraFields() {
    return [
      if (recurrentRule.isNoRecurrent)
        DropdownButtonFormField<TransactionStatus?>(
          value: date.compareTo(DateTime.now()) > 0
              ? TransactionStatus.pending
              : status,
          decoration: InputDecoration(
            labelText: t.transaction.form.status,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(t.transaction.status.none),
            ),
            ...List.generate(
                TransactionStatus.values.length,
                (index) => DropdownMenuItem(
                    value: TransactionStatus.values[index],
                    child: Text(
                        TransactionStatus.values[index].displayName(context))))
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
              labelText:
                  '${t.transfer.form.currency_exchange_selector.value_in_destiny}  *',
              hintText: 'Ex.: 200',
              suffixText: toAccount?.currency.symbol),
          keyboardType: TextInputType.number,
          inputFormatters: decimalDigitFormatter,
          validator: (value) {
            final defaultNumberValidatorResult = fieldValidator(value,
                isRequired: false, validator: ValidatorType.double);

            if (defaultNumberValidatorResult != null) {
              return defaultNumberValidatorResult;
            }

            if (valueToNumber == null) {
              return null;
            } else if (valueToNumber! == 0) {
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
      ],
      if (widget.mode == TransactionFormMode.transfer &&
          valueToNumber != null &&
          valueInDestinyToNumber == null) ...[
        const SizedBox(height: 16),
        InlineInfoCard(
            text: '${t.transfer.form.currency_info_add(
              x: NumberFormat.currency(symbol: toAccount!.currency.symbol)
                  .format(valueToNumber),
            )} ',
            mode: InlineInfoCardMode.info)
      ],
      const SizedBox(height: 16),
      TextFormField(
        minLines: 2,
        maxLines: 10,
        controller: notesController,
        decoration: InputDecoration(
          labelText: t.transaction.form.description,
          alignLabelWithHint: true,
          hintText: t.transaction.form.description_info,
        ),
      ),
    ];
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleController,
      maxLength: 15,
      decoration: InputDecoration(labelText: t.transaction.form.title),
    );
  }

  Widget buildCalculatorButton({
    required String text,
    int flex = 1,
    required Color bgColor,
    Color? textColor = Colors.black,
  }) {
    onButtonPress() {
      HapticFeedback.lightImpact();

      final decimalPlaces = valueController.text.split('.').elementAtOrNull(1);

      if (text == 'DONE') {
        if (selectedCategory == null) {
          _shakeKey.currentState?.shake();
          return;
        }
        submitForm();
        return;
      }

      if (text == 'AC') {
        valueController.text = '0';
      } else if (text == '⌫' && valueToNumber != null) {
        valueController.text =
            valueController.text.substring(0, valueController.text.length - 1);
      } else {
        if (decimalPlaces != null && decimalPlaces.length >= 2) {
          return;
        }

        valueController.text += text;
      }
      setState(() {});
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            shadowColor: bgColor.darken(0.15),
            surfaceTintColor: bgColor.darken(0.15),
            foregroundColor: textColor,
            disabledForegroundColor: textColor,
            disabledBackgroundColor: bgColor.lighten(0.175),
            elevation: 0,
          ),
          onPressed:
              text == 'DONE' && (valueToNumber == null || valueToNumber == 0)
                  ? null
                  : () => onButtonPress(),
          child: text == '⌫' || text == 'DONE'
              ? Icon(
                  text == '⌫' ? Icons.backspace_rounded : Icons.check_rounded)
              : Text(
                  text,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    final bool isBlue = (widget.mode == TransactionFormMode.transfer ||
        selectedCategory == null);

    final trColor = isBlue
        ? Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColor
        : (selectedCategory!.type.isIncome ? Colors.green : Colors.red);

    final trColorLighten = trColor.lighten(isBlue ? 0.275 : 0.375);

    return StreamBuilder(
        stream: UserSettingService.instance
            .getSetting(SettingKey.transactionMobileMode),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title:
                  Text(isEditMode ? t.transaction.edit : t.transaction.create),
            ),
            persistentFooterButtons: snapshot.hasData && snapshot.data == '0'
                ? [
                    PersistentFooterButton(
                      child: FilledButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            submitForm();
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(isEditMode
                            ? t.transaction.edit
                            : t.transaction.create),
                      ),
                    )
                  ]
                : null,
            body: Builder(builder: (context) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              if (snapshot.data == '1') {
                /* -----------------------------------------------
                ---------- FORM IN A CALCULATOR STYLE ------------
                ------------------------------------------------- */

                return LayoutBuilder(builder: (context, constrains) {
                  return Column(
                    children: [
                      SizedBox(
                        height: constrains.maxHeight * 0.6,
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: CurrencyDisplayer(
                                  amountToConvert: valueToNumber ?? 0,
                                  currency: fromAccount?.currency,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .copyWith(fontSize: 32),
                                ),
                              ),
                            ),
                            if (date.compareTo(DateTime.now()) > 0)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InlineInfoCard(
                                    text:
                                        t.transaction.form.validators.date_max,
                                    mode: InlineInfoCardMode.info),
                              ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 8, 12),
                                      child: recurrentRule.isNoRecurrent
                                          ? Text(
                                              DateFormat.yMMMMd()
                                                  .add_Hm()
                                                  .format(date),
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                            )
                                          : Text(
                                              '${DateFormat.yMMMMd().format(date)} - ${recurrentRule.formText(context)}',
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                            ),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await openDateTimePicker(
                                        context,
                                        initialDate: date,
                                        firstDate: fromAccount?.date,
                                        showTimePickerAfterDate: true,
                                      );
                                      if (pickedDate == null) return;

                                      setState(() {
                                        date = pickedDate;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final res =
                                        await showIntervalSelectoHelpDialog(
                                            context,
                                            selectedRecurrentRule:
                                                recurrentRule);

                                    if (res == null) return;

                                    setState(() {
                                      recurrentRule = res;
                                    });
                                  },
                                  icon: recurrentRule.isRecurrent
                                      ? const Icon(Icons.event_repeat_rounded)
                                      : const Icon(Icons.repeat_one_rounded),
                                ),
                                const SizedBox(width: 4)
                              ],
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  selector(
                                      isMobile: true,
                                      title: t.general.account,
                                      inputValue: fromAccount?.name,
                                      icon: fromAccount?.icon,
                                      iconColor: null,
                                      onClick: () async {
                                        final modalRes =
                                            await showAccountSelector(
                                                fromAccount!);

                                        if (modalRes != null &&
                                            modalRes.isNotEmpty) {
                                          setState(() {
                                            fromAccount = modalRes.first;
                                          });
                                        }
                                      }),
                                  const Icon(Icons.arrow_forward),
                                  if (widget.mode ==
                                      TransactionFormMode.transfer)
                                    selector(
                                        isMobile: true,
                                        title: t.transfer.form.to,
                                        inputValue: toAccount?.name,
                                        icon: toAccount?.icon,
                                        iconColor: null,
                                        onClick: () async {
                                          final modalRes =
                                              await showAccountSelector(
                                                  toAccount!);

                                          if (modalRes != null &&
                                              modalRes.isNotEmpty) {
                                            setState(() {
                                              toAccount = modalRes.first;
                                            });
                                          }
                                        }),
                                  if (widget.mode ==
                                      TransactionFormMode.incomeOrExpense)
                                    ShakeWidget(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      shakeCount: 1,
                                      shakeOffset: 10,
                                      key: _shakeKey,
                                      child: selector(
                                        isMobile: true,
                                        title: t.general.category,
                                        inputValue: selectedCategory?.name,
                                        icon: selectedCategory?.icon,
                                        iconColor: selectedCategory != null
                                            ? ColorHex.get(
                                                selectedCategory!.color)
                                            : null,
                                        onClick: () => selectCategory(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(),
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                //color: trColorLighten,
                                child: Center(
                                  child: Text(
                                    t.transaction.form.tap_to_see_more,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                              onTap: () => showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                isScrollControlled: true,
                                builder: (context) => DraggableScrollableSheet(
                                    expand: false,
                                    maxChildSize: 0.85,
                                    minChildSize: 0.5,
                                    initialChildSize: 0.55,
                                    builder: (context, scrollController) {
                                      return Column(
                                        children: [
                                          Expanded(
                                            child: ScrollableWithBottomGradient(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 16,
                                              ),
                                              controller: scrollController,
                                              child: Column(
                                                children: [
                                                  buildTitleField(),
                                                  const SizedBox(height: 16),
                                                  ...buildExtraFields()
                                                ],
                                              ),
                                            ),
                                          ),
                                          BottomSheetFooter(
                                              submitText:
                                                  t.general.close_and_save,
                                              showCloseIcon: false,
                                              submitIcon: Icons
                                                  .keyboard_arrow_down_rounded,
                                              onSaved: () {
                                                Navigator.pop(context);
                                              })
                                        ],
                                      );
                                    }),
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      Container(
                        height: constrains.maxHeight * 0.4,
                        padding: const EdgeInsets.all(6),
                        color: trColorLighten,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '1'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '4'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '7'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '.'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '2'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '5'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '8'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '0'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '3'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '6'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '9'),
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: '⌫'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildCalculatorButton(
                                      bgColor: trColorLighten, text: 'AC'),
                                  buildCalculatorButton(
                                      bgColor: trColor, text: 'DONE', flex: 3),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                });
              }

              /* -----------------------------------------------
              ---------- FORM IN IT'S DEFAULT STYLE ------------
              ------------------------------------------------- */

              return SingleChildScrollView(
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
                                  labelText: '${t.transaction.form.value} *',
                                  hintText: 'Ex.: 200',
                                  suffixText: fromAccount?.currency.symbol),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final defaultNumberValidatorResult =
                                    fieldValidator(value,
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.next,
                              inputFormatters: decimalDigitFormatter,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            selector(
                                isMobile: false,
                                title: '${t.general.account} *',
                                inputValue: fromAccount?.name,
                                icon: fromAccount?.icon,
                                iconColor: null,
                                onClick: () async {
                                  final modalRes =
                                      await showAccountSelector(fromAccount!);

                                  if (modalRes != null && modalRes.isNotEmpty) {
                                    setState(() {
                                      fromAccount = modalRes.first;
                                    });
                                  }
                                }),
                            const SizedBox(height: 16),
                            if (widget.mode == TransactionFormMode.transfer)
                              selector(
                                  isMobile: false,
                                  title: '${t.transfer.form.to} *',
                                  inputValue: toAccount?.name,
                                  icon: toAccount?.icon,
                                  iconColor: null,
                                  onClick: () async {
                                    final modalRes =
                                        await showAccountSelector(toAccount!);

                                    if (modalRes != null &&
                                        modalRes.isNotEmpty) {
                                      setState(() {
                                        toAccount = modalRes.first;
                                      });
                                    }
                                  }),
                            if (widget.mode ==
                                TransactionFormMode.incomeOrExpense)
                              selector(
                                isMobile: false,
                                title: '${t.general.category} *',
                                inputValue: selectedCategory?.name,
                                icon: selectedCategory?.icon,
                                iconColor: selectedCategory != null
                                    ? ColorHex.get(selectedCategory!.color)
                                    : null,
                                onClick: () => selectCategory(),
                              ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: TextEditingController(
                                  text: DateFormat.yMMMMd()
                                      .add_Hm()
                                      .format(date)),
                              decoration: InputDecoration(
                                  labelText: '${t.general.time.datetime} *'),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await openDateTimePicker(
                                  context,
                                  initialDate: date,
                                  firstDate: fromAccount?.date,
                                  showTimePickerAfterDate: true,
                                );
                                if (pickedDate == null) return;

                                setState(() {
                                  date = pickedDate;
                                });
                              },
                            ),
                            if (date.compareTo(DateTime.now()) > 0) ...[
                              const SizedBox(height: 8),
                              InlineInfoCard(
                                  text: t.transaction.form.validators.date_max,
                                  mode: InlineInfoCardMode.info),
                              const SizedBox(height: 4),
                            ],
                            const SizedBox(height: 16),
                            TextField(
                              controller: TextEditingController(
                                  text: recurrentRule.formText(context)),
                              readOnly: true,
                              onTap: () async {
                                final res = await showIntervalSelectoHelpDialog(
                                    context,
                                    selectedRecurrentRule: recurrentRule);

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
                            buildTitleField()
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
                              child: Column(children: buildExtraFields())),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}