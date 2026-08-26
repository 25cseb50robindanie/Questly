import { SaveManager } from "./SaveManager.js";
import { StateManager } from "./StateManager.js";
import { LevelManager } from "./LevelManager.js";
import { AudioManager } from "./AudioManager.js";
import { UIManager } from "./UIManager.js";
import { IntegrationManager } from "./IntegrationManager.js";
import { CONCEPT_BEATS, GUIDED_PUZZLES, GAME_LEVELS, FINAL_CHALLENGE, TIME_ATTACK_POOL, JOURNEY_STAGES } from "../data/content.js";
import { addFrac, splitFrac, simplify, canSplit, labelOf, toNumber, isSimplified } from "../math/fractions.js";
import { evaluateExploreGoals, syncExploreGoalIds } from "../math/exploreGoals.js";

export class AppEngine {
  constructor() {
    this.save = new SaveManager();
    this.state = new StateManager(this.save);
    this.levels = new LevelManager();
    this.audio = new AudioManager();
    this.ui = new UIManager();
    this.questly = new IntegrationManager("fraction_forge");
    this.mergeBuffer = null;
    this.mode = "PRACTICE";
    this.timeLeft = 0;
    this.timeScore = 0;
    this.timer = null;
    this.fx = [];
    this.canvas = null;
    this.ctx = null;
  }

  init() {
    this.state.load();
    
    // Read stage parameter to determine if we are running as an embedded Questly lesson
    const urlParams = new URLSearchParams(window.location.search);
    const stageParam = urlParams.get('stage');
    this.isEmbedded = !!stageParam;
    this.embeddedStage = stageParam;

    if (this.isEmbedded) {
      document.body.classList.add("questly-embedded");
    }

    this.state.setRoute("HOME");
    this.ui.init({
      go: (r) => this.go(r),
      beginModule: () => this.beginModule(),
      onConceptContinue: () => this.conceptContinue(),
      onExploreClear: () => this.exploreClear(),
      onExploreContinue: () => {
        const goals = syncExploreGoalIds(this.state.state.exploreGoals, evaluateExploreGoals(this.state.state));
        if (goals.allComplete) {
          this.state.completeStage("explore");
          if (this.isEmbedded) {
            this.questly.sendGameComplete(100, 3, 0);
            return;
          }
          this.unlockStage("practice", "PRACTICE");
        }
      },
      onWbReset: () => this.loadCurrentWorkbench(true),
      onWbCheck: () => this.checkWorkbench(),
      onWbNext: () => this.nextWorkbench(),
      onReplay: () => this.replayModule(),
      onResultsContinue: () => this.unlockStage("revision", "REVISION"),
      onRevision: (kind) => this.revision(kind),
      onDrop: (id, dest) => this.drop(id, dest),
      onDouble: (id) => this.doubleClick(id),
      onPickup: () => this.audio.playPickUp(),
      onMute: () => this.toggleMute(),
      onChallengeTab: (id) => this.switchChallenge(id),
      onNavigateStage: (stageId) => this.navigateToStage(stageId),
      getMergeBuffer: () => this.mergeBuffer,
      onBackToQuestly: () => this.questly.sendNavigateBack(),
      novaToast: (_where, msg) => {
        this.ui.setNova("nova-home", "worried");
        const p = document.querySelector("#screen-home .lede");
        if (p) p.textContent = msg;
      }
    });
    this.audio.setMute(this.state.state.muted);
    this.ui.updateMute(this.audio.isMuted);
    this.ui.updateHud(this.state.state);
    this.ui.setCompletedStages(this.state.state.completedStages);
    this.ui.setUnlockedStages(this.state.state.currentStageUnlocked);
    this.ui.renderChapters(this.state.state.completed);
    this.ui.renderJourney("concept", this.state.state.completedStages, this.state.state.currentStageUnlocked);
    this.setupFx();

    if (this.isEmbedded) {
      if (this.embeddedStage === "concept") {
        this.openConcept();
      } else if (this.embeddedStage === "explore") {
        this.openExplore(true);
      } else if (this.embeddedStage === "practice") {
        this.unlockStage("practice", "PRACTICE");
      } else if (this.embeddedStage === "game") {
        this.unlockStage("game", "GAME");
      } else if (this.embeddedStage === "challenge") {
        this.unlockStage("challenge", "CHALLENGE");
      } else {
        this.go("HOME");
      }
    } else {
      this.go("HOME");
    }
  }

