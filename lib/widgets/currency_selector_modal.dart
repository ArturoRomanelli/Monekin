import 'package:finlytics/services/currency/currency.dart';
import 'package:finlytics/services/currency/currency.service.dart';
import 'package:finlytics/widgets/bottomSheetFooter.dart';
import 'package:finlytics/widgets/bottomSheetHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CurrencySelectorModal extends StatefulWidget {
  const CurrencySelectorModal(
      {super.key, required this.preselectedCurrency, this.onCurrencySelected});

  final void Function(Currency selectedCurrency)? onCurrencySelected;

  final Currency preselectedCurrency;

  @override
  State<CurrencySelectorModal> createState() => _CurrencySelectorModalState();
}

class _CurrencySelectorModalState extends State<CurrencySelectorModal> {
  CurrencyService? _currencyService;

  List<Currency>? _filteredCurrencies;

  Currency? _selectedCurrency;

  @override
  void initState() {
    super.initState();

    _currencyService = context.read<CurrencyService>();
    _selectedCurrency = widget.preselectedCurrency;
    _filteredCurrencies = _currencyService!.getCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.85,
      minChildSize: 0.625,
      initialChildSize: 0.85,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHeader(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select a currency",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Chip(
                        side: BorderSide(color: colors.primary, width: 2),
                        // backgroundColor: Theme.of(context).primaryColorLight,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text("${_selectedCurrency?.code}")),
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SvgPicture.asset(
                                _selectedCurrency!.currencyIconPath,
                                height: 20,
                                width: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'Search for a currency by name or code',
                      labelText: "Tap to search",
                      prefixIcon: Icon(Icons.search),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  onChanged: (value) {
                    setState(() {
                      _filteredCurrencies = context
                          .read<CurrencyService>()
                          .searchCurrencies(value, context);
                    });
                    (() {});
                  },
                ),
                Expanded(
                    child: Stack(children: [
                  ListView.separated(
                      controller: scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filteredCurrencies?.length ?? 0,
                      separatorBuilder: (context, i) {
                        return const Divider(
                          height: 0,
                        );
                      },
                      itemBuilder: (context, index) {
                        final currencyItem = _filteredCurrencies![index];

                        return ListTile(
                          title: Text(
                            currencyItem.getLocaleName(context),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                          trailing: Text(
                            currencyItem.code,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          selected:
                              currencyItem.code == _selectedCurrency?.code,
                          // selectedTileColor: colors.primaryContainer,
                          leading: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Stack(
                              children: [
                                SvgPicture.asset(
                                  currencyItem.currencyIconPath,
                                  height: 35,
                                  width: 35,
                                ),
                                if (currencyItem.code ==
                                    _selectedCurrency?.code)
                                  Container(
                                      height: 35,
                                      width: 35,
                                      color: const Color.fromARGB(92, 0, 0, 0),
                                      child: const Center(
                                          child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )))
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCurrency = currencyItem;
                            });
                          },
                        );
                      }),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.background.withOpacity(0),
                          colors.background
                        ],
                      )),
                    ),
                  )
                ])),
                BottomSheetFooter(
                    onSaved: () => {
                          widget.onCurrencySelected!(_selectedCurrency!),
                          Navigator.pop(context)
                        })
              ],
            ),
          ),
        );
      },
    );
  }
}
