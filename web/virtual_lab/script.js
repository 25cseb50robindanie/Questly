/**
 * QUESTLY VIRTUAL SCIENCE LAB ENGINE
 * High-fidelity, gamified, multi-module virtual lab simulator.
 * Features direct hands-on physical interactions, photorealistic glassware, 3D blast furnace cutaway, and balanced audio.
 * Supports: Acid-Base Titration, Smelting & Blast Furnace Metallurgy, Calorimetry, Flame Test.
 */

// ============================================================================
// 1. SOUND SYSTEM (PLEASANT, GENTLE SYNTHESIZER)
// ============================================================================
class LabSoundEngine {
  constructor() {
    this.enabled = true;
    this.ctx = null;
  }

  _initCtx() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playClick() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(520, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(260, this.ctx.currentTime + 0.04);
    gain.gain.setValueAtTime(0.06, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.001, this.ctx.currentTime + 0.04);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.04);
  }

  playSuccess() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [523.25, 659.25, 783.99].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + i * 0.07);
      gain.gain.setValueAtTime(0.05, now + i * 0.07);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.07 + 0.2);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + i * 0.07);
      osc.stop(now + i * 0.07 + 0.2);
    });
  }

  playError() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(220, now);
    osc.frequency.exponentialRampToValueAtTime(140, now + 0.12);
    gain.gain.setValueAtTime(0.06, now);
    gain.gain.linearRampToValueAtTime(0.001, now + 0.12);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.12);
  }

  playWaterDrop() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(950, now);
    osc.frequency.exponentialRampToValueAtTime(350, now + 0.06);
    gain.gain.setValueAtTime(0.06, now);
    gain.gain.linearRampToValueAtTime(0.001, now + 0.06);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.06);
  }

  playFurnaceHum() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(110, now);
    osc.frequency.linearRampToValueAtTime(150, now + 0.3);
    gain.gain.setValueAtTime(0.05, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.35);
  }

  playFanfare() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const notes = [440, 554.37, 659.25, 880];
    notes.forEach((freq, idx) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + idx * 0.09);
      gain.gain.setValueAtTime(0.06, now + idx * 0.09);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.09 + 0.3);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + idx * 0.09);
      osc.stop(now + idx * 0.09 + 0.3);
    });
  }
}

const labSound = new LabSoundEngine();

// ============================================================================
// 2. REALISTIC LAB VISUAL ASSET GENERATOR (SVGs & LAB BOTTLES)
// ============================================================================
function getRealisticApparatusSVG(id) {
  switch (id) {
    case 'burette':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="25" y="10" width="6" height="105" fill="#475569" rx="2"/>
          <path d="M25 45 L50 45 L52 48 L48 52 L25 50" fill="#334155"/>
          <circle cx="28" cy="47" r="4" fill="#94A3B8"/>
          <rect x="48" y="15" width="12" height="75" fill="rgba(224, 242, 254, 0.5)" stroke="#334155" stroke-width="1.5" rx="2"/>
          <rect x="49" y="35" width="10" height="54" fill="rgba(59, 130, 246, 0.45)" rx="1"/>
          <line x1="48" y1="25" x2="54" y2="25" stroke="#1E293B" stroke-width="1"/>
          <line x1="48" y1="45" x2="55" y2="45" stroke="#1E293B" stroke-width="1"/>
          <line x1="48" y1="65" x2="55" y2="65" stroke="#1E293B" stroke-width="1"/>
          <circle cx="54" cy="93" r="5" fill="#EF4444" stroke="#991B1B" stroke-width="1"/>
          <polygon points="52,98 56,98 54,112" fill="rgba(224, 242, 254, 0.7)" stroke="#334155" stroke-width="1"/>
        </svg>
      `;

    case 'conical_flask':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="42" y="15" width="16" height="6" fill="#E2E8F0" stroke="#334155" stroke-width="1.5" rx="2"/>
          <rect x="44" y="20" width="12" height="25" fill="rgba(241, 245, 249, 0.6)" stroke="#334155" stroke-width="1.5"/>
          <polygon points="44,45 15,102 85,102 56,45" fill="rgba(224, 242, 254, 0.55)" stroke="#334155" stroke-width="2"/>
          <polygon points="32,70 17,100 83,100 68,70" fill="rgba(244, 114, 182, 0.35)"/>
          <line x1="40" y1="75" x2="60" y2="75" stroke="rgba(255,255,255,0.8)" stroke-width="1.2"/>
          <line x1="35" y1="85" x2="65" y2="85" stroke="rgba(255,255,255,0.8)" stroke-width="1.2"/>
          <path d="M22 96 L47 48" stroke="rgba(255,255,255,0.6)" stroke-width="2" stroke-linecap="round"/>
        </svg>
      `;

    case 'pipette':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <ellipse cx="50" cy="18" rx="10" ry="12" fill="#DC2626" stroke="#991B1B" stroke-width="1.5"/>
          <rect x="48" y="34" width="4" height="25" fill="rgba(224, 242, 254, 0.6)" stroke="#334155" stroke-width="1"/>
          <line x1="47" y1="48" x2="53" y2="48" stroke="#D97706" stroke-width="1.5"/>
          <ellipse cx="50" cy="72" rx="9" ry="16" fill="rgba(224, 242, 254, 0.6)" stroke="#334155" stroke-width="1.5"/>
          <polygon points="48,88 52,88 50,114" fill="rgba(224, 242, 254, 0.7)" stroke="#334155" stroke-width="1"/>
        </svg>
      `;

    case 'stand_clamp':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="15" y="98" width="70" height="12" fill="#1E293B" stroke="#0F172A" stroke-width="1.5" rx="3"/>
          <rect x="25" y="15" width="6" height="85" fill="#94A3B8" stroke="#475569" stroke-width="1" rx="1"/>
          <rect x="23" y="38" width="18" height="8" fill="#475569" rx="2"/>
          <path d="M40 42 L65 34 L72 38" stroke="#334155" stroke-width="2.5" fill="none"/>
          <path d="M40 42 L65 50 L72 46" stroke="#334155" stroke-width="2.5" fill="none"/>
          <rect x="68" y="32" width="8" height="6" fill="#EF4444" rx="2"/>
          <rect x="68" y="46" width="8" height="6" fill="#EF4444" rx="2"/>
        </svg>
      `;

    case 'beaker':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <path d="M22 30 L18 28 L24 35 L76 35 L76 30 Z" fill="#CBD5E1"/>
          <rect x="24" y="32" width="52" height="68" fill="rgba(224, 242, 254, 0.55)" stroke="#334155" stroke-width="2" rx="3"/>
          <rect x="26" y="55" width="48" height="43" fill="rgba(14, 165, 233, 0.4)" rx="2"/>
          <line x1="60" y1="45" x2="72" y2="45" stroke="rgba(255,255,255,0.9)" stroke-width="1.5"/>
          <line x1="60" y1="60" x2="72" y2="60" stroke="rgba(255,255,255,0.9)" stroke-width="1.5"/>
          <line x1="60" y1="75" x2="72" y2="75" stroke="rgba(255,255,255,0.9)" stroke-width="1.5"/>
        </svg>
      `;

    case 'furnace_rig':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <polygon points="35,15 65,15 60,25 40,25" fill="#64748B" stroke="#1E293B" stroke-width="1.5"/>
          <polygon points="40,25 60,25 78,80 70,105 30,105 22,80" fill="#334155" stroke="#0F172A" stroke-width="2"/>
          <ellipse cx="50" cy="88" rx="14" ry="12" fill="#F97316"/>
          <ellipse cx="50" cy="88" rx="8" ry="7" fill="#FDE047"/>
          <rect x="15" y="76" width="70" height="6" fill="#475569" stroke="#1E293B" stroke-width="1" rx="2"/>
          <polygon points="35,105 20,114 40,114" fill="#EAB308"/>
        </svg>
      `;

    case 'pyrometer':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="25" y="25" width="50" height="35" fill="#1E293B" stroke="#0F172A" stroke-width="2" rx="4"/>
          <rect x="75" y="32" width="14" height="20" fill="#475569" rx="2"/>
          <rect x="32" y="32" width="34" height="20" fill="#022C22" stroke="#065F46" stroke-width="1.5" rx="2"/>
          <text x="35" y="46" fill="#34D399" font-size="8" font-weight="bold" font-family="monospace">1450°C</text>
          <path d="M35 60 L30 105 L45 105 L50 60 Z" fill="#334155" stroke="#1E293B" stroke-width="1.5"/>
          <rect x="50" y="65" width="6" height="10" fill="#EF4444" rx="2"/>
        </svg>
      `;

    case 'tuyere_blower':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="15" y="40" width="14" height="40" fill="#64748B" stroke="#1E293B" stroke-width="1.5" rx="2"/>
          <polygon points="29,46 80,52 80,68 29,74" fill="#B45309" stroke="#78350F" stroke-width="2"/>
          <rect x="42" y="44" width="22" height="32" fill="#D97706" stroke="#92400E" stroke-width="1.5" rx="2"/>
          <path d="M82 54 L96 50 L94 70 L82 66 Z" fill="rgba(56, 189, 248, 0.6)"/>
        </svg>
      `;

    case 'ladle_mold':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <path d="M20 40 L28 95 L72 95 L80 40 Z" fill="#334155" stroke="#0F172A" stroke-width="2"/>
          <ellipse cx="50" cy="50" rx="26" ry="8" fill="#FDE047" stroke="#F97316" stroke-width="1.5"/>
          <path d="M22 55 L22 25 L78 25 L78 55" stroke="#64748B" stroke-width="3" fill="none"/>
        </svg>
      `;

    case 'calorimeter':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="22" y="35" width="56" height="68" fill="#E2E8F0" stroke="#475569" stroke-width="2" rx="4"/>
          <rect x="18" y="28" width="64" height="10" fill="#94A3B8" stroke="#334155" stroke-width="1.5" rx="2"/>
          <rect x="36" y="8" width="4" height="60" fill="#DC2626" rx="1"/>
          <path d="M58 12 L58 85 A8 8 0 0 1 50 93 A8 8 0 0 1 42 85" stroke="#64748B" stroke-width="2" fill="none"/>
        </svg>
      `;

    case 'thermometer':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="25" y="15" width="50" height="35" fill="#F1F5F9" stroke="#334155" stroke-width="2" rx="4"/>
          <rect x="30" y="22" width="40" height="20" fill="#1E293B" rx="2"/>
          <text x="33" y="36" fill="#38BDF8" font-size="9" font-family="monospace" font-weight="bold">22.0°C</text>
          <path d="M50 50 Q60 65 48 78" stroke="#64748B" stroke-width="2" fill="none"/>
          <rect x="46" y="78" width="4" height="35" fill="#CBD5E1" stroke="#475569" stroke-width="1" rx="1"/>
        </svg>
      `;

    case 'bunsen_burner':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <polygon points="50,10 40,42 60,42" fill="#38BDF8" opacity="0.85"/>
          <polygon points="50,18 45,42 55,42" fill="#FFFFFF"/>
          <rect x="45" y="42" width="10" height="42" fill="#F59E0B" stroke="#B45309" stroke-width="1.5"/>
          <rect x="43" y="72" width="14" height="10" fill="#78350F" rx="1"/>
          <polygon points="20,108 80,108 72,94 28,94" fill="#334155" stroke="#0F172A" stroke-width="2"/>
        </svg>
      `;

    case 'platinum_loop':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="46" y="10" width="8" height="60" fill="#94A3B8" stroke="#475569" stroke-width="1.5" rx="2"/>
          <polygon points="45,70 55,70 53,78 47,78" fill="#F59E0B"/>
          <line x1="50" y1="78" x2="50" y2="104" stroke="#E2E8F0" stroke-width="1.8"/>
          <circle cx="50" cy="108" r="4" stroke="#E2E8F0" stroke-width="1.8" fill="none"/>
        </svg>
      `;

    case 'watch_glass':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <path d="M15 65 Q50 90 85 65 Q50 78 15 65 Z" fill="rgba(224, 242, 254, 0.65)" stroke="#64748B" stroke-width="1.5"/>
          <ellipse cx="50" cy="74" rx="18" ry="6" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
          <path d="M22 66 Q50 86 78 66" stroke="rgba(255,255,255,0.8)" stroke-width="1.5" fill="none"/>
        </svg>
      `;

    case 'cobalt_glass':
      return `
        <svg viewBox="0 0 100 120" class="real-apparatus-svg">
          <rect x="20" y="25" width="60" height="70" fill="rgba(30, 58, 138, 0.85)" stroke="#1E3A8A" stroke-width="2" rx="3"/>
          <rect x="24" y="29" width="52" height="62" fill="rgba(37, 99, 235, 0.6)" stroke="rgba(255,255,255,0.4)" stroke-width="1"/>
        </svg>
      `;

    default:
      return `<svg viewBox="0 0 100 120" class="real-apparatus-svg"><rect x="20" y="20" width="60" height="80" fill="#E2E8F0" rx="4"/></svg>`;
  }
}

