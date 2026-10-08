import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/balance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/api_key_field.dart';
import '../widgets/balance_card.dart';
import '../widgets/brand_loader.dart';
import '../widgets/details_section.dart';
import '../widgets/error_banner.dart';
import '../widgets/whale_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final provider = context.read<BalanceProvider>();
    await provider.initialize();
    if (!mounted) return;
    if (_keyController.text.isEmpty && provider.apiKey != null) {
      _keyController.text = provider.apiKey!;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<bool> _handleSave(String value) async {
    final provider = context.read<BalanceProvider>();
    final ok = await provider.saveKeyAndRefresh(value);
    if (!mounted) return ok;
    _showSnack(
      ok
          ? 'Key saved · balance updated'
          : provider.errorMessage ?? 'Could not save the key.',
      ok ? AppColors.offPeak : AppColors.peak,
    );
    return ok;
  }

  Future<void> _confirmClear() async {
    final provider = context.read<BalanceProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        title: const Text('Remove API key?'),
        content: const Text(
          'The key will be erased from secure storage on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.peak),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await provider.clearKey();
    _keyController.clear();
    if (mounted) _showSnack('API key removed', context.mutedText);
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == AppColors.offPeak
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BalanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
        child: provider.isInitializing
            ? const _BootView()
            : RefreshIndicator(
                onRefresh: () async {
                  await provider.refresh();
                },
                color: AppColors.brand,
                backgroundColor: context.cardSurface,
                strokeWidth: 2.6,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                      sliver: SliverList.list(
                        children: [
                          _Header(
                            hasKey: provider.hasApiKey,
                            lastUpdated: provider.lastUpdated,
                            onClear: _confirmClear,
                          ),
                          const SizedBox(height: 22),
                          const _SectionLabel('API KEY'),
                          const SizedBox(height: 10),
                          ApiKeyField(
                            controller: _keyController,
                            isLoading: provider.isLoading,
                            hasSavedKey: provider.hasApiKey,
                            onSave: _handleSave,
                          ),
                          const SizedBox(height: 18),
                          if (provider.errorMessage != null) ...[
                            ErrorBanner(
                              message: provider.errorMessage!,
                              isAuthError: provider.isAuthError,
                              onRetry: provider.hasApiKey
                                  ? () => provider.refresh()
                                  : null,
                            ),
                            const SizedBox(height: 18),
                          ],
                          BalanceCard(
                            balance: provider.balance,
                            traffic: provider.traffic,
                            isLoading: provider.isLoading,
                            lastUpdated: provider.lastUpdated,
                          ),
                          const SizedBox(height: 16),
                          DetailsSection(
                            balance: provider.balance,
                            isLoading: provider.isLoading,
                          ),
                          const SizedBox(height: 26),
                          const _Footer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.hasKey,
    required this.onClear,
    this.lastUpdated,
  });

  final bool hasKey;
  final VoidCallback onClear;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const WhaleLogo(size: 44),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DeepSeek Balance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'API usage & remaining credit',
                style: TextStyle(fontSize: 12.5, color: context.mutedText),
              ),
              if (lastUpdated != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Last updated: ${DateFormat('dd MMM yyyy, HH:mm').format(lastUpdated!.toLocal())}',
                  style: TextStyle(fontSize: 11.5, color: context.mutedText),
                ),
              ],
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: hasKey
              ? IconButton(
                  key: const ValueKey('clear'),
                  tooltip: 'Remove API key',
                  onPressed: onClear,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                )
              : const SizedBox.shrink(key: ValueKey('none')),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
        color: context.mutedText,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, size: 15, color: context.mutedText),
          const SizedBox(height: 8),
          Text(
            'Your key is stored securely on-device.\n'
            'Data is fetched from api.deepseek.com.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: context.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BootView extends StatelessWidget {
  const _BootView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const WhaleLogo(size: 72),
        const SizedBox(height: 28),
        const BrandLoader(size: 34),
        const SizedBox(height: 20),
        Text(
          'Loading your balance…',
          style: TextStyle(fontSize: 13.5, color: context.mutedText),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
