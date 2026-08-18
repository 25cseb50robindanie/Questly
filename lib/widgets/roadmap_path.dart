import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';

class LevelNode {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLocked;

  LevelNode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isLocked,
  });
}

class RoadmapPath extends StatelessWidget {
  final List<LevelNode> nodes;
  final String activeNodeId;
  final Function(LevelNode) onNodeSelected;

  const RoadmapPath({
    Key? key,
    required this.nodes,
    required this.activeNodeId,
    required this.onNodeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Connecting Line
          Positioned(
            left: 50,
            right: 50,
            child: CustomPaint(
              size: const Size(double.infinity, 20),
              painter: _DottedRoadLinePainter(nodeCount: nodes.length),
            ),
          ),
          // Horizontal Scrollable Quest Nodes
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            itemCount: nodes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 50),
            itemBuilder: (context, index) {
              final node = nodes[index];
              final isActive = node.id == activeNodeId;

              // Node Background & Borders
              Color fill;
              Widget statusIcon;

              if (node.isLocked) {
                fill = Colors.grey.shade300;
                statusIcon = const Icon(Icons.lock_outline, size: 20, color: Colors.grey);
              } else if (node.isCompleted) {
                fill = ColorSystem.lightGreen;
                statusIcon = const Icon(Icons.check, size: 22, color: Colors.white);
              } else if (isActive) {
                fill = ColorSystem.gold;
                statusIcon = const Icon(Icons.play_arrow, size: 24, color: ColorSystem.plum);
              } else {
                // Unlocked but not active/completed
                fill = ColorSystem.lavender;
                statusIcon = const Icon(Icons.lock_open, size: 20, color: ColorSystem.plum);
              }

              return GestureDetector(
                onTap: node.isLocked ? null : () => onNodeSelected(node),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stepping Stone Node
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: fill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorSystem.plum,
                          width: isActive ? 3 : 1.5,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: ColorSystem.gold.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Center(child: statusIcon),
                    ),
                    const SizedBox(height: 8),
                    // Title Label
                    Text(
                      node.title,
                      style: TextStyle(
                        fontFamily: 'system-ui',
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                        color: node.isLocked ? ColorSystem.plum.withOpacity(0.5) : ColorSystem.plum,
                      ),
                    ),
                    // Subtitle (mass/density targets)
                    Text(
                      node.subtitle,
                      style: TextStyle(
                        fontFamily: 'system-ui',
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: ColorSystem.plum.withOpacity(node.isLocked ? 0.4 : 0.6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DottedRoadLinePainter extends CustomPainter {
  final int nodeCount;

  _DottedRoadLinePainter({required this.nodeCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorSystem.plum.withOpacity(0.25)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double dashWidth = 8;
    final double dashSpace = 6;
    double startX = 0;

    // Draw simple horizontal dashed line
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
