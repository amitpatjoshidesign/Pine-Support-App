import 'package:flutter/material.dart';

import '../features/support/presentation/support_home_screen.dart';
import '../theme/app_theme.dart';

class SupportMobileApp extends StatelessWidget {
  const SupportMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Support Mobile',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _SupportScrollBehavior(),
      theme: SupportAppTheme.light(),
      darkTheme: SupportAppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SupportHomeScreen(),
    );
  }
}

class _SupportScrollBehavior extends MaterialScrollBehavior {
  const _SupportScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
