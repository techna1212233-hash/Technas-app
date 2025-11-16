import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/videos_screen.dart';
import 'screens/listing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: TechnaApp(),
    ),
  );
}

class TechnaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TECHNA',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainTabs(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int currentIndex = 0;
  final pages = [
    HomeScreen(),
    ReferralScreen(),
    WalletScreen(),
    VideosScreen(),
    ListingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Mine'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Referral'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listing'),
        ],
        onTap: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}