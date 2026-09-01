/**
 * QUESTLY VIRTUAL SCIENCE LAB ENGINE
 * High-fidelity, gamified, multi-module virtual lab simulator.
 * Supports: Acid-Base Titration, Calorimetry & Thermochemistry, Flame Test & Salt Analysis.
 */

// ============================================================================
// 1. SOUND SYSTEM (WEB AUDIO API SYNTHESIZER)
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
    osc.frequency.setValueAtTime(600, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(300, this.ctx.currentTime + 0.05);
    gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.01, this.ctx.currentTime + 0.05);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.05);
  }

  playSuccess() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [523.25, 659.25, 783.99, 1046.50].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + i * 0.08);
      gain.gain.setValueAtTime(0, now + i * 0.08);
      gain.gain.linearRampToValueAtTime(0.18, now + i * 0.08 + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.08 + 0.25);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + i * 0.08);
      osc.stop(now + i * 0.08 + 0.25);
    });
  }

  playError() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(180, now);
    osc.frequency.linearRampToValueAtTime(110, now + 0.25);
    gain.gain.setValueAtTime(0.2, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.25);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.25);
  }

  playWaterDrop() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(1200, now);
    osc.frequency.exponentialRampToValueAtTime(400, now + 0.08);
    gain.gain.setValueAtTime(0.2, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.08);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.08);
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
      osc.type = 'square';
      osc.frequency.setValueAtTime(freq, now + idx * 0.12);
      gain.gain.setValueAtTime(0.12, now + idx * 0.12);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.12 + 0.4);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + idx * 0.12);
      osc.stop(now + idx * 0.12 + 0.4);
    });
  }
}

const labSound = new LabSoundEngine();

