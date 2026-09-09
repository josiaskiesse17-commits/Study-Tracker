import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    Supabase.instance.client,
  );
});

final dioProvider = Provider((ref) {
  return ref.read(dioClientProvider).dio;
});