import { novaSvg } from "../ui/nova.js";
import { SUBJECTS, MATH_TOPICS, CHAPTERS, JOURNEY_STAGES, CONCEPT_BEATS, EXPLORE_GOALS, PIECE_COLORS } from "../data/content.js";
import { labelOf, toNumber } from "../math/fractions.js";

export class UIManager {
  constructor() {
    this.drag = null;
    this.ghost = null;
    this.hot = null;
    this.lastPiecePress = null;
  }

  init(cb) {
    this.cb = cb;
    this.el = {
      screens: {
        HOME: document.getElementById("screen-home"),
        MATH: document.getElementById("screen-math"),
        TOPIC: document.getElementById("screen-topic"),
        CHAPTERS: document.getElementById("screen-chapters"),
        MODULE_INTRO: document.getElementById("screen-module"),
        CONCEPT: document.getElementById("screen-concept"),
        EXPLORE: document.getElementById("screen-explore"),
        WORKBENCH: document.getElementById("screen-workbench"),
        RESULTS: document.getElementById("screen-results"),
        REVISION: document.getElementById("screen-revision")
      },
      brand: document.getElementById("brand-name"),
      journey: document.getElementById("journey-strip"),
      hudXp: document.getElementById("hud-xp"),
      hudCoins: document.getElementById("hud-coins"),
      hudScore: document.getElementById("hud-score"),
      mute: document.getElementById("mute-btn"),
      homeSubjects: document.getElementById("home-subjects"),
      mathTopics: document.getElementById("math-topics"),
      chapterList: document.getElementById("chapter-list"),
      moduleRoadmap: document.getElementById("module-roadmap"),
      moduleSpeech: document.getElementById("module-speech"),
      conceptVisual: document.getElementById("concept-visual"),
      conceptCaption: document.getElementById("concept-caption"),
      conceptSpeech: document.getElementById("concept-speech"),
      exploreSpeech: document.getElementById("explore-speech"),
      pizzaDrop: document.getElementById("pizza-drop"),
      barTrack: document.getElementById("bar-track"),
      exploreShelf: document.getElementById("explore-shelf"),
      exploreGoals: document.getElementById("explore-goals"),
      exploreContinue: document.getElementById("btn-explore-continue"),
      wbKicker: document.getElementById("wb-kicker"),
      wbSpeech: document.getElementById("wb-speech"),
      wbHint: document.getElementById("wb-hint"),
      missing: document.getElementById("missing-preview"),
      wbTitle: document.getElementById("wb-title"),
      wbDesc: document.getElementById("wb-desc"),
      wbTarget: document.getElementById("wb-target"),
      challengeTabs: document.getElementById("challenge-tabs"),
      bridgeSlot: document.getElementById("bridge-slot"),
      targetGhost: document.getElementById("target-ghost"),
      ratioZone: document.getElementById("ratio-zone"),
      ratioRed: document.getElementById("ratio-red"),
      ratioBlue: document.getElementById("ratio-blue"),
      ratioLabel: document.getElementById("ratio-label"),
      wbShelf: document.getElementById("wb-shelf"),
      wbCheck: document.getElementById("btn-wb-check"),
      wbNext: document.getElementById("btn-wb-next"),
      resultStars: document.getElementById("result-stars"),
      resScore: document.getElementById("res-score"),
      resXp: document.getElementById("res-xp"),
      resCoins: document.getElementById("res-coins"),
      resMistakes: document.getElementById("res-mistakes"),
      revBody: document.getElementById("rev-body")
    };

    document.getElementById("home-nova").innerHTML = novaSvg("nova-home");
    document.getElementById("topic-nova").innerHTML = novaSvg("nova-topic");
    document.getElementById("module-nova").innerHTML = novaSvg("nova-mod");
    document.getElementById("concept-nova").innerHTML = novaSvg("nova-concept");
    document.getElementById("explore-nova").innerHTML = novaSvg("nova-explore");
    document.getElementById("wb-nova").innerHTML = novaSvg("nova-wb");
    this.setNova("nova-home", "happy");
    this.setNova("nova-topic", "neutral");

    this.el.mute.addEventListener("click", () => this.cb.onMute());
    document.getElementById("btn-open-chapters").addEventListener("click", () => this.cb.go("CHAPTERS"));
    document.getElementById("btn-begin-module").addEventListener("click", () => this.cb.beginModule());
    document.getElementById("btn-concept-continue").addEventListener("click", () => this.cb.onConceptContinue());
    document.getElementById("btn-explore-clear").addEventListener("click", () => this.cb.onExploreClear());
    document.getElementById("btn-explore-continue").addEventListener("click", () => this.cb.onExploreContinue());
    document.getElementById("btn-wb-reset").addEventListener("click", () => this.cb.onWbReset());
    document.getElementById("btn-wb-check").addEventListener("click", () => this.cb.onWbCheck());
    document.getElementById("btn-wb-next").addEventListener("click", () => this.cb.onWbNext());
    document.getElementById("btn-replay").addEventListener("click", () => this.cb.onReplay());
    document.getElementById("btn-results-continue").addEventListener("click", () => this.cb.onResultsContinue());
    document.getElementById("btn-back-questly").addEventListener("click", () => {
      if (this.cb.onBackToQuestly) {
        this.cb.onBackToQuestly();
      } else {
        this.cb.go("HOME");
      }
    });

    document.querySelectorAll("[data-back]").forEach((btn) => {
      btn.addEventListener("click", () => this.cb.go(btn.getAttribute("data-back")));
    });
    document.querySelectorAll("[data-rev]").forEach((btn) => {
      btn.addEventListener("click", () => this.cb.onRevision(btn.getAttribute("data-rev")));
    });

    this.renderHome();
    this.renderMath();
    this.spawnStars();

    document.addEventListener("mousemove", (e) => this.onMove(e));
    document.addEventListener("touchmove", (e) => this.onMove(e), { passive: false });
    document.addEventListener("mouseup", (e) => this.onUp(e));
    document.addEventListener("touchend", (e) => this.onUp(e));
    document.addEventListener("touchcancel", (e) => this.onUp(e));
  }

