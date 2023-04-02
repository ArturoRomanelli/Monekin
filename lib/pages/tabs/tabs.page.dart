import 'package:finlytics/pages/tabs/tab1.page.dart';
import 'package:finlytics/pages/tabs/tab2.page.dart';
import 'package:finlytics/pages/tabs/tab3.page.dart';
import 'package:flutter/material.dart';

class TabsPage extends StatefulWidget {
  TabsPage({super.key, this.currentPageIndex = 0});

  int currentPageIndex;

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.business,
      'label': 'Business',
    },
    {
      'icon': Icons.school,
      'label': 'School',
    },
  ];

  final List<Widget> tabsPages = [];

  Widget _selectedWidget = _buildTabComponent(widget: const Tab1Page(), key: 0);

  @override
  void initState() {
    tabsPages.addAll([
      _buildTabComponent(widget: const Tab1Page(), key: 0),
      _buildTabComponent(widget: const Tab2Page(), key: 1),
      _buildTabComponent(widget: const Tab3Page(), key: 2),
    ]);

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.currentPageIndex = index;
      _selectedWidget = tabsPages[widget.currentPageIndex];
    });
  }

  static Widget _buildTabComponent({required Widget widget, required int key}) {
    return Scaffold(
      body: widget,
      key: ValueKey<int>(key),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
                      label: Text(_tabs[index]['label']),
                    ),
                  ),
                  selectedIndex: widget.currentPageIndex,
                  onDestinationSelected: _onItemTapped,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: tabsPages[widget.currentPageIndex],
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
                  label: _tabs[index]['label'],
                ),
              ),
              selectedIndex: widget.currentPageIndex,
              onDestinationSelected: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
