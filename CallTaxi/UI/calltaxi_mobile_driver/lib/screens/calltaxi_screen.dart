import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_driver/model/driver_request.dart';
import 'package:calltaxi_mobile_driver/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CallTaxiScreen extends StatefulWidget {
  final Function(int)? onTabChanged;

  const CallTaxiScreen({Key? key, this.onTabChanged}) : super(key: key);

  @override
  State<CallTaxiScreen> createState() => _CallTaxiScreenState();
}

class _CallTaxiScreenState extends State<CallTaxiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  DriverRequest? _currentDrive;
  late DriverRequestProvider driverRequestProvider;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      driverRequestProvider = Provider.of<DriverRequestProvider>(
        context,
        listen: false,
      );
      await _checkCurrentDrive();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for current drives when the screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkCurrentDrive();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentDrive() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
     // Check for accepted drives first
      final acceptedResult = await driverRequestProvider.get(
        filter: {
          "driverId": UserProvider.currentUser!.id,
          "status": "Accepted",
          "page": 0,
          "pageSize": 1,
        },
      );

      // Check for paid drives
      final paidResult = await driverRequestProvider.get(
        filter: {
          "driverId": UserProvider.currentUser!.id,
          "status": "Paid",
          "page": 0,
          "pageSize": 1,
        },
      );

      // Prioritize paid drives over accepted drives
      if (paidResult.items != null && paidResult.items!.isNotEmpty) {
        setState(() {
          _currentDrive = paidResult.items!.first;
          _isLoading = false;
        });
      } else if (acceptedResult.items != null &&
          acceptedResult.items!.isNotEmpty) {
        setState(() {
          _currentDrive = acceptedResult.items!.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentDrive = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking current drive: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completeDrive() async {
    if (_currentDrive == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await driverRequestProvider.complete(_currentDrive!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Drive completed successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the screen
      await _checkCurrentDrive();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to complete drive: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFindDrivePressed() {
    // Use the callback to switch to the drives list tab (index 3)
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(3); // Switch to DrivesListScreen tab
    } else {
      // Fallback: show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Go to the "Drives" tab to see available drives'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  // State 1: Find Drive Screen (no active drive)
  Widget _buildFindDriveScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await _checkCurrentDrive();
      },
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Find Me a Drive',
                        style: TextStyle(
                          color: Color(0xFFFF6F00),
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap below to find available drives in your area.',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28),
                      Center(
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return GestureDetector(
                                  onTap: _onFindDrivePressed,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 4,
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF8C00),
                                          Color(0xFFFFA726),
                                          Color(0xFFFFCC80),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFFFF8C00,
                                          ).withOpacity(0.3),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Transform.scale(
                                        scale:
                                            1.0 + 0.3 * _scaleAnimation.value,
                                        child: Icon(
                                          Icons.search,
                                          size: 65,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 18),
                            Text(
                              'Find Drive',
                              style: TextStyle(
                                color: Color(0xFFFF6F00),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // State 2: Drive In Progress Screen (status Accepted = 2)
  Widget _buildDriveInProgressScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await _checkCurrentDrive();
      },
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Drive In Progress',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You are currently on a drive.',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28),
                      // Animated taxi icon
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: () {}, // No action needed
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Color(0xFF42A5F5),
                                    Color(0xFF64B5F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scale: 1.0 + 0.2 * _scaleAnimation.value,
                                  child: Icon(
                                    Icons.local_taxi,
                                    size: 65,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32),
                      // Client info section
                      if (_currentDrive != null) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Client Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _currentDrive!.userFullName ?? 'Unknown Client',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Payment Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${_currentDrive!.finalPrice.toStringAsFixed(2)} KM',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Waiting for client payment',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // State 3: Complete Drive Screen (status Paid = 5)
  Widget _buildCompleteDriveScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await _checkCurrentDrive();
      },
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Payment Received',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The client has paid for the drive.',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28),
                      // Animated payment icon
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: () {}, // No action needed
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Color(0xFF66BB6A),
                                    Color(0xFF81C784),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scale: 1.0 + 0.2 * _scaleAnimation.value,
                                  child: Icon(
                                    Icons.payment,
                                    size: 65,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 32),
                      // Client info section
                      if (_currentDrive != null) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Client Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _currentDrive!.userFullName ?? 'Unknown Client',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Payment Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${_currentDrive!.finalPrice.toStringAsFixed(2)} KM',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Payment received successfully',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _completeDrive,
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Completing...' : 'Complete Drive',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine which screen to show based on current drive status
    if (_currentDrive == null) {
      // No active drive - show Find Drive screen
      return _buildFindDriveScreen();
    } else if (_currentDrive!.statusName?.toLowerCase() == 'accepted') {
      // Drive is accepted but not paid - show Drive In Progress screen
      return _buildDriveInProgressScreen();
    } else if (_currentDrive!.statusName?.toLowerCase() == 'paid') {
      // Drive is paid - show Complete Drive screen
      return _buildCompleteDriveScreen();
    } else {
      // Fallback to Find Drive screen
      return _buildFindDriveScreen();
    }
  }
}