function getRealisticBottleHTML(item) {
  const isOre = item.hazard && item.hazard.includes('Mineral');
  const isFuel = item.hazard && item.hazard.includes('Fuel');
  const isFlux = item.hazard && item.hazard.includes('Flux');

  let bottleTypeClass = 'clear-glass-bottle';
  let fluidGradient = 'rgba(59, 130, 246, 0.45)';
  let hazardIcon = '⚠️';
  let hazardColor = '#EF4444';

  if (item.id === 'phenolphthalein' || item.id === 'hno3_conc' || item.id === 'silver_nitrate') {
    bottleTypeClass = 'amber-glass-bottle';
    fluidGradient = 'rgba(180, 83, 9, 0.65)';
  } else if (item.hazard.includes('Corrosive') || item.hazard.includes('Acid')) {
    hazardIcon = '🧪';
    hazardColor = '#DC2626';
    fluidGradient = 'rgba(224, 242, 254, 0.6)';
  } else if (item.hazard.includes('Flammable')) {
    hazardIcon = '🔥';
    hazardColor = '#EA580C';
    fluidGradient = 'rgba(254, 215, 170, 0.5)';
  } else if (item.hazard.includes('Toxic')) {
    hazardIcon = '☠️';
    hazardColor = '#7F1D1D';
  }

  if (isOre) {
    return `
      <div class="mineral-jar-visual">
        <div class="jar-lid"></div>
        <div class="jar-glass-body">
          <div class="ore-pellets-fill hematite"></div>
        </div>
      </div>
      <div class="bottle-label-box real-lab-label">
        <div class="ghs-hazard-diamond" style="border-color: #B45309;">🪨</div>
        <div class="bottle-formula">${item.formula}</div>
        <div class="bottle-conc">${item.conc}</div>
        <div class="bottle-name-sub">${item.name}</div>
        <div class="label-cas">CAS: 1309-37-1</div>
      </div>
    `;
  } else if (isFuel) {
    return `
      <div class="mineral-jar-visual">
        <div class="jar-lid"></div>
        <div class="jar-glass-body">
          <div class="ore-pellets-fill coke"></div>
        </div>
      </div>
      <div class="bottle-label-box real-lab-label">
        <div class="ghs-hazard-diamond" style="border-color: #EF4444;">🔥</div>
        <div class="bottle-formula">${item.formula}</div>
        <div class="bottle-conc">${item.conc}</div>
        <div class="bottle-name-sub">${item.name}</div>
        <div class="label-cas">CAS: 7440-44-0</div>
      </div>
    `;
  } else if (isFlux) {
    return `
      <div class="mineral-jar-visual">
        <div class="jar-lid"></div>
        <div class="jar-glass-body">
          <div class="ore-pellets-fill limestone"></div>
        </div>
      </div>
      <div class="bottle-label-box real-lab-label">
        <div class="ghs-hazard-diamond" style="border-color: #3B82F6;">🪨</div>
        <div class="bottle-formula">${item.formula}</div>
        <div class="bottle-conc">${item.conc}</div>
        <div class="bottle-name-sub">${item.name}</div>
        <div class="label-cas">CAS: 471-34-1</div>
      </div>
    `;
  }

  return `
    <div class="bottle-visual ${bottleTypeClass}">
      <div class="bottle-cap"></div>
      <div class="bottle-neck"></div>
      <div class="bottle-glass">
        <div class="liquid-fill" style="background: ${fluidGradient};"></div>
        <div class="glass-reflection-streak"></div>
      </div>
    </div>
    <div class="bottle-label-box real-lab-label">
      <div class="ghs-hazard-diamond" style="border-color: ${hazardColor};">${hazardIcon}</div>
      <div class="bottle-formula">${item.formula}</div>
      <div class="bottle-conc">${item.conc}</div>
      <div class="bottle-name-sub">${item.name}</div>
      <div class="label-purity">ACS Reagent Grade • 99.8%</div>
    </div>
  `;
}

