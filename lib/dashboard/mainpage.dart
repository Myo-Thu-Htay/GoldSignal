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
        AppRouter.delegate
            .navigateTo(AppRouter.signalHistory); // Navigate to Signal History
        break;
      case 2:
        AppRouter.delegate
            .navigateTo(AppRouter.addTrade); // Navigate to Add Trade
        break;
      case 3:
        AppRouter.delegate
            .navigateTo(AppRouter.portfolio); // Navigate to Portfolio
        break;
      case 4:
        AppRouter.delegate.navigateTo(AppRouter.account); // Navigate to Account
        break;
      case 5:
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
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Chart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Signals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_card_outlined), label: "Trade"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: "Portfolio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
