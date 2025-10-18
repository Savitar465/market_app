import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/security/credential_cipher.dart';
import 'features/auth/data/datasources/local/auth_local_data_source.dart';
import 'features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/products/data/datasources/local/product_local_data_source.dart';
import 'features/products/data/datasources/remote/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/inventory/data/datasources/local/inventory_local_data_source.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase credentials are missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY using --dart-define at build/run time.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final supabaseClient = Supabase.instance.client;
  final database = AppDatabase();
  final credentialCipher = CredentialCipher();

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(supabaseClient),
    localDataSource: AuthLocalDataSource(
      database: database,
      credentialCipher: credentialCipher,
    ),
  );

  final productRepository = ProductRepositoryImpl(
    remoteDataSource: ProductRemoteDataSource(supabaseClient),
    localDataSource: ProductLocalDataSource(database),
  );

  final inventoryRepository = InventoryRepositoryImpl(
    localDataSource: InventoryLocalDataSource(database),
  );

  runApp(
    App(
      authRepository: authRepository,
      productRepository: productRepository,
      inventoryRepository: inventoryRepository,
    ),
  );
}











