import '../../../../core/network/dio_client.dart';
import '../domain/membership_models.dart';

class MembershipPlanRemoteDataSource {
  final DioClient _client;
  MembershipPlanRemoteDataSource(this._client);

  Future<List<MembershipPlan>> listPublic() async {
    final result = await _client.get<List<dynamic>>('/membership-plans/public');
    if (result == null) return [];
    return result
        .map((p) => MembershipPlan.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

class UserMembershipRemoteDataSource {
  final DioClient _client;
  UserMembershipRemoteDataSource(this._client);

  Future<List<UserMembership>> listMine() async {
    final result = await _client.get<List<dynamic>>('/me/memberships');
    if (result == null) return [];
    return result
        .map((m) => UserMembership.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<UserMembership> purchase(String planId, {String? startDate, String? notes}) async {
    final body = <String, dynamic>{'planId': planId};
    if (startDate != null) body['startDate'] = startDate;
    if (notes != null) body['notes'] = notes;

    final result = await _client.post<UserMembership>(
      '/memberships/purchase',
      body,
      fromJson: (json) =>
          UserMembership.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Purchase failed');
    return result;
  }
}
