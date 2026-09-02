/**
 * QUESTLY VIRTUAL LAB - MOBILE 5-LEVEL GAME CONTROLLER WITH EXPERIMENT SELECTOR
 */

let selectedExperiment = 'titration';
let currentLevel = 1;
let unlockedLevel = 1;
let conceptSlide = 0; // 0..3
let isQuizCorrect = false;

// Apparatus Set (6 items)
const assembledApparatus = new Set();

// Reagents
let selectedAcid = null;
let selectedIndicator = null;
let acidPipetted = false;
let indicatorAdded = false;

// Titration Simulation
let buretteVolume = 0.0;
const targetEndpoint = 20.00;
let isContinuous = false;
let continuousInterval = null;
let isSwirling = false;
let dripProgress = 0;
let dripAnim = null;

// Sound Synthesizer
class SimpleSound {
  constructor() {
    this.ctx = null;
  }
  _init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) this.ctx = new AudioCtx();
    }
    if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
  }
  playClick() {
    this._init();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(520, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(260, this.ctx.currentTime + 0.04);
    gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.001, this.ctx.currentTime + 0.04);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.04);
  }
  playPop() {
    this._init();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(950, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(350, this.ctx.currentTime + 0.06);
    gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.001, this.ctx.currentTime + 0.06);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.06);
  }
  playSuccess() {
    this._init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [523.25, 659.25, 783.99].forEach((f, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(f, now + i * 0.07);
      gain.gain.setValueAtTime(0.06, now + i * 0.07);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.07 + 0.2);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + i * 0.07);
      osc.stop(now + i * 0.07 + 0.2);
    });
  }
}
const sound = new SimpleSound();

