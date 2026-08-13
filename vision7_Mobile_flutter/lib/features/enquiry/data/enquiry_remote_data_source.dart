import '../../../../core/network/dio_client.dart';
import '../domain/enquiry_models.dart';

class EnquiryRemoteDataSource {
  final DioClient _client;
  EnquiryRemoteDataSource(this._client);

  Future<EnquiryResult> submit(Map<String, dynamic> body) async {
    final result = await _client.post<EnquiryResult>(
      '/crm/enquiry',
      body,
      fromJson: (json) =>
          EnquiryResult.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Enquiry submission failed');
    return result;
  }
}
