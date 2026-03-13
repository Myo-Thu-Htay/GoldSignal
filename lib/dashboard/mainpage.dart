import 'package:flutter/material.dart';
import 'package:gold_signal/core/routing/app_router.dart';

class MainPage extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  const MainPage({super.key, required this.child, required this.selectedIndex});

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        AppRouter.delegate
            .navigateTo(AppRouter.dashboard); // Navigate to Dashboard
        break;
      case 1:
        AppRouter.delegate.navigateTo(AppRouter.account); // Navigate to Account
        break;
      case 2:
        AppRouter.delegate.navigateTo(AppRouter.addTrade);
        break;
      case 3:
        AppRouter.delegate
            .navigateTo(AppRouter.portfolio); // Navigate to Portfolio
        break;
      case 4:
        AppRouter.delegate
            .navigateTo(AppRouter.settings); // Navigate to Settings
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Account"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_outlined), label: "Add"),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: "Portfolio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