  spawnStars() {
    const field = document.getElementById("stars-field");
    for (let i = 0; i < 40; i++) {
      const s = document.createElement("div");
      s.className = "star-dot";
      s.style.left = `${Math.random() * 100}%`;
      s.style.top = `${Math.random() * 70}%`;
      s.style.animationDelay = `${Math.random() * 3}s`;
      field.appendChild(s);
    }
  }

  show(route, moduleStage) {
    Object.entries(this.el.screens).forEach(([key, node]) => {
      const workbench = route === "PRACTICE" || route === "GAME" || route === "CHALLENGE" || route === "TIME_ATTACK";
      const match = key === route || (key === "WORKBENCH" && workbench);
      node.classList.toggle("hidden", !match);
      node.classList.toggle("active", match);
    });
    const inModule = ["CONCEPT", "EXPLORE", "PRACTICE", "GAME", "CHALLENGE", "RESULTS", "REVISION"].includes(route);
    this.el.journey.classList.toggle("hidden", !inModule);
    this.el.brand.textContent = route === "HOME" ? "Questly" : inModule ? "Fraction Module" : "Questly";
    if (inModule) this.renderJourney(moduleStage, this._completed || [], this._unlockedStages || []);
  }

  setCompletedStages(list) {
    this._completed = list;
  }

  setUnlockedStages(list) {
    this._unlockedStages = list;
  }

  updateHud(state) {
    this.el.hudXp.textContent = state.xp;
    this.el.hudCoins.textContent = state.coins;
    this.el.hudScore.textContent = state.score;
  }

  updateMute(muted) {
    this.el.mute.innerHTML = muted
      ? `<svg viewBox="0 0 24 24" width="20" height="20"><path fill="#F4EFE6" d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM5.2 3.9L3.8 5.3 7.5 9H3v6h4.2L16 22.3V14.2l4.7 4.7 1.4-1.4z"/></svg>`
      : `<svg viewBox="0 0 24 24" width="20" height="20"><path fill="#F4EFE6" d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>`;
  }

  setNova(id, mood) {
    const svg = document.getElementById(id);
    if (svg) svg.setAttribute("class", `nova-svg expression-${mood}`);
  }

