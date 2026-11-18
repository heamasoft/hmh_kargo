import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/approvals_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/shell_controller.dart';
import '../../router.dart';
import '../../services/link_inbox.dart';
import '../../theme/app_colors.dart';
import '../../services/push_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/heama_toast.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/wallet_screen.dart';
import '../stores/stores_screen.dart';
import '../webstore/open_store.dart';

/// The tabbed container for the five primary destinations.
/// The active tab lives in [ShellController] so any screen can switch tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final _pages = const [
    HomeScreen(),
    StoresScreen(),
    CartScreen(),
    OrdersScreen(),
    WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialTab != 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ShellController>().goToTab(widget.initialTab),
      );
    }
    // Keep the approvals badge fresh without a manual refresh: check the
    // server every 20 s while the shell is alive.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSignedInWork();
      // Links from outside: a copied one is offered, a shared one opens.
      LinkInbox.copied.addListener(_offerCopiedLink);
      LinkInbox.listenForShares((text) {
        if (mounted) openPastedLink(context, text);
      });
      LinkInbox.check();
    });
  }

  /// "Found a link you copied — Add to cart", over whatever screen is open.
  void _offerCopiedLink() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 30),
      content: Row(
        children: [
          const Icon(Icons.link_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(l.copiedLinkFound)),
        ],
      ),
      action: SnackBarAction(
        label: l.copiedLinkAdd,
        onPressed: () async {
          final link = await LinkInbox.copiedLink();
          if (!mounted) return;
          if (link == null) {
            showHeamaToast(context, l.icNotALink);
            return;
          }
          openPastedLink(context, link);
        },
      ),
    ));
  }

  /// Whether the signed-in side of the shell is running.
  bool _signedInStarted = false;

  /// The work that only means anything to a signed-in shopper: what the admin
  /// is waiting on them to answer, and where to send them a notification. A
  /// guest browsing the shop has neither, and asking the server for them would
  /// only be turned away — so it waits until they log in, which they may do at
  /// any point from their cart or their account.
  void _startSignedInWork() {
    if (!mounted || _signedInStarted) return;
    if (!context.read<AuthProvider>().isAuthenticated) return;
    _signedInStarted = true;
    _approvals = context.read<ApprovalsProvider>()..startPolling();
    _setUpPush();
  }

  /// Logged out: stop asking on their behalf.
  void _stopSignedInWork() {
    if (!_signedInStarted) return;
    _signedInStarted = false;
    _approvals?.stopPolling();
    _approvals = null;
  }

  /// Registers this phone for FCM pushes and reacts to them: refresh the data
  /// when one arrives in the foreground, open the approvals screen on tap.
  Future<void> _setUpPush() async {
    final push = context.read<PushService>();
    await push.register();
    if (!mounted) return;
    push.attachHandlers(
      onMessage: (m) {
        if (!mounted) return;
        context.read<ApprovalsProvider>().refreshSilently();
        context.read<OrdersProvider>().load();
        final text = m.notification?.body ?? m.notification?.title;
        if (text != null && text.isNotEmpty) showHeamaToast(context, text);
      },
      onOpened: (m) {
        if (!mounted) return;
        context.read<ApprovalsProvider>().refreshSilently();
        Navigator.of(context).pushNamed(Routes.approvals);
      },
    );
  }

  ApprovalsProvider? _approvals;

  @override
  void dispose() {
    _approvals?.stopPolling(); // logged out / shell gone — stop hitting the API
    LinkInbox.copied.removeListener(_offerCopiedLink);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the background → check immediately.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ApprovalsProvider>().refreshSilently();
      // Back from the Shein app or the browser: did they copy a link?
      LinkInbox.check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = context.watch<ShellController>().tab;
    // A guest can log in from their cart or their account without leaving the
    // shell, and can log out the same way, so the signed-in side follows the
    // session rather than only what was true when the app opened.
    final signedIn = context.watch<AuthProvider>().isAuthenticated;
    if (signedIn != _signedInStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        signedIn ? _startSignedInWork() : _stopSignedInWork();
      });
    }
    // Android back button: from any non-Home tab, go back to Home first; from
    // Home, allow the pop so the app closes (canPop = true only on Home).
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && index != 0) {
          context.read<ShellController>().goToTab(0);
        }
      },
      child: Scaffold(
        // Home and Shop sit on the soft grey; the other tabs on white. The
        // floating bar shows the page colour around it.
        backgroundColor: index <= 1 ? AppColors.cloud : Colors.white,
        body: IndexedStack(index: index, children: _pages),
        bottomNavigationBar: AppBottomNav(
          current: index,
          onTap: (i) => context.read<ShellController>().goToTab(i),
        ),
      ),
    );
  }
}
