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

class Locator {
  static late final StorageService storageService;
  static late final StudentRepository studentRepository;
  static late final ModuleRepository moduleRepository;
  static late final ProgressRepository progressRepository;
  static late final CollectionRepository collectionRepository;
  static late final ShopRepository shopRepository;
  static late final NotificationRepository notificationRepository;
  static late final AuthService authService;
  
  // V0.3 progression interfaces
  static late final RoadmapRepository roadmapRepository;
  static late final ProgressionService progressionService;
  static late final RewardService rewardService;
  static late final PendingRewardService pendingRewardService;

  // V0.4 AI Tutor interfaces
  static late final KnowledgeRepository knowledgeRepository;
  static late final DoubtRepository doubtRepository;
  static late final SpeechToTextProvider speechToTextProvider;
  static late final TextToSpeechProvider textToSpeechProvider;
  static late final AITutorService aiTutorService;

  // New Game App Services
  static late final DailyRewardService dailyRewardService;
  static late final MissionService missionService;
  static late final ReadAloudService readAloudService;
  static late final WhisperVoiceService whisperVoiceService;

  static bool _initialized = false;

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
    
    final aiProvider = OllamaAIProvider();
    final retriever = KeywordRetriever();
    aiTutorService = AITutorService(aiProvider, retriever);

    // Instantiate New Game App Services
    dailyRewardService = DailyRewardService(storageService);
    missionService = MissionService(storageService);
    readAloudService = ReadAloudService();
    whisperVoiceService = WhisperVoiceService();
    
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
