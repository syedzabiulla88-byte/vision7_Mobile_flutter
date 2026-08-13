import '../domain/enquiry_models.dart';
import '../domain/enquiry_repository.dart';
import '../data/enquiry_remote_data_source.dart';

class EnquiryRepositoryImpl implements EnquiryRepository {
  final EnquiryRemoteDataSource _remote;
  EnquiryRepositoryImpl(this._remote);

  @override
  Future<EnquiryResult> submit(Map<String, dynamic> body) =>
      _remote.submit(body);
}
