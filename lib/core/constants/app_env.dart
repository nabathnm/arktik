import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_KEY'] ?? '';

  static String? get googleWebClientId {
    final clientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    return (clientId != null && clientId.isNotEmpty) ? clientId : null;
  }
}
