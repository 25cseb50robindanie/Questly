/**
 * Persistent Questly + Fraction Module progress.
 */
export class StateManager {
  constructor(saveManager) {
    this.saveManager = saveManager;
    this.storageKey = "questly_fraction_module_v2";
    this.state = this.getInitialState();
  }

  getInitialState() {
    return {
      route: "HOME",
      moduleStage: "concept",
      completedStages: [],
      currentStageUnlocked: ["concept"],
      conceptBeat: 0,
      exploreGoals: [],
      exploreGoalAwards: [],
      guidedIndex: 0,
      gameIndex: 0,
      challengeSection: 0,
      challengeDone: { "sec-frac": false, "sec-simp": false, "sec-ratio": false },
      inventory: [],
      placed: [],
      ratioRed: [],
      ratioBlue: [],
      usedSplit: false,
      usedCombine: false,
      usedSimplify: false,
      score: 0,
      xp: 0,
      coins: 0,
      stars: 0,
      mistakes: 0,
      levelMistakes: 0,
      mistakeHistory: [],
      started: false,
      completed: false,
      revisionUnlocked: false,
      timeAttackBest: 0,
      muted: false,
      pieceSeq: 1
    };
  }

  load() {
    const loaded = this.saveManager.load(this.storageKey, null);
    if (loaded && typeof loaded === "object") {
      this.state = { ...this.getInitialState(), ...loaded };
    }
    ["inventory", "placed", "ratioRed", "ratioBlue", "exploreGoals", "exploreGoalAwards", "completedStages", "currentStageUnlocked"].forEach((key) => {
      if (!Array.isArray(this.state[key])) this.state[key] = [];
    });
    if (!this.state.currentStageUnlocked.includes("concept")) {
      this.state.currentStageUnlocked.push("concept");
    }
  }

  save() {
    this.saveManager.save(this.storageKey, this.state);
  }

  resetModulePlay() {
    const keep = {
      revisionUnlocked: this.state.revisionUnlocked,
      completed: this.state.completed,
      timeAttackBest: this.state.timeAttackBest,
      muted: this.state.muted
    };
    this.state = { ...this.getInitialState(), ...keep, route: "MODULE_INTRO" };
    this.save();
  }

  nextPieceId() {
    const id = `p${this.state.pieceSeq}`;
    this.state.pieceSeq += 1;
    return id;
  }

  setRoute(route) {
    this.state.route = route;
    this.save();
  }

  setModuleStage(stage) {
    this.state.moduleStage = stage;
    this.save();
  }

  completeStage(stageId) {
    if (!this.state.completedStages.includes(stageId)) {
      this.state.completedStages.push(stageId);
    }
    this.save();
  }

  unlockStage(stageId) {
    if (!this.state.currentStageUnlocked.includes(stageId)) {
      this.state.currentStageUnlocked.push(stageId);
    }
    this.save();
  }

  addXp(n) {
    this.state.xp += n;
    this.save();
  }

  addCoins(n) {
    this.state.coins += n;
    this.save();
  }

  addScore(n) {
    this.state.score = Math.max(0, this.state.score + n);
    this.save();
  }

  recordMistake(details) {
    this.state.mistakes += 1;
    this.state.levelMistakes += 1;
    this.state.mistakeHistory.push({
      timestamp: Date.now(),
      ...details
    });
    this.save();
  }

  resetLevelMistakes() {
    this.state.levelMistakes = 0;
  }

  markComplete(stars) {
    this.state.completed = true;
    this.state.revisionUnlocked = true;
    this.state.stars = stars;
    this.unlockStage("revision");
    this.completeStage("results");
    this.save();
  }
}
