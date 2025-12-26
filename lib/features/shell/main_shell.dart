import 'package:flutter/material.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import '../journal/journal_list_page.dart';
import '../stats/weekly_report_page.dart';
import '../anomaly/anomaly_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> pages = [
      const JournalListPage(),
      const AnomalyPage(),
      const WeeklyReportPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.edit_note),
            label: l10n.label_nav_journal,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bolt),
            label: l10n.label_nav_alerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.label_nav_stats,
          ),
        ],
      ),
    );
  }
}
