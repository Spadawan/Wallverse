import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const ListView(
        children: [
          ListTile(
            leading: Icon(Icons.check_circle_outline_rounded),
            title: Text('Upload approved'),
            subtitle: Text('Your wallpaper is now public.'),
          ),
          ListTile(
            leading: Icon(Icons.favorite_border_rounded),
            title: Text('New like'),
            subtitle: Text('@pixelmage liked your wallpaper.'),
          ),
        ],
      ),
    );
  }
}