// ============================================================================
// 3. MODULE DATABASE
// ============================================================================
const LAB_MODULES = {
  titration: {
    id: 'titration',
    name: 'Acid–Base Titration',
    subtitle: 'Determine the exact neutralization endpoint using standardized 0.1 M NaOH & HCl.',
    xpReward: 60,
    goldReward: 20,
    concept: {
      title: 'Neutralization Reaction & Titrimetric Analysis',
      subtitle: 'Understand stoichiometry, indicators, apparatus, and dropwise titration.',
      cards: {
        principle: {
          tag: 'Chemical Principle',
          heading: 'Neutralization & Equivalence Point',
          desc: 'A neutralization reaction occurs when stoichiometric amounts of an acid and a base react to form a neutral salt and water. Moles of H⁺ equal moles of OH⁻ at equivalence.',
          formula: 'HCl(aq) + NaOH(aq) → NaCl(aq) + H₂O(l)   [M₁V₁ = M₂V₂]',
          modalDetails: `
            <h4>1. Theory & Mechanism</h4>
            <p>Acid-base titration calculates the unknown concentration of an identified analyte. In this lab, we titrate 10.0 mL of Hydrochloric Acid (HCl) against standard 0.1 M Sodium Hydroxide (NaOH).</p>
            <br>
            <h4>2. Equivalence vs. Endpoint</h4>
            <p><strong>Equivalence Point:</strong> Theoretical stoichiometric neutralization (pH = 7.0).</p>
            <p><strong>Endpoint:</strong> Sharp color change of Phenolphthalein from colorless to faint, permanent pale pink (pH 8.2 - 8.3).</p>
          `
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Required Apparatus',
          desc: 'Precision volumetric glassware including a 50 mL graduated Burette, 10 mL Volumetric Pipette, 250 mL Conical Flask, and Retort Stand.',
          tags: ['Burette (50 mL)', 'Pipette (10 mL)', 'Conical Flask (250 mL)', 'Retort Stand & Clamp'],
          modalDetails: `
            <h4>Apparatus Utility:</h4>
            <ul>
              <li><strong>Burette:</strong> Delivers variable volumes of NaOH drop by drop.</li>
              <li><strong>Pipette:</strong> Accurately measures 10.0 mL of HCl analyte.</li>
              <li><strong>Conical Flask:</strong> Prevents splashing during swirling.</li>
              <li><strong>White Tile:</strong> Enhances pale pink color detection.</li>
            </ul>
          `
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Solutions',
          desc: 'Standard Hydrochloric Acid (HCl 0.1 M), Sodium Hydroxide (NaOH 0.1 M), and Phenolphthalein Indicator.',
          tags: ['0.1 M HCl (Analyte)', '0.1 M NaOH (Titrant)', 'Phenolphthalein Indicator'],
          modalDetails: `
            <h4>Reagents:</h4>
            <p>0.1 M HCl (in flask), 0.1 M NaOH (in burette), and 2 drops of Phenolphthalein indicator.</p>
          `
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Step-by-Step Execution',
          desc: '1. Rinse & fill burette. 2. Pipette 10 mL HCl. 3. Add 2 drops indicator. 4. Dispense titrant until permanent pale pink.',
          modalDetails: `
            <h4>Protocol:</h4>
            <ol>
              <li>Fill burette with 0.1 M NaOH.</li>
              <li>Pipette 10.0 mL HCl into conical flask.</li>
              <li>Add 2 drops of indicator.</li>
              <li>Dispense titrant while swirling until permanent pale pink persists.</li>
            </ol>
          `
        }
      }
    },
    apparatusPool: [
      { id: 'burette', name: 'Burette', spec: '50 mL Borosilicate Glass', required: true },
      { id: 'conical_flask', name: 'Conical Flask', spec: '250 mL Erlenmeyer', required: true },
      { id: 'pipette', name: 'Volumetric Pipette', spec: '10.0 mL Class A', required: true },
      { id: 'stand_clamp', name: 'Retort Stand & Clamp', spec: 'Cast Iron Base + Rod', required: true },
      { id: 'beaker', name: 'Griffin Beaker', spec: '100 mL Pyrex Glass', required: false, wrongDesc: "A Beaker is for holding bulk liquids, not precision volumetric titration." },
      { id: 'furnace_rig', name: 'Blast Furnace', spec: 'Industrial Smelter', required: false, wrongDesc: "A Blast Furnace is for smelting ores, not liquid titration!" },
      { id: 'bunsen_burner', name: 'Bunsen Burner', spec: 'Gas Burner', required: false, wrongDesc: "Heating is not required for acid-base room temperature titration." },
      { id: 'watch_glass', name: 'Watch Glass', spec: 'Dish Lens', required: false, wrongDesc: "A Watch Glass is for drying solid crystals, not liquid titration." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_01', name: 'Hydrochloric Acid', formula: 'HCl', conc: '0.1000 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'h2so4_conc', name: 'Sulfuric Acid (Conc)', formula: 'H₂SO₄', conc: '18.0 M', hazard: 'Severe Acid 🔥', required: false, shelf: 'A', wrongDesc: "Concentrated H₂SO₄ is too hazardous and not required for 0.1 M titration." },
        { id: 'acetic_acid', name: 'Acetic Acid', formula: 'CH₃COOH', conc: '0.5 M', hazard: 'Weak Acid ⚠️', required: false, shelf: 'A', wrongDesc: "Acetic Acid is a weak organic acid; we require standard strong 0.1 M HCl." },
        { id: 'distilled_water', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: false, shelf: 'A', wrongDesc: "Distilled water is for rinsing, but not the primary analyte reagent." }
      ],
      shelfB: [
        { id: 'naoh_01', name: 'Sodium Hydroxide', formula: 'NaOH', conc: '0.1000 M', hazard: 'Caustic Base ⚠️', required: true, shelf: 'B' },
        { id: 'phenolphthalein', name: 'Phenolphthalein', formula: 'C₂₀H₁₄O₄', conc: '1% Sol.', hazard: 'Indicator 💧', required: true, shelf: 'B' },
        { id: 'methyl_orange', name: 'Methyl Orange', formula: 'C₁₄H₁₄N₃NaO₃S', conc: '0.1% Sol.', hazard: 'Indicator 💧', required: false, shelf: 'B', wrongDesc: "Methyl orange transitions at pH 3.1-4.4. Phenolphthalein is required for strong acid-base titration." },
        { id: 'ethanol', name: 'Ethanol (95%)', formula: 'C₂H₅OH', conc: '95%', hazard: 'Flammable 🔥', required: false, shelf: 'B', wrongDesc: "Ethanol is an organic solvent not used in this titration." }
      ]
    },
    revision: {
      title: 'Acid–Base Titration Summary Sheet',
      content: `
        <div class="rev-block">
          <h4>📌 Core Equation & Calculations:</h4>
          <p><code>HCl + NaOH &rarr; NaCl + H₂O</code></p>
          <p>Molarity Formula: <code>M₁ &times; V₁ = M₂ &times; V₂</code></p>
        </div>
        <div class="rev-block">
          <h4>📌 Indicators & pH Ranges:</h4>
          <p>Phenolphthalein: Colorless (pH < 8.2) &rarr; Pale Pink (pH 8.2 - 10.0).</p>
        </div>
      `
    }
  },

  smelting: {
    id: 'smelting',
    name: 'Blast Furnace Smelting Lab',
    subtitle: 'Extract molten iron from Hematite ore (Fe₂O₃) using coke reduction, limestone flux, and thermal regulation.',
    xpReward: 60,
    goldReward: 20,
    concept: {
      title: 'Pyrometallurgy & Blast Furnace Iron Extraction',
      subtitle: 'Understand carbon reduction, slag formation, temperature zones, and molten metal tapping.',
      cards: {
        principle: {
          tag: 'Chemical Principle',
          heading: 'Carbothermic Reduction & Slag Formation',
          desc: 'Hematite ore (Fe₂O₃) is reduced to molten metallic iron by Carbon Monoxide (CO). Limestone (CaCO₃) decomposes to CaO and reacts with silica impurity (SiO₂) to form molten slag (CaSiO₃).',
          formula: 'Fe₂O₃ + 3CO → 2Fe(l) + 3CO₂   |   CaO + SiO₂ → CaSiO₃ (Slag)',
          modalDetails: `
            <h4>1. Chemical Reaction Zones in Blast Furnace:</h4>
            <ul>
              <li><strong>Combustion Zone (1800°C - 2000°C):</strong> Coke burns in hot air blast: <code>C + O₂ → CO₂ + Heat</code>.</li>
              <li><strong>Reduction Zone (500°C - 900°C):</strong> CO reduces hematite: <code>Fe₂O₃ + 3CO → 2Fe + 3CO₂</code>.</li>
              <li><strong>Slag Formation Zone (1000°C - 1200°C):</strong> <code>CaCO₃ → CaO + CO₂</code>, then <code>CaO + SiO₂ → CaSiO₃ (Slag)</code>.</li>
            </ul>
            <br>
            <h4>2. Temperature Regulation:</h4>
            <p><strong>Underheating (< 1100°C):</strong> Iron and slag will solidify inside the hearth, causing fatal furnace freezing.</p>
            <p><strong>Overheating (> 1800°C):</strong> Damaging refractory brick lining and vaporizing volatile metals.</p>
            <p><strong>Optimal Hearth Operating Temp:</strong> <strong>1400°C – 1550°C</strong> for pure molten iron separation.</p>
          `
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Required Metallurgy Apparatus',
          desc: 'Blast Furnace Crucible Rig, Optical Pyrometer (High-Temp Sensor), Tuyere Air Blast Blower, Foundry Tapping Ladle.',
          tags: ['Blast Furnace Tower', 'Digital Pyrometer', 'Tuyere Blast Nozzle', 'Tapping Ladle'],
          modalDetails: `
            <h4>Apparatus Functions:</h4>
            <ul>
              <li><strong>Blast Furnace:</strong> Refractory-lined steel stack where ore reduction and melting occur continuously.</li>
              <li><strong>Optical Pyrometer:</strong> Measures extreme internal hearth temperatures (0°C - 2000°C).</li>
              <li><strong>Tuyere Nozzles:</strong> Injects pre-heated air/oxygen blasts to ignite the metallurgical coke.</li>
              <li><strong>Tapping Ladle:</strong> Collects dense molten iron (~1500°C) flowing from the bottom taphole.</li>
            </ul>
          `
        },
        solutions: {
          tag: 'Raw Materials & Ores',
          heading: 'Required Raw Charge',
          desc: 'Hematite Ore (Fe₂O₃), Metallurgical Coke (C fuel & reducing agent), and Limestone Flux (CaCO₃).',
          tags: ['Hematite (Fe₂O₃)', 'Metallurgical Coke (C)', 'Limestone Flux (CaCO₃)'],
          modalDetails: `
            <h4>Raw Charge Components:</h4>
            <ul>
              <li><strong>Hematite (Fe₂O₃):</strong> Primary iron oxide ore to be reduced.</li>
              <li><strong>Coke (C):</strong> 90% Carbon fuel producing CO reducing gas and intense heat.</li>
              <li><strong>Limestone (CaCO₃):</strong> Basic flux that binds acidic silica sand impurities (SiO₂) into molten calcium silicate slag.</li>
            </ul>
          `
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Smelting Protocol',
          desc: '1. Charge ore, coke & flux into hopper. 2. Ignite tuyere hot air. 3. Regulate temp to 1400°C–1500°C. 4. Tap molten iron & slag.',
          modalDetails: `
            <h4>Operational Steps:</h4>
            <ol>
              <li>Load raw charge (Fe₂O₃ + Coke + CaCO₃) through the double-bell top hopper.</li>
              <li>Engage the tuyere hot air blast to initiate combustion.</li>
              <li>Adjust temperature slider to reach optimal smelting zone (1400°C – 1500°C).</li>
              <li>Open the bottom taphole: observe blazing white-hot molten iron flowing into the ladle mold while lighter slag floats and taps separately!</li>
            </ol>
          `
        }
      }
    },
    apparatusPool: [
      { id: 'furnace_rig', name: 'Blast Furnace Stack', spec: 'Refractory Lined Steel Tower', required: true },
      { id: 'pyrometer', name: 'Digital Pyrometer', spec: 'Optical 0–2000°C Sensor', required: true },
      { id: 'tuyere_blower', name: 'Tuyere Blast Pipe', spec: 'Copper Water-Cooled Nozzle', required: true },
      { id: 'ladle_mold', name: 'Foundry Tapping Ladle', spec: 'Refractory Ingot Mold', required: true },
      { id: 'burette', name: 'Burette', spec: '50 mL Glass', required: false, wrongDesc: "A Burette is for liquid titration and will shatter in a blast furnace!" },
      { id: 'beaker', name: 'Griffin Beaker', spec: '100 mL Glass', required: false, wrongDesc: "Glass beakers cannot withstand pyrometallurgical furnace temperatures." },
      { id: 'calorimeter', name: 'Calorimeter Cup', spec: 'Styrofoam Vessel', required: false, wrongDesc: "Styrofoam melts immediately near smelting heat!" },
      { id: 'platinum_loop', name: 'Platinum Loop', spec: 'Thin Wire', required: false, wrongDesc: "A wire loop is for flame tests, not industrial ore smelting." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hematite_ore', name: 'Hematite Ore', formula: 'Fe₂O₃', conc: 'Dense Ore Pellets', hazard: 'Mineral 🪨', required: true, shelf: 'A' },
        { id: 'metallurgical_coke', name: 'Metallurgical Coke', formula: 'C', conc: '90% Carbon Fuel', hazard: 'Fuel 🔥', required: true, shelf: 'A' },
        { id: 'sodium_metal', name: 'Sodium Metal', formula: 'Na', conc: 'Pure Metal', hazard: 'Explosive 💥', required: false, shelf: 'A', wrongDesc: "Sodium metal reacts violently and explosively with oxygen and moisture!" },
        { id: 'sulfuric_acid_conc', name: 'Sulfuric Acid', formula: 'H₂SO₄', conc: '18.0 M', hazard: 'Corrosive ⚠️', required: false, shelf: 'A', wrongDesc: "Sulfuric acid is not a raw material for blast furnace smelting." }
      ],
      shelfB: [
        { id: 'limestone_flux', name: 'Limestone Flux', formula: 'CaCO₃', conc: 'Crushed Calcite', hazard: 'Flux 🪨', required: true, shelf: 'B' },
        { id: 'ethanol_smelt', name: 'Ethanol', formula: 'C₂H₅OH', conc: '95%', hazard: 'Flammable 🔥', required: false, shelf: 'B', wrongDesc: "Ethanol is an organic solvent not used in pyrometallurgy." },
        { id: 'copper_sulfate_smelt', name: 'Copper Sulfate', formula: 'CuSO₄', conc: 'Hydrated Salt', hazard: 'Sample 🧫', required: false, shelf: 'B', wrongDesc: "We are smelting iron from hematite, not copper salts." },
        { id: 'acetone_smelt', name: 'Acetone', formula: 'C₃H₆O', conc: 'Pure', hazard: 'Volatile 🔥', required: false, shelf: 'B', wrongDesc: "Acetone is an organic cleaning solvent." }
      ]
    },
    revision: {
      title: 'Blast Furnace Smelting & Metallurgy Summary',
      content: `
        <div class="rev-block">
          <h4>📌 Core Reactions in Blast Furnace:</h4>
          <p>1. Combustion: <code>C + O₂ &rarr; CO₂</code> & <code>CO₂ + C &rarr; 2CO</code></p>
          <p>2. Reduction: <code>Fe₂O₃ + 3CO &rarr; 2Fe(l) + 3CO₂</code></p>
          <p>3. Slag Fluxing: <code>CaCO₃ &rarr; CaO + CO₂</code>, <code>CaO + SiO₂ &rarr; CaSiO₃ (Molten Slag)</code></p>
        </div>
        <div class="rev-block">
          <h4>📌 Key Temperature Operating Windows:</h4>
          <ul>
            <li><strong>Optimal Smelting Zone:</strong> 1400°C – 1550°C (Liquefies iron & allows slag to float).</li>
            <li><strong>Density Separation:</strong> Molten slag floats above molten iron.</li>
          </ul>
        </div>
      `
    }
  },

  calorimetry: {
    id: 'calorimetry',
    name: 'Calorimetry & Heat of Reaction',
    subtitle: 'Measure the enthalpy of neutralization (ΔH) using an insulated polystyrene calorimeter.',
    xpReward: 60,
    goldReward: 20,
    concept: {
      title: 'Thermochemistry & Enthalpy of Neutralization',
      subtitle: 'Measure temperature rise (ΔT) and compute heat evolved: q = mcΔT.',
      cards: {
        principle: {
          tag: 'Chemical Principle',
          heading: 'Exothermic Neutralization & Enthalpy',
          desc: 'When strong acids and strong bases neutralize, energy is released into the solution, increasing temperature. q = m · c · ΔT.',
          formula: 'q = m · c · ΔT   |   ΔH_neut ≈ -57.1 kJ/mol',
          modalDetails: `<p>Heat evolved is absorbed by the aqueous solution: q = -(m · c · ΔT).</p>`
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Calorimeter & Instruments',
          desc: 'Styrofoam calorimeter cup with lid, high-precision digital thermometer, magnetic stirrer, and graduated cylinders.',
          tags: ['Polystyrene Calorimeter', 'Digital Thermometer', 'Stirrer Rod', 'Graduated Cylinder'],
          modalDetails: `<p>Insulated calorimeter prevents heat loss to surroundings.</p>`
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Solutions',
          desc: '1.0 M Hydrochloric Acid (50 mL), 1.0 M Sodium Hydroxide (50 mL), and Distilled Water.',
          tags: ['1.0 M HCl (50 mL)', '1.0 M NaOH (50 mL)', 'Distilled H₂O'],
          modalDetails: `<p>Mixing 50 mL 1.0 M HCl + 50 mL 1.0 M NaOH.</p>`
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Experimental Protocol',
          desc: '1. Measure initial T₁. 2. Mix 50 mL HCl + 50 mL NaOH. 3. Close lid & stir. 4. Record peak T₂.',
          modalDetails: `<p>Record temperature every 5 seconds until peak.</p>`
        }
      }
    },
    apparatusPool: [
      { id: 'calorimeter', name: 'Calorimeter Vessel', spec: 'Double-Walled Insulated Cup', required: true },
      { id: 'thermometer', name: 'Digital Thermocouple', spec: '±0.1°C Precision Probe', required: true },
      { id: 'stand_clamp', name: 'Lab Clamp Stand', spec: 'Stainless Support Rod', required: true },
      { id: 'beaker', name: 'Measuring Beaker', spec: '100 mL Glass', required: true },
      { id: 'furnace_rig', name: 'Blast Furnace', spec: 'Smelting Stack', required: false, wrongDesc: "Blast furnaces generate external heat; calorimetry measures reaction heat!" },
      { id: 'bunsen_burner', name: 'Bunsen Burner', spec: 'Gas Burner', required: false, wrongDesc: "External flame will ruin precise enthalpy measurements!" },
      { id: 'cobalt_glass', name: 'Cobalt Glass', spec: 'Optical Filter', required: false, wrongDesc: "Cobalt glass is for flame tests, not calorimetry." },
      { id: 'pipette', name: 'Pipette', spec: 'Small 10 mL Pipette', required: false, wrongDesc: "We need 50 mL beakers/cylinders for calorimetry volumes." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_1m', name: 'Hydrochloric Acid', formula: 'HCl', conc: '1.000 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'distilled_water_cal', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: true, shelf: 'A' },
        { id: 'hno3_conc', name: 'Nitric Acid', formula: 'HNO₃', conc: '2.0 M', hazard: 'Oxidizer 🔥', required: false, shelf: 'A', wrongDesc: "Nitric acid has unwanted oxidation side reactions; use 1.0 M HCl." },
        { id: 'acetone', name: 'Acetone', formula: 'C₃H₆O', conc: 'Pure', hazard: 'Flammable 🔥', required: false, shelf: 'A', wrongDesc: "Acetone is not used in aqueous calorimetry." }
      ],
      shelfB: [
        { id: 'naoh_1m', name: 'Sodium Hydroxide', formula: 'NaOH', conc: '1.000 M', hazard: 'Caustic ⚠️', required: true, shelf: 'B' },
        { id: 'ammonia_sol', name: 'Ammonium Hydroxide', formula: 'NH₄OH', conc: '1.0 M', hazard: 'Weak Base ⚠️', required: false, shelf: 'B', wrongDesc: "NH₄OH is a weak base with incomplete ionization." },
        { id: 'copper_sulfate', name: 'Copper Sulfate', formula: 'CuSO₄', conc: '0.5 M', hazard: 'Irritant ⚠️', required: false, shelf: 'B', wrongDesc: "Copper sulfate is not required for neutralization heat." },
        { id: 'glycerol', name: 'Glycerol', formula: 'C₃H₈O₃', conc: 'Pure', hazard: 'Safe 💧', required: false, shelf: 'B', wrongDesc: "Glycerol is not used in this experiment." }
      ]
    },
    revision: {
      title: 'Calorimetry Summary',
      content: `<div class="rev-block"><p>q = mcΔT = 100g × 4.184 × 6.8 = 2.85 kJ</p></div>`
    }
  },

  flametest: {
    id: 'flametest',
    name: 'Flame Test & Salt Analysis',
    subtitle: 'Identify metallic cations by their characteristic atomic emission spectra in a Bunsen flame.',
    xpReward: 60,
    goldReward: 20,
    concept: {
      title: 'Atomic Emission Spectroscopy & Flame Tests',
      subtitle: 'Thermal excitation of electrons produces characteristic light wavelengths.',
      cards: {
        principle: {
          tag: 'Chemical Principle',
          heading: 'Electronic Excitation & Emission',
          desc: 'Thermal energy promotes electrons to excited states. Returning to ground state releases photons of specific wavelength (E = hc/λ).',
          formula: 'E = h · ν = (h · c) / λ   [Photon Emission]',
          modalDetails: `<p>Discrete wavelengths emitted upon electron relaxation.</p>`
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Required Apparatus',
          desc: 'Bunsen Burner with adjustable air-collar, Platinum/Nichrome wire loop, Watch Glasses, and Cobalt Blue Glass.',
          tags: ['Bunsen Burner', 'Platinum Wire Loop', 'Watch Glass (x3)', 'Cobalt Blue Glass'],
          modalDetails: `<p>Inert platinum loop and high-temperature non-luminous flame.</p>`
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Reagents & Salts',
          desc: 'Concentrated Hydrochloric Acid (HCl for loop cleaning), Sodium Chloride (NaCl), Copper Sulfate (CuSO₄), Strontium Chloride (SrCl₂).',
          tags: ['Conc. HCl (Cleaning)', 'NaCl (Sodium Salt)', 'CuSO₄ (Copper Salt)', 'SrCl₂ (Strontium Salt)'],
          modalDetails: `<p>Conc HCl forms volatile metal chlorides.</p>`
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Execution Protocol',
          desc: '1. Clean loop in conc. HCl. 2. Dip in sample salt. 3. Place in hottest blue cone of flame. 4. Observe color.',
          modalDetails: `<p>Na⁺: Golden Yellow, Sr²⁺: Crimson, Cu²⁺: Turquoise.</p>`
        }
      }
    },
    apparatusPool: [
      { id: 'bunsen_burner', name: 'Bunsen Burner', spec: 'Adjustable Air Collar', required: true },
      { id: 'platinum_loop', name: 'Platinum Loop', spec: 'Nichrome/Pt Inert Wire', required: true },
      { id: 'watch_glass', name: 'Watch Glasses', spec: 'Borosilicate Concave Lens', required: true },
      { id: 'cobalt_glass', name: 'Cobalt Blue Glass', spec: 'Optical Spectral Filter Plate', required: true },
      { id: 'burette', name: 'Burette', spec: '50 mL Glass', required: false, wrongDesc: "Burettes are for liquid titration, not flame tests!" },
      { id: 'calorimeter', name: 'Calorimeter', spec: 'Insulated Vessel', required: false, wrongDesc: "Calorimeters are for measuring heat of reaction." },
      { id: 'stand_clamp', name: 'Retort Stand', spec: 'Heavy Base', required: false, wrongDesc: "Flame tests use handheld wire loops over the burner." },
      { id: 'ladle_mold', name: 'Tapping Ladle', spec: 'Foundry Ladle', required: false, wrongDesc: "Ladles are for molten metallurgy, not qualitative flame tests." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'conc_hcl_flame', name: 'Hydrochloric Acid (Conc)', formula: 'HCl', conc: '12.0 M', hazard: 'Volatilizer ⚠️', required: true, shelf: 'A' },
        { id: 'nacl_salt', name: 'Sodium Chloride', formula: 'NaCl', conc: 'AR Powder', hazard: 'Salt 🧂', required: true, shelf: 'A' },
        { id: 'srcl2_salt', name: 'Strontium Chloride', formula: 'SrCl₂', conc: 'Pure Salt', hazard: 'Sample 🧫', required: true, shelf: 'A' },
        { id: 'lead_nitrate', name: 'Lead Nitrate', formula: 'Pb(NO₃)₂', conc: 'Toxic Solid', hazard: 'Toxic ☠️', required: false, shelf: 'A', wrongDesc: "Lead produces toxic heavy metal fumes when burned!" }
      ],
      shelfB: [
        { id: 'cuso4_salt', name: 'Copper(II) Sulfate', formula: 'CuSO₄', conc: 'Anhydrous', hazard: 'Sample 🧫', required: true, shelf: 'B' },
        { id: 'kcl_salt', name: 'Potassium Chloride', formula: 'KCl', conc: 'Salt', hazard: 'Sample 🧫', required: false, shelf: 'B', wrongDesc: "We already have sufficient test samples." },
        { id: 'hexane', name: 'n-Hexane', formula: 'C₆H₁₄', conc: 'Solvent', hazard: 'Flammable 🔥', required: false, shelf: 'B', wrongDesc: "Hexane creates an uncontrollable flash fire near open burners!" },
        { id: 'silver_nitrate', name: 'Silver Nitrate', formula: 'AgNO₃', conc: '0.1 M', hazard: 'Staining ⚠️', required: false, shelf: 'B', wrongDesc: "Silver nitrate is for precipitation tests." }
      ]
    },
    revision: {
      title: 'Flame Test Summary',
      content: `<div class="rev-block"><p>Na⁺: Yellow (589 nm), Sr²⁺: Crimson (650 nm), Cu²⁺: Green-Blue (510 nm).</p></div>`
    }
  }
};

