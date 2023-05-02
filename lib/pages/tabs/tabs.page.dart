import 'package:finlytics/pages/accounts/accountForm.dart';
import 'package:finlytics/pages/tabs/tab1.page.dart';
import 'package:finlytics/pages/tabs/tab2.page.dart';
import 'package:finlytics/pages/tabs/tab3.page.dart';
import 'package:finlytics/pages/transactions/transaction_form.page.dart';
import 'package:finlytics/services/account/accountService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key, this.currentPageIndex = 0});

  final int currentPageIndex;

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.home_outlined,
      'selectedIcon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.list_alt_outlined,
      'selectedIcon': Icons.list_alt,
      'label': 'Transactions',
    },
    {
      'icon': Icons.query_stats_outlined,
      'selectedIcon': Icons.query_stats,
      'label': 'Analysis',
    },
  ];

  final List<Widget> tabsPages = [];

  late Widget _selectedWidget;
  late int currentSelectedIndex;

  @override
  void initState() {
    tabsPages.addAll([
      _buildTabComponent(widget: const Tab1Page(), context: context, key: 0),
      _buildTabComponent(widget: const Tab2Page(), context: context, key: 1),
      _buildTabComponent(widget: const Tab3Page(), context: context, key: 2),
    ]);

    currentSelectedIndex = widget.currentPageIndex;
    _selectedWidget = tabsPages[currentSelectedIndex];

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      currentSelectedIndex = index;
      _selectedWidget = tabsPages[currentSelectedIndex];
    });
  }

  _showShouldCreateAccountWarn() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ops!'),
          content: const SingleChildScrollView(
              child: Text(
                  'You should create an account first to create this action perform this action')),
          actions: [
            TextButton(
              child: const Text('Go for that!'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountFormPage()));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabComponent(
      {required Widget widget,
      required BuildContext context,
      required int key}) {
    final accountService = context.read<AccountService>();

    return Scaffold(
      body: widget,
      key: ValueKey<int>(key),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if ((await accountService.getAccounts()).isEmpty) {
            _showShouldCreateAccountWarn();

            return;
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionFormPage(
                        prevPage:
                            TabsPage(currentPageIndex: currentSelectedIndex),
                      )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                NavigationRail(
                  destinations: List.generate(
                    _tabs.length,
                    (index) => NavigationRailDestination(
                      icon: Icon(_tabs[index]['icon']),
                      selectedIcon: Icon(_tabs[index]['selectedIcon']),
                      label: Text(_tabs[index]['label']),
                    ),
                  ),
                  leading: const SizedBox(
                      height: 50, child: Icon(Icons.safety_check)),
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: currentSelectedIndex,
                  onDestinationSelected: _onItemTapped,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: tabsPages[currentSelectedIndex],
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedWidget),
            bottomNavigationBar: NavigationBar(
              destinations: List.generate(
                _tabs.length,
                (index) => NavigationDestination(
                  icon: Icon(_tabs[index]['icon']),
                  selectedIcon: Icon(_tabs[index]['selectedIcon']),
                  label: _tabs[index]['label'],
                ),
              ),
              selectedIndex: currentSelectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
