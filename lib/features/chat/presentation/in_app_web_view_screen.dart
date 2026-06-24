import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_theme.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _currentTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title ?? widget.url;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageFinished: (url) async {
            final title = await _controller.getTitle();
            final canGoBack = await _controller.canGoBack();
            final canGoForward = await _controller.canGoForward();
            setState(() {
              _isLoading = false;
              if (title != null && title.isNotEmpty) {
                _currentTitle = title;
              }
              _canGoBack = canGoBack;
              _canGoForward = canGoForward;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Đóng',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              Uri.tryParse(widget.url)?.host ?? widget.url,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () => _controller.reload(),
            tooltip: 'Tải lại',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading
              ? LinearProgressIndicator(
                  value: _loadingProgress > 0 ? _loadingProgress : null,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 2,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: WebViewWidget(controller: _controller),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 20,
                    color: _canGoBack
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                  onPressed: _canGoBack
                      ? () async {
                          await _controller.goBack();
                          final canGoBack = await _controller.canGoBack();
                          final canGoForward = await _controller.canGoForward();
                          setState(() {
                            _canGoBack = canGoBack;
                            _canGoForward = canGoForward;
                          });
                        }
                      : null,
                  tooltip: 'Quay lại',
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: _canGoForward
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                  onPressed: _canGoForward
                      ? () async {
                          await _controller.goForward();
                          final canGoBack = await _controller.canGoBack();
                          final canGoForward = await _controller.canGoForward();
                          setState(() {
                            _canGoBack = canGoBack;
                            _canGoForward = canGoForward;
                          });
                        }
                      : null,
                  tooltip: 'Tiến',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
