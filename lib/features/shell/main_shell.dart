import 'package:flutter/material.dart';
import '../journal/journal_list_page.dart';
import '../onboarding/onboarding_watchlist_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const JournalListPage(),
    const Center(child: Text('异动 (Step 4 实现)')),
    const Center(child: Text('统计 (Step 5 实现)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易前置复盘日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            tooltip: '管理关注股票',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const OnboardingWatchlistPage(isStandalone: true),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_note), label: '复盘'),
          NavigationDestination(icon: Icon(Icons.bolt), label: '异动'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: '统计'),
        ],
      ),
    );
  }
}
