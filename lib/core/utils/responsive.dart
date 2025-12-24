import 'package:flutter/material.dart';

/// Responsive breakpoints และ utilities
class Responsive {
  Responsive._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// ตรวจสอบว่าเป็น mobile หรือไม่
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// ตรวจสอบว่าเป็น tablet หรือไม่
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// ตรวจสอบว่าเป็น desktop หรือไม่
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// คืนค่าตามขนาดหน้าจอ
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// คืนค่า padding ที่เหมาะสม
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context,
        mobile: 24.0,
        tablet: 48.0,
        desktop: 64.0,
      ),
    );
  }

  /// คืนค่า max width สำหรับ content
  static double maxContentWidth(BuildContext context) {
    return value(
      context,
      mobile: double.infinity,
      tablet: 700.0,
      desktop: 750.0,
    );
  }

  /// คืนค่า font scale factor
  static double fontScale(BuildContext context) {
    return value(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.15,
    );
  }

  /// คืนค่า spacing scale factor
  static double spacingScale(BuildContext context) {
    return value(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.3,
    );
  }
}

/// Widget ที่ช่วยจัดการ responsive layout
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// Wrapper ที่จำกัด max width ของ content
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? Responsive.horizontalPadding(context),
          child: child,
        ),
      ),
    );
  }
}