// ============================================================================
// 4. LAB STATE MANAGER
// ============================================================================
class LabStateManager {
  constructor() {
    this.currentModuleId = 'titration';
    this.currentStage = 1;
    this.firstAttemptScore = 100;
    this.stage2Mistakes = 0;
    this.stage3Mistakes = 0;
    this.stage4Mistakes = 0;

    this.selectedApparatus = new Set();
    this.selectedCupboard = new Set();

    this.expState = {};
    this.initExpState();
  }

  get moduleData() {
    return LAB_MODULES[this.currentModuleId];
  }

  switchModule(modId) {
    if (!LAB_MODULES[modId]) return;
    this.currentModuleId = modId;
    this.currentStage = 1;
    this.resetMistakes();
    this.selectedApparatus.clear();
    this.selectedCupboard.clear();
    this.initExpState();
  }

  resetMistakes() {
    this.stage2Mistakes = 0;
    this.stage3Mistakes = 0;
    this.stage4Mistakes = 0;
    this.firstAttemptScore = 100;
  }

  calculateFinalScore() {
    const totalMistakes = this.stage2Mistakes + this.stage3Mistakes + this.stage4Mistakes;
    if (totalMistakes === 0) return 100;
    if (totalMistakes === 1) return 92;
    if (totalMistakes === 2) return 85;
    if (totalMistakes === 3) return 75;
    return Math.max(60, 100 - (totalMistakes * 10));
  }

  initExpState() {
    if (this.currentModuleId === 'titration') {
      this.expState = {
        buretteVolume: 0.0,
        flaskVolume: 10.0,
        hasIndicator: false,
        stopcockMode: 0, // 0 = OFF, 1 = SLOW DRIP, 2 = FAST FLOW
        endpointReached: false
      };
    } else if (this.currentModuleId === 'smelting') {
      this.expState = {
        chargedOre: false,
        chargedCoke: false,
        chargedFlux: false,
        tuyereBlastOn: false,
        temperature: 600,
        reactionRate: 0,
        slagTapped: false,
        ironTapped: false
      };
    } else if (this.currentModuleId === 'calorimetry') {
      this.expState = {
        acidAdded: false,
        baseAdded: false,
        lidClosed: false,
        stirring: false,
        currentTemp: 22.0
      };
    } else if (this.currentModuleId === 'flametest') {
      this.expState = {
        burnerOn: true,
        airVentOpen: true,
        currentSample: null
      };
    }
  }
}

const state = new LabStateManager();

// ============================================================================
// 5. DOM CONTROLLER & RENDERERS
// ============================================================================
document.addEventListener('DOMContentLoaded', () => {
  initUrlParams();
  bindGlobalEvents();
  renderCurrentModule();
});

function initUrlParams() {
  const params = new URLSearchParams(window.location.search);
  const modParam = params.get('module');
  const stageParam = params.get('stage');

  if (modParam && LAB_MODULES[modParam]) {
    state.currentModuleId = modParam;
  }
  if (stageParam) {
    const s = parseInt(stageParam, 10);
    if (s >= 1 && s <= 5) {
      state.currentStage = s;
    }
  }
}

function bindGlobalEvents() {
  const soundBtn = document.getElementById('btnSoundToggle');
  soundBtn.addEventListener('click', () => {
    labSound.enabled = !labSound.enabled;
    document.getElementById('soundIcon').textContent = labSound.enabled ? '🔊' : '🔇';
    labSound.playClick();
  });

  document.querySelectorAll('.module-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      const modId = tab.dataset.module;
      if (modId !== state.currentModuleId) {
        labSound.playClick();
        state.switchModule(modId);
        renderCurrentModule();
      }
    });
  });

  document.querySelectorAll('.step-pill').forEach(pill => {
    pill.addEventListener('click', () => {
      const targetStage = parseInt(pill.dataset.stage, 10);
      if (targetStage <= state.currentStage) {
        labSound.playClick();
        goToStage(targetStage);
      }
    });
  });

  document.getElementById('btnFinishConcept').addEventListener('click', () => {
    labSound.playSuccess();
    openHurrahModal();
  });

  document.getElementById('btnHurrahGo').addEventListener('click', () => {
    labSound.playClick();
    closeHurrahModal();
    goToStage(2);
  });

  document.getElementById('btnProceedStage2').addEventListener('click', () => {
    labSound.playClick();
    goToStage(3);
  });

  document.getElementById('btnProceedStage3').addEventListener('click', () => {
    labSound.playClick();
    goToStage(4);
  });

  document.getElementById('btnFinishExperiment').addEventListener('click', () => {
    labSound.playFanfare();
    goToStage(5);
  });

  document.getElementById('btnOpenRevisionModal').addEventListener('click', () => {
    labSound.playClick();
    openRevisionModal();
  });

  document.getElementById('btnRestartModule').addEventListener('click', () => {
    labSound.playClick();
    state.switchModule(state.currentModuleId);
    renderCurrentModule();
  });

  document.getElementById('btnCompleteModuleQuest').addEventListener('click', () => {
    labSound.playFanfare();
    sendQuestlyEvent('lab_complete', {
      moduleId: state.currentModuleId,
      score: state.calculateFinalScore(),
      stars: state.calculateFinalScore() >= 85 ? 3 : 2
    });
    alert('🎉 Congratulations! Lab completed and saved in Questly profile!');
  });

  document.getElementById('btnBackToModules').addEventListener('click', () => {
    labSound.playClick();
    sendQuestlyEvent('navigate_back', {});
  });
}

