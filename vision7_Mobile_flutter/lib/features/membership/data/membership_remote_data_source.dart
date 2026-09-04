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
}
