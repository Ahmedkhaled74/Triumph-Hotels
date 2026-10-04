import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:triumph_hotels/core/constants/app_strings.dart';
import 'package:triumph_hotels/core/localization/app_localizations.dart';
import 'package:triumph_hotels/core/providers/language_provider.dart';
import 'package:triumph_hotels/core/providers/auth_provider.dart';
import 'package:triumph_hotels/core/providers/hotel_provider.dart';
import 'package:triumph_hotels/core/providers/guest_portal_provider.dart';
import 'package:triumph_hotels/core/providers/global_notification_provider.dart';
import 'package:triumph_hotels/features/splash/splash_screen.dart';

import 'package:provider/provider.dart';
import 'package:triumph_hotels/core/providers/theme_provider.dart';

import 'core/theme/app_theme_old.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TriumphApp extends StatelessWidget {
  const TriumphApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => GuestPortalProvider()),
        ChangeNotifierProvider(create: (_) => GlobalNotificationProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final isRtl = languageProvider.currentLocale.languageCode == 'ar';
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