// ============================================================================
// 2. MODULE DATABASE (3 COMPLETE LAB MODULES)
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
          desc: 'A neutralization reaction occurs when stoichiometric amounts of an acid and a base react to form a neutral salt and water. The point at which moles of H⁺ equal moles of OH⁻ is the Equivalence Point.',
          formula: 'HCl(aq) + NaOH(aq) → NaCl(aq) + H₂O(l)   [M₁V₁ = M₂V₂]',
          modalDetails: `
            <h4>1. Theory & Mechanism</h4>
            <p>Acid-base titration is a quantitative chemical analysis method used to calculate the unknown concentration of an identified analyte. In this lab, we titrate 10.0 mL of Hydrochloric Acid (HCl) against standard 0.1 M Sodium Hydroxide (NaOH).</p>
            <br>
            <h4>2. Equivalence vs. Endpoint</h4>
            <p><strong>Equivalence Point:</strong> Theoretical point where stoichiometric equivalents of acid and base neutralize each other (pH = 7.0).</p>
            <p><strong>Endpoint:</strong> Experimental point indicated by the sharp color change of Phenolphthalein indicator from colorless to faint, permanent pale pink (pH 8.2 - 8.3).</p>
          `
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Required Apparatus',
          desc: 'Precision volumetric glassware including a 50 mL graduated Burette, 10 mL Volumetric Pipette, 250 mL Conical Flask, and White Tile.',
          tags: ['Burette (50 mL)', 'Pipette (10 mL)', 'Conical Flask (250 mL)', 'Retort Stand & Clamp'],
          modalDetails: `
            <h4>Volumetric Glassware Purpose:</h4>
            <ul>
              <li><strong>Burette:</strong> Delivers variable, precise volumes of titrant (NaOH) drop by drop.</li>
              <li><strong>Volumetric Pipette:</strong> Accurately measures exactly 10.0 mL of analyte (HCl).</li>
              <li><strong>Conical (Erlenmeyer) Flask:</strong> Slanted sides prevent liquid splashing during continuous swirling.</li>
              <li><strong>White Tile:</strong> Placed under the flask to detect the subtle pale-pink endpoint transition instantly.</li>
            </ul>
          `
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Solutions',
          desc: 'Standard Hydrochloric Acid (HCl 0.1 M), Sodium Hydroxide (NaOH 0.1 M), and Phenolphthalein Indicator solution.',
          tags: ['0.1 M HCl (Analyte)', '0.1 M NaOH (Titrant)', 'Phenolphthalein Indicator'],
          modalDetails: `
            <h4>Reagents & Safety:</h4>
            <ul>
              <li><strong>0.1 M HCl:</strong> Strong monoprotective acid placed in the conical flask.</li>
              <li><strong>0.1 M NaOH:</strong> Strong base standard solution loaded in the burette.</li>
              <li><strong>Phenolphthalein:</strong> Synthetic pH indicator. Colorless in acidic medium (pH < 8.2), vivid pink in basic medium (pH > 10.0). Only 2-3 drops required!</li>
            </ul>
          `
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Step-by-Step Execution',
          desc: '1. Rinse & fill burette. 2. Pipette 10 mL HCl into conical flask. 3. Add 2 drops indicator. 4. Dispense titrant until permanent pale pink.',
          modalDetails: `
            <h4>Laboratory Protocol:</h4>
            <ol>
              <li>Fill the burette with 0.1 M NaOH up to the 0.0 mL initial mark, checking for air bubbles in the tip.</li>
              <li>Pipette exactly 10.0 mL of 0.1 M HCl into the clean conical flask.</li>
              <li>Add 2 drops of phenolphthalein indicator and swirl the flask. (Remains colorless).</li>
              <li>Place flask on the white tile beneath the burette tip.</li>
              <li>Gradually open stopcock to add NaOH while swirling continuously. Near 20.0 mL, add drop-by-drop until a faint permanent pink color persists for 30 seconds.</li>
            </ol>
          `
        }
      }
    },
    apparatusPool: [
      { id: 'burette', name: 'Burette', icon: '📏', spec: '50 mL Volumetric', required: true },
      { id: 'conical_flask', name: 'Conical Flask', icon: '⚗️', spec: '250 mL Erlenmeyer', required: true },
      { id: 'pipette', name: 'Pipette', icon: '🧪', spec: '10 mL Volumetric', required: true },
      { id: 'stand_clamp', name: 'Retort Stand', icon: '📐', spec: 'Heavy Iron Base + Clamp', required: true },
      { id: 'beaker', name: 'Beaker', icon: '🥛', spec: '100 mL Glass', required: false, wrongDesc: "A Beaker is used for holding bulk liquids, not precision volumetric titration." },
      { id: 'crucible', name: 'Crucible', icon: '🥣', spec: 'Porcelain High Temp', required: false, wrongDesc: "A Crucible is for heating solids at high temperatures, not titration." },
      { id: 'test_tube', name: 'Test Tube', icon: '🧫', spec: 'Borosilicate 15 mL', required: false, wrongDesc: "Test tubes cannot accommodate continuous swirling for titration." },
      { id: 'tripod', name: 'Tripod Stand', icon: '🔺', spec: 'Steel Burner Support', required: false, wrongDesc: "Tripod stands are for heating over burners, not titration." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_01', name: 'Hydrochloric Acid', formula: 'HCl', conc: '0.1 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'h2so4_conc', name: 'Sulfuric Acid (Conc)', formula: 'H₂SO₄', conc: '18.0 M', hazard: 'Severe Acid 🔥', required: false, shelf: 'A', wrongDesc: "Concentrated H₂SO₄ is too hazardous and not required for 0.1 M titration." },
        { id: 'acetic_acid', name: 'Acetic Acid', formula: 'CH₃COOH', conc: '0.5 M', hazard: 'Weak Acid ⚠️', required: false, shelf: 'A', wrongDesc: "Acetic Acid is a weak organic acid; we require strong 0.1 M HCl." },
        { id: 'distilled_water', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: false, shelf: 'A', wrongDesc: "Distilled water is for rinsing, but not the primary analyte reagent." }
      ],
      shelfB: [
        { id: 'naoh_01', name: 'Sodium Hydroxide', formula: 'NaOH', conc: '0.1 M', hazard: 'Caustic Base ⚠️', required: true, shelf: 'B' },
        { id: 'phenolphthalein', name: 'Phenolphthalein', formula: 'C₂₀H₁₄O₄', conc: '1% Sol.', hazard: 'Indicator 💧', required: true, shelf: 'B' },
        { id: 'methyl_orange', name: 'Methyl Orange', formula: 'C₁₄H₁₄N₃NaO₃S', conc: '0.1% Sol.', hazard: 'Indicator 💧', required: false, shelf: 'B', wrongDesc: "Methyl orange changes at pH 3.1-4.4. Phenolphthalein is needed for strong acid-base titration." },
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
          <p>Where M₁ = 0.100 M (HCl), V₁ = 10.0 mL, M₂ = 0.100 M (NaOH), V₂ = 10.0 mL.</p>
        </div>
        <div class="rev-block">
          <h4>📌 Indicators & pH Ranges:</h4>
          <ul>
            <li><strong>Phenolphthalein:</strong> Colorless (pH < 8.2) &rarr; Faint Pink (pH 8.2 - 10.0) &rarr; Dark Magenta (> 10.0).</li>
            <li>Ideal Endpoint: A faint, pale pink tint that persists for at least 30 seconds.</li>
          </ul>
        </div>
        <div class="rev-block">
          <h4>📌 Common Lab Errors to Avoid:</h4>
          <ul>
            <li>Air bubble trapped in burette nozzle creates false volume readings.</li>
            <li>Over-titration (adding too much base) results in dark pink overshot error.</li>
            <li>Not swirling the flask causes localized premature color changes.</li>
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
          desc: 'When strong acids and strong bases neutralize, energy is released into the aqueous solution, increasing temperature. q = m · c · ΔT.',
          formula: 'q = m · c · ΔT   |   ΔH_neut ≈ -57.1 kJ/mol',
          modalDetails: `
            <h4>1. Heat of Reaction (q)</h4>
            <p>In an isolated polystyrene calorimeter cup, heat lost to the surroundings is negligible. The heat generated by the reaction is absorbed by the water:</p>
            <p><code>q_reaction = -(m_solution &times; c_water &times; &Delta;T)</code></p>
            <p>Where c = 4.184 J/(g·°C) and density of solution ≈ 1.00 g/mL.</p>
          `
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Calorimeter & Instruments',
          desc: 'Styrofoam calorimeter cup with lid, high-precision digital thermometer, magnetic stirrer, and graduated cylinders.',
          tags: ['Polystyrene Calorimeter', 'Digital Thermometer', 'Stirrer Rod', 'Graduated Cylinder'],
          modalDetails: `
            <h4>Apparatus Roles:</h4>
            <ul>
              <li><strong>Styrofoam Cup:</strong> Provides high thermal insulation to minimize heat loss.</li>
              <li><strong>Digital Thermometer:</strong> Measures temperature with 0.1°C precision.</li>
              <li><strong>Stirrer:</strong> Ensures uniform temperature distribution throughout the solution.</li>
            </ul>
          `
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Solutions',
          desc: '1.0 M Hydrochloric Acid (HCl 50 mL), 1.0 M Sodium Hydroxide (NaOH 50 mL), and Distilled Water.',
          tags: ['1.0 M HCl (50 mL)', '1.0 M NaOH (50 mL)', 'Distilled H₂O'],
          modalDetails: `
            <h4>Reagent Volumes:</h4>
            <p>Mixing 50.0 mL of 1.0 M HCl with 50.0 mL of 1.0 M NaOH creates 100.0 g of solution containing 0.050 moles of neutralized water.</p>
          `
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Experimental Protocol',
          desc: '1. Measure initial T₁. 2. Mix 50 mL HCl + 50 mL NaOH in cup. 3. Close lid and stir. 4. Record maximum peak temperature T₂.',
          modalDetails: `
            <h4>Procedure Steps:</h4>
            <ol>
              <li>Pour 50 mL 1.0 M HCl into the calorimeter cup and record initial temperature T₁ (22.0°C).</li>
              <li>Quickly add 50 mL 1.0 M NaOH, close the insulated lid, and insert the thermometer probe.</li>
              <li>Stir gently and record temperature every 5 seconds until peak temperature T₂ is reached.</li>
            </ol>
          `
        }
      }
    },
    apparatusPool: [
      { id: 'calorimeter', name: 'Calorimeter Cup', icon: '☕', spec: 'Double Polystyrene Insulated', required: true },
      { id: 'thermometer', name: 'Digital Thermometer', icon: '🌡️', spec: '±0.1°C Electronic Probe', required: true },
      { id: 'stirrer', name: 'Stirring Rod', icon: '🥢', spec: 'Teflon Thermal Stirrer', required: true },
      { id: 'grad_cylinder', name: 'Graduated Cylinder', icon: '📐', spec: '50 mL Precision Glass', required: true },
      { id: 'bunsen', name: 'Bunsen Burner', icon: '🔥', spec: 'Gas Flame Burner', required: false, wrongDesc: "Calorimetry measures reaction heat itself; external heat from a burner will ruin data!" },
      { id: 'filter_paper', name: 'Filter Paper', icon: '📄', spec: 'Whatman No. 1', required: false, wrongDesc: "Filter paper is for gravimetric filtration, not calorimetry." },
      { id: 'dropper', name: 'Dropper Pipette', icon: '💧', spec: 'Rubber Teat Pipette', required: false, wrongDesc: "We need large graduated cylinders for 50 mL volumes, not small droppers." },
      { id: 'evaporating_dish', name: 'Evaporating Dish', icon: '🥣', spec: 'Porcelain Flat Base', required: false, wrongDesc: "Evaporating dishes allow heat to escape rapidly into the room." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_1m', name: 'Hydrochloric Acid', formula: 'HCl', conc: '1.0 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'distilled_water_cal', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: true, shelf: 'A' },
        { id: 'hno3_conc', name: 'Nitric Acid', formula: 'HNO₃', conc: '2.0 M', hazard: 'Oxidizer 🔥', required: false, shelf: 'A', wrongDesc: "Nitric acid has unwanted oxidation side reactions; use 1.0 M HCl." },
        { id: 'acetone', name: 'Acetone', formula: 'C₃H₆O', conc: 'Pure', hazard: 'Flammable 🔥', required: false, shelf: 'A', wrongDesc: "Acetone is a flammable solvent not used in aqueous calorimetry." }
      ],
      shelfB: [
        { id: 'naoh_1m', name: 'Sodium Hydroxide', formula: 'NaOH', conc: '1.0 M', hazard: 'Caustic ⚠️', required: true, shelf: 'B' },
        { id: 'ammonia_sol', name: 'Ammonium Hydroxide', formula: 'NH₄OH', conc: '1.0 M', hazard: 'Weak Base ⚠️', required: false, shelf: 'B', wrongDesc: "NH₄OH is a weak base with incomplete ionization. We need 1.0 M NaOH." },
        { id: 'copper_sulfate', name: 'Copper Sulfate', formula: 'CuSO₄', conc: '0.5 M', hazard: 'Irritant ⚠️', required: false, shelf: 'B', wrongDesc: "Copper sulfate is not required for acid-base heat of neutralization." },
        { id: 'glycerol', name: 'Glycerol', formula: 'C₃H₈O₃', conc: 'Pure', hazard: 'Safe 💧', required: false, shelf: 'B', wrongDesc: "Glycerol is a viscous humectant not used in this experiment." }
      ]
    },
    revision: {
      title: 'Calorimetry & Heat of Reaction Summary',
      content: `
        <div class="rev-block">
          <h4>📌 Key Thermochemical Equations:</h4>
          <p>Heat Absorbed: <code>q_sol = m &times; c &times; &Delta;T</code></p>
          <p><code>m = 100.0 g</code>, <code>c = 4.184 J/g&deg;C</code>, <code>&Delta;T = 28.8 - 22.0 = 6.8&deg;C</code></p>
          <p><code>q = 100.0 &times; 4.184 &times; 6.8 = 2,845 J = 2.85 kJ</code></p>
        </div>
        <div class="rev-block">
          <h4>📌 Molar Enthalpy (&Delta;H_neut):</h4>
          <p><code>&Delta;H = -q / n = -2.85 kJ / 0.050 mol = -57.0 kJ/mol</code></p>
          <p>Consistent with standard literature value of -57.1 kJ/mol for strong acid-strong base pairs.</p>
        </div>
      `
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
          desc: 'Thermal energy promotes electrons in metal cations to excited energy states. Returning to ground state releases photons of specific wavelength (E = hc/λ).',
          formula: 'E = h · ν = (h · c) / λ   [Photon Emission]',
          modalDetails: `
            <h4>1. Quantum Mechanism:</h4>
            <p>When metal salts are vaporized in a high-temperature non-luminous flame, valence electrons absorb thermal energy and jump to higher quantum energy levels (excited state). As they relax back to ground state, they emit light of discrete wavelengths corresponding to the energy difference &Delta;E.</p>
          `
        },
        apparatus: {
          tag: 'Lab Equipment',
          heading: 'Required Apparatus',
          desc: 'Bunsen Burner with adjustable air-collar, Platinum/Nichrome wire loop, Watch Glasses, and Cobalt Blue Glass.',
          tags: ['Bunsen Burner', 'Platinum Wire Loop', 'Watch Glass (x3)', 'Cobalt Blue Glass'],
          modalDetails: `
            <h4>Apparatus Utility:</h4>
            <ul>
              <li><strong>Bunsen Burner:</strong> Provides clean, hot non-luminous blue flame (up to 1200°C).</li>
              <li><strong>Platinum Loop:</strong> Chemically unreactive loop that does not impart its own color to the flame.</li>
              <li><strong>Cobalt Glass:</strong> Filters out the intense yellow sodium emission when analyzing potassium mixtures.</li>
            </ul>
          `
        },
        solutions: {
          tag: 'Chemical Reagents',
          heading: 'Required Reagents & Salts',
          desc: 'Concentrated Hydrochloric Acid (HCl for loop cleaning), Sodium Chloride (NaCl), Copper Sulfate (CuSO₄), Strontium Chloride (SrCl₂).',
          tags: ['Conc. HCl (Cleaning)', 'NaCl (Sodium Salt)', 'CuSO₄ (Copper Salt)', 'SrCl₂ (Strontium Salt)'],
          modalDetails: `
            <h4>Reagents & Cleaning:</h4>
            <p>Concentrated HCl converts metal salts to volatile metal chlorides, which vaporize readily in the flame. Dipping into clean HCl purifies the loop between tests.</p>
          `
        },
        procedure: {
          tag: 'Standard Procedure',
          heading: 'Execution Protocol',
          desc: '1. Clean loop in conc. HCl until no flame color. 2. Dip loop in sample salt. 3. Place in hottest blue cone of flame. 4. Observe color.',
          modalDetails: `
            <h4>Standard Flame Colors:</h4>
            <ul>
              <li><strong>Sodium (Na⁺):</strong> Intense Persistent Golden Yellow (589 nm)</li>
              <li><strong>Strontium (Sr²⁺):</strong> Brilliant Crimson Red (650 nm)</li>
              <li><strong>Copper (Cu²⁺):</strong> Dazzling Turquoise Green-Blue (510 nm)</li>
              <li><strong>Potassium (K⁺):</strong> Delicate Lilac Violet (766 nm)</li>
              <li><strong>Barium (Ba²⁺):</strong> Apple Green (553 nm)</li>
            </ul>
          `
        }
      }
    },
    apparatusPool: [
      { id: 'bunsen_burner', name: 'Bunsen Burner', icon: '🔥', spec: 'Adjustable Air Collar', required: true },
      { id: 'platinum_loop', name: 'Platinum Loop', icon: '🦯', spec: 'Nichrome/Pt Inert Wire', required: true },
      { id: 'watch_glass', name: 'Watch Glasses', icon: '🥏', spec: 'Porcelain / Glass Dish', required: true },
      { id: 'cobalt_glass', name: 'Cobalt Blue Glass', icon: '🟦', spec: 'Optical Spectral Filter', required: true },
      { id: 'burette', name: 'Burette', icon: '📏', spec: '50 mL Glass', required: false, wrongDesc: "Burettes are for liquid volumetric titration, not flame tests!" },
      { id: 'condenser', name: 'Liebig Condenser', icon: '🧪', spec: 'Distillation Tube', required: false, wrongDesc: "Liebig condensers are for condensing vapor in distillation rigs." },
      { id: 'mortar_pestle', name: 'Mortar & Pestle', icon: '🥣', spec: 'Agate Grinder', required: false, wrongDesc: "Salts are already finely powdered in their sample dishes." },
      { id: 'separating_funnel', name: 'Separating Funnel', icon: '🔻', spec: 'Pear Shaped 250 mL', required: false, wrongDesc: "Separating funnels are for immiscible liquid extractions." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'conc_hcl_flame', name: 'Hydrochloric Acid (Conc)', formula: 'HCl', conc: '12.0 M', hazard: 'Volatilizer ⚠️', required: true, shelf: 'A' },
        { id: 'nacl_salt', name: 'Sodium Chloride', formula: 'NaCl', conc: 'AR Powder', hazard: 'Salt 🧂', required: true, shelf: 'A' },
        { id: 'srcl2_salt', name: 'Strontium Chloride', formula: 'SrCl₂', conc: 'Pure Salt', hazard: 'Sample 🧫', required: true, shelf: 'A' },
        { id: 'lead_nitrate', name: 'Lead Nitrate', formula: 'Pb(NO₃)₂', conc: 'Toxic Solid', hazard: 'Toxic ☠️', required: false, shelf: 'A', wrongDesc: "Lead compounds produce toxic heavy metal fumes when burned!" }
      ],
      shelfB: [
        { id: 'cuso4_salt', name: 'Copper(II) Sulfate', formula: 'CuSO₄', conc: 'Anhydrous', hazard: 'Sample 🧫', required: true, shelf: 'B' },
        { id: 'kcl_salt', name: 'Potassium Chloride', formula: 'KCl', conc: 'Salt', hazard: 'Sample 🧫', required: false, shelf: 'B', wrongDesc: "We already have sufficient test samples (NaCl, SrCl₂, CuSO₄)." },
        { id: 'hexane', name: 'n-Hexane', formula: 'C₆H₁₄', conc: 'Solvent', hazard: 'Flammable 🔥', required: false, shelf: 'B', wrongDesc: "Hexane creates an uncontrollable flash fire near open burners!" },
        { id: 'silver_nitrate', name: 'Silver Nitrate', formula: 'AgNO₃', conc: '0.1 M', hazard: 'Staining ⚠️', required: false, shelf: 'B', wrongDesc: "Silver nitrate is for halide precipitation, not flame analysis." }
      ]
    },
    revision: {
      title: 'Flame Test & Cation Spectroscopy Summary',
      content: `
        <div class="rev-block">
          <h4>📌 Characteristic Flame Colors:</h4>
          <ul>
            <li><strong>Na⁺ (Sodium):</strong> Golden Yellow (589 nm) — extremely sensitive.</li>
            <li><strong>Sr²⁺ (Strontium):</strong> Crimson Red (650 nm).</li>
            <li><strong>Cu²⁺ (Copper):</strong> Green-Blue / Turquoise (510 nm).</li>
            <li><strong>K⁺ (Potassium):</strong> Lilac / Pale Violet (766 nm) — viewed through cobalt glass.</li>
            <li><strong>Ba²⁺ (Barium):</strong> Apple Green (553 nm).</li>
          </ul>
        </div>
        <div class="rev-block">
          <h4>📌 Loop Cleaning Protocol:</h4>
          <p>Dip wire in concentrated HCl and heat in non-luminous flame until the wire imparts zero color.</p>
        </div>
      `
    }
  }
};

