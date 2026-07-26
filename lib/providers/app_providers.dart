import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/goal_operations_service.dart';
import '../services/goal_repository.dart';
import '../services/goal_status_service.dart';
import '../services/study_session_repository.dart';
import '../services/subscription_service.dart';

final goalRepositoryProvider = Provider<GoalRepository>((_) => GoalRepository());

final studySessionRepositoryProvider =
    Provider<StudySessionRepository>((_) => StudySessionRepository());

final goalOperationsServiceProvider = Provider<GoalOperationsService>((ref) {
  return GoalOperationsService(
    goalRepo: ref.watch(goalRepositoryProvider),
    sessionRepo: ref.watch(studySessionRepositoryProvider),
  );
});

final goalStatusServiceProvider = Provider<GoalStatusService>((ref) {
  return GoalStatusService(
    ref.watch(goalRepositoryProvider),
    ref.watch(studySessionRepositoryProvider),
  );
});

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (_) => SubscriptionService(),
);

final isPremiumProvider = FutureProvider<bool>((ref) async {
  return ref.watch(subscriptionServiceProvider).isPremium();
});
