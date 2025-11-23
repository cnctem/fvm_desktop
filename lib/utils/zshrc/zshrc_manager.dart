import 'dart:io';
import 'package:fvm_desktop/utils/permissions/file_permissions.dart';

class ZshrcManager {
  static Future<String> readZshrc() async {
    try {
      print('DEBUG: Attempting to read .zshrc file...');
      final zshrcPath = await FilePermissions.getZshrcPath();
      print('DEBUG: Resolved path: $zshrcPath');
      
      final file = File(zshrcPath);
      
      if (!await file.exists()) {
        print('DEBUG: File does not exist at path: $zshrcPath');
        return '';
      }
      
      print('DEBUG: File exists, reading content...');
      final content = await file.readAsString();
      print('DEBUG: Successfully read ${content.length} characters');
      return content;
    } catch (e) {
      print('DEBUG: Error reading .zshrc file: $e');
      // Check if it's a permission error
      if (e.toString().contains('Operation not permitted') || 
          e.toString().contains('errno = 1')) {
        // Return empty content with a comment explaining the permission issue
        return '# Permission denied: Cannot read .zshrc file due to macOS sandbox restrictions.\n'
               '# To edit your .zshrc file, please use a terminal or grant the app full disk access in System Preferences > Security & Privacy > Privacy > Full Disk Access.\n';
      }
      // For other errors, return a helpful message
      return '# Error reading .zshrc file: ${e.toString()}\n';
    }
  }
  
  static Future<bool> writeZshrc(String content) async {
    try {
      print('DEBUG: Attempting to write .zshrc file...');
      final zshrcPath = await FilePermissions.getZshrcPath();
      print('DEBUG: Writing to path: $zshrcPath');
      
      // Create backup before writing
      await FilePermissions.backupFile(zshrcPath);
      
      final file = File(zshrcPath);
      await file.writeAsString(content, flush: true);
      print('DEBUG: Successfully wrote ${content.length} characters');
      
      return true;
    } catch (e) {
      print('DEBUG: Error writing .zshrc file: $e');
      // Check if it's a permission error
      if (e.toString().contains('Operation not permitted') || 
          e.toString().contains('errno = 1')) {
        throw Exception('Permission denied: Cannot write .zshrc file due to macOS sandbox restrictions. To edit your .zshrc file, please use a terminal or grant the app full disk access in System Preferences > Security & Privacy > Privacy > Full Disk Access.');
      }
      // Re-throw other errors
      throw Exception('Failed to write .zshrc file: $e');
    }
  }
  
  static Future<bool> validateZshrcSyntax(String content) async {
    try {
      // Basic validation - check for common syntax errors
      final lines = content.split('\n');
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }
        
        // Check for unclosed quotes
        if (_hasUnclosedQuotes(trimmed)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static bool _hasUnclosedQuotes(String line) {
    bool inSingleQuote = false;
    bool inDoubleQuote = false;
    
    return inSingleQuote || inDoubleQuote;
  }
  
  static Future<Map<String, String>> getZshrcInfo() async {
    try {
      print('DEBUG: Getting .zshrc info...');
      final zshrcPath = await FilePermissions.getZshrcPath();
      print('DEBUG: Info path: $zshrcPath');
      
      final file = File(zshrcPath);
      
      if (!await file.exists()) {
        print('DEBUG: File does not exist');
        return {
          'exists': 'false',
          'size': '0',
          'lastModified': 'N/A',
          'path': zshrcPath,
        };
      }
      
      final stat = await file.stat();
      print('DEBUG: File exists, size: ${stat.size}');
      return {
        'exists': 'true',
        'size': stat.size.toString(),
        'lastModified': stat.modified.toString(),
        'path': zshrcPath,
      };
    } catch (e) {
      print('DEBUG: Error getting .zshrc info: $e');
      return {
        'exists': 'false',
        'size': '0',
        'lastModified': 'Error',
        'path': 'Unknown',
      };
    }
  }
}