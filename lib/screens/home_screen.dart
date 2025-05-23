import 'package:flutter/material.dart';
import 'package:workgest/screens/material_screen.dart';
import 'package:workgest/widgets/dashboard_card.dart'; // Assuming you have this widget
import 'package:workgest/widgets/action_button.dart'; // Assuming you have this widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/widgets/notification_tile.dart'; // Assuming you have this widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // App Logo
            Image.asset(
              'assets/images/logo.png', // Adjust path if necessary
              height: AppBar().preferredSize.height * 0.8,
            ),
            const SizedBox(width: 8.0), // Spacing between logo and title
            Text(
              'Workgest', // Replace with your app name
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          // Profile Avatar
          IconButton(
            icon: CircleAvatar(
              // You might want to display the user's actual avatar here
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            tooltip: 'Profile',
            onPressed: () {
              // Navigate to the profile screen
              Navigator.pushNamed(context, '/userProfile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // Example Notification Tile
                const NotificationTile(
                  title: 'New Message',
                  message: 'You have a new message from the admin.',
                ),
                const SizedBox(height: 16.0),

                // Example Dashboard Cards
                DashboardCard(
                  title: 'View Weather',
                  icon: Icons.cloud,
                  onTap: () {
                    Navigator.pushNamed(context, '/weather'); // Example route
                  },
                ),
                const SizedBox(height: 16.0),
                DashboardCard(
                    title: 'Manage Materials',
                    icon: Icons.inventory,
                    onTap: () {
                      if (user != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MaterialScreen(user),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in')),
                        );
                      }
                    },
                ),
                const SizedBox(height: 16.0),
                DashboardCard(
                  title: 'View Schedule',
                  icon: Icons.calendar_today,
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.pushNamed(context, '/schedule', arguments: user);
                    } else {
                      // Handle the case where the user is not logged in
                    }
                  },
                ),
                const SizedBox(height: 16.0),

                // Example Action Buttons
                ActionButton(
                  label: 'View Users',
                  icon: Icons.group,
                  onPressed: () {
                    Navigator.pushNamed(context, '/userList'); // Example route
                  },
                ),
                const SizedBox(height: 16.0),
                ActionButton(
                  label: 'Register Camper',
                  icon: Icons.person_add,
                  onPressed: () {
                    Navigator.pushNamed(context, '/summerCamperRegistration'); // Example route
                  },
                ),
                const SizedBox(height: 16.0),
                ActionButton(
                  label: 'Manage Users',
                  icon: Icons.manage_accounts,
                  onPressed: () {
                    // You might need to pass arguments for this route
                    // Navigator.pushNamed(context, '/userManage', arguments: currentUser);
                  },
                ),
                const SizedBox(height: 16.0),

                // Add more widgets as needed based on your app's functionality
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // To ensure all labels are visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        //currentIndex: _selectedIndex, // You would manage the selected index in a StatefulWidget
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        // onTap: _onItemTapped, // You would handle navigation here
      ),
    );
  }
}