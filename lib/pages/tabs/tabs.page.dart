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
  static const List<Map<String, dynamic>> _tabs = [
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

  static final _tabsComponent = [
    _buildTabComponent(widget: const Tab1Page()),
    _buildTabComponent(widget: const Tab2Page()),
    _buildTabComponent(widget: const Tab3Page()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      widget.currentPageIndex = index;
    });
  }

  static Widget _buildTabComponent({required Widget widget}) {
    return Scaffold(
      body: widget,
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
                  child: _tabsComponent[widget.currentPageIndex],
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: _tabsComponent[widget.currentPageIndex],
            ),
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
