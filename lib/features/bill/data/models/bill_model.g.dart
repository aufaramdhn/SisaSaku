// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBillModelCollection on Isar {
  IsarCollection<BillModel> get billModels => this.collection();
}

const BillModelSchema = CollectionSchema(
  name: r'BillModel',
  id: 7819431562807030620,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deskripsi': PropertySchema(
      id: 1,
      name: r'deskripsi',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'nama': PropertySchema(
      id: 3,
      name: r'nama',
      type: IsarType.string,
    ),
    r'nominal': PropertySchema(
      id: 4,
      name: r'nominal',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 6,
      name: r'syncStatus',
      type: IsarType.bool,
    ),
    r'tanggalJatuhTempo': PropertySchema(
      id: 7,
      name: r'tanggalJatuhTempo',
      type: IsarType.dateTime,
    ),
    r'tanggalPembayaran': PropertySchema(
      id: 8,
      name: r'tanggalPembayaran',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'waktuPengingat': PropertySchema(
      id: 10,
      name: r'waktuPengingat',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _billModelEstimateSize,
  serialize: _billModelSerialize,
  deserialize: _billModelDeserialize,
  deserializeProp: _billModelDeserializeProp,
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
    r'tanggalJatuhTempo': IndexSchema(
      id: 1129523984494701429,
      name: r'tanggalJatuhTempo',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tanggalJatuhTempo',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'waktuPengingat': IndexSchema(
      id: 265771042770488142,
      name: r'waktuPengingat',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'waktuPengingat',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _billModelGetId,
  getLinks: _billModelGetLinks,
  attach: _billModelAttach,
  version: '3.1.0+1',
);

int _billModelEstimateSize(
  BillModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.deskripsi;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.id;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nama;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _billModelSerialize(
  BillModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.deskripsi);
  writer.writeString(offsets[2], object.id);
  writer.writeString(offsets[3], object.nama);
  writer.writeDouble(offsets[4], object.nominal);
  writer.writeString(offsets[5], object.status);
  writer.writeBool(offsets[6], object.syncStatus);
  writer.writeDateTime(offsets[7], object.tanggalJatuhTempo);
  writer.writeDateTime(offsets[8], object.tanggalPembayaran);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeDateTime(offsets[10], object.waktuPengingat);
}

BillModel _billModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BillModel(
    createdAt: reader.readDateTimeOrNull(offsets[0]),
    deskripsi: reader.readStringOrNull(offsets[1]),
    id: reader.readStringOrNull(offsets[2]),
    nama: reader.readStringOrNull(offsets[3]),
    nominal: reader.readDoubleOrNull(offsets[4]),
    status: reader.readStringOrNull(offsets[5]),
    syncStatus: reader.readBoolOrNull(offsets[6]) ?? false,
    tanggalJatuhTempo: reader.readDateTimeOrNull(offsets[7]),
    tanggalPembayaran: reader.readDateTimeOrNull(offsets[8]),
    updatedAt: reader.readDateTimeOrNull(offsets[9]),
    waktuPengingat: reader.readDateTimeOrNull(offsets[10]),
  );
  object.isarId = id;
  return object;
}

P _billModelDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _billModelGetId(BillModel object) {
  return object.isarId ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _billModelGetLinks(BillModel object) {
  return [];
}

void _billModelAttach(IsarCollection<dynamic> col, Id id, BillModel object) {
  object.isarId = id;
}

extension BillModelByIndex on IsarCollection<BillModel> {
  Future<BillModel?> getById(String? id) {
    return getByIndex(r'id', [id]);
  }

  BillModel? getByIdSync(String? id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String? id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String? id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<BillModel?>> getAllById(List<String?> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<BillModel?> getAllByIdSync(List<String?> idValues) {
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

  Future<Id> putById(BillModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(BillModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<BillModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<BillModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension BillModelQueryWhereSort
    on QueryBuilder<BillModel, BillModel, QWhere> {
  QueryBuilder<BillModel, BillModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhere> anyTanggalJatuhTempo() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tanggalJatuhTempo'),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhere> anyWaktuPengingat() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'waktuPengingat'),
      );
    });
  }
}

extension BillModelQueryWhere
    on QueryBuilder<BillModel, BillModel, QWhereClause> {
  QueryBuilder<BillModel, BillModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [null],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'id',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idEqualTo(String? id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggalJatuhTempo',
        value: [null],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggalJatuhTempo',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoEqualTo(DateTime? tanggalJatuhTempo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggalJatuhTempo',
        value: [tanggalJatuhTempo],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoNotEqualTo(DateTime? tanggalJatuhTempo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggalJatuhTempo',
              lower: [],
              upper: [tanggalJatuhTempo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggalJatuhTempo',
              lower: [tanggalJatuhTempo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggalJatuhTempo',
              lower: [tanggalJatuhTempo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggalJatuhTempo',
              lower: [],
              upper: [tanggalJatuhTempo],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoGreaterThan(
    DateTime? tanggalJatuhTempo, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggalJatuhTempo',
        lower: [tanggalJatuhTempo],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoLessThan(
    DateTime? tanggalJatuhTempo, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggalJatuhTempo',
        lower: [],
        upper: [tanggalJatuhTempo],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      tanggalJatuhTempoBetween(
    DateTime? lowerTanggalJatuhTempo,
    DateTime? upperTanggalJatuhTempo, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggalJatuhTempo',
        lower: [lowerTanggalJatuhTempo],
        includeLower: includeLower,
        upper: [upperTanggalJatuhTempo],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> waktuPengingatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'waktuPengingat',
        value: [null],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      waktuPengingatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'waktuPengingat',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> waktuPengingatEqualTo(
      DateTime? waktuPengingat) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'waktuPengingat',
        value: [waktuPengingat],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      waktuPengingatNotEqualTo(DateTime? waktuPengingat) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'waktuPengingat',
              lower: [],
              upper: [waktuPengingat],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'waktuPengingat',
              lower: [waktuPengingat],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'waktuPengingat',
              lower: [waktuPengingat],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'waktuPengingat',
              lower: [],
              upper: [waktuPengingat],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause>
      waktuPengingatGreaterThan(
    DateTime? waktuPengingat, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'waktuPengingat',
        lower: [waktuPengingat],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> waktuPengingatLessThan(
    DateTime? waktuPengingat, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'waktuPengingat',
        lower: [],
        upper: [waktuPengingat],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> waktuPengingatBetween(
    DateTime? lowerWaktuPengingat,
    DateTime? upperWaktuPengingat, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'waktuPengingat',
        lower: [lowerWaktuPengingat],
        includeLower: includeLower,
        upper: [upperWaktuPengingat],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [null],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> statusEqualTo(
      String? status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterWhereClause> statusNotEqualTo(
      String? status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BillModelQueryFilter
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {
  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deskripsi',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      deskripsiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deskripsi',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      deskripsiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deskripsi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deskripsi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deskripsi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> deskripsiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deskripsi',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      deskripsiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deskripsi',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idMatches(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nama',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nama',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nama',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nominal',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nominal',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nominal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> nominalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nominal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> syncStatusEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalJatuhTempo',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalJatuhTempo',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalJatuhTempo',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalJatuhTempo',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalJatuhTempo',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalJatuhTempoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalJatuhTempo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalPembayaran',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalPembayaran',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalPembayaran',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalPembayaran',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalPembayaran',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      tanggalPembayaranBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalPembayaran',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'waktuPengingat',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'waktuPengingat',
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waktuPengingat',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waktuPengingat',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waktuPengingat',
        value: value,
      ));
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterFilterCondition>
      waktuPengingatBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waktuPengingat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BillModelQueryObject
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {}

extension BillModelQueryLinks
    on QueryBuilder<BillModel, BillModel, QFilterCondition> {}

extension BillModelQuerySortBy on QueryBuilder<BillModel, BillModel, QSortBy> {
  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByDeskripsi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deskripsi', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByDeskripsiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deskripsi', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByNominalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByTanggalJatuhTempo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalJatuhTempo', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy>
      sortByTanggalJatuhTempoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalJatuhTempo', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByTanggalPembayaran() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalPembayaran', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy>
      sortByTanggalPembayaranDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalPembayaran', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByWaktuPengingat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waktuPengingat', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> sortByWaktuPengingatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waktuPengingat', Sort.desc);
    });
  }
}

extension BillModelQuerySortThenBy
    on QueryBuilder<BillModel, BillModel, QSortThenBy> {
  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByDeskripsi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deskripsi', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByDeskripsiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deskripsi', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByNominalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominal', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByTanggalJatuhTempo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalJatuhTempo', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy>
      thenByTanggalJatuhTempoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalJatuhTempo', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByTanggalPembayaran() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalPembayaran', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy>
      thenByTanggalPembayaranDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalPembayaran', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByWaktuPengingat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waktuPengingat', Sort.asc);
    });
  }

  QueryBuilder<BillModel, BillModel, QAfterSortBy> thenByWaktuPengingatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waktuPengingat', Sort.desc);
    });
  }
}

extension BillModelQueryWhereDistinct
    on QueryBuilder<BillModel, BillModel, QDistinct> {
  QueryBuilder<BillModel, BillModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByDeskripsi(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deskripsi', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByNama(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByNominal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nominal');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByTanggalJatuhTempo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalJatuhTempo');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByTanggalPembayaran() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalPembayaran');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BillModel, BillModel, QDistinct> distinctByWaktuPengingat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waktuPengingat');
    });
  }
}

extension BillModelQueryProperty
    on QueryBuilder<BillModel, BillModel, QQueryProperty> {
  QueryBuilder<BillModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> deskripsiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deskripsi');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<BillModel, double?, QQueryOperations> nominalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nominal');
    });
  }

  QueryBuilder<BillModel, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BillModel, bool, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations>
      tanggalJatuhTempoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalJatuhTempo');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations>
      tanggalPembayaranProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalPembayaran');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BillModel, DateTime?, QQueryOperations>
      waktuPengingatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waktuPengingat');
    });
  }
}
