import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

AppUser toAppUser(User user) => AppUser(id: user.id, email: user.email);
