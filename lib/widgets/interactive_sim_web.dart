// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';

class InteractiveSimView extends StatefulWidget {
  final String simulationPath;
  final String viewKey;
  final void Function(Map<String, dynamic> data)? onMessage;

  const InteractiveSimView({
    Key? key,
    required this.simulationPath,
    required this.viewKey,
    this.onMessage,
  }) : super(key: key);

  @override
  State<InteractiveSimView> createState() => _InteractiveSimViewState();
}

class _InteractiveSimViewState extends State<InteractiveSimView> {
  StreamSubscription<html.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.onMessage != null) {
      _messageSubscription = html.window.onMessage.listen((event) {
        final data = event.data;
        if (data is Map) {
          final mapped = Map<String, dynamic>.from(data);
          widget.onMessage!(mapped);
        }
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  String _getUrl() {
    try {
      final origin = html.window.location.origin;
      return '$origin${widget.simulationPath.startsWith('/') ? '' : '/'}${widget.simulationPath}';
    } catch (_) {
      return widget.simulationPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: ValueKey(widget.viewKey),
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as html.IFrameElement;
        iframe.src = _getUrl();
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.display = 'block';
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.setAttribute('allow', 'fullscreen; autoplay; clipboard-write');
      },
    );
  }
}
