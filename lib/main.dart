import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/health_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Required before calling any native/plugin code before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Set up notifications early so the channel exists before any
  // screen tries to schedule a reminder.
  await NotificationService.instance.init();

  runApp(const ElderEaseApp());
}

class ElderEaseApp extends StatelessWidget {
  const ElderEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => TextScaleProvider()..load()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: Consumer<TextScaleProvider>(
        builder: (context, textScaleProvider, _) {
          return MaterialApp(
            title: 'ElderEase',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            // Applies the user's chosen text size (Settings > Text Size)
            // to every screen in the app automatically.
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScaleProvider.scale),
                ),
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