  setupFx() {
    this.canvas = document.getElementById("fx-canvas");
    this.ctx = this.canvas.getContext("2d");
    const resize = () => {
      this.canvas.width = innerWidth;
      this.canvas.height = innerHeight;
    };
    resize();
    addEventListener("resize", resize);
    const tick = () => {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.fx = this.fx.filter((p) => p.life > 0);
      this.fx.forEach((p) => {
        p.life -= 1;
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.04;
        this.ctx.globalAlpha = p.life / p.max;
        this.ctx.fillStyle = p.color;
        this.ctx.beginPath();
        this.ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        this.ctx.fill();
      });
      this.ctx.globalAlpha = 1;
      requestAnimationFrame(tick);
    };
    tick();
  }

  burst(x, y) {
    const colors = ["#FFD166", "#06D6A0", "#C7B9E5", "#FF8B94"];
    for (let i = 0; i < 28; i++) {
      this.fx.push({
        x, y,
        vx: (Math.random() - 0.5) * 6,
        vy: (Math.random() - 0.8) * 6,
        r: Math.random() * 4 + 2,
        color: colors[i % 4],
        life: 40,
        max: 40
      });
    }
  }

  toggleMute() {
    const newVal = !this.audio.isMuted;
    this.audio.setMute(newVal);
    this.state.state.muted = newVal;
    this.state.save();
    this.ui.updateMute(newVal);
  }

  go(route) {
    this.audio.playClick();
    this.state.setRoute(route);
    if (route === "CHAPTERS") this.ui.renderChapters(this.state.state.completed);
    if (route === "MODULE_INTRO") {
      this.ui.setCompletedStages(this.state.state.completedStages);
      this.ui.setUnlockedStages(this.state.state.currentStageUnlocked);
      this.ui.renderJourney(this.state.state.moduleStage, this.state.state.completedStages, this.state.state.currentStageUnlocked);
      const begin = document.getElementById("btn-begin-module");
      begin.textContent = this.state.state.completed ? "Open Revision" : "Begin Concept Learning";
    }
    if (route === "REVISION") this.ui.renderMistakes(this.state.state.mistakeHistory);
    const map = {
      PRACTICE: "practice",
      GAME: "game",
      CHALLENGE: "challenge",
      CONCEPT: "concept",
      EXPLORE: "explore",
      RESULTS: "results",
      REVISION: "revision"
    };
    this.ui.show(route, map[route] || this.state.state.moduleStage);
  }

  beginModule() {
    this.audio.playClick();
    if (!this.state.state.started) {
      this.state.state.started = true;
      this.state.save();
      this.questly.sendGameStart();
    }
    const next = this.firstIncomplete();
    if (next === "concept") this.openConcept();
    else if (next === "explore") this.openExplore();
    else if (next === "practice") this.unlockStage("practice", "PRACTICE");
    else if (next === "game") this.unlockStage("game", "GAME");
    else if (next === "challenge") this.unlockStage("challenge", "CHALLENGE");
    else if (next === "results") this.openResults();
    else this.go("REVISION");
  }

  firstIncomplete() {
    for (const s of JOURNEY_STAGES) {
      if (!this.state.state.completedStages.includes(s.id)) return s.id;
    }
    return "revision";
  }

  openConcept() {
    this.state.setModuleStage("concept");
    this.state.state.conceptBeat = 0;
    this.go("CONCEPT");
    this.ui.renderConcept(0);
  }

  conceptContinue() {
    this.audio.playClick();
    const i = this.state.state.conceptBeat;
    if (i < CONCEPT_BEATS.length - 1) {
      this.state.state.conceptBeat = i + 1;
      this.ui.renderConcept(i + 1);
      return;
    }
    this.state.completeStage("concept");
    this.state.unlockStage("explore");
    this.ui.setCompletedStages(this.state.state.completedStages);
    this.ui.setUnlockedStages(this.state.state.currentStageUnlocked);
    if (this.isEmbedded) {
      this.questly.sendGameComplete(100, 3, 0);
      return;
    }
    this.openExplore(true);
  }

