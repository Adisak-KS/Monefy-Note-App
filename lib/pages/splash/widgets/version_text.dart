import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatefulWidget {
  final TextStyle? style;
  const VersionText({super.key, this.style});

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _version,
      style:
          widget.style ??
          TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
    );
  }
}
