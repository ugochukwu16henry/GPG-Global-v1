import '../models/user_data_model.dart';

class SearchFilterService {
  const SearchFilterService();

  List<UserDataModel> filterTalentMarketplace(
    List<UserDataModel> users, {
    UserGender? gender,
    String? lga,
    String? state,
  }) {
    final normalizedLga = _normalizeNullable(lga);
    final normalizedState = _normalizeNullable(state);

    return users.where((user) {
      if (!user.offersMarketplaceServices) {
        return false;
      }
      if (gender != null && user.gender != gender) {
        return false;
      }
      if (normalizedLga != null && _normalize(user.lga) != normalizedLga) {
        return false;
      }
      if (normalizedState != null && _normalize(user.state) != normalizedState) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  List<UserDataModel> findMissionPeers(
    List<UserDataModel> users, {
    required String missionId,
    String? excludeUserId,
  }) {
    final normalizedMissionId = _normalize(missionId);
    final normalizedExcluded = _normalizeNullable(excludeUserId);
    if (normalizedMissionId.isEmpty) {
      throw const FormatException('missionId is required to find mission peers.');
    }

    return users.where((user) {
      final sameMission = _normalize(user.missionId) == normalizedMissionId;
      final isExcluded = normalizedExcluded != null &&
          _normalize(user.id) == normalizedExcluded;
      return sameMission && !isExcluded;
    }).toList(growable: false);
  }

  String _normalize(String value) => value.trim().toLowerCase();

  String? _normalizeNullable(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = _normalize(value);
    return normalized.isEmpty ? null : normalized;
  }
}