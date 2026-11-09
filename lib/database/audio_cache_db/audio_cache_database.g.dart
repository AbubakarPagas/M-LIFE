// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_cache_database.dart';

// ignore_for_file: type=lint
class $AudioCacheEntriesTable extends AudioCacheEntries
    with TableInfo<$AudioCacheEntriesTable, AudioCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<String> reciterId = GeneratedColumn<String>(
    'reciter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<String> downloadedAt = GeneratedColumn<String>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('downloading'),
  );
  static const VerificationMeta _cacheVersionMeta = const VerificationMeta(
    'cacheVersion',
  );
  @override
  late final GeneratedColumn<int> cacheVersion = GeneratedColumn<int>(
    'cache_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahId,
    reciterId,
    audioUrl,
    localFilePath,
    fileSizeBytes,
    downloadedAt,
    status,
    cacheVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterIdMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('cache_version')) {
      context.handle(
        _cacheVersionMeta,
        cacheVersion.isAcceptableOrUnknown(
          data['cache_version']!,
          _cacheVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_id'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}downloaded_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cacheVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_version'],
      )!,
    );
  }

  @override
  $AudioCacheEntriesTable createAlias(String alias) {
    return $AudioCacheEntriesTable(attachedDatabase, alias);
  }
}

class AudioCacheEntry extends DataClass implements Insertable<AudioCacheEntry> {
  /// Auto-increment primary key.
  final int id;

  /// Surah number (1–114).
  final int surahId;

  /// Reciter identifier stored by quran_library (e.g. "ar.alafasy").
  final String reciterId;

  /// Original remote URL used to fetch the audio.
  final String audioUrl;

  /// Absolute path to the local MP3 file.
  final String localFilePath;

  /// File size in bytes; -1 if unknown.
  final int fileSizeBytes;

  /// ISO-8601 timestamp of when the download completed.
  final String downloadedAt;

  /// One of: 'downloading' | 'completed' | 'failed' | 'paused'
  final String status;

  /// Incremented when the cached file should be invalidated.
  final int cacheVersion;
  const AudioCacheEntry({
    required this.id,
    required this.surahId,
    required this.reciterId,
    required this.audioUrl,
    required this.localFilePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
    required this.status,
    required this.cacheVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['reciter_id'] = Variable<String>(reciterId);
    map['audio_url'] = Variable<String>(audioUrl);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['downloaded_at'] = Variable<String>(downloadedAt);
    map['status'] = Variable<String>(status);
    map['cache_version'] = Variable<int>(cacheVersion);
    return map;
  }

  AudioCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return AudioCacheEntriesCompanion(
      id: Value(id),
      surahId: Value(surahId),
      reciterId: Value(reciterId),
      audioUrl: Value(audioUrl),
      localFilePath: Value(localFilePath),
      fileSizeBytes: Value(fileSizeBytes),
      downloadedAt: Value(downloadedAt),
      status: Value(status),
      cacheVersion: Value(cacheVersion),
    );
  }

