import 'package:flutter/material.dart';

import 'collections/collections_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';
import 'upload/upload_screen.dart';

class WallverseShell extends StatefulWidget {
  const WallverseShell({super.key});

  @override
  State<WallverseShell> createState() => _WallverseShellState();
}

class _WallverseShellState extends State<WallverseShell> {
  var _index = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    UploadScreen(),
    CollectionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark_rounded), label: 'Collections'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
