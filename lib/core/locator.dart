import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/student_repository.dart';
import '../services/module_repository.dart';
import '../services/progress_repository.dart';
import '../services/collection_repository.dart';
import '../services/shop_repository.dart';
import '../services/notification_repository.dart';
import '../services/localization_service.dart';
import '../services/roadmap_repository.dart';
import '../services/progression_service.dart';
import '../services/reward_service.dart';
import '../services/pending_reward_service.dart';
import '../services/knowledge_repository.dart';
import '../services/doubt_repository.dart';
import '../services/speech_service.dart';
import '../services/ai_tutor_service.dart';
import '../services/ollama_ai_provider.dart';
import '../services/retriever.dart';
import '../services/daily_reward_service.dart';
import '../services/mission_service.dart';
import '../services/read_aloud_service.dart';
import '../services/whisper_voice_service.dart';
import '../services/learner_analytics_service.dart';

class Locator {
  static late StorageService storageService;
  static late StudentRepository studentRepository;
  static late ModuleRepository moduleRepository;
  static late ProgressRepository progressRepository;
  static late CollectionRepository collectionRepository;
  static late ShopRepository shopRepository;
  static late NotificationRepository notificationRepository;
  static late AuthService authService;
  
  // V0.3 progression interfaces
  static late RoadmapRepository roadmapRepository;
  static late ProgressionService progressionService;
  static late RewardService rewardService;
  static late PendingRewardService pendingRewardService;

  // V0.4 AI Tutor interfaces
  static late KnowledgeRepository knowledgeRepository;
  static late DoubtRepository doubtRepository;
  static late SpeechToTextProvider speechToTextProvider;
  static late TextToSpeechProvider textToSpeechProvider;
  static late AITutorService aiTutorService;

  // New Game App Services
  static late DailyRewardService dailyRewardService;
  static late MissionService missionService;
  static late ReadAloudService readAloudService;
  static late WhisperVoiceService whisperVoiceService;
  static late LearnerAnalyticsService learnerAnalyticsService;

  static bool _initialized = false;

  static void resetForTest() {
    _initialized = false;
  }

  static Future<void> setup() async {
    if (_initialized) return;
    _initialized = true;
    storageService = await StorageService.init();
    studentRepository = StudentRepository(storageService);
    moduleRepository = ModuleRepository();
    progressRepository = ProgressRepository(storageService);
    collectionRepository = CollectionRepository(storageService);
    shopRepository = ShopRepository(storageService, studentRepository);
    notificationRepository = NotificationRepository(storageService);
    
    // Instantiate progression services
    roadmapRepository = RoadmapRepository();
    progressionService = ProgressionService();
    rewardService = RewardService();
    pendingRewardService = PendingRewardService();
    
    // Instantiate AI Tutor services
    knowledgeRepository = KnowledgeRepository();
    doubtRepository = DoubtRepository();
    speechToTextProvider = MockSpeechToTextProvider();
    textToSpeechProvider = MockTextToSpeechProvider();
    
    aiTutorService = AITutorService();

    // Instantiate New Game App Services
    dailyRewardService = DailyRewardService(storageService);
    missionService = MissionService(storageService);
    readAloudService = ReadAloudService();
    whisperVoiceService = WhisperVoiceService();
    learnerAnalyticsService = LearnerAnalyticsService(storageService);
    
    // Seed and hook auth
    authService = MockAuthService(
      storageService,
      studentRepository,
      progressRepository,
      collectionRepository,
      notificationRepository,
    );

    // Initialize Localization Settings
    LocalizationService.init(storageService);
  }
}
