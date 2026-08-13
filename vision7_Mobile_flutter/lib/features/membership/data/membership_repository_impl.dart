import '../domain/membership_models.dart';
import '../domain/membership_repository.dart';
import '../data/membership_remote_data_source.dart';

class MembershipPlanRepositoryImpl implements MembershipPlanRepository {
  final MembershipPlanRemoteDataSource _remote;
  MembershipPlanRepositoryImpl(this._remote);

  @override
  Future<List<MembershipPlan>> listPublic() => _remote.listPublic();
}

class UserMembershipRepositoryImpl implements UserMembershipRepository {
  final UserMembershipRemoteDataSource _remote;
  UserMembershipRepositoryImpl(this._remote);

  @override
  Future<List<UserMembership>> listMine() => _remote.listMine();

  @override
  Future<UserMembership> purchase(String planId, {String? startDate, String? notes}) =>
      _remote.purchase(planId, startDate: startDate, notes: notes);
}
