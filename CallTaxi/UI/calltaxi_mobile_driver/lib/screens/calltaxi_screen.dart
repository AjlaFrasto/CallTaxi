import 'package:flutter/material.dart';

class CallTaxiScreen extends StatefulWidget {
  const CallTaxiScreen({Key? key}) : super(key: key);

  @override
  State<CallTaxiScreen> createState() => _CallTaxiScreenState();
}

class _CallTaxiScreenState extends State<CallTaxiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Slower for smoother pulsing
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smoother curve for up and down motion
    );
    _controller.repeat(reverse: true); // This creates the up and down motion
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFindDrivePressed() {
    setState(() {
      _showForm = true;
    });
    // For now, do nothing on click as requested
  }

  Widget _buildModernFindDriveCard() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic will be added later
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
                      // Spinning animated circular button
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
                                            1.0 +
                                            0.3 *
                                                _scaleAnimation
                                                    .value, // More pronounced pulsing
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

  Widget _buildForm() {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _showForm = false;
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _showForm = false;
                });
              },
              tooltip: 'Close',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 20),
                Text(
                  'Drive Search',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This feature will be implemented soon.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showForm = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: Size(double.infinity, 48),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.black12, width: 1.2),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  child: Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _buildForm();
    }
    return _buildModernFindDriveCard();
  }
} 