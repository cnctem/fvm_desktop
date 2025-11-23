import 'dart:io';
import 'zshell_executor.dart';

/// Helper class for common zshell operations
class ZShellHelpers {
  /// Get the current user's home directory
  static String get homeDirectory {
    return Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '~';
  }

  /// Get the current working directory
  static Future<String> getCurrentDirectory() async {
    final result = await ZShellExecutor.executeCommand('pwd');
    if (result.isSuccess) {
      return result.stdout.trim();
    }
    return Directory.current.path;
  }

  /// Change directory
  static Future<ZShellResult> changeDirectory(String path) async {
    return await ZShellExecutor.executeCommand('cd "$path" && pwd');
  }

  /// List files and directories
  static Future<ZShellResult> listDirectory(String path, {bool showHidden = false}) async {
    final flags = showHidden ? '-la' : '-l';
    return await ZShellExecutor.executeCommand('ls $flags "$path"');
  }

  /// Check if a file or directory exists
  static Future<bool> exists(String path) async {
    final result = await ZShellExecutor.executeCommand('test -e "$path"');
    return result.isSuccess;
  }

  /// Check if a path is a file
  static Future<bool> isFile(String path) async {
    final result = await ZShellExecutor.executeCommand('test -f "$path"');
    return result.isSuccess;
  }

  /// Check if a path is a directory
  static Future<bool> isDirectory(String path) async {
    final result = await ZShellExecutor.executeCommand('test -d "$path"');
    return result.isSuccess;
  }

  /// Create a directory
  static Future<ZShellResult> createDirectory(String path, {bool recursive = false}) async {
    final flags = recursive ? '-p' : '';
    return await ZShellExecutor.executeCommand('mkdir $flags "$path"');
  }

  /// Remove a file or directory
  static Future<ZShellResult> remove(String path, {bool recursive = false}) async {
    final command = recursive ? 'rm -rf "$path"' : 'rm -f "$path"';
    return await ZShellExecutor.executeCommand(command);
  }

  /// Copy files or directories
  static Future<ZShellResult> copy(String source, String destination, {bool recursive = false}) async {
    final flags = recursive ? '-r' : '';
    return await ZShellExecutor.executeCommand('cp $flags "$source" "$destination"');
  }

  /// Move files or directories
  static Future<ZShellResult> move(String source, String destination) async {
    return await ZShellExecutor.executeCommand('mv "$source" "$destination"');
  }

  /// Get file permissions
  static Future<String> getPermissions(String path) async {
    final result = await ZShellExecutor.executeCommand('ls -la "$path" | awk \'{print \$1}\'');
    if (result.isSuccess) {
      return result.stdout.trim();
    }
    return '';
  }

  /// Set file permissions
  static Future<ZShellResult> setPermissions(String path, String permissions) async {
    return await ZShellExecutor.executeCommand('chmod $permissions "$path"');
  }

  /// Get file owner
  static Future<String> getOwner(String path) async {
    final result = await ZShellExecutor.executeCommand('ls -la "$path" | awk \'{print \$3}\'');
    if (result.isSuccess) {
      return result.stdout.trim();
    }
    return '';
  }

  /// Get file size
  static Future<int> getFileSize(String path) async {
    final result = await ZShellExecutor.executeCommand('stat -f%z "$path" 2>/dev/null || stat -c%s "$path" 2>/dev/null');
    if (result.isSuccess) {
      return int.tryParse(result.stdout.trim()) ?? 0;
    }
    return 0;
  }

  /// Get file modification time
  static Future<DateTime?> getModificationTime(String path) async {
    final result = await ZShellExecutor.executeCommand('stat -f%m "$path" 2>/dev/null || stat -c%Y "$path" 2>/dev/null');
    if (result.isSuccess) {
      final timestamp = int.tryParse(result.stdout.trim());
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }
    return null;
  }

  /// Find files matching a pattern
  static Future<List<String>> findFiles(String pattern, {String? directory}) async {
    final searchDir = directory ?? '.';
    final result = await ZShellExecutor.executeCommand('find "$searchDir" -name "$pattern" -type f');
    
    if (result.isSuccess && result.stdout.isNotEmpty) {
      return result.stdout.trim().split('\n').where((line) => line.isNotEmpty).toList();
    }
    return [];
  }

  /// Search for text in files
  static Future<List<String>> searchInFiles(String pattern, {String? directory, String? filePattern}) async {
    final searchDir = directory ?? '.';
    final fileFilter = filePattern != null ? '--include="$filePattern"' : '';
    final result = await ZShellExecutor.executeCommand('grep -r "$pattern" $fileFilter "$searchDir"');
    
    if (result.isSuccess && result.stdout.isNotEmpty) {
      return result.stdout.trim().split('\n').where((line) => line.isNotEmpty).toList();
    }
    return [];
  }

  /// Get environment variables
  static Future<Map<String, String>> getEnvironmentVariables() async {
    final result = await ZShellExecutor.executeCommand('env');
    final env = <String, String>{};
    
    if (result.isSuccess && result.stdout.isNotEmpty) {
      final lines = result.stdout.trim().split('\n');
      for (final line in lines) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          env[parts[0]] = parts.sublist(1).join('=');
        }
      }
    }
    
    return env;
  }

  /// Get a specific environment variable
  static Future<String?> getEnvironmentVariable(String name) async {
    final result = await ZShellExecutor.executeCommand('echo \$$name');
    if (result.isSuccess) {
      final value = result.stdout.trim();
      return value.isEmpty ? null : value;
    }
    return null;
  }

  /// Check if a command is available
  static Future<bool> isCommandAvailable(String command) async {
    final result = await ZShellExecutor.executeCommand('which $command');
    return result.isSuccess && result.stdout.trim().isNotEmpty;
  }

  /// Get the version of a command
  static Future<String?> getCommandVersion(String command) async {
    // Try common version flags
    final versionFlags = ['--version', '-v', '-version'];
    
    for (final flag in versionFlags) {
      final result = await ZShellExecutor.executeCommand('$command $flag');
      if (result.isSuccess && result.stdout.trim().isNotEmpty) {
        return result.stdout.trim();
      }
    }
    
    return null;
  }
}