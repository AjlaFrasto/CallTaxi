import 'dart:io';

class NetworkUtils {
  /// Get the appropriate base URL based on the platform
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      // For physical devices, use your computer's actual IP address
      // Found from ipconfig: 192.168.1.106
      //return "http://192.168.1.106:5130/";

      // For emulator testing, you can temporarily change this to:
      return "http://10.0.2.2:5130/";
    } else {
      return "http://localhost:5130/";
    }
  }

  /// Instructions for setting up network access on physical devices
  static String getNetworkSetupInstructions() {
    return '''
To connect your physical device to your development server:

1. Find your computer's IP address:
   - Windows: Open Command Prompt and type 'ipconfig'
   - Mac/Linux: Open Terminal and type 'ifconfig' or 'ip addr'
   - Look for your local network IP (usually 192.168.x.x or 10.0.x.x)

2. Make sure both your phone and computer are on the same WiFi network

3. Update the base URL in lib/providers/base_provider.dart:
   - Replace 'YOUR_COMPUTER_IP' with your actual IP address
   - Example: "http://192.168.1.100:5130/"

4. Ensure your backend server is configured to accept connections from all interfaces:
   - For ASP.NET Core, make sure it's listening on 0.0.0.0:5130
   - Check your firewall settings

5. Test the connection by opening http://YOUR_COMPUTER_IP:5130 in your phone's browser
''';
  }
}
