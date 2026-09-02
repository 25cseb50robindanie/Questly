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
            title: 'Level 1: Discover Density',
            order: 1,
            lessons: [
              Lesson(
                id: 'density_les1',
                levelId: 'density_lvl1',
                title: 'Curiosity',
                order: 1,
                activityType: 'discovery_curiosity',
                activities: [
                  Activity(
                    id: 'act_density_curiosity',
                    title: 'Discover Density: Curiosity',
                    instruction: 'Why do some objects float while others sink? Test your predictions and observe.',
                    type: 'discovery_curiosity',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les2',
                levelId: 'density_lvl1',
                title: 'Experiment',
                order: 2,
                activityType: 'experiment',
                activities: [
                  Activity(
                    id: 'act_density_experiment',
                    title: 'Experiment: Mass & Volume',
                    instruction: 'Experiment with mass and volume to see what causes floating.',
                    type: 'experiment',
                    targetDensity: 1.0,
                    targetCondition: 'float',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les3',
                levelId: 'density_lvl1',
                title: 'Apply',
                order: 3,
                activityType: 'apply',
                activities: [
                  Activity(
                    id: 'act_density_apply',
                    title: 'Apply: Real World Scenarios',
                    instruction: 'Apply concepts to everyday materials and objects.',
                    type: 'apply',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les4',
                levelId: 'density_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'challenge',
                activities: [
                  Activity(
                    id: 'act_density_challenge',
                    title: 'Challenge: Buoyancy Puzzle',
                    instruction: 'Test your intuition with tricky buoyancy challenges.',
                    type: 'challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'density_les5',
                levelId: 'density_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'teach_dendy',
                activities: [
                  Activity(
                    id: 'act_density_teach_dendy',
                    title: 'Teach Dendy',
                    instruction: 'Explain why objects float or sink to your companion Dendy.',
                    type: 'teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 100,
                    goldReward: 20,
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

      // 4. Fractions & Ratios (MATHEMATICS)
      Module(
        id: 'mod_fractions',
        title: 'Fractions & Ratios',
        subject: 'MATHEMATICS',
        description: 'See parts of a whole, then build equivalent amounts and bridge ratio crossings.',
        levels: [
          Level(
            id: 'fractions_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 1: Canyon Crossings (Fractions)',
            order: 1,
            lessons: [
              Lesson(
                id: 'fractions_les1',
                levelId: 'fractions_lvl1',
                title: 'Concept Learning',
                order: 1,
                activityType: 'fraction_concept',
                activities: [
                  Activity(
                    id: 'act_fraction_concept',
                    title: 'Concept Learning: Fractions',
                    instruction: 'Learn the fundamentals of fractions, numerator, and denominator.',
                    type: 'fraction_concept',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les2',
                levelId: 'fractions_lvl1',
                title: 'Visual Understanding',
                order: 2,
                activityType: 'fraction_visual',
                activities: [
                  Activity(
                    id: 'act_fraction_visual',
                    title: 'Visual Understanding: Fractions',
                    instruction: 'Explore interactive pizzas, chocolate bars, strips, and number lines.',
                    type: 'fraction_visual',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les3',
                levelId: 'fractions_lvl1',
                title: 'Guided Practice',
                order: 3,
                activityType: 'fraction_practice',
                activities: [
                  Activity(
                    id: 'act_fraction_practice',
                    title: 'Guided Practice: Fractions',
                    instruction: 'Adaptive problem solving with real-time misconception detection.',
                    type: 'fraction_practice',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les4',
                levelId: 'fractions_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'fraction_challenge',
                activities: [
                  Activity(
                    id: 'act_fraction_challenge',
                    title: 'Challenge Arena: Fractions',
                    instruction: 'Bridge builder, flashcards deck, and speed quiz challenges.',
                    type: 'fraction_challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'fractions_les5',
                levelId: 'fractions_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'fraction_teach_dendy',
                activities: [
                  Activity(
                    id: 'act_fraction_teach_dendy',
                    title: 'Teach Dendy: Fractions',
                    instruction: 'Guide Dendy, correct misconceptions, and master the quest!',
                    type: 'fraction_teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 100,
                    goldReward: 20,
                  ),
                ],
              ),
            ],
          ),
          Level(
            id: 'ratios_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 2: Alchemist\'s Workshop (Ratios)',
            order: 2,
            lessons: [
              Lesson(
                id: 'ratios_les1',
                levelId: 'ratios_lvl1',
                title: 'Concept Learning',
                order: 1,
                activityType: 'ratio_concept',
                activities: [
                  Activity(
                    id: 'act_ratio_concept',
                    title: 'Concept Learning: Ratios',
                    instruction: 'Discover ratio relationships, proportions, and notation.',
                    type: 'ratio_concept',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'ratios_les2',
                levelId: 'ratios_lvl1',
                title: 'Visual Understanding',
                order: 2,
                activityType: 'ratio_visual',
                activities: [
                  Activity(
                    id: 'act_ratio_visual',
                    title: 'Visual Understanding: Ratios',
                    instruction: 'Experiment with juice mixing beakers and fruit sorters.',
                    type: 'ratio_visual',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'ratios_les3',
                levelId: 'ratios_lvl1',
                title: 'Guided Practice',
                order: 3,
                activityType: 'ratio_practice',
                activities: [
                  Activity(
                    id: 'act_ratio_practice',
                    title: 'Guided Practice: Ratios',
                    instruction: 'Solve ratio problems with adaptive scaling & misconception detection.',
                    type: 'ratio_practice',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'ratios_les4',
                levelId: 'ratios_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'ratio_challenge',
                activities: [
                  Activity(
                    id: 'act_ratio_challenge',
                    title: 'Challenge Arena: Ratios',
                    instruction: 'Conquer ratio flashcards, recipe scaling, and memory games.',
                    type: 'ratio_challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'ratios_les5',
                levelId: 'ratios_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'ratio_teach_dendy',
                activities: [
                  Activity(
                    id: 'act_ratio_teach_dendy',
                    title: 'Teach Dendy: Ratios',
                    instruction: 'Help Dendy mix potions and achieve ratio mastery!',
                    type: 'ratio_teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 100,
                    goldReward: 20,
                  ),
                ],
              ),
            ],
          ),

          // 3. Quest 3: Proportions
          Level(
            id: 'proportions_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 3: Scale Castle (Proportions)',
            order: 3,
            lessons: [
              Lesson(
                id: 'proportions_les1',
                levelId: 'proportions_lvl1',
                title: 'Concept Learning',
                order: 1,
                activityType: 'proportion_concept',
                activities: [
                  Activity(
                    id: 'act_proportion_concept',
                    title: 'Concept Learning: Proportions',
                    instruction: 'Understand scale factors, equivalent ratios, and cross-multiplication.',
                    type: 'proportion_concept',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'proportions_les2',
                levelId: 'proportions_lvl1',
                title: 'Visual Understanding',
                order: 2,
                activityType: 'proportion_visual',
                activities: [
                  Activity(
                    id: 'act_proportion_visual',
                    title: 'Visual Understanding: Proportions',
                    instruction: 'Scale shapes and balance proportions on the interactive scale.',
                    type: 'proportion_visual',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'proportions_les3',
                levelId: 'proportions_lvl1',
                title: 'Guided Practice',
                order: 3,
                activityType: 'proportion_practice',
                activities: [
                  Activity(
                    id: 'act_proportion_practice',
                    title: 'Guided Practice: Proportions',
                    instruction: 'Adaptive proportion equations and misconception diagnostics.',
                    type: 'proportion_practice',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'proportions_les4',
                levelId: 'proportions_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'proportion_challenge',
                activities: [
                  Activity(
                    id: 'act_proportion_challenge',
                    title: 'Challenge Arena: Proportions',
                    instruction: 'Scale the castle gate and solve proportion blitz puzzles.',
                    type: 'proportion_challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'proportions_les5',
                levelId: 'proportions_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'proportion_teach_dendy',
                activities: [
                  Activity(
                    id: 'act_proportion_teach_dendy',
                    title: 'Teach Dendy: Proportions',
                    instruction: 'Guide Dendy to scale maps and achieve proportion mastery!',
                    type: 'proportion_teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 100,
                    goldReward: 20,
                  ),
                ],
              ),
            ],
          ),

          // 4. Quest 4: Percentages
          Level(
            id: 'percentages_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 4: Market Bazaar (Percentages)',
            order: 4,
            lessons: [
              Lesson(
                id: 'percentages_les1',
                levelId: 'percentages_lvl1',
                title: 'Concept Learning',
                order: 1,
                activityType: 'percentage_concept',
                activities: [
                  Activity(
                    id: 'act_percentage_concept',
                    title: 'Concept Learning: Percentages',
                    instruction: 'Discover parts per hundred and conversions to fractions & decimals.',
                    type: 'percentage_concept',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'percentages_les2',
                levelId: 'percentages_lvl1',
                title: 'Visual Understanding',
                order: 2,
                activityType: 'percentage_visual',
                activities: [
                  Activity(
                    id: 'act_percentage_visual',
                    title: 'Visual Understanding: Percentages',
                    instruction: 'Explore 100-grids, discount visualizers, and circular percentage dials.',
                    type: 'percentage_visual',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'percentages_les3',
                levelId: 'percentages_lvl1',
                title: 'Guided Practice',
                order: 3,
                activityType: 'percentage_practice',
                activities: [
                  Activity(
                    id: 'act_percentage_practice',
                    title: 'Guided Practice: Percentages',
                    instruction: 'Adaptive percentage discounts and tax calculations with error remediation.',
                    type: 'percentage_practice',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'percentages_les4',
                levelId: 'percentages_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'percentage_challenge',
                activities: [
                  Activity(
                    id: 'act_percentage_challenge',
                    title: 'Challenge Arena: Percentages',
                    instruction: 'Discount shopper speed challenge and percentage flashcards.',
                    type: 'percentage_challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'percentages_les5',
                levelId: 'percentages_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'percentage_teach_dendy',
                activities: [
                  Activity(
                    id: 'act_percentage_teach_dendy',
                    title: 'Teach Dendy: Percentages',
                    instruction: 'Teach Dendy how discounts work in the market!',
                    type: 'percentage_teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 100,
                    goldReward: 20,
                  ),
                ],
              ),
            ],
          ),

          // 5. Quest 5: Real-World Applications
          Level(
            id: 'applications_lvl1',
            moduleId: 'mod_fractions',
            title: 'Level 5: Royal Architect (Real-World Applications)',
            order: 5,
            lessons: [
              Lesson(
                id: 'applications_les1',
                levelId: 'applications_lvl1',
                title: 'Concept Learning',
                order: 1,
                activityType: 'application_concept',
                activities: [
                  Activity(
                    id: 'act_application_concept',
                    title: 'Concept Learning: Real-World Applications',
                    instruction: 'Synthesize fractions, ratios, proportions, and percentages in kingdom engineering.',
                    type: 'application_concept',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 40,
                    goldReward: 5,
                  ),
                ],
              ),
              Lesson(
                id: 'applications_les2',
                levelId: 'applications_lvl1',
                title: 'Visual Understanding',
                order: 2,
                activityType: 'application_visual',
                activities: [
                  Activity(
                    id: 'act_application_visual',
                    title: 'Visual Understanding: Applications',
                    instruction: 'Interact with blueprint maps and feast recipe cauldrons.',
                    type: 'application_visual',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'applications_les3',
                levelId: 'applications_lvl1',
                title: 'Guided Practice',
                order: 3,
                activityType: 'application_practice',
                activities: [
                  Activity(
                    id: 'act_application_practice',
                    title: 'Guided Practice: Applications',
                    instruction: 'Solve multi-step architectural and recipe problems adaptively.',
                    type: 'application_practice',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 60,
                    goldReward: 10,
                  ),
                ],
              ),
              Lesson(
                id: 'applications_les4',
                levelId: 'applications_lvl1',
                title: 'Challenge',
                order: 4,
                activityType: 'application_challenge',
                activities: [
                  Activity(
                    id: 'act_application_challenge',
                    title: 'Challenge Arena: Applications',
                    instruction: 'Master the ultimate Kingdom Builder challenge.',
                    type: 'application_challenge',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 80,
                    goldReward: 15,
                  ),
                ],
              ),
              Lesson(
                id: 'applications_les5',
                levelId: 'applications_lvl1',
                title: 'Teach Dendy',
                order: 5,
                activityType: 'application_teach_dendy',
                activities: [
                  Activity(
                    id: 'act_application_teach_dendy',
                    title: 'Teach Dendy: Grand Master',
                    instruction: 'Help Dendy complete the King\'s Great Bridge and achieve Grand Mastery!',
                    type: 'application_teach_dendy',
                    targetDensity: 0.0,
                    targetCondition: '',
                    xpReward: 120,
                    goldReward: 30,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<Module> getAllModules() => getModules();

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

  Activity? getActivityById(String id) {
    for (var m in getModules()) {
      for (var lvl in m.levels) {
        for (var les in lvl.lessons) {
          for (var act in les.activities) {
            if (act.id == id) return act;
          }
        }
      }
    }
    return null;
  }
}
