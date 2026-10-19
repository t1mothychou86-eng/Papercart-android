import 'package:shared_preferences/shared_preferences.dart';

/// Shared defaults and migration for the official DeepSeek API.
class DeepSeekSettings {
  static const defaultModel = 'deepseek-flash';

  /// Keep model names on third-party endpoints, which may use their own aliases.
  static Future<String> loadModelName(SharedPreferences prefs) async {
    final stored = prefs.getString('deepseek_model_name');
    final baseUrl = prefs.getString('deepseek_base_url');
    final useCustom = prefs.getBool('use_custom_deepseek_base_url') ?? false;
    final usesOfficialApi = !useCustom ||
        baseUrl == null ||
        baseUrl.isEmpty ||
        Uri.tryParse(baseUrl)?.host.toLowerCase() == 'api.deepseek.com';
    final isRetired =
        stored == 'deepseek-chat' || stored == 'deepseek-reasoner';
    final model = usesOfficialApi && isRetired
        ? defaultModel
        : (stored == null || stored.isEmpty ? defaultModel : stored);
    if (stored != null && model != stored) {
      await prefs.setString('deepseek_model_name', model);
    }
    return model;
  }
}
