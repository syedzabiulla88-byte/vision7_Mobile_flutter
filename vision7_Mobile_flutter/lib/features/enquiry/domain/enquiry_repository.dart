import './enquiry_models.dart';

abstract class EnquiryRepository {
  Future<EnquiryResult> submit(Map<String, dynamic> body);
}
