import '../models/module.dart';
import '../models/level.dart';
import '../models/lesson.dart';
import '../models/activity.dart';

class ModuleRepository {
  List<Module> getModules() {
    return [
      // 1. Density & Buoyancy (SCIENCE / physics topic)
      Module(
        id: 'mod_density',
        title: 'Density & Buoyancy',
        subject: 'SCIENCE',
        description: 'Explore the physics of mass, volume, and how materials behave in fluids.',
        levels: [
          Level(
            id: 'density_lvl1',
            moduleId: 'mod_density',
            title: 'Level 1: Volume & Mass',
            order: 1,
            lessons: [
              Lesson(
                id: 'density_les1',
                levelId: 'density_lvl1',
                title: 'Introduction to Density',
                order: 1,
                activityType: 'flashcard',
                activities: [
                  Activity(
                    id: 'act_density_intro',
                    title: 'Understanding Density',
                    instruction: 'Density is how tightly packed particles are inside a material. Swipe through these concepts to learn the formula: Density = Mass / Volume.',
                    type: 'flashcard',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 30,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les2',
                levelId: 'density_lvl1',
                title: 'Determining Volume',
                order: 2,
                activityType: 'scenario',
                activities: [
                  Activity(
                    id: 'act_density_vol',
                    title: 'Water Displacement Challenge',
                    instruction: 'Observe how dropping an object in a graduated cylinder rises the water level. Solve the volume difference to understand cubic displacement.',
                    type: 'scenario',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 30,
                    goldReward: 5,
                  ),
                ],
              ),
            ],
          ),
          Level(
            id: 'density_lvl2',
            moduleId: 'mod_density',
            title: 'Level 2: Buoyancy Laws',
            order: 2,
            lessons: [
              Lesson(
                id: 'density_les3',
                levelId: 'density_lvl2',
                title: 'Floating Experiment',
                order: 1,
                activityType: 'flameGame',
                activities: [
                  Activity(
                    id: 'act_float_challenge', // Matches current Floatation simulation
                    title: 'Floatation Lab',
                    instruction: 'Adjust the mass and volume sliders so the block density is LESS than water (1.0 kg/L) and it floats safely!',
                    type: 'flameGame',
                    targetDensity: 1.0,
                    targetCondition: 'float',
                    xpReward: 100,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les4',
                levelId: 'density_lvl2',
                title: 'Sinking Experiment',
                order: 2,
                activityType: 'flameGame',
                activities: [
                  Activity(
                    id: 'act_sink_challenge', // Matches current Sinker simulation
                    title: 'Abyssal Sinker',
                    instruction: 'Adjust the mass and volume sliders so the block density is GREATER than water (1.0 kg/L) and it sinks to the seabed!',
                    type: 'flameGame',
                    targetDensity: 1.0,
                    targetCondition: 'sink',
                    xpReward: 100,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les5',
                levelId: 'density_lvl2',
                title: 'Archimedes Challenge',
                order: 3,
                activityType: 'quiz',
                activities: [
                  Activity(
                    id: 'act_density_archimedes',
                    title: 'Archimedes Crown Quiz',
                    instruction: 'Complete the scenario challenge where King Hiero ask Archimedes to check if his crown is pure gold.',
                    type: 'quiz',
                    targetDensity: 19.3,
                    targetCondition: 'exact',
                    xpReward: 50,
                    goldReward: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // 2. Forces & Motion (PHYSICS)
      Module(
        id: 'mod_forces',
        title: 'Forces & Motion',
        subject: 'PHYSICS',
        description: 'Investigate gravity, friction, and Newton\'s laws of acceleration.',
        levels: [
          Level(
            id: 'forces_lvl1',
            moduleId: 'mod_forces',
            title: 'Level 1: Push & Pull',
            order: 1,
            lessons: [
              Lesson(
                id: 'forces_les1',
                levelId: 'forces_lvl1',
                title: 'Friction Basics',
                order: 1,
                activityType: 'flashcard',
                activities: [
                  Activity(
                    id: 'act_friction_basics',
                    title: 'Rough vs Smooth Surfaces',
                    instruction: 'Learn how friction resists movement and acts opposite to slide vectors.',
                    type: 'flashcard',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 30,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'forces_les2',
                levelId: 'forces_lvl1',
                title: 'Friction Lab',
                order: 2,
                activityType: 'simulation',
                activities: [
                  Activity(
                    id: 'act_friction_sim',
                    title: 'Surface Sled Sorter',
                    instruction: 'Apply force to pull a sled across rough gravel versus smooth ice.',
                    type: 'simulation',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 50,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'forces_les3',
                levelId: 'forces_lvl1',
                title: 'Gravity & Air Resistance',
                order: 3,
                activityType: 'quiz',
                activities: [
                  Activity(
                    id: 'act_gravity_quiz',
                    title: 'Galileo Gravity Drop',
                    instruction: 'Do heavier objects fall faster in a vacuum? Answer the Galileo dropping challenge.',
                    type: 'quiz',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 50,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'forces_les4',
                levelId: 'forces_lvl1',
                title: 'Newton\'s First Law',
                order: 4,
                activityType: 'scenario',
                activities: [
                  Activity(
                    id: 'act_newton_inertia',
                    title: 'The Inertia Coin Trick',
                    instruction: 'Flick a card and see the coin drop directly into a cup. Explain inertia!',
                    type: 'scenario',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // 3. Matter Around Us (SCIENCE)
      Module(
        id: 'mod_matter',
        title: 'Matter Around Us',
        subject: 'SCIENCE',
        description: 'Explore the states of matter: solid, liquid, and gas molecules.',
        levels: [
          Level(
            id: 'matter_lvl1',
            moduleId: 'mod_matter',
            title: 'Level 1: Three States',
            order: 1,
            lessons: [
              Lesson(
                id: 'matter_les1',
                levelId: 'matter_lvl1',
                title: 'Solids & Liquids',
                order: 1,
                activityType: 'flashcard',
                activities: [
                  Activity(
                    id: 'act_matter_states',
                    title: 'Molecule Arrangement',
                    instruction: 'Solids have tightly packed molecules. Liquids flow and fill containers.',
                    type: 'flashcard',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 20,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'matter_les2',
                levelId: 'matter_lvl1',
                title: 'Phase Transitions',
                order: 2,
                activityType: 'quiz',
                activities: [
                  Activity(
                    id: 'act_matter_transitions',
                    title: 'Ice Melting & Boiling Quiz',
                    instruction: 'Test your understanding of heat energy absorption and evaporation.',
                    type: 'quiz',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // 4. Fractions & Decimals (MATHEMATICS)
      Module(
        id: 'mod_fractions',
        title: 'Fractions & Decimals',
        subject: 'MATHEMATICS',
        description: 'Visualize fractional shares and solve decimal equation puzzles.',
        levels: [
          Level(
            id: 'fractions_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 1: Part of a Whole',
            order: 1,
            lessons: [
              Lesson(
                id: 'fractions_les1',
                levelId: 'fractions_lvl1',
                title: 'Pizza Fractions Intro',
                order: 1,
                activityType: 'flashcard',
                activities: [
                  Activity(
                    id: 'act_pizza_fraction',
                    title: 'Visualizing Fractions',
                    instruction: 'Cut pizzas into slices to represent 1/2, 1/4, and 3/8 shares.',
                    type: 'flashcard',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 20,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les2',
                levelId: 'fractions_lvl1',
                title: 'Numerator & Denominator',
                order: 2,
                activityType: 'scenario',
                activities: [
                  Activity(
                    id: 'act_fraction_terms',
                    title: 'Name the Fraction',
                    instruction: 'Identify the top number (Numerator) and the bottom number (Denominator) in custom scenario slides.',
                    type: 'scenario',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 30,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les3',
                levelId: 'fractions_lvl1',
                title: 'Equivalent Fractions',
                order: 3,
                activityType: 'quiz',
                activities: [
                  Activity(
                    id: 'act_equivalent_fractions',
                    title: 'Fraction Match Challenge',
                    instruction: 'Identify that 2/4 is equivalent to 1/2 in this matching challenge.',
                    type: 'quiz',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Module? getModuleById(String id) {
    for (var m in getModules()) {
      if (m.id == id) return m;
    }
    return null;
  }

  Lesson? getLessonById(String id) {
    for (var m in getModules()) {
      for (var lvl in m.levels) {
        for (var les in lvl.lessons) {
          if (les.id == id) return les;
        }
      }
    }
    return null;
  }
}
