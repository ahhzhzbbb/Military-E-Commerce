import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_theme.dart';
import '../constants/api_constants.dart';
import '../api/api_client.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CustomNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildShimmer(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.divider.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.textHint.withValues(alpha: 0.6),
              size: (height != null && height! < 80) ? 24 : 40,
            ),
            if (height == null || height! > 80)
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final TextStyle? style;
  final TextStyle? originalStyle;
  final bool showDiscountPercent;

  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.style,
    this.originalStyle,
    this.showDiscountPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${price.toStringAsFixed(0)} xu',
          style: style ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        if (originalPrice != null && originalPrice! > price) ...[
          const SizedBox(width: 8),
          Text(
            '${originalPrice!.toStringAsFixed(0)} xu',
            style: originalStyle ??
                const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          if (showDiscountPercent && originalPrice != null && originalPrice! > price) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${(((originalPrice! - price) / originalPrice!) * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star;
          color = activeColor ?? Colors.amber;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
          color = activeColor ?? Colors.amber;
        } else {
          icon = Icons.star_border;
          color = inactiveColor ?? AppColors.textHint;
        }

        return Icon(icon, size: size, color: color);
      }),
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 100, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 16, width: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerProductGrid extends StatelessWidget {
  final int count;
  const ShimmerProductGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.58,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(count, (_) => const ShimmerProductCard()),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final bool leadingCircle;
  final int subtitleLines;

  const ShimmerListTile({super.key, this.leadingCircle = true, this.subtitleLines = 1});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListTile(
        leading: leadingCircle
            ? CircleAvatar(backgroundColor: Colors.white, radius: 24)
            : Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
        title: Container(height: 14, width: 140, color: Colors.white),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            ...List.generate(subtitleLines, (i) => Padding(
              padding: EdgeInsets.only(bottom: i < subtitleLines - 1 ? 4 : 0),
              child: Container(height: 12, width: i == 0 ? 200 : 160, color: Colors.white),
            )),
          ],
        ),
        trailing: Container(height: 12, width: 40, color: Colors.white),
      ),
    );
  }
}

class ShimmerCategoryChips extends StatelessWidget {
  final int count;
  const ShimmerCategoryChips({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SizedBox(
        height: 90,
        child: GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(count, (_) => Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 4),
              Container(height: 11, width: 48, color: Colors.white),
            ],
          )),
        ),
      ),
    );
  }
}

class ShimmerProductDetail extends StatelessWidget {
  const ShimmerProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 360, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 20, width: 250, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(height: 28, width: 120, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(children: [
                    CircleAvatar(backgroundColor: Colors.white, radius: 20),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 14, width: 120, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 80, color: Colors.white),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  Container(height: 16, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 16, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 180, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerUserProfile extends StatelessWidget {
  const ShimmerUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(expandedHeight: 220, pinned: true, flexibleSpace: Container(color: Colors.white)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Expanded(child: Container(height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
                  ]),
                ),
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(children: List.generate(3, (_) => Expanded(
                    child: Column(children: [
                      Container(width: 22, height: 22, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(height: 20, width: 40, color: Colors.white),
                      const SizedBox(height: 2),
                      Container(height: 11, width: 60, color: Colors.white),
                    ]),
                  ))),
                ),
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: List.generate(4, (_) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Container(width: 20, height: 20, color: Colors.white),
                      const SizedBox(width: 12),
                      Container(height: 14, width: 110, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 14, color: Colors.white)),
                    ]),
                  ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductLikeOverlay extends StatefulWidget {
  final int productId;
  final bool isLiked;
  final Widget child;

  const ProductLikeOverlay({
    super.key,
    required this.productId,
    required this.isLiked,
    required this.child,
  });

  @override
  State<ProductLikeOverlay> createState() => _ProductLikeOverlayState();
}

class _ProductLikeOverlayState extends State<ProductLikeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  OverlayEntry? _overlayEntry;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 0.4),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 0.15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 0.15),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.3),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.2),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant ProductLikeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showHeart() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? AppColors.error : Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(from: 0).then((_) {
      _removeOverlay();
    });
  }

  Future<void> _handleLongPress() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLiked = !_isLiked);
    _showHeart();

    final apiClient = ApiClient();
    final response = await apiClient.post(
      ApiConstants.likeProduct,
      body: {'product_id': widget.productId},
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      if (mounted) {
        setState(() => _isLiked = !_isLiked);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Thao tác thất bại'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(_isLiked ? 'Đã thích sản phẩm' : 'Đã bỏ thích'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _handleLongPress,
      child: widget.child,
    );
  }
}
