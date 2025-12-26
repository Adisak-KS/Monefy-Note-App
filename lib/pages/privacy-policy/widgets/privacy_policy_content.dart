import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'privacy.section_intro_title'.tr(),
          content: 'privacy.section_intro_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_collection_title'.tr(),
          content: 'privacy.section_collection_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_usage_title'.tr(),
          content: 'privacy.section_usage_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_sharing_title'.tr(),
          content: 'privacy.section_sharing_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_security_title'.tr(),
          content: 'privacy.section_security_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_rights_title'.tr(),
          content: 'privacy.section_rights_content'.tr(),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'privacy.section_contact_title'.tr(),
          content: 'privacy.section_contact_content'.tr(),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
