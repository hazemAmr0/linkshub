import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SocialPlatform {
  facebook,
  twitter,
  instagram,
  linkedin,
  youtube,
  whatsapp,
  github,
  telegram,
  tiktok,
  snapchat,
  website,
  email,
  phone,
  other,
}

class SocialIconData {
  final IconData icon;
  final Color color;
  final String label;

  const SocialIconData({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class SocialIcons {
  static const Map<SocialPlatform, SocialIconData> _icons = {
    SocialPlatform.facebook: SocialIconData(
      icon: FontAwesomeIcons.facebook,
      color: Color(0xFF1877F2),
      label: 'Facebook',
    ),
    SocialPlatform.twitter: SocialIconData(
      icon: FontAwesomeIcons.twitter,
      color: Color(0xFF1DA1F2),
      label: 'Twitter',
    ),
    SocialPlatform.instagram: SocialIconData(
      icon: FontAwesomeIcons.instagram,
      color: Color(0xFFE4405F),
      label: 'Instagram',
    ),
    SocialPlatform.linkedin: SocialIconData(
      icon: FontAwesomeIcons.linkedin,
      color: Color(0xFF0077B5),
      label: 'LinkedIn',
    ),
    SocialPlatform.youtube: SocialIconData(
      icon: FontAwesomeIcons.youtube,
      color: Color(0xFFFF0000),
      label: 'YouTube',
    ),
    SocialPlatform.whatsapp: SocialIconData(
      icon: FontAwesomeIcons.whatsapp,
      color: Color(0xFF25D366),
      label: 'WhatsApp',
    ),
    SocialPlatform.github: SocialIconData(
      icon: FontAwesomeIcons.github,
      color: Color(0xFF333333),
      label: 'GitHub',
    ),
    SocialPlatform.telegram: SocialIconData(
      icon: FontAwesomeIcons.telegram,
      color: Color(0xFF0088CC),
      label: 'Telegram',
    ),
    SocialPlatform.tiktok: SocialIconData(
      icon: FontAwesomeIcons.tiktok,
      color: Color(0xFF000000),
      label: 'TikTok',
    ),
    SocialPlatform.snapchat: SocialIconData(
      icon: FontAwesomeIcons.snapchat,
      color: Color(0xFFFFFC00),
      label: 'Snapchat',
    ),
    SocialPlatform.website: SocialIconData(
      icon: FontAwesomeIcons.globe,
      color: Color(0xFF6C63FF),
      label: 'Website',
    ),
    SocialPlatform.email: SocialIconData(
      icon: FontAwesomeIcons.envelope,
      color: Color(0xFF34A853),
      label: 'Email',
    ),
    SocialPlatform.phone: SocialIconData(
      icon: FontAwesomeIcons.phone,
      color: Color(0xFF4285F4),
      label: 'Phone',
    ),
    SocialPlatform.other: SocialIconData(
      icon: FontAwesomeIcons.link,
      color: Color(0xFF9C27B0),
      label: 'Other',
    ),
  };

  static SocialIconData getIcon(SocialPlatform platform) {
    return _icons[platform] ?? _icons[SocialPlatform.other]!;
  }

  static SocialIconData getIconByName(String name) {
    try {
      final platform = SocialPlatform.values.firstWhere(
        (p) => p.name == name,
        orElse: () => SocialPlatform.other,
      );
      return getIcon(platform);
    } catch (e) {
      return getIcon(SocialPlatform.other);
    }
  }

  static List<SocialPlatform> get allPlatforms => SocialPlatform.values;
}