  openExplore(reset = false) {
    const wasExploring = this.state.state.moduleStage === "explore";
    this.state.setModuleStage("explore");
    const hasSession = wasExploring && (this.state.state.inventory.length || this.state.state.placed.length);
    if (reset || !hasSession) {
      this.state.state.inventory = this.makePieces([
        { num: 1, den: 2 },
        { num: 1, den: 4 },
        { num: 1, den: 4 },
        { num: 1, den: 8 },
        { num: 1, den: 8 },
        { num: 1, den: 8 },
        { num: 1, den: 8 }
      ]);
      this.state.state.placed = [];
      this.state.state.exploreGoals = [];
    }
    this.mergeBuffer = null;
    this.go("EXPLORE");
    this.syncExploreGoals({ speak: false });
    this.ui.renderExplore(this.state.state);
    this.ui.speakExplore("Try placing another quarter. Drag slices onto the pizza, or stack bars. Split and merge to watch them change.", "happy");
  }

  exploreClear() {
    this.openExplore(true);
  }

  makePieces(defs) {
    return defs.map((d) => {
      if (d.kind) return { id: this.state.nextPieceId(), kind: d.kind };
      return { id: this.state.nextPieceId(), kind: "frac", num: d.num, den: d.den };
    });
  }

  findPiece(id) {
    const s = this.state.state;
    const bags = [s.inventory, s.placed, s.ratioRed, s.ratioBlue];
    for (const bag of bags) {
      const p = bag.find((x) => x.id === id);
      if (p) return { piece: p, bag };
    }
    return null;
  }

  takePiece(id) {
    if (this.mergeBuffer === id) {
      this.mergeBuffer = null;
    }
    const found = this.findPiece(id);
    if (!found) return null;
    found.bag.splice(found.bag.indexOf(found.piece), 1);
    return found.piece;
  }

  storeFraction(piece, template = piece) {
    if (template.zone === "pizza" || template.zone === "bar") {
      piece.zone = template.zone;
      this.state.state.placed.push(piece);
    } else {
      delete piece.zone;
      this.state.state.inventory.push(piece);
    }
  }

  checkpoint() {
    this.state.save();
  }

  drop(id, dest) {
    const piece = this.findPiece(id)?.piece;
    if (!piece) return;
    this.audio.playSnap();

    if (dest === "split") {
      this.splitPiece(id);
      return;
    }
    if (dest === "simplify") {
      this.simplifyPiece(id);
      return;
    }
    if (dest === "merge") {
      this.mergePiece(id);
      return;
    }

    if (dest === "shelf") {
      // A click begins a drag so a quick double-click also briefly lands back
      // on the shelf. Do not rerender in that case: replacing the element
      // between clicks prevents some browsers from emitting dblclick.
      const current = this.findPiece(id);
      if (current?.bag === this.state.state.inventory) return;
      const p = this.takePiece(id);
      if (p) {
        p.zone = undefined;
        this.state.state.inventory.push(p);
      }
      this.checkpoint();
      this.refreshCurrent();
      if (this.state.state.route === "EXPLORE") {
        this.afterExploreChange();
      }
      return;
    }

    const p = this.takePiece(id);
    if (!p) return;

    if (dest === "pizza" || dest === "bar") {
      if (p.kind !== "frac") {
        this.state.state.inventory.push(p);
        this.ui.speakExplore("Ratio blocks belong on the towers later. Use fraction pieces here.", "worried");
        this.afterExploreMutation();
        return;
      }
      p.zone = dest;
      this.state.state.placed.push(p);
      this.checkpoint();
      this.afterExploreChange();
      return;
    }

    if (dest === "bridge") {
      if (p.kind !== "frac") {
        this.state.state.inventory.push(p);
        this.ui.speakWb("Those are ratio supports. Use the colored towers for them.", "worried");
        this.refreshCurrent();
        return;
      }
      this.state.state.placed.push(p);
      this.checkpoint();
      this.refreshCurrent();
      return;
    }

    if (dest === "ratio-red" || dest === "ratio-blue") {
      const need = dest === "ratio-red" ? "ratio-red" : "ratio-blue";
      if (p.kind !== need) {
        this.state.state.inventory.push(p);
        this.ui.speakWb("That color belongs on the other tower.", "worried");
        this.refreshCurrent();
        return;
      }
      (dest === "ratio-red" ? this.state.state.ratioRed : this.state.state.ratioBlue).push(p);
      this.checkpoint();
      this.refreshCurrent();
      return;
    }

    this.state.state.inventory.push(p);
    this.checkpoint();
    this.afterExploreMutation();
  }

