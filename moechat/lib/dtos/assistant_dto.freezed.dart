// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateAssistantDto _$CreateAssistantDtoFromJson(Map<String, dynamic> json) {
  return _CreateAssistantDto.fromJson(json);
}

/// @nodoc
mixin _$CreateAssistantDto {
  String get name => throw _privateConstructorUsedError;
  String get avatar => throw _privateConstructorUsedError;
  String get birthday => throw _privateConstructorUsedError;
  String get height => throw _privateConstructorUsedError;
  String get weight => throw _privateConstructorUsedError;
  String get personality => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  String? get userNickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'mask')
  String? get userSetting => throw _privateConstructorUsedError;
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples => throw _privateConstructorUsedError;
  String? get extraDescription => throw _privateConstructorUsedError;
  String? get customPrompt => throw _privateConstructorUsedError;
  @JsonKey(name: 'startWith')
  List<String>? get greetings => throw _privateConstructorUsedError;
  FeatureSettingsDto? get settings => throw _privateConstructorUsedError;
  GsvSettingsDto? get gsvSetting => throw _privateConstructorUsedError;

  /// Serializes this CreateAssistantDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAssistantDtoCopyWith<CreateAssistantDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAssistantDtoCopyWith<$Res> {
  factory $CreateAssistantDtoCopyWith(
    CreateAssistantDto value,
    $Res Function(CreateAssistantDto) then,
  ) = _$CreateAssistantDtoCopyWithImpl<$Res, CreateAssistantDto>;
  @useResult
  $Res call({
    String name,
    String avatar,
    String birthday,
    String height,
    String weight,
    String personality,
    String description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  });

  $FeatureSettingsDtoCopyWith<$Res>? get settings;
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting;
}

