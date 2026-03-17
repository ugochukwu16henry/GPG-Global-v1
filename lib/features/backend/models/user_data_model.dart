import 'dart:convert';

enum UserGender { male, female }

enum PathwayStatus { connect, degree, alumni }

class UserDataModel {
  const UserDataModel({
    required this.id,
    required this.displayName,
    required this.isMember,
    required this.missionId,
    required this.missionName,
    required this.pathwayStatus,
    required this.genotype,
    required this.gender,
    required this.lga,
    required this.state,
    this.offersMarketplaceServices = false,
  });

  final String id;
  final String displayName;
  final bool isMember;
  final String missionId;
  final String missionName;
  final PathwayStatus pathwayStatus;
  final String genotype;
  final UserGender gender;
  final String lga;
  final String state;
  final bool offersMarketplaceServices;

  UserDataModel copyWith({
    String? id,
    String? displayName,
    bool? isMember,
    String? missionId,
    String? missionName,
    PathwayStatus? pathwayStatus,
    String? genotype,
    UserGender? gender,
    String? lga,
    String? state,
    bool? offersMarketplaceServices,
  }) {
    return UserDataModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      isMember: isMember ?? this.isMember,
      missionId: missionId ?? this.missionId,
      missionName: missionName ?? this.missionName,
      pathwayStatus: pathwayStatus ?? this.pathwayStatus,
      genotype: genotype ?? this.genotype,
      gender: gender ?? this.gender,
      lga: lga ?? this.lga,
      state: state ?? this.state,
      offersMarketplaceServices:
          offersMarketplaceServices ?? this.offersMarketplaceServices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'isMember': isMember,
      'missionId': missionId,
      'missionName': missionName,
      'pathwayStatus': pathwayStatus.name,
      'genotype': genotype,
      'gender': gender.name,
      'lga': lga,
      'state': state,
      'offersMarketplaceServices': offersMarketplaceServices,
    };
  }

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: _requiredString(json, 'id'),
      displayName: _requiredString(json, 'displayName'),
      isMember: _requiredBool(json, 'isMember'),
      missionId: _requiredString(json, 'missionId'),
      missionName: _requiredString(json, 'missionName'),
      pathwayStatus: _parsePathwayStatus(_requiredString(json, 'pathwayStatus')),
      genotype: _requiredString(json, 'genotype'),
      gender: _parseGender(_requiredString(json, 'gender')),
      lga: _requiredString(json, 'lga'),
      state: _requiredString(json, 'state'),
      offersMarketplaceServices:
          (json['offersMarketplaceServices'] as bool?) ?? false,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw FormatException('Invalid or missing "$key" in user payload.');
  }

  static bool _requiredBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    throw FormatException('Invalid or missing "$key" in user payload.');
  }

  static PathwayStatus _parsePathwayStatus(String rawValue) {
    final normalized = rawValue.toLowerCase();
    switch (normalized) {
      case 'connect':
        return PathwayStatus.connect;
      case 'degree':
        return PathwayStatus.degree;
      case 'alumni':
        return PathwayStatus.alumni;
      default:
        throw FormatException('Unsupported pathwayStatus "$rawValue".');
    }
  }

  static UserGender _parseGender(String rawValue) {
    final normalized = rawValue.toLowerCase();
    switch (normalized) {
      case 'male':
        return UserGender.male;
      case 'female':
        return UserGender.female;
      default:
        throw FormatException('Unsupported gender "$rawValue".');
    }
  }
}

class GenotypeCipher {
  static const _prefix = 'gpg:v1:';

  static String encrypt(String plainText) {
    if (plainText.trim().isEmpty) {
      throw const FormatException('Genotype cannot be empty.');
    }
    final encoded = base64Encode(utf8.encode(plainText.trim()));
    return '$_prefix$encoded';
  }

  static String decrypt(String encryptedValue) {
    if (!encryptedValue.startsWith(_prefix)) {
      throw const FormatException('Unsupported genotype encryption format.');
    }
    final encoded = encryptedValue.substring(_prefix.length);
    try {
      return utf8.decode(base64Decode(encoded));
    } on FormatException {
      throw const FormatException('Invalid genotype cipher text.');
    }
  }
}