  splitPiece(id) {
    const p = this.takePiece(id);
    if (!p || p.kind !== "frac" || !canSplit(p)) {
      if (p) this.state.state.inventory.push(p);
      this.talk("This piece is already tiny. Try a larger one.", "worried");
      this.refreshCurrent();
      return;
    }
    const [a, b] = splitFrac(p);
    this.storeFraction({ id: this.state.nextPieceId(), kind: "frac", num: a.num, den: a.den, crafted: true }, p);
    this.storeFraction({ id: this.state.nextPieceId(), kind: "frac", num: b.num, den: b.den, crafted: true }, p);
    this.state.state.usedSplit = true;
    this.talk(`Split ${labelOf(p)} into two ${labelOf(a)} pieces.`, "happy");
    if (this.state.state.route === "EXPLORE") this.syncExploreGoals();
    this.checkpoint();
    this.refreshCurrent();
  }

  simplifyPiece(id) {
    const p = this.takePiece(id);
    if (!p || p.kind !== "frac") {
      if (p) this.state.state.inventory.push(p);
      this.refreshCurrent();
      return;
    }
    if (isSimplified(p)) {
      this.state.state.inventory.push(p);
      this.talk(`${labelOf(p)} is already in simplest form.`, "neutral");
      this.refreshCurrent();
      return;
    }
    const s = simplify(p);
    this.storeFraction({ id: this.state.nextPieceId(), kind: "frac", num: s.num, den: s.den, fromSimplify: true, crafted: true }, p);
    this.state.state.usedSimplify = true;
    this.talk(`Excellent! ${labelOf(p)} simplifies to ${labelOf(s)}. Same space, simpler name.`, "ecstatic");
    if (this.state.state.route === "EXPLORE") this.syncExploreGoals();
    this.checkpoint();
    this.refreshCurrent();
  }

  mergePiece(id) {
    if (!this.mergeBuffer) {
      const candidate = this.findPiece(id)?.piece;
      if (!candidate || candidate.kind !== "frac") {
        this.talk("Merge needs two fraction pieces.", "worried");
        return;
      }
      this.mergeBuffer = id;
      this.talk("Drop a second matching piece to merge.", "neutral");
      this.refreshCurrent();
      return;
    }
    if (this.mergeBuffer === id) {
      this.mergeBuffer = null;
      this.talk("Merge cancelled.", "neutral");
      this.refreshCurrent();
      return;
    }
    const first = this.findPiece(this.mergeBuffer)?.piece;
    const second = this.findPiece(id)?.piece;
    this.mergeBuffer = null;
    if (!first || !second || first.kind !== "frac" || second.kind !== "frac") {
      this.talk("Merge needs two fraction pieces.", "worried");
      this.refreshCurrent();
      return;
    }
    if (first.den !== second.den) {
      this.talk("Merge matching-sized pieces, such as two eighths or two quarters.", "worried");
      this.refreshCurrent();
      return;
    }
    const a = this.takePiece(first.id);
    const b = this.takePiece(second.id);
    const sum = addFrac(a, b);
    this.storeFraction({ id: this.state.nextPieceId(), kind: "frac", num: sum.num, den: sum.den, crafted: true }, a);
    this.state.state.usedCombine = true;
    this.talk(`Merged into ${labelOf(sum)}. If it can simplify, drop it on Simplify.`, "happy");
    if (this.state.state.route === "EXPLORE") this.syncExploreGoals();
    this.checkpoint();
    this.refreshCurrent();
  }

  doubleClick(id) {
    const found = this.findPiece(id);
    if (!found || found.piece.kind !== "frac") return;
    if (!isSimplified(found.piece) && found.piece.num > 1) {
      this.simplifyPiece(id);
      return;
    }
    this.splitPiece(id);
  }

  afterExploreChange() {
    this.syncExploreGoals();
    this.checkpoint();
    this.refreshCurrent();
  }

  afterExploreMutation() {
    this.syncExploreGoals();
    this.checkpoint();
    this.refreshCurrent();
  }

