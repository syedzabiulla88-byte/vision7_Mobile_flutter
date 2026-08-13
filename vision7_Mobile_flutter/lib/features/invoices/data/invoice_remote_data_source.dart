import '../../../../core/network/dio_client.dart';
import '../domain/invoice.dart';

class InvoiceRemoteDataSource {
  final DioClient _client;
  InvoiceRemoteDataSource(this._client);

  Future<List<Invoice>> listMyInvoices() async {
    final result = await _client.get<List<dynamic>>('/me/invoices');
    if (result == null) return [];
    return result
        .map((i) => Invoice.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Invoice> getById(String id) async {
    final result = await _client.get<Invoice>(
      '/me/invoices/$id',
      fromJson: (json) => Invoice.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Invoice not found');
    return result;
  }
}
