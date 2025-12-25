import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fupan/l10n/generated/app_localizations.dart';
import 'core/providers.dart';
import 'core/locale_provider.dart';
import 'features/onboarding/onboarding_watchlist_page.dart';
import 'features/shell/main_shell.dart';
import 'models/watchlist_item.dart';
import 'features/auth/login_page.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final userSession = container.read(userSessionProvider);
  await userSession.init();

  // Initialize locale from saved preferences
  await container.read(localeProvider.notifier).init();

  runApp(
    UncontrolledProviderScope(container: container, child: const FupanApp()),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class FupanApp extends ConsumerWidget {
  const FupanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for auth state changes to handle 401/logout
    ref.listen(userSessionProvider, (previous, next) {
      if (previous?.isAuthenticated == true && next.isAuthenticated == false) {
        // Redirect to login page when session is cleared (e.g., 401)
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });

    // Watch locale state
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.title_journal,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh'), Locale('en')],
      locale: locale, // Use user-selected locale (null = follow system)
      theme: AppTheme.lightTheme,
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
    _initFlow();
  }

  Future<void> _initFlow() async {
    final userSession = ref.read(userSessionProvider);
    if (!userSession.isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

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

    final userSession = ref.watch(userSessionProvider);
    if (!userSession.isAuthenticated) {
      return const LoginPage();
    }

    if (_watchlist.isEmpty) {
      return const OnboardingWatchlistPage();
    }

    return const MainShell();
  }
}