// ============================================================================
// 6. STAGE NAVIGATION & RENDERING
// ============================================================================
function goToStage(stageNum) {
  state.currentStage = stageNum;
  document.querySelectorAll('.stage-view').forEach(v => v.classList.remove('active'));
  const targetView = document.getElementById(`stage${stageNum}`);
  if (targetView) targetView.classList.add('active');

  document.querySelectorAll('.step-pill').forEach(p => {
    const s = parseInt(p.dataset.stage, 10);
    p.classList.remove('active', 'completed');
    if (s === stageNum) p.classList.add('active');
    else if (s < stageNum) p.classList.add('completed');
  });

  sendQuestlyEvent('stage_complete', {
    stage: stageNum - 1,
    moduleId: state.currentModuleId
  });

  if (stageNum === 2) renderStage2();
  else if (stageNum === 3) renderStage3();
  else if (stageNum === 4) renderStage4();
  else if (stageNum === 5) renderStage5();
}

function renderCurrentModule() {
  const mod = state.moduleData;

  document.getElementById('currentModuleName').textContent = mod.name;
  document.querySelectorAll('.module-tab').forEach(tab => {
    tab.classList.toggle('active', tab.dataset.module === state.currentModuleId);
  });

  document.getElementById('stage1Title').textContent = mod.concept.title;
  document.getElementById('stage1Subtitle').textContent = mod.concept.subtitle;
  
  document.getElementById('principleHeading').textContent = mod.concept.cards.principle.heading;
  document.getElementById('principleDesc').textContent = mod.concept.cards.principle.desc;
  document.getElementById('principleFormula').innerHTML = `<code>${mod.concept.cards.principle.formula}</code>`;

  document.getElementById('apparatusHeading').textContent = mod.concept.cards.apparatus.heading;
  document.getElementById('apparatusSummary').textContent = mod.concept.cards.apparatus.desc;
  const appTagsContainer = document.getElementById('apparatusTags');
  appTagsContainer.innerHTML = '';
  mod.concept.cards.apparatus.tags.forEach(t => {
    const span = document.createElement('span');
    span.className = 'mini-tag';
    span.textContent = t;
    appTagsContainer.appendChild(span);
  });

  document.getElementById('solutionsHeading').textContent = mod.concept.cards.solutions.heading;
  document.getElementById('solutionsSummary').textContent = mod.concept.cards.solutions.desc;
  const solTagsContainer = document.getElementById('solutionsTags');
  solTagsContainer.innerHTML = '';
  mod.concept.cards.solutions.tags.forEach(t => {
    const span = document.createElement('span');
    span.className = `mini-tag ${state.currentModuleId === 'smelting' ? 'mineral' : 'reagent'}`;
    span.textContent = t;
    solTagsContainer.appendChild(span);
  });

  document.getElementById('procedureHeading').textContent = mod.concept.cards.procedure.heading;
  document.getElementById('procedureSummary').textContent = mod.concept.cards.procedure.desc;

  goToStage(state.currentStage);
}

// ============================================================================
// 7. STAGE 2: REALISTIC APPARATUS SELECTION
// ============================================================================
function renderStage2() {
  const mod = state.moduleData;
  const grid = document.getElementById('apparatusGrid');
  const checklist = document.getElementById('apparatusTargetPills');
  const tracker = document.getElementById('apparatusTracker');
  const proceedBtn = document.getElementById('btnProceedStage2');

  grid.innerHTML = '';
  checklist.innerHTML = '';

  const requiredItems = mod.apparatusPool.filter(a => a.required);
  tracker.textContent = `${state.selectedApparatus.size} / ${requiredItems.length}`;
  proceedBtn.disabled = state.selectedApparatus.size < requiredItems.length;

  requiredItems.forEach(item => {
    const pill = document.createElement('div');
    const isFound = state.selectedApparatus.has(item.id);
    pill.className = `target-pill ${isFound ? 'found' : ''}`;
    pill.id = `pill-app-${item.id}`;
    pill.innerHTML = `<span>${isFound ? '✔' : '○'}</span><span>${item.name}</span>`;
    checklist.appendChild(pill);
  });

  mod.apparatusPool.forEach(item => {
    const card = document.createElement('div');
    const isSelected = state.selectedApparatus.has(item.id);
    card.className = `apparatus-card ${isSelected ? 'selected' : ''}`;
    card.id = `card-app-${item.id}`;

    card.innerHTML = `
      <div class="app-icon real-svg-container">
        ${getRealisticApparatusSVG(item.id)}
      </div>
      <div class="app-name">${item.name}</div>
      <div class="app-spec">${item.spec}</div>
      <div class="wrong-overlay">
        <div class="cross-icon">❌</div>
        <div class="wrong-text">Not Required!</div>
      </div>
    `;

    card.addEventListener('click', () => handleApparatusClick(item, card));
    grid.appendChild(card);
  });
}

function handleApparatusClick(item, cardEl) {
  const mod = state.moduleData;
  const feedback = document.getElementById('apparatusFeedback');
  const tracker = document.getElementById('apparatusTracker');
  const proceedBtn = document.getElementById('btnProceedStage2');
  const requiredCount = mod.apparatusPool.filter(a => a.required).length;

  if (item.required) {
    if (state.selectedApparatus.has(item.id)) return;

    labSound.playSuccess();
    state.selectedApparatus.add(item.id);
    cardEl.classList.add('selected');
    cardEl.classList.remove('wrong');

    const pill = document.getElementById(`pill-app-${item.id}`);
    if (pill) {
      pill.className = 'target-pill found';
      pill.innerHTML = `<span>✔</span><span>${item.name}</span>`;
    }

    feedback.className = 'live-feedback-box success';
    feedback.innerHTML = `<span class="fb-icon">✔</span><span class="fb-text">Correct! Added <strong>${item.name}</strong> to workbench.</span>`;
    tracker.textContent = `${state.selectedApparatus.size} / ${requiredCount}`;

    if (state.selectedApparatus.size === requiredCount) {
      labSound.playFanfare();
      proceedBtn.disabled = false;
      feedback.innerHTML = `<span class="fb-icon">🎉</span><span class="fb-text">All required equipment gathered! Click Proceed to Storage.</span>`;
    }
  } else {
    labSound.playError();
    state.stage2Mistakes++;
    cardEl.classList.add('wrong');
    
    showErrorToast(`❌ Incorrect: ${item.name}`, item.wrongDesc || `Not required for this stage.`);

    feedback.className = 'live-feedback-box error';
    feedback.innerHTML = `<span class="fb-icon">❌</span><span class="fb-text"><strong>${item.name}:</strong> ${item.wrongDesc || 'Not required for this experiment.'}</span>`;

    setTimeout(() => {
      cardEl.classList.remove('wrong');
    }, 1800);
  }
  updateHeaderScore();
}

// ============================================================================
// 8. STAGE 3: REALISTIC CHEMICAL STORAGE CUPBOARD
// ============================================================================
function renderStage3() {
  const mod = state.moduleData;
  const rowA = document.getElementById('shelfRowA');
  const rowB = document.getElementById('shelfRowB');
  const checklist = document.getElementById('cupboardTargetPills');
  const tracker = document.getElementById('cupboardTracker');
  const proceedBtn = document.getElementById('btnProceedStage3');

  rowA.innerHTML = '';
  rowB.innerHTML = '';
  checklist.innerHTML = '';

  const allReagents = [...mod.cupboardPool.shelfA, ...mod.cupboardPool.shelfB];
  const requiredReagents = allReagents.filter(r => r.required);
  tracker.textContent = `${state.selectedCupboard.size} / ${requiredReagents.length}`;
  proceedBtn.disabled = state.selectedCupboard.size < requiredReagents.length;

  requiredReagents.forEach(item => {
    const pill = document.createElement('div');
    const isFound = state.selectedCupboard.has(item.id);
    pill.className = `target-pill ${isFound ? 'found' : ''}`;
    pill.id = `pill-cup-${item.id}`;
    pill.innerHTML = `<span>${isFound ? '✔' : '○'}</span><span>${item.formula} (${item.name})</span>`;
    checklist.appendChild(pill);
  });

  mod.cupboardPool.shelfA.forEach(item => rowA.appendChild(createBottleElement(item)));
  mod.cupboardPool.shelfB.forEach(item => rowB.appendChild(createBottleElement(item)));
}

function createBottleElement(item) {
  const bottle = document.createElement('div');
  const isPicked = state.selectedCupboard.has(item.id);
  bottle.className = `chemical-bottle real-bottle-card ${isPicked ? 'picked' : ''}`;
  bottle.id = `bottle-${item.id}`;

  bottle.innerHTML = `
    ${getRealisticBottleHTML(item)}
    <div class="wrong-overlay">
      <div class="cross-icon">❌</div>
      <div class="wrong-text">Wrong Material!</div>
    </div>
  `;

  bottle.addEventListener('click', () => handleBottleClick(item, bottle));
  return bottle;
}

function handleBottleClick(item, bottleEl) {
  const mod = state.moduleData;
  const feedback = document.getElementById('cupboardFeedback');
  const tracker = document.getElementById('cupboardTracker');
  const proceedBtn = document.getElementById('btnProceedStage3');
  const allReagents = [...mod.cupboardPool.shelfA, ...mod.cupboardPool.shelfB];
  const requiredCount = allReagents.filter(r => r.required).length;

  if (item.required) {
    if (state.selectedCupboard.has(item.id)) return;

    labSound.playSuccess();
    state.selectedCupboard.add(item.id);
    bottleEl.classList.add('picked');
    bottleEl.classList.remove('wrong');

    const pill = document.getElementById(`pill-cup-${item.id}`);
    if (pill) {
      pill.className = 'target-pill found';
      pill.innerHTML = `<span>✔</span><span>${item.formula} (${item.name})</span>`;
    }

    feedback.className = 'live-feedback-box success';
    feedback.innerHTML = `<span class="fb-icon">✔</span><span class="fb-text">Loaded <strong>${item.name} (${item.formula})</strong> into charge carrier!</span>`;
    tracker.textContent = `${state.selectedCupboard.size} / ${requiredCount}`;

    if (state.selectedCupboard.size === requiredCount) {
      labSound.playFanfare();
      proceedBtn.disabled = false;
      feedback.innerHTML = `<span class="fb-icon">🎉</span><span class="fb-text">All raw materials collected! Proceed to Experiment Workbench.</span>`;
    }
  } else {
    labSound.playError();
    state.stage3Mistakes++;
    bottleEl.classList.add('wrong');

    showErrorToast(`❌ Wrong Material: ${item.name}`, item.wrongDesc || `Do not select this item.`);

    feedback.className = 'live-feedback-box error';
    feedback.innerHTML = `<span class="fb-icon">❌</span><span class="fb-text"><strong>${item.name}:</strong> ${item.wrongDesc}</span>`;

    setTimeout(() => {
      bottleEl.classList.remove('wrong');
    }, 1800);
  }
  updateHeaderScore();
}

// ============================================================================
// 9. STAGE 4: DIRECT HANDS-ON WORKBENCH SIMULATION
// ============================================================================
function renderStage4() {
  const mod = state.moduleData;
  document.getElementById('expTitle').textContent = `${mod.name} Simulation`;
  document.getElementById('expSubtitle').textContent = "Interact directly with the lab equipment on the workbench desk below!";

  const workbenchArea = document.getElementById('simWorkbenchArea');
  workbenchArea.innerHTML = '';

  if (state.currentModuleId === 'titration') {
    renderDirectTitrationWorkbench(workbenchArea);
  } else if (state.currentModuleId === 'smelting') {
    renderDirectSmeltingWorkbench(workbenchArea);
  } else if (state.currentModuleId === 'calorimetry') {
    renderDirectCalorimetryWorkbench(workbenchArea);
  } else if (state.currentModuleId === 'flametest') {
    renderDirectFlameTestWorkbench(workbenchArea);
  }
}

