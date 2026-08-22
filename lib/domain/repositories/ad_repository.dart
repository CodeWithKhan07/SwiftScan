abstract interface class AdRepository {
  bool get initialized;
  String get bannerId;
  Future<void> initialize();
}
