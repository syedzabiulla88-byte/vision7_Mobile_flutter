import 'membership_models.dart';

abstract class MembershipPlanRepository {
  Future<List<MembershipPlan>> listPublic();
}

abstract class UserMembershipRepository {
  Future<List<UserMembership>> listMine();
}
