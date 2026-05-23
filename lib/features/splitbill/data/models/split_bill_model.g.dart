// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_bill_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSplitBillModelCollection on Isar {
  IsarCollection<SplitBillModel> get splitBillModels => this.collection();
}

const SplitBillModelSchema = CollectionSchema(
  name: r'SplitBillModel',
  id: 2178546421854277976,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'isEqualSplit': PropertySchema(
      id: 2,
      name: r'isEqualSplit',
      type: IsarType.bool,
    ),
    r'isSettled': PropertySchema(
      id: 3,
      name: r'isSettled',
      type: IsarType.bool,
    ),
    r'paidParticipantNames': PropertySchema(
      id: 4,
      name: r'paidParticipantNames',
      type: IsarType.stringList,
    ),
    r'participantAmounts': PropertySchema(
      id: 5,
      name: r'participantAmounts',
      type: IsarType.doubleList,
    ),
    r'participantNames': PropertySchema(
      id: 6,
      name: r'participantNames',
      type: IsarType.stringList,
    ),
    r'syncStatus': PropertySchema(
      id: 7,
      name: r'syncStatus',
      type: IsarType.bool,
    ),
    r'title': PropertySchema(
      id: 8,
      name: r'title',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 9,
      name: r'total',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _splitBillModelEstimateSize,
  serialize: _splitBillModelSerialize,
  deserialize: _splitBillModelDeserialize,
  deserializeProp: _splitBillModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSettled': IndexSchema(
      id: -7113239362134594466,
      name: r'isSettled',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSettled',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _splitBillModelGetId,
  getLinks: _splitBillModelGetLinks,
  attach: _splitBillModelAttach,
  version: '3.1.0+1',
);

int _splitBillModelEstimateSize(
  SplitBillModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.id;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.paidParticipantNames.length * 3;
  {
    for (var i = 0; i < object.paidParticipantNames.length; i++) {
      final value = object.paidParticipantNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.participantAmounts.length * 8;
  bytesCount += 3 + object.participantNames.length * 3;
  {
    for (var i = 0; i < object.participantNames.length; i++) {
      final value = object.participantNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _splitBillModelSerialize(
  SplitBillModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.id);
  writer.writeBool(offsets[2], object.isEqualSplit);
  writer.writeBool(offsets[3], object.isSettled);
  writer.writeStringList(offsets[4], object.paidParticipantNames);
  writer.writeDoubleList(offsets[5], object.participantAmounts);
  writer.writeStringList(offsets[6], object.participantNames);
  writer.writeBool(offsets[7], object.syncStatus);
  writer.writeString(offsets[8], object.title);
  writer.writeDouble(offsets[9], object.total);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

SplitBillModel _splitBillModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SplitBillModel(
    createdAt: reader.readDateTimeOrNull(offsets[0]),
    id: reader.readStringOrNull(offsets[1]),
    isEqualSplit: reader.readBool(offsets[2]),
    isSettled: reader.readBoolOrNull(offsets[3]) ?? false,
    paidParticipantNames: reader.readStringList(offsets[4]) ?? [],
    participantAmounts: reader.readDoubleList(offsets[5]) ?? [],
    participantNames: reader.readStringList(offsets[6]) ?? [],
    syncStatus: reader.readBoolOrNull(offsets[7]) ?? false,
    title: reader.readStringOrNull(offsets[8]),
    total: reader.readDoubleOrNull(offsets[9]),
    updatedAt: reader.readDateTimeOrNull(offsets[10]),
  );
  object.isarId = id;
  return object;
}

P _splitBillModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _splitBillModelGetId(SplitBillModel object) {
  return object.isarId ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _splitBillModelGetLinks(SplitBillModel object) {
  return [];
}

void _splitBillModelAttach(
    IsarCollection<dynamic> col, Id id, SplitBillModel object) {
  object.isarId = id;
}

extension SplitBillModelByIndex on IsarCollection<SplitBillModel> {
  Future<SplitBillModel?> getById(String? id) {
    return getByIndex(r'id', [id]);
  }

  SplitBillModel? getByIdSync(String? id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String? id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String? id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<SplitBillModel?>> getAllById(List<String?> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<SplitBillModel?> getAllByIdSync(List<String?> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String?> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String?> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(SplitBillModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(SplitBillModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<SplitBillModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<SplitBillModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension SplitBillModelQueryWhereSort
    on QueryBuilder<SplitBillModel, SplitBillModel, QWhere> {
  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhere> anyIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSettled'),
      );
    });
  }
}

extension SplitBillModelQueryWhere
    on QueryBuilder<SplitBillModel, SplitBillModel, QWhereClause> {
  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [null],
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'id',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause> idEqualTo(
      String? id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause> idNotEqualTo(
      String? id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      isSettledEqualTo(bool isSettled) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSettled',
        value: [isSettled],
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterWhereClause>
      isSettledNotEqualTo(bool isSettled) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSettled',
              lower: [],
              upper: [isSettled],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSettled',
              lower: [isSettled],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSettled',
              lower: [isSettled],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSettled',
              lower: [],
              upper: [isSettled],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SplitBillModelQueryFilter
    on QueryBuilder<SplitBillModel, SplitBillModel, QFilterCondition> {
  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition> idEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition> idBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isEqualSplitEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEqualSplit',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isSettledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSettled',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      isarIdBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidParticipantNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paidParticipantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paidParticipantNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidParticipantNames',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paidParticipantNames',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      paidParticipantNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paidParticipantNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantAmounts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantAmounts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantAmounts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantAmounts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantAmountsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantAmounts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantNames',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantNames',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      participantNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      syncStatusEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'total',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'total',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      totalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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
}

extension SplitBillModelQueryObject
    on QueryBuilder<SplitBillModel, SplitBillModel, QFilterCondition> {}

extension SplitBillModelQueryLinks
    on QueryBuilder<SplitBillModel, SplitBillModel, QFilterCondition> {}

extension SplitBillModelQuerySortBy
    on QueryBuilder<SplitBillModel, SplitBillModel, QSortBy> {
  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortByIsEqualSplit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEqualSplit', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortByIsEqualSplitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEqualSplit', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortByIsSettledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SplitBillModelQuerySortThenBy
    on QueryBuilder<SplitBillModel, SplitBillModel, QSortThenBy> {
  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByIsEqualSplit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEqualSplit', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByIsEqualSplitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEqualSplit', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByIsSettledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SplitBillModelQueryWhereDistinct
    on QueryBuilder<SplitBillModel, SplitBillModel, QDistinct> {
  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByIsEqualSplit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEqualSplit');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSettled');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByPaidParticipantNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidParticipantNames');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByParticipantAmounts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantAmounts');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByParticipantNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantNames');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<SplitBillModel, SplitBillModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SplitBillModelQueryProperty
    on QueryBuilder<SplitBillModel, SplitBillModel, QQueryProperty> {
  QueryBuilder<SplitBillModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SplitBillModel, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SplitBillModel, String?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SplitBillModel, bool, QQueryOperations> isEqualSplitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEqualSplit');
    });
  }

  QueryBuilder<SplitBillModel, bool, QQueryOperations> isSettledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSettled');
    });
  }

  QueryBuilder<SplitBillModel, List<String>, QQueryOperations>
      paidParticipantNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidParticipantNames');
    });
  }

  QueryBuilder<SplitBillModel, List<double>, QQueryOperations>
      participantAmountsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantAmounts');
    });
  }

  QueryBuilder<SplitBillModel, List<String>, QQueryOperations>
      participantNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantNames');
    });
  }

  QueryBuilder<SplitBillModel, bool, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<SplitBillModel, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SplitBillModel, double?, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<SplitBillModel, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
