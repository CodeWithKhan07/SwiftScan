import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppMotion {
  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 260);
  static const entrance = Duration(milliseconds: 420);
  static const route = Duration(milliseconds: 320);

  static const emphasizedCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
}

/// Keeps tab state mounted while ensuring only one full page can ever paint.
class AppAnimatedIndexedStack extends StatefulWidget {
  const AppAnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  }) : assert(children.length > 0);

  final int index;
  final List<Widget> children;

  @override
  State<AppAnimatedIndexedStack> createState() =>
      _AppAnimatedIndexedStackState();
}

class _AppAnimatedIndexedStackState extends State<AppAnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.standard,
    value: 1,
  );
  bool _reduceMotion = false;
  double _direction = 1;

  int get _safeIndex => widget.index.clamp(0, widget.children.length - 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant AppAnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index) return;
    _direction = widget.index > oldWidget.index ? 1 : -1;
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _safeIndex;
    return AnimatedBuilder(
      animation: _controller,
      // IndexedStack paints exactly one page while preserving every tab state.
      child: IndexedStack(
        index: selected,
        children: List<Widget>.generate(widget.children.length, (index) {
          final active = index == selected;
          return ExcludeSemantics(
            excluding: !active,
            child: IgnorePointer(
              ignoring: !active,
              child: TickerMode(enabled: active, child: widget.children[index]),
            ),
          );
        }),
      ),
      builder: (context, child) {
        if (_reduceMotion) return child!;
        final progress = AppMotion.emphasizedCurve.transform(_controller.value);
        return Opacity(
          opacity: .9 + (.1 * progress),
          child: Transform.translate(
            offset: Offset(_direction * 6 * (1 - progress), 0),
            child: child,
          ),
        );
      },
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.offset = 14,
    this.delay = Duration.zero,
    this.duration = AppMotion.entrance,
  });

  final Widget child;
  final double offset;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // Respect the platform reduced-motion accessibility preference.
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delayMs = delay.inMilliseconds.toDouble();
    final motionMs = duration.inMilliseconds.toDouble();
    final totalMs = delayMs + motionMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs.round()),
      curve: Curves.linear,
      child: child,
      builder: (context, elapsed, child) {
        final linearProgress = motionMs == 0
            ? (elapsed * totalMs >= delayMs ? 1.0 : 0.0)
            : ((elapsed * totalMs - delayMs) / motionMs).clamp(0.0, 1.0);
        final progress = AppMotion.emphasizedCurve.transform(linearProgress);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Adds quiet physical feedback without replacing Material ripple semantics.
class AppPressScale extends StatefulWidget {
  const AppPressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = .975,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: _pressed ? AppMotion.quick : AppMotion.standard,
        curve: AppMotion.emphasizedCurve,
        child: widget.child,
      ),
    );
  }
}

class AppRouteTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasizedCurve,
      reverseCurve: AppMotion.exitCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(.018, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
