import 'dart:io';
import 'package:path/path.dart' as path;

class FilePermissions {
  static const String _zshrcPath = '~/.zshrc';
  
  static Future<String> getZshrcPath() async {
    print('DEBUG: Platform.environment[HOME] = ${Platform.environment['HOME']}');
    
    // Try to get the real user home directory
    String? homeDir;
    
    // Method 1: Check if we're in a sandboxed environment and try to get the real home
    if (Platform.isMacOS) {
      // Try to get the real user home from environment variables
      homeDir = Platform.environment['HOME'];
      
      // If we're in a sandbox, the HOME might point to a container
      // Try to get the real user home from other sources
      if (homeDir != null && homeDir.contains('Containers')) {
        // Try to get the real user home from USER or LOGNAME
        final user = Platform.environment['USER'] ?? Platform.environment['LOGNAME'];
        if (user != null) {
          final realHome = '/Users/$user';
          print('DEBUG: Detected sandbox environment, trying real home: $realHome');
          
          // Check if this path exists
          final realHomeDir = Directory(realHome);
          if (await realHomeDir.exists()) {
            homeDir = realHome;
            print('DEBUG: Using real home directory: $homeDir');
          }
        }
      }
    } else {
      // For non-macOS platforms, use standard HOME
      homeDir = Platform.environment['HOME'];
    }
    
    if (homeDir == null) {
      print('DEBUG: HOME environment variable is null!');
      throw Exception('Could not determine home directory');
    }
    
    final result = path.join(homeDir, '.zshrc');
    print('DEBUG: Constructed .zshrc path: $result');
    return result;
  }
  
  static Future<bool> canReadFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() && await file.readAsString().then((_) => true).catchError((_) => false);
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> canWriteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return true; // Can create new file
      }
      
      final stat = await file.stat();
      final currentUser = Platform.environment['USER'];
      
      // Simple permission check - in real app, you'd want more sophisticated checks
      return stat.modeString().contains('w');
    } catch (e) {
      return false;
    }
  }
  
  static Future<String?> requestFileAccess() async {
    try {
      final zshrcPath = await getZshrcPath();
      final file = File(zshrcPath);
      
      if (!await file.exists()) {
        await file.create();
        return zshrcPath;
      }
      
      return zshrcPath;
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> backupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return true; // No need to backup non-existent file
      }
      
      final backupPath = '$filePath.backup.${DateTime.now().millisecondsSinceEpoch}';
      await file.copy(backupPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}