// ============================================================================
// 3. LAB STATE MANAGER
// ============================================================================
class LabStateManager {
  constructor() {
    this.currentModuleId = 'titration';
    this.currentStage = 1;
    this.firstAttemptScore = 100;
    this.stage2Mistakes = 0;
    this.stage3Mistakes = 0;
    this.stage4Mistakes = 0;

    // Selections
    this.selectedApparatus = new Set();
    this.selectedCupboard = new Set();

    // Experiment specific state
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
        buretteVolume: 0.0, // mL added
        flaskVolume: 10.0,   // mL in flask
        hasIndicator: false,
        stopcockOpen: false,
        flowMode: 'stop', // stop, drip, flow
        swirling: false,
        endpointReached: false,
        overTitrated: false
      };
    } else if (this.currentModuleId === 'calorimetry') {
      this.expState = {
        acidAdded: false,
        baseAdded: false,
        lidClosed: false,
        stirring: false,
        currentTemp: 22.0,
        peakTemp: 28.8,
        reactionComplete: false
      };
    } else if (this.currentModuleId === 'flametest') {
      this.expState = {
        burnerOn: true,
        airVentOpen: true, // blue flame
        loopClean: true,
        currentSample: null,
        flameColor: 'blue',
        spectrumActive: false
      };
    }
  }
}

