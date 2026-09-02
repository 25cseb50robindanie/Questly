/**
 * QUESTLY VIRTUAL LAB - MOBILE 5-LEVEL GAME CONTROLLER
 */

let currentLevel = 1;
let unlockedLevel = 1;
let conceptSlide = 0; // 0..3
let isQuizCorrect = false;

// Apparatus
const assembledApparatus = new Set();

// Reagents
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

// Text to Speech
function speakFoxyText() {
  const text = document.getElementById('foxySpeech').innerText;
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel();
    const utter = new SpeechSynthesisUtterance(text.replace(/"/g, ''));
    utter.rate = 1.0;
    utter.pitch = 1.1;
    window.speechSynthesis.speak(utter);
  }
}

function setFoxySpeech(text) {
  document.getElementById('foxySpeech').innerText = text;
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

  // Update Stepper Pills
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

  // Update Header
  document.getElementById('headerSubtitle').innerText = `LEVEL ${currentLevel} OF 5 • ACID–BASE TITRATION`;

  // Show Active Level Section
  for (let i = 1; i <= 5; i++) {
    const card = document.getElementById(`level${i}Card`);
    if (card) card.classList.toggle('active', i === currentLevel);
  }

  // Teacher Message
  switch (currentLevel) {
    case 2:
      setFoxySpeech('"Level 2: Tap each apparatus card to assemble all 4 essential pieces onto your lab table!"');
      break;
    case 3:
      setFoxySpeech('"Level 3: Pipette 20.0 mL of HCl acid into the flask, then add 3 drops of indicator!"');
      break;
    case 4:
      setFoxySpeech('"Level 4: Add drops slowly and swirl. Stop right when a faint persistent pink endpoint appears!"');
      renderCanvas();
      break;
    case 5:
      setFoxySpeech('"Level 5: Excellent laboratory work! Review your stoichiometry analysis and claim your 3-star trophy!"');
      break;
  }
}

// ---------------------------------------------------------------------------
// LEVEL 2: APPARATUS
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

  document.getElementById('apparatusCount').innerText = `${assembledApparatus.size} / 4 Placed`;
  const btn = document.getElementById('btnFinishLevel2');

  if (assembledApparatus.size === 4) {
    sound.playSuccess();
    btn.classList.remove('disabled');
    btn.innerText = 'START REAGENTS PREPARATION ➜';
  } else {
    btn.classList.add('disabled');
    btn.innerText = 'Assemble all 4 items to proceed';
  }
}

function finishLevel2() {
  if (assembledApparatus.size === 4) {
    sound.playSuccess();
    goToLevel(3);
  }
}

// ---------------------------------------------------------------------------
// LEVEL 3: REAGENTS
// ---------------------------------------------------------------------------
function pipetteAcid() {
  sound.playPop();
  acidPipetted = true;
  const box = document.getElementById('acidBox');
  box.classList.add('done');
  document.getElementById('btnPipetteAcid').innerText = '✓ Pipetted 20 mL';
  document.getElementById('btnPipetteAcid').classList.add('btn-green-solid');
  checkReagentsLevel();
}

function addIndicator() {
  sound.playPop();
  indicatorAdded = true;
  const box = document.getElementById('indicatorBox');
  box.classList.add('done');
  document.getElementById('btnAddIndicator').innerText = '✓ 3 Drops Added';
  document.getElementById('btnAddIndicator').classList.add('btn-green-solid');
  checkReagentsLevel();
}

function checkReagentsLevel() {
  const count = (acidPipetted ? 1 : 0) + (indicatorAdded ? 1 : 0);
  document.getElementById('reagentsCount').innerText = `${count} / 2 Steps`;

  const btn = document.getElementById('btnFinishLevel3');
  if (acidPipetted && indicatorAdded) {
    sound.playSuccess();
    btn.classList.remove('disabled');
    btn.innerText = 'START TITRATION SIMULATOR ➜';
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
    alert(`Keep going! Volume is ${buretteVolume.toFixed(2)} mL (Target: 20.00 mL). Add drops until pink color persists!`);
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

// Canvas Painter
function renderCanvas() {
  const canvas = document.getElementById('titrationCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;
  ctx.clearRect(0, 0, w, h);

  const cx = w * 0.55;
  const standX = w * 0.22;

  // Retort Stand
  ctx.fillStyle = '#1E293B';
  ctx.fillRect(standX - 25, h * 0.92, 50, 8);
  ctx.strokeStyle = '#334155';
  ctx.lineWidth = 3.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.92);
  ctx.lineTo(standX, h * 0.06);
  ctx.stroke();

  // Clamp
  ctx.lineWidth = 2.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.25);
  ctx.lineTo(cx, h * 0.25);
  ctx.stroke();

  // Burette Tube
  const bTop = h * 0.08;
  const bBottom = h * 0.54;
  const bWidth = 11;

  // Liquid
  const frac = Math.max(0, Math.min(1, 1 - (buretteVolume / 50.0)));
  const liqTop = bTop + (bBottom - bTop) * (1 - frac);
  ctx.fillStyle = 'rgba(186, 230, 253, 0.5)';
  ctx.fillRect(cx - bWidth / 2 + 1, liqTop, bWidth - 2, bBottom - liqTop);

  // Outline
  ctx.strokeStyle = '#475569';
  ctx.lineWidth = 1.2;
  ctx.strokeRect(cx - bWidth / 2, bTop, bWidth, bBottom - bTop);

  // Stopcock
  const valveY = bBottom + 6;
  ctx.fillStyle = '#EF4444';
  ctx.beginPath();
  ctx.arc(cx, valveY, 3, 0, Math.PI * 2);
  ctx.fill();

  // Tip
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

  // Liquid Color calculation
  const ph = calculatePH();
  let liqColor = 'rgba(186, 230, 253, 0.35)';
  if (ph >= 8.2 && ph <= 9.0) {
    liqColor = 'rgba(244, 114, 182, 0.65)'; // Pale pink
  } else if (ph > 9.0) {
    liqColor = 'rgba(219, 39, 119, 0.85)'; // Dark magenta
  }

  // Fill Flask Liquid
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

  // Flask outline
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
// LEVEL 5: REPORT
// ---------------------------------------------------------------------------
function claimLabTrophy() {
  sound.playSuccess();
  alert('🏆 CONGRATULATIONS!\nYou completed all 5 Virtual Lab levels and earned +60 XP & +15 Coins!');
}

function handleGoBack() {
  if (confirm('Return to previous screen?')) {
    window.history.back();
  }
}

// Init
window.addEventListener('DOMContentLoaded', () => {
  updateSlideView();
  renderCanvas();
});