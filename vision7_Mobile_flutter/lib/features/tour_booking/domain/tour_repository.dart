import 'tour_models.dart';

abstract class TourRepository {
  Future<TourAvailability> getAvailability(String date);
  Future<TourWindow> getWindow();
  Future<TourBookingResult> book(Map<String, dynamic> body);
}
