import 'dart:io';
import 'dart:convert';
import 'dart:async';

/// ZShell command execution utility
class ZShellExecutor {
  static const String _defaultShell = '/bin/zsh';
  
  /// Execute a single command in zshell
  static Future<ZShellResult> executeCommand(String command, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    StreamController<String>? stdoutController;
    StreamController<String>? stderrController;
    StreamSubscription<String>? stdoutSubscription;
    StreamSubscription<String>? stderrSubscription;

    try {
      final process = await Process.start(
        _defaultShell,
        ['-i', '-c', command],
        workingDirectory: workingDirectory,
        environment: environment,
        runInShell: true,
      );

      stdoutController = StreamController<String>.broadcast();
      stderrController = StreamController<String>.broadcast();
      
      stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stdoutController.add);
          
      stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stderrController.add);

      final exitCode = await process.exitCode.timeout(timeout);
      
      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();
      
      final stdoutOutput = await stdoutController.stream.join('\n');
      final stderrOutput = await stderrController.stream.join('\n');
      
      await stdoutController.close();
      await stderrController.close();
      
      return ZShellResult(
        exitCode: exitCode,
        stdout: stdoutOutput,
        stderr: stderrOutput,
        command: command,
      );
    } on TimeoutException catch (_) {
      // Ensure all streams are properly closed on timeout
      await stdoutSubscription?.cancel();
      await stderrSubscription?.cancel();
      await stdoutController?.close();
      await stderrController?.close();
      
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command timed out after ${timeout.inSeconds} seconds',
        command: command,
      );
    } on ProcessException catch (e) {
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Failed to execute command: ${e.message}',
        command: command,
      );
    } catch (e) {
      // Ensure all streams are properly closed on error
      await stdoutSubscription?.cancel();
      await stderrSubscription?.cancel();
      await stdoutController?.close();
      await stderrController?.close();
      
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Unexpected error: $e',
        command: command,
      );
    }
  }

  /// Execute multiple commands in sequence
  static Future<List<ZShellResult>> executeCommands(
    List<String> commands, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final results = <ZShellResult>[];
    
    for (final command in commands) {
      final result = await executeCommand(
        command,
        workingDirectory: workingDirectory,
        environment: environment,
        timeout: timeout,
      );
      results.add(result);
      
      // Stop execution if a command fails
      if (result.exitCode != 0) {
        break;
      }
    }
    
    return results;
  }

  /// Check if zshell is available on the system
  static Future<bool> isZShellAvailable() async {
    try {
      final result = await executeCommand('which zsh');
      return result.exitCode == 0 && result.stdout.trim().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the zshell version
  static Future<String> getZShellVersion() async {
    try {
      final result = await executeCommand('zsh --version');
      if (result.exitCode == 0) {
        return result.stdout.trim();
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Execute a command with elevated privileges (requires sudo)
  static Future<ZShellResult> executeWithSudo(
    String command, {
    String? password,
    String? workingDirectory,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final sudoCommand = 'sudo -S $command';
    StreamController<String>? stdoutController;
    StreamController<String>? stderrController;
    StreamSubscription<String>? stdoutSubscription;
    StreamSubscription<String>? stderrSubscription;
    
    try {
      final process = await Process.start(
        _defaultShell,
        ['-i', '-c', sudoCommand],
        workingDirectory: workingDirectory,
        runInShell: true,
      );

      // Send password if provided
      if (password != null) {
        process.stdin.writeln(password);
      }

      stdoutController = StreamController<String>.broadcast();
      stderrController = StreamController<String>.broadcast();
      
      stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stdoutController.add);
          
      stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stderrController.add);

      final exitCode = await process.exitCode.timeout(timeout);
      
      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();
      
      final stdoutOutput = await stdoutController.stream.join('\n');
      final stderrOutput = await stderrController.stream.join('\n');
      
      await stdoutController.close();
      await stderrController.close();
      
      return ZShellResult(
        exitCode: exitCode,
        stdout: stdoutOutput,
        stderr: stderrOutput,
        command: sudoCommand,
      );
    } on ProcessException catch (e) {
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Failed to execute sudo command: ${e.message}',
        command: sudoCommand,
      );
    } on TimeoutException catch (_) {
      // Ensure all streams are properly closed on timeout
      await stdoutSubscription?.cancel();
      await stderrSubscription?.cancel();
      await stdoutController?.close();
      await stderrController?.close();
      
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Command timed out after ${timeout.inSeconds} seconds',
        command: sudoCommand,
      );
    } catch (e) {
      // Ensure all streams are properly closed on error
      await stdoutSubscription?.cancel();
      await stderrSubscription?.cancel();
      await stdoutController?.close();
      await stderrController?.close();
      
      return ZShellResult(
        exitCode: -1,
        stdout: '',
        stderr: 'Unexpected error with sudo: $e',
        command: sudoCommand,
      );
    }
  }
}

/// Result of a zshell command execution
class ZShellResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final String command;

  ZShellResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.command,
  });

  /// Check if the command was successful
  bool get isSuccess => exitCode == 0;

  /// Check if the command failed
  bool get isFailure => exitCode != 0;

  /// Get the full output (stdout + stderr)
  String get fullOutput {
    final buffer = StringBuffer();
    if (stdout.isNotEmpty) {
      buffer.writeln(stdout);
    }
    if (stderr.isNotEmpty) {
      buffer.writeln(stderr);
    }
    return buffer.toString().trim();
  }

  @override
  String toString() {
    return 'ZShellResult(exitCode: $exitCode, command: "$command")';
  }
}