  renderHome() {
    this.el.homeSubjects.innerHTML = SUBJECTS.map((s) => `
      <button class="world-card ${s.unlocked ? "" : "locked"}" data-subject="${s.id}">
        <h3>${s.title}</h3>
        <p>${s.blurb}</p>
      </button>
    `).join("");
    this.el.homeSubjects.querySelectorAll("[data-subject]").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (btn.classList.contains("locked")) {
          this.cb.novaToast("HOME", "That world is still sealed. Open Math to start your first trail.");
          return;
        }
        this.cb.go("MATH");
      });
    });
  }

  renderMath() {
    this.el.mathTopics.innerHTML = MATH_TOPICS.map((t) => `
      <button class="world-card ${t.unlocked ? "" : "locked"}" data-topic="${t.id}">
        <h3>${t.title}</h3>
        <p>${t.blurb}</p>
      </button>
    `).join("");
    this.el.mathTopics.querySelectorAll("[data-topic]").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (btn.classList.contains("locked")) return;
        this.cb.go("TOPIC");
      });
    });
  }

  renderChapters(completed) {
    this.el.chapterList.innerHTML = CHAPTERS.map((c) => {
      const isUnlocked = c.unlocked || (completed && (c.id === "ratio-recipes" || c.id === "mixed-spans"));
      return `
        <button class="chapter-card ${isUnlocked ? "" : "locked"}" data-ch="${c.id}">
          <h3>${c.title}</h3>
          <p>${c.blurb}</p>
          ${completed && c.id === "canyon-crossings" ? "<small>✓ Mastered — revision unlocked</small>" : ""}
        </button>
      `;
    }).join("");
    this.el.chapterList.querySelectorAll("[data-ch]").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (btn.classList.contains("locked")) return;
        this.cb.go("MODULE_INTRO");
      });
    });
  }

  renderJourney(current, completed, unlockedStages = []) {
    const order = JOURNEY_STAGES.map((s) => s.id);
    
    this.el.journey.innerHTML = JOURNEY_STAGES.map((s) => {
      const isUnlocked = unlockedStages.includes(s.id);
      const cls = completed.includes(s.id) ? "done" : s.id === current ? "now" : isUnlocked ? "unlocked" : "lock";
      return `<div class="j-node ${cls} clickable-node" data-stage="${s.id}"><div class="dot"></div><span>${s.label}</span></div>`;
    }).join("");
    
    this.el.moduleRoadmap.innerHTML = JOURNEY_STAGES.map((s) => {
      const isUnlocked = unlockedStages.includes(s.id);
      const cls = completed.includes(s.id) ? "done" : s.id === current ? "now" : isUnlocked ? "unlocked" : "lock";
      const orbContent = completed.includes(s.id) ? "✓" : order.indexOf(s.id) + 1;
      return `<div class="r-node ${cls} clickable-node" data-stage="${s.id}"><div class="orb">${orbContent}</div><small>${s.label}</small></div>`;
    }).join("");

    this.el.journey.querySelectorAll(".clickable-node").forEach((node) => {
      node.addEventListener("click", () => {
        const stageId = node.getAttribute("data-stage");
        this.cb.onNavigateStage(stageId);
      });
    });
    
    this.el.moduleRoadmap.querySelectorAll(".clickable-node").forEach((node) => {
      node.addEventListener("click", () => {
        const stageId = node.getAttribute("data-stage");
        this.cb.onNavigateStage(stageId);
      });
    });
  }

  renderConcept(beatIndex) {
    const beat = CONCEPT_BEATS[beatIndex];
    this.el.conceptSpeech.textContent = beat.nova;
    this.el.conceptCaption.textContent = beat.caption;
    this.el.conceptVisual.innerHTML = this.pizzaSvg(beat.id);
    this.setNova("nova-concept", beat.id === "equivalent" ? "ecstatic" : beatIndex === 0 ? "neutral" : "happy");
    document.getElementById("btn-concept-continue").textContent = beatIndex >= CONCEPT_BEATS.length - 1 ? "Continue" : "Continue";
  }

  pizzaSvg(mode) {
    if (mode === "whole") {
      return `<svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="82" fill="#FFD166" stroke="#4C3970" stroke-width="6"/><circle cx="100" cy="100" r="8" fill="#c47b2a"/><text x="100" y="190" text-anchor="middle" fill="#FFD166" font-size="16" font-weight="700">1</text></svg>`;
    }
    if (mode === "halves") {
      return `<svg viewBox="0 0 200 200">
        <path class="slice enter" d="M100 100 L100 18 A82 82 0 0 0 100 182 Z" fill="#FFD166" stroke="#4C3970" stroke-width="4"/>
        <path class="slice enter" d="M100 100 L100 18 A82 82 0 0 1 100 182 Z" fill="#87c4a8" stroke="#4C3970" stroke-width="4"/>
        <text x="60" y="108" font-weight="800" fill="#29213D">1/2</text>
        <text x="120" y="108" font-weight="800" fill="#29213D">1/2</text>
      </svg>`;
    }
    if (mode === "quarters") {
      return `<svg viewBox="0 0 200 200">
        <path class="slice enter" d="M100 100 L100 18 A82 82 0 0 1 182 100 Z" fill="#118AB2" stroke="#4C3970" stroke-width="3"/>
        <path class="slice enter" d="M100 100 L182 100 A82 82 0 0 1 100 182 Z" fill="#FF8B94" stroke="#4C3970" stroke-width="3"/>
        <path class="slice enter" d="M100 100 L100 182 A82 82 0 0 1 18 100 Z" fill="#C7B9E5" stroke="#4C3970" stroke-width="3"/>
        <path class="slice enter" d="M100 100 L18 100 A82 82 0 0 1 100 18 Z" fill="#FFD166" stroke="#4C3970" stroke-width="3"/>
        <text x="118" y="70" font-size="13" font-weight="800">1/4</text>
        <text x="118" y="140" font-size="13" font-weight="800">1/4</text>
        <text x="52" y="140" font-size="13" font-weight="800">1/4</text>
        <text x="52" y="70" font-size="13" font-weight="800">1/4</text>
      </svg>`;
    }
    return `<svg viewBox="0 0 200 200">
      <circle cx="100" cy="100" r="82" fill="rgba(255,255,255,.06)" stroke="#4C3970" stroke-width="3"/>
      <path class="slice enter" d="M100 100 L100 18 A82 82 0 0 1 182 100 Z" fill="#FFD166" stroke="#4C3970" stroke-width="4"/>
      <path class="slice enter" d="M100 100 L182 100 A82 82 0 0 1 100 182 Z" fill="#FFD166" stroke="#4C3970" stroke-width="4"/>
      <path d="M18 100 A82 82 0 0 1 100 18" fill="none" stroke="#FFD166" stroke-width="4" stroke-dasharray="6 6"/>
      <text x="128" y="78" font-size="13" font-weight="800" fill="#29213D">1/4</text>
      <text x="128" y="138" font-size="13" font-weight="800" fill="#29213D">1/4</text>
      <text x="36" y="108" font-size="16" font-weight="800" fill="#FFD166">1/2</text>
    </svg>`;
  }

  renderExplore(state) {
    this.renderShelf(this.el.exploreShelf, state.inventory);
    this.renderBar(state.placed.filter((p) => p.zone === "bar"));
    this.renderPizza(state.placed.filter((p) => p.zone === "pizza"));
    this.el.exploreGoals.innerHTML = EXPLORE_GOALS.map((g) => {
      const ok = state.exploreGoals.includes(g.id);
      return `<div class="pill ${ok ? "ok" : ""}">${ok ? "✓ " : ""}${g.title}</div>`;
    }).join("");
    this.el.exploreContinue.disabled = !EXPLORE_GOALS.every((goal) => state.exploreGoals.includes(goal.id));
  }

  speakExplore(text, mood = "neutral") {
    this.el.exploreSpeech.textContent = text;
    this.setNova("nova-explore", mood);
  }

  renderBar(pieces) {
    const html = pieces.map((p) => {
      const w = toNumber(p) * 100;
      return `<div class="bar-seg piece-on-board" data-id="${p.id}" style="width:${w}%;background:${this.color(p)};cursor:grab;">${labelOf(p)}</div>`;
    }).join("");
    this.el.barTrack.innerHTML = html || "";
    this.el.barTrack.querySelectorAll(".piece-on-board").forEach((el) => this.bindPiece(el));
  }

  renderPizza(pieces) {
    let offset = 0;
    const slices = pieces.map((p) => {
      const deg = Math.max(0, Math.min(360, toNumber(p) * 360));
      const start = offset;
      offset += deg;
      const end = start + deg;
      const large = deg > 180 ? 1 : 0;
      const point = (angle) => {
        const radians = (angle - 90) * Math.PI / 180;
        return `${110 + 110 * Math.cos(radians)} ${110 + 110 * Math.sin(radians)}`;
      };
      const path = deg >= 359.999
        ? `<circle cx="110" cy="110" r="110"/>`
        : `<path d="M 110 110 L ${point(start)} A 110 110 0 ${large} 1 ${point(end)} Z"/>`;
      const mid = start + deg / 2;
      const labelRadians = (mid - 90) * Math.PI / 180;
      const labelX = 110 + 67 * Math.cos(labelRadians);
      const labelY = 116 + 67 * Math.sin(labelRadians);
      return `<svg class="pizza-slice piece-on-board" data-id="${p.id}" viewBox="0 0 220 220" aria-label="${labelOf(p)} slice" style="cursor:grab;">
        <g fill="${this.color(p)}" stroke="#4C3970" stroke-width="2">${path}</g>
        <text x="${labelX}" y="${labelY}" text-anchor="middle" fill="#29213D" font-size="16" font-weight="800" pointer-events="none">${labelOf(p)}</text>
      </svg>`;
    }).join("");
    this.el.pizzaDrop.innerHTML = slices;
    this.el.pizzaDrop.querySelectorAll(".piece-on-board").forEach((el) => this.bindPiece(el));
  }

  renderWorkbench(ctx) {
    const { mode, level, state, section } = ctx;
    const kickers = {
      PRACTICE: "Stage 3 · Guided Mini Challenges",
      GAME: "Stage 4 · Fraction Forge",
      CHALLENGE: "Stage 5 · Final Challenge",
      TIME_ATTACK: "Revision · Time Attack"
    };
    this.el.wbKicker.textContent = kickers[mode] || "";
    this.el.wbTitle.textContent = level.title || section?.title || "Build";
    this.el.wbCheck.classList.remove("hidden");
    this.el.wbNext.classList.add("hidden");
    this.el.missing.classList.add("hidden");
    this.el.bridgeSlot.classList.remove("bad");

    // Reset success stamp and zoom
    const stamp = document.getElementById("success-stamp");
    if (stamp) {
      stamp.classList.remove("stamp-active");
      stamp.classList.add("hidden");
    }
    const canyon = document.getElementById("canyon");
    if (canyon) {
      canyon.classList.remove("zoom");
    }

    const isRatio = (section || level).type === "ratio";
    const isSimp = (section || level).type === "simplified";
    this.el.ratioZone.classList.toggle("hidden", !isRatio);
    document.getElementById("bridge-frame").classList.toggle("hidden", isRatio);

    if (isRatio) {
      const t = (section || level).targetRatio;
      this.el.wbDesc.textContent = `Match the ratio ${t.red} red : ${t.blue} blue.`;
      this.el.wbTarget.textContent = `Ratio ${t.red}:${t.blue}`;
      this.el.ratioLabel.textContent = `${t.red} : ${t.blue}`;
      this.renderRatio(state);
    } else {
      const target = (section || level).target;
      this.el.wbDesc.textContent = isSimp
        ? "Place one simplified 1/2 plank. Merge, then simplify — a 2/4 will not lock."
        : `Fill exactly ${labelOf(target)} of the span.`;
      this.el.wbTarget.textContent = `Target ${labelOf(target)}`;
      this.el.targetGhost.style.width = `${toNumber(target) * 100}%`;
      this.renderBridge(state.placed);
    }

    if (mode === "CHALLENGE") {
      this.el.challengeTabs.classList.remove("hidden");
      this.el.challengeTabs.innerHTML = ctx.sections.map((s) => {
        const on = s.id === ctx.section.id ? "on" : "";
        const ok = state.challengeDone[s.id] ? "ok" : "";
        return `<button class="${on} ${ok}" data-sec="${s.id}">${s.title.split("·")[0].trim()}</button>`;
      }).join("");
      this.el.challengeTabs.querySelectorAll("button").forEach((b) => {
        b.addEventListener("click", () => this.cb.onChallengeTab(b.getAttribute("data-sec")));
      });
      this.el.wbHint.classList.add("hidden");
    } else {
      this.el.challengeTabs.classList.add("hidden");
    }

    this.renderShelf(this.el.wbShelf, state.inventory);
    this.updateHud(state);
  }

  renderBridge(placed) {
    this.el.bridgeSlot.innerHTML = placed.map((p) => {
      const w = toNumber(p) * 100;
      return `<div class="bar-seg piece-on-board" data-id="${p.id}" style="width:${w}%;background:${this.color(p)};cursor:grab;">${labelOf(p)}</div>`;
    }).join("");
    this.el.bridgeSlot.querySelectorAll(".piece-on-board").forEach((el) => this.bindPiece(el));
  }

  renderRatio(state) {
    this.el.ratioRed.innerHTML = state.ratioRed.map(() => `<div class="ratio-block" style="background:#FF8B94"></div>`).join("");
    this.el.ratioBlue.innerHTML = state.ratioBlue.map(() => `<div class="ratio-block" style="background:#118AB2"></div>`).join("");
  }

  speakWb(text, mood = "neutral") {
    this.el.wbSpeech.textContent = text;
    this.setNova("nova-wb", mood);
  }

  showHint(text) {
    if (!text) {
      this.el.wbHint.classList.add("hidden");
      return;
    }
    this.el.wbHint.classList.remove("hidden");
    this.el.wbHint.textContent = text;
  }

  showMissing(under) {
    this.el.missing.classList.toggle("hidden", !under);
    this.el.bridgeSlot.classList.add("bad");
    setTimeout(() => this.el.bridgeSlot.classList.remove("bad"), 450);
  }

  showSuccessReady() {
    this.el.wbCheck.classList.add("hidden");
    this.el.wbNext.classList.remove("hidden");
    const stamp = document.getElementById("success-stamp");
    if (stamp) {
      stamp.classList.remove("hidden");
      setTimeout(() => stamp.classList.add("stamp-active"), 50);
    }
    const canyon = document.getElementById("canyon");
    if (canyon) {
      canyon.classList.add("zoom");
    }
  }

  renderShelf(node, inventory) {
    node.innerHTML = inventory.map((p) => this.pieceHtml(p)).join("");
    node.querySelectorAll(".piece").forEach((el) => this.bindPiece(el));
  }

  pieceHtml(p) {
    const isBuffer = this.cb.getMergeBuffer?.() === p.id;
    const label = p.kind === "frac" ? labelOf(p) : p.kind === "ratio-red" ? "Red" : "Blue";
    const w = p.kind === "frac" ? Math.max(56, toNumber(p) * 180) : 70;
    const glowClass = isBuffer ? "merge-buffered" : "";
    return `<div class="piece ${glowClass}" draggable="false" data-id="${p.id}" style="width:${w}px;background:${this.color(p)}">${label}</div>`;
  }

  color(p) {
    if (p.kind === "ratio-red") return PIECE_COLORS["ratio-red"];
    if (p.kind === "ratio-blue") return PIECE_COLORS["ratio-blue"];
    return PIECE_COLORS[labelOf(p)] || "#C7B9E5";
  }

  bindPiece(el) {
    el.addEventListener("mousedown", (e) => this.startDrag(e, el));
    el.addEventListener("touchstart", (e) => this.startDrag(e, el), { passive: false });
  }

  startDrag(e, el) {
    if (this.drag || (e.type === "mousedown" && e.button !== 0)) return;
    const id = el.getAttribute("data-id");
    const now = performance.now();
    if (this.lastPiecePress?.id === id && now - this.lastPiecePress.at < 500) {
      this.lastPiecePress = null;
      e.preventDefault();
      this.cb.onDouble(id);
      return;
    }
    this.lastPiecePress = { id, at: now };
    e.preventDefault();
    this.drag = { id, el };
    el.classList.add("dragging");
    this.ghost = document.createElement("div");
    this.ghost.className = "drag-ghost";
    this.ghost.style.width = `${el.getBoundingClientRect().width}px`;
    this.ghost.style.background = el.style.background;
    this.ghost.textContent = el.textContent;
    document.getElementById("drag-layer").appendChild(this.ghost);
    this.placeGhost(e);
    this.cb.onPickup();
  }

  eventPoint(e) {
    const t = e.changedTouches ? e.changedTouches[0] : e.touches ? e.touches[0] : e;
    return { x: t.clientX, y: t.clientY };
  }

  placeGhost(e) {
    if (!this.ghost) return;
    const p = this.eventPoint(e);
    this.ghost.style.left = `${p.x - 30}px`;
    this.ghost.style.top = `${p.y - 24}px`;
  }

  dropTargets() {
    return [...document.querySelectorAll("[data-drop]")].filter((n) => n.offsetParent !== null || n.getClientRects().length);
  }

  onMove(e) {
    if (!this.drag) return;
    e.preventDefault();
    this.placeGhost(e);
    const p = this.eventPoint(e);
    let found = null;
    this.dropTargets().forEach((n) => {
      const r = n.getBoundingClientRect();
      const hit = p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;
      n.classList.toggle("hot", hit);
      if (hit) found = n.getAttribute("data-drop");
    });
    this.hot = found;
  }

  onUp(e) {
    if (!this.drag) return;
    const id = this.drag.id;
    let dest = this.hot;
    if (e) {
      const p = this.eventPoint(e);
      const target = this.dropTargets().find((node) => {
        const r = node.getBoundingClientRect();
        return p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;
      });
      dest = target?.getAttribute("data-drop") || dest;
    }
    this.drag.el.classList.remove("dragging");
    this.ghost?.remove();
    this.ghost = null;
    this.drag = null;
    this.dropTargets().forEach((n) => n.classList.remove("hot"));
    this.hot = null;
    if (dest) this.cb.onDrop(id, dest);
  }

  renderResults(state) {
    this.el.resScore.textContent = state.score;
    this.el.resXp.textContent = state.xp;
    this.el.resCoins.textContent = state.coins;
    this.el.resMistakes.textContent = state.mistakes;
    this.el.resultStars.innerHTML = [0, 1, 2].map((i) => {
      const on = i < state.stars;
      return `<svg width="54" height="54" viewBox="0 0 24 24"><path fill="${on ? "#FFD166" : "#3a3350"}" d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>`;
    }).join("");
  }

  renderMistakes(history) {
    if (!history.length) {
      this.el.revBody.innerHTML = `<p>No misses recorded. Beautiful work — try Time Attack to stay sharp.</p>`;
      return;
    }
    this.el.revBody.innerHTML = history.slice().reverse().map((m) => `
      <div class="mistake-card">
        <strong>${m.title || "Span"}</strong> needed <span style="color:#FFD166">${m.target || "?"}</span>
        <div>You placed: ${m.placed || "nothing"}</div>
        <div class="vis-row">
          <div style="width:${m.targetPct || 50}%;background:rgba(255,209,102,.4)"></div>
        </div>
        <div class="vis-row">
          <div style="width:${m.placedPct || 20}%;background:#FF8B94"></div>
        </div>
        <p>${m.why || ""}</p>
      </div>
    `).join("");
  }

  renderTimeAttack(score, best, seconds) {
    if (this.el.wbTitle) {
      this.el.wbTitle.textContent = `Time Attack · ${seconds}s left`;
      this.el.wbDesc.textContent = `Exact spans this run: ${score} · Best: ${best}`;
    }
    this.el.revBody.innerHTML = `<p>Time left: <strong>${seconds}s</strong> · This run: ${score} · Best: ${best}</p>`;
  }

  floatReward(xp, coins) {
    const n = document.createElement("div");
    n.className = "float-xp";
    n.textContent = `+${xp} XP  +${coins} coins`;
    n.style.left = "70%";
    n.style.top = "80px";
    document.body.appendChild(n);
    setTimeout(() => n.remove(), 1100);
  }

  burst(x, y) {
    this.cb.burst?.(x, y);
  }
}