// ----------------------------------------------------------------------------
// DIRECT INTERACTIVE TITRATION WORKBENCH
// ----------------------------------------------------------------------------
function renderDirectTitrationWorkbench(container) {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Burette Reading</span>
      <span class="metric-value" id="titrBuretteVal">0.0 mL</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Flask pH</span>
      <span class="metric-value" id="titrPhVal">1.0</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Color Indicator</span>
      <span class="metric-value" id="titrColorVal" style="color: #64748B;">Colorless</span>
    </div>
  `;

  container.innerHTML = `
    <!-- Left Main Workbench -->
    <div class="workbench-viewport">
      <div class="titration-rig">
        <div class="stand-post"></div>
        <div class="stand-base"></div>
        <div class="white-tile">
          <div id="endpointSealBadge" style="display: none; font-family: var(--font-display); font-size: 9px; font-weight: 900; color: #065F46; background: #D1FAE5; padding: 2px 6px; border-radius: 4px; border: 1px solid #10B981; cursor: pointer;">
            ✨ CLICK TO CONFIRM ENDPOINT
          </div>
        </div>

        <div class="burette-assembly">
          <div class="burette-liquid" id="buretteLiquidBar"></div>
          <div class="burette-scale">
            <div class="scale-mark"></div><div class="scale-mark"></div><div class="scale-mark"></div><div class="scale-mark"></div><div class="scale-mark"></div>
          </div>
          <!-- Clickable Stopcock Valve on Burette -->
          <div class="stopcock-valve" id="interactiveStopcock" title="Click Valve to toggle flow speed!">
            OFF
          </div>
          <div class="droplet-stream" id="dropletStream"></div>
        </div>

        <!-- Clickable & Swirlable Conical Flask -->
        <div class="conical-flask-sim interactive-bench-item" id="interactiveFlask" title="Click to swirl solution!">
          <div class="flask-liquid colorless" id="flaskLiquid"></div>
        </div>
      </div>
    </div>

    <!-- Right Interactive Tools Tray -->
    <div class="workbench-tools-tray">
      <div class="panel-section-title">🧪 WORKBENCH TOOLBAR</div>

      <!-- Interactive Indicator Dropper Card -->
      <div class="direct-action-card" id="toolDropperCard">
        <div class="action-card-icon">💧</div>
        <div>
          <div class="action-card-title">Phenolphthalein Dropper</div>
          <div class="action-card-hint">Click to squeeze 2 drops into flask</div>
        </div>
      </div>

      <!-- Interactive Swirl Card -->
      <div class="direct-action-card" id="toolSwirlCard">
        <div class="action-card-icon">🌀</div>
        <div>
          <div class="action-card-title">Swirl Conical Flask</div>
          <div class="action-card-hint">Mixes analyte and titrant uniformly</div>
        </div>
      </div>

      <!-- Valve Speed Controller -->
      <div class="direct-action-card" id="toolValveCard">
        <div class="action-card-icon">🎛️</div>
        <div>
          <div class="action-card-title">Burette Stopcock (Click Valve)</div>
          <div class="action-card-hint" id="valveStatusText">Current: OFF (Closed)</div>
        </div>
      </div>
    </div>
  `;

  bindDirectTitrationEvents();
}

let directTitrTimer = null;

function bindDirectTitrationEvents() {
  const dropperCard = document.getElementById('toolDropperCard');
  const swirlCard = document.getElementById('toolSwirlCard');
  const valveCard = document.getElementById('toolValveCard');
  const valve = document.getElementById('interactiveStopcock');
  const flask = document.getElementById('interactiveFlask');
  const seal = document.getElementById('endpointSealBadge');
  const btnFinish = document.getElementById('btnFinishExperiment');

  // Add Indicator
  dropperCard.addEventListener('click', () => {
    if (state.expState.hasIndicator) return;
    labSound.playWaterDrop();
    state.expState.hasIndicator = true;
    dropperCard.classList.add('active');
    dropperCard.querySelector('.action-card-hint').textContent = '✔ Indicator added (2 drops in acid)';
    updateExpFeedback('Phenolphthalein added! Click the Burette stopcock valve to begin dropwise titration.');
  });

  // Swirl Flask
  const triggerSwirl = () => {
    labSound.playClick();
    flask.classList.add('swirl-anim');
    setTimeout(() => flask.classList.remove('swirl-anim'), 600);
  };
  swirlCard.addEventListener('click', triggerSwirl);
  flask.addEventListener('click', triggerSwirl);

  // Toggle Stopcock Valve
  const toggleValve = () => {
    if (!state.expState.hasIndicator) {
      showErrorToast('Add Indicator First!', 'Please add Phenolphthalein drops using the dropper before opening the burette.');
      return;
    }

    labSound.playClick();
    state.expState.stopcockMode = (state.expState.stopcockMode + 1) % 3;

    if (state.expState.stopcockMode === 0) {
      stopTitrationDrip();
      valve.className = 'stopcock-valve';
      valve.textContent = 'OFF';
      document.getElementById('valveStatusText').textContent = 'Current: OFF (Closed)';
    } else if (state.expState.stopcockMode === 1) {
      startTitrationDrip(0.2, 400);
      valve.className = 'stopcock-valve open';
      valve.textContent = 'SLOW';
      document.getElementById('valveStatusText').textContent = 'Current: SLOW DRIP (0.2 mL/s)';
    } else {
      startTitrationDrip(0.6, 250);
      valve.className = 'stopcock-valve open';
      valve.textContent = 'FAST';
      document.getElementById('valveStatusText').textContent = 'Current: FAST FLOW (0.6 mL/s)';
    }
  };

  valve.addEventListener('click', toggleValve);
  valveCard.addEventListener('click', toggleValve);

  // Confirm Endpoint Seal
  seal.addEventListener('click', () => {
    stopTitrationDrip();
    state.expState.stopcockMode = 0;
    valve.className = 'stopcock-valve';
    valve.textContent = 'OFF';

    const vol = state.expState.buretteVolume;
    if (vol >= 19.5 && vol <= 20.5) {
      labSound.playFanfare();
      state.expState.endpointReached = true;
      btnFinish.disabled = false;
      updateExpFeedback('🎯 PERFECT! Precise pale-pink equivalence endpoint locked in at 20.0 mL (pH 7.0)!');
      seal.style.display = 'none';
    } else {
      labSound.playError();
      state.stage4Mistakes++;
      updateExpFeedback(`⚠️ Incorrect endpoint (${vol.toFixed(1)} mL). Regulate volume to exactly 20.0 mL.`);
    }
    updateHeaderScore();
  });
}

function dispenseTitrant(amt) {
  if (state.expState.buretteVolume >= 25.0) {
    stopTitrationDrip();
    return;
  }

  labSound.playWaterDrop();
  state.expState.buretteVolume = Math.min(25.0, state.expState.buretteVolume + amt);
  const vol = state.expState.buretteVolume;

  document.getElementById('titrBuretteVal').textContent = `${vol.toFixed(1)} mL`;

  const liquidBar = document.getElementById('buretteLiquidBar');
  if (liquidBar) {
    const pct = Math.max(10, 90 - (vol / 25.0) * 80);
    liquidBar.style.height = `${pct}%`;
  }

  // Calculate pH curve based on neutralization stoichiometry
  let ph = 1.0;
  if (vol < 18.0) {
    ph = 1.0 + (vol / 18.0) * 2.2;
  } else if (vol < 19.8) {
    ph = 3.2 + ((vol - 18.0) / 1.8) * 2.8;
  } else if (vol <= 20.2) {
    ph = 7.0 + ((vol - 19.8) / 0.4) * 1.5;
  } else if (vol < 22.0) {
    ph = 8.5 + ((vol - 20.2) / 1.8) * 3.5;
  } else {
    ph = 12.0 + Math.min(1.5, (vol - 22.0) * 0.3);
  }

  document.getElementById('titrPhVal').textContent = ph.toFixed(1);

  const flaskLiquid = document.getElementById('flaskLiquid');
  const colorVal = document.getElementById('titrColorVal');
  const seal = document.getElementById('endpointSealBadge');

  if (ph < 8.2) {
    flaskLiquid.className = 'flask-liquid colorless';
    colorVal.textContent = 'Colorless (Acidic)';
    colorVal.style.color = '#64748B';
    if (seal) seal.style.display = 'none';
  } else if (ph >= 8.2 && ph <= 9.2) {
    flaskLiquid.className = 'flask-liquid pale-pink';
    colorVal.textContent = 'Faint Pale Pink (Endpoint! ✨)';
    colorVal.style.color = '#EC4899';
    if (seal) seal.style.display = 'inline-block';
    updateExpFeedback('✨ FAINT PALE PINK DETECTED! Turn OFF stopcock valve and click the green confirm seal on the tile!');
  } else {
    flaskLiquid.className = 'flask-liquid over-titrated';
    colorVal.textContent = 'Dark Magenta (Over-Titrated ⚠️)';
    colorVal.style.color = '#BE185D';
    if (seal) seal.style.display = 'none';
    updateExpFeedback('⚠️ Excess titrant added! The solution is over-titrated (Dark Magenta).');
  }
}

function startTitrationDrip(amt, ms) {
  stopTitrationDrip();
  document.getElementById('dropletStream').classList.add('dropping');
  directTitrTimer = setInterval(() => {
    dispenseTitrant(amt);
  }, ms);
}

function stopTitrationDrip() {
  if (directTitrTimer) {
    clearInterval(directTitrTimer);
    directTitrTimer = null;
  }
  const stream = document.getElementById('dropletStream');
  if (stream) stream.classList.remove('dropping');
}

// ----------------------------------------------------------------------------
// DIRECT INTERACTIVE SMELTING WORKBENCH (3D BLAST FURNACE & HEARTH)
// ----------------------------------------------------------------------------
function renderDirectSmeltingWorkbench(container) {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Hearth Pyrometer</span>
      <span class="metric-value" id="smeltTempVal" style="color: #F97316;">600 °C</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Thermal State</span>
      <span class="metric-value" id="smeltZoneVal" style="color: #EF4444;">Too Cold ❄️</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Molten Iron Yield</span>
      <span class="metric-value" id="smeltYieldVal">0.0%</span>
    </div>
  `;

  container.innerHTML = `
    <!-- Left Main 3D Blast Furnace Viewport -->
    <div class="workbench-viewport">
      <div class="blast-furnace-cutaway">
        <!-- Top Charging Hopper with Drop Badge -->
        <div class="hopper-charging-deck" id="hopperDeck" title="Click to charge raw materials!">
          <span class="hopper-label">📥 CHARGING HOPPER (TOP)</span>
        </div>

        <!-- Heavy Welded Steel Shell with Clear Readable Zone Badges -->
        <div class="furnace-outer-shell">
          <div class="furnace-fiery-core" id="furnaceFieryCore"></div>

          <!-- Upper Reduction Zone Label -->
          <div class="furnace-zone-banner top-zone">
            <span class="zone-title">REDUCTION ZONE (500°C–900°C)</span>
            <span class="zone-sub">Fe₂O₃ + 3CO → 2Fe + 3CO₂</span>
          </div>

          <!-- Middle Slag Formation Zone Label -->
          <div class="furnace-zone-banner mid-zone">
            <span class="zone-title">SLAG FORMATION (1000°C–1200°C)</span>
            <span class="zone-sub">CaO + SiO₂ → CaSiO₃ (Molten Slag)</span>
          </div>

          <!-- Bottom Melting Hearth Zone Label -->
          <div class="furnace-zone-banner hearth-zone">
            <span class="zone-title">MELTING HEARTH (1400°C–1550°C)</span>
            <span class="zone-sub">Dense Pure Molten Iron (Fe)</span>
          </div>
        </div>

        <!-- Tuyere Air Blast Pipes -->
        <div class="tuyere-pipe-assembly">
          <div class="tuyere-pipe">TUYERE L</div>
          <div class="tuyere-pipe">TUYERE R</div>
        </div>

        <!-- Molten Iron Tap Channel & Ladle Mold -->
        <div class="taphole-channel" id="tapStream"></div>
        <div class="ladle-mold-container" id="ladleMold" title="Molten Iron Ingot Ladle">
          <div class="ladle-liquid-iron" id="ladleLiquid"></div>
          <span class="ladle-label">IRON MOLD</span>
        </div>

        <!-- Slag Tap Box -->
        <div class="slag-tap-box" id="slagTapBox">SLAG RUNNER: IDLE</div>
      </div>
    </div>

    <!-- Right Interactive Direct Charge Toolbar -->
    <div class="workbench-tools-tray">
      <div class="panel-section-title">🧱 1. CHARGE PLATFORM</div>

      <!-- Ore Charge Card -->
      <div class="direct-action-card" id="cardChargeOre">
        <div class="action-card-icon">🪨</div>
        <div>
          <div class="action-card-title">Dump Hematite Ore (Fe₂O₃)</div>
          <div class="action-card-hint">Click to dump into top hopper</div>
        </div>
      </div>

      <!-- Coke Charge Card -->
      <div class="direct-action-card disabled" id="cardChargeCoke">
        <div class="action-card-icon">🔥</div>
        <div>
          <div class="action-card-title">Dump Metallurgical Coke (C)</div>
          <div class="action-card-hint">Carbon fuel & reducing agent</div>
        </div>
      </div>

      <!-- Limestone Charge Card -->
      <div class="direct-action-card disabled" id="cardChargeFlux">
        <div class="action-card-icon">🧪</div>
        <div>
          <div class="action-card-title">Dump Limestone Flux (CaCO₃)</div>
          <div class="action-card-hint">Binds silica impurity into slag</div>
        </div>
      </div>

      <div class="panel-section-title" style="margin-top: 6px;">💨 2. TUYERE BLAST & HEARTH TEMP</div>

      <!-- Tuyere Toggle -->
      <div class="direct-action-card disabled" id="cardTuyereBlast">
        <div class="action-card-icon">🌬️</div>
        <div>
          <div class="action-card-title">Engage Tuyere Air Blast</div>
          <div class="action-card-hint">Ignites coke in pre-heated air</div>
        </div>
      </div>

      <!-- Temperature Regulation Slider -->
      <div class="temp-slider-container" style="margin-top: 4px;">
        <div class="temp-slider-header">
          <span>Hearth Temperature Dial:</span>
          <strong id="sliderTempDisplay">600 °C</strong>
        </div>
        <input type="range" id="tempRangeSlider" class="temp-range-input" min="300" max="2000" step="25" value="600" disabled>
      </div>

      <!-- Taphole Drill Lever -->
      <div class="direct-action-card disabled" id="cardTapIron" style="margin-top: 4px;">
        <div class="action-card-icon">🌋</div>
        <div>
          <div class="action-card-title">Tap Molten Metal & Slag</div>
          <div class="action-card-hint">Releases 1500°C molten iron stream</div>
        </div>
      </div>
    </div>
  `;

  bindDirectSmeltingEvents();
}

