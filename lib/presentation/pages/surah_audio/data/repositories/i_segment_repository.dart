import '../models/ayah_segment_model.dart';

/// واجهة مجردة لإدارة بيانات segments القراء
abstract class ISegmentRepository {
  bool hasSegments(int readerIndex);
  Future<void> preloadSegments(int readerIndex);
  Future<SurahSegmentsData?> getSegmentsForSurah(
    int readerIndex,
    int surahNumber,
  );
  bool isLoaded(int readerIndex);
}
