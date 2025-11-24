class CommandConfig {
  final String title;
  final String content;
  final String? description;

  const CommandConfig({
    required this.title,
    required this.content,
    this.description,
  });
}

class CommandsText {
  static const List<CommandConfig> zshrcCommands = [
    CommandConfig(
      title: '环境路径',
      content: 'export PATH="\$HOME/fvm/default/bin:\$PATH"',
      description: 'Add FVM to PATH environment variable',
    ),
    CommandConfig(
      title: '官方Git源',
      content: 'export FLUTTER_GIT_URL=https://github.com/flutter/flutter.git',
      description: 'Official Flutter Git repository',
    ),
    CommandConfig(
      title: '镜像Git源',
      content: 'export FLUTTER_GIT_URL=https://mirrors.tuna.tsinghua.edu.cn/git/flutter-sdk.git',
      description: 'Tsinghua mirror for Flutter Git repository',
    ),
    CommandConfig(
      title: '依赖镜像',
      content: 'export PUB_HOSTED_URL=https://pub.flutter-io.cn\nexport FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn',
      description: 'Flutter dependency mirrors for China',
    ),
    CommandConfig(
      title: '鸿蒙Git源',
      content: 'export FLUTTER_GIT_URL=https://gitcode.com/openharmony-tpc/flutter_flutter.git',
      description: 'OpenHarmony Flutter Git repository',
    ),
    CommandConfig(
      title: 'HarmonyOS SDK & Other Environment',
      content: 'export DEVECO_SDK_HOME=\$TOOL_HOME/sdk # command-line-tools/sdk\nexport PATH=\$TOOL_HOME/tools/ohpm/bin:\$PATH # command-line-tools/ohpm/bin\nexport PATH=\$TOOL_HOME/tools/hvigor/bin:\$PATH # command-line-tools/hvigor/bin\nexport PATH=\$TOOL_HOME/tools/node/bin:\$PATH # command-line-tools/tool/node/bin',
      description: 'HarmonyOS SDK and development tools environment setup',
    ),
  ];

  // 获取所有Flutter相关命令
  static List<CommandConfig> get flutterCommands => zshrcCommands.where((cmd) => 
    cmd.title.contains('Git源') || cmd.title.contains('依赖镜像')).toList();
  
  static List<CommandConfig> get harmonyCommands => zshrcCommands.where((cmd) => 
    cmd.title.contains('鸿蒙') || cmd.title.contains('HarmonyOS')).toList();
  
  static List<CommandConfig> get pathCommands => zshrcCommands.where((cmd) => 
    cmd.title.contains('路径')).toList();
}