const state = new LabStateManager();

// ============================================================================
// 4. DOM CONTROLLER & RENDERERS
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
  // Sound Toggle
  const soundBtn = document.getElementById('btnSoundToggle');
  soundBtn.addEventListener('click', () => {
    labSound.enabled = !labSound.enabled;
    document.getElementById('soundIcon').textContent = labSound.enabled ? '🔊' : '🔇';
    labSound.playClick();
  });

  // Module Tabs
  document.querySelectorAll('.module-tab').forEach(tab => {
    tab.addEventListener('click', (e) => {
      const modId = tab.dataset.module;
      if (modId !== state.currentModuleId) {
        labSound.playClick();
        state.switchModule(modId);
        renderCurrentModule();
      }
    });
  });

  // Stage Steppers
  document.querySelectorAll('.step-pill').forEach(pill => {
    pill.addEventListener('click', () => {
      const targetStage = parseInt(pill.dataset.stage, 10);
      if (targetStage <= state.currentStage) {
        labSound.playClick();
        goToStage(targetStage);
      }
    });
  });

  // Stage 1: Finish Concept -> Hurrah Modal
  document.getElementById('btnFinishConcept').addEventListener('click', () => {
    labSound.playSuccess();
    openHurrahModal();
  });

  // Hurrah Modal Go -> Stage 2
  document.getElementById('btnHurrahGo').addEventListener('click', () => {
    labSound.playClick();
    closeHurrahModal();
    goToStage(2);
  });

  // Stage 2: Proceed -> Stage 3
  document.getElementById('btnProceedStage2').addEventListener('click', () => {
    labSound.playClick();
    goToStage(3);
  });

  // Stage 3: Proceed -> Stage 4
  document.getElementById('btnProceedStage3').addEventListener('click', () => {
    labSound.playClick();
    goToStage(4);
  });

  // Stage 4: Finish Exp -> Stage 5
  document.getElementById('btnFinishExperiment').addEventListener('click', () => {
    labSound.playFanfare();
    goToStage(5);
  });

  // Stage 5 Actions
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
    alert('🎉 Congratulations! Lab completion recorded in Questly profile!');
  });

  // Back to modules
  document.getElementById('btnBackToModules').addEventListener('click', () => {
    labSound.playClick();
    sendQuestlyEvent('navigate_back', {});
  });
}

