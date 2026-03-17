// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsLocalModelCollection on Isar {
  IsarCollection<AppSettingsLocalModel> get appSettingsLocalModels =>
      this.collection();
}

const AppSettingsLocalModelSchema = CollectionSchema(
  name: r'AppSettingsLocalModel',
  id: -7711851287718184256,
  properties: {
    r'minimumFreeSlotMinutes': PropertySchema(
      id: 0,
      name: r'minimumFreeSlotMinutes',
      type: IsarType.long,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 1,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'themePalette': PropertySchema(
      id: 2,
      name: r'themePalette',
      type: IsarType.string,
      enumMap: _AppSettingsLocalModelthemePaletteEnumValueMap,
    ),
    r'themePreference': PropertySchema(
      id: 3,
      name: r'themePreference',
      type: IsarType.string,
      enumMap: _AppSettingsLocalModelthemePreferenceEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'workDayEndHour': PropertySchema(
      id: 5,
      name: r'workDayEndHour',
      type: IsarType.long,
    ),
    r'workDayStartHour': PropertySchema(
      id: 6,
      name: r'workDayStartHour',
      type: IsarType.long,
    )
  },
  estimateSize: _appSettingsLocalModelEstimateSize,
  serialize: _appSettingsLocalModelSerialize,
  deserialize: _appSettingsLocalModelDeserialize,
  deserializeProp: _appSettingsLocalModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsLocalModelGetId,
  getLinks: _appSettingsLocalModelGetLinks,
  attach: _appSettingsLocalModelAttach,
  version: '3.1.0+1',
);

int _appSettingsLocalModelEstimateSize(
  AppSettingsLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.themePalette.name.length * 3;
  bytesCount += 3 + object.themePreference.name.length * 3;
  return bytesCount;
}

void _appSettingsLocalModelSerialize(
  AppSettingsLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.minimumFreeSlotMinutes);
  writer.writeBool(offsets[1], object.notificationsEnabled);
  writer.writeString(offsets[2], object.themePalette.name);
  writer.writeString(offsets[3], object.themePreference.name);
  writer.writeDateTime(offsets[4], object.updatedAt);
  writer.writeLong(offsets[5], object.workDayEndHour);
  writer.writeLong(offsets[6], object.workDayStartHour);
}

AppSettingsLocalModel _appSettingsLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsLocalModel();
  object.id = id;
  object.minimumFreeSlotMinutes = reader.readLong(offsets[0]);
  object.notificationsEnabled = reader.readBool(offsets[1]);
  object.themePalette = _AppSettingsLocalModelthemePaletteValueEnumMap[
          reader.readStringOrNull(offsets[2])] ??
      AppThemePalette.blue;
  object.themePreference = _AppSettingsLocalModelthemePreferenceValueEnumMap[
          reader.readStringOrNull(offsets[3])] ??
      AppThemePreference.system;
  object.updatedAt = reader.readDateTime(offsets[4]);
  object.workDayEndHour = reader.readLong(offsets[5]);
  object.workDayStartHour = reader.readLong(offsets[6]);
  return object;
}

P _appSettingsLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (_AppSettingsLocalModelthemePaletteValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AppThemePalette.blue) as P;
    case 3:
      return (_AppSettingsLocalModelthemePreferenceValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AppThemePreference.system) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppSettingsLocalModelthemePaletteEnumValueMap = {
  r'blue': r'blue',
  r'green': r'green',
  r'amber': r'amber',
};
const _AppSettingsLocalModelthemePaletteValueEnumMap = {
  r'blue': AppThemePalette.blue,
  r'green': AppThemePalette.green,
  r'amber': AppThemePalette.amber,
};
const _AppSettingsLocalModelthemePreferenceEnumValueMap = {
  r'system': r'system',
  r'light': r'light',
  r'dark': r'dark',
};
const _AppSettingsLocalModelthemePreferenceValueEnumMap = {
  r'system': AppThemePreference.system,
  r'light': AppThemePreference.light,
  r'dark': AppThemePreference.dark,
};

Id _appSettingsLocalModelGetId(AppSettingsLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsLocalModelGetLinks(
    AppSettingsLocalModel object) {
  return [];
}

void _appSettingsLocalModelAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsLocalModel object) {
  object.id = id;
}