/// @nodoc
class _$CreateAssistantDtoCopyWithImpl<$Res, $Val extends CreateAssistantDto>
    implements $CreateAssistantDtoCopyWith<$Res> {
  _$CreateAssistantDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = null,
    Object? birthday = null,
    Object? height = null,
    Object? weight = null,
    Object? personality = null,
    Object? description = null,
    Object? userNickname = freezed,
    Object? userSetting = freezed,
    Object? messageExamples = freezed,
    Object? extraDescription = freezed,
    Object? customPrompt = freezed,
    Object? greetings = freezed,
    Object? settings = freezed,
    Object? gsvSetting = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: null == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String,
            birthday: null == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as String,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as String,
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            userNickname: freezed == userNickname
                ? _value.userNickname
                : userNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            userSetting: freezed == userSetting
                ? _value.userSetting
                : userSetting // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageExamples: freezed == messageExamples
                ? _value.messageExamples
                : messageExamples // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            extraDescription: freezed == extraDescription
                ? _value.extraDescription
                : extraDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            customPrompt: freezed == customPrompt
                ? _value.customPrompt
                : customPrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            greetings: freezed == greetings
                ? _value.greetings
                : greetings // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as FeatureSettingsDto?,
            gsvSetting: freezed == gsvSetting
                ? _value.gsvSetting
                : gsvSetting // ignore: cast_nullable_to_non_nullable
                      as GsvSettingsDto?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeatureSettingsDtoCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $FeatureSettingsDtoCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting {
    if (_value.gsvSetting == null) {
      return null;
    }

    return $GsvSettingsDtoCopyWith<$Res>(_value.gsvSetting!, (value) {
      return _then(_value.copyWith(gsvSetting: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateAssistantDtoImplCopyWith<$Res>
    implements $CreateAssistantDtoCopyWith<$Res> {
  factory _$$CreateAssistantDtoImplCopyWith(
    _$CreateAssistantDtoImpl value,
    $Res Function(_$CreateAssistantDtoImpl) then,
  ) = __$$CreateAssistantDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String avatar,
    String birthday,
    String height,
    String weight,
    String personality,
    String description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  });

  @override
  $FeatureSettingsDtoCopyWith<$Res>? get settings;
  @override
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting;
}

/// @nodoc
class __$$CreateAssistantDtoImplCopyWithImpl<$Res>
    extends _$CreateAssistantDtoCopyWithImpl<$Res, _$CreateAssistantDtoImpl>
    implements _$$CreateAssistantDtoImplCopyWith<$Res> {
  __$$CreateAssistantDtoImplCopyWithImpl(
    _$CreateAssistantDtoImpl _value,
    $Res Function(_$CreateAssistantDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = null,
    Object? birthday = null,
    Object? height = null,
    Object? weight = null,
    Object? personality = null,
    Object? description = null,
    Object? userNickname = freezed,
    Object? userSetting = freezed,
    Object? messageExamples = freezed,
    Object? extraDescription = freezed,
    Object? customPrompt = freezed,
    Object? greetings = freezed,
    Object? settings = freezed,
    Object? gsvSetting = freezed,
  }) {
    return _then(
      _$CreateAssistantDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: null == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String,
        birthday: null == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as String,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as String,
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        userNickname: freezed == userNickname
            ? _value.userNickname
            : userNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        userSetting: freezed == userSetting
            ? _value.userSetting
            : userSetting // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageExamples: freezed == messageExamples
            ? _value._messageExamples
            : messageExamples // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        extraDescription: freezed == extraDescription
            ? _value.extraDescription
            : extraDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        customPrompt: freezed == customPrompt
            ? _value.customPrompt
            : customPrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        greetings: freezed == greetings
            ? _value._greetings
            : greetings // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as FeatureSettingsDto?,
        gsvSetting: freezed == gsvSetting
            ? _value.gsvSetting
            : gsvSetting // ignore: cast_nullable_to_non_nullable
                  as GsvSettingsDto?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateAssistantDtoImpl implements _CreateAssistantDto {
  const _$CreateAssistantDtoImpl({
    required this.name,
    required this.avatar,
    required this.birthday,
    required this.height,
    required this.weight,
    required this.personality,
    required this.description,
    @JsonKey(name: 'user') this.userNickname,
    @JsonKey(name: 'mask') this.userSetting,
    @JsonKey(name: 'messageExamples') final List<String>? messageExamples,
    this.extraDescription,
    this.customPrompt,
    @JsonKey(name: 'startWith') final List<String>? greetings,
    this.settings,
    this.gsvSetting,
  }) : _messageExamples = messageExamples,
       _greetings = greetings;

  factory _$CreateAssistantDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateAssistantDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String avatar;
  @override
  final String birthday;
  @override
  final String height;
  @override
  final String weight;
  @override
  final String personality;
  @override
  final String description;
  @override
  @JsonKey(name: 'user')
  final String? userNickname;
  @override
  @JsonKey(name: 'mask')
  final String? userSetting;
  final List<String>? _messageExamples;
  @override
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples {
    final value = _messageExamples;
    if (value == null) return null;
    if (_messageExamples is EqualUnmodifiableListView) return _messageExamples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? extraDescription;
  @override
  final String? customPrompt;
  final List<String>? _greetings;
  @override
  @JsonKey(name: 'startWith')
  List<String>? get greetings {
    final value = _greetings;
    if (value == null) return null;
    if (_greetings is EqualUnmodifiableListView) return _greetings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final FeatureSettingsDto? settings;
  @override
  final GsvSettingsDto? gsvSetting;

  @override
  String toString() {
    return 'CreateAssistantDto(name: $name, avatar: $avatar, birthday: $birthday, height: $height, weight: $weight, personality: $personality, description: $description, userNickname: $userNickname, userSetting: $userSetting, messageExamples: $messageExamples, extraDescription: $extraDescription, customPrompt: $customPrompt, greetings: $greetings, settings: $settings, gsvSetting: $gsvSetting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAssistantDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userNickname, userNickname) ||
                other.userNickname == userNickname) &&
            (identical(other.userSetting, userSetting) ||
                other.userSetting == userSetting) &&
            const DeepCollectionEquality().equals(
              other._messageExamples,
              _messageExamples,
            ) &&
            (identical(other.extraDescription, extraDescription) ||
                other.extraDescription == extraDescription) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt) &&
            const DeepCollectionEquality().equals(
              other._greetings,
              _greetings,
            ) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.gsvSetting, gsvSetting) ||
                other.gsvSetting == gsvSetting));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    avatar,
    birthday,
    height,
    weight,
    personality,
    description,
    userNickname,
    userSetting,
    const DeepCollectionEquality().hash(_messageExamples),
    extraDescription,
    customPrompt,
    const DeepCollectionEquality().hash(_greetings),
    settings,
    gsvSetting,
  );

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAssistantDtoImplCopyWith<_$CreateAssistantDtoImpl> get copyWith =>
      __$$CreateAssistantDtoImplCopyWithImpl<_$CreateAssistantDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateAssistantDtoImplToJson(this);
  }
}

abstract class _CreateAssistantDto implements CreateAssistantDto {
  const factory _CreateAssistantDto({
    required final String name,
    required final String avatar,
    required final String birthday,
    required final String height,
    required final String weight,
    required final String personality,
    required final String description,
    @JsonKey(name: 'user') final String? userNickname,
    @JsonKey(name: 'mask') final String? userSetting,
    @JsonKey(name: 'messageExamples') final List<String>? messageExamples,
    final String? extraDescription,
    final String? customPrompt,
    @JsonKey(name: 'startWith') final List<String>? greetings,
    final FeatureSettingsDto? settings,
    final GsvSettingsDto? gsvSetting,
  }) = _$CreateAssistantDtoImpl;

  factory _CreateAssistantDto.fromJson(Map<String, dynamic> json) =
      _$CreateAssistantDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get avatar;
  @override
  String get birthday;
  @override
  String get height;
  @override
  String get weight;
  @override
  String get personality;
  @override
  String get description;
  @override
  @JsonKey(name: 'user')
  String? get userNickname;
  @override
  @JsonKey(name: 'mask')
  String? get userSetting;
  @override
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples;
  @override
  String? get extraDescription;
  @override
  String? get customPrompt;
  @override
  @JsonKey(name: 'startWith')
  List<String>? get greetings;
  @override
  FeatureSettingsDto? get settings;
  @override
  GsvSettingsDto? get gsvSetting;

  /// Create a copy of CreateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAssistantDtoImplCopyWith<_$CreateAssistantDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateAssistantDto _$UpdateAssistantDtoFromJson(Map<String, dynamic> json) {
  return _UpdateAssistantDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateAssistantDto {
  String get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  String? get birthday => throw _privateConstructorUsedError;
  String? get height => throw _privateConstructorUsedError;
  String? get weight => throw _privateConstructorUsedError;
  String? get personality => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  String? get userNickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'mask')
  String? get userSetting => throw _privateConstructorUsedError;
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples => throw _privateConstructorUsedError;
  String? get extraDescription => throw _privateConstructorUsedError;
  String? get customPrompt => throw _privateConstructorUsedError;
  @JsonKey(name: 'startWith')
  List<String>? get greetings => throw _privateConstructorUsedError;
  FeatureSettingsDto? get settings => throw _privateConstructorUsedError;
  GsvSettingsDto? get gsvSetting => throw _privateConstructorUsedError;

  /// Serializes this UpdateAssistantDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateAssistantDtoCopyWith<UpdateAssistantDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateAssistantDtoCopyWith<$Res> {
  factory $UpdateAssistantDtoCopyWith(
    UpdateAssistantDto value,
    $Res Function(UpdateAssistantDto) then,
  ) = _$UpdateAssistantDtoCopyWithImpl<$Res, UpdateAssistantDto>;
  @useResult
  $Res call({
    String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  });

  $FeatureSettingsDtoCopyWith<$Res>? get settings;
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting;
}

/// @nodoc
class _$UpdateAssistantDtoCopyWithImpl<$Res, $Val extends UpdateAssistantDto>
    implements $UpdateAssistantDtoCopyWith<$Res> {
  _$UpdateAssistantDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = freezed,
    Object? birthday = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? userNickname = freezed,
    Object? userSetting = freezed,
    Object? messageExamples = freezed,
    Object? extraDescription = freezed,
    Object? customPrompt = freezed,
    Object? greetings = freezed,
    Object? settings = freezed,
    Object? gsvSetting = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthday: freezed == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as String?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as String?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as String?,
            personality: freezed == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            userNickname: freezed == userNickname
                ? _value.userNickname
                : userNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            userSetting: freezed == userSetting
                ? _value.userSetting
                : userSetting // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageExamples: freezed == messageExamples
                ? _value.messageExamples
                : messageExamples // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            extraDescription: freezed == extraDescription
                ? _value.extraDescription
                : extraDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            customPrompt: freezed == customPrompt
                ? _value.customPrompt
                : customPrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            greetings: freezed == greetings
                ? _value.greetings
                : greetings // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as FeatureSettingsDto?,
            gsvSetting: freezed == gsvSetting
                ? _value.gsvSetting
                : gsvSetting // ignore: cast_nullable_to_non_nullable
                      as GsvSettingsDto?,
          )
          as $Val,
    );
  }

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeatureSettingsDtoCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $FeatureSettingsDtoCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting {
    if (_value.gsvSetting == null) {
      return null;
    }

    return $GsvSettingsDtoCopyWith<$Res>(_value.gsvSetting!, (value) {
      return _then(_value.copyWith(gsvSetting: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateAssistantDtoImplCopyWith<$Res>
    implements $UpdateAssistantDtoCopyWith<$Res> {
  factory _$$UpdateAssistantDtoImplCopyWith(
    _$UpdateAssistantDtoImpl value,
    $Res Function(_$UpdateAssistantDtoImpl) then,
  ) = __$$UpdateAssistantDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  });

  @override
  $FeatureSettingsDtoCopyWith<$Res>? get settings;
  @override
  $GsvSettingsDtoCopyWith<$Res>? get gsvSetting;
}

/// @nodoc
class __$$UpdateAssistantDtoImplCopyWithImpl<$Res>
    extends _$UpdateAssistantDtoCopyWithImpl<$Res, _$UpdateAssistantDtoImpl>
    implements _$$UpdateAssistantDtoImplCopyWith<$Res> {
  __$$UpdateAssistantDtoImplCopyWithImpl(
    _$UpdateAssistantDtoImpl _value,
    $Res Function(_$UpdateAssistantDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = freezed,
    Object? birthday = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? userNickname = freezed,
    Object? userSetting = freezed,
    Object? messageExamples = freezed,
    Object? extraDescription = freezed,
    Object? customPrompt = freezed,
    Object? greetings = freezed,
    Object? settings = freezed,
    Object? gsvSetting = freezed,
  }) {
    return _then(
      _$UpdateAssistantDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthday: freezed == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as String?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as String?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as String?,
        personality: freezed == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        userNickname: freezed == userNickname
            ? _value.userNickname
            : userNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        userSetting: freezed == userSetting
            ? _value.userSetting
            : userSetting // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageExamples: freezed == messageExamples
            ? _value._messageExamples
            : messageExamples // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        extraDescription: freezed == extraDescription
            ? _value.extraDescription
            : extraDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        customPrompt: freezed == customPrompt
            ? _value.customPrompt
            : customPrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        greetings: freezed == greetings
            ? _value._greetings
            : greetings // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as FeatureSettingsDto?,
        gsvSetting: freezed == gsvSetting
            ? _value.gsvSetting
            : gsvSetting // ignore: cast_nullable_to_non_nullable
                  as GsvSettingsDto?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateAssistantDtoImpl implements _UpdateAssistantDto {
  const _$UpdateAssistantDtoImpl({
    required this.name,
    this.avatar,
    this.birthday,
    this.height,
    this.weight,
    this.personality,
    this.description,
    @JsonKey(name: 'user') this.userNickname,
    @JsonKey(name: 'mask') this.userSetting,
    @JsonKey(name: 'messageExamples') final List<String>? messageExamples,
    this.extraDescription,
    this.customPrompt,
    @JsonKey(name: 'startWith') final List<String>? greetings,
    this.settings,
    this.gsvSetting,
  }) : _messageExamples = messageExamples,
       _greetings = greetings;

  factory _$UpdateAssistantDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateAssistantDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String? avatar;
  @override
  final String? birthday;
  @override
  final String? height;
  @override
  final String? weight;
  @override
  final String? personality;
  @override
  final String? description;
  @override
  @JsonKey(name: 'user')
  final String? userNickname;
  @override
  @JsonKey(name: 'mask')
  final String? userSetting;
  final List<String>? _messageExamples;
  @override
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples {
    final value = _messageExamples;
    if (value == null) return null;
    if (_messageExamples is EqualUnmodifiableListView) return _messageExamples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? extraDescription;
  @override
  final String? customPrompt;
  final List<String>? _greetings;
  @override
  @JsonKey(name: 'startWith')
  List<String>? get greetings {
    final value = _greetings;
    if (value == null) return null;
    if (_greetings is EqualUnmodifiableListView) return _greetings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final FeatureSettingsDto? settings;
  @override
  final GsvSettingsDto? gsvSetting;

  @override
  String toString() {
    return 'UpdateAssistantDto(name: $name, avatar: $avatar, birthday: $birthday, height: $height, weight: $weight, personality: $personality, description: $description, userNickname: $userNickname, userSetting: $userSetting, messageExamples: $messageExamples, extraDescription: $extraDescription, customPrompt: $customPrompt, greetings: $greetings, settings: $settings, gsvSetting: $gsvSetting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAssistantDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userNickname, userNickname) ||
                other.userNickname == userNickname) &&
            (identical(other.userSetting, userSetting) ||
                other.userSetting == userSetting) &&
            const DeepCollectionEquality().equals(
              other._messageExamples,
              _messageExamples,
            ) &&
            (identical(other.extraDescription, extraDescription) ||
                other.extraDescription == extraDescription) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt) &&
            const DeepCollectionEquality().equals(
              other._greetings,
              _greetings,
            ) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.gsvSetting, gsvSetting) ||
                other.gsvSetting == gsvSetting));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    avatar,
    birthday,
    height,
    weight,
    personality,
    description,
    userNickname,
    userSetting,
    const DeepCollectionEquality().hash(_messageExamples),
    extraDescription,
    customPrompt,
    const DeepCollectionEquality().hash(_greetings),
    settings,
    gsvSetting,
  );

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAssistantDtoImplCopyWith<_$UpdateAssistantDtoImpl> get copyWith =>
      __$$UpdateAssistantDtoImplCopyWithImpl<_$UpdateAssistantDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateAssistantDtoImplToJson(this);
  }
}

abstract class _UpdateAssistantDto implements UpdateAssistantDto {
  const factory _UpdateAssistantDto({
    required final String name,
    final String? avatar,
    final String? birthday,
    final String? height,
    final String? weight,
    final String? personality,
    final String? description,
    @JsonKey(name: 'user') final String? userNickname,
    @JsonKey(name: 'mask') final String? userSetting,
    @JsonKey(name: 'messageExamples') final List<String>? messageExamples,
    final String? extraDescription,
    final String? customPrompt,
    @JsonKey(name: 'startWith') final List<String>? greetings,
    final FeatureSettingsDto? settings,
    final GsvSettingsDto? gsvSetting,
  }) = _$UpdateAssistantDtoImpl;

  factory _UpdateAssistantDto.fromJson(Map<String, dynamic> json) =
      _$UpdateAssistantDtoImpl.fromJson;

  @override
  String get name;
  @override
  String? get avatar;
  @override
  String? get birthday;
  @override
  String? get height;
  @override
  String? get weight;
  @override
  String? get personality;
  @override
  String? get description;
  @override
  @JsonKey(name: 'user')
  String? get userNickname;
  @override
  @JsonKey(name: 'mask')
  String? get userSetting;
  @override
  @JsonKey(name: 'messageExamples')
  List<String>? get messageExamples;
  @override
  String? get extraDescription;
  @override
  String? get customPrompt;
  @override
  @JsonKey(name: 'startWith')
  List<String>? get greetings;
  @override
  FeatureSettingsDto? get settings;
  @override
  GsvSettingsDto? get gsvSetting;

  /// Create a copy of UpdateAssistantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAssistantDtoImplCopyWith<_$UpdateAssistantDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeatureSettingsDto _$FeatureSettingsDtoFromJson(Map<String, dynamic> json) {
  return _FeatureSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$FeatureSettingsDto {
  int get contextLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableLongMemory')
  bool get diary => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableLongMemorySearchEnhance')
  bool get diarySearchBoost => throw _privateConstructorUsedError;
  @JsonKey(name: 'longMemoryThreshold')
  double get diarySearchThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableCoreMemory')
  bool get coreMemory => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableLoreBooks')
  bool get worldBook => throw _privateConstructorUsedError;
  @JsonKey(name: 'loreBooksThreshold')
  double get worldBookThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'loreBooksDepth')
  int get worldBookDepth => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableEmotionSystem')
  bool get emotionSystem => throw _privateConstructorUsedError;
  @JsonKey(name: 'enableEmotionPersist')
  bool get emotionPersist => throw _privateConstructorUsedError;

  /// Serializes this FeatureSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeatureSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeatureSettingsDtoCopyWith<FeatureSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureSettingsDtoCopyWith<$Res> {
  factory $FeatureSettingsDtoCopyWith(
    FeatureSettingsDto value,
    $Res Function(FeatureSettingsDto) then,
  ) = _$FeatureSettingsDtoCopyWithImpl<$Res, FeatureSettingsDto>;
  @useResult
  $Res call({
    int contextLength,
    @JsonKey(name: 'enableLongMemory') bool diary,
    @JsonKey(name: 'enableLongMemorySearchEnhance') bool diarySearchBoost,
    @JsonKey(name: 'longMemoryThreshold') double diarySearchThreshold,
    @JsonKey(name: 'enableCoreMemory') bool coreMemory,
    @JsonKey(name: 'enableLoreBooks') bool worldBook,
    @JsonKey(name: 'loreBooksThreshold') double worldBookThreshold,
    @JsonKey(name: 'loreBooksDepth') int worldBookDepth,
    @JsonKey(name: 'enableEmotionSystem') bool emotionSystem,
    @JsonKey(name: 'enableEmotionPersist') bool emotionPersist,
  });
}

/// @nodoc
class _$FeatureSettingsDtoCopyWithImpl<$Res, $Val extends FeatureSettingsDto>
    implements $FeatureSettingsDtoCopyWith<$Res> {
  _$FeatureSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeatureSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contextLength = null,
    Object? diary = null,
    Object? diarySearchBoost = null,
    Object? diarySearchThreshold = null,
    Object? coreMemory = null,
    Object? worldBook = null,
    Object? worldBookThreshold = null,
    Object? worldBookDepth = null,
    Object? emotionSystem = null,
    Object? emotionPersist = null,
  }) {
    return _then(
      _value.copyWith(
            contextLength: null == contextLength
                ? _value.contextLength
                : contextLength // ignore: cast_nullable_to_non_nullable
                      as int,
            diary: null == diary
                ? _value.diary
                : diary // ignore: cast_nullable_to_non_nullable
                      as bool,
            diarySearchBoost: null == diarySearchBoost
                ? _value.diarySearchBoost
                : diarySearchBoost // ignore: cast_nullable_to_non_nullable
                      as bool,
            diarySearchThreshold: null == diarySearchThreshold
                ? _value.diarySearchThreshold
                : diarySearchThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            coreMemory: null == coreMemory
                ? _value.coreMemory
                : coreMemory // ignore: cast_nullable_to_non_nullable
                      as bool,
            worldBook: null == worldBook
                ? _value.worldBook
                : worldBook // ignore: cast_nullable_to_non_nullable
                      as bool,
            worldBookThreshold: null == worldBookThreshold
                ? _value.worldBookThreshold
                : worldBookThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            worldBookDepth: null == worldBookDepth
                ? _value.worldBookDepth
                : worldBookDepth // ignore: cast_nullable_to_non_nullable
                      as int,
            emotionSystem: null == emotionSystem
                ? _value.emotionSystem
                : emotionSystem // ignore: cast_nullable_to_non_nullable
                      as bool,
            emotionPersist: null == emotionPersist
                ? _value.emotionPersist
                : emotionPersist // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeatureSettingsDtoImplCopyWith<$Res>
    implements $FeatureSettingsDtoCopyWith<$Res> {
  factory _$$FeatureSettingsDtoImplCopyWith(
    _$FeatureSettingsDtoImpl value,
    $Res Function(_$FeatureSettingsDtoImpl) then,
  ) = __$$FeatureSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int contextLength,
    @JsonKey(name: 'enableLongMemory') bool diary,
    @JsonKey(name: 'enableLongMemorySearchEnhance') bool diarySearchBoost,
    @JsonKey(name: 'longMemoryThreshold') double diarySearchThreshold,
    @JsonKey(name: 'enableCoreMemory') bool coreMemory,
    @JsonKey(name: 'enableLoreBooks') bool worldBook,
    @JsonKey(name: 'loreBooksThreshold') double worldBookThreshold,
    @JsonKey(name: 'loreBooksDepth') int worldBookDepth,
    @JsonKey(name: 'enableEmotionSystem') bool emotionSystem,
    @JsonKey(name: 'enableEmotionPersist') bool emotionPersist,
  });
}

/// @nodoc
class __$$FeatureSettingsDtoImplCopyWithImpl<$Res>
    extends _$FeatureSettingsDtoCopyWithImpl<$Res, _$FeatureSettingsDtoImpl>
    implements _$$FeatureSettingsDtoImplCopyWith<$Res> {
  __$$FeatureSettingsDtoImplCopyWithImpl(
    _$FeatureSettingsDtoImpl _value,
    $Res Function(_$FeatureSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeatureSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contextLength = null,
    Object? diary = null,
    Object? diarySearchBoost = null,
    Object? diarySearchThreshold = null,
    Object? coreMemory = null,
    Object? worldBook = null,
    Object? worldBookThreshold = null,
    Object? worldBookDepth = null,
    Object? emotionSystem = null,
    Object? emotionPersist = null,
  }) {
    return _then(
      _$FeatureSettingsDtoImpl(
        contextLength: null == contextLength
            ? _value.contextLength
            : contextLength // ignore: cast_nullable_to_non_nullable
                  as int,
        diary: null == diary
            ? _value.diary
            : diary // ignore: cast_nullable_to_non_nullable
                  as bool,
        diarySearchBoost: null == diarySearchBoost
            ? _value.diarySearchBoost
            : diarySearchBoost // ignore: cast_nullable_to_non_nullable
                  as bool,
        diarySearchThreshold: null == diarySearchThreshold
            ? _value.diarySearchThreshold
            : diarySearchThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        coreMemory: null == coreMemory
            ? _value.coreMemory
            : coreMemory // ignore: cast_nullable_to_non_nullable
                  as bool,
        worldBook: null == worldBook
            ? _value.worldBook
            : worldBook // ignore: cast_nullable_to_non_nullable
                  as bool,
        worldBookThreshold: null == worldBookThreshold
            ? _value.worldBookThreshold
            : worldBookThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        worldBookDepth: null == worldBookDepth
            ? _value.worldBookDepth
            : worldBookDepth // ignore: cast_nullable_to_non_nullable
                  as int,
        emotionSystem: null == emotionSystem
            ? _value.emotionSystem
            : emotionSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        emotionPersist: null == emotionPersist
            ? _value.emotionPersist
            : emotionPersist // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureSettingsDtoImpl implements _FeatureSettingsDto {
  const _$FeatureSettingsDtoImpl({
    this.contextLength = DefaultValueConstants.contextLength,
    @JsonKey(name: 'enableLongMemory') this.diary = false,
    @JsonKey(name: 'enableLongMemorySearchEnhance')
    this.diarySearchBoost = false,
    @JsonKey(name: 'longMemoryThreshold')
    this.diarySearchThreshold = DefaultValueConstants.diarySearchThreshold,
    @JsonKey(name: 'enableCoreMemory') this.coreMemory = false,
    @JsonKey(name: 'enableLoreBooks') this.worldBook = false,
    @JsonKey(name: 'loreBooksThreshold')
    this.worldBookThreshold = DefaultValueConstants.worldBookThreshold,
    @JsonKey(name: 'loreBooksDepth')
    this.worldBookDepth = DefaultValueConstants.worldBookDepth,
    @JsonKey(name: 'enableEmotionSystem') this.emotionSystem = false,
    @JsonKey(name: 'enableEmotionPersist') this.emotionPersist = false,
  });

  factory _$FeatureSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureSettingsDtoImplFromJson(json);

  @override
  @JsonKey()
  final int contextLength;
  @override
  @JsonKey(name: 'enableLongMemory')
  final bool diary;
  @override
  @JsonKey(name: 'enableLongMemorySearchEnhance')
  final bool diarySearchBoost;
  @override
  @JsonKey(name: 'longMemoryThreshold')
  final double diarySearchThreshold;
  @override
  @JsonKey(name: 'enableCoreMemory')
  final bool coreMemory;
  @override
  @JsonKey(name: 'enableLoreBooks')
  final bool worldBook;
  @override
  @JsonKey(name: 'loreBooksThreshold')
  final double worldBookThreshold;
  @override
  @JsonKey(name: 'loreBooksDepth')
  final int worldBookDepth;
  @override
  @JsonKey(name: 'enableEmotionSystem')
  final bool emotionSystem;
  @override
  @JsonKey(name: 'enableEmotionPersist')
  final bool emotionPersist;

  @override
  String toString() {
    return 'FeatureSettingsDto(contextLength: $contextLength, diary: $diary, diarySearchBoost: $diarySearchBoost, diarySearchThreshold: $diarySearchThreshold, coreMemory: $coreMemory, worldBook: $worldBook, worldBookThreshold: $worldBookThreshold, worldBookDepth: $worldBookDepth, emotionSystem: $emotionSystem, emotionPersist: $emotionPersist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureSettingsDtoImpl &&
            (identical(other.contextLength, contextLength) ||
                other.contextLength == contextLength) &&
            (identical(other.diary, diary) || other.diary == diary) &&
            (identical(other.diarySearchBoost, diarySearchBoost) ||
                other.diarySearchBoost == diarySearchBoost) &&
            (identical(other.diarySearchThreshold, diarySearchThreshold) ||
                other.diarySearchThreshold == diarySearchThreshold) &&
            (identical(other.coreMemory, coreMemory) ||
                other.coreMemory == coreMemory) &&
            (identical(other.worldBook, worldBook) ||
                other.worldBook == worldBook) &&
            (identical(other.worldBookThreshold, worldBookThreshold) ||
                other.worldBookThreshold == worldBookThreshold) &&
            (identical(other.worldBookDepth, worldBookDepth) ||
                other.worldBookDepth == worldBookDepth) &&
            (identical(other.emotionSystem, emotionSystem) ||
                other.emotionSystem == emotionSystem) &&
            (identical(other.emotionPersist, emotionPersist) ||
                other.emotionPersist == emotionPersist));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    contextLength,
    diary,
    diarySearchBoost,
    diarySearchThreshold,
    coreMemory,
    worldBook,
    worldBookThreshold,
    worldBookDepth,
    emotionSystem,
    emotionPersist,
  );

  /// Create a copy of FeatureSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureSettingsDtoImplCopyWith<_$FeatureSettingsDtoImpl> get copyWith =>
      __$$FeatureSettingsDtoImplCopyWithImpl<_$FeatureSettingsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureSettingsDtoImplToJson(this);
  }
}

abstract class _FeatureSettingsDto implements FeatureSettingsDto {
  const factory _FeatureSettingsDto({
    final int contextLength,
    @JsonKey(name: 'enableLongMemory') final bool diary,
    @JsonKey(name: 'enableLongMemorySearchEnhance') final bool diarySearchBoost,
    @JsonKey(name: 'longMemoryThreshold') final double diarySearchThreshold,
    @JsonKey(name: 'enableCoreMemory') final bool coreMemory,
    @JsonKey(name: 'enableLoreBooks') final bool worldBook,
    @JsonKey(name: 'loreBooksThreshold') final double worldBookThreshold,
    @JsonKey(name: 'loreBooksDepth') final int worldBookDepth,
    @JsonKey(name: 'enableEmotionSystem') final bool emotionSystem,
    @JsonKey(name: 'enableEmotionPersist') final bool emotionPersist,
  }) = _$FeatureSettingsDtoImpl;

  factory _FeatureSettingsDto.fromJson(Map<String, dynamic> json) =
      _$FeatureSettingsDtoImpl.fromJson;

  @override
  int get contextLength;
  @override
  @JsonKey(name: 'enableLongMemory')
  bool get diary;
  @override
  @JsonKey(name: 'enableLongMemorySearchEnhance')
  bool get diarySearchBoost;
  @override
  @JsonKey(name: 'longMemoryThreshold')
  double get diarySearchThreshold;
  @override
  @JsonKey(name: 'enableCoreMemory')
  bool get coreMemory;
  @override
  @JsonKey(name: 'enableLoreBooks')
  bool get worldBook;
  @override
  @JsonKey(name: 'loreBooksThreshold')
  double get worldBookThreshold;
  @override
  @JsonKey(name: 'loreBooksDepth')
  int get worldBookDepth;
  @override
  @JsonKey(name: 'enableEmotionSystem')
  bool get emotionSystem;
  @override
  @JsonKey(name: 'enableEmotionPersist')
  bool get emotionPersist;

  /// Create a copy of FeatureSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeatureSettingsDtoImplCopyWith<_$FeatureSettingsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GsvSettingsDto _$GsvSettingsDtoFromJson(Map<String, dynamic> json) {
  return _GsvSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$GsvSettingsDto {
  String? get textLang => throw _privateConstructorUsedError;
  String? get gptModelPath => throw _privateConstructorUsedError;
  String? get sovitsModelPath => throw _privateConstructorUsedError;
  String? get refAudioPath => throw _privateConstructorUsedError;
  String? get promptText => throw _privateConstructorUsedError;
  String? get promptLang => throw _privateConstructorUsedError;
  int? get seed => throw _privateConstructorUsedError;
  int? get topK => throw _privateConstructorUsedError;
  int? get batchSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'extra')
  Map<String, dynamic>? get extraSettings => throw _privateConstructorUsedError;
  String? get extraRefAudio => throw _privateConstructorUsedError;

  /// Serializes this GsvSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GsvSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GsvSettingsDtoCopyWith<GsvSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GsvSettingsDtoCopyWith<$Res> {
  factory $GsvSettingsDtoCopyWith(
    GsvSettingsDto value,
    $Res Function(GsvSettingsDto) then,
  ) = _$GsvSettingsDtoCopyWithImpl<$Res, GsvSettingsDto>;
  @useResult
  $Res call({
    String? textLang,
    String? gptModelPath,
    String? sovitsModelPath,
    String? refAudioPath,
    String? promptText,
    String? promptLang,
    int? seed,
    int? topK,
    int? batchSize,
    @JsonKey(name: 'extra') Map<String, dynamic>? extraSettings,
    String? extraRefAudio,
  });
}

/// @nodoc
class _$GsvSettingsDtoCopyWithImpl<$Res, $Val extends GsvSettingsDto>
    implements $GsvSettingsDtoCopyWith<$Res> {
  _$GsvSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GsvSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textLang = freezed,
    Object? gptModelPath = freezed,
    Object? sovitsModelPath = freezed,
    Object? refAudioPath = freezed,
    Object? promptText = freezed,
    Object? promptLang = freezed,
    Object? seed = freezed,
    Object? topK = freezed,
    Object? batchSize = freezed,
    Object? extraSettings = freezed,
    Object? extraRefAudio = freezed,
  }) {
    return _then(
      _value.copyWith(
            textLang: freezed == textLang
                ? _value.textLang
                : textLang // ignore: cast_nullable_to_non_nullable
                      as String?,
            gptModelPath: freezed == gptModelPath
                ? _value.gptModelPath
                : gptModelPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            sovitsModelPath: freezed == sovitsModelPath
                ? _value.sovitsModelPath
                : sovitsModelPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            refAudioPath: freezed == refAudioPath
                ? _value.refAudioPath
                : refAudioPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            promptText: freezed == promptText
                ? _value.promptText
                : promptText // ignore: cast_nullable_to_non_nullable
                      as String?,
            promptLang: freezed == promptLang
                ? _value.promptLang
                : promptLang // ignore: cast_nullable_to_non_nullable
                      as String?,
            seed: freezed == seed
                ? _value.seed
                : seed // ignore: cast_nullable_to_non_nullable
                      as int?,
            topK: freezed == topK
                ? _value.topK
                : topK // ignore: cast_nullable_to_non_nullable
                      as int?,
            batchSize: freezed == batchSize
                ? _value.batchSize
                : batchSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            extraSettings: freezed == extraSettings
                ? _value.extraSettings
                : extraSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            extraRefAudio: freezed == extraRefAudio
                ? _value.extraRefAudio
                : extraRefAudio // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GsvSettingsDtoImplCopyWith<$Res>
    implements $GsvSettingsDtoCopyWith<$Res> {
  factory _$$GsvSettingsDtoImplCopyWith(
    _$GsvSettingsDtoImpl value,
    $Res Function(_$GsvSettingsDtoImpl) then,
  ) = __$$GsvSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? textLang,
    String? gptModelPath,
    String? sovitsModelPath,
    String? refAudioPath,
    String? promptText,
    String? promptLang,
    int? seed,
    int? topK,
    int? batchSize,
    @JsonKey(name: 'extra') Map<String, dynamic>? extraSettings,
    String? extraRefAudio,
  });
}

/// @nodoc
class __$$GsvSettingsDtoImplCopyWithImpl<$Res>
    extends _$GsvSettingsDtoCopyWithImpl<$Res, _$GsvSettingsDtoImpl>
    implements _$$GsvSettingsDtoImplCopyWith<$Res> {
  __$$GsvSettingsDtoImplCopyWithImpl(
    _$GsvSettingsDtoImpl _value,
    $Res Function(_$GsvSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GsvSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textLang = freezed,
    Object? gptModelPath = freezed,
    Object? sovitsModelPath = freezed,
    Object? refAudioPath = freezed,
    Object? promptText = freezed,
    Object? promptLang = freezed,
    Object? seed = freezed,
    Object? topK = freezed,
    Object? batchSize = freezed,
    Object? extraSettings = freezed,
    Object? extraRefAudio = freezed,
  }) {
    return _then(
      _$GsvSettingsDtoImpl(
        textLang: freezed == textLang
            ? _value.textLang
            : textLang // ignore: cast_nullable_to_non_nullable
                  as String?,
        gptModelPath: freezed == gptModelPath
            ? _value.gptModelPath
            : gptModelPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        sovitsModelPath: freezed == sovitsModelPath
            ? _value.sovitsModelPath
            : sovitsModelPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        refAudioPath: freezed == refAudioPath
            ? _value.refAudioPath
            : refAudioPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        promptText: freezed == promptText
            ? _value.promptText
            : promptText // ignore: cast_nullable_to_non_nullable
                  as String?,
        promptLang: freezed == promptLang
            ? _value.promptLang
            : promptLang // ignore: cast_nullable_to_non_nullable
                  as String?,
        seed: freezed == seed
            ? _value.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int?,
        topK: freezed == topK
            ? _value.topK
            : topK // ignore: cast_nullable_to_non_nullable
                  as int?,
        batchSize: freezed == batchSize
            ? _value.batchSize
            : batchSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        extraSettings: freezed == extraSettings
            ? _value._extraSettings
            : extraSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        extraRefAudio: freezed == extraRefAudio
            ? _value.extraRefAudio
            : extraRefAudio // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GsvSettingsDtoImpl implements _GsvSettingsDto {
  const _$GsvSettingsDtoImpl({
    this.textLang,
    this.gptModelPath,
    this.sovitsModelPath,
    this.refAudioPath,
    this.promptText,
    this.promptLang,
    this.seed = DefaultValueConstants.gsvSeed,
    this.topK = DefaultValueConstants.gsvTopK,
    this.batchSize = DefaultValueConstants.gsvBatchSize,
    @JsonKey(name: 'extra') final Map<String, dynamic>? extraSettings,
    this.extraRefAudio,
  }) : _extraSettings = extraSettings;

  factory _$GsvSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$GsvSettingsDtoImplFromJson(json);

  @override
  final String? textLang;
  @override
  final String? gptModelPath;
  @override
  final String? sovitsModelPath;
  @override
  final String? refAudioPath;
  @override
  final String? promptText;
  @override
  final String? promptLang;
  @override
  @JsonKey()
  final int? seed;
  @override
  @JsonKey()
  final int? topK;
  @override
  @JsonKey()
  final int? batchSize;
  final Map<String, dynamic>? _extraSettings;
  @override
  @JsonKey(name: 'extra')
  Map<String, dynamic>? get extraSettings {
    final value = _extraSettings;
    if (value == null) return null;
    if (_extraSettings is EqualUnmodifiableMapView) return _extraSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? extraRefAudio;

  @override
  String toString() {
    return 'GsvSettingsDto(textLang: $textLang, gptModelPath: $gptModelPath, sovitsModelPath: $sovitsModelPath, refAudioPath: $refAudioPath, promptText: $promptText, promptLang: $promptLang, seed: $seed, topK: $topK, batchSize: $batchSize, extraSettings: $extraSettings, extraRefAudio: $extraRefAudio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GsvSettingsDtoImpl &&
            (identical(other.textLang, textLang) ||
                other.textLang == textLang) &&
            (identical(other.gptModelPath, gptModelPath) ||
                other.gptModelPath == gptModelPath) &&
            (identical(other.sovitsModelPath, sovitsModelPath) ||
                other.sovitsModelPath == sovitsModelPath) &&
            (identical(other.refAudioPath, refAudioPath) ||
                other.refAudioPath == refAudioPath) &&
            (identical(other.promptText, promptText) ||
                other.promptText == promptText) &&
            (identical(other.promptLang, promptLang) ||
                other.promptLang == promptLang) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            (identical(other.topK, topK) || other.topK == topK) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            const DeepCollectionEquality().equals(
              other._extraSettings,
              _extraSettings,
            ) &&
            (identical(other.extraRefAudio, extraRefAudio) ||
                other.extraRefAudio == extraRefAudio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    textLang,
    gptModelPath,
    sovitsModelPath,
    refAudioPath,
    promptText,
    promptLang,
    seed,
    topK,
    batchSize,
    const DeepCollectionEquality().hash(_extraSettings),
    extraRefAudio,
  );

  /// Create a copy of GsvSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GsvSettingsDtoImplCopyWith<_$GsvSettingsDtoImpl> get copyWith =>
      __$$GsvSettingsDtoImplCopyWithImpl<_$GsvSettingsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GsvSettingsDtoImplToJson(this);
  }
}

abstract class _GsvSettingsDto implements GsvSettingsDto {
  const factory _GsvSettingsDto({
    final String? textLang,
    final String? gptModelPath,
    final String? sovitsModelPath,
    final String? refAudioPath,
    final String? promptText,
    final String? promptLang,
    final int? seed,
    final int? topK,
    final int? batchSize,
    @JsonKey(name: 'extra') final Map<String, dynamic>? extraSettings,
    final String? extraRefAudio,
  }) = _$GsvSettingsDtoImpl;

  factory _GsvSettingsDto.fromJson(Map<String, dynamic> json) =
      _$GsvSettingsDtoImpl.fromJson;

  @override
  String? get textLang;
  @override
  String? get gptModelPath;
  @override
  String? get sovitsModelPath;
  @override
  String? get refAudioPath;
  @override
  String? get promptText;
  @override
  String? get promptLang;
  @override
  int? get seed;
  @override
  int? get topK;
  @override
  int? get batchSize;
  @override
  @JsonKey(name: 'extra')
  Map<String, dynamic>? get extraSettings;
  @override
  String? get extraRefAudio;

  /// Create a copy of GsvSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GsvSettingsDtoImplCopyWith<_$GsvSettingsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
