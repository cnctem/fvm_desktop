import 'package:flutter/material.dart';
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
  String _filePath = '';
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
        _filePath = fileInfo['path'] ?? 'Unknown';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Syntax validation failed. Please check your configuration.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await ZshrcManager.writeZshrc(content);
      
      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('.zshrc file saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save .zshrc file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left half - Text Editor
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
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
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
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
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
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
          // Right half - Preview/Info Panel (placeholder for now)
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal,
                      size: 64,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terminal Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit your .zshrc file on the left',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File Information',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Path:', _filePath.isEmpty ? 'Loading...' : _filePath),
                            _buildInfoRow('Size:', _fileInfo['size'] ?? 'Unknown'),
                            _buildInfoRow('Last Modified:', _fileInfo['lastModified'] ?? 'Unknown'),
                            _buildInfoRow('Status:', _fileInfo['exists'] == 'true' ? 'Exists' : 'Not Found'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}