function bindDirectSmeltingEvents() {
  const cardOre = document.getElementById('cardChargeOre');
  const cardCoke = document.getElementById('cardChargeCoke');
  const cardFlux = document.getElementById('cardChargeFlux');
  const cardBlast = document.getElementById('cardTuyereBlast');
  const cardTap = document.getElementById('cardTapIron');
  const slider = document.getElementById('tempRangeSlider');
  const sliderDisplay = document.getElementById('sliderTempDisplay');
  const fieryCore = document.getElementById('furnaceFieryCore');
  const btnFinish = document.getElementById('btnFinishExperiment');

  cardOre.addEventListener('click', () => {
    if (state.expState.chargedOre) return;
    labSound.playClick();
    state.expState.chargedOre = true;
    cardOre.classList.add('active');
    cardOre.classList.add('disabled');
    cardCoke.classList.remove('disabled');
    updateExpFeedback('Hematite (Fe₂O₃) loaded into top hopper. Now add Coke fuel!');
  });

  cardCoke.addEventListener('click', () => {
    if (!state.expState.chargedOre || state.expState.chargedCoke) return;
    labSound.playClick();
    state.expState.chargedCoke = true;
    cardCoke.classList.add('active');
    cardCoke.classList.add('disabled');
    cardFlux.classList.remove('disabled');
    updateExpFeedback('Coke loaded. Add Limestone (CaCO₃) flux to remove silica!');
  });

  cardFlux.addEventListener('click', () => {
    if (!state.expState.chargedCoke || state.expState.chargedFlux) return;
    labSound.playSuccess();
    state.expState.chargedFlux = true;
    cardFlux.classList.add('active');
    cardFlux.classList.add('disabled');
    cardBlast.classList.remove('disabled');
    updateExpFeedback('Raw charge complete! Engage the Tuyere Air Blast to start combustion.');
  });

  cardBlast.addEventListener('click', () => {
    if (!state.expState.chargedFlux || state.expState.tuyereBlastOn) return;
    labSound.playFurnaceHum();
    state.expState.tuyereBlastOn = true;
    cardBlast.classList.add('active');
    cardBlast.querySelector('.action-card-hint').textContent = 'Air Blast ACTIVE 🟢';
    slider.disabled = false;
    cardTap.classList.remove('disabled');

    fieryCore.className = 'furnace-fiery-core warm';
    updateExpFeedback('Air blast active! Use the temperature dial to regulate the hearth to optimal smelting range (1400°C–1550°C).');
  });

  slider.addEventListener('input', (e) => {
    const temp = parseInt(e.target.value, 10);
    state.expState.temperature = temp;
    sliderDisplay.textContent = `${temp} °C`;
    document.getElementById('smeltTempVal').textContent = `${temp} °C`;

    const zoneVal = document.getElementById('smeltZoneVal');

    if (temp < 1100) {
      fieryCore.className = 'furnace-fiery-core';
      zoneVal.textContent = 'Too Cold ❄️';
      zoneVal.style.color = '#EF4444';
    } else if (temp >= 1100 && temp < 1350) {
      fieryCore.className = 'furnace-fiery-core warm';
      zoneVal.textContent = 'Pre-Heating 🔥';
      zoneVal.style.color = '#F97316';
    } else if (temp >= 1350 && temp <= 1600) {
      fieryCore.className = 'furnace-fiery-core optimal';
      zoneVal.textContent = 'Optimal Smelting 🌟';
      zoneVal.style.color = '#10B981';
    } else {
      fieryCore.className = 'furnace-fiery-core overheat';
      zoneVal.textContent = 'DANGEROUS OVERHEAT ⚠️';
      zoneVal.style.color = '#DC2626';
    }
  });

  cardTap.addEventListener('click', () => {
    if (!state.expState.tuyereBlastOn || state.expState.ironTapped) return;

    const temp = state.expState.temperature;

    if (temp < 1200) {
      labSound.playError();
      state.stage4Mistakes++;
      openTempAlert(
        '❄️ Temperature Too Low!',
        `At ${temp}°C, the reduction of hematite cannot complete and slag solidifies into rock! The taphole cannot flow.`,
        '1400 °C - 1550 °C (Molten Smelting Zone)'
      );
      updateHeaderScore();
      return;
    } else if (temp > 1750) {
      labSound.playError();
      state.stage4Mistakes++;
      openTempAlert(
        '🔥 Temperature Excessively High!',
        `At ${temp}°C, the furnace is severely overheated! Refractory bricks are melting and metallic vapors are escaping violently.`,
        '1400 °C - 1550 °C (Safe High Efficiency Zone)'
      );
      updateHeaderScore();
      return;
    }

    labSound.playFanfare();
    state.expState.ironTapped = true;
    cardTap.classList.add('active');
    cardTap.classList.add('disabled');

    const stream = document.getElementById('tapStream');
    const ladleFill = document.getElementById('ladleLiquid');
    const slagBox = document.getElementById('slagTapBox');

    stream.classList.add('flowing');
    ladleFill.style.height = '100%';
    slagBox.textContent = 'SLAG SEPARATED ✔';
    slagBox.style.background = '#065F46';

    document.getElementById('smeltYieldVal').textContent = '98.5%';
    updateExpFeedback('🎉 SUCCESS! White-hot molten iron (Fe) tapped into ingot mold, and lighter slag separated cleanly!');
    btnFinish.disabled = false;
  });
}

function openTempAlert(title, message, optimal) {
  document.getElementById('tempAlertTitle').textContent = title;
  document.getElementById('tempAlertMsg').textContent = message;
  document.getElementById('tempAlertOptimal').textContent = optimal;
  document.getElementById('modalTempAlert').classList.add('open');
}

function closeTempAlert() {
  labSound.playClick();
  document.getElementById('modalTempAlert').classList.remove('open');
}

