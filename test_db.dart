import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://zvjamfvfujrmrirximbb.supabase.co';
  final supabaseKey = 'sb_publishable_2RYFPHGvvMEANBzatrl01A_DcnjcZKg';
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    final res = await client.from('trip_itineraries').select();
    print('Trip Itineraries count: ${res.length}');
    print(res);
  } catch (e) {
    print('Error: $e');
  }
}
