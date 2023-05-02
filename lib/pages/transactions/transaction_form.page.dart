import 'package:finlytics/pages/accounts/account_selector.dart';
import 'package:finlytics/pages/categories/categories_list.dart';
import 'package:finlytics/pages/tabs/tab2.page.dart';
import 'package:finlytics/services/account/account.model.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:finlytics/services/category/category.model.dart';
import 'package:finlytics/services/supported_icon/supported_icon.dart';
import 'package:finlytics/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/services/transaction/transaction.model.dart';
import 'package:finlytics/services/transaction/transaction_service.dart';
import 'package:finlytics/widgets/bottomSheetHeader.dart';
import 'package:finlytics/widgets/expansion_panel/single_expansion_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.prevPage});

  final Widget? prevPage;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController valueController = TextEditingController();
  double? get valueToNumber => double.tryParse(valueController.text);

  Category? selectedCategory;

  Account? fromAccount;

  DateTime date = DateTime.now();

  TransactionStatus? status;
  bool isHidden = false;

  TextEditingController noteController = TextEditingController();

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
        onTap: () => onClick(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
          icon: const Icon(Icons.category),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 6),
            child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: iconColor.withOpacity(0.2)),
                child: icon.display(color: iconColor)),
          ),
        ));
  }

  submitForm() {
    if (valueToNumber! < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No uses cantidades negativas para tu transaccion. Aplicaremos el signo en función de si la categoría seleccionada es de tipo gasto/ingreso')));

      return;
    }

    final toPush = MoneyTransaction.incomeOrExpense(
      id: const Uuid().v4(),
      account: fromAccount!,
      date: date,
      value:
          selectedCategory!.type == 'E' ? valueToNumber! * -1 : valueToNumber!,
      category: selectedCategory!,
      status: status,
      isHidden: isHidden,
      text: noteController.text.isEmpty ? null : noteController.text,
    );

    context
        .read<MoneyTransactionService>()
        .insertMoneyTransaction(toPush)
        .then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => widget.prevPage ?? const Tab2Page()));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    });
  }

  @override
  void initState() {
    super.initState();

    context.read<AccountService>().getAccounts(limit: 1).then((acc) {
      setState(() {
        fromAccount = acc[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add transaction'),
      ),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.all(4),
          width: double.infinity,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                submitForm();
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Guardar transacción'),
          ),
        )
      ],
      body: SingleChildScrollView(
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
                          border: const OutlineInputBorder(),
                          suffix: fromAccount != null && valueToNumber != null
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(NumberFormat.simpleCurrency(
                                          name: fromAccount!.currency.code,
                                          decimalDigits: 2)
                                      .format(valueToNumber)),
                                )
                              : null),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter initial value';
                        }

                        if (value.contains(',')) {
                          return 'Character "," is not valid. Split the decimal part by a "."';
                        }

                        if (valueToNumber == null) {
                          return 'Please enter a valid number';
                        } else if (valueToNumber == 0) {
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
                                filterSavingAccounts: false,
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
                    selector(
                        title: 'Category *',
                        inputValue: selectedCategory?.name,
                        icon: selectedCategory?.icon,
                        iconColor: selectedCategory != null
                            ? Color(int.parse('0xff${selectedCategory?.color}'))
                            : null,
                        onClick: () async {
                          final modalRes =
                              await showModalBottomSheet<List<Category>>(
                            context: context,
                            builder: (context) {
                              return ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Scaffold(
                                  body: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: TextEditingController(
                          text: DateFormat.yMMMd().format(
                              date)), //editing controller of this TextField
                      decoration: const InputDecoration(
                        labelText: 'Fecha y hora *',
                        icon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
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
                    const SizedBox(height: 16),
                    TextFormField(
                      minLines: 2,
                      maxLines: 10,
                      controller:
                          noteController, //editing controller of this TextField
                      decoration: const InputDecoration(
                        labelText: 'Nota',
                        hintText: 'Description',
                        alignLabelWithHint: true,
                        icon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(),
                      ),
                    )
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
                      child: DropdownButtonFormField(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Ninguno'),
                          ),
                          DropdownMenuItem(
                            value: TransactionStatus.voided,
                            child: Text('Nulo'),
                          ),
                          DropdownMenuItem(
                            value: TransactionStatus.pending,
                            child: Text('Pendiente'),
                          ),
                          DropdownMenuItem(
                            value: TransactionStatus.reconcilied,
                            child: Text('Reconciliado'),
                          ),
                          DropdownMenuItem(
                            value: TransactionStatus.unreconcilied,
                            child: Text('No reconciliado'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });
                        },
                      )),
                  SwitchListTile(
                    value: isHidden,
                    title: Text("Ocultar transacción"),
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
