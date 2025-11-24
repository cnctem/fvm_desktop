import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fvm_desktop/utils/zshrc/zshrc_manager.dart';
import 'package:fvm_desktop/utils/zshrc/zshrc_text_field.dart';

class ZshrcPage extends StatefulWidget {
  const ZshrcPage({super.key});

  @override
  State<ZshrcPage> createState() => _ZshrcPageState();
}

class _ZshrcPageState extends State<ZshrcPage> {
  final ZshrcTextEditingController _controller = ZshrcTextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasChanges = false;
  Map<String, String> _fileInfo = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadZshrc();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadZshrc() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final content = await ZshrcManager.readZshrc();
      final fileInfo = await ZshrcManager.getZshrcInfo();

      setState(() {
        _controller.text = content;
        _fileInfo = fileInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load .zshrc file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveZshrc() async {
    try {
      final content = _controller.text;
      
      // Validate syntax before saving
      final isValid = await ZshrcManager.validateZshrcSyntax(content);
      if (!isValid) {
        SmartDialog.showToast('Syntax validation failed. Please check your configuration.');
        return;
      }

      await ZshrcManager.writeZshrc(content);
      
      setState(() {
        _hasChanges = false;
      });

      SmartDialog.showToast('.zshrc file saved successfully!');
    } catch (e) {
      SmartDialog.showToast('Failed to save .zshrc file: $e');
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Widget _buildCopyButton({
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _copyToClipboard(content, title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.replaceAll('\n', ' ').length > 50
                          ? '${content.replaceAll('\n', ' ').substring(0, 50)}...'
                          : content.replaceAll('\n', ' '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.content_copy, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String content, String title) {
    Clipboard.setData(ClipboardData(text: content));
    SmartDialog.showToast('Copied "$title" to clipboard',);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Text Editor (70% width)
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Editor Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Editor',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status indicator dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _errorMessage != null && (_errorMessage!.contains('Permission denied') || _errorMessage!.contains('Operation not permitted'))
                                ? Colors.red 
                                : _hasChanges 
                                    ? Colors.orange 
                                    : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        if (_hasChanges)
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: _saveZshrc,
                            tooltip: 'Save Changes',
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadZshrc,
                          tooltip: 'Reload File',
                        ),
                      ],
                    ),
                  ),
                  // Editor Content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorMessage!,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loadZshrc,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 800, // Fixed width to prevent wrapping
                                  child: ZshrcTextField(
                                    controller: _controller,
                                    scrollController: _scrollController,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your .zshrc configuration...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                    onChanged: (_) => _onTextChanged(),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    strutStyle: const StrutStyle(
                                      forceStrutHeight: true,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  // Editor Footer
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _fileInfo['exists'] == 'true' ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: _fileInfo['exists'] == 'true' ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fileInfo['exists'] == 'true' 
                              ? 'File exists (${_fileInfo['size']} bytes)' 
                              : 'File not found',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          'Lines: ${_controller.text.split('\n').length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Quick Copy Buttons (30% width)
          Expanded(
            flex: 3,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.content_copy, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Copy',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content - Scrollable list of copy buttons
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCopyButton(
                            title: '环境路径',
                            content: 'export PATH="\$HOME/fvm/default/bin:\$PATH"',
                          ),
                          const SizedBox(height: 12),
                          _buildCopyButton(
                            title: '官方Git源',
                            content: 'export FLUTTER_GIT_URL=https://github.com/flutter/flutter.git',
                          ),
                          const SizedBox(height: 12),
                          _buildCopyButton(
                            title: '镜像Git源',
                            content: 'export FLUTTER_GIT_URL=https://mirrors.tuna.tsinghua.edu.cn/git/flutter-sdk.git',
                          ),
                          const SizedBox(height: 12),
                          _buildCopyButton(
                            title: '依赖镜像',
                            content: 'export PUB_HOSTED_URL=https://pub.flutter-io.cn\nexport FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn',
                          ),
                          const SizedBox(height: 12),
                          _buildCopyButton(
                            title: '鸿蒙Git源',
                            content: 'export FLUTTER_GIT_URL=https://gitcode.com/openharmony-tpc/flutter_flutter.git',
                          ),
                          const SizedBox(height: 12),
                          _buildCopyButton(
                            title: 'HarmonyOS SDK & Other Environment',
                            content: 'export DEVECO_SDK_HOME=\$TOOL_HOME/sdk # command-line-tools/sdk\nexport PATH=\$TOOL_HOME/tools/ohpm/bin:\$PATH # command-line-tools/ohpm/bin\nexport PATH=\$TOOL_HOME/tools/hvigor/bin:\$PATH # command-line-tools/hvigor/bin\nexport PATH=\$TOOL_HOME/tools/node/bin:\$PATH # command-line-tools/tool/node/bin',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}