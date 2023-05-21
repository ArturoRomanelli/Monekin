// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_impl.dart';

// ignore_for_file: type=lint
class Currencies extends Table with TableInfo<Currencies, CurrencyInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Currencies(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [code, symbol];
  @override
  String get aliasedName => _alias ?? 'currencies';
  @override
  String get actualTableName => 'currencies';
  @override
  VerificationContext validateIntegrity(Insertable<CurrencyInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CurrencyInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyInDB(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
    );
  }

  @override
  Currencies createAlias(String alias) {
    return Currencies(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CurrencyInDB extends DataClass implements Insertable<CurrencyInDB> {
  /// ISO 4217 currency code. Identifies a currency uniquely ([see more](https://en.wikipedia.org/wiki/ISO_4217#List_of_ISO_4217_currency_codes))
  final String code;

  /// Symbol to represent the currency
  final String symbol;
  const CurrencyInDB({required this.code, required this.symbol});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['symbol'] = Variable<String>(symbol);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      symbol: Value(symbol),
    );
  }

  factory CurrencyInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyInDB(
      code: serializer.fromJson<String>(json['code']),
      symbol: serializer.fromJson<String>(json['symbol']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'symbol': serializer.toJson<String>(symbol),
    };
  }

  CurrencyInDB copyWith({String? code, String? symbol}) => CurrencyInDB(
        code: code ?? this.code,
        symbol: symbol ?? this.symbol,
      );
  @override
  String toString() {
    return (StringBuffer('CurrencyInDB(')
          ..write('code: $code, ')
          ..write('symbol: $symbol')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, symbol);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyInDB &&
          other.code == this.code &&
          other.symbol == this.symbol);
}

class CurrenciesCompanion extends UpdateCompanion<CurrencyInDB> {
  final Value<String> code;
  final Value<String> symbol;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.symbol = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required String symbol,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        symbol = Value(symbol);
  static Insertable<CurrencyInDB> custom({
    Expression<String>? code,
    Expression<String>? symbol,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (symbol != null) 'symbol': symbol,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith(
      {Value<String>? code, Value<String>? symbol, Value<int>? rowid}) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('symbol: $symbol, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Accounts extends Table with TableInfo<Accounts, AccountInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Accounts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _iniValueMeta =
      const VerificationMeta('iniValue');
  late final GeneratedColumn<double> iniValue = GeneratedColumn<double>(
      'iniValue', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _iconIdMeta = const VerificationMeta('iconId');
  late final GeneratedColumn<String> iconId = GeneratedColumn<String>(
      'iconId', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _currencyIdMeta =
      const VerificationMeta('currencyId');
  late final GeneratedColumn<String> currencyId = GeneratedColumn<String>(
      'currencyId', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES currencies(code)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _ibanMeta = const VerificationMeta('iban');
  late final GeneratedColumn<String> iban = GeneratedColumn<String>(
      'iban', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _swiftMeta = const VerificationMeta('swift');
  late final GeneratedColumn<String> swift = GeneratedColumn<String>(
      'swift', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iniValue,
        date,
        description,
        type,
        iconId,
        currencyId,
        iban,
        swift
      ];
  @override
  String get aliasedName => _alias ?? 'accounts';
  @override
  String get actualTableName => 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<AccountInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('iniValue')) {
      context.handle(_iniValueMeta,
          iniValue.isAcceptableOrUnknown(data['iniValue']!, _iniValueMeta));
    } else if (isInserting) {
      context.missing(_iniValueMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('iconId')) {
      context.handle(_iconIdMeta,
          iconId.isAcceptableOrUnknown(data['iconId']!, _iconIdMeta));
    } else if (isInserting) {
      context.missing(_iconIdMeta);
    }
    if (data.containsKey('currencyId')) {
      context.handle(
          _currencyIdMeta,
          currencyId.isAcceptableOrUnknown(
              data['currencyId']!, _currencyIdMeta));
    } else if (isInserting) {
      context.missing(_currencyIdMeta);
    }
    if (data.containsKey('iban')) {
      context.handle(
          _ibanMeta, iban.isAcceptableOrUnknown(data['iban']!, _ibanMeta));
    }
    if (data.containsKey('swift')) {
      context.handle(
          _swiftMeta, swift.isAcceptableOrUnknown(data['swift']!, _swiftMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountInDB(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iniValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}iniValue'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      iconId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iconId'])!,
      currencyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currencyId'])!,
      iban: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iban']),
      swift: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}swift']),
    );
  }

  @override
  Accounts createAlias(String alias) {
    return Accounts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AccountInDB extends DataClass implements Insertable<AccountInDB> {
  final String id;

  /// Account name (unique among user accounts)
  final String name;
  final double iniValue;
  final DateTime date;
  final String? description;
  final String type;
  final String iconId;

  /// ID of the currency used by this account and therefore all transactions contained in it
  final String currencyId;
  final String? iban;
  final String? swift;
  const AccountInDB(
      {required this.id,
      required this.name,
      required this.iniValue,
      required this.date,
      this.description,
      required this.type,
      required this.iconId,
      required this.currencyId,
      this.iban,
      this.swift});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['iniValue'] = Variable<double>(iniValue);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    map['iconId'] = Variable<String>(iconId);
    map['currencyId'] = Variable<String>(currencyId);
    if (!nullToAbsent || iban != null) {
      map['iban'] = Variable<String>(iban);
    }
    if (!nullToAbsent || swift != null) {
      map['swift'] = Variable<String>(swift);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      iniValue: Value(iniValue),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      iconId: Value(iconId),
      currencyId: Value(currencyId),
      iban: iban == null && nullToAbsent ? const Value.absent() : Value(iban),
      swift:
          swift == null && nullToAbsent ? const Value.absent() : Value(swift),
    );
  }

  factory AccountInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountInDB(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iniValue: serializer.fromJson<double>(json['iniValue']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      iconId: serializer.fromJson<String>(json['iconId']),
      currencyId: serializer.fromJson<String>(json['currencyId']),
      iban: serializer.fromJson<String?>(json['iban']),
      swift: serializer.fromJson<String?>(json['swift']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iniValue': serializer.toJson<double>(iniValue),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'iconId': serializer.toJson<String>(iconId),
      'currencyId': serializer.toJson<String>(currencyId),
      'iban': serializer.toJson<String?>(iban),
      'swift': serializer.toJson<String?>(swift),
    };
  }

  AccountInDB copyWith(
          {String? id,
          String? name,
          double? iniValue,
          DateTime? date,
          Value<String?> description = const Value.absent(),
          String? type,
          String? iconId,
          String? currencyId,
          Value<String?> iban = const Value.absent(),
          Value<String?> swift = const Value.absent()}) =>
      AccountInDB(
        id: id ?? this.id,
        name: name ?? this.name,
        iniValue: iniValue ?? this.iniValue,
        date: date ?? this.date,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        iconId: iconId ?? this.iconId,
        currencyId: currencyId ?? this.currencyId,
        iban: iban.present ? iban.value : this.iban,
        swift: swift.present ? swift.value : this.swift,
      );
  @override
  String toString() {
    return (StringBuffer('AccountInDB(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iniValue: $iniValue, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('iconId: $iconId, ')
          ..write('currencyId: $currencyId, ')
          ..write('iban: $iban, ')
          ..write('swift: $swift')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iniValue, date, description, type,
      iconId, currencyId, iban, swift);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountInDB &&
          other.id == this.id &&
          other.name == this.name &&
          other.iniValue == this.iniValue &&
          other.date == this.date &&
          other.description == this.description &&
          other.type == this.type &&
          other.iconId == this.iconId &&
          other.currencyId == this.currencyId &&
          other.iban == this.iban &&
          other.swift == this.swift);
}

class AccountsCompanion extends UpdateCompanion<AccountInDB> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> iniValue;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String> type;
  final Value<String> iconId;
  final Value<String> currencyId;
  final Value<String?> iban;
  final Value<String?> swift;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iniValue = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.iconId = const Value.absent(),
    this.currencyId = const Value.absent(),
    this.iban = const Value.absent(),
    this.swift = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required double iniValue,
    required DateTime date,
    this.description = const Value.absent(),
    required String type,
    required String iconId,
    required String currencyId,
    this.iban = const Value.absent(),
    this.swift = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iniValue = Value(iniValue),
        date = Value(date),
        type = Value(type),
        iconId = Value(iconId),
        currencyId = Value(currencyId);
  static Insertable<AccountInDB> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? iniValue,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? iconId,
    Expression<String>? currencyId,
    Expression<String>? iban,
    Expression<String>? swift,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iniValue != null) 'iniValue': iniValue,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (iconId != null) 'iconId': iconId,
      if (currencyId != null) 'currencyId': currencyId,
      if (iban != null) 'iban': iban,
      if (swift != null) 'swift': swift,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? iniValue,
      Value<DateTime>? date,
      Value<String?>? description,
      Value<String>? type,
      Value<String>? iconId,
      Value<String>? currencyId,
      Value<String?>? iban,
      Value<String?>? swift,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iniValue: iniValue ?? this.iniValue,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      iconId: iconId ?? this.iconId,
      currencyId: currencyId ?? this.currencyId,
      iban: iban ?? this.iban,
      swift: swift ?? this.swift,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iniValue.present) {
      map['iniValue'] = Variable<double>(iniValue.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (iconId.present) {
      map['iconId'] = Variable<String>(iconId.value);
    }
    if (currencyId.present) {
      map['currencyId'] = Variable<String>(currencyId.value);
    }
    if (iban.present) {
      map['iban'] = Variable<String>(iban.value);
    }
    if (swift.present) {
      map['swift'] = Variable<String>(swift.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iniValue: $iniValue, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('iconId: $iconId, ')
          ..write('currencyId: $currencyId, ')
          ..write('iban: $iban, ')
          ..write('swift: $swift, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Categories extends Table with TableInfo<Categories, CategoryInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Categories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  static const VerificationMeta _iconIdMeta = const VerificationMeta('iconId');
  late final GeneratedColumn<String> iconId = GeneratedColumn<String>(
      'iconId', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumnWithTypeConverter<CategoryType?, String> type =
      GeneratedColumn<String>('type', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: 'CHECK (status IN (\'E\', \'I\', \'B\'))')
          .withConverter<CategoryType?>(Categories.$convertertypen);
  static const VerificationMeta _parentCategoryIDMeta =
      const VerificationMeta('parentCategoryID');
  late final GeneratedColumn<String> parentCategoryID = GeneratedColumn<String>(
      'parentCategoryID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'REFERENCES categories(id)ON UPDATE CASCADE ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconId, color, type, parentCategoryID];
  @override
  String get aliasedName => _alias ?? 'categories';
  @override
  String get actualTableName => 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('iconId')) {
      context.handle(_iconIdMeta,
          iconId.isAcceptableOrUnknown(data['iconId']!, _iconIdMeta));
    } else if (isInserting) {
      context.missing(_iconIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('parentCategoryID')) {
      context.handle(
          _parentCategoryIDMeta,
          parentCategoryID.isAcceptableOrUnknown(
              data['parentCategoryID']!, _parentCategoryIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryInDB(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iconId'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      type: Categories.$convertertypen.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])),
      parentCategoryID: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parentCategoryID']),
    );
  }

  @override
  Categories createAlias(String alias) {
    return Categories(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryType, String, String> $convertertype =
      const EnumNameConverter<CategoryType>(CategoryType.values);
  static JsonTypeConverter2<CategoryType?, String?, String?> $convertertypen =
      JsonTypeConverter2.asNullable($convertertype);
  @override
  List<String> get customConstraints => const [
        'CHECK((parentCategoryID IS NULL)!=(color IS NULL AND type IS NULL))',
        'CHECK((color IS NULL)==(type IS NULL))'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class CategoryInDB extends DataClass implements Insertable<CategoryInDB> {
  final String id;

  /// The name of the category
  final String name;

  /// Id of the icon that represents this category
  final String iconId;

  /// Color that will be used to represent this category in some screens. If null, the color of the parent's category will be used
  final String? color;

  /// Type of the category. If null, the type of the parent's category will be used
  final CategoryType? type;
  final String? parentCategoryID;
  const CategoryInDB(
      {required this.id,
      required this.name,
      required this.iconId,
      this.color,
      this.type,
      this.parentCategoryID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['iconId'] = Variable<String>(iconId);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || type != null) {
      final converter = Categories.$convertertypen;
      map['type'] = Variable<String>(converter.toSql(type));
    }
    if (!nullToAbsent || parentCategoryID != null) {
      map['parentCategoryID'] = Variable<String>(parentCategoryID);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconId: Value(iconId),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      parentCategoryID: parentCategoryID == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCategoryID),
    );
  }

  factory CategoryInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryInDB(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconId: serializer.fromJson<String>(json['iconId']),
      color: serializer.fromJson<String?>(json['color']),
      type: Categories.$convertertypen
          .fromJson(serializer.fromJson<String?>(json['type'])),
      parentCategoryID: serializer.fromJson<String?>(json['parentCategoryID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconId': serializer.toJson<String>(iconId),
      'color': serializer.toJson<String?>(color),
      'type':
          serializer.toJson<String?>(Categories.$convertertypen.toJson(type)),
      'parentCategoryID': serializer.toJson<String?>(parentCategoryID),
    };
  }

  CategoryInDB copyWith(
          {String? id,
          String? name,
          String? iconId,
          Value<String?> color = const Value.absent(),
          Value<CategoryType?> type = const Value.absent(),
          Value<String?> parentCategoryID = const Value.absent()}) =>
      CategoryInDB(
        id: id ?? this.id,
        name: name ?? this.name,
        iconId: iconId ?? this.iconId,
        color: color.present ? color.value : this.color,
        type: type.present ? type.value : this.type,
        parentCategoryID: parentCategoryID.present
            ? parentCategoryID.value
            : this.parentCategoryID,
      );
  @override
  String toString() {
    return (StringBuffer('CategoryInDB(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconId: $iconId, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentCategoryID: $parentCategoryID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconId, color, type, parentCategoryID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryInDB &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconId == this.iconId &&
          other.color == this.color &&
          other.type == this.type &&
          other.parentCategoryID == this.parentCategoryID);
}

class CategoriesCompanion extends UpdateCompanion<CategoryInDB> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconId;
  final Value<String?> color;
  final Value<CategoryType?> type;
  final Value<String?> parentCategoryID;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconId = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.parentCategoryID = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String iconId,
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.parentCategoryID = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconId = Value(iconId);
  static Insertable<CategoryInDB> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconId,
    Expression<String>? color,
    Expression<String>? type,
    Expression<String>? parentCategoryID,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconId != null) 'iconId': iconId,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (parentCategoryID != null) 'parentCategoryID': parentCategoryID,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? iconId,
      Value<String?>? color,
      Value<CategoryType?>? type,
      Value<String?>? parentCategoryID,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconId: iconId ?? this.iconId,
      color: color ?? this.color,
      type: type ?? this.type,
      parentCategoryID: parentCategoryID ?? this.parentCategoryID,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconId.present) {
      map['iconId'] = Variable<String>(iconId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      final converter = Categories.$convertertypen;
      map['type'] = Variable<String>(converter.toSql(type.value));
    }
    if (parentCategoryID.present) {
      map['parentCategoryID'] = Variable<String>(parentCategoryID.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconId: $iconId, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentCategoryID: $parentCategoryID, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Transactions extends Table with TableInfo<Transactions, TransactionInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Transactions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _accountIDMeta =
      const VerificationMeta('accountID');
  late final GeneratedColumn<String> accountID = GeneratedColumn<String>(
      'accountID', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES accounts(id)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumnWithTypeConverter<TransactionStatus?,
      String> status = GeneratedColumn<String>('status', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'CHECK (status IN (\'voided\', \'pending\', \'reconcilied\', \'unreconcilied\'))')
      .withConverter<TransactionStatus?>(Transactions.$converterstatusn);
  static const VerificationMeta _categoryIDMeta =
      const VerificationMeta('categoryID');
  late final GeneratedColumn<String> categoryID = GeneratedColumn<String>(
      'categoryID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'REFERENCES categories(id)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _valueInDestinyMeta =
      const VerificationMeta('valueInDestiny');
  late final GeneratedColumn<double> valueInDestiny = GeneratedColumn<double>(
      'valueInDestiny', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _receivingAccountIDMeta =
      const VerificationMeta('receivingAccountID');
  late final GeneratedColumn<String> receivingAccountID =
      GeneratedColumn<String>('receivingAccountID', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'REFERENCES accounts(id)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'isHidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountID,
        date,
        value,
        note,
        status,
        categoryID,
        valueInDestiny,
        receivingAccountID,
        isHidden
      ];
  @override
  String get aliasedName => _alias ?? 'transactions';
  @override
  String get actualTableName => 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('accountID')) {
      context.handle(_accountIDMeta,
          accountID.isAcceptableOrUnknown(data['accountID']!, _accountIDMeta));
    } else if (isInserting) {
      context.missing(_accountIDMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    context.handle(_statusMeta, const VerificationResult.success());
    if (data.containsKey('categoryID')) {
      context.handle(
          _categoryIDMeta,
          categoryID.isAcceptableOrUnknown(
              data['categoryID']!, _categoryIDMeta));
    }
    if (data.containsKey('valueInDestiny')) {
      context.handle(
          _valueInDestinyMeta,
          valueInDestiny.isAcceptableOrUnknown(
              data['valueInDestiny']!, _valueInDestinyMeta));
    }
    if (data.containsKey('receivingAccountID')) {
      context.handle(
          _receivingAccountIDMeta,
          receivingAccountID.isAcceptableOrUnknown(
              data['receivingAccountID']!, _receivingAccountIDMeta));
    }
    if (data.containsKey('isHidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['isHidden']!, _isHiddenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionInDB(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accountID'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      status: Transactions.$converterstatusn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])),
      categoryID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoryID']),
      valueInDestiny: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valueInDestiny']),
      receivingAccountID: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receivingAccountID']),
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isHidden'])!,
    );
  }

  @override
  Transactions createAlias(String alias) {
    return Transactions(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionStatus, String, String>
      $converterstatus =
      const EnumNameConverter<TransactionStatus>(TransactionStatus.values);
  static JsonTypeConverter2<TransactionStatus?, String?, String?>
      $converterstatusn = JsonTypeConverter2.asNullable($converterstatus);
  @override
  List<String> get customConstraints => const [
        'CHECK((receivingAccountID IS NULL)!=(categoryID IS NULL))',
        'CHECK(categoryID IS NULL OR valueInDestiny IS NULL)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class TransactionInDB extends DataClass implements Insertable<TransactionInDB> {
  final String id;
  final String accountID;
  final DateTime date;
  final double value;
  final String? note;
  final TransactionStatus? status;
  final String? categoryID;
  final double? valueInDestiny;
  final String? receivingAccountID;
  final bool isHidden;
  const TransactionInDB(
      {required this.id,
      required this.accountID,
      required this.date,
      required this.value,
      this.note,
      this.status,
      this.categoryID,
      this.valueInDestiny,
      this.receivingAccountID,
      required this.isHidden});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['accountID'] = Variable<String>(accountID);
    map['date'] = Variable<DateTime>(date);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || status != null) {
      final converter = Transactions.$converterstatusn;
      map['status'] = Variable<String>(converter.toSql(status));
    }
    if (!nullToAbsent || categoryID != null) {
      map['categoryID'] = Variable<String>(categoryID);
    }
    if (!nullToAbsent || valueInDestiny != null) {
      map['valueInDestiny'] = Variable<double>(valueInDestiny);
    }
    if (!nullToAbsent || receivingAccountID != null) {
      map['receivingAccountID'] = Variable<String>(receivingAccountID);
    }
    map['isHidden'] = Variable<bool>(isHidden);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountID: Value(accountID),
      date: Value(date),
      value: Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      categoryID: categoryID == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryID),
      valueInDestiny: valueInDestiny == null && nullToAbsent
          ? const Value.absent()
          : Value(valueInDestiny),
      receivingAccountID: receivingAccountID == null && nullToAbsent
          ? const Value.absent()
          : Value(receivingAccountID),
      isHidden: Value(isHidden),
    );
  }

  factory TransactionInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionInDB(
      id: serializer.fromJson<String>(json['id']),
      accountID: serializer.fromJson<String>(json['accountID']),
      date: serializer.fromJson<DateTime>(json['date']),
      value: serializer.fromJson<double>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
      status: Transactions.$converterstatusn
          .fromJson(serializer.fromJson<String?>(json['status'])),
      categoryID: serializer.fromJson<String?>(json['categoryID']),
      valueInDestiny: serializer.fromJson<double?>(json['valueInDestiny']),
      receivingAccountID:
          serializer.fromJson<String?>(json['receivingAccountID']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountID': serializer.toJson<String>(accountID),
      'date': serializer.toJson<DateTime>(date),
      'value': serializer.toJson<double>(value),
      'note': serializer.toJson<String?>(note),
      'status': serializer
          .toJson<String?>(Transactions.$converterstatusn.toJson(status)),
      'categoryID': serializer.toJson<String?>(categoryID),
      'valueInDestiny': serializer.toJson<double?>(valueInDestiny),
      'receivingAccountID': serializer.toJson<String?>(receivingAccountID),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  TransactionInDB copyWith(
          {String? id,
          String? accountID,
          DateTime? date,
          double? value,
          Value<String?> note = const Value.absent(),
          Value<TransactionStatus?> status = const Value.absent(),
          Value<String?> categoryID = const Value.absent(),
          Value<double?> valueInDestiny = const Value.absent(),
          Value<String?> receivingAccountID = const Value.absent(),
          bool? isHidden}) =>
      TransactionInDB(
        id: id ?? this.id,
        accountID: accountID ?? this.accountID,
        date: date ?? this.date,
        value: value ?? this.value,
        note: note.present ? note.value : this.note,
        status: status.present ? status.value : this.status,
        categoryID: categoryID.present ? categoryID.value : this.categoryID,
        valueInDestiny:
            valueInDestiny.present ? valueInDestiny.value : this.valueInDestiny,
        receivingAccountID: receivingAccountID.present
            ? receivingAccountID.value
            : this.receivingAccountID,
        isHidden: isHidden ?? this.isHidden,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionInDB(')
          ..write('id: $id, ')
          ..write('accountID: $accountID, ')
          ..write('date: $date, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('categoryID: $categoryID, ')
          ..write('valueInDestiny: $valueInDestiny, ')
          ..write('receivingAccountID: $receivingAccountID, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountID, date, value, note, status,
      categoryID, valueInDestiny, receivingAccountID, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionInDB &&
          other.id == this.id &&
          other.accountID == this.accountID &&
          other.date == this.date &&
          other.value == this.value &&
          other.note == this.note &&
          other.status == this.status &&
          other.categoryID == this.categoryID &&
          other.valueInDestiny == this.valueInDestiny &&
          other.receivingAccountID == this.receivingAccountID &&
          other.isHidden == this.isHidden);
}

class TransactionsCompanion extends UpdateCompanion<TransactionInDB> {
  final Value<String> id;
  final Value<String> accountID;
  final Value<DateTime> date;
  final Value<double> value;
  final Value<String?> note;
  final Value<TransactionStatus?> status;
  final Value<String?> categoryID;
  final Value<double?> valueInDestiny;
  final Value<String?> receivingAccountID;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountID = const Value.absent(),
    this.date = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.categoryID = const Value.absent(),
    this.valueInDestiny = const Value.absent(),
    this.receivingAccountID = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String accountID,
    required DateTime date,
    required double value,
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.categoryID = const Value.absent(),
    this.valueInDestiny = const Value.absent(),
    this.receivingAccountID = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountID = Value(accountID),
        date = Value(date),
        value = Value(value);
  static Insertable<TransactionInDB> custom({
    Expression<String>? id,
    Expression<String>? accountID,
    Expression<DateTime>? date,
    Expression<double>? value,
    Expression<String>? note,
    Expression<String>? status,
    Expression<String>? categoryID,
    Expression<double>? valueInDestiny,
    Expression<String>? receivingAccountID,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountID != null) 'accountID': accountID,
      if (date != null) 'date': date,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (categoryID != null) 'categoryID': categoryID,
      if (valueInDestiny != null) 'valueInDestiny': valueInDestiny,
      if (receivingAccountID != null) 'receivingAccountID': receivingAccountID,
      if (isHidden != null) 'isHidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountID,
      Value<DateTime>? date,
      Value<double>? value,
      Value<String?>? note,
      Value<TransactionStatus?>? status,
      Value<String?>? categoryID,
      Value<double?>? valueInDestiny,
      Value<String?>? receivingAccountID,
      Value<bool>? isHidden,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountID: accountID ?? this.accountID,
      date: date ?? this.date,
      value: value ?? this.value,
      note: note ?? this.note,
      status: status ?? this.status,
      categoryID: categoryID ?? this.categoryID,
      valueInDestiny: valueInDestiny ?? this.valueInDestiny,
      receivingAccountID: receivingAccountID ?? this.receivingAccountID,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountID.present) {
      map['accountID'] = Variable<String>(accountID.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      final converter = Transactions.$converterstatusn;
      map['status'] = Variable<String>(converter.toSql(status.value));
    }
    if (categoryID.present) {
      map['categoryID'] = Variable<String>(categoryID.value);
    }
    if (valueInDestiny.present) {
      map['valueInDestiny'] = Variable<double>(valueInDestiny.value);
    }
    if (receivingAccountID.present) {
      map['receivingAccountID'] = Variable<String>(receivingAccountID.value);
    }
    if (isHidden.present) {
      map['isHidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountID: $accountID, ')
          ..write('date: $date, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('categoryID: $categoryID, ')
          ..write('valueInDestiny: $valueInDestiny, ')
          ..write('receivingAccountID: $receivingAccountID, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ExchangeRates extends Table
    with TableInfo<ExchangeRates, ExchangeRateInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExchangeRates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currencyCode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES currencies(code)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchangeRate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [date, currencyCode, exchangeRate];
  @override
  String get aliasedName => _alias ?? 'exchangeRates';
  @override
  String get actualTableName => 'exchangeRates';
  @override
  VerificationContext validateIntegrity(Insertable<ExchangeRateInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('currencyCode')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currencyCode']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchangeRate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchangeRate']!, _exchangeRateMeta));
    } else if (isInserting) {
      context.missing(_exchangeRateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, currencyCode};
  @override
  ExchangeRateInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateInDB(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currencyCode'])!,
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchangeRate'])!,
    );
  }

  @override
  ExchangeRates createAlias(String alias) {
    return ExchangeRates(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['PRIMARY KEY(date, currencyCode)'];
  @override
  bool get dontWriteConstraints => true;
}

class ExchangeRateInDB extends DataClass
    implements Insertable<ExchangeRateInDB> {
  final DateTime date;
  final String currencyCode;
  final double exchangeRate;
  const ExchangeRateInDB(
      {required this.date,
      required this.currencyCode,
      required this.exchangeRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['currencyCode'] = Variable<String>(currencyCode);
    map['exchangeRate'] = Variable<double>(exchangeRate);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      date: Value(date),
      currencyCode: Value(currencyCode),
      exchangeRate: Value(exchangeRate),
    );
  }

  factory ExchangeRateInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateInDB(
      date: serializer.fromJson<DateTime>(json['date']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
    };
  }

  ExchangeRateInDB copyWith(
          {DateTime? date, String? currencyCode, double? exchangeRate}) =>
      ExchangeRateInDB(
        date: date ?? this.date,
        currencyCode: currencyCode ?? this.currencyCode,
        exchangeRate: exchangeRate ?? this.exchangeRate,
      );
  @override
  String toString() {
    return (StringBuffer('ExchangeRateInDB(')
          ..write('date: $date, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRate: $exchangeRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, currencyCode, exchangeRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateInDB &&
          other.date == this.date &&
          other.currencyCode == this.currencyCode &&
          other.exchangeRate == this.exchangeRate);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRateInDB> {
  final Value<DateTime> date;
  final Value<String> currencyCode;
  final Value<double> exchangeRate;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.date = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required DateTime date,
    required String currencyCode,
    required double exchangeRate,
    this.rowid = const Value.absent(),
  })  : date = Value(date),
        currencyCode = Value(currencyCode),
        exchangeRate = Value(exchangeRate);
  static Insertable<ExchangeRateInDB> custom({
    Expression<DateTime>? date,
    Expression<String>? currencyCode,
    Expression<double>? exchangeRate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (exchangeRate != null) 'exchangeRate': exchangeRate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith(
      {Value<DateTime>? date,
      Value<String>? currencyCode,
      Value<double>? exchangeRate,
      Value<int>? rowid}) {
    return ExchangeRatesCompanion(
      date: date ?? this.date,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (currencyCode.present) {
      map['currencyCode'] = Variable<String>(currencyCode.value);
    }
    if (exchangeRate.present) {
      map['exchangeRate'] = Variable<double>(exchangeRate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('date: $date, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CurrencyNames extends Table with TableInfo<CurrencyNames, CurrencyName> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CurrencyNames(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currencyCode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL PRIMARY KEY REFERENCES currencies(code)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _enMeta = const VerificationMeta('en');
  late final GeneratedColumn<String> en = GeneratedColumn<String>(
      'en', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _esMeta = const VerificationMeta('es');
  late final GeneratedColumn<String> es = GeneratedColumn<String>(
      'es', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [currencyCode, en, es];
  @override
  String get aliasedName => _alias ?? 'currencyNames';
  @override
  String get actualTableName => 'currencyNames';
  @override
  VerificationContext validateIntegrity(Insertable<CurrencyName> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('currencyCode')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currencyCode']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('en')) {
      context.handle(_enMeta, en.isAcceptableOrUnknown(data['en']!, _enMeta));
    } else if (isInserting) {
      context.missing(_enMeta);
    }
    if (data.containsKey('es')) {
      context.handle(_esMeta, es.isAcceptableOrUnknown(data['es']!, _esMeta));
    } else if (isInserting) {
      context.missing(_esMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {currencyCode};
  @override
  CurrencyName map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyName(
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currencyCode'])!,
      en: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}en'])!,
      es: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}es'])!,
    );
  }

  @override
  CurrencyNames createAlias(String alias) {
    return CurrencyNames(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CurrencyName extends DataClass implements Insertable<CurrencyName> {
  final String currencyCode;
  final String en;
  final String es;
  const CurrencyName(
      {required this.currencyCode, required this.en, required this.es});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['currencyCode'] = Variable<String>(currencyCode);
    map['en'] = Variable<String>(en);
    map['es'] = Variable<String>(es);
    return map;
  }

  CurrencyNamesCompanion toCompanion(bool nullToAbsent) {
    return CurrencyNamesCompanion(
      currencyCode: Value(currencyCode),
      en: Value(en),
      es: Value(es),
    );
  }

  factory CurrencyName.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyName(
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      en: serializer.fromJson<String>(json['en']),
      es: serializer.fromJson<String>(json['es']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'currencyCode': serializer.toJson<String>(currencyCode),
      'en': serializer.toJson<String>(en),
      'es': serializer.toJson<String>(es),
    };
  }

  CurrencyName copyWith({String? currencyCode, String? en, String? es}) =>
      CurrencyName(
        currencyCode: currencyCode ?? this.currencyCode,
        en: en ?? this.en,
        es: es ?? this.es,
      );
  @override
  String toString() {
    return (StringBuffer('CurrencyName(')
          ..write('currencyCode: $currencyCode, ')
          ..write('en: $en, ')
          ..write('es: $es')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(currencyCode, en, es);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyName &&
          other.currencyCode == this.currencyCode &&
          other.en == this.en &&
          other.es == this.es);
}

class CurrencyNamesCompanion extends UpdateCompanion<CurrencyName> {
  final Value<String> currencyCode;
  final Value<String> en;
  final Value<String> es;
  final Value<int> rowid;
  const CurrencyNamesCompanion({
    this.currencyCode = const Value.absent(),
    this.en = const Value.absent(),
    this.es = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrencyNamesCompanion.insert({
    required String currencyCode,
    required String en,
    required String es,
    this.rowid = const Value.absent(),
  })  : currencyCode = Value(currencyCode),
        en = Value(en),
        es = Value(es);
  static Insertable<CurrencyName> custom({
    Expression<String>? currencyCode,
    Expression<String>? en,
    Expression<String>? es,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (en != null) 'en': en,
      if (es != null) 'es': es,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrencyNamesCompanion copyWith(
      {Value<String>? currencyCode,
      Value<String>? en,
      Value<String>? es,
      Value<int>? rowid}) {
    return CurrencyNamesCompanion(
      currencyCode: currencyCode ?? this.currencyCode,
      en: en ?? this.en,
      es: es ?? this.es,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (currencyCode.present) {
      map['currencyCode'] = Variable<String>(currencyCode.value);
    }
    if (en.present) {
      map['en'] = Variable<String>(en.value);
    }
    if (es.present) {
      map['es'] = Variable<String>(es.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyNamesCompanion(')
          ..write('currencyCode: $currencyCode, ')
          ..write('en: $en, ')
          ..write('es: $es, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserSettings extends Table with TableInfo<UserSettings, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserSettings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta =
      const VerificationMeta('settingKey');
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
      'settingKey', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _settingValueMeta =
      const VerificationMeta('settingValue');
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
      'settingValue', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? 'userSettings';
  @override
  String get actualTableName => 'userSettings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('settingKey')) {
      context.handle(
          _settingKeyMeta,
          settingKey.isAcceptableOrUnknown(
              data['settingKey']!, _settingKeyMeta));
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('settingValue')) {
      context.handle(
          _settingValueMeta,
          settingValue.isAcceptableOrUnknown(
              data['settingValue']!, _settingValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      settingKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settingKey'])!,
      settingValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settingValue']),
    );
  }

  @override
  UserSettings createAlias(String alias) {
    return UserSettings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String settingKey;
  final String? settingValue;
  const UserSetting({required this.settingKey, this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['settingKey'] = Variable<String>(settingKey);
    if (!nullToAbsent || settingValue != null) {
      map['settingValue'] = Variable<String>(settingValue);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: settingValue == null && nullToAbsent
          ? const Value.absent()
          : Value(settingValue),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String?>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String?>(settingValue),
    };
  }

  UserSetting copyWith(
          {String? settingKey,
          Value<String?> settingValue = const Value.absent()}) =>
      UserSetting(
        settingKey: settingKey ?? this.settingKey,
        settingValue:
            settingValue.present ? settingValue.value : this.settingValue,
      );
  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> settingKey;
  final Value<String?> settingValue;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String settingKey,
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey);
  static Insertable<UserSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'settingKey': settingKey,
      if (settingValue != null) 'settingValue': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? settingKey,
      Value<String?>? settingValue,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['settingKey'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['settingValue'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AppData extends Table with TableInfo<AppData, AppDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppData(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _appDataKeyMeta =
      const VerificationMeta('appDataKey');
  late final GeneratedColumn<String> appDataKey = GeneratedColumn<String>(
      'appDataKey', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _appDataValueMeta =
      const VerificationMeta('appDataValue');
  late final GeneratedColumn<String> appDataValue = GeneratedColumn<String>(
      'appDataValue', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [appDataKey, appDataValue];
  @override
  String get aliasedName => _alias ?? 'appData';
  @override
  String get actualTableName => 'appData';
  @override
  VerificationContext validateIntegrity(Insertable<AppDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('appDataKey')) {
      context.handle(
          _appDataKeyMeta,
          appDataKey.isAcceptableOrUnknown(
              data['appDataKey']!, _appDataKeyMeta));
    } else if (isInserting) {
      context.missing(_appDataKeyMeta);
    }
    if (data.containsKey('appDataValue')) {
      context.handle(
          _appDataValueMeta,
          appDataValue.isAcceptableOrUnknown(
              data['appDataValue']!, _appDataValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {appDataKey};
  @override
  AppDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppDataData(
      appDataKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appDataKey'])!,
      appDataValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appDataValue']),
    );
  }

  @override
  AppData createAlias(String alias) {
    return AppData(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AppDataData extends DataClass implements Insertable<AppDataData> {
  final String appDataKey;
  final String? appDataValue;
  const AppDataData({required this.appDataKey, this.appDataValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['appDataKey'] = Variable<String>(appDataKey);
    if (!nullToAbsent || appDataValue != null) {
      map['appDataValue'] = Variable<String>(appDataValue);
    }
    return map;
  }

  AppDataCompanion toCompanion(bool nullToAbsent) {
    return AppDataCompanion(
      appDataKey: Value(appDataKey),
      appDataValue: appDataValue == null && nullToAbsent
          ? const Value.absent()
          : Value(appDataValue),
    );
  }

  factory AppDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppDataData(
      appDataKey: serializer.fromJson<String>(json['appDataKey']),
      appDataValue: serializer.fromJson<String?>(json['appDataValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appDataKey': serializer.toJson<String>(appDataKey),
      'appDataValue': serializer.toJson<String?>(appDataValue),
    };
  }

  AppDataData copyWith(
          {String? appDataKey,
          Value<String?> appDataValue = const Value.absent()}) =>
      AppDataData(
        appDataKey: appDataKey ?? this.appDataKey,
        appDataValue:
            appDataValue.present ? appDataValue.value : this.appDataValue,
      );
  @override
  String toString() {
    return (StringBuffer('AppDataData(')
          ..write('appDataKey: $appDataKey, ')
          ..write('appDataValue: $appDataValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(appDataKey, appDataValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppDataData &&
          other.appDataKey == this.appDataKey &&
          other.appDataValue == this.appDataValue);
}

class AppDataCompanion extends UpdateCompanion<AppDataData> {
  final Value<String> appDataKey;
  final Value<String?> appDataValue;
  final Value<int> rowid;
  const AppDataCompanion({
    this.appDataKey = const Value.absent(),
    this.appDataValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppDataCompanion.insert({
    required String appDataKey,
    this.appDataValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : appDataKey = Value(appDataKey);
  static Insertable<AppDataData> custom({
    Expression<String>? appDataKey,
    Expression<String>? appDataValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (appDataKey != null) 'appDataKey': appDataKey,
      if (appDataValue != null) 'appDataValue': appDataValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppDataCompanion copyWith(
      {Value<String>? appDataKey,
      Value<String?>? appDataValue,
      Value<int>? rowid}) {
    return AppDataCompanion(
      appDataKey: appDataKey ?? this.appDataKey,
      appDataValue: appDataValue ?? this.appDataValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (appDataKey.present) {
      map['appDataKey'] = Variable<String>(appDataKey.value);
    }
    if (appDataValue.present) {
      map['appDataValue'] = Variable<String>(appDataValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppDataCompanion(')
          ..write('appDataKey: $appDataKey, ')
          ..write('appDataValue: $appDataValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class RecurrentRules extends Table
    with TableInfo<RecurrentRules, RecurrentRuleInDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RecurrentRules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _accountIDMeta =
      const VerificationMeta('accountID');
  late final GeneratedColumn<String> accountID = GeneratedColumn<String>(
      'accountID', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES accounts(id)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _nextPaymentDateMeta =
      const VerificationMeta('nextPaymentDate');
  late final GeneratedColumn<DateTime> nextPaymentDate =
      GeneratedColumn<DateTime>('nextPaymentDate', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: true,
          $customConstraints: 'NOT NULL');
  static const VerificationMeta _intervalPeriodMeta =
      const VerificationMeta('intervalPeriod');
  late final GeneratedColumn<String> intervalPeriod = GeneratedColumn<String>(
      'intervalPeriod', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _intervalEachMeta =
      const VerificationMeta('intervalEach');
  late final GeneratedColumn<String> intervalEach = GeneratedColumn<String>(
      'intervalEach', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 1',
      defaultValue: const CustomExpression('1'));
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'endDate', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _categoryIDMeta =
      const VerificationMeta('categoryID');
  late final GeneratedColumn<String> categoryID = GeneratedColumn<String>(
      'categoryID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'REFERENCES categories(id)ON UPDATE CASCADE ON DELETE CASCADE');
  static const VerificationMeta _valueInDestinyMeta =
      const VerificationMeta('valueInDestiny');
  late final GeneratedColumn<double> valueInDestiny = GeneratedColumn<double>(
      'valueInDestiny', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _receivingAccountIDMeta =
      const VerificationMeta('receivingAccountID');
  late final GeneratedColumn<String> receivingAccountID =
      GeneratedColumn<String>('receivingAccountID', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'REFERENCES accounts(id)ON UPDATE CASCADE ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountID,
        nextPaymentDate,
        intervalPeriod,
        intervalEach,
        endDate,
        value,
        note,
        categoryID,
        valueInDestiny,
        receivingAccountID
      ];
  @override
  String get aliasedName => _alias ?? 'recurrentRules';
  @override
  String get actualTableName => 'recurrentRules';
  @override
  VerificationContext validateIntegrity(Insertable<RecurrentRuleInDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('accountID')) {
      context.handle(_accountIDMeta,
          accountID.isAcceptableOrUnknown(data['accountID']!, _accountIDMeta));
    } else if (isInserting) {
      context.missing(_accountIDMeta);
    }
    if (data.containsKey('nextPaymentDate')) {
      context.handle(
          _nextPaymentDateMeta,
          nextPaymentDate.isAcceptableOrUnknown(
              data['nextPaymentDate']!, _nextPaymentDateMeta));
    } else if (isInserting) {
      context.missing(_nextPaymentDateMeta);
    }
    if (data.containsKey('intervalPeriod')) {
      context.handle(
          _intervalPeriodMeta,
          intervalPeriod.isAcceptableOrUnknown(
              data['intervalPeriod']!, _intervalPeriodMeta));
    } else if (isInserting) {
      context.missing(_intervalPeriodMeta);
    }
    if (data.containsKey('intervalEach')) {
      context.handle(
          _intervalEachMeta,
          intervalEach.isAcceptableOrUnknown(
              data['intervalEach']!, _intervalEachMeta));
    }
    if (data.containsKey('endDate')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['endDate']!, _endDateMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('categoryID')) {
      context.handle(
          _categoryIDMeta,
          categoryID.isAcceptableOrUnknown(
              data['categoryID']!, _categoryIDMeta));
    }
    if (data.containsKey('valueInDestiny')) {
      context.handle(
          _valueInDestinyMeta,
          valueInDestiny.isAcceptableOrUnknown(
              data['valueInDestiny']!, _valueInDestinyMeta));
    }
    if (data.containsKey('receivingAccountID')) {
      context.handle(
          _receivingAccountIDMeta,
          receivingAccountID.isAcceptableOrUnknown(
              data['receivingAccountID']!, _receivingAccountIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrentRuleInDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrentRuleInDB(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accountID'])!,
      nextPaymentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}nextPaymentDate'])!,
      intervalPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intervalPeriod'])!,
      intervalEach: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intervalEach'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}endDate']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      categoryID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoryID']),
      valueInDestiny: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valueInDestiny']),
      receivingAccountID: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receivingAccountID']),
    );
  }

  @override
  RecurrentRules createAlias(String alias) {
    return RecurrentRules(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'CHECK((receivingAccountID IS NULL)!=(categoryID IS NULL))',
        'CHECK(categoryID IS NULL OR valueInDestiny IS NULL)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class RecurrentRuleInDB extends DataClass
    implements Insertable<RecurrentRuleInDB> {
  final String id;
  final String accountID;
  final DateTime nextPaymentDate;
  final String intervalPeriod;
  final String intervalEach;
  final DateTime? endDate;
  final double value;
  final String? note;
  final String? categoryID;
  final double? valueInDestiny;
  final String? receivingAccountID;
  const RecurrentRuleInDB(
      {required this.id,
      required this.accountID,
      required this.nextPaymentDate,
      required this.intervalPeriod,
      required this.intervalEach,
      this.endDate,
      required this.value,
      this.note,
      this.categoryID,
      this.valueInDestiny,
      this.receivingAccountID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['accountID'] = Variable<String>(accountID);
    map['nextPaymentDate'] = Variable<DateTime>(nextPaymentDate);
    map['intervalPeriod'] = Variable<String>(intervalPeriod);
    map['intervalEach'] = Variable<String>(intervalEach);
    if (!nullToAbsent || endDate != null) {
      map['endDate'] = Variable<DateTime>(endDate);
    }
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryID != null) {
      map['categoryID'] = Variable<String>(categoryID);
    }
    if (!nullToAbsent || valueInDestiny != null) {
      map['valueInDestiny'] = Variable<double>(valueInDestiny);
    }
    if (!nullToAbsent || receivingAccountID != null) {
      map['receivingAccountID'] = Variable<String>(receivingAccountID);
    }
    return map;
  }

  RecurrentRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurrentRulesCompanion(
      id: Value(id),
      accountID: Value(accountID),
      nextPaymentDate: Value(nextPaymentDate),
      intervalPeriod: Value(intervalPeriod),
      intervalEach: Value(intervalEach),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      value: Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryID: categoryID == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryID),
      valueInDestiny: valueInDestiny == null && nullToAbsent
          ? const Value.absent()
          : Value(valueInDestiny),
      receivingAccountID: receivingAccountID == null && nullToAbsent
          ? const Value.absent()
          : Value(receivingAccountID),
    );
  }

  factory RecurrentRuleInDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrentRuleInDB(
      id: serializer.fromJson<String>(json['id']),
      accountID: serializer.fromJson<String>(json['accountID']),
      nextPaymentDate: serializer.fromJson<DateTime>(json['nextPaymentDate']),
      intervalPeriod: serializer.fromJson<String>(json['intervalPeriod']),
      intervalEach: serializer.fromJson<String>(json['intervalEach']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      value: serializer.fromJson<double>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
      categoryID: serializer.fromJson<String?>(json['categoryID']),
      valueInDestiny: serializer.fromJson<double?>(json['valueInDestiny']),
      receivingAccountID:
          serializer.fromJson<String?>(json['receivingAccountID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountID': serializer.toJson<String>(accountID),
      'nextPaymentDate': serializer.toJson<DateTime>(nextPaymentDate),
      'intervalPeriod': serializer.toJson<String>(intervalPeriod),
      'intervalEach': serializer.toJson<String>(intervalEach),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'value': serializer.toJson<double>(value),
      'note': serializer.toJson<String?>(note),
      'categoryID': serializer.toJson<String?>(categoryID),
      'valueInDestiny': serializer.toJson<double?>(valueInDestiny),
      'receivingAccountID': serializer.toJson<String?>(receivingAccountID),
    };
  }

  RecurrentRuleInDB copyWith(
          {String? id,
          String? accountID,
          DateTime? nextPaymentDate,
          String? intervalPeriod,
          String? intervalEach,
          Value<DateTime?> endDate = const Value.absent(),
          double? value,
          Value<String?> note = const Value.absent(),
          Value<String?> categoryID = const Value.absent(),
          Value<double?> valueInDestiny = const Value.absent(),
          Value<String?> receivingAccountID = const Value.absent()}) =>
      RecurrentRuleInDB(
        id: id ?? this.id,
        accountID: accountID ?? this.accountID,
        nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
        intervalPeriod: intervalPeriod ?? this.intervalPeriod,
        intervalEach: intervalEach ?? this.intervalEach,
        endDate: endDate.present ? endDate.value : this.endDate,
        value: value ?? this.value,
        note: note.present ? note.value : this.note,
        categoryID: categoryID.present ? categoryID.value : this.categoryID,
        valueInDestiny:
            valueInDestiny.present ? valueInDestiny.value : this.valueInDestiny,
        receivingAccountID: receivingAccountID.present
            ? receivingAccountID.value
            : this.receivingAccountID,
      );
  @override
  String toString() {
    return (StringBuffer('RecurrentRuleInDB(')
          ..write('id: $id, ')
          ..write('accountID: $accountID, ')
          ..write('nextPaymentDate: $nextPaymentDate, ')
          ..write('intervalPeriod: $intervalPeriod, ')
          ..write('intervalEach: $intervalEach, ')
          ..write('endDate: $endDate, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('categoryID: $categoryID, ')
          ..write('valueInDestiny: $valueInDestiny, ')
          ..write('receivingAccountID: $receivingAccountID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      accountID,
      nextPaymentDate,
      intervalPeriod,
      intervalEach,
      endDate,
      value,
      note,
      categoryID,
      valueInDestiny,
      receivingAccountID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrentRuleInDB &&
          other.id == this.id &&
          other.accountID == this.accountID &&
          other.nextPaymentDate == this.nextPaymentDate &&
          other.intervalPeriod == this.intervalPeriod &&
          other.intervalEach == this.intervalEach &&
          other.endDate == this.endDate &&
          other.value == this.value &&
          other.note == this.note &&
          other.categoryID == this.categoryID &&
          other.valueInDestiny == this.valueInDestiny &&
          other.receivingAccountID == this.receivingAccountID);
}

class RecurrentRulesCompanion extends UpdateCompanion<RecurrentRuleInDB> {
  final Value<String> id;
  final Value<String> accountID;
  final Value<DateTime> nextPaymentDate;
  final Value<String> intervalPeriod;
  final Value<String> intervalEach;
  final Value<DateTime?> endDate;
  final Value<double> value;
  final Value<String?> note;
  final Value<String?> categoryID;
  final Value<double?> valueInDestiny;
  final Value<String?> receivingAccountID;
  final Value<int> rowid;
  const RecurrentRulesCompanion({
    this.id = const Value.absent(),
    this.accountID = const Value.absent(),
    this.nextPaymentDate = const Value.absent(),
    this.intervalPeriod = const Value.absent(),
    this.intervalEach = const Value.absent(),
    this.endDate = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryID = const Value.absent(),
    this.valueInDestiny = const Value.absent(),
    this.receivingAccountID = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrentRulesCompanion.insert({
    required String id,
    required String accountID,
    required DateTime nextPaymentDate,
    required String intervalPeriod,
    this.intervalEach = const Value.absent(),
    this.endDate = const Value.absent(),
    required double value,
    this.note = const Value.absent(),
    this.categoryID = const Value.absent(),
    this.valueInDestiny = const Value.absent(),
    this.receivingAccountID = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountID = Value(accountID),
        nextPaymentDate = Value(nextPaymentDate),
        intervalPeriod = Value(intervalPeriod),
        value = Value(value);
  static Insertable<RecurrentRuleInDB> custom({
    Expression<String>? id,
    Expression<String>? accountID,
    Expression<DateTime>? nextPaymentDate,
    Expression<String>? intervalPeriod,
    Expression<String>? intervalEach,
    Expression<DateTime>? endDate,
    Expression<double>? value,
    Expression<String>? note,
    Expression<String>? categoryID,
    Expression<double>? valueInDestiny,
    Expression<String>? receivingAccountID,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountID != null) 'accountID': accountID,
      if (nextPaymentDate != null) 'nextPaymentDate': nextPaymentDate,
      if (intervalPeriod != null) 'intervalPeriod': intervalPeriod,
      if (intervalEach != null) 'intervalEach': intervalEach,
      if (endDate != null) 'endDate': endDate,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (categoryID != null) 'categoryID': categoryID,
      if (valueInDestiny != null) 'valueInDestiny': valueInDestiny,
      if (receivingAccountID != null) 'receivingAccountID': receivingAccountID,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrentRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountID,
      Value<DateTime>? nextPaymentDate,
      Value<String>? intervalPeriod,
      Value<String>? intervalEach,
      Value<DateTime?>? endDate,
      Value<double>? value,
      Value<String?>? note,
      Value<String?>? categoryID,
      Value<double?>? valueInDestiny,
      Value<String?>? receivingAccountID,
      Value<int>? rowid}) {
    return RecurrentRulesCompanion(
      id: id ?? this.id,
      accountID: accountID ?? this.accountID,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      intervalPeriod: intervalPeriod ?? this.intervalPeriod,
      intervalEach: intervalEach ?? this.intervalEach,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      note: note ?? this.note,
      categoryID: categoryID ?? this.categoryID,
      valueInDestiny: valueInDestiny ?? this.valueInDestiny,
      receivingAccountID: receivingAccountID ?? this.receivingAccountID,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountID.present) {
      map['accountID'] = Variable<String>(accountID.value);
    }
    if (nextPaymentDate.present) {
      map['nextPaymentDate'] = Variable<DateTime>(nextPaymentDate.value);
    }
    if (intervalPeriod.present) {
      map['intervalPeriod'] = Variable<String>(intervalPeriod.value);
    }
    if (intervalEach.present) {
      map['intervalEach'] = Variable<String>(intervalEach.value);
    }
    if (endDate.present) {
      map['endDate'] = Variable<DateTime>(endDate.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryID.present) {
      map['categoryID'] = Variable<String>(categoryID.value);
    }
    if (valueInDestiny.present) {
      map['valueInDestiny'] = Variable<double>(valueInDestiny.value);
    }
    if (receivingAccountID.present) {
      map['receivingAccountID'] = Variable<String>(receivingAccountID.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrentRulesCompanion(')
          ..write('id: $id, ')
          ..write('accountID: $accountID, ')
          ..write('nextPaymentDate: $nextPaymentDate, ')
          ..write('intervalPeriod: $intervalPeriod, ')
          ..write('intervalEach: $intervalEach, ')
          ..write('endDate: $endDate, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('categoryID: $categoryID, ')
          ..write('valueInDestiny: $valueInDestiny, ')
          ..write('receivingAccountID: $receivingAccountID, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseImpl extends GeneratedDatabase {
  _$DatabaseImpl(QueryExecutor e) : super(e);
  late final Currencies currencies = Currencies(this);
  late final Accounts accounts = Accounts(this);
  late final Categories categories = Categories(this);
  late final Transactions transactions = Transactions(this);
  late final ExchangeRates exchangeRates = ExchangeRates(this);
  late final CurrencyNames currencyNames = CurrencyNames(this);
  late final UserSettings userSettings = UserSettings(this);
  late final AppData appData = AppData(this);
  late final RecurrentRules recurrentRules = RecurrentRules(this);
  Selectable<Account> getAccountsWithFullData(
      {GetAccountsWithFullData$predicate? predicate, required double limit}) {
    var $arrayStartIndex = 2;
    final generatedpredicate = $write(
        predicate?.call(alias(this.accounts, 'a'),
                alias(this.currencies, 'currency')) ??
            const CustomExpression('(TRUE)'),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    return customSelect(
        'SELECT a.*,"currency"."code" AS "nested_0.code", "currency"."symbol" AS "nested_0.symbol" FROM accounts AS a INNER JOIN currencies AS currency ON a.currencyId = currency.code WHERE ${generatedpredicate.sql} LIMIT ?1',
        variables: [
          Variable<double>(limit),
          ...generatedpredicate.introducedVariables
        ],
        readsFrom: {
          accounts,
          currencies,
          ...generatedpredicate.watchedTables,
        }).asyncMap((QueryRow row) async => Account(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          iniValue: row.read<double>('iniValue'),
          date: row.read<DateTime>('date'),
          type: row.read<String>('type'),
          iconId: row.read<String>('iconId'),
          currency: await currencies.mapFromRow(row, tablePrefix: 'nested_0'),
          description: row.readNullable<String>('description'),
          iban: row.readNullable<String>('iban'),
          swift: row.readNullable<String>('swift'),
        ));
  }

  Selectable<MoneyTransaction> getTransactionsWithFullData(
      {GetTransactionsWithFullData$predicate? predicate,
      GetTransactionsWithFullData$orderBy? orderBy,
      required GetTransactionsWithFullData$limit limit}) {
    var $arrayStartIndex = 1;
    final generatedpredicate = $write(
        predicate?.call(
                alias(this.transactions, 't'),
                alias(this.accounts, 'a'),
                alias(this.accounts, 'ra'),
                alias(this.categories, 'c'),
                alias(this.categories, 'pc')) ??
            const CustomExpression('(TRUE)'),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    final generatedorderBy = $write(
        orderBy?.call(
                alias(this.transactions, 't'),
                alias(this.accounts, 'a'),
                alias(this.accounts, 'ra'),
                alias(this.categories, 'c'),
                alias(this.categories, 'pc')) ??
            const OrderBy.nothing(),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedorderBy.amountOfVariables;
    final generatedlimit = $write(
        limit(
            alias(this.transactions, 't'),
            alias(this.accounts, 'a'),
            alias(this.accounts, 'ra'),
            alias(this.categories, 'c'),
            alias(this.categories, 'pc')),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedlimit.amountOfVariables;
    return customSelect(
        'SELECT t.*,"a"."id" AS "nested_0.id", "a"."name" AS "nested_0.name", "a"."iniValue" AS "nested_0.iniValue", "a"."date" AS "nested_0.date", "a"."description" AS "nested_0.description", "a"."type" AS "nested_0.type", "a"."iconId" AS "nested_0.iconId", "a"."currencyId" AS "nested_0.currencyId", "a"."iban" AS "nested_0.iban", "a"."swift" AS "nested_0.swift","ra"."id" AS "nested_1.id", "ra"."name" AS "nested_1.name", "ra"."iniValue" AS "nested_1.iniValue", "ra"."date" AS "nested_1.date", "ra"."description" AS "nested_1.description", "ra"."type" AS "nested_1.type", "ra"."iconId" AS "nested_1.iconId", "ra"."currencyId" AS "nested_1.currencyId", "ra"."iban" AS "nested_1.iban", "ra"."swift" AS "nested_1.swift","c"."id" AS "nested_2.id", "c"."name" AS "nested_2.name", "c"."iconId" AS "nested_2.iconId", "c"."color" AS "nested_2.color", "c"."type" AS "nested_2.type", "c"."parentCategoryID" AS "nested_2.parentCategoryID","pc"."id" AS "nested_3.id", "pc"."name" AS "nested_3.name", "pc"."iconId" AS "nested_3.iconId", "pc"."color" AS "nested_3.color", "pc"."type" AS "nested_3.type", "pc"."parentCategoryID" AS "nested_3.parentCategoryID" FROM transactions AS t INNER JOIN accounts AS a ON t.accountID = a.id LEFT JOIN accounts AS ra ON t.receivingAccountID = ra.id LEFT JOIN categories AS c ON t.categoryID = c.id LEFT JOIN categories AS pc ON c.parentCategoryID = pc.id WHERE ${generatedpredicate.sql} ${generatedorderBy.sql} ${generatedlimit.sql}',
        variables: [
          ...generatedpredicate.introducedVariables,
          ...generatedorderBy.introducedVariables,
          ...generatedlimit.introducedVariables
        ],
        readsFrom: {
          transactions,
          accounts,
          categories,
          ...generatedpredicate.watchedTables,
          ...generatedorderBy.watchedTables,
          ...generatedlimit.watchedTables,
        }).asyncMap((QueryRow row) async => MoneyTransaction(
          id: row.read<String>('id'),
          account: await accounts.mapFromRow(row, tablePrefix: 'nested_0'),
          date: row.read<DateTime>('date'),
          value: row.read<double>('value'),
          isHidden: row.read<bool>('isHidden'),
          note: row.readNullable<String>('note'),
          status: NullAwareTypeConverter.wrapFromSql(
              Transactions.$converterstatus,
              row.readNullable<String>('status')),
          valueInDestiny: row.readNullable<double>('valueInDestiny'),
          receivingAccount:
              await accounts.mapFromRowOrNull(row, tablePrefix: 'nested_1'),
          category:
              await categories.mapFromRowOrNull(row, tablePrefix: 'nested_2'),
          parentCategory:
              await categories.mapFromRowOrNull(row, tablePrefix: 'nested_3'),
        ));
  }

  Selectable<Category> getCategoriesWithFullData(
      {GetCategoriesWithFullData$predicate? predicate, required double limit}) {
    var $arrayStartIndex = 2;
    final generatedpredicate = $write(
        predicate?.call(alias(this.categories, 'a'),
                alias(this.categories, 'parentCategory')) ??
            const CustomExpression('(TRUE)'),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    return customSelect(
        'SELECT a.*,"parentCategory"."id" AS "nested_0.id", "parentCategory"."name" AS "nested_0.name", "parentCategory"."iconId" AS "nested_0.iconId", "parentCategory"."color" AS "nested_0.color", "parentCategory"."type" AS "nested_0.type", "parentCategory"."parentCategoryID" AS "nested_0.parentCategoryID" FROM categories AS a LEFT JOIN categories AS parentCategory ON a.parentCategoryID = parentCategory.id WHERE ${generatedpredicate.sql} LIMIT ?1',
        variables: [
          Variable<double>(limit),
          ...generatedpredicate.introducedVariables
        ],
        readsFrom: {
          categories,
          ...generatedpredicate.watchedTables,
        }).asyncMap((QueryRow row) async => Category(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          iconId: row.read<String>('iconId'),
          color: row.readNullable<String>('color'),
          type: NullAwareTypeConverter.wrapFromSql(
              Categories.$convertertype, row.readNullable<String>('type')),
          parentCategory:
              await categories.mapFromRowOrNull(row, tablePrefix: 'nested_0'),
        ));
  }

  Selectable<ExchangeRate> getExchangeRates(
      {GetExchangeRates$predicate? predicate, required double limit}) {
    var $arrayStartIndex = 2;
    final generatedpredicate = $write(
        predicate?.call(alias(this.exchangeRates, 'e'),
                alias(this.currencies, 'currency')) ??
            const CustomExpression('(TRUE)'),
        hasMultipleTables: true,
        startIndex: $arrayStartIndex);
    $arrayStartIndex += generatedpredicate.amountOfVariables;
    return customSelect(
        'SELECT e.*,"currency"."code" AS "nested_0.code", "currency"."symbol" AS "nested_0.symbol" FROM exchangeRates AS e INNER JOIN currencies AS currency ON e.currencyCode = currency.code WHERE ${generatedpredicate.sql} ORDER BY date LIMIT ?1',
        variables: [
          Variable<double>(limit),
          ...generatedpredicate.introducedVariables
        ],
        readsFrom: {
          exchangeRates,
          currencies,
          ...generatedpredicate.watchedTables,
        }).asyncMap((QueryRow row) async => ExchangeRate(
          date: row.read<DateTime>('date'),
          currency: await currencies.mapFromRow(row, tablePrefix: 'nested_0'),
          exchangeRate: row.read<double>('exchangeRate'),
        ));
  }

  Selectable<ExchangeRate> getLastExchangeRates({required double limit}) {
    return customSelect(
        'SELECT er.*,"currency"."code" AS "nested_0.code", "currency"."symbol" AS "nested_0.symbol" FROM exchangeRates AS er INNER JOIN currencies AS currency ON er.currencyCode = currency.code WHERE date = (SELECT MAX(date) FROM exchangeRates WHERE currencyCode = er.currencyCode) ORDER BY currency.code LIMIT ?1',
        variables: [
          Variable<double>(limit)
        ],
        readsFrom: {
          exchangeRates,
          currencies,
        }).asyncMap((QueryRow row) async => ExchangeRate(
          date: row.read<DateTime>('date'),
          currency: await currencies.mapFromRow(row, tablePrefix: 'nested_0'),
          exchangeRate: row.read<double>('exchangeRate'),
        ));
  }

  Future<int> insertInitialCurrencies() {
    return customInsert(
      'INSERT INTO currencies VALUES (\'AED\', \'dh\'), (\'AFN\', \'Af.\'), (\'ALL\', \'Lek\'), (\'AMD\', \'Dram\'), (\'ANG\', \'ƒ\'), (\'AOA\', \'Kz\'), (\'ARS\', \'\$\'), (\'AUD\', \'\$\'), (\'AWG\', \'Afl.\'), (\'AZN\', \'man.\'), (\'BAM\', \'KM\'), (\'BBD\', \'\$\'), (\'BDT\', \'৳\'), (\'BGN\', \'lev\'), (\'BHD\', \'din\'), (\'BIF\', \'FBu\'), (\'BND\', \'\$\'), (\'BOB\', \'Bs\'), (\'BRL\', \'R\$\'), (\'BSD\', \'\$\'), (\'BTN\', \'Nu.\'), (\'BWP\', \'P\'), (\'BYR\', \'BYR\'), (\'BZD\', \'\$\'), (\'CAD\', \'\$\'), (\'CDF\', \'FrCD\'), (\'CHF\', \'CHF\'), (\'CLP\', \'\$\'), (\'CNY\', \'¥\'), (\'COP\', \'\$\'), (\'CRC\', \'₡\'), (\'CUP\', \'\$\'), (\'CVE\', \'CVE\'), (\'CZK\', \'Kč\'), (\'DJF\', \'Fdj\'), (\'DKK\', \'kr\'), (\'DOP\', \'\$\'), (\'DZD\', \'din\'), (\'EGP\', \'E£\'), (\'ERN\', \'Nfk\'), (\'ETB\', \'Birr\'), (\'EUR\', \'€\'), (\'FJD\', \'\$\'), (\'FKP\', \'£\'), (\'GBP\', \'£\'), (\'GEL\', \'GEL\'), (\'GHS\', \'GHS\'), (\'GIP\', \'£\'), (\'GMD\', \'GMD\'), (\'GNF\', \'FG\'), (\'GTQ\', \'Q\'), (\'HKD\', \'\$\'), (\'HNL\', \'L\'), (\'HRK\', \'kn\'), (\'HTG\', \'HTG\'), (\'HUF\', \'Ft\'), (\'IDR\', \'Rp\'), (\'ILS\', \'₪\'), (\'INR\', \'₹\'), (\'IQD\', \'din\'), (\'IRR\', \'Rial\'), (\'ISK\', \'kr\'), (\'JMD\', \'\$\'), (\'JOD\', \'din\'), (\'JPY\', \'¥\'), (\'KES\', \'Ksh\'), (\'KGS\', \'KGS\'), (\'KHR\', \'Riel\'), (\'KMF\', \'CF\'), (\'KPW\', \'₩\'), (\'KRW\', \'₩\'), (\'KWD\', \'din\'), (\'KYD\', \'\$\'), (\'KZT\', \'₸\'), (\'LAK\', \'₭\'), (\'LBP\', \'L£\'), (\'LKR\', \'Rs\'), (\'LRD\', \'\$\'), (\'LSL\', \'LSL\'), (\'LYD\', \'din\'), (\'MAD\', \'dh\'), (\'MDL\', \'MDL\'), (\'MGA\', \'Ar\'), (\'MKD\', \'din\'), (\'MMK\', \'K\'), (\'MNT\', \'₮\'), (\'MOP\', \'MOP\'), (\'MUR\', \'Rs\'), (\'MVR\', \'Rf\'), (\'MWK\', \'MWK\'), (\'MXN\', \'\$\'), (\'MYR\', \'RM\'), (\'MZN\', \'MTn\'), (\'NAD\', \'\$\'), (\'NGN\', \'₦\'), (\'NIO\', \'C\$\'), (\'NOK\', \'kr\'), (\'NPR\', \'Rs\'), (\'NZD\', \'\$\'), (\'OMR\', \'Rial\'), (\'PAB\', \'B/.\'), (\'PEN\', \'S/\'), (\'PGK\', \'PGK\'), (\'PHP\', \'₱\'), (\'PKR\', \'Rs\'), (\'PLN\', \'zł\'), (\'PYG\', \'Gs\'), (\'QAR\', \'Rial\'), (\'RON\', \'RON\'), (\'RSD\', \'din\'), (\'RUB\', \'₽\'), (\'RWF\', \'RF\'), (\'SAR\', \'Riyal\'), (\'SBD\', \'\$\'), (\'SCR\', \'SCR\'), (\'SDG\', \'SDG\'), (\'SEK\', \'kr\'), (\'SGD\', \'\$\'), (\'SLL\', \'SLL\'), (\'SOS\', \'SOS\'), (\'SRD\', \'\$\'), (\'SSP\', \'SSP\'), (\'STD\', \'Db\'), (\'SVC\', \'₡\'), (\'SYP\', \'£\'), (\'SZL\', \'SZL\'), (\'THB\', \'฿\'), (\'TJS\', \'Som\'), (\'TMT\', \'TMT\'), (\'TND\', \'din\'), (\'TOP\', \'T\$\'), (\'TRY\', \'TL\'), (\'TTD\', \'\$\'), (\'TWD\', \'NT\$\'), (\'TZS\', \'TSh\'), (\'UAH\', \'₴\'), (\'UGX\', \'UGX\'), (\'USD\', \'\$\'), (\'UYU\', \'\$\'), (\'UZS\', \'soʼm\'), (\'VEF\', \'Bs\'), (\'VND\', \'₫\'), (\'VUV\', \'VUV\'), (\'WST\', \'WST\'), (\'XAF\', \'FCFA\'), (\'XCD\', \'\$\'), (\'XOF\', \'CFA\'), (\'XPF\', \'FCFP\'), (\'YER\', \'Rial\'), (\'ZAR\', \'R\'), (\'ZMW\', \'ZK\'), (\'ZWL\', \'\$\')',
      variables: [],
      updates: {currencies},
    );
  }

  Future<int> insertInitialCurrencyNames() {
    return customInsert(
      'INSERT INTO currencyNames (currencyCode, en, es) VALUES (\'AED\', \'UAE Dirham\', \'Dírham de los Emiratos Árabes Unidos\'), (\'AFN\', \'Afghani\', \'Afgani\'), (\'ALL\', \'Lek\', \'Lek\'), (\'AMD\', \'Armenian Dram\', \'Dram armenio\'), (\'ANG\', \'Netherlands Antillian Guilder\', \'Florín antillano neerlandés\'), (\'AOA\', \'Kwanza\', \'Kwanza\'), (\'ARS\', \'Argentine Peso\', \'Peso argentino\'), (\'AUD\', \'Australian Dollar\', \'Dólar australiano\'), (\'AWG\', \'Aruban Guilder\', \'Florín arubeño\'), (\'AZN\', \'Azerbaijanian Manat\', \'Manat azerbaiyano\'), (\'BAM\', \'Convertible Marks\', \'Marco convertible\'), (\'BBD\', \'Barbados Dollar\', \'Dólar de Barbados\'), (\'BDT\', \'Taka\', \'Taka\'), (\'BGN\', \'Bulgarian Lev\', \'Lev búlgaro\'), (\'BHD\', \'Bahraini Dinar\', \'Dinar bareiní\'), (\'BIF\', \'Burundi Franc\', \'Franco de Burundi\'), (\'BND\', \'Brunei Dollar\', \'Dólar de Brunéi\'), (\'BOB\', \'Boliviano\', \'Boliviano\'), (\'BRL\', \'Brazilian Real\', \'Real brasileño\'), (\'BSD\', \'Bahamian Dollar\', \'Dólar bahameño\'), (\'BTN\', \'Ngultrum\', \'Ngultrum\'), (\'BWP\', \'Pula\', \'Pula\'), (\'BYR\', \'Belarussian Ruble\', \'Rublo bielorruso\'), (\'BZD\', \'Belize Dollar\', \'Dólar beliceño\'), (\'CAD\', \'Canadian Dollar\', \'Dólar canadiense\'), (\'CDF\', \'Congolese Franc\', \'Franco congoleño\'), (\'CHF\', \'Swiss Franc\', \'Franco suizo\'), (\'CLP\', \'Chilean Peso\', \'Peso chileno\'), (\'CNY\', \'Chinese Yuan\', \'Yuan chino\'), (\'COP\', \'Colombian Peso\', \'Peso colombiano\'), (\'CRC\', \'Costa Rican Colon\', \'Colón costarricense\'), (\'CUP\', \'Cuban Peso\', \'Peso cubano\'), (\'CVE\', \'Cape Verde Escudo\', \'Escudo caboverdiano\'), (\'CZK\', \'Czech Koruna\', \'Corona checa\'), (\'DJF\', \'Djibouti Franc\', \'Franco yibutiano\'), (\'DKK\', \'Danish Krone\', \'Corona danesa\'), (\'DOP\', \'Dominican Peso\', \'Peso dominicano\'), (\'DZD\', \'Algerian Dinar\', \'Dinar argelino\'), (\'EGP\', \'Egyptian Pound\', \'Libra egipcia\'), (\'ERN\', \'Nakfa\', \'Nakfa\'), (\'ETB\', \'Ethiopian Birr\', \'Birr etíope\'), (\'EUR\', \'Euro\', \'Euro\'), (\'FJD\', \'Fiji Dollar\', \'Dólar fiyiano\'), (\'FKP\', \'Falkland Islands Pound\', \'Libra malvinense\'), (\'GBP\', \'Pound Sterling\', \'Libra esterlina\'), (\'GEL\', \'Lari\', \'Lari\'), (\'GHS\', \'Cedi\', \'Cedi ghanés\'), (\'GIP\', \'Gibraltar Pound\', \'Libra de Gibraltar\'), (\'GMD\', \'Dalasi\', \'Dalasi\'), (\'GNF\', \'Guinea Franc\', \'Franco guineano\'), (\'GTQ\', \'Quetzal\', \'Quetzal\'), (\'HKD\', \'Hong Kong Dollar\', \'Dólar de Hong Kong\'), (\'HNL\', \'Lempira\', \'Lempira\'), (\'HRK\', \'Croatian Kuna\', \'Kuna\'), (\'HTG\', \'Gourde\', \'Gourde\'), (\'HUF\', \'Hungary Forint\', \'Forinto\'), (\'IDR\', \'Rupiah\', \'Rupia indonesia\'), (\'ILS\', \'Israeli Sheqel\', \'Nuevo shéquel israelí\'), (\'INR\', \'Indian Rupee\', \'Rupia india\'), (\'IQD\', \'Iraqi Dinar\', \'Dinar iraquí\'), (\'IRR\', \'Iranian Rial\', \'Rial iraní\'), (\'ISK\', \'Iceland Krona\', \'Corona islandesa\'), (\'JMD\', \'Jamaican Dollar\', \'Dólar jamaiquino\'), (\'JOD\', \'Jordanian Dinar\', \'Dinar jordano\'), (\'JPY\', \'Japan Yen\', \'Yen\'), (\'KES\', \'Kenyan Shilling\', \'Chelín keniano\'), (\'KGS\', \'Som\', \'Som\'), (\'KHR\', \'Riel\', \'Riel\'), (\'KMF\', \'Comoro Franc\', \'Franco comorense\'), (\'KPW\', \'North Korean Won\', \'Won norcoreano\'), (\'KRW\', \'Won\', \'Won\'), (\'KWD\', \'Kuwaiti Dinar\', \'Dinar kuwaití\'), (\'KYD\', \'Cayman Islands Dollar\', \'Dólar de las Islas Caimán\'), (\'KZT\', \'Tenge\', \'Tenge\'), (\'LAK\', \'Kip\', \'Kip\'), (\'LBP\', \'Lebanese Pound\', \'Libra libanesa\'), (\'LKR\', \'Sri Lanka Rupee\', \'Rupia de Sri Lanka\'), (\'LRD\', \'Liberian Dollar\', \'Dólar liberiano\'), (\'LSL\', \'Loti\', \'Loti\'), (\'LYD\', \'Libyan Dinar\', \'Dinar libio\'), (\'MAD\', \'Moroccan Dirham\', \'Dírham marroquí\'), (\'MDL\', \'Moldovan Leu\', \'Leu moldavo\'), (\'MGA\', \'Malagasy Ariary\', \'Ariary malgache\'), (\'MKD\', \'Denar\', \'Denar\'), (\'MMK\', \'Kyat\', \'Kyat\'), (\'MNT\', \'Tugrik\', \'Tugrik\'), (\'MOP\', \'Pataca\', \'Pataca\'), (\'MUR\', \'Mauritius Rupee\', \'Rupia de Mauricio\'), (\'MVR\', \'Rufiyaa\', \'Rufiyaa\'), (\'MWK\', \'Kwacha\', \'Kwacha\'), (\'MXN\', \'Mexican Peso\', \'Peso mexicano\'), (\'MYR\', \'Malaysian Ringgit\', \'Ringgit malayo\'), (\'MZN\', \'Metical\', \'Metical mozambiqueño\'), (\'NAD\', \'Namibia Dollar\', \'Dólar namibio\'), (\'NGN\', \'Naira\', \'Naira\'), (\'NIO\', \'Cordoba Oro\', \'Córdoba\'), (\'NOK\', \'Norwegian Krone\', \'Corona noruega\'), (\'NPR\', \'Nepalese Rupee\', \'Rupia nepalí\'), (\'NZD\', \'New Zealand Dollar\', \'Dólar neozelandés\'), (\'OMR\', \'Rial Omani\', \'Rial omaní\'), (\'PAB\', \'Balboa\', \'Balboa\'), (\'PEN\', \'Nuevo Sol\', \'Sol\'), (\'PGK\', \'Kina\', \'Kina\'), (\'PHP\', \'Philippine Peso\', \'Peso filipino\'), (\'PKR\', \'Pakistan Rupee\', \'Rupia pakistaní\'), (\'PLN\', \'Polish Zloty\', \'Złoty\'), (\'PYG\', \'Guarani\', \'Guaraní\'), (\'QAR\', \'Qatari Rial\', \'Riyal qatarí\'), (\'RON\', \'New Leu\', \'Leu rumano\'), (\'RSD\', \'Serbian Dinar\', \'Dinar serbio\'), (\'RUB\', \'Russian Ruble\', \'Rublo ruso\'), (\'RWF\', \'Rwanda Franc\', \'Franco ruandés\'), (\'SAR\', \'Saudi Riyal\', \'Riyal saudí\'), (\'SBD\', \'Solomon Islands Dollar\', \'Dólar de las Islas Salomón\'), (\'SCR\', \'Seychelles Rupee\', \'Rupia seychelense\'), (\'SDG\', \'Sudanese Pound\', \'Dinar sudanés\'), (\'SEK\', \'Swedish Krona\', \'Corona sueca\'), (\'SGD\', \'Singapore Dollar\', \'Dólar de Singapur\'), (\'SLL\', \'Leone\', \'Leone\'), (\'SOS\', \'Somali Shilling\', \'Chelín somalí\'), (\'SRD\', \'Surinam Dollar\', \'Dólar surinamés\'), (\'SSP\', \'South Sudanese pound\', \'Libra sursudanesa\'), (\'STD\', \'Dobra\', \'Dobra\'), (\'SVC\', \'Salvadoran Colon\', \'Colon Salvadoreño\'), (\'SYP\', \'Syrian Pound\', \'Libra siria\'), (\'SZL\', \'Lilangeni\', \'Lilangeni\'), (\'THB\', \'Baht\', \'Baht\'), (\'TJS\', \'Somoni\', \'Somoni tayiko\'), (\'TMT\', \'Manat\', \'Manat turcomano\'), (\'TND\', \'Tunisian Dinar\', \'Dinar tunecino\'), (\'TOP\', \'Pa´anga\', \'Pa´anga\'), (\'TRY\', \'Turkish Lira\', \'Lira turca\'), (\'TTD\', \'Trinidad and Tobago Dollar\', \'Dólar de Trinidad y Tobago\'), (\'TWD\', \'Taiwan Dollar\', \'Nuevo dólar taiwanés\'), (\'TZS\', \'Tanzanian Shilling\', \'Chelín tanzano\'), (\'UAH\', \'Hryvnia\', \'Grivna\'), (\'UGX\', \'Uganda Shilling\', \'Chelín ugandés\'), (\'USD\', \'US Dollar\', \'Dólar estadounidense\'), (\'UYU\', \'Peso Uruguayo\', \'Peso uruguayo\'), (\'UZS\', \'Uzbekistan Sum\', \'Som uzbeko\'), (\'VEF\', \'Bolivar Fuerte\', \'Fuerte bolivar\'), (\'VND\', \'Dong\', \'Dong vietnamita\'), (\'VUV\', \'Vatu\', \'Vatu\'), (\'WST\', \'Tala\', \'Tala\'), (\'XAF\', \'CFA Franc\', \'Franco CFA de África Central\'), (\'XCD\', \'East Caribbean Dollar\', \'Dólar del Caribe Oriental\'), (\'XOF\', \'CFA Franc\', \'Franco CFA de África Occidental\'), (\'XPF\', \'CFP Franc\', \'Franco CFP\'), (\'YER\', \'Yemeni Rial\', \'Rial yemení\'), (\'ZAR\', \'Rand\', \'Rand\'), (\'ZMW\', \'Zambian Kwacha\', \'Kwacha zambiano\'), (\'ZWL\', \'Zimbabwean dollar\', \'Dólar de Zimbawe\')',
      variables: [],
      updates: {currencyNames},
    );
  }

  Future<int> insertInitialSettings() {
    return customInsert(
      'INSERT INTO userSettings VALUES (\'avatar\', \'man\'), (\'userName\', \'User\')',
      variables: [],
      updates: {userSettings},
    );
  }

  Future<int> insertInitialSettings2() {
    return customInsert(
      'INSERT INTO appData VALUES (\'avdjlkatar\', \'man\'), (\'userNcdhjame\', \'User\')',
      variables: [],
      updates: {appData},
    );
  }

  Future<int> insertInitialSettings3() {
    return customInsert(
      'INSERT INTO userSettings VALUES (\'avdkatar\', \'man\'), (\'userNflkcdhjame\', \'User\')',
      variables: [],
      updates: {userSettings},
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        currencies,
        accounts,
        categories,
        transactions,
        exchangeRates,
        currencyNames,
        userSettings,
        appData,
        recurrentRules
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('accounts', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('accounts', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('exchangeRates', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('exchangeRates', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('currencyNames', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('currencies',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('currencyNames', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('recurrentRules', kind: UpdateKind.update),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef GetAccountsWithFullData$predicate = Expression<bool> Function(
    Accounts a, Currencies currency);
typedef GetTransactionsWithFullData$predicate = Expression<bool> Function(
    Transactions t, Accounts a, Accounts ra, Categories c, Categories pc);
typedef GetTransactionsWithFullData$orderBy = OrderBy Function(
    Transactions t, Accounts a, Accounts ra, Categories c, Categories pc);
typedef GetTransactionsWithFullData$limit = Limit Function(
    Transactions t, Accounts a, Accounts ra, Categories c, Categories pc);
typedef GetCategoriesWithFullData$predicate = Expression<bool> Function(
    Categories a, Categories parentCategory);
typedef GetExchangeRates$predicate = Expression<bool> Function(
    ExchangeRates e, Currencies currency);