  factory AudioCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      reciterId: serializer.fromJson<String>(json['reciterId']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      downloadedAt: serializer.fromJson<String>(json['downloadedAt']),
      status: serializer.fromJson<String>(json['status']),
      cacheVersion: serializer.fromJson<int>(json['cacheVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'reciterId': serializer.toJson<String>(reciterId),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'downloadedAt': serializer.toJson<String>(downloadedAt),
      'status': serializer.toJson<String>(status),
      'cacheVersion': serializer.toJson<int>(cacheVersion),
    };
  }

  AudioCacheEntry copyWith({
    int? id,
    int? surahId,
    String? reciterId,
    String? audioUrl,
    String? localFilePath,
    int? fileSizeBytes,
    String? downloadedAt,
    String? status,
    int? cacheVersion,
  }) => AudioCacheEntry(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    reciterId: reciterId ?? this.reciterId,
    audioUrl: audioUrl ?? this.audioUrl,
    localFilePath: localFilePath ?? this.localFilePath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    status: status ?? this.status,
    cacheVersion: cacheVersion ?? this.cacheVersion,
  );
  AudioCacheEntry copyWithCompanion(AudioCacheEntriesCompanion data) {
    return AudioCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      status: data.status.present ? data.status.value : this.status,
      cacheVersion: data.cacheVersion.present
          ? data.cacheVersion.value
          : this.cacheVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioCacheEntry(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('reciterId: $reciterId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('status: $status, ')
          ..write('cacheVersion: $cacheVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahId,
    reciterId,
    audioUrl,
    localFilePath,
    fileSizeBytes,
    downloadedAt,
    status,
    cacheVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioCacheEntry &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.reciterId == this.reciterId &&
          other.audioUrl == this.audioUrl &&
          other.localFilePath == this.localFilePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.downloadedAt == this.downloadedAt &&
          other.status == this.status &&
          other.cacheVersion == this.cacheVersion);
}

class AudioCacheEntriesCompanion extends UpdateCompanion<AudioCacheEntry> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<String> reciterId;
  final Value<String> audioUrl;
  final Value<String> localFilePath;
  final Value<int> fileSizeBytes;
  final Value<String> downloadedAt;
  final Value<String> status;
  final Value<int> cacheVersion;
  const AudioCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.reciterId = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.cacheVersion = const Value.absent(),
  });
  AudioCacheEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required String reciterId,
    required String audioUrl,
    required String localFilePath,
    this.fileSizeBytes = const Value.absent(),
    required String downloadedAt,
    this.status = const Value.absent(),
    this.cacheVersion = const Value.absent(),
  }) : surahId = Value(surahId),
       reciterId = Value(reciterId),
       audioUrl = Value(audioUrl),
       localFilePath = Value(localFilePath),
       downloadedAt = Value(downloadedAt);
  static Insertable<AudioCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<String>? reciterId,
    Expression<String>? audioUrl,
    Expression<String>? localFilePath,
    Expression<int>? fileSizeBytes,
    Expression<String>? downloadedAt,
    Expression<String>? status,
    Expression<int>? cacheVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (reciterId != null) 'reciter_id': reciterId,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (status != null) 'status': status,
      if (cacheVersion != null) 'cache_version': cacheVersion,
    });
  }

  AudioCacheEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<String>? reciterId,
    Value<String>? audioUrl,
    Value<String>? localFilePath,
    Value<int>? fileSizeBytes,
    Value<String>? downloadedAt,
    Value<String>? status,
    Value<int>? cacheVersion,
  }) {
    return AudioCacheEntriesCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      reciterId: reciterId ?? this.reciterId,
      audioUrl: audioUrl ?? this.audioUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      status: status ?? this.status,
      cacheVersion: cacheVersion ?? this.cacheVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (reciterId.present) {
      map['reciter_id'] = Variable<String>(reciterId.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<String>(downloadedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cacheVersion.present) {
      map['cache_version'] = Variable<int>(cacheVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('reciterId: $reciterId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('status: $status, ')
          ..write('cacheVersion: $cacheVersion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AudioCacheDatabase extends GeneratedDatabase {
  _$AudioCacheDatabase(QueryExecutor e) : super(e);
  $AudioCacheDatabaseManager get managers => $AudioCacheDatabaseManager(this);
  late final $AudioCacheEntriesTable audioCacheEntries =
      $AudioCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [audioCacheEntries];
}

typedef $$AudioCacheEntriesTableCreateCompanionBuilder =
    AudioCacheEntriesCompanion Function({
      Value<int> id,
      required int surahId,
      required String reciterId,
      required String audioUrl,
      required String localFilePath,
      Value<int> fileSizeBytes,
      required String downloadedAt,
      Value<String> status,
      Value<int> cacheVersion,
    });
typedef $$AudioCacheEntriesTableUpdateCompanionBuilder =
    AudioCacheEntriesCompanion Function({
      Value<int> id,
      Value<int> surahId,
      Value<String> reciterId,
      Value<String> audioUrl,
      Value<String> localFilePath,
      Value<int> fileSizeBytes,
      Value<String> downloadedAt,
      Value<String> status,
      Value<int> cacheVersion,
    });

class $$AudioCacheEntriesTableFilterComposer
    extends Composer<_$AudioCacheDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheVersion => $composableBuilder(
    column: $table.cacheVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioCacheEntriesTableOrderingComposer
    extends Composer<_$AudioCacheDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheVersion => $composableBuilder(
    column: $table.cacheVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioCacheEntriesTableAnnotationComposer
    extends Composer<_$AudioCacheDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<String> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get cacheVersion => $composableBuilder(
    column: $table.cacheVersion,
    builder: (column) => column,
  );
}

class $$AudioCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AudioCacheDatabase,
          $AudioCacheEntriesTable,
          AudioCacheEntry,
          $$AudioCacheEntriesTableFilterComposer,
          $$AudioCacheEntriesTableOrderingComposer,
          $$AudioCacheEntriesTableAnnotationComposer,
          $$AudioCacheEntriesTableCreateCompanionBuilder,
          $$AudioCacheEntriesTableUpdateCompanionBuilder,
          (
            AudioCacheEntry,
            BaseReferences<
              _$AudioCacheDatabase,
              $AudioCacheEntriesTable,
              AudioCacheEntry
            >,
          ),
          AudioCacheEntry,
          PrefetchHooks Function()
        > {
  $$AudioCacheEntriesTableTableManager(
    _$AudioCacheDatabase db,
    $AudioCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<String> reciterId = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> downloadedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> cacheVersion = const Value.absent(),
              }) => AudioCacheEntriesCompanion(
                id: id,
                surahId: surahId,
                reciterId: reciterId,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                fileSizeBytes: fileSizeBytes,
                downloadedAt: downloadedAt,
                status: status,
                cacheVersion: cacheVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required String reciterId,
                required String audioUrl,
                required String localFilePath,
                Value<int> fileSizeBytes = const Value.absent(),
                required String downloadedAt,
                Value<String> status = const Value.absent(),
                Value<int> cacheVersion = const Value.absent(),
              }) => AudioCacheEntriesCompanion.insert(
                id: id,
                surahId: surahId,
                reciterId: reciterId,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                fileSizeBytes: fileSizeBytes,
                downloadedAt: downloadedAt,
                status: status,
                cacheVersion: cacheVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioCacheEntriesTable, AudioCacheEntry>(table),
                  BaseReferences<
                    _$AudioCacheDatabase,
                    $AudioCacheEntriesTable,
                    AudioCacheEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AudioCacheDatabase,
      $AudioCacheEntriesTable,
      AudioCacheEntry,
      $$AudioCacheEntriesTableFilterComposer,
      $$AudioCacheEntriesTableOrderingComposer,
      $$AudioCacheEntriesTableAnnotationComposer,
      $$AudioCacheEntriesTableCreateCompanionBuilder,
      $$AudioCacheEntriesTableUpdateCompanionBuilder,
      (
        AudioCacheEntry,
        BaseReferences<
          _$AudioCacheDatabase,
          $AudioCacheEntriesTable,
          AudioCacheEntry
        >,
      ),
      AudioCacheEntry,
      PrefetchHooks Function()
    >;

class $AudioCacheDatabaseManager {
  final _$AudioCacheDatabase _db;
  $AudioCacheDatabaseManager(this._db);
  $$AudioCacheEntriesTableTableManager get audioCacheEntries =>
      $$AudioCacheEntriesTableTableManager(_db, _db.audioCacheEntries);
}
