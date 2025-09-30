// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AuthCredentialsTableTable extends AuthCredentialsTable
    with TableInfo<$AuthCredentialsTableTable, AuthCredentialsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthCredentialsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashedPasswordMeta = const VerificationMeta(
    'hashedPassword',
  );
  @override
  late final GeneratedColumn<String> hashedPassword = GeneratedColumn<String>(
    'hashed_password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
    'password_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedAccessTokenMeta =
      const VerificationMeta('encryptedAccessToken');
  @override
  late final GeneratedColumn<String> encryptedAccessToken =
      GeneratedColumn<String>(
        'encrypted_access_token',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encryptedRefreshTokenMeta =
      const VerificationMeta('encryptedRefreshToken');
  @override
  late final GeneratedColumn<String> encryptedRefreshToken =
      GeneratedColumn<String>(
        'encrypted_refresh_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonUserMetadataMeta = const VerificationMeta(
    'jsonUserMetadata',
  );
  @override
  late final GeneratedColumn<String> jsonUserMetadata = GeneratedColumn<String>(
    'json_user_metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    email,
    displayName,
    hashedPassword,
    passwordSalt,
    encryptedAccessToken,
    encryptedRefreshToken,
    expiresAt,
    jsonUserMetadata,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_credentials_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthCredentialsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('hashed_password')) {
      context.handle(
        _hashedPasswordMeta,
        hashedPassword.isAcceptableOrUnknown(
          data['hashed_password']!,
          _hashedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hashedPasswordMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('encrypted_access_token')) {
      context.handle(
        _encryptedAccessTokenMeta,
        encryptedAccessToken.isAcceptableOrUnknown(
          data['encrypted_access_token']!,
          _encryptedAccessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedAccessTokenMeta);
    }
    if (data.containsKey('encrypted_refresh_token')) {
      context.handle(
        _encryptedRefreshTokenMeta,
        encryptedRefreshToken.isAcceptableOrUnknown(
          data['encrypted_refresh_token']!,
          _encryptedRefreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('json_user_metadata')) {
      context.handle(
        _jsonUserMetadataMeta,
        jsonUserMetadata.isAcceptableOrUnknown(
          data['json_user_metadata']!,
          _jsonUserMetadataMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  AuthCredentialsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthCredentialsTableData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      hashedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hashed_password'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt'],
      )!,
      encryptedAccessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_access_token'],
      )!,
      encryptedRefreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_refresh_token'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      ),
      jsonUserMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_user_metadata'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AuthCredentialsTableTable createAlias(String alias) {
    return $AuthCredentialsTableTable(attachedDatabase, alias);
  }
}

class AuthCredentialsTableData extends DataClass
    implements Insertable<AuthCredentialsTableData> {
  final String userId;
  final String email;
  final String? displayName;
  final String hashedPassword;
  final String passwordSalt;
  final String encryptedAccessToken;
  final String? encryptedRefreshToken;
  final int? expiresAt;
  final String? jsonUserMetadata;
  final DateTime updatedAt;
  const AuthCredentialsTableData({
    required this.userId,
    required this.email,
    this.displayName,
    required this.hashedPassword,
    required this.passwordSalt,
    required this.encryptedAccessToken,
    this.encryptedRefreshToken,
    this.expiresAt,
    this.jsonUserMetadata,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['hashed_password'] = Variable<String>(hashedPassword);
    map['password_salt'] = Variable<String>(passwordSalt);
    map['encrypted_access_token'] = Variable<String>(encryptedAccessToken);
    if (!nullToAbsent || encryptedRefreshToken != null) {
      map['encrypted_refresh_token'] = Variable<String>(encryptedRefreshToken);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    if (!nullToAbsent || jsonUserMetadata != null) {
      map['json_user_metadata'] = Variable<String>(jsonUserMetadata);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuthCredentialsTableCompanion toCompanion(bool nullToAbsent) {
    return AuthCredentialsTableCompanion(
      userId: Value(userId),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      hashedPassword: Value(hashedPassword),
      passwordSalt: Value(passwordSalt),
      encryptedAccessToken: Value(encryptedAccessToken),
      encryptedRefreshToken: encryptedRefreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedRefreshToken),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      jsonUserMetadata: jsonUserMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonUserMetadata),
      updatedAt: Value(updatedAt),
    );
  }

  factory AuthCredentialsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthCredentialsTableData(
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      hashedPassword: serializer.fromJson<String>(json['hashedPassword']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      encryptedAccessToken: serializer.fromJson<String>(
        json['encryptedAccessToken'],
      ),
      encryptedRefreshToken: serializer.fromJson<String?>(
        json['encryptedRefreshToken'],
      ),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
      jsonUserMetadata: serializer.fromJson<String?>(json['jsonUserMetadata']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'hashedPassword': serializer.toJson<String>(hashedPassword),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'encryptedAccessToken': serializer.toJson<String>(encryptedAccessToken),
      'encryptedRefreshToken': serializer.toJson<String?>(
        encryptedRefreshToken,
      ),
      'expiresAt': serializer.toJson<int?>(expiresAt),
      'jsonUserMetadata': serializer.toJson<String?>(jsonUserMetadata),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AuthCredentialsTableData copyWith({
    String? userId,
    String? email,
    Value<String?> displayName = const Value.absent(),
    String? hashedPassword,
    String? passwordSalt,
    String? encryptedAccessToken,
    Value<String?> encryptedRefreshToken = const Value.absent(),
    Value<int?> expiresAt = const Value.absent(),
    Value<String?> jsonUserMetadata = const Value.absent(),
    DateTime? updatedAt,
  }) => AuthCredentialsTableData(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    hashedPassword: hashedPassword ?? this.hashedPassword,
    passwordSalt: passwordSalt ?? this.passwordSalt,
    encryptedAccessToken: encryptedAccessToken ?? this.encryptedAccessToken,
    encryptedRefreshToken: encryptedRefreshToken.present
        ? encryptedRefreshToken.value
        : this.encryptedRefreshToken,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    jsonUserMetadata: jsonUserMetadata.present
        ? jsonUserMetadata.value
        : this.jsonUserMetadata,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AuthCredentialsTableData copyWithCompanion(
    AuthCredentialsTableCompanion data,
  ) {
    return AuthCredentialsTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      hashedPassword: data.hashedPassword.present
          ? data.hashedPassword.value
          : this.hashedPassword,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      encryptedAccessToken: data.encryptedAccessToken.present
          ? data.encryptedAccessToken.value
          : this.encryptedAccessToken,
      encryptedRefreshToken: data.encryptedRefreshToken.present
          ? data.encryptedRefreshToken.value
          : this.encryptedRefreshToken,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      jsonUserMetadata: data.jsonUserMetadata.present
          ? data.jsonUserMetadata.value
          : this.jsonUserMetadata,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthCredentialsTableData(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('hashedPassword: $hashedPassword, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('encryptedAccessToken: $encryptedAccessToken, ')
          ..write('encryptedRefreshToken: $encryptedRefreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('jsonUserMetadata: $jsonUserMetadata, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    email,
    displayName,
    hashedPassword,
    passwordSalt,
    encryptedAccessToken,
    encryptedRefreshToken,
    expiresAt,
    jsonUserMetadata,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthCredentialsTableData &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.hashedPassword == this.hashedPassword &&
          other.passwordSalt == this.passwordSalt &&
          other.encryptedAccessToken == this.encryptedAccessToken &&
          other.encryptedRefreshToken == this.encryptedRefreshToken &&
          other.expiresAt == this.expiresAt &&
          other.jsonUserMetadata == this.jsonUserMetadata &&
          other.updatedAt == this.updatedAt);
}

class AuthCredentialsTableCompanion
    extends UpdateCompanion<AuthCredentialsTableData> {
  final Value<String> userId;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<String> hashedPassword;
  final Value<String> passwordSalt;
  final Value<String> encryptedAccessToken;
  final Value<String?> encryptedRefreshToken;
  final Value<int?> expiresAt;
  final Value<String?> jsonUserMetadata;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AuthCredentialsTableCompanion({
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.hashedPassword = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.encryptedAccessToken = const Value.absent(),
    this.encryptedRefreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.jsonUserMetadata = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthCredentialsTableCompanion.insert({
    required String userId,
    required String email,
    this.displayName = const Value.absent(),
    required String hashedPassword,
    required String passwordSalt,
    required String encryptedAccessToken,
    this.encryptedRefreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.jsonUserMetadata = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       email = Value(email),
       hashedPassword = Value(hashedPassword),
       passwordSalt = Value(passwordSalt),
       encryptedAccessToken = Value(encryptedAccessToken),
       updatedAt = Value(updatedAt);
  static Insertable<AuthCredentialsTableData> custom({
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? hashedPassword,
    Expression<String>? passwordSalt,
    Expression<String>? encryptedAccessToken,
    Expression<String>? encryptedRefreshToken,
    Expression<int>? expiresAt,
    Expression<String>? jsonUserMetadata,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (hashedPassword != null) 'hashed_password': hashedPassword,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (encryptedAccessToken != null)
        'encrypted_access_token': encryptedAccessToken,
      if (encryptedRefreshToken != null)
        'encrypted_refresh_token': encryptedRefreshToken,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (jsonUserMetadata != null) 'json_user_metadata': jsonUserMetadata,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthCredentialsTableCompanion copyWith({
    Value<String>? userId,
    Value<String>? email,
    Value<String?>? displayName,
    Value<String>? hashedPassword,
    Value<String>? passwordSalt,
    Value<String>? encryptedAccessToken,
    Value<String?>? encryptedRefreshToken,
    Value<int?>? expiresAt,
    Value<String?>? jsonUserMetadata,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AuthCredentialsTableCompanion(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      encryptedAccessToken: encryptedAccessToken ?? this.encryptedAccessToken,
      encryptedRefreshToken:
          encryptedRefreshToken ?? this.encryptedRefreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      jsonUserMetadata: jsonUserMetadata ?? this.jsonUserMetadata,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (hashedPassword.present) {
      map['hashed_password'] = Variable<String>(hashedPassword.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (encryptedAccessToken.present) {
      map['encrypted_access_token'] = Variable<String>(
        encryptedAccessToken.value,
      );
    }
    if (encryptedRefreshToken.present) {
      map['encrypted_refresh_token'] = Variable<String>(
        encryptedRefreshToken.value,
      );
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (jsonUserMetadata.present) {
      map['json_user_metadata'] = Variable<String>(jsonUserMetadata.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthCredentialsTableCompanion(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('hashedPassword: $hashedPassword, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('encryptedAccessToken: $encryptedAccessToken, ')
          ..write('encryptedRefreshToken: $encryptedRefreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('jsonUserMetadata: $jsonUserMetadata, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuthCredentialsTableTable authCredentialsTable =
      $AuthCredentialsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [authCredentialsTable];
}

typedef $$AuthCredentialsTableTableCreateCompanionBuilder =
    AuthCredentialsTableCompanion Function({
      required String userId,
      required String email,
      Value<String?> displayName,
      required String hashedPassword,
      required String passwordSalt,
      required String encryptedAccessToken,
      Value<String?> encryptedRefreshToken,
      Value<int?> expiresAt,
      Value<String?> jsonUserMetadata,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AuthCredentialsTableTableUpdateCompanionBuilder =
    AuthCredentialsTableCompanion Function({
      Value<String> userId,
      Value<String> email,
      Value<String?> displayName,
      Value<String> hashedPassword,
      Value<String> passwordSalt,
      Value<String> encryptedAccessToken,
      Value<String?> encryptedRefreshToken,
      Value<int?> expiresAt,
      Value<String?> jsonUserMetadata,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AuthCredentialsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuthCredentialsTableTable> {
  $$AuthCredentialsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonUserMetadata => $composableBuilder(
    column: $table.jsonUserMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthCredentialsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthCredentialsTableTable> {
  $$AuthCredentialsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonUserMetadata => $composableBuilder(
    column: $table.jsonUserMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthCredentialsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthCredentialsTableTable> {
  $$AuthCredentialsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get jsonUserMetadata => $composableBuilder(
    column: $table.jsonUserMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AuthCredentialsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthCredentialsTableTable,
          AuthCredentialsTableData,
          $$AuthCredentialsTableTableFilterComposer,
          $$AuthCredentialsTableTableOrderingComposer,
          $$AuthCredentialsTableTableAnnotationComposer,
          $$AuthCredentialsTableTableCreateCompanionBuilder,
          $$AuthCredentialsTableTableUpdateCompanionBuilder,
          (
            AuthCredentialsTableData,
            BaseReferences<
              _$AppDatabase,
              $AuthCredentialsTableTable,
              AuthCredentialsTableData
            >,
          ),
          AuthCredentialsTableData,
          PrefetchHooks Function()
        > {
  $$AuthCredentialsTableTableTableManager(
    _$AppDatabase db,
    $AuthCredentialsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthCredentialsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthCredentialsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AuthCredentialsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> hashedPassword = const Value.absent(),
                Value<String> passwordSalt = const Value.absent(),
                Value<String> encryptedAccessToken = const Value.absent(),
                Value<String?> encryptedRefreshToken = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> jsonUserMetadata = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthCredentialsTableCompanion(
                userId: userId,
                email: email,
                displayName: displayName,
                hashedPassword: hashedPassword,
                passwordSalt: passwordSalt,
                encryptedAccessToken: encryptedAccessToken,
                encryptedRefreshToken: encryptedRefreshToken,
                expiresAt: expiresAt,
                jsonUserMetadata: jsonUserMetadata,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String email,
                Value<String?> displayName = const Value.absent(),
                required String hashedPassword,
                required String passwordSalt,
                required String encryptedAccessToken,
                Value<String?> encryptedRefreshToken = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> jsonUserMetadata = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AuthCredentialsTableCompanion.insert(
                userId: userId,
                email: email,
                displayName: displayName,
                hashedPassword: hashedPassword,
                passwordSalt: passwordSalt,
                encryptedAccessToken: encryptedAccessToken,
                encryptedRefreshToken: encryptedRefreshToken,
                expiresAt: expiresAt,
                jsonUserMetadata: jsonUserMetadata,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthCredentialsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthCredentialsTableTable,
      AuthCredentialsTableData,
      $$AuthCredentialsTableTableFilterComposer,
      $$AuthCredentialsTableTableOrderingComposer,
      $$AuthCredentialsTableTableAnnotationComposer,
      $$AuthCredentialsTableTableCreateCompanionBuilder,
      $$AuthCredentialsTableTableUpdateCompanionBuilder,
      (
        AuthCredentialsTableData,
        BaseReferences<
          _$AppDatabase,
          $AuthCredentialsTableTable,
          AuthCredentialsTableData
        >,
      ),
      AuthCredentialsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuthCredentialsTableTableTableManager get authCredentialsTable =>
      $$AuthCredentialsTableTableTableManager(_db, _db.authCredentialsTable);
}
