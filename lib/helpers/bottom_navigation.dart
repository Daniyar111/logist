import 'package:flutter/material.dart';

enum TabItem {profile, onStock, sendPage, ppp}

class TabHelper{

  static TabItem item({int index}) {

    switch (index){
      case 0:
        return TabItem.profile;
      case 1:
        return TabItem.onStock;
      case 2:
        return TabItem.sendPage;
      case 3:
        return TabItem.ppp;
    }
    return TabItem.profile;
  }

  static String description(TabItem tabItem){

    switch (tabItem) {
      case TabItem.profile:
        return 'Профиль';
      case TabItem.onStock:
        return 'На складе';
      case TabItem.sendPage:
        return 'Отправленные';
      case TabItem.ppp:
        return 'ПпП';
    }
    return '';
  }

  static IconData icon(TabItem tabItem){
    switch (tabItem) {
      case TabItem.profile:
        return Icons.error;
      case TabItem.onStock:
        return Icons.pin_drop;
      case TabItem.sendPage:
        return Icons.mode_comment;
      case TabItem.ppp:
        return Icons.email;
    }
    return Icons.email;
  }

  static MaterialColor color(TabItem tabItem){

    switch (tabItem) {
      case TabItem.profile:
        return Colors.red;
      case TabItem.onStock:
        return Colors.red;
      case TabItem.sendPage:
        return Colors.red;
      case TabItem.ppp:
        return Colors.red;
    }
    return Colors.grey[800];
  }
}


class BottomNavigation extends StatelessWidget {

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  BottomNavigation({this.currentTab, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.profile),
        _buildItem(tabItem: TabItem.onStock),
        _buildItem(tabItem: TabItem.sendPage),
        _buildItem(tabItem: TabItem.ppp),
      ],
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}){

    String text = TabHelper.description(tabItem);
    IconData icon = TabHelper.icon(tabItem);

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _colorTabMatching(tabItem: tabItem),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: _colorTabMatching(tabItem: tabItem)
        ),
      )
    );
  }


  Color _colorTabMatching({TabItem tabItem}){
    return currentTab == tabItem ? TabHelper.color(tabItem) : Colors.grey;
  }
}