function speakText(text) {
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel();
    const utter = new SpeechSynthesisUtterance(text.replace(/"/g, ''));
    utter.rate = 1.0;
    utter.pitch = 1.1;
    window.speechSynthesis.speak(utter);
  }
}

function speakFoxyText() {
  const text = document.getElementById('foxySpeech').innerText;
  speakText(text);
}

function setFoxySpeech(text) {
  document.getElementById('foxySpeech').innerText = text;
}

// ---------------------------------------------------------------------------
// 0. EXPERIMENT SELECTION FLOW
// ---------------------------------------------------------------------------
function startExperiment(expId) {
  sound.playClick();
  selectedExperiment = expId;
  document.getElementById('screenExpSelect').classList.remove('active');
  document.getElementById('screenActiveLab').classList.add('active');

  currentLevel = 1;
  unlockedLevel = 1;
  conceptSlide = 0;
  isQuizCorrect = false;
  assembledApparatus.clear();
  selectedAcid = null;
  selectedIndicator = null;
  acidPipetted = false;
  indicatorAdded = false;
  buretteVolume = 0.0;
  isContinuous = false;

  updateSlideView();
  goToLevel(1);
}

function exitToExperimentSelect() {
  sound.playClick();
  if (isContinuous) toggleContinuous();
  document.getElementById('screenActiveLab').classList.remove('active');
  document.getElementById('screenExpSelect').classList.add('active');
}

// ---------------------------------------------------------------------------
// LEVEL 1: CONCEPT SLIDES
// ---------------------------------------------------------------------------
function updateSlideView() {
  for (let i = 0; i <= 3; i++) {
    const el = document.getElementById(`cSlide${i}`);
    if (el) el.classList.toggle('active', i === conceptSlide);
  }

  document.getElementById('slideCounter').innerText = `Lesson ${conceptSlide + 1} of 4`;
  document.getElementById('btnPrevSlide').style.visibility = conceptSlide > 0 ? 'visible' : 'hidden';

  const btnNext = document.getElementById('btnNextSlide');
  if (conceptSlide < 3) {
    btnNext.innerText = 'Next Concept ➜';
    btnNext.className = 'btn-primary';
  } else {
    btnNext.innerText = isQuizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option';
    btnNext.className = isQuizCorrect ? 'btn-primary btn-green-solid' : 'btn-primary disabled';
  }

  const messages = [
    '"Step 1/4: In an acid-base titration, hydrochloric acid reacts with sodium hydroxide to form water and salt!"',
    '"Step 2/4: We use a standard 0.100 M NaOH titrant to find the concentration of our 20.0 mL HCl analyte acid."',
    '"Step 3/4: Phenolphthalein indicator stays clear in acid and turns pale pink the exact moment neutralization happens!"',
    '"Step 4/4: Checkpoint quiz! Answer correctly to unlock and enter the lab apparatus workbench!"'
  ];
  setFoxySpeech(messages[conceptSlide]);
}

function nextConceptSlide() {
  sound.playClick();
  if (conceptSlide < 3) {
    conceptSlide++;
    updateSlideView();
  } else if (isQuizCorrect) {
    sound.playSuccess();
    goToLevel(2);
  }
}

function prevConceptSlide() {
  sound.playClick();
  if (conceptSlide > 0) {
    conceptSlide--;
    updateSlideView();
  }
}

function selectQuizOption(idx) {
  sound.playClick();
  const options = document.querySelectorAll('.quiz-option-btn');
  options.forEach((btn, i) => {
    btn.classList.remove('correct', 'wrong');
    if (i === idx) {
      if (idx === 0) {
        btn.classList.add('correct');
        isQuizCorrect = true;
        sound.playSuccess();
        setFoxySpeech('"Correct! Phenolphthalein turns pale pink at the exact endpoint. Tap the button to enter the lab!"');
      } else {
        btn.classList.add('wrong');
        isQuizCorrect = false;
        sound.playPop();
      }
    }
  });

  const btnNext = document.getElementById('btnNextSlide');
  if (conceptSlide === 3) {
    btnNext.innerText = isQuizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option';
    btnNext.className = isQuizCorrect ? 'btn-primary btn-green-solid' : 'btn-primary disabled';
  }
}

// ---------------------------------------------------------------------------
// LEVEL NAVIGATION
// ---------------------------------------------------------------------------
function goToLevel(lvl) {
  if (lvl > unlockedLevel + 1) return;
  currentLevel = lvl;
  if (lvl > unlockedLevel) unlockedLevel = lvl;

  // Stepper Pills
  for (let i = 1; i <= 5; i++) {
    const pill = document.getElementById(`pill${i}`);
    pill.classList.remove('active', 'passed', 'locked');
    if (i === currentLevel) {
      pill.classList.add('active');
      pill.innerText = `Level ${i}`;
    } else if (i < currentLevel || i < unlockedLevel) {
      pill.classList.add('passed');
      pill.innerText = `✓ Level ${i}`;
    } else {
      pill.classList.add('locked');
      pill.innerText = `🔒 Level ${i}`;
    }
  }

  document.getElementById('headerSubtitle').innerText = `LEVEL ${currentLevel} OF 5 • ACID–BASE TITRATION`;

  for (let i = 1; i <= 5; i++) {
    const card = document.getElementById(`level${i}Card`);
    if (card) card.classList.toggle('active', i === currentLevel);
  }

  switch (currentLevel) {
    case 2:
      setFoxySpeech('"Level 2: Select the 4 required glassware apparatus for titration from the 6 lab tools below!"');
      break;
    case 3:
      setFoxySpeech('"Level 3: Select and pipette 20.0 mL of 0.1M HCl into the flask, then add 3 drops of Phenolphthalein!"');
      break;
    case 4:
      setFoxySpeech('"Level 4: Turn the stopcock to add drops of NaOH. Swirl regularly. Stop right when a faint persistent pink endpoint appears!"');
      renderCanvas();
      break;
    case 5:
      setFoxySpeech('"Level 5: Excellent laboratory work! Review your stoichiometry analysis and claim your 3-star trophy!"');
      break;
  }
}

// ---------------------------------------------------------------------------
// LEVEL 2: 6 APPARATUS (4 REQUIRED)
// ---------------------------------------------------------------------------
function toggleApparatus(id) {
  sound.playPop();
  const card = document.getElementById(`app_${id}`);
  const mark = card.querySelector('.check-mark');

  if (assembledApparatus.has(id)) {
    assembledApparatus.delete(id);
    card.classList.remove('placed');
    mark.innerText = '⭕';
  } else {
    assembledApparatus.add(id);
    card.classList.add('placed');
    mark.innerText = '✅';
  }

  document.getElementById('apparatusCount').innerText = `${assembledApparatus.size} Selected`;
  const btn = document.getElementById('btnFinishLevel2');

  const required = ['stand', 'burette', 'flask', 'pipette'];
  const allRequired = required.every(r => assembledApparatus.has(r));

  if (allRequired) {
    sound.playSuccess();
    btn.classList.remove('disabled');
    btn.innerText = 'START REAGENTS PREPARATION ➜';
  } else {
    btn.classList.add('disabled');
    btn.innerText = 'Select Stand, Burette, Flask & Pipette';
  }
}

function finishLevel2() {
  const required = ['stand', 'burette', 'flask', 'pipette'];
  if (required.every(r => assembledApparatus.has(r))) {
    sound.playSuccess();
    goToLevel(3);
  }
}

// ---------------------------------------------------------------------------
// LEVEL 3: 6 REAGENTS BOTTLES (HCl + PHENOLPHTHALEIN REQUIRED)
// ---------------------------------------------------------------------------
function selectReagent(id, type) {
  sound.playPop();

  if (type === 'acid') {
    selectedAcid = id;
    acidPipetted = (id === 'hcl');
  } else if (type === 'indicator') {
    selectedIndicator = id;
    indicatorAdded = (id === 'phenolphthalein');
  }

  // Update checkmarks on bottles
  const reagents = ['hcl', 'phenolphthalein', 'naoh', 'ch3cooh', 'methyl_orange', 'h2o'];
  reagents.forEach(r => {
    const card = document.getElementById(`bot_${r}`);
    const chk = document.getElementById(`chk_${r}`);
    if (r === selectedAcid || r === selectedIndicator) {
      card.classList.add('selected');
      chk.innerText = '✅';
    } else {
      card.classList.remove('selected');
      chk.innerText = '⭕';
    }
  });

  const btn = document.getElementById('btnFinishLevel3');
  const counter = document.getElementById('reagentsCount');

  if (acidPipetted && indicatorAdded) {
    sound.playSuccess();
    counter.innerText = '✓ Ready';
    counter.style.color = '#06D6A0';
    btn.classList.remove('disabled');
    btn.innerText = 'START TITRATION SIMULATOR ➜';
  } else {
    counter.innerText = 'Select Acid & Indicator';
    counter.style.color = '#FF6B6B';
    btn.classList.add('disabled');
    btn.innerText = 'Select 0.1M HCl and Phenolphthalein';
  }
}

function finishLevel3() {
  if (acidPipetted && indicatorAdded) {
    sound.playSuccess();
    goToLevel(4);
  }
}

// ---------------------------------------------------------------------------
// LEVEL 4: TITRATION SIMULATOR & CANVAS
// ---------------------------------------------------------------------------
function calculatePH() {
  const molesAcid = 0.002;
  const molesBase = (buretteVolume / 1000.0) * 0.1;
  const totalVol = (20.0 + buretteVolume) / 1000.0;

  if (molesAcid > molesBase) {
    const excess = molesAcid - molesBase;
    const conc = excess / totalVol;
    return Math.min(6.9, Math.max(1.0, -Math.log10(conc)));
  } else if (Math.abs(molesAcid - molesBase) < 0.00001) {
    return 7.0;
  } else {
    const excess = molesBase - molesAcid;
    const conc = excess / totalVol;
    return Math.min(13.5, Math.max(7.1, 14.0 - (-Math.log10(conc))));
  }
}

function addDrop(amt) {
  if (buretteVolume >= 50.0) return;
  sound.playPop();
  buretteVolume = Math.min(50.0, buretteVolume + amt);

  dripProgress = 0.1;
  if (dripAnim) cancelAnimationFrame(dripAnim);
  animateDrip();

  updateHud();
  renderCanvas();
}

function animateDrip() {
  dripProgress += 0.15;
  renderCanvas();
  if (dripProgress < 1.0) {
    dripAnim = requestAnimationFrame(animateDrip);
  } else {
    dripProgress = 0;
  }
}

function toggleContinuous() {
  sound.playClick();
  isContinuous = !isContinuous;
  const btn = document.getElementById('btnContinuous');

  if (isContinuous) {
    btn.innerText = '⏸ Pause';
    btn.style.background = '#FF6B6B';
    continuousInterval = setInterval(() => {
      if (buretteVolume >= 50.0) {
        toggleContinuous();
        return;
      }
      addDrop(0.15);
    }, 180);
  } else {
    btn.innerText = '▶ Continuous';
    btn.style.background = '#293B49';
    if (continuousInterval) clearInterval(continuousInterval);
  }
}

function triggerSwirl() {
  sound.playPop();
  isSwirling = true;
  renderCanvas();
  setTimeout(() => {
    isSwirling = false;
    renderCanvas();
  }, 600);
}

function verifyEndpoint() {
  if (isContinuous) toggleContinuous();
  const diff = Math.abs(buretteVolume - targetEndpoint);

  if (diff <= 0.35) {
    sound.playSuccess();
    goToLevel(5);
  } else if (buretteVolume < targetEndpoint) {
    sound.playPop();
    alert(`Keep going! Volume is ${buretteVolume.toFixed(2)} mL (Target: 20.00 mL). Add drops until faint pink color persists!`);
  } else {
    sound.playPop();
    alert(`Over-titrated (${buretteVolume.toFixed(2)} mL). Dark pink indicates excess base. Let's see calculations in the report!`);
    goToLevel(5);
  }
}

function updateHud() {
  document.getElementById('hudVol').innerText = `${buretteVolume.toFixed(2)} mL`;
  document.getElementById('hudPH').innerText = calculatePH().toFixed(2);
}

function renderCanvas() {
  const canvas = document.getElementById('titrationCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;
  ctx.clearRect(0, 0, w, h);

  const cx = w * 0.55;
  const standX = w * 0.22;

  // Stand Base & Rod
  ctx.fillStyle = '#1E293B';
  ctx.fillRect(standX - 25, h * 0.92, 50, 8);
  ctx.strokeStyle = '#334155';
  ctx.lineWidth = 3.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.92);
  ctx.lineTo(standX, h * 0.06);
  ctx.stroke();

  // Stand Clamp
  ctx.lineWidth = 2.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.25);
  ctx.lineTo(cx, h * 0.25);
  ctx.stroke();

  // Glass Burette
  const bTop = h * 0.08;
  const bBottom = h * 0.54;
  const bWidth = 11;

  const frac = Math.max(0, Math.min(1, 1 - (buretteVolume / 50.0)));
  const liqTop = bTop + (bBottom - bTop) * (1 - frac);
  ctx.fillStyle = 'rgba(186, 230, 253, 0.5)';
  ctx.fillRect(cx - bWidth / 2 + 1, liqTop, bWidth - 2, bBottom - liqTop);

  ctx.strokeStyle = '#475569';
  ctx.lineWidth = 1.2;
  ctx.strokeRect(cx - bWidth / 2, bTop, bWidth, bBottom - bTop);

  // Red Stopcock Valve
  const valveY = bBottom + 6;
  ctx.fillStyle = '#EF4444';
  ctx.beginPath();
  ctx.arc(cx, valveY, 3, 0, Math.PI * 2);
  ctx.fill();

  ctx.beginPath();
  ctx.moveTo(cx, valveY);
  ctx.lineTo(cx, valveY + 10);
  ctx.stroke();

  // Droplet
  if (dripProgress > 0 && dripProgress < 1) {
    const dropY = (valveY + 10) + (h * 0.74 - (valveY + 10)) * dripProgress;
    ctx.fillStyle = '#38BDF8';
    ctx.beginPath();
    ctx.arc(cx, dropY, 2.5, 0, Math.PI * 2);
    ctx.fill();
  }

  // Conical Flask
  const fTop = h * 0.66;
  const fBottom = h * 0.92;
  ctx.beginPath();
  ctx.moveTo(cx - 7, fTop);
  ctx.lineTo(cx + 7, fTop);
  ctx.lineTo(cx + 7, fTop + 8);
  ctx.lineTo(cx + 26, fBottom);
  ctx.lineTo(cx - 26, fBottom);
  ctx.lineTo(cx - 7, fTop + 8);
  ctx.closePath();

  const ph = calculatePH();
  let liqColor = 'rgba(186, 230, 253, 0.35)';
  if (ph >= 8.2 && ph <= 9.0) {
    liqColor = 'rgba(244, 114, 182, 0.65)';
  } else if (ph > 9.0) {
    liqColor = 'rgba(219, 39, 119, 0.85)';
  }

  const liqY = fBottom - 18;
  ctx.fillStyle = liqColor;
  ctx.beginPath();
  ctx.moveTo(cx - 16, liqY);
  if (isSwirling) {
    ctx.quadraticCurveTo(cx, liqY + 3, cx + 16, liqY);
  } else {
    ctx.lineTo(cx + 16, liqY);
  }
  ctx.lineTo(cx + 25, fBottom - 1);
  ctx.lineTo(cx - 25, fBottom - 1);
  ctx.closePath();
  ctx.fill();

  ctx.strokeStyle = '#334155';
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(cx - 7, fTop);
  ctx.lineTo(cx + 7, fTop);
  ctx.lineTo(cx + 7, fTop + 8);
  ctx.lineTo(cx + 26, fBottom);
  ctx.lineTo(cx - 26, fBottom);
  ctx.lineTo(cx - 7, fTop + 8);
  ctx.closePath();
  ctx.stroke();
}

// ---------------------------------------------------------------------------
// LEVEL 5: REPORT & FINISH
// ---------------------------------------------------------------------------
function claimLabTrophy() {
  sound.playSuccess();
  alert('🏆 CONGRATULATIONS!\nYou completed all 5 Virtual Lab levels and earned +60 XP & +15 Coins!');
  exitToExperimentSelect();
}

window.addEventListener('DOMContentLoaded', () => {
  // Ready
});