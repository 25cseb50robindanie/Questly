/**
 * QUESTLY VIRTUAL SCIENCE LAB ENGINE
 * High-fidelity, gamified, multi-module virtual lab simulator.
 * Supports: Acid-Base Titration, Smelting & Blast Furnace Metallurgy, Calorimetry, Flame Test.
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

  playFurnaceRoar() {
    if (!this.enabled) return;
    this._initCtx();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.linearRampToValueAtTime(140, now + 0.4);
    gain.gain.setValueAtTime(0.25, now);
    gain.gain.exponentialRampToValueAtTime(0.01, now + 0.5);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.5);
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
// 2. MODULE DATABASE (TITRATION, SMELTING, CALORIMETRY, FLAME TEST)
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
      { id: 'burette', name: 'Burette', icon: '📏', spec: '50 mL Volumetric', required: true },
      { id: 'conical_flask', name: 'Conical Flask', icon: '⚗️', spec: '250 mL Erlenmeyer', required: true },
      { id: 'pipette', name: 'Pipette', icon: '🧪', spec: '10 mL Volumetric', required: true },
      { id: 'stand_clamp', name: 'Retort Stand', icon: '📐', spec: 'Heavy Base + Clamp', required: true },
      { id: 'beaker', name: 'Beaker', icon: '🥛', spec: '100 mL Glass', required: false, wrongDesc: "A Beaker is for holding bulk liquids, not precision titration." },
      { id: 'crucible', name: 'Crucible', icon: '🥣', spec: 'Porcelain High Temp', required: false, wrongDesc: "A Crucible is for heating solids at high temperatures, not titration." },
      { id: 'test_tube', name: 'Test Tube', icon: '🧫', spec: 'Borosilicate 15 mL', required: false, wrongDesc: "Test tubes cannot accommodate continuous swirling for titration." },
      { id: 'tripod', name: 'Tripod Stand', icon: '🔺', spec: 'Steel Burner Support', required: false, wrongDesc: "Tripod stands are for heating, not titration." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_01', name: 'Hydrochloric Acid', formula: 'HCl', conc: '0.1 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'h2so4_conc', name: 'Sulfuric Acid (Conc)', formula: 'H₂SO₄', conc: '18.0 M', hazard: 'Severe Acid 🔥', required: false, shelf: 'A', wrongDesc: "Concentrated H₂SO₄ is too hazardous and not required for 0.1 M titration." },
        { id: 'acetic_acid', name: 'Acetic Acid', formula: 'CH₃COOH', conc: '0.5 M', hazard: 'Weak Acid ⚠️', required: false, shelf: 'A', wrongDesc: "Acetic Acid is a weak organic acid; we require strong 0.1 M HCl." },
        { id: 'distilled_water', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: false, shelf: 'A', wrongDesc: "Distilled water is for rinsing, but not the primary analyte." }
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
      { id: 'furnace_rig', name: 'Blast Furnace Rig', icon: '🌋', spec: 'Refractory Lined Tower', required: true },
      { id: 'pyrometer', name: 'Digital Pyrometer', icon: '🌡️', spec: 'Optical 0–2000°C Sensor', required: true },
      { id: 'tuyere_blower', name: 'Tuyere Blast Nozzle', icon: '💨', spec: 'Oxygen-Air Blower', required: true },
      { id: 'ladle_mold', name: 'Tapping Ladle', icon: '🪣', spec: 'Cast Iron Ingot Mold', required: true },
      { id: 'burette', name: 'Burette', icon: '📏', spec: '50 mL Glass', required: false, wrongDesc: "A Burette is for liquid titration and will melt instantly in a furnace!" },
      { id: 'condenser', name: 'Liebig Condenser', icon: '🧪', spec: 'Glass Distillation Tube', required: false, wrongDesc: "Liebig condensers are for laboratory liquid condensation." },
      { id: 'filter_paper', name: 'Filter Paper', icon: '📄', spec: 'Paper Filter Disk', required: false, wrongDesc: "Paper incinerates immediately at smelting temperatures." },
      { id: 'bunsen_burner', name: 'Bunsen Burner', icon: '🔥', spec: 'Small Lab Gas Burner', required: false, wrongDesc: "Bunsen burners only reach ~1000°C; smelting requires industrial tuyere air blasts (>1500°C)." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hematite_ore', name: 'Hematite Ore', formula: 'Fe₂O₃', conc: 'Ore Pellets', hazard: 'Mineral 🪨', required: true, shelf: 'A' },
        { id: 'metallurgical_coke', name: 'Metallurgical Coke', formula: 'C', conc: '90% Carbon', hazard: 'Fuel 🔥', required: true, shelf: 'A' },
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
            <li><strong>Density Separation:</strong> Molten slag ($\rho \approx 2.5\text{ g/cm}^3$) floats above molten iron ($\rho \approx 7.0\text{ g/cm}^3$), preventing re-oxidation.</li>
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
          modalDetails: `
            <h4>1. Heat of Reaction (q)</h4>
            <p><code>q = -(m_solution &times; c_water &times; &Delta;T)</code></p>
          `
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
      { id: 'calorimeter', name: 'Calorimeter Cup', icon: '☕', spec: 'Double Polystyrene Insulated', required: true },
      { id: 'thermometer', name: 'Digital Thermometer', icon: '🌡️', spec: '±0.1°C Electronic Probe', required: true },
      { id: 'stirrer', name: 'Stirring Rod', icon: '🥢', spec: 'Teflon Thermal Stirrer', required: true },
      { id: 'grad_cylinder', name: 'Graduated Cylinder', icon: '📐', spec: '50 mL Precision Glass', required: true },
      { id: 'bunsen', name: 'Bunsen Burner', icon: '🔥', spec: 'Gas Flame Burner', required: false, wrongDesc: "External heat from a burner will ruin calorimetry measurements!" },
      { id: 'filter_paper', name: 'Filter Paper', icon: '📄', spec: 'Whatman No. 1', required: false, wrongDesc: "Filter paper is for filtration, not calorimetry." },
      { id: 'dropper', name: 'Dropper Pipette', icon: '💧', spec: 'Rubber Teat Pipette', required: false, wrongDesc: "We need graduated cylinders for 50 mL volumes." },
      { id: 'evaporating_dish', name: 'Evaporating Dish', icon: '🥣', spec: 'Porcelain Flat Base', required: false, wrongDesc: "Evaporating dishes allow heat to escape rapidly." }
    ],
    cupboardPool: {
      shelfA: [
        { id: 'hcl_1m', name: 'Hydrochloric Acid', formula: 'HCl', conc: '1.0 M', hazard: 'Corrosive ⚠️', required: true, shelf: 'A' },
        { id: 'distilled_water_cal', name: 'Distilled Water', formula: 'H₂O', conc: 'Pure', hazard: 'Safe 💧', required: true, shelf: 'A' },
        { id: 'hno3_conc', name: 'Nitric Acid', formula: 'HNO₃', conc: '2.0 M', hazard: 'Oxidizer 🔥', required: false, shelf: 'A', wrongDesc: "Nitric acid has unwanted oxidation side reactions; use 1.0 M HCl." },
        { id: 'acetone', name: 'Acetone', formula: 'C₃H₆O', conc: 'Pure', hazard: 'Flammable 🔥', required: false, shelf: 'A', wrongDesc: "Acetone is not used in aqueous calorimetry." }
      ],
      shelfB: [
        { id: 'naoh_1m', name: 'Sodium Hydroxide', formula: 'NaOH', conc: '1.0 M', hazard: 'Caustic ⚠️', required: true, shelf: 'B' },
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
      { id: 'bunsen_burner', name: 'Bunsen Burner', icon: '🔥', spec: 'Adjustable Air Collar', required: true },
      { id: 'platinum_loop', name: 'Platinum Loop', icon: '🦯', spec: 'Nichrome/Pt Inert Wire', required: true },
      { id: 'watch_glass', name: 'Watch Glasses', icon: '🥏', spec: 'Porcelain / Glass Dish', required: true },
      { id: 'cobalt_glass', name: 'Cobalt Blue Glass', icon: '🟦', spec: 'Optical Spectral Filter', required: true },
      { id: 'burette', name: 'Burette', icon: '📏', spec: '50 mL Glass', required: false, wrongDesc: "Burettes are for liquid titration, not flame tests!" },
      { id: 'condenser', name: 'Liebig Condenser', icon: '🧪', spec: 'Distillation Tube', required: false, wrongDesc: "Liebig condensers are for distillation." },
      { id: 'mortar_pestle', name: 'Mortar & Pestle', icon: '🥣', spec: 'Agate Grinder', required: false, wrongDesc: "Salts are already finely powdered." },
      { id: 'separating_funnel', name: 'Separating Funnel', icon: '🔻', spec: 'Pear Shaped 250 mL', required: false, wrongDesc: "Separating funnels are for immiscible liquids." }
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
        stopcockOpen: false,
        flowMode: 'stop',
        endpointReached: false
      };
    } else if (this.currentModuleId === 'smelting') {
      this.expState = {
        chargedOre: false,
        chargedCoke: false,
        chargedFlux: false,
        tuyereBlastOn: false,
        temperature: 600, // °C
        reactionRate: 0,
        slagTapped: false,
        ironTapped: false,
        smeltingComplete: false
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
// 5. STAGE NAVIGATION & RENDERING
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
// 6. STAGE 2: APPARATUS SELECTION (WITH RED X & ERROR VOICE FEEDBACK)
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
// 7. STAGE 3: CHEMICAL & ORE STORAGE CUPBOARD
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
  bottle.className = `chemical-bottle ${isPicked ? 'picked' : ''}`;
  bottle.id = `bottle-${item.id}`;

  const liquidColor = state.currentModuleId === 'smelting' 
    ? (item.id === 'hematite_ore' ? '#78350F' : (item.id === 'metallurgical_coke' ? '#1E293B' : '#CBD5E1'))
    : (item.shelf === 'A' ? 'rgba(59, 130, 246, 0.45)' : 'rgba(236, 72, 153, 0.35)');

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
// 8. STAGE 4: EXPERIMENT SIMULATION BENCH
// ============================================================================
function renderStage4() {
  const mod = state.moduleData;
  document.getElementById('expTitle').textContent = `${mod.name} Simulation`;
  document.getElementById('expSubtitle').textContent = mod.subtitle;

  if (state.currentModuleId === 'titration') {
    renderTitrationSim();
  } else if (state.currentModuleId === 'smelting') {
    renderSmeltingSim();
  } else if (state.currentModuleId === 'calorimetry') {
    renderCalorimetrySim();
  } else if (state.currentModuleId === 'flametest') {
    renderFlameTestSim();
  }
}

// ----------------------------------------------------------------------------
// SMELTING EXPERIMENT SIMULATION (BLAST FURNACE & TEMP REGULATION)
// ----------------------------------------------------------------------------
function renderSmeltingSim() {
  const metrics = document.getElementById('expMetrics');
  metrics.innerHTML = `
    <div class="metric-card">
      <span class="metric-label">Hearth Pyrometer</span>
      <span class="metric-value" id="smeltTempVal" style="color: #F97316;">600 °C</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Thermal Zone</span>
      <span class="metric-value" id="smeltZoneVal" style="color: #EF4444;">Too Cold ❄️</span>
    </div>
    <div class="metric-card">
      <span class="metric-label">Molten Iron Yield</span>
      <span class="metric-value" id="smeltYieldVal">0.0%</span>
    </div>
  `;

  const viewport = document.getElementById('simViewport');
  viewport.innerHTML = `
    <div class="furnace-rig">
      <div class="furnace-top-hopper" id="furnaceHopper">📥 Hopper</div>
      <div class="furnace-body" id="furnaceBody">
        <div class="furnace-glow-core cold" id="furnaceGlow"></div>
        <div style="z-index: 2; font-family: var(--font-display); font-size: 11px; font-weight: 800; color: #FFFFFF; text-shadow: 0 2px 4px rgba(0,0,0,0.8);" id="furnaceStatusText">
          EMPTY CHARGE
        </div>
      </div>
      <div class="tuyere-blast-pipe">
        <div class="tuyere-nozzle" title="Left Tuyere"></div>
        <div class="tuyere-nozzle" title="Right Tuyere"></div>
      </div>
      <div class="molten-iron-stream" id="moltenIronStream"></div>
      <div class="iron-ladle-mold">
        <div class="ladle-molten-fill" id="ladleFill"></div>
        <span style="z-index: 2;">Iron Mold</span>
      </div>
      <div class="slag-tap-layer" id="slagTapBadge">Slag: 0%</div>
    </div>
  `;

  const controls = document.getElementById('simControlsPanel');
  controls.innerHTML = `
    <div class="panel-section-title">🧱 1. CHARGE RAW MATERIALS</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnChargeOre">
        <span>🪨 Load Fe₂O₃ Ore</span>
      </button>
      <button class="action-chip-btn" id="btnChargeCoke" disabled>
        <span>🔥 Load Coke (C)</span>
      </button>
      <button class="action-chip-btn" id="btnChargeFlux" disabled>
        <span>🧪 Load CaCO₃ Flux</span>
      </button>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">💨 2. TUYERE BLAST & TEMPERATURE REGULATION</div>
    <div class="control-btn-group">
      <button class="action-chip-btn" id="btnToggleBlast" disabled>
        <span>🌬️ Turn ON Air Blast</span>
      </button>
    </div>

    <div class="temp-slider-container" style="margin-top: 6px;">
      <div class="temp-slider-header">
        <span>Regulate Blast Furnace Temp:</span>
        <strong id="sliderTempDisplay">600 °C</strong>
      </div>
      <input type="range" id="tempRangeSlider" class="temp-range-input" min="300" max="2000" step="25" value="600" disabled>
    </div>

    <div class="panel-section-title" style="margin-top: 10px;">🌋 3. TAP MOLTEN METAL & SLAG</div>
    <div class="control-btn-group">
      <button class="primary-btn" id="btnTapIron" style="width: 100%; justify-content: center;" disabled>
        <span>🪣 Tap Molten Iron & Slag</span>
      </button>
    </div>
  `;

  bindSmeltingEvents();
}

function bindSmeltingEvents() {
  const btnOre = document.getElementById('btnChargeOre');
  const btnCoke = document.getElementById('btnChargeCoke');
  const btnFlux = document.getElementById('btnChargeFlux');
  const btnBlast = document.getElementById('btnToggleBlast');
  const slider = document.getElementById('tempRangeSlider');
  const sliderDisplay = document.getElementById('sliderTempDisplay');
  const btnTap = document.getElementById('btnTapIron');
  const btnFinish = document.getElementById('btnFinishExperiment');
  const glow = document.getElementById('furnaceGlow');
  const statusText = document.getElementById('furnaceStatusText');

  btnOre.addEventListener('click', () => {
    labSound.playClick();
    state.expState.chargedOre = true;
    btnOre.disabled = true;
    btnOre.classList.add('active');
    btnCoke.disabled = false;
    statusText.textContent = 'ORE LOADED (Fe₂O₃)';
    updateExpFeedback('Hematite ore added to top hopper. Now add metallurgical coke!');
  });

  btnCoke.addEventListener('click', () => {
    labSound.playClick();
    state.expState.chargedCoke = true;
    btnCoke.disabled = true;
    btnCoke.classList.add('active');
    btnFlux.disabled = false;
    statusText.textContent = 'ORE + COKE CHARGED';
    updateExpFeedback('Coke loaded. Add limestone (CaCO₃) flux to remove silica impurities!');
  });

  btnFlux.addEventListener('click', () => {
    labSound.playSuccess();
    state.expState.chargedFlux = true;
    btnFlux.disabled = true;
    btnFlux.classList.add('active');
    btnBlast.disabled = false;
    statusText.textContent = 'CHARGE COMPLETE (READY)';
    updateExpFeedback('All materials charged! Engage the tuyere hot air blast to initiate combustion.');
  });

  btnBlast.addEventListener('click', () => {
    labSound.playFurnaceRoar();
    state.expState.tuyereBlastOn = true;
    btnBlast.disabled = true;
    btnBlast.classList.add('active');
    btnBlast.innerHTML = '<span>💨 Tuyere Blast ACTIVE 🟢</span>';
    slider.disabled = false;
    btnTap.disabled = false;

    glow.className = 'furnace-glow-core warm';
    statusText.textContent = 'BURNING COKE (CO₂/CO)';
    updateExpFeedback('Air blast active! Use the temperature slider to regulate the blast furnace to optimal smelting range.');
  });

  slider.addEventListener('input', (e) => {
    const temp = parseInt(e.target.value, 10);
    state.expState.temperature = temp;
    sliderDisplay.textContent = `${temp} °C`;
    document.getElementById('smeltTempVal').textContent = `${temp} °C`;

    const zoneVal = document.getElementById('smeltZoneVal');

    if (temp < 1100) {
      glow.className = 'furnace-glow-core cold';
      zoneVal.textContent = 'Too Cold ❄️';
      zoneVal.style.color = '#EF4444';
      statusText.textContent = 'LOW HEAT (NO REDUCTION)';
    } else if (temp >= 1100 && temp < 1350) {
      glow.className = 'furnace-glow-core warm';
      zoneVal.textContent = 'Pre-Heating 🔥';
      zoneVal.style.color = '#F97316';
      statusText.textContent = 'REDUCING Fe₂O₃ → FeO';
    } else if (temp >= 1350 && temp <= 1600) {
      glow.className = 'furnace-glow-core optimal';
      zoneVal.textContent = 'Optimal Smelting 🌟';
      zoneVal.style.color = '#10B981';
      statusText.textContent = 'MOLTEN IRON (Fe) & SLAG';
    } else {
      glow.className = 'furnace-glow-core overheat';
      zoneVal.textContent = 'DANGEROUS OVERHEAT ⚠️';
      zoneVal.style.color = '#DC2626';
      statusText.textContent = 'REFRACTORY LINING AT RISK!';
    }
  });

  btnTap.addEventListener('click', () => {
    const temp = state.expState.temperature;

    if (temp < 1200) {
      labSound.playError();
      state.stage4Mistakes++;
      openTempAlert(
        '❄️ Temperature Too Low!',
        `At ${temp}°C, the reduction of hematite cannot complete and slag remains solid rock! The taphole cannot flow.`,
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

    // Optimal Smelting Execution
    labSound.playFanfare();
    state.expState.ironTapped = true;
    btnTap.disabled = true;

    // Show Molten Iron Stream & Ladle Fill Animation
    const stream = document.getElementById('moltenIronStream');
    const ladleFill = document.getElementById('ladleFill');
    const slagBadge = document.getElementById('slagTapBadge');

    stream.classList.add('flowing');
    ladleFill.style.height = '100%';
    slagBadge.textContent = 'Slag Tapped ✔';
    slagBadge.style.background = '#065F46';
    slagBadge.style.color = '#34D399';

    document.getElementById('smeltYieldVal').textContent = '98.5%';
    statusText.textContent = 'PURE MOLTEN IRON TAPPED!';

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

  const liquidBar = document.getElementById('buretteLiquidBar');
  const pct = Math.max(10, 90 - (vol / 50.0) * 80);
  if (liquidBar) liquidBar.style.height = `${pct}%`;

  const buretteVal = document.getElementById('titrBuretteVal');
  const phVal = document.getElementById('titrPhVal');
  const colorVal = document.getElementById('titrColorVal');
  const flaskLiquid = document.getElementById('flaskLiquid');
  const btnDeclare = document.getElementById('btnDeclareEndpoint');

  if (buretteVal) buretteVal.textContent = `${vol.toFixed(1)} mL`;

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