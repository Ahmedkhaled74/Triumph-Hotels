import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AutoScrollListView extends StatefulWidget {
  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const AutoScrollListView({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
    this.padding,
  });

  @override
  State<AutoScrollListView> createState() => _AutoScrollListViewState();
}

class _AutoScrollListViewState extends State<AutoScrollListView> {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _isUserScrolling = false;
  bool _scrollingForward = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_scrollController.hasClients && !_isUserScrolling) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double delta = 1.5; // Speed

        if (maxScroll > 0) {
          if (_scrollingForward) {
            if (currentScroll + delta >= maxScroll) {
              _scrollingForward = false; // Reverse direction
              // Optional: Pause at end?
            } else {
              _scrollController.jumpTo(currentScroll + delta);
            }
          } else {
            if (currentScroll - delta <= 0) {
              _scrollingForward = true; // Forward direction
            } else {
              _scrollController.jumpTo(currentScroll - delta);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction != ScrollDirection.idle) {
            _isUserScrolling = true;
          } else {
            // Wait a bit before resuming auto scroll
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isUserScrolling = false);
            });
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
          physics: widget.physics ?? const BouncingScrollPhysics(),
          padding: widget.padding,
        ),
      ),
    );
  }
}
