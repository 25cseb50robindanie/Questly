// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

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
  html.IFrameElement? _iframe;
  VoidCallback? _langListener;

  @override
  void initState() {
    super.initState();
    try {
      html.window.localStorage['questly_language'] = LocalizationService.currentLanguage;
    } catch (_) {}

    if (widget.onMessage != null) {
      _messageSubscription = html.window.onMessage.listen((event) {
        final data = event.data;
        if (data is Map) {
          final mapped = Map<String, dynamic>.from(data);
          widget.onMessage!(mapped);
        }
      });
    }

    _langListener = () {
      final lang = LocalizationService.currentLanguage;
      try {
        html.window.localStorage['questly_language'] = lang;
      } catch (_) {}
      _sendLanguageToIframe(lang);
    };
    LocalizationService.languageNotifier.addListener(_langListener!);
  }

  void _sendLanguageToIframe(String lang) {
    if (_iframe != null && _iframe!.contentWindow != null) {
      try {
        _iframe!.contentWindow!.postMessage({'type': 'SET_LANGUAGE', 'lang': lang}, '*');
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    if (_langListener != null) {
      LocalizationService.languageNotifier.removeListener(_langListener!);
    }
    _messageSubscription?.cancel();
    super.dispose();
  }

  String _getUrl() {
    String path = widget.simulationPath;
    final currentLang = LocalizationService.currentLanguage;
    if (!path.contains('lang=')) {
      final sep = path.contains('?') ? '&' : '?';
      path = '$path${sep}lang=$currentLang';
    }
    try {
      final origin = html.window.location.origin;
      return '$origin${path.startsWith('/') ? '' : '/'}$path';
    } catch (_) {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: ValueKey('${widget.viewKey}_${LocalizationService.currentLanguage}'),
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as html.IFrameElement;
        _iframe = iframe;
        iframe.src = _getUrl();
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.display = 'block';
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.setAttribute('allow', 'fullscreen; autoplay; clipboard-write');

        iframe.onLoad.listen((_) {
          _sendLanguageToIframe(LocalizationService.currentLanguage);
        });
      },
    );
  }
}
