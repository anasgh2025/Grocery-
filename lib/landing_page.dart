import 'package:flutter/material.dart';

import 'widgets/footer_menu.dart';
import 'widgets/landing_header.dart';
import 'widgets/search_field.dart';
import 'widgets/list_section_with_api.dart';
import 'widgets/marketing_card.dart';
import 'widgets/create_list_dialog.dart';
import 'models/grocery_list.dart';

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
            // ── Fixed search bar ────────────────────────────────────
            SizedBox(
              height: 52,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horPad, 4, horPad, 0),
                child: const SearchField(),
              ),
            ),
            // ── Fixed marketing card ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(horPad, 10, horPad, 0),
              child: RepaintBoundary(
                child: SizedBox(
                  height: 110,
                  child: MarketingCard(accent: accent, heroBg: heroBg),
                ),
              ),
            ),
            // ── "Active Lists" row — fixed, never inside scroll ─────
            Padding(
              padding: EdgeInsets.fromLTRB(horPad, 10, horPad, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Lists',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    // Calls refresh() on the section without rebuilding this widget
                    onPressed: () => _listKey.currentState?.refresh(),
                    child: Text('Refresh', style: TextStyle(color: accent)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final created = await showModalBottomSheet<GroceryList>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: CreateListDialog(accent: accent),
                ),
              ),
            ),
          );

          if (created != null) {
            messenger.showSnackBar(const SnackBar(content: Text('List created')));
          }
        },
        backgroundColor: accent,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: FooterMenu(accent: accent),
    );
  }
}
