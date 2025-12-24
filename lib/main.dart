import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers.dart';
import 'features/onboarding/onboarding_watchlist_page.dart';
import 'features/shell/main_shell.dart';
import 'models/watchlist_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final userSession = container.read(userSessionProvider);
  await userSession.init();

  runApp(
    UncontrolledProviderScope(container: container, child: const FupanApp()),
  );
}

class FupanApp extends ConsumerWidget {
  const FupanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '交易前置复盘日记',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StartupFlow(),
    );
  }
}

class StartupFlow extends ConsumerStatefulWidget {
  const StartupFlow({super.key});

  @override
  ConsumerState<StartupFlow> createState() => _StartupFlowState();
}

class _StartupFlowState extends ConsumerState<StartupFlow> {
  bool _isLoading = true;
  List<WatchlistItem> _watchlist = [];

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/watchlist');

      if (response.data != null && response.data['ok'] == true) {
        final List items = response.data['items'] ?? [];
        _watchlist = items.map((e) => WatchlistItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch watchlist: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_watchlist.isEmpty) {
      return const OnboardingWatchlistPage();
    }

    return const MainShell();
  }
}