// ============================================================================
// 5. STAGE NAVIGATION & RENDERING
// ============================================================================
function goToStage(stageNum) {
  state.currentStage = stageNum;
  document.querySelectorAll('.stage-view').forEach(v => v.classList.remove('active'));
  const targetView = document.getElementById(`stage${stageNum}`);
  if (targetView) targetView.classList.add('active');

  // Update Stepper UI
  document.querySelectorAll('.step-pill').forEach(p => {
    const s = parseInt(p.dataset.stage, 10);
    p.classList.remove('active', 'completed');
    if (s === stageNum) p.classList.add('active');
    else if (s < stageNum) p.classList.add('completed');
  });

  // Notify parent Flutter view
  sendQuestlyEvent('stage_complete', {
    stage: stageNum - 1,
    moduleId: state.currentModuleId
  });

  // Render specific stage details
  if (stageNum === 2) renderStage2();
  else if (stageNum === 3) renderStage3();
  else if (stageNum === 4) renderStage4();
  else if (stageNum === 5) renderStage5();
}

function renderCurrentModule() {
  const mod = state.moduleData;

  // Header Title & Active Tab
  document.getElementById('currentModuleName').textContent = mod.name;
  document.querySelectorAll('.module-tab').forEach(tab => {
    tab.classList.toggle('active', tab.dataset.module === state.currentModuleId);
  });

  // Stage 1 Concept Cards
  document.getElementById('stage1Title').textContent = mod.concept.title;
  document.getElementById('stage1Subtitle').textContent = mod.concept.subtitle;
  
  // Card 1
  document.getElementById('principleHeading').textContent = mod.concept.cards.principle.heading;
  document.getElementById('principleDesc').textContent = mod.concept.cards.principle.desc;
  document.getElementById('principleFormula').innerHTML = `<code>${mod.concept.cards.principle.formula}</code>`;

  // Card 2
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

  // Card 3
  document.getElementById('solutionsHeading').textContent = mod.concept.cards.solutions.heading;
  document.getElementById('solutionsSummary').textContent = mod.concept.cards.solutions.desc;
  const solTagsContainer = document.getElementById('solutionsTags');
  solTagsContainer.innerHTML = '';
  mod.concept.cards.solutions.tags.forEach(t => {
    const span = document.createElement('span');
    span.className = 'mini-tag reagent';
    span.textContent = t;
    solTagsContainer.appendChild(span);
  });

  // Card 4
  document.getElementById('procedureHeading').textContent = mod.concept.cards.procedure.heading;
  document.getElementById('procedureSummary').textContent = mod.concept.cards.procedure.desc;

  // Go to Stage 1 initially
  goToStage(state.currentStage);
}

