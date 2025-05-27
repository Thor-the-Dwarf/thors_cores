import 'package:supabase_flutter/supabase_flutter.dart';

class Core {
  final String id;
  String? _name;
  String? _details;
  int? _essenceCount;

  Core({
    required this.id,
    String? name,
    String? details,
    int? essenceCount,
  }) {
    _name = name;
    _details = details;
    _essenceCount = essenceCount;
  }

  String get name => _name ?? 'Unknown Core';
  String? get details => _details;
  int get essenceCount => _essenceCount ?? 0;

  Future<void> loadDetails() async {
    if (_name != null) return;
    final response = await Supabase.instance.client
        .from('core')
        .select('name, details')
        .eq('core_pk', id)
        .single();
    _name = response['name'] as String?;
    _details = response['details'] as String?;
  }

  Future<void> countEssences() async {
    if (_essenceCount != null) return;
    final essenceResponse = await Supabase.instance.client
        .from('essence')
        .select('essence_pk')
        .eq('core_fk', id);
    _essenceCount = essenceResponse.length;
  }
}