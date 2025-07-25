import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_driver/screens/profile_screen.dart';
import 'package:calltaxi_mobile_driver/screens/vehicle_screen_list.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title});
  final Widget child;
  final String title;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      // Logout
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return ProfileScreen();
      case 1:
        return VehicleScreenList();
      default:
        return ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
