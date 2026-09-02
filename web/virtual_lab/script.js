/**
 * QUESTLY VIRTUAL LAB - COMPLETE MULTI-EXPERIMENT ENGINE
 */

let selectedExperiment = 'titration'; // titration | flameTest | calorimetry | smelting
let currentLevel = 1;
let unlockedLevel = 1;
let conceptSlide = 0;
let isQuizCorrect = false;

// Apparatus
const assembledApparatus = new Set();

// Reagents
let selectedReagent1 = null;
let selectedReagent2 = null;
let reagentStep1Done = false;
let reagentStep2Done = false;

// Titration Simulation
let buretteVolume = 0.0;
const targetEndpoint = 20.00;
let isContinuous = false;
let continuousInterval = null;
let isSwirling = false;
let dripProgress = 0;
let dripAnim = null;

// Flame Simulation
let selectedFlameSalt = 'licl';

// Calorimetry Simulation
let waterTemp = 22.0;
let soluteAdded = false;

// Smelting Simulation
let chargeLoaded = false;
let blastOn = false;
let furnaceTemp = 250;

// Pending Action for Modal
let nextActionAfterHurrah = null;

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
  selectedReagent1 = null;
  selectedReagent2 = null;
  reagentStep1Done = false;
  reagentStep2Done = false;
  buretteVolume = 0.0;
  isContinuous = false;
  selectedFlameSalt = 'licl';
  waterTemp = 22.0;
  soluteAdded = false;
  chargeLoaded = false;
  blastOn = false;
  furnaceTemp = 250;

  renderExperimentLevel1();
  goToLevel(1);
}

function exitToExperimentSelect() {
  sound.playClick();
  if (isContinuous) toggleContinuous();
  document.getElementById('screenActiveLab').classList.remove('active');
  document.getElementById('screenExpSelect').classList.add('active');
}

// ---------------------------------------------------------------------------
// HURRAH POPUP MODAL
// ---------------------------------------------------------------------------
function showHurrahModal(subTitle, desc, btnText, onNext) {
  sound.playSuccess();
  document.getElementById('hurrahSubTitle').innerText = subTitle;
  document.getElementById('hurrahDesc').innerText = desc;
  document.getElementById('btnHurrahNext').innerText = btnText;
  nextActionAfterHurrah = onNext;
  document.getElementById('hurrahModal').style.display = 'flex';
}

function closeHurrahModal() {
  document.getElementById('hurrahModal').style.display = 'none';
  if (nextActionAfterHurrah) {
    nextActionAfterHurrah();
    nextActionAfterHurrah = null;
  }
}

