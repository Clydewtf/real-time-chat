import 'package:flutter/material.dart';
import '../widgets/layout/app_bottom_nav.dart';
import '../widgets/layout/app_scaffold.dart';
import 'chats/chats_screen.dart';
import 'settings/settings_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatsScreen(),
    SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Chats', 'Settings'];

    return AppScaffold(
      title: titles[_currentIndex],
      centerTitle: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}