  syncExploreGoals({ speak = true } = {}) {
    const current = this.state.state.exploreGoals;
    const evaluation = evaluateExploreGoals(this.state.state);
    const synced = syncExploreGoalIds(current, evaluation);
    this.state.state.exploreGoals = synced.next;

    synced.newlyCompleted.forEach((id) => this.markGoal(id));
    if (speak && synced.newlyCompleted.includes("eighths-to-quarter")) {
      this.ui.speakExplore("You built a quarter. Equivalent pieces can cover the same amount.", "ecstatic");
    } else if (speak && synced.newlyCompleted.includes("two-quarters")) {
      this.ui.speakExplore("Two quarters cover exactly the same space as one half.", "ecstatic");
    }

    if (synced.allComplete) {
      this.state.completeStage("explore");
      this.state.unlockStage("practice");
      this.ui.setCompletedStages(this.state.state.completedStages);
      this.ui.setUnlockedStages(this.state.state.currentStageUnlocked);
    }
    this.checkpoint();
  }

  markGoal(id) {
    if (!this.state.state.exploreGoalAwards.includes(id)) {
      this.state.state.exploreGoalAwards.push(id);
      this.state.addXp(15);
      this.state.addCoins(4);
      this.ui.floatReward(15, 4);
      this.audio.playCoinSound();
    }
  }

  talk(msg, mood) {
    if (this.state.state.route === "EXPLORE") this.ui.speakExplore(msg, mood);
    else this.ui.speakWb(msg, mood);
  }

  refreshCurrent() {
    const r = this.state.state.route;
    if (r === "EXPLORE") this.ui.renderExplore(this.state.state);
    else if (["PRACTICE", "GAME", "CHALLENGE", "TIME_ATTACK"].includes(r)) this.paintWorkbench();
  }

  unlockStage(stageId, route) {
    this.state.unlockStage(stageId);
    this.state.setModuleStage(stageId);
    this.state.setRoute(route);
    this.audio.playLockBreak();
    this.ui.setCompletedStages(this.state.state.completedStages);
    this.ui.setUnlockedStages(this.state.state.currentStageUnlocked);
    if (route === "PRACTICE") {
      if (this.state.state.guidedIndex === undefined || this.state.state.guidedIndex >= GUIDED_PUZZLES.length) {
        this.state.state.guidedIndex = 0;
      }
      this.mode = "PRACTICE";
      this.loadCurrentWorkbench(true);
      this.go("PRACTICE");
    } else if (route === "GAME") {
      if (this.state.state.gameIndex === undefined || this.state.state.gameIndex >= GAME_LEVELS.length) {
        this.state.state.gameIndex = 0;
      }
      this.mode = "GAME";
      this.loadCurrentWorkbench(true);
      this.go("GAME");
    } else if (route === "CHALLENGE") {
      this.mode = "CHALLENGE";
      this.state.state.challengeSection = 0;
      this.state.state.challengeDone = { "sec-frac": false, "sec-simp": false, "sec-ratio": false };
      this.loadCurrentWorkbench(true);
      this.go("CHALLENGE");
    } else if (route === "REVISION") {
      this.go("REVISION");
    }
  }

  navigateToStage(stageId) {
    if (!this.state.state.currentStageUnlocked.includes(stageId)) {
      this.talk("That stage is still locked. Finish the previous stage first!", "worried");
      return;
    }
    this.audio.playClick();
    if (stageId === "concept") {
      this.openConcept();
    } else if (stageId === "explore") {
      this.openExplore();
    } else if (stageId === "practice") {
      this.mode = "PRACTICE";
      this.state.setModuleStage("practice");
      this.state.setRoute("PRACTICE");
      this.loadCurrentWorkbench(true);
      this.go("PRACTICE");
    } else if (stageId === "game") {
      this.mode = "GAME";
      this.state.setModuleStage("game");
      this.state.setRoute("GAME");
      this.loadCurrentWorkbench(true);
      this.go("GAME");
    } else if (stageId === "challenge") {
      this.mode = "CHALLENGE";
      this.state.setModuleStage("challenge");
      this.state.setRoute("CHALLENGE");
      this.loadCurrentWorkbench(true);
      this.go("CHALLENGE");
    } else if (stageId === "results") {
      this.openResults();
    } else if (stageId === "revision") {
      this.go("REVISION");
    }
  }

  currentLevel() {
    if (this.mode === "PRACTICE") return GUIDED_PUZZLES[this.state.state.guidedIndex];
    if (this.mode === "GAME") return GAME_LEVELS[this.state.state.gameIndex];
    if (this.mode === "CHALLENGE") return FINAL_CHALLENGE;
    if (this.mode === "TIME_ATTACK") return this.taLevel;
    return null;
  }

  currentSection() {
    if (this.mode !== "CHALLENGE") return null;
    return FINAL_CHALLENGE.sections[this.state.state.challengeSection];
  }

  loadCurrentWorkbench(resetPieces) {
    const level = this.currentLevel();
    const section = this.currentSection();
    const src = section || level;
    if (resetPieces) {
      this.state.state.inventory = this.makePieces(src.inventory);
      this.state.state.placed = [];
      this.state.state.ratioRed = [];
      this.state.state.ratioBlue = [];
      this.state.resetLevelMistakes();
      this.mergeBuffer = null;
    }
    this.paintWorkbench();
    const intro = this.mode === "CHALLENGE"
      ? (this.state.state.challengeSection === 0 ? FINAL_CHALLENGE.novaIntro : "Keep going. No hints on this bridge.")
      : level.novaIntro;
    this.ui.speakWb(intro, this.mode === "CHALLENGE" ? "neutral" : "happy");
    if (this.mode === "PRACTICE") this.ui.showHint("");
    else this.ui.showHint("");
  }

  paintWorkbench() {
    this.ui.renderWorkbench({
      mode: this.mode,
      level: this.currentLevel(),
      section: this.currentSection(),
      sections: FINAL_CHALLENGE.sections,
      state: this.state.state
    });
  }

  switchChallenge(id) {
    const idx = FINAL_CHALLENGE.sections.findIndex((s) => s.id === id);
    if (idx < 0) return;
    this.state.state.challengeSection = idx;
    this.loadCurrentWorkbench(true);
  }

  checkWorkbench() {
    const level = this.currentLevel();
    const section = this.currentSection();
    const src = section || level;
    let result;

    if (src.type === "ratio") {
      result = this.levels.evaluateRatio(this.state.state.ratioRed.length, this.state.state.ratioBlue.length, src.targetRatio);
    } else {
      result = this.levels.evaluateFraction(this.state.state.placed, src.target, {
        requireSimplifiedSingle: src.type === "simplified",
        requireEquivalent: !!src.requireEquivalent
      });
    }

    if (result.success) {
      this.audio.playSuccess();
      this.burst(innerWidth * 0.55, innerHeight * 0.42);
      if (this.mode === "PRACTICE") {
        this.ui.speakWb("The gap is filled exactly. That is the amount we needed — same space, even if the pieces look different.", "ecstatic");
        this.ui.showSuccessReady();
      } else if (this.mode === "TIME_ATTACK") {
        this.timeScore += 1;
        this.ui.speakWb("Exact! Next span!", "happy");
        this.nextTimeAttack();
      } else if (this.mode === "CHALLENGE") {
        this.state.state.challengeDone[src.id] = true;
        const all = Object.values(this.state.state.challengeDone).every(Boolean);
        this.ui.speakWb(all ? "The royal lock accepts every span. You used fractions, equivalents, ratios, and simplification." : "That span is true. Open the next tab.", "ecstatic");
        this.state.addXp(40);
        this.state.addCoins(8);
        this.ui.floatReward(40, 8);
        this.paintWorkbench();
        if (all) {
          this.state.addXp(FINAL_CHALLENGE.xp);
          this.state.addCoins(FINAL_CHALLENGE.coins);
          this.state.addScore(500);
          this.state.completeStage("challenge");
          if (this.isEmbedded) {
            this.questly.sendGameComplete(this.state.state.score, this.levels.starsFromMistakes(this.state.state.mistakes), this.state.state.mistakes);
            return;
          }
          setTimeout(() => this.openResults(), 900);
        }
      } else {
        const xp = level.xp || 50;
        const coins = level.coins || 10;
        this.state.addXp(xp);
        this.state.addCoins(coins);
        this.state.addScore(xp * 8);
        this.ui.floatReward(xp, coins);
        this.audio.playCoinSound();
        this.questly.sendGameProgress(this.state.state.gameIndex, this.state.state.score, this.state.state.mistakes);
        this.ui.speakWb("The planks lock. The explorer can cross!", "ecstatic");
        this.ui.showSuccessReady();
      }
      this.ui.updateHud(this.state.state);
      return;
    }

    this.audio.playFailure();
    this.state.recordMistake({
      title: src.title || level.title,
      target: src.target ? labelOf(src.target) : `${src.targetRatio.red}:${src.targetRatio.blue}`,
      placed: this.state.state.placed.map((p) => labelOf(p)).join(" + ") || `${this.state.state.ratioRed.length}:${this.state.state.ratioBlue.length}`,
      targetPct: src.target ? toNumber(src.target) * 100 : 50,
      placedPct: src.target ? Math.min(100, toNumber(this.levels.sumPlaced(this.state.state.placed)) * 100) : 30,
      why: result.message
    });
    this.state.addScore(-10);
    this.ui.speakWb(result.message, "worried");
    this.ui.showMissing(result.reason === "under" || result.reason === "empty");
    if (this.mode === "PRACTICE") {
      this.ui.showHint(this.levels.hintFor(level, this.state.state.levelMistakes));
    }
    this.ui.updateHud(this.state.state);
  }