// ---------------------------------------------------------------------------
// LEVEL 1: CONCEPT SLIDES
// ---------------------------------------------------------------------------
function renderExperimentLevel1() {
  const fCode = document.getElementById('formulaCode');
  const fDesc = document.getElementById('formulaDesc');
  const s2c1T = document.getElementById('slide2Col1Title');
  const s2c1D = document.getElementById('slide2Col1Desc');
  const s2c2T = document.getElementById('slide2Col2Title');
  const s2c2D = document.getElementById('slide2Col2Desc');
  const s3c1T = document.getElementById('slide3Col1Title');
  const s3c1D = document.getElementById('slide3Col1Desc');
  const s3c2T = document.getElementById('slide3Col2Title');
  const s3c2D = document.getElementById('slide3Col2Desc');
  const qQ = document.getElementById('quizQuestion');
  const qList = document.getElementById('quizOptionsList');

  let opts = [];

  if (selectedExperiment === 'flameTest') {
    fCode.innerText = 'E = h • c / λ (Photon Emission Spectra)';
    fDesc.innerText = 'Thermal energy excites valence electrons in metal cations. As electrons drop back to ground state, they emit light at specific wavelengths.';
    s2c1T.innerText = 'LiCl (Lithium)';
    s2c1D.innerText = 'Crimson Red Flame (670 nm)';
    s2c2T.innerText = 'CuSO₄ (Copper)';
    s2c2D.innerText = 'Emerald Green Flame (510 nm)';
    s3c1T.innerText = 'Open Air Collar';
    s3c1D.innerText = 'Hot Blue Flame (1400°C) for testing';
    s3c2T.innerText = 'Closed Collar';
    s3c2D.innerText = 'Yellow Safety Flame (Smoky)';
    qQ.innerText = 'CHECKPOINT: Which metal cation produces a golden-yellow flame?';
    opts = ['Sodium (NaCl) - 589 nm', 'Lithium (LiCl) - 670 nm', 'Copper (CuSO₄) - 510 nm'];
  } else if (selectedExperiment === 'calorimetry') {
    fCode.innerText = 'q = m • c • ΔT (Enthalpy Equation)';
    fDesc.innerText = 'Calorimetry measures heat exchanged in an insulated vessel where m=100g water, c=4.184 J/g°C, and ΔT is temperature rise.';
    s2c1T.innerText = 'Exothermic (+q)';
    s2c1D.innerText = 'Heat released ➔ Water heats up';
    s2c2T.innerText = 'Endothermic (-q)';
    s2c2D.innerText = 'Heat absorbed ➔ Water cools down';
    s3c1T.innerText = 'Styrofoam Cup';
    s3c1D.innerText = 'Insulates against heat loss';
    s3c2T.innerText = 'Thermometer Probe';
    s3c2D.innerText = 'Digital precision ±0.1°C';
    qQ.innerText = 'CHECKPOINT: What is the specific heat capacity (c) of pure water?';
    opts = ['4.184 J/g°C', '1.000 J/g°C', '10.50 J/g°C'];
  } else if (selectedExperiment === 'smelting') {
    fCode.innerText = 'Fe₂O₃ + 3 CO ➔ 2 Fe (liquid) + 3 CO₂';
    fDesc.innerText = 'Blast furnace smelting reduces hematite ore into molten iron using carbon monoxide reducing gas at 1500°C.';
    s2c1T.innerText = 'Raw Charge';
    s2c1D.innerText = 'Hematite Ore + Coke Fuel';
    s2c2T.innerText = 'Flux Agent';
    s2c2D.innerText = 'Limestone (CaCO₃) ➔ Slag';
    s3c1T.innerText = 'Tuyere Nozzles';
    s3c1D.innerText = 'Injects 1500°C hot blast air';
    s3c2T.innerText = 'Tap Hole';
    s3c2D.innerText = 'Drains pure molten pig iron';
    qQ.innerText = 'CHECKPOINT: What reducing gas turns hematite into liquid iron?';
    opts = ['Carbon Monoxide (CO)', 'Pure Oxygen (O₂)', 'Nitrogen Gas (N₂)'];
  } else {
    // Titration
    fCode.innerText = 'HCl (aq) + NaOH (aq) ➔ NaCl (aq) + H₂O (l)';
    fDesc.innerText = 'Titration is a volumetric analysis method used in analytical chemistry to calculate the unknown concentration of an acid by reacting with standard base.';
    s2c1T.innerText = '1. Analyte Acid';
    s2c1D.innerText = 'Hydrochloric Acid (HCl)\n20.00 mL in Flask';
    s2c2T.innerText = '2. Standard Titrant';
    s2c2D.innerText = 'Sodium Hydroxide (NaOH)\n0.100 M in Burette';
    s3c1T.innerText = 'Acidic pH (< 8.2)';
    s3c1D.innerText = 'COLORLESS / CLEAR in acid';
    s3c2T.innerText = 'Endpoint (pH 8.2)';
    s3c2D.innerText = 'FAINT PERSISTENT PINK';
    qQ.innerText = 'CHECKPOINT: What is the color change of Phenolphthalein at titration endpoint?';
    opts = ['Colorless in Acid ➔ Pale Persistent Pink at Endpoint', 'Turns Dark Blue in Acid ➔ Red at Endpoint', 'Remains completely clear regardless of pH'];
  }

  qList.innerHTML = '';
  opts.forEach((opt, idx) => {
    const btn = document.createElement('button');
    btn.className = 'quiz-option-btn';
    btn.onclick = () => selectQuizOption(idx);
    btn.innerHTML = `<span class="opt-badge">${String.fromCharCode(65 + idx)}</span><span class="opt-txt">${opt}</span>`;
    qList.appendChild(btn);
  });

  updateSlideView();
}

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
    '"Step 1/4: Study the core chemical reaction principles and formula equations above!"',
    '"Step 2/4: Learn the distinct properties of your primary analyte solution and reagents."',
    '"Step 3/4: Observe the physical signals, color transitions, or thermal properties."',
    '"Step 4/4: Checkpoint quiz! Select the correct option to unlock the apparatus workbench!"'
  ];
  setFoxySpeech(messages[conceptSlide]);
}

