import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import '../data/invoice_remote_data_source.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _remote;
  InvoiceRepositoryImpl(this._remote);

  @override
  Future<List<Invoice>> listMyInvoices() => _remote.listMyInvoices();

  @override
  Future<Invoice> getById(String id) => _remote.getById(id);
}