extension AppSettingsLocalModelQueryWhereSort
    on QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QWhere> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsLocalModelQueryWhere on QueryBuilder<AppSettingsLocalModel,
    AppSettingsLocalModel, QWhereClause> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsLocalModelQueryFilter on QueryBuilder<
    AppSettingsLocalModel, AppSettingsLocalModel, QFilterCondition> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> minimumFreeSlotMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minimumFreeSlotMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> minimumFreeSlotMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minimumFreeSlotMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> minimumFreeSlotMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minimumFreeSlotMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> minimumFreeSlotMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minimumFreeSlotMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteEqualTo(
    AppThemePalette value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteGreaterThan(
    AppThemePalette value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteLessThan(
    AppThemePalette value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteBetween(
    AppThemePalette lower,
    AppThemePalette upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themePalette',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
          QAfterFilterCondition>
      themePaletteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themePalette',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
          QAfterFilterCondition>
      themePaletteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themePalette',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePalette',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePaletteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themePalette',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceEqualTo(
    AppThemePreference value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceGreaterThan(
    AppThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceLessThan(
    AppThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceBetween(
    AppThemePreference lower,
    AppThemePreference upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themePreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
          QAfterFilterCondition>
      themePreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
          QAfterFilterCondition>
      themePreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themePreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> themePreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayEndHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDayEndHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayEndHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workDayEndHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayEndHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workDayEndHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayEndHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workDayEndHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayStartHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDayStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayStartHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workDayStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayStartHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workDayStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel,
      QAfterFilterCondition> workDayStartHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workDayStartHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsLocalModelQueryObject on QueryBuilder<
    AppSettingsLocalModel, AppSettingsLocalModel, QFilterCondition> {}

extension AppSettingsLocalModelQueryLinks on QueryBuilder<AppSettingsLocalModel,
    AppSettingsLocalModel, QFilterCondition> {}

extension AppSettingsLocalModelQuerySortBy
    on QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QSortBy> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByMinimumFreeSlotMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumFreeSlotMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByMinimumFreeSlotMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumFreeSlotMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByThemePalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePalette', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByThemePaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePalette', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByWorkDayEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayEndHour', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByWorkDayEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayEndHour', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByWorkDayStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayStartHour', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      sortByWorkDayStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayStartHour', Sort.desc);
    });
  }
}

extension AppSettingsLocalModelQuerySortThenBy
    on QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QSortThenBy> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByMinimumFreeSlotMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumFreeSlotMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByMinimumFreeSlotMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumFreeSlotMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByThemePalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePalette', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByThemePaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePalette', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByWorkDayEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayEndHour', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByWorkDayEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayEndHour', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByWorkDayStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayStartHour', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QAfterSortBy>
      thenByWorkDayStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDayStartHour', Sort.desc);
    });
  }
}

extension AppSettingsLocalModelQueryWhereDistinct
    on QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct> {
  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByMinimumFreeSlotMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minimumFreeSlotMinutes');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByThemePalette({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themePalette', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByThemePreference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themePreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByWorkDayEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workDayEndHour');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppSettingsLocalModel, QDistinct>
      distinctByWorkDayStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workDayStartHour');
    });
  }
}

extension AppSettingsLocalModelQueryProperty on QueryBuilder<
    AppSettingsLocalModel, AppSettingsLocalModel, QQueryProperty> {
  QueryBuilder<AppSettingsLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsLocalModel, int, QQueryOperations>
      minimumFreeSlotMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minimumFreeSlotMinutes');
    });
  }

  QueryBuilder<AppSettingsLocalModel, bool, QQueryOperations>
      notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppThemePalette, QQueryOperations>
      themePaletteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themePalette');
    });
  }

  QueryBuilder<AppSettingsLocalModel, AppThemePreference, QQueryOperations>
      themePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themePreference');
    });
  }

  QueryBuilder<AppSettingsLocalModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<AppSettingsLocalModel, int, QQueryOperations>
      workDayEndHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workDayEndHour');
    });
  }

  QueryBuilder<AppSettingsLocalModel, int, QQueryOperations>
      workDayStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workDayStartHour');
    });
  }
}