// ----------------------------------------------------------------------------
// DIRECT INTERACTIVE CALORIMETRY WORKBENCH
// ----------------------------------------------------------------------------
function renderDirectCalorimetryWorkbench(container) {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Temp (T₁)</span>
      <span class="metric-value">22.0 °C</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Current Temp</span>
      <span class="metric-value" id="calorTemp">22.0 °C</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Heat Evolved (q)</span>
      <span class="metric-value" id="calorHeatVal">0.00 kJ</span>
    </div>
  `;

  container.innerHTML = `
    <div class="workbench-viewport">
      <div style="width: 140px; height: 160px; position: relative;">
        ${getRealisticApparatusSVG('calorimeter')}
        <div style="position: absolute; top: 10px; right: -50px; background: white; border: 2px solid #7C3AED; padding: 6px 12px; border-radius: 8px; font-family: var(--font-mono); font-weight: 800; font-size: 16px; color: #7C3AED;" id="digitalProbe">
          22.0 °C
        </div>
      </div>
      <div style="margin-top: 14px; font-family: var(--font-display); font-size: 14px; font-weight: 800; color: #2D144B;" id="calorStatus">
        Calorimeter Chamber Ready
      </div>
    </div>

    <div class="workbench-tools-tray">
      <div class="panel-section-title">🧪 1. POUR REACTANTS</div>

      <div class="direct-action-card" id="cardPourAcid">
        <div class="action-card-icon">🥛</div>
        <div>
          <div class="action-card-title">Pour 50 mL 1.0 M HCl</div>
          <div class="action-card-hint">Transfers acid into calorimeter</div>
        </div>
      </div>

      <div class="direct-action-card disabled" id="cardPourBase">
        <div class="action-card-icon">🥛</div>
        <div>
          <div class="action-card-title">Pour 50 mL 1.0 M NaOH</div>
          <div class="action-card-hint">Initiates neutralization</div>
        </div>
      </div>

      <div class="panel-section-title" style="margin-top: 6px;">🔒 2. SEAL & STIR</div>

      <div class="direct-action-card disabled" id="cardSealLid">
        <div class="action-card-icon">🛡️</div>
        <div>
          <div class="action-card-title">Seal Insulated Lid</div>
          <div class="action-card-hint">Prevents heat loss to room</div>
        </div>
      </div>

      <div class="direct-action-card disabled" id="cardStirMix">
        <div class="action-card-icon">🌀</div>
        <div>
          <div class="action-card-title">Stir Solution & Measure ΔT</div>
          <div class="action-card-hint">Continuous temperature sampling</div>
        </div>
      </div>
    </div>
  `;

  bindDirectCalorimetryEvents();
}

function bindDirectCalorimetryEvents() {
  const cardAcid = document.getElementById('cardPourAcid');
  const cardBase = document.getElementById('cardPourBase');
  const cardLid = document.getElementById('cardSealLid');
  const cardStir = document.getElementById('cardStirMix');
  const btnFinish = document.getElementById('btnFinishExperiment');

  cardAcid.addEventListener('click', () => {
    if (state.expState.acidAdded) return;
    labSound.playWaterDrop();
    state.expState.acidAdded = true;
    cardAcid.classList.add('active', 'disabled');
    cardBase.classList.remove('disabled');
    document.getElementById('calorStatus').textContent = '50 mL HCl in Cup (22.0 °C)';
  });

  cardBase.addEventListener('click', () => {
    if (!state.expState.acidAdded || state.expState.baseAdded) return;
    labSound.playWaterDrop();
    state.expState.baseAdded = true;
    cardBase.classList.add('active', 'disabled');
    cardLid.classList.remove('disabled');
    document.getElementById('calorStatus').textContent = 'HCl + NaOH Mixed! Rapidly Close Lid!';
  });

  cardLid.addEventListener('click', () => {
    if (!state.expState.baseAdded || state.expState.lidClosed) return;
    labSound.playClick();
    state.expState.lidClosed = true;
    cardLid.classList.add('active', 'disabled');
    cardStir.classList.remove('disabled');
    document.getElementById('calorStatus').textContent = 'Calorimeter Sealed. Stir to Measure ΔT.';
  });

  cardStir.addEventListener('click', () => {
    if (!state.expState.lidClosed) return;
    labSound.playSuccess();
    cardStir.classList.add('active', 'disabled');
    document.getElementById('calorStatus').textContent = 'Stirring... Exothermic reaction in progress! 📈';

    let temp = 22.0;
    const interval = setInterval(() => {
      temp += 0.2;
      document.getElementById('calorTemp').textContent = `${temp.toFixed(1)} °C`;
      document.getElementById('digitalProbe').textContent = `${temp.toFixed(1)} °C`;

      const q = (100.0 * 4.184 * (temp - 22.0)) / 1000;
      document.getElementById('calorHeatVal').textContent = `${q.toFixed(2)} kJ`;

      if (temp >= 28.8) {
        clearInterval(interval);
        labSound.playFanfare();
        document.getElementById('calorStatus').textContent = 'Peak Temperature (28.8 °C) Reached! ΔT = +6.8 °C';
        btnFinish.disabled = false;
      }
    }, 90);
  });
}

// ----------------------------------------------------------------------------
// DIRECT INTERACTIVE FLAME TEST WORKBENCH
// ----------------------------------------------------------------------------
function renderDirectFlameTestWorkbench(container) {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Flame Type</span>
      <span class="metric-value" id="flameTypeVal" style="color: #3B82F6;">Hot Blue (1200°C)</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Active Sample</span>
      <span class="metric-value" id="flameSampleVal">None</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Wavelength (λ)</span>
      <span class="metric-value" id="flameLambdaVal">—</span>
    </div>
  `;

  container.innerHTML = `
    <div class="workbench-viewport">
      <div style="display: flex; flex-direction: column; align-items: center; position: relative;">
        <div id="flameGlowEffect" style="width: 130px; height: 190px; border-radius: 50% 50% 20% 20%; background: radial-gradient(circle, #38BDF8 0%, #3B82F6 60%, transparent 80%); filter: blur(4px); box-shadow: 0 0 40px #38BDF8; transition: all 0.5s ease;"></div>
        <div style="width: 32px; height: 75px; background: #64748B; border-radius: 4px; margin-top: -10px;"></div>
        <div style="width: 75px; height: 16px; background: #334155; border-radius: 6px;"></div>
      </div>
    </div>

    <div class="workbench-tools-tray">
      <div class="panel-section-title">🌈 1. PICK SAMPLE ON PLATINUM LOOP</div>

      <div class="direct-action-card" id="cardSampleNa">
        <div class="action-card-icon">🧂</div>
        <div>
          <div class="action-card-title">Dip Loop in NaCl (Sodium)</div>
          <div class="action-card-hint">Holds into Bunsen flame</div>
        </div>
      </div>

      <div class="direct-action-card" id="cardSampleSr">
        <div class="action-card-icon">🧂</div>
        <div>
          <div class="action-card-title">Dip Loop in SrCl₂ (Strontium)</div>
          <div class="action-card-hint">Holds into Bunsen flame</div>
        </div>
      </div>

      <div class="direct-action-card" id="cardSampleCu">
        <div class="action-card-icon">🧂</div>
        <div>
          <div class="action-card-title">Dip Loop in CuSO₄ (Copper)</div>
          <div class="action-card-hint">Holds into Bunsen flame</div>
        </div>
      </div>

      <div class="panel-section-title" style="margin-top: 6px;">🧼 2. CLEANING BATH</div>

      <div class="direct-action-card" id="cardCleanWire">
        <div class="action-card-icon">🧪</div>
        <div>
          <div class="action-card-title">Rinse Loop in Conc. HCl</div>
          <div class="action-card-hint">Purifies platinum wire</div>
        </div>
      </div>
    </div>
  `;

  bindDirectFlameTestEvents();
}

function bindDirectFlameTestEvents() {
  const glow = document.getElementById('flameGlowEffect');
  const sampleVal = document.getElementById('flameSampleVal');
  const lambdaVal = document.getElementById('flameLambdaVal');
  const btnFinish = document.getElementById('btnFinishExperiment');

  let testedCount = 0;

  document.getElementById('cardSampleNa').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #FDE047 0%, #EAB308 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #FDE047';
    sampleVal.textContent = 'Na⁺ (Sodium)';
    lambdaVal.textContent = '589 nm (Yellow)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('cardSampleSr').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #F87171 0%, #DC2626 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #EF4444';
    sampleVal.textContent = 'Sr²⁺ (Strontium)';
    lambdaVal.textContent = '650 nm (Crimson)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('cardSampleCu').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #34D399 0%, #059669 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #10B981';
    sampleVal.textContent = 'Cu²⁺ (Copper)';
    lambdaVal.textContent = '510 nm (Green-Blue)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('cardCleanWire').addEventListener('click', () => {
    labSound.playWaterDrop();
    glow.style.background = 'radial-gradient(circle, #38BDF8 0%, #3B82F6 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 40px #38BDF8';
    sampleVal.textContent = 'Cleaned (Inert)';
    lambdaVal.textContent = '—';
  });
}

function updateExpFeedback(text) {
  const fb = document.getElementById('expFeedbackText');
  if (fb) fb.textContent = text;
}

// ============================================================================
// 10. STAGE 5: REPORT & QUICK REVISION
// ============================================================================
function renderStage5() {
  const finalScore = state.calculateFinalScore();
  document.getElementById('finalScoreVal').textContent = `${finalScore}%`;

  const starsContainer = document.getElementById('starsDisplay');
  starsContainer.innerHTML = '';
  const starCount = finalScore >= 85 ? 3 : (finalScore >= 70 ? 2 : 1);
  for (let i = 0; i < 3; i++) {
    const s = document.createElement('span');
    s.className = `star ${i < starCount ? 'filled' : ''}`;
    s.textContent = '★';
    starsContainer.appendChild(s);
  }

  document.getElementById('apparatusPerf').textContent = state.stage2Mistakes === 0 ? '100% (No Mistakes)' : `${state.stage2Mistakes} Mistakes`;
  document.getElementById('cupboardPerf').textContent = state.stage3Mistakes === 0 ? '100% (No Mistakes)' : `${state.stage3Mistakes} Mistakes`;
  document.getElementById('simPerf').textContent = state.stage4Mistakes === 0 ? 'Optimal Performance' : 'Completed with Retries';

  const tableContainer = document.getElementById('reportDataTable');
  if (state.currentModuleId === 'titration') {
    tableContainer.innerHTML = `
      <table class="log-table">
        <tr><th>Parameter</th><th>Measured Value</th><th>Theoretical</th></tr>
        <tr><td>Volume of HCl Analyte</td><td>10.0 mL</td><td>10.0 mL</td></tr>
        <tr><td>Volume of 0.1 M NaOH</td><td>${state.expState.buretteVolume.toFixed(1)} mL</td><td>20.0 mL</td></tr>
        <tr><td>Calculated Molarity (M₂)</td><td>0.100 M</td><td>0.100 M</td></tr>
        <tr><td>Indicator Transition</td><td>Colorless &rarr; Pale Pink</td><td>pH 8.2 Endpoint</td></tr>
      </table>
    `;
  } else if (state.currentModuleId === 'smelting') {
    tableContainer.innerHTML = `
      <table class="log-table">
        <tr><th>Parameter</th><th>Observed Measurement</th><th>Target Status</th></tr>
        <tr><td>Furnace Operating Temp</td><td>${state.expState.temperature} °C</td><td>1400°C - 1550°C (Optimal)</td></tr>
        <tr><td>Primary Ore Reduced</td><td>Hematite (Fe₂O₃)</td><td>100% Charged</td></tr>
        <tr><td>Reducing Gas Agent</td><td>Carbon Monoxide (CO)</td><td>Active Oxidation</td></tr>
        <tr><td>Slag Formed & Separated</td><td>Calcium Silicate (CaSiO₃)</td><td>Clean Separation ✔</td></tr>
        <tr><td>Molten Iron Yield</td><td>98.5%</td><td>Poured into Ingot Mold ✔</td></tr>
      </table>
    `;
  } else if (state.currentModuleId === 'calorimetry') {
    tableContainer.innerHTML = `
      <table class="log-table">
        <tr><th>Parameter</th><th>Measured Value</th></tr>
        <tr><td>Initial Temp (T₁)</td><td>22.0 °C</td></tr>
        <tr><td>Peak Temp (T₂)</td><td>28.8 °C</td></tr>
        <tr><td>Temperature Rise (ΔT)</td><td>+6.8 °C</td></tr>
        <tr><td>Heat of Neutralization (q)</td><td>2.85 kJ</td></tr>
        <tr><td>Molar Enthalpy (ΔH)</td><td>-57.0 kJ/mol</td></tr>
      </table>
    `;
  } else {
    tableContainer.innerHTML = `
      <table class="log-table">
        <tr><th>Cation</th><th>Characteristic Flame Color</th><th>Dominant λ</th></tr>
        <tr><td>Sodium (Na⁺)</td><td>Golden Yellow</td><td>589 nm</td></tr>
        <tr><td>Strontium (Sr²⁺)</td><td>Crimson Red</td><td>650 nm</td></tr>
        <tr><td>Copper (Cu²⁺)</td><td>Turquoise Blue-Green</td><td>510 nm</td></tr>
      </table>
    `;
  }

  renderRevisionContent();
}

function renderRevisionContent() {
  const mod = state.moduleData;
  document.getElementById('revisionTitle').textContent = `⚡ Quick Revision: ${mod.name}`;
  document.getElementById('revisionModalBody').innerHTML = mod.revision.content;
}

// ============================================================================
// 11. MODALS & TOAST NOTICES
// ============================================================================
function openHurrahModal() { document.getElementById('modalHurrah').classList.add('open'); }
function closeHurrahModal() { document.getElementById('modalHurrah').classList.remove('open'); }

function openConceptModal(cardKey) {
  labSound.playClick();
  const mod = state.moduleData;
  const cardData = mod.concept.cards[cardKey];
  if (!cardData) return;

  document.getElementById('conceptModalBadge').textContent = cardData.tag;
  document.getElementById('conceptModalTitle').textContent = cardData.heading;
  document.getElementById('conceptModalBody').innerHTML = cardData.modalDetails;
  document.getElementById('modalConceptDetail').classList.add('open');
}

function closeConceptModal() {
  labSound.playClick();
  document.getElementById('modalConceptDetail').classList.remove('open');
}

function openRevisionModal() {
  renderRevisionContent();
  document.getElementById('modalQuickRevision').classList.add('open');
}

function closeRevisionModal() {
  labSound.playClick();
  document.getElementById('modalQuickRevision').classList.remove('open');
}

function showErrorToast(title, message) {
  const toast = document.getElementById('errorToast');
  document.getElementById('toastTitle').textContent = title;
  document.getElementById('toastMessage').textContent = message;
  toast.classList.add('active');
  setTimeout(() => {
    toast.classList.remove('active');
  }, 2500);
}

function updateHeaderScore() {
  const score = state.calculateFinalScore();
  document.getElementById('headerScore').textContent = `${score}%`;
}

// ============================================================================
// 12. QUESTLY FLUTTER BRIDGE EVENT SENDER
// ============================================================================
function sendQuestlyEvent(eventType, payload) {
  try {
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({
        type: 'QUESTLY_LAB_EVENT',
        event: eventType,
        ...payload
      }, '*');
    }
  } catch (e) {
    console.log('Questly bridge dispatch error:', e);
  }
}