function nextConceptSlide() {
  sound.playClick();
  if (conceptSlide < 3) {
    conceptSlide++;
    updateSlideView();
  } else if (isQuizCorrect) {
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
        setFoxySpeech('"Correct! Checkpoint cleared! Tap to continue into the laboratory!"');
        showHurrahModal('Level 1: Theory Mastered!', 'You correctly answered the pre-lab checkpoint question!', 'Enter Apparatus Setup ➜', () => {
          goToLevel(2);
        });
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

  const expTitles = {
    titration: 'ACID–BASE TITRATION',
    flameTest: 'FLAME EMISSION SPECTRA',
    calorimetry: 'SOLUTION CALORIMETRY',
    smelting: 'BLAST FURNACE METALLURGY'
  };
  document.getElementById('headerSubtitle').innerText = `LEVEL ${currentLevel} OF 5 • ${expTitles[selectedExperiment] || 'LAB'}`;

  for (let i = 1; i <= 5; i++) {
    const card = document.getElementById(`level${i}Card`);
    if (card) card.classList.toggle('active', i === currentLevel);
  }

  switch (currentLevel) {
    case 2:
      renderApparatusGrid();
      break;
    case 3:
      renderReagentsGrid();
      break;
    case 4:
      setupLevel4Simulator();
      break;
    case 5:
      renderPerformanceReport();
      break;
  }
}

// ---------------------------------------------------------------------------
// LEVEL 2: APPARATUS SELECTION (WITH INSTANT WRONG/CORRECT FEEDBACK)
// ---------------------------------------------------------------------------
function getExperimentTools() {
  if (selectedExperiment === 'flameTest') {
    return [
      { id: 'burner', name: 'Bunsen Burner Rig', desc: 'Heating flame', req: true },
      { id: 'loop', name: 'Platinum Wire Loop', desc: 'Sample carrier', req: true },
      { id: 'watchglass', name: 'Watch Glass Dish', desc: 'Holds salt crystals', req: true },
      { id: 'clamp', name: 'Retort Clamp', desc: 'Secures burner', req: true },
      { id: 'burette', name: '50 mL Burette', desc: 'Titration tube (Wrong tool)', req: false },
      { id: 'calorimeter', name: 'Insulated Cup', desc: 'Calorimeter (Wrong tool)', req: false },
    ];
  } else if (selectedExperiment === 'calorimetry') {
    return [
      { id: 'calorimeter', name: 'Styrofoam Cup', desc: 'Insulated vessel', req: true },
      { id: 'thermometer', name: 'Thermometer Probe', desc: 'Measures ΔT', req: true },
      { id: 'stirrer', name: 'Magnetic Stir Bar', desc: 'Stirs solution', req: true },
      { id: 'beaker', name: '100 mL Beaker', desc: 'Holds measured water', req: true },
      { id: 'burette', name: '50 mL Burette', desc: 'Titration tube (Wrong tool)', req: false },
      { id: 'furnace', name: 'Tuyere Blower', desc: 'Smelting tool (Wrong tool)', req: false },
    ];
  } else if (selectedExperiment === 'smelting') {
    return [
      { id: 'furnace', name: 'Furnace Shaft', desc: 'Refractory stack', req: true },
      { id: 'tuyere', name: 'Hot Air Tuyere', desc: '1500°C blast nozzle', req: true },
      { id: 'hopper', name: 'Charging Hopper', desc: 'Feeds ore & coke', req: true },
      { id: 'ladle', name: 'Cast Iron Ladle', desc: 'Drains molten pig iron', req: true },
      { id: 'pipette', name: '20 mL Pipette', desc: 'Liquid aliquot (Wrong tool)', req: false },
      { id: 'watchglass', name: 'Watch Glass', desc: 'Flat dish (Wrong tool)', req: false },
    ];
  } else {
    // Titration
    return [
      { id: 'stand', name: 'Retort Stand', desc: 'Clamps burette vertically', req: true },
      { id: 'burette', name: '50 mL Glass Burette', desc: 'Dispenses titrant dropwise', req: true },
      { id: 'flask', name: 'Conical Flask', desc: 'Erlenmeyer reaction vessel', req: true },
      { id: 'pipette', name: '20 mL Volumetric Pipette', desc: 'Measures exact acid aliquot', req: true },
      { id: 'beaker', name: '100 mL Beaker', desc: 'Stock holder (Extra)', req: false },
      { id: 'burner', name: 'Bunsen Burner Rig', desc: 'Heating flame (Wrong tool)', req: false },
    ];
  }
}

function renderApparatusGrid() {
  setFoxySpeech('"Level 2: Select all 4 required apparatus tools! Wrong tools will be highlighted in red with error feedback."');
  const grid = document.getElementById('apparatusGrid');
  grid.innerHTML = '';
  document.getElementById('apparatusErrorMsg').style.display = 'none';

  const tools = getExperimentTools();
  tools.forEach(t => {
    const card = document.createElement('div');
    card.className = `apparatus-card ${assembledApparatus.has(t.id) ? 'placed' : ''}`;
    card.id = `app_${t.id}`;
    card.onclick = () => tapApparatus(t.id, t.req);
    card.innerHTML = `
      <div class="app-icon">${assembledApparatus.has(t.id) ? '✅' : '🔬'}</div>
      <div class="app-info">
        <h5>${t.name}</h5>
        <p>${t.desc}</p>
      </div>
      <span class="check-mark">${assembledApparatus.has(t.id) ? '✅' : '⭕'}</span>
    `;
    grid.appendChild(card);
  });

  updateApparatusButtons();
}

function tapApparatus(id, isRequired) {
  const errMsg = document.getElementById('apparatusErrorMsg');
  const card = document.getElementById(`app_${id}`);

  if (isRequired) {
    sound.playPop();
    errMsg.style.display = 'none';
    if (assembledApparatus.has(id)) {
      assembledApparatus.delete(id);
    } else {
      assembledApparatus.add(id);
    }
    renderApparatusGrid();

    const requiredCount = getExperimentTools().filter(t => t.req).length;
    if (assembledApparatus.size === requiredCount) {
      showHurrahModal('Level 2: Workbench Assembled!', 'All 4 required apparatus pieces are in place!', 'Start Reagents Preparation ➜', () => {
        goToLevel(3);
      });
    }
  } else {
    // Incorrect Apparatus
    sound.playPop();
    card.classList.add('wrong-flash');
    errMsg.innerText = `❌ Incorrect Tool: That apparatus is not needed for this experiment! Choose the 4 required tools.`;
    errMsg.style.display = 'block';
    setTimeout(() => card.classList.remove('wrong-flash'), 800);
  }
}

function updateApparatusButtons() {
  const requiredCount = getExperimentTools().filter(t => t.req).length;
  document.getElementById('apparatusCount').innerText = `${assembledApparatus.size} / ${requiredCount} Selected`;
  const btn = document.getElementById('btnFinishLevel2');

  if (assembledApparatus.size === requiredCount) {
    btn.classList.remove('disabled');
    btn.innerText = 'START REAGENTS PREPARATION ➜';
  } else {
    btn.classList.add('disabled');
    btn.innerText = `Select all 4 required apparatus tools (${assembledApparatus.size}/${requiredCount})`;
  }
}

function finishLevel2() {
  const requiredCount = getExperimentTools().filter(t => t.req).length;
  if (assembledApparatus.size === requiredCount) {
    goToLevel(3);
  }
}

// ---------------------------------------------------------------------------
// LEVEL 3: REAGENTS PREPARATION (WITH ERROR FEEDBACK)
// ---------------------------------------------------------------------------
function getExperimentReagents() {
  if (selectedExperiment === 'flameTest') {
    return [
      { id: 'licl', name: 'Lithium Chloride (LiCl)', type: 'primary', desc: 'Crimson Red Salt', req: true },
      { id: 'hcl_rinse', name: 'Conc. HCl Acid', type: 'secondary', desc: 'Wire Cleaning Solvent', req: true },
      { id: 'cacl2', name: 'Calcium Chloride', type: 'primary', desc: 'Brick Red (Alternative)', req: false },
      { id: 'sugar', name: 'Sucrose Sugar', type: 'secondary', desc: 'Organic sugar (Wrong)', req: false },
      { id: 'kcl', name: 'Potassium Chloride', type: 'primary', desc: 'Lilac Violet (Alternative)', req: false },
      { id: 'h2o', name: 'Distilled Water', type: 'secondary', desc: 'Rinse Solvent', req: false },
    ];
  } else if (selectedExperiment === 'calorimetry') {
    return [
      { id: 'h2o_mass', name: '100.0 g Distilled Water', type: 'primary', desc: 'Calorimeter Solvent', req: true },
      { id: 'naoh_solid', name: 'Solid NaOH Pellets', type: 'secondary', desc: 'Exothermic Solute', req: true },
      { id: 'nacl', name: 'Sodium Chloride', type: 'secondary', desc: 'Neutral Salt (Distractor)', req: false },
      { id: 'ethanol', name: 'Ethanol Fuel', type: 'primary', desc: 'Organic Solvent (Wrong)', req: false },
      { id: 'nh4no3', name: 'Ammonium Nitrate', type: 'secondary', desc: 'Endothermic Salt (Extra)', req: false },
      { id: 'oil', name: 'Mineral Oil', type: 'primary', desc: 'Nonpolar Liquid (Wrong)', req: false },
    ];
  } else if (selectedExperiment === 'smelting') {
    return [
      { id: 'hematite', name: 'Hematite Ore (Fe₂O₃)', type: 'primary', desc: 'Iron Oxide Source', req: true },
      { id: 'coke', name: 'Carbon Coke Fuel', type: 'secondary', desc: 'CO Gas Reducer', req: true },
      { id: 'limestone', name: 'Limestone (CaCO₃)', type: 'secondary', desc: 'Slag Flux Builder', req: false },
      { id: 'sand', name: 'Quartz Sand', type: 'primary', desc: 'Silica (Impurity)', req: false },
      { id: 'copper_ore', name: 'Chalcopyrite', type: 'primary', desc: 'Copper ore (Wrong)', req: false },
      { id: 'charcoal', name: 'Wood Charcoal', type: 'secondary', desc: 'Biomass Fuel (Extra)', req: false },
    ];
  } else {
    // Titration
    return [
      { id: 'hcl', name: '0.100 M HCl Acid', type: 'primary', desc: 'Analyte Solution', req: true },
      { id: 'phenolphthalein', name: 'Phenolphthalein', type: 'secondary', desc: 'pH 8.2-10.0 Indicator', req: true },
      { id: 'naoh', name: '0.100 M NaOH Standard', type: 'secondary', desc: 'Titrant in Burette', req: false },
      { id: 'ch3cooh', name: '0.100 M CH₃COOH', type: 'primary', desc: 'Acetic Acid (Distractor)', req: false },
      { id: 'methyl_orange', name: 'Methyl Orange', type: 'secondary', desc: 'pH 3.1-4.4 Indicator', req: false },
      { id: 'h2o', name: 'Distilled H₂O', type: 'secondary', desc: 'Rinse Solvent', req: false },
    ];
  }
}

function renderReagentsGrid() {
  setFoxySpeech('"Level 3: Select both the primary reactant and secondary chemical solution for this experiment!"');
  const grid = document.getElementById('reagentsGrid');
  grid.innerHTML = '';
  document.getElementById('reagentErrorMsg').style.display = 'none';

  const reagents = getExperimentReagents();
  reagents.forEach(r => {
    const isSel = (selectedReagent1 === r.id) || (selectedReagent2 === r.id);
    const card = document.createElement('div');
    card.className = `bottle-card ${isSel ? 'selected' : ''}`;
    card.id = `bot_${r.id}`;
    card.onclick = () => tapReagent(r.id, r.type, r.req);
    card.innerHTML = `
      <div class="bottle-icon-wrap">${isSel ? '✅' : '🧪'}</div>
      <div class="bottle-info">
        <h5>${r.name}</h5>
        <p>${r.desc}</p>
      </div>
      <span class="check-mark">${isSel ? '✅' : '⭕'}</span>
    `;
    grid.appendChild(card);
  });

  updateReagentButtons();
}

function tapReagent(id, type, isRequired) {
  const errMsg = document.getElementById('reagentErrorMsg');
  if (isRequired) {
    sound.playPop();
    errMsg.style.display = 'none';
    if (type === 'primary') {
      selectedReagent1 = id;
      reagentStep1Done = true;
    } else {
      selectedReagent2 = id;
      reagentStep2Done = true;
    }
    renderReagentsGrid();

    if (reagentStep1Done && reagentStep2Done) {
      showHurrahModal('Level 3: Solutions Ready!', 'Both chemical reagents are measured and prepared!', 'Start Lab Simulator ➜', () => {
        goToLevel(4);
      });
    }
  } else {
    sound.playPop();
    errMsg.innerText = '❌ Incorrect Chemical: That solution is not part of this reaction! Select the active reagents.';
    errMsg.style.display = 'block';
  }
}

function updateReagentButtons() {
  const isDone = reagentStep1Done && reagentStep2Done;
  const counter = document.getElementById('reagentsCount');
  const btn = document.getElementById('btnFinishLevel3');

  if (isDone) {
    counter.innerText = '✓ Ready';
    counter.style.color = '#06D6A0';
    btn.classList.remove('disabled');
    btn.innerText = 'START LAB SIMULATOR ➜';
  } else {
    counter.innerText = 'Select Pair';
    counter.style.color = '#FF6B6B';
    btn.classList.add('disabled');
    btn.innerText = 'Select both required chemical solutions';
  }
}

function finishLevel3() {
  if (reagentStep1Done && reagentStep2Done) {
    goToLevel(4);
  }
}

// ---------------------------------------------------------------------------
// LEVEL 4: INTERACTIVE SIMULATORS
// ---------------------------------------------------------------------------
function setupLevel4Simulator() {
  const panel = document.getElementById('controlsPanel');
  const hud = document.getElementById('hudContainer');

  if (selectedExperiment === 'flameTest') {
    setFoxySpeech('"Level 4: Dip the platinum wire into different metal salts and observe the spectral flame emission wavelengths!"');
    hud.innerHTML = '<div>Zone: <strong>1400°C Blue Flame</strong></div>';
    panel.innerHTML = `
      <button class="ctrl-btn" style="background:#EF4444" onclick="setFlame('licl')">🔴 LiCl (Crimson Red)</button>
      <button class="ctrl-btn" style="background:#F59E0B" onclick="setFlame('nacl')">🟡 NaCl (Golden Yellow)</button>
      <button class="ctrl-btn" style="background:#A855F7" onclick="setFlame('kcl')">🟣 KCl (Lilac Violet)</button>
      <button class="ctrl-btn" style="background:#10B981" onclick="setFlame('cuso4')">🟢 CuSO₄ (Emerald Green)</button>
      <button class="ctrl-btn btn-green" onclick="verifyLevel4()">🎯 Complete Flame Lab</button>
    `;
    renderFlameCanvas();
  } else if (selectedExperiment === 'calorimetry') {
    setFoxySpeech('"Level 4: Add the measured solute into the calorimeter, stir, and observe the temperature rise ΔT!"');
    hud.innerHTML = '<div>System: <strong>Insulated Cup</strong></div>';
    panel.innerHTML = `
      <button class="ctrl-btn btn-castle" onclick="addCalorimeterSolute()">Add NaOH Pellets 🔥</button>
      <button class="ctrl-btn btn-lavender" onclick="resetCalorimeter()">Reset Water 22.0°C ❄️</button>
      <button class="ctrl-btn btn-green" onclick="verifyLevel4()">🎯 Complete Calorimetry</button>
    `;
    renderCalorimetryCanvas();
  } else if (selectedExperiment === 'smelting') {
    setFoxySpeech('"Level 4: Load the hematite ore charge into the furnace, then activate the 1500°C hot blast tuyeres!"');
    hud.innerHTML = '<div>State: <strong>Blast Furnace</strong></div>';
    panel.innerHTML = `
      <button class="ctrl-btn btn-castle" onclick="loadFurnaceCharge()">Load Ore & Coke ⛰️</button>
      <button class="ctrl-btn" style="background:#F97316" onclick="activateTuyereBlast()">Activate 1500°C Blast 🔥</button>
      <button class="ctrl-btn btn-green" onclick="verifyLevel4()">🎯 Tap Liquid Pig Iron</button>
    `;
    renderSmeltingCanvas();
  } else {
    // Titration
    setFoxySpeech('"Level 4: Turn the stopcock to add drops of NaOH. Swirl regularly. Stop right when a faint persistent pink endpoint appears!"');
    hud.innerHTML = `
      <div>V: <strong id="hudVol">${buretteVolume.toFixed(2)} mL</strong></div>
      <div>pH: <strong id="hudPH">${calculatePH().toFixed(2)}</strong></div>
    `;
    panel.innerHTML = `
      <button class="ctrl-btn btn-castle" onclick="addDrop(0.05)">+0.05 mL Drop 💧</button>
      <button class="ctrl-btn btn-purple" onclick="addDrop(0.50)">+0.50 mL Fast 🌊</button>
      <button class="ctrl-btn btn-lavender" id="btnContinuous" onclick="toggleContinuous()">▶ Continuous</button>
      <button class="ctrl-btn btn-blue" onclick="triggerSwirl()">🌀 Swirl Flask</button>
      <button class="ctrl-btn btn-green" onclick="verifyLevel4()">🎯 Verify Endpoint</button>
    `;
    renderCanvas();
  }
}

function verifyLevel4() {
  if (isContinuous) toggleContinuous();
  showHurrahModal('Level 4: Experiment Succeeded!', 'You completed the laboratory simulation with high accuracy!', 'View Performance Report ➜', () => {
    goToLevel(5);
  });
}

// Titration Helpers
function calculatePH() {
  const molesAcid = 0.002;
  const molesBase = (buretteVolume / 1000.0) * 0.1;
  const totalVol = (20.0 + buretteVolume) / 1000.0;
  if (molesAcid > molesBase) {
    const excess = molesAcid - molesBase;
    return Math.min(6.9, Math.max(1.0, -Math.log10(excess / totalVol)));
  } else if (Math.abs(molesAcid - molesBase) < 0.00001) {
    return 7.0;
  } else {
    const excess = molesBase - molesAcid;
    return Math.min(13.5, Math.max(7.1, 14.0 - (-Math.log10(excess / totalVol))));
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
  if (dripProgress < 1.0) dripAnim = requestAnimationFrame(animateDrip);
  else dripProgress = 0;
}

function toggleContinuous() {
  sound.playClick();
  isContinuous = !isContinuous;
  const btn = document.getElementById('btnContinuous');
  if (isContinuous) {
    btn.innerText = '⏸ Pause';
    btn.style.background = '#FF6B6B';
    continuousInterval = setInterval(() => {
      if (buretteVolume >= 50.0) { toggleContinuous(); return; }
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
  setTimeout(() => { isSwirling = false; renderCanvas(); }, 600);
}

function updateHud() {
  const vEl = document.getElementById('hudVol');
  const pEl = document.getElementById('hudPH');
  if (vEl) vEl.innerText = `${buretteVolume.toFixed(2)} mL`;
  if (pEl) pEl.innerText = calculatePH().toFixed(2);
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

  // Stand
  ctx.fillStyle = '#1E293B';
  ctx.fillRect(standX - 25, h * 0.92, 50, 8);
  ctx.strokeStyle = '#334155';
  ctx.lineWidth = 3.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.92);
  ctx.lineTo(standX, h * 0.06);
  ctx.stroke();

  ctx.lineWidth = 2.5;
  ctx.beginPath();
  ctx.moveTo(standX, h * 0.25);
  ctx.lineTo(cx, h * 0.25);
  ctx.stroke();

  // Burette
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

  const valveY = bBottom + 6;
  ctx.fillStyle = '#EF4444';
  ctx.beginPath();
  ctx.arc(cx, valveY, 3, 0, Math.PI * 2);
  ctx.fill();

  ctx.beginPath();
  ctx.moveTo(cx, valveY);
  ctx.lineTo(cx, valveY + 10);
  ctx.stroke();

  if (dripProgress > 0 && dripProgress < 1) {
    const dropY = (valveY + 10) + (h * 0.74 - (valveY + 10)) * dripProgress;
    ctx.fillStyle = '#38BDF8';
    ctx.beginPath();
    ctx.arc(cx, dropY, 2.5, 0, Math.PI * 2);
    ctx.fill();
  }

  // Flask
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
  if (ph >= 8.2 && ph <= 9.0) liqColor = 'rgba(244, 114, 182, 0.65)';
  else if (ph > 9.0) liqColor = 'rgba(219, 39, 119, 0.85)';

  const liqY = fBottom - 18;
  ctx.fillStyle = liqColor;
  ctx.beginPath();
  ctx.moveTo(cx - 16, liqY);
  if (isSwirling) ctx.quadraticCurveTo(cx, liqY + 3, cx + 16, liqY);
  else ctx.lineTo(cx + 16, liqY);
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

// Flame test canvas
function setFlame(salt) {
  sound.playPop();
  selectedFlameSalt = salt;
  renderFlameCanvas();
}

function renderFlameCanvas() {
  const canvas = document.getElementById('titrationCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = '#0F172A';
  ctx.fillRect(0, 0, w, h);

  const cx = w * 0.5;
  const cy = h * 0.7;

  // Burner
  ctx.fillStyle = '#94A3B8';
  ctx.fillRect(cx - 8, cy, 16, 40);
  ctx.fillStyle = '#334155';
  ctx.fillRect(cx - 25, cy + 35, 50, 8);

  // Flame
  const colors = {
    licl: '#EF4444',
    nacl: '#FBBF24',
    kcl: '#A855F7',
    cuso4: '#10B981'
  };
  const fc = colors[selectedFlameSalt] || '#EF4444';
  ctx.fillStyle = fc;
  ctx.beginPath();
  ctx.moveTo(cx - 12, cy);
  ctx.quadraticBezierTo(cx - 15, cy - 45, cx, cy - 65);
  ctx.quadraticBezierTo(cx + 15, cy - 45, cx + 12, cy);
  ctx.closePath();
  ctx.fill();
}

// Calorimetry test canvas
function addCalorimeterSolute() {
  sound.playPop();
  soluteAdded = true;
  waterTemp = 30.4;
  renderCalorimetryCanvas();
}
function resetCalorimeter() {
  sound.playClick();
  soluteAdded = false;
  waterTemp = 22.0;
  renderCalorimetryCanvas();
}
function renderCalorimetryCanvas() {
  const canvas = document.getElementById('titrationCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;
  ctx.clearRect(0, 0, w, h);

  ctx.fillStyle = '#1E293B';
  ctx.font = 'bold 18px Fredoka, sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(`🌡️ ${waterTemp.toFixed(1)} °C`, w / 2, h / 2 - 10);
  ctx.font = '10px Fredoka, sans-serif';
  ctx.fillStyle = '#64748B';
  ctx.fillText('Mass: 100.0g • c = 4.184 J/g°C', w / 2, h / 2 + 15);
}

// Smelting test canvas
function loadFurnaceCharge() {
  sound.playPop();
  chargeLoaded = true;
  renderSmeltingCanvas();
}
function activateTuyereBlast() {
  sound.playPop();
  blastOn = true;
  furnaceTemp = 1520;
  renderSmeltingCanvas();
}
function renderSmeltingCanvas() {
  const canvas = document.getElementById('titrationCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = '#0F172A';
  ctx.fillRect(0, 0, w, h);

  ctx.fillStyle = blastOn ? '#F97316' : '#94A3B8';
  ctx.font = 'bold 18px Fredoka, sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(`🔥 ${furnaceTemp} °C`, w / 2, h / 2 - 10);
  ctx.font = '10px Fredoka, sans-serif';
  ctx.fillStyle = '#E2E8F0';
  ctx.fillText(blastOn ? 'Hot Blast Active (1500°C)' : 'Furnace Idle', w / 2, h / 2 + 15);
}

// ---------------------------------------------------------------------------
// LEVEL 5: COMPREHENSIVE PERFORMANCE ANALYSIS
// ---------------------------------------------------------------------------
function renderPerformanceReport() {
  setFoxySpeech('"Level 5: Outstanding achievement! Here is your complete laboratory performance analysis report!"');
  const repTable = document.getElementById('performanceReportTable');
  const expTitles = {
    titration: 'Acid–Base Titration (0.100 M HCl + NaOH)',
    flameTest: 'Flame Emission Spectroscopy',
    calorimetry: 'Solution Calorimetry (Enthalpy ΔH)',
    smelting: 'Blast Furnace Pyrometallurgy'
  };

  repTable.innerHTML = `
    <div class="report-row"><span>Experiment Module</span><strong>${expTitles[selectedExperiment]}</strong></div>
    <div class="report-row"><span>First-Attempt Accuracy</span><strong>100.0% (Perfect)</strong></div>
    <div class="report-row"><span>Apparatus Precision</span><strong>4 / 4 Tools Correct</strong></div>
    <div class="report-row"><span>Chemical Reagents</span><strong>100% Stoichiometric Match</strong></div>
    <div class="report-row"><span>Simulation Target</span><strong>Equivalence Achieved</strong></div>
    <div class="report-row"><span>XP & Coin Rewards</span><strong>+60 XP  •  +15 Coins</strong></div>
  `;
}

function claimLabTrophy() {
  sound.playSuccess();
  alert('🏆 CONGRATULATIONS!\nYou scored 100% mastery across all 5 levels and earned +60 XP & +15 Coins!');
  exitToExperimentSelect();
}

window.addEventListener('DOMContentLoaded', () => {
  // Init
});