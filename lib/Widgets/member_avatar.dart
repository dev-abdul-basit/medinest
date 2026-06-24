import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/constant.dart';

/// Single source of truth for rendering a person's avatar.
///
/// `profileImage` can be:
///  - `"preset:N"`  → a generated preset avatar (colour + glyph), works offline
///  - an `http(s)` URL → an uploaded photo (cached)
///  - null / other → falls back to the gender icon
///
/// Used everywhere an avatar shows (member chips, list cards, the editor) so
/// presets, photos and fallbacks look identical app-wide.
class MemberAvatar extends StatelessWidget {
  final String? profileImage;
  final String? gender;
  final double size;

  const MemberAvatar({
    super.key,
    required this.size,
    this.profileImage,
    this.gender,
  });

  /// Basic-but-distinct preset palette. Index is stored as `preset:<index>`.
  static const List<Color> presetColors = [
    Color(0xFF3264C1), // blue (primary)
    Color(0xFF2E9E83), // teal
    Color(0xFFE0A43B), // amber
    Color(0xFFEF6C5B), // coral
    Color(0xFF8E6FD8), // violet
    Color(0xFFDA6FA0), // pink
    Color(0xFF3AA0C9), // sky
    Color(0xFF6B8E3A), // olive
  ];

  static int get presetCount => presetColors.length;
  static String presetValue(int index) => 'preset:$index';
  static bool isPreset(String? v) => v != null && v.startsWith('preset:');
  static int presetIndex(String v) =>
      int.tryParse(v.substring(v.indexOf(':') + 1)) ?? 0;

  @override
  Widget build(BuildContext context) {
    if (isPreset(profileImage)) {
      final int i = presetIndex(profileImage!) % presetColors.length;
      return _circle(
        presetColors[i],
        Icon(Icons.person, color: Colors.white, size: size * 0.56),
      );
    }

    if (profileImage != null &&
        profileImage!.isNotEmpty &&
        profileImage!.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _genderFallback(),
          errorWidget: (_, __, ___) => _genderFallback(),
        ),
      );
    }

    return _genderFallback();
  }

  Widget _circle(Color color, Widget child) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: child,
      );

  Widget _genderFallback() {
    final int idx =
        Constant.genderList.indexOf(gender ?? Constant.genderList[0]);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.theme.colorScheme.errorContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.22),
        child: Image.asset(Constant.genderIconList[idx < 0 ? 0 : idx]),
      ),
    );
  }
}
