import 'package:flutter/material.dart';

class ExpandableFloatingActionButton extends StatefulWidget {
  final VoidCallback onAddItem;
  final Future<void> Function(BuildContext) onAddCustomItem;

  const ExpandableFloatingActionButton({
    super.key,
    required this.onAddItem,
    required this.onAddCustomItem,
  });

  @override
  State<ExpandableFloatingActionButton> createState() =>
      _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState
    extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _positionAnimation;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Button 1
          AnimatedOpacity(
            opacity: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SlideTransition(
              position: _positionAnimation,
              child: FloatingActionButton(
                onPressed: widget.onAddItem,
                tooltip: 'Add Item',
                child: const Icon(Icons.favorite),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Button 2
          AnimatedOpacity(
            opacity: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SlideTransition(
              position: _positionAnimation,
              child: FloatingActionButton(
                onPressed: () => widget.onAddCustomItem(context),
                tooltip: 'Add Custom Item',
                child: const Icon(Icons.create),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Main expandable button
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
                isExpanded
                    ? _animationController.forward()
                    : _animationController.reverse();
              });
            },
            tooltip: 'Expand Options',
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              color: Theme.of(context).colorScheme.onPrimary,
              progress: _animationController,
            ),
          ),
        ],
      ),
    );
  }
}