  nextWorkbench() {
    this.audio.playClick();
    if (this.mode === "PRACTICE") {
      this.state.state.guidedIndex += 1;
      if (this.state.state.guidedIndex >= GUIDED_PUZZLES.length) {
        this.state.completeStage("practice");
        if (this.isEmbedded) {
          this.questly.sendGameComplete(100, 3, this.state.state.mistakes);
          return;
        }
        this.unlockStage("game", "GAME");
        return;
      }
      this.loadCurrentWorkbench(true);
    } else if (this.mode === "GAME") {
      this.state.state.gameIndex += 1;
      if (this.state.state.gameIndex >= GAME_LEVELS.length) {
        this.state.completeStage("game");
        if (this.isEmbedded) {
          this.questly.sendGameComplete(this.state.state.score, this.levels.starsFromMistakes(this.state.state.mistakes), this.state.state.mistakes);
          return;
        }
        this.unlockStage("challenge", "CHALLENGE");
        return;
      }
      this.loadCurrentWorkbench(true);
    }
  }

  openResults() {
    const stars = this.levels.starsFromMistakes(this.state.state.mistakes);
    this.state.markComplete(stars);
    this.state.setModuleStage("results");
    this.state.completeStage("results");
    this.ui.setCompletedStages(this.state.state.completedStages);
    this.ui.renderResults(this.state.state);
    this.go("RESULTS");
    this.questly.sendGameComplete(this.state.state.score, stars, this.state.state.mistakes);
    this.burst(innerWidth / 2, innerHeight / 3);
  }

  replayModule() {
    this.state.resetModulePlay();
    this.openConcept();
  }

  revision(kind) {
    this.audio.playClick();
    if (kind === "mistakes") {
      this.ui.renderMistakes(this.state.state.mistakeHistory);
      return;
    }
    if (kind === "practice") {
      this.mode = "PRACTICE";
      this.state.state.guidedIndex = 0;
      this.state.setRoute("PRACTICE");
      this.loadCurrentWorkbench(true);
      this.go("PRACTICE");
      return;
    }
    if (kind === "challenge") {
      this.unlockStage("challenge", "CHALLENGE");
      return;
    }
    if (kind === "time") this.startTimeAttack();
  }

  startTimeAttack() {
    this.mode = "TIME_ATTACK";
    this.timeScore = 0;
    this.timeLeft = 60;
    this.state.setRoute("TIME_ATTACK");
    this.nextTimeAttack();
    this.go("TIME_ATTACK");
    clearInterval(this.timer);
    this.timer = setInterval(() => {
      this.timeLeft -= 1;
      this.ui.renderTimeAttack(this.timeScore, this.state.state.timeAttackBest, this.timeLeft);
      if (this.timeLeft <= 0) {
        clearInterval(this.timer);
        this.state.state.timeAttackBest = Math.max(this.state.state.timeAttackBest, this.timeScore);
        this.state.save();
        this.go("REVISION");
        this.ui.renderMistakes([{
          title: "Time attack finished",
          target: "exact spans",
          placed: String(this.timeScore),
          why: `You locked ${this.timeScore} spans. Best: ${this.state.state.timeAttackBest}.`
        }]);
      }
    }, 1000);
  }

  nextTimeAttack() {
    const spec = TIME_ATTACK_POOL[Math.floor(Math.random() * TIME_ATTACK_POOL.length)];
    this.taLevel = {
      title: "Time span",
      novaIntro: `Fill ${labelOf(spec.target)} before the clock wins.`,
      type: "fraction",
      target: spec.target,
      inventory: spec.inventory
    };
    this.loadCurrentWorkbench(true);
    this.ui.renderTimeAttack(this.timeScore, this.state.state.timeAttackBest, this.timeLeft);
  }
}

function compareOver(sum) {
  return toNumber(sum) > 1.001;
}
