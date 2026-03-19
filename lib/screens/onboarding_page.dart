import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _page = 0;
  late PageController _controller;
  bool _langSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  void _setLang(Locale locale) {
    localeNotifier.value = locale;
    setState(() => _langSelected = true);
    // Advance to next onboarding page after language selection
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _next() {
    if (_page < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finishOnboarding();
    }
  }

  void _skip() => _finishOnboarding();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F8),
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: _langSelected ? null : const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  // 1. Language selection
                  _LangSelectScreen(onSelect: _setLang),
                  // 2. Create your list
                  _OnboardScreen(
                    image: isAr ? 'assets/images/onboard_create_ar.png' : 'assets/images/onboard_create_en.png',
                    title: loc.onboardCreateTitle,
                    subtitle: loc.onboardCreateSubtitle,
                    button: loc.next,
                    onNext: _next,
                    page: 1,
                  ),
                  // 3. Add items
                  _OnboardScreen(
                    image: isAr ? 'assets/images/onboard_add_ar.png' : 'assets/images/onboard_add_en.png',
                    title: loc.onboardAddTitle,
                    subtitle: loc.onboardAddSubtitle,
                    button: loc.next,
                    onNext: _next,
                    page: 2,
                  ),
                  // 4. Share with friends
                  _OnboardScreen(
                    image: isAr ? 'assets/images/onboard_share_ar.png' : 'assets/images/onboard_share_en.png',
                    title: loc.onboardShareTitle,
                    subtitle: loc.onboardShareSubtitle,
                    button: loc.getStarted,
                    onNext: _next,
                    page: 3,
                  ),
                ],
              ),
              Positioned(
                top: 24, right: 24, left: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_page == 0 && isAr) const Text('البقالة التحريرية', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (_page == 0 && !isAr) const SizedBox(),
                    TextButton(
                      onPressed: _skip,
                      child: Text(loc.skip, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              if (_page > 0)
                Positioned(
                  bottom: 120, left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24, height: 6,
                      decoration: BoxDecoration(
                        color: _page-1 == i ? Colors.redAccent : Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangSelectScreen extends StatelessWidget {
  final void Function(Locale) onSelect;
  const _LangSelectScreen({required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isAr ? 'اختر اللغة' : 'Choose Language', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => onSelect(const Locale('en')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('English', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () => onSelect(const Locale('ar')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('العربية', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardScreen extends StatelessWidget {
  final String image, title, subtitle, button;
  final VoidCallback onNext;
  final int page;
  const _OnboardScreen({required this.image, required this.title, required this.subtitle, required this.button, required this.onNext, required this.page});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(image, height: 320),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(button),
            ),
          ),
        ),
      ],
    );
  }
}