// ============================================================================
// 6. STAGE 2: APPARATUS SELECTION (WITH RED X & ERROR VOICE FEEDBACK)
// ============================================================================
function renderStage2() {
  const mod = state.moduleData;
  const grid = document.getElementById('apparatusGrid');
  const checklist = document.getElementById('apparatusTargetPills');
  const tracker = document.getElementById('apparatusTracker');
  const proceedBtn = document.getElementById('btnProceedStage2');
  const feedback = document.getElementById('apparatusFeedback');

  grid.innerHTML = '';
  checklist.innerHTML = '';

  const requiredItems = mod.apparatusPool.filter(a => a.required);
  tracker.textContent = `${state.selectedApparatus.size} / ${requiredItems.length}`;
  proceedBtn.disabled = state.selectedApparatus.size < requiredItems.length;

  // Render Target Checklist
  requiredItems.forEach(item => {
    const pill = document.createElement('div');
    const isFound = state.selectedApparatus.has(item.id);
    pill.className = `target-pill ${isFound ? 'found' : ''}`;
    pill.id = `pill-app-${item.id}`;
    pill.innerHTML = `<span>${isFound ? '✔' : '○'}</span><span>${item.name}</span>`;
    checklist.appendChild(pill);
  });

  // Render Selection Cards
  mod.apparatusPool.forEach(item => {
    const card = document.createElement('div');
    const isSelected = state.selectedApparatus.has(item.id);
    card.className = `apparatus-card ${isSelected ? 'selected' : ''}`;
    card.id = `card-app-${item.id}`;

    card.innerHTML = `
      <div class="app-icon">${item.icon}</div>
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
    if (state.selectedApparatus.has(item.id)) return; // Already picked

    labSound.playSuccess();
    state.selectedApparatus.add(item.id);
    cardEl.classList.add('selected');
    cardEl.classList.remove('wrong');

    // Update Checklist Pill
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
      feedback.innerHTML = `<span class="fb-icon">🎉</span><span class="fb-text">All required apparatus gathered! Click Proceed to Cupboard.</span>`;
    }
  } else {
    // WRONG APPARATUS PICKED
    labSound.playError();
    state.stage2Mistakes++;
    cardEl.classList.add('wrong');
    
    // Voice / Toast notice
    showErrorToast(`❌ Incorrect: ${item.name}`, item.wrongDesc || `This apparatus is not required for ${mod.name}.`);

    feedback.className = 'live-feedback-box error';
    feedback.innerHTML = `<span class="fb-icon">❌</span><span class="fb-text"><strong>${item.name}:</strong> ${item.wrongDesc || 'Not required for this experiment.'}</span>`;

    setTimeout(() => {
      cardEl.classList.remove('wrong');
    }, 1800);
  }
  updateHeaderScore();
}

// ============================================================================
// 7. STAGE 3: CHEMICAL CUPBOARD (WITH SOUND & RED X)
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

  // Render Target Checklist
  requiredReagents.forEach(item => {
    const pill = document.createElement('div');
    const isFound = state.selectedCupboard.has(item.id);
    pill.className = `target-pill ${isFound ? 'found' : ''}`;
    pill.id = `pill-cup-${item.id}`;
    pill.innerHTML = `<span>${isFound ? '✔' : '○'}</span><span>${item.formula} (${item.name})</span>`;
    checklist.appendChild(pill);
  });

  // Render Shelf A
  mod.cupboardPool.shelfA.forEach(item => {
    rowA.appendChild(createBottleElement(item));
  });

  // Render Shelf B
  mod.cupboardPool.shelfB.forEach(item => {
    rowB.appendChild(createBottleElement(item));
  });
}

function createBottleElement(item) {
  const bottle = document.createElement('div');
  const isPicked = state.selectedCupboard.has(item.id);
  bottle.className = `chemical-bottle ${isPicked ? 'picked' : ''}`;
  bottle.id = `bottle-${item.id}`;

  const liquidColor = item.shelf === 'A' ? 'rgba(59, 130, 246, 0.45)' : 'rgba(236, 72, 153, 0.35)';

  bottle.innerHTML = `
    <div class="bottle-visual">
      <div class="bottle-cap"></div>
      <div class="bottle-glass">
        <div class="liquid-fill" style="background: ${liquidColor};"></div>
      </div>
    </div>
    <div class="bottle-label-box">
      <div class="bottle-formula">${item.formula}</div>
      <div class="bottle-conc">${item.conc}</div>
      <div class="bottle-name-sub">${item.name}</div>
    </div>
    <div class="wrong-overlay">
      <div class="cross-icon">❌</div>
      <div class="wrong-text">Wrong Chemical!</div>
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
    feedback.innerHTML = `<span class="fb-icon">✔</span><span class="fb-text">Selected <strong>${item.name} (${item.formula})</strong>. Safe and verified!</span>`;
    tracker.textContent = `${state.selectedCupboard.size} / ${requiredCount}`;

    if (state.selectedCupboard.size === requiredCount) {
      labSound.playFanfare();
      proceedBtn.disabled = false;
      feedback.innerHTML = `<span class="fb-icon">🎉</span><span class="fb-text">All necessary chemical reagents collected! Proceed to Experiment.</span>`;
    }
  } else {
    // WRONG BOTTLE SELECTED
    labSound.playError();
    state.stage3Mistakes++;
    bottleEl.classList.add('wrong');

    showErrorToast(`❌ Wrong Reagent: ${item.name}`, item.wrongDesc || `Do not select this reagent.`);

    feedback.className = 'live-feedback-box error';
    feedback.innerHTML = `<span class="fb-icon">❌</span><span class="fb-text"><strong>${item.name}:</strong> ${item.wrongDesc}</span>`;

    setTimeout(() => {
      bottleEl.classList.remove('wrong');
    }, 1800);
  }
  updateHeaderScore();
}

// ============================================================================
// 8. STAGE 4: EXPERIMENT SIMULATION BENCH
// ============================================================================
function renderStage4() {
  const mod = state.moduleData;
  document.getElementById('expTitle').textContent = `${mod.name} Simulation`;
  document.getElementById('expSubtitle').textContent = mod.subtitle;

  if (state.currentModuleId === 'titration') {
    renderTitrationSim();
  } else if (state.currentModuleId === 'calorimetry') {
    renderCalorimetrySim();
  } else if (state.currentModuleId === 'flametest') {
    renderFlameTestSim();
  }
}

// ----------------------------------------------------------------------------
// TITRATION SIMULATION
// ----------------------------------------------------------------------------
function renderTitrationSim() {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Burette Dispensed</span>
      <span class="metric-value" id="titrBuretteVal">0.0 mL</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Flask pH</span>
      <span class="metric-value" id="titrPhVal">1.0</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Solution Color</span>
      <span class="metric-value" id="titrColorVal" style="color: #64748B;">Colorless</span>
    </div>
  `;

  const viewport = document.getElementById('simViewport');
  viewport.innerHTML = `
    <div class="titration-rig">
      <div class="stand-post"></div>
      <div class="stand-base"></div>
      <div class="white-tile"></div>
      <div class="burette-assembly">
        <div class="burette-liquid" id="buretteLiquidBar"></div>
        <div class="burette-scale">
          <div class="scale-mark"></div>
          <div class="scale-mark"></div>
          <div class="scale-mark"></div>
          <div class="scale-mark"></div>
          <div class="scale-mark"></div>
        </div>
        <div class="stopcock-valve" id="stopcockValve">OFF</div>
        <div class="droplet-stream" id="dropletStream"></div>
      </div>
      <div class="conical-flask-sim" id="conicalFlask">
        <div class="flask-liquid colorless" id="flaskLiquid"></div>
      </div>
    </div>
  `;

  const controls = document.getElementById('simControlsPanel');
  controls.innerHTML = `
    <div class="panel-section-title">🧪 1. PRE-TITRATION STEPS</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnAddIndicator">
        <span>💧 Add Phenolphthalein</span>
        <small>(2 Drops)</small>
      </button>
      <button class="action-chip-btn" id="btnSwirlFlask">
        <span>🌀 Swirl Conical Flask</span>
        <small>Continuous Mix</small>
      </button>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">📏 2. BURETTE DISPENSING CONTROL</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnSingleDrop" disabled>
        <span>💧 Single Drop</span>
        <small>+0.1 mL</small>
      </button>
      <button class="action-chip-btn" id="btnSlowDrip" disabled>
        <span>⏱️ Slow Drip</span>
        <small>+0.5 mL / sec</small>
      </button>
      <button class="action-chip-btn" id="btnFastFlow" disabled>
        <span>🌊 Fast Flow</span>
        <small>+2.0 mL / sec</small>
      </button>
      <button class="action-chip-btn" id="btnStopFlow" disabled>
        <span>🛑 Stop Dispenser</span>
      </button>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">🎯 3. ENDPOINT DETECTION</div>
    <button class="primary-btn" id="btnDeclareEndpoint" style="width: 100%; justify-content: center;" disabled>
      <span>🏁 Confirm Endpoint Reached!</span>
    </button>
  `;

  bindTitrationSimEvents();
}

let titrationInterval = null;

function bindTitrationSimEvents() {
  const btnIndicator = document.getElementById('btnAddIndicator');
  const btnSwirl = document.getElementById('btnSwirlFlask');
  const btnSingle = document.getElementById('btnSingleDrop');
  const btnSlow = document.getElementById('btnSlowDrip');
  const btnFast = document.getElementById('btnFastFlow');
  const btnStop = document.getElementById('btnStopFlow');
  const btnDeclare = document.getElementById('btnDeclareEndpoint');
  const btnFinish = document.getElementById('btnFinishExperiment');

  btnIndicator.addEventListener('click', () => {
    labSound.playWaterDrop();
    state.expState.hasIndicator = true;
    btnIndicator.disabled = true;
    btnIndicator.classList.add('active');
    btnIndicator.innerHTML = '<span>✔ Indicator Added</span>';

    btnSingle.disabled = false;
    btnSlow.disabled = false;
    btnFast.disabled = false;

    updateExpFeedback('Phenolphthalein indicator added. Solution remains colorless in acid. Begin titration!');
  });

  btnSwirl.addEventListener('click', () => {
    labSound.playClick();
    const flask = document.getElementById('conicalFlask');
    flask.classList.add('swirl-anim');
    setTimeout(() => flask.classList.remove('swirl-anim'), 800);
  });

  btnSingle.addEventListener('click', () => {
    dispenseTitrant(0.1);
  });

  btnSlow.addEventListener('click', () => {
    startContinuousFlow(0.2, 300);
    btnSlow.classList.add('active');
    btnFast.classList.remove('active');
    btnStop.disabled = false;
  });

  btnFast.addEventListener('click', () => {
    startContinuousFlow(0.5, 200);
    btnFast.classList.add('active');
    btnSlow.classList.remove('active');
    btnStop.disabled = false;
  });

  btnStop.addEventListener('click', () => {
    stopContinuousFlow();
  });

  btnDeclare.addEventListener('click', () => {
    stopContinuousFlow();
    const vol = state.expState.buretteVolume;
    if (vol >= 19.5 && vol <= 20.5) {
      labSound.playFanfare();
      state.expState.endpointReached = true;
      btnFinish.disabled = false;
      updateExpFeedback('🎯 PERFECT! Exact pale-pink neutralization equivalence reached at 20.0 mL (pH = 7.0)!');
      btnDeclare.disabled = true;
    } else if (vol < 19.5) {
      labSound.playError();
      state.stage4Mistakes++;
      updateExpFeedback(`⚠️ Under-titrated (${vol.toFixed(1)} mL). The solution is still acidic! Add more NaOH.`);
    } else {
      labSound.playError();
      state.stage4Mistakes++;
      updateExpFeedback(`⚠️ Over-titrated (${vol.toFixed(1)} mL)! You added excess base, turning the solution dark fuchsia.`);
      btnFinish.disabled = false;
    }
    updateHeaderScore();
  });
}

function startContinuousFlow(amount, rateMs) {
  stopContinuousFlow();
  document.getElementById('stopcockValve').classList.add('open');
  document.getElementById('stopcockValve').textContent = 'ON';
  document.getElementById('dropletStream').classList.add('dropping');

  titrationInterval = setInterval(() => {
    dispenseTitrant(amount);
  }, rateMs);
}

function stopContinuousFlow() {
  if (titrationInterval) {
    clearInterval(titrationInterval);
    titrationInterval = null;
  }
  const valve = document.getElementById('stopcockValve');
  const stream = document.getElementById('dropletStream');
  if (valve) {
    valve.classList.remove('open');
    valve.textContent = 'OFF';
  }
  if (stream) stream.classList.remove('dropping');

  const btnSlow = document.getElementById('btnSlowDrip');
  const btnFast = document.getElementById('btnFastFlow');
  if (btnSlow) btnSlow.classList.remove('active');
  if (btnFast) btnFast.classList.remove('active');
}

function dispenseTitrant(amount) {
  labSound.playWaterDrop();
  state.expState.buretteVolume = Math.min(50.0, state.expState.buretteVolume + amount);
  const vol = state.expState.buretteVolume;

  // Update Burette liquid UI
  const liquidBar = document.getElementById('buretteLiquidBar');
  const pct = Math.max(10, 90 - (vol / 50.0) * 80);
  if (liquidBar) liquidBar.style.height = `${pct}%`;

  // Update Metrics
  const buretteVal = document.getElementById('titrBuretteVal');
  const phVal = document.getElementById('titrPhVal');
  const colorVal = document.getElementById('titrColorVal');
  const flaskLiquid = document.getElementById('flaskLiquid');
  const btnDeclare = document.getElementById('btnDeclareEndpoint');

  if (buretteVal) buretteVal.textContent = `${vol.toFixed(1)} mL`;

  // Dynamic pH & Color Model
  let calcPh = 1.0;
  if (vol < 18.0) {
    calcPh = 1.0 + (vol / 18.0) * 2.0;
  } else if (vol < 19.8) {
    calcPh = 3.5 + ((vol - 18.0) / 1.8) * 2.5;
  } else if (vol <= 20.2) {
    calcPh = 7.0 + (vol - 20.0) * 4.0;
  } else {
    calcPh = Math.min(13.0, 10.0 + (vol - 20.2) * 0.4);
  }

  if (phVal) phVal.textContent = calcPh.toFixed(1);

  // Color change logic
  if (flaskLiquid && state.expState.hasIndicator) {
    if (vol < 19.5) {
      flaskLiquid.className = 'flask-liquid colorless';
      if (colorVal) {
        colorVal.textContent = 'Colorless';
        colorVal.style.color = '#64748B';
      }
    } else if (vol >= 19.5 && vol < 20.0) {
      flaskLiquid.className = 'flask-liquid transient-pink';
      if (colorVal) {
        colorVal.textContent = 'Faint Wisps';
        colorVal.style.color = '#F472B6';
      }
      if (btnDeclare) btnDeclare.disabled = false;
    } else if (vol >= 20.0 && vol <= 20.4) {
      flaskLiquid.className = 'flask-liquid pale-pink';
      if (colorVal) {
        colorVal.textContent = 'Permanent Pale Pink 🌸';
        colorVal.style.color = '#EC4899';
      }
      if (btnDeclare) btnDeclare.disabled = false;
    } else {
      flaskLiquid.className = 'flask-liquid over-titrated';
      if (colorVal) {
        colorVal.textContent = 'Over-titrated Magenta 🛑';
        colorVal.style.color = '#BE185D';
      }
      if (btnDeclare) btnDeclare.disabled = false;
    }
  }
}

// ----------------------------------------------------------------------------
// CALORIMETRY SIMULATION
// ----------------------------------------------------------------------------
function renderCalorimetrySim() {
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

  const viewport = document.getElementById('simViewport');
  viewport.innerHTML = `
    <div style="display: flex; flex-direction: column; align-items: center; position: relative;">
      <div style="font-size: 80px; filter: drop-shadow(0 4px 10px rgba(0,0,0,0.15));" id="calorimeterIcon">☕</div>
      <div style="position: absolute; top: 10px; right: -40px; background: white; border: 2px solid #7C3AED; padding: 6px 12px; border-radius: 8px; font-family: var(--font-mono); font-weight: 800; font-size: 16px; color: #7C3AED;" id="digitalProbe">
        22.0 °C
      </div>
      <div style="margin-top: 10px; font-family: var(--font-display); font-size: 13px; font-weight: 800; color: #2D144B;" id="calorStatus">
        Calorimeter Ready (Empty)
      </div>
    </div>
  `;

  const controls = document.getElementById('simControlsPanel');
  controls.innerHTML = `
    <div class="panel-section-title">🔥 1. CHARGE REACTANTS</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnAddAcidCal">
        <span>🧪 Add 50 mL 1.0 M HCl</span>
      </button>
      <button class="action-chip-btn" id="btnAddBaseCal" disabled>
        <span>🧪 Add 50 mL 1.0 M NaOH</span>
      </button>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">🔒 2. INSULATE & STIR</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnCloseLid" disabled>
        <span>🛡️ Close Insulated Lid</span>
      </button>
      <button class="action-chip-btn" id="btnStirCal" disabled>
        <span>🌀 Activate Stirrer</span>
      </button>
    </div>
  `;

  bindCalorimetryEvents();
}

function bindCalorimetryEvents() {
  const btnAcid = document.getElementById('btnAddAcidCal');
  const btnBase = document.getElementById('btnAddBaseCal');
  const btnLid = document.getElementById('btnCloseLid');
  const btnStir = document.getElementById('btnStirCal');
  const btnFinish = document.getElementById('btnFinishExperiment');

  btnAcid.addEventListener('click', () => {
    labSound.playWaterDrop();
    state.expState.acidAdded = true;
    btnAcid.disabled = true;
    btnAcid.classList.add('active');
    btnBase.disabled = false;
    document.getElementById('calorStatus').textContent = '50 mL HCl in Cup (22.0 °C)';
  });

  btnBase.addEventListener('click', () => {
    labSound.playWaterDrop();
    state.expState.baseAdded = true;
    btnBase.disabled = true;
    btnBase.classList.add('active');
    btnLid.disabled = false;
    document.getElementById('calorStatus').textContent = 'HCl + NaOH Mixed! Rapidly Close Lid!';
  });

  btnLid.addEventListener('click', () => {
    labSound.playClick();
    state.expState.lidClosed = true;
    btnLid.disabled = true;
    btnLid.classList.add('active');
    btnStir.disabled = false;
    document.getElementById('calorStatus').textContent = 'Calorimeter Sealed. Stir to Measure ΔT.';
  });

  btnStir.addEventListener('click', () => {
    labSound.playSuccess();
    btnStir.disabled = true;
    btnStir.classList.add('active');
    document.getElementById('calorStatus').textContent = 'Stirring... Exothermic reaction in progress! 📈';

    // Animate Temperature Rise
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
    }, 100);
  });
}

// ----------------------------------------------------------------------------
// FLAME TEST SIMULATION
// ----------------------------------------------------------------------------
function renderFlameTestSim() {
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

  const viewport = document.getElementById('simViewport');
  viewport.innerHTML = `
    <div style="display: flex; flex-direction: column; align-items: center; position: relative;">
      <div id="flameGlowEffect" style="width: 120px; height: 180px; border-radius: 50% 50% 20% 20%; background: radial-gradient(circle, #38BDF8 0%, #3B82F6 60%, transparent 80%); filter: blur(4px); box-shadow: 0 0 40px #38BDF8; transition: all 0.5s ease;"></div>
      <div style="width: 30px; height: 70px; background: #64748B; border-radius: 4px; margin-top: -10px;"></div>
      <div style="width: 70px; height: 14px; background: #334155; border-radius: 6px;"></div>
    </div>
  `;

  const controls = document.getElementById('simControlsPanel');
  controls.innerHTML = `
    <div class="panel-section-title">🌈 1. SELECT SAMPLE SALT</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnSampleNa">
        <span>🧂 NaCl (Sodium)</span>
      </button>
      <button class="action-chip-btn" id="btnSampleSr">
        <span>🧂 SrCl₂ (Strontium)</span>
      </button>
      <button class="action-chip-btn" id="btnSampleCu">
        <span>🧂 CuSO₄ (Copper)</span>
      </button>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">🧹 2. WIRE LOOP PROTOCOL</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnCleanLoop">
        <span>🧼 Clean Loop in Conc. HCl</span>
      </button>
    </div>
  `;

  bindFlameTestEvents();
}

function bindFlameTestEvents() {
  const glow = document.getElementById('flameGlowEffect');
  const sampleVal = document.getElementById('flameSampleVal');
  const lambdaVal = document.getElementById('flameLambdaVal');
  const btnFinish = document.getElementById('btnFinishExperiment');

  let testedCount = 0;

  document.getElementById('btnSampleNa').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #FDE047 0%, #EAB308 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #FDE047';
    sampleVal.textContent = 'Na⁺ (Sodium)';
    lambdaVal.textContent = '589 nm (Yellow)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('btnSampleSr').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #F87171 0%, #DC2626 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #EF4444';
    sampleVal.textContent = 'Sr²⁺ (Strontium)';
    lambdaVal.textContent = '650 nm (Crimson)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('btnSampleCu').addEventListener('click', () => {
    labSound.playSuccess();
    testedCount++;
    glow.style.background = 'radial-gradient(circle, #34D399 0%, #059669 60%, transparent 80%)';
    glow.style.boxShadow = '0 0 50px #10B981';
    sampleVal.textContent = 'Cu²⁺ (Copper)';
    lambdaVal.textContent = '510 nm (Green-Blue)';
    if (testedCount >= 2) btnFinish.disabled = false;
  });

  document.getElementById('btnCleanLoop').addEventListener('click', () => {
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
// 9. STAGE 5: REPORT & QUICK REVISION
// ============================================================================
function renderStage5() {
  const finalScore = state.calculateFinalScore();
  document.getElementById('finalScoreVal').textContent = `${finalScore}%`;

  // Stars
  const starsContainer = document.getElementById('starsDisplay');
  starsContainer.innerHTML = '';
  const starCount = finalScore >= 85 ? 3 : (finalScore >= 70 ? 2 : 1);
  for (let i = 0; i < 3; i++) {
    const s = document.createElement('span');
    s.className = `star ${i < starCount ? 'filled' : ''}`;
    s.textContent = '★';
    starsContainer.appendChild(s);
  }

  // Performance Breakdown
  document.getElementById('apparatusPerf').textContent = state.stage2Mistakes === 0 ? '100% (No Mistakes)' : `${state.stage2Mistakes} Mistakes`;
  document.getElementById('cupboardPerf').textContent = state.stage3Mistakes === 0 ? '100% (No Mistakes)' : `${state.stage3Mistakes} Mistakes`;
  document.getElementById('simPerf').textContent = state.stage4Mistakes === 0 ? 'Perfect Accuracy' : 'Completed with Retries';

  // Data Table Summary Log
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

  // Auto pop revision modal if desired or available
  renderRevisionContent();
}

function renderRevisionContent() {
  const mod = state.moduleData;
  document.getElementById('revisionTitle').textContent = `⚡ Quick Revision: ${mod.name}`;
  document.getElementById('revisionModalBody').innerHTML = mod.revision.content;
}

// ============================================================================
// 10. MODALS & TOAST NOTICES
// ============================================================================
function openHurrahModal() {
  document.getElementById('modalHurrah').classList.add('open');
}

function closeHurrahModal() {
  document.getElementById('modalHurrah').classList.remove('open');
}

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
// 11. QUESTLY FLUTTER BRIDGE EVENT SENDER
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