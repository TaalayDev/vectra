import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/services/in_app_review_service.dart';
import '../core/utils/local_storage.dart';

final analyticsProvider = Provider((ref) => FirebaseAnalytics.instance);

final inAppReviewProvider = Provider<InAppReviewService>((ref) {
  return InAppReviewService();
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});
