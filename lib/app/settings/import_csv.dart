import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:drift/drift.dart' as drift;
import 'package:finlytics/app/accounts/account_selector.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/home/home.page.dart';
import 'package:finlytics/core/database/app_db.dart';
import 'package:finlytics/core/database/backup/backup_database_service.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/database/services/currency/currency_service.dart';
import 'package:finlytics/core/database/services/transaction/transaction_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/presentation/widgets/loading_overlay.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ImportCSVPage extends StatefulWidget {
  const ImportCSVPage({super.key});

  @override
  State<ImportCSVPage> createState() => _ImportCSVPageState();
}

class _ImportCSVPageState extends State<ImportCSVPage> {
  int currentStep = 0;

  List<List<dynamic>>? csvData;
  Iterable<String>? get csvHeaders =>
      csvData?[0].map((item) => item.toString());

  int? amountColumn;
  int? accountColumn;
  int? dateColumn;

  final TextEditingController _dateFormatController =
      TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

  int? categoryColumn;
  Category? defaultCategory;
  Account? defaultAccount;

  int? notesColumn;
  int? titleColumn;

  void readFile() {
    BackupDatabaseService().readFile().then((csv) async {
      if (csv == null) {
        return;
      }

      await BackupDatabaseService()
          .processCsv(await csv.readAsString())
          .then((parsedCSV) {
        final columnsLenght = parsedCSV.map((e) => e.length).toList();

        if (parsedCSV.length >= 2 &&
            columnsLenght.elementAt(0) == columnsLenght.elementAt(1) + 1) {
          parsedCSV[0].removeLast();
        }

        if (parsedCSV.every((e) => e == parsedCSV.first)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'All the rows of the csv file must have the same number of columns')));
        }

        setState(() {
          csvData = parsedCSV;
        });
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    });
  }

  Widget selector({
    required String title,
    required String? inputValue,
    required SupportedIcon? icon,
    required Color? iconColor,
    required Function onClick,
    bool isRequired = false,
  }) {
    icon ??= SupportedIconService.instance.defaultSupportedIcon;
    iconColor ??= Theme.of(context).colorScheme.primary;

    return TextFormField(
        controller:
            TextEditingController(text: inputValue ?? 'Sin especificar'),
        readOnly: true,
        validator: (_) => fieldValidator(inputValue, isRequired: isRequired),
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

  DropdownButtonFormField<int> buildColumnSelector(
      {required int? value,
      required Iterable<String> headersToSelect,
      String? labelText,
      bool isNullable = true,
      required void Function(int? value) onChanged}) {
    labelText ??= 'Selecciona una columna del .csv';

    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(labelText: labelText),
      items: [
        if (isNullable)
          DropdownMenuItem(
            value: null,
            child: Text(t.general.unspecified),
          ),
        ...List.generate(
            headersToSelect.length,
            (index) => DropdownMenuItem(
                  value: csvHeaders!.toList().indexWhere(
                      (element) => element == headersToSelect.toList()[index]),
                  child: Text(headersToSelect.toList()[index]),
                ))
      ],
      onChanged: (value) {
        if (dateColumn == value) dateColumn = null;
        if (notesColumn == value) notesColumn = null;
        if (titleColumn == value) titleColumn = null;
        if (amountColumn == value) amountColumn = null;
        if (accountColumn == value) accountColumn = null;
        if (categoryColumn == value) categoryColumn = null;

        onChanged(value);
      },
    );
  }

  Future<void> addTransactions() async {
    if (accountColumn == null || amountColumn == null) {
      throw Exception('Account and amount columns can not be null');
    }

    final snackbarDisplayer = ScaffoldMessenger.of(context).showSnackBar;
    final loadingOverlay = LoadingOverlay.of(context);

    onSuccess() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));

      snackbarDisplayer(SnackBar(
          content: Text(
              'Se han importado correctamente ${csvData!.slice(1).length} transacciones')));
    }

    loadingOverlay.show();

    try {
      final csvRows = csvData!.slice(1).toList();
      final db = AppDB.instance;

      for (final row in csvRows) {
        final account = await (db.select(db.accounts)
              ..where((tbl) => tbl.name
                  .lower()
                  .isValue(row[accountColumn!].toString().toLowerCase())))
            .getSingleOrNull();

        final accountID = account != null
            ? account.id
            : defaultAccount != null
                ? defaultAccount!.id
                : const Uuid().v4();

        if (account == null && defaultAccount == null) {
          await AccountService.instance.insertAccount(AccountInDB(
              id: accountID,
              name: row[accountColumn!].toString(),
              iniValue: 0,
              date: DateTime.now(),
              type: AccountType.normal,
              iconId: SupportedIconService.instance.defaultSupportedIcon.id,
              currencyId:
                  (await CurrencyService.instance.getUserPreferredCurrency())
                      .code));
        }

        final String categoryID = (await CategoryService.instance
                    .getCategories(
                      predicate: (catTable, parentCatTable) =>
                          catTable.name.lower().isValue(
                              row[categoryColumn!].toString().toLowerCase()) |
                          parentCatTable.name.lower().isValue(
                              row[categoryColumn!].toString().toLowerCase()),
                    )
                    .first)
                .firstOrNull
                ?.id ??
            defaultCategory!.id;

        await TransactionService.instance.insertTransaction(TransactionInDB(
          id: const Uuid().v4(),
          date: dateColumn == null
              ? DateTime.now()
              : DateFormat(_dateFormatController.text, 'en_US')
                  .parse(row[dateColumn!].toString()),
          accountID: accountID,
          value: double.parse(row[amountColumn!].toString()),
          isHidden: false,
          categoryID: categoryID,
          notes: notesColumn == null ? null : row[notesColumn!].toString(),
          title: titleColumn == null ? null : row[titleColumn!].toString(),
        ));
      }
    } catch (e) {
      snackbarDisplayer(SnackBar(content: Text(e.toString())));
    }

    loadingOverlay.hide();
    onSuccess();
  }

  Step buildStep(
      {required int index,
      required String title,
      required List<Widget> content}) {
    return Step(
      title: Text(title),
      isActive: currentStep >= index,
      state: currentStep > index
          ? StepState.complete
          : currentStep == index
              ? StepState.editing
              : StepState.disabled,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
        appBar: AppBar(title: Text(t.backup.import.manual_import)),
        body: Stepper(
          type: StepperType.vertical,
          currentStep: currentStep,
          onStepTapped: (value) {
            setState(() {
              currentStep = value;
            });
          },
          controlsBuilder: (context, details) {
            bool nextButtonDisabled = currentStep == 0 && csvData == null ||
                currentStep == 3 && defaultCategory == null ||
                currentStep == 1 && amountColumn == null ||
                currentStep == 4 && _dateFormatController.text.isEmpty;

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: currentStep == 5
                  ? SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            nextButtonDisabled ? null : () => addTransactions(),
                        label: Text('Importar transacciones'),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    )
                  : Row(
                      children: [
                        FilledButton(
                          onPressed: nextButtonDisabled
                              ? null
                              : details.onStepContinue,
                          child: Text(t.general.continue_text),
                        ),
                        if (currentStep == 0 && csvData != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => readFile(),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Select other file'),
                          ),
                        ]
                      ],
                    ),
            );
          },
          onStepContinue: () {
            setState(() => currentStep++);
          },
          steps: [
            buildStep(index: 0, title: 'Select a file', content: [
              const Text(
                  'Selecciona un fichero .csv de tu dispositivo. Asegurate de que este tenga una primera fila que describa el nombre de cada columna'),
              const SizedBox(height: 8),
              if (csvData == null) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => readFile(),
                  child: DottedBorder(
                    color: Colors.grey.withOpacity(0.5),
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    borderType: BorderType.RRect,
                    dashPattern: const [6, 8],
                    radius: const Radius.circular(12),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 68),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                size: 48,
                                weight: 10,
                                color: Colors.grey.withOpacity(0.95)),
                            const SizedBox(height: 4),
                            Text(
                              'Pulsa para seleccionar un archivo',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (csvData != null) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) => Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.18),
                    ),
                    headingTextStyle:
                        const TextStyle(fontWeight: FontWeight.w600),
                    columns: csvHeaders!
                        .map((item) => DataColumn(label: Text(item)))
                        .toList(),
                    rows: csvData!
                        .sublist(1, 5)
                        .map(
                          (csvrow) => DataRow(
                            cells: csvrow
                                .map((csvItem) =>
                                    DataCell(Text(csvItem.toString())))
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (csvData!.length - 4 >= 1)
                  Text(
                    '+${csvData!.length - 4} filas más',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 12),
              ]
            ]),
            buildStep(
              index: 1,
              title: 'Select amount column',
              content: [
                const Text(
                    'Selecciona la columna donde se especifica el valor de cada transacción. Usa valores negativos para los gastos y positivos para los ingresos. Usa un punto como separador decimal'),
                const SizedBox(height: 24),
                if (csvHeaders != null)
                  buildColumnSelector(
                    value: amountColumn,
                    headersToSelect: csvHeaders!,
                    onChanged: (value) {
                      setState(() {
                        amountColumn = value;
                      });
                    },
                  ),
              ],
            ),
            buildStep(
              index: 2,
              title: 'Select account column',
              content: [
                const Text(
                    'Selecciona la columna donde se especifica la cuenta a la que pertenece cada transacción. Podrás también seleccionar una cuenta por defecto en el caso de que no encontremos la cuenta que desea. Si no se especifica una cuenta por defecto, crearemos una con el mismo nombre'),
                const SizedBox(height: 24),
                if (csvHeaders != null)
                  buildColumnSelector(
                    value: accountColumn,
                    headersToSelect: csvHeaders!.whereIndexed(
                        (index, element) => index != amountColumn),
                    onChanged: (value) {
                      setState(() {
                        accountColumn = value;
                      });
                    },
                  ),
                const SizedBox(height: 12),
                selector(
                    title: '${t.general.account} *',
                    inputValue: defaultAccount?.name,
                    icon: defaultAccount?.icon,
                    iconColor: null,
                    onClick: () async {
                      final modalRes = await showAccountSelectorBottomSheet(
                          context,
                          AccountSelector(
                            allowMultiSelection: false,
                            filterSavingAccounts: true,
                            selectedAccounts: [
                              if (defaultAccount != null) defaultAccount!
                            ],
                          ));

                      if (modalRes != null && modalRes.isNotEmpty) {
                        setState(() {
                          defaultAccount = modalRes.first;
                        });
                      }
                    }),
              ],
            ),
            buildStep(
              index: 3,
              title: 'Select category options',
              content: [
                const Text(
                    'Especifica la columna donde se encuentra el nombre de la categoría de la transacción. Debes especificar una categoría por defecto para que asignemos esta categoría a las transacciones, en caso de que la categoría no se pueda encontrar'),
                const SizedBox(height: 12),
                if (csvHeaders != null)
                  Builder(builder: (context) {
                    final headersToSelect = csvHeaders!.whereIndexed(
                        (index, element) =>
                            index != amountColumn && index != accountColumn);

                    return buildColumnSelector(
                      value: categoryColumn,
                      headersToSelect: headersToSelect,
                      onChanged: (value) {
                        setState(() {
                          categoryColumn = value;
                        });
                      },
                    );
                  }),
                const SizedBox(height: 12),
                selector(
                    title: '${t.general.category} *',
                    inputValue: defaultCategory?.name,
                    icon: defaultCategory?.icon,
                    isRequired: true,
                    iconColor: defaultCategory != null
                        ? ColorHex.get(defaultCategory!.color)
                        : null,
                    onClick: () async {
                      final modalRes = await showCategoryListModal(
                          context,
                          const CategoriesList(
                            mode: CategoriesListMode.modalSelectSubcategory,
                          ));

                      if (modalRes != null && modalRes.isNotEmpty) {
                        setState(() {
                          defaultCategory = modalRes.first;
                        });
                      }
                    }),
              ],
            ),
            buildStep(
              index: 4,
              title: 'Select date column',
              content: [
                const Text(
                    'Selecciona la columna donde se especifica la fecha de cada transacción. En caso de no especificarse, se crearan transacciones con la fecha actual'),
                const SizedBox(height: 24),
                if (csvHeaders != null)
                  buildColumnSelector(
                    value: dateColumn,
                    headersToSelect: csvHeaders!.whereIndexed((index,
                            element) =>
                        index != amountColumn &&
                        index != accountColumn &&
                        (categoryColumn == null || index != categoryColumn)),
                    onChanged: (value) {
                      setState(() {
                        dateColumn = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateFormatController,
                  decoration: InputDecoration(labelText: t.account.form.notes),
                  validator: (value) => fieldValidator(value),
                  autovalidateMode: AutovalidateMode.always,
                ),
              ],
            ),
            buildStep(
              index: 5,
              title: 'Other transactions attributes',
              content: [
                const Text(
                    'Especifica las columnas para otros atributos optativos de las transacciones'),
                const SizedBox(height: 24),
                if (csvHeaders != null)
                  Builder(builder: (context) {
                    final headersToSelect = csvHeaders!.whereIndexed((index,
                            element) =>
                        index != amountColumn &&
                        index != accountColumn &&
                        index != dateColumn &&
                        (categoryColumn == null || index != categoryColumn));

                    return Column(
                      children: [
                        buildColumnSelector(
                          value: notesColumn,
                          labelText: 'Columna de notas/descripción',
                          headersToSelect: headersToSelect,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        buildColumnSelector(
                          value: titleColumn,
                          labelText: 'Columna de título',
                          headersToSelect: headersToSelect,
                          onChanged: (value) {},
                        ),
                      ],
                    );
                  }),
              ],
            ),
          ],
        ));
  }
}
