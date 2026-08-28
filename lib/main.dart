import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qr_doc/core/app_navigator.dart';
import 'package:qr_doc/core/utils.dart';
import 'package:qr_doc/pages/login_page.dart';
import 'package:qr_doc/pages/qr_detail/qr_detail_page.dart';
import 'package:qr_doc/pages/qr_detail/verify_doc_page.dart';
import 'package:qr_doc/pages/scan_qr_page.dart';
import 'package:qr_doc/pages/user_scan_list.dart';
import 'package:qr_doc/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

late final SharedPreferences storagePref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("km_KH");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8060);
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }
  storagePref = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = MaterialTheme(Theme.of(context).textTheme);
    return MaterialApp.router(
      scaffoldMessengerKey: GlobalKey(),
      title: 'QR DOC',
      themeMode: ThemeMode.light,
      theme: theme.lightHighContrast(),
      darkTheme: theme.darkHighContrast(),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  redirect: (context, state) {
    final loggedIn = LoginManager.isLoggedIn;
    final goingToLogin = state.matchedLocation == '/login';
    if (!loggedIn && !goingToLogin) return '/login';
    if (loggedIn && goingToLogin) return '/';
    print(currentRoute);
    print(state.matchedLocation);
    print("----------");
    if (loggedIn && currentRoute != state.matchedLocation) {
      resetCurrentRoute();
      return "/";
    }
    return null;
  },
  routes: [
    GoRoute(
      path: "/",
      pageBuilder: (context, state) {
        return NoTransitionPage(child: UserScanListPage());
      },
    ),
    GoRoute(
      name: "scan",
      path: "/scan",
      pageBuilder: (context, state) {
        return NoTransitionPage(child: ScanQrPage());
      },
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: "/doc-detail",
      pageBuilder: (context, state) {
        var data = state.extra as Map<String, dynamic>?;
        return NoTransitionPage(
          child: QrDetailPage(
            code: data?['code'] ?? "",
            isViewOnly: data?['isViewOnly'] == "1",
          ),
        );
      },
      /*redirect: (context, state) {
        var data = state.extra as Map<String, dynamic>?;
        var noCode = data?["code"]?.toString().isNotEmpty != true;
        if (noCode) return "/";
        return null;
      },*/
    ),
    GoRoute(
      path: "/doc-verify",
      pageBuilder: (context, state) {
        var data = state.extra as Map<String, dynamic>?;
        return NoTransitionPage(
          child: VerifyDocPage(
            qrCodeContent: data?['code'] ?? "",
            docId: data?["docId"] ?? "",
          ),
        );
      },
      /*redirect: (context, state) {
        var data = state.extra as Map<String, dynamic>?;
        var noCode = data?["code"]?.toString().isNotEmpty != true;
        if (noCode) return "/";
        var noDocId = data?["docId"]?.toString().isNotEmpty != true;
        if (noDocId) return "/";
        return null;
      },*/
    ),
  ],
);
