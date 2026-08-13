import 'invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> listMyInvoices();
  Future<Invoice> getById(String id);
}
