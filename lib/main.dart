import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:steeker/pages/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://eb74916782e146d698b22a6e9d06193a@o170856.ingest.sentry.io/5648249';
    },
    appRunner: () => runApp(SteekerApp()),
  );
}

class SteekerApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steeker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LandingPage(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
