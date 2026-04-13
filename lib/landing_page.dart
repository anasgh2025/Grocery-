import 'package:flutter/material.dart';

import 'widgets/banner_ad_widget.dart';
import 'widgets/footer_menu.dart';
import 'widgets/landing_header.dart';
import 'widgets/list_section_with_api.dart';
import 'widgets/marketing_card.dart';
import 'l10n/app_localizations.dart';

/// Mobile-first landing page composed from smaller widgets.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Colors are derived from the active Theme's ColorScheme so the app-wide
  // palette defined in `AppTheme` is used consistently.

  // Key lets us call .currentState!.refresh() from the Refresh button
  // without triggering any parent rebuild.
  final _listKey = GlobalKey<ListSectionWithApiState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final heroBg = theme.colorScheme.secondary;
    final width = MediaQuery.sizeOf(context).width;
    final horPad = width > 420 ? 28.0 : 20.0;

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fixed header ────────────────────────────────────────
            SizedBox(
              height: 56,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horPad),
                child: const LandingHeader(),
              ),
            ),
            // ── Fixed marketing card ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(horPad, 10, horPad, 0),
              child: RepaintBoundary(
                child: MarketingCard(accent: accent, heroBg: heroBg, height: 110),
              ),
            ),
            // ── "Active Lists" row — fixed, never inside scroll ─────
            Padding(
              padding: EdgeInsets.fromLTRB(horPad, 10, horPad, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.activeLists,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    // Calls refresh() on the section without rebuilding this widget
                    onPressed: () => _listKey.currentState?.refresh(),
                    child: Text(loc.refresh, style: TextStyle(color: accent)),
                  ),
                ],
              ),
            ),
            // ── List grid — the ONLY thing that scrolls ─────────────
            Expanded(
              child: RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horPad),
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      ListSectionWithApi(key: _listKey, accent: accent),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Removed FloatingActionButton (+)
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          FooterMenu(accent: accent),
        ],
      ),
    );
  }
}
