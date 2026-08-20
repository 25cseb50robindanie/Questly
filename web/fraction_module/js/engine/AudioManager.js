/**
 * AudioManager handles all sound effects in the game using the Web Audio API.
 * This ensures zero external dependencies and guarantees offline compliance.
 */
export class AudioManager {
  constructor() {
    this.ctx = null;
    this.isMuted = false;
  }

  /**
   * Initialize Web Audio Context lazily on user interaction
   */
  _initContext() {
    if (!this.ctx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        this.ctx = new AudioContext();
      }
    }
    if (this.ctx && this.ctx.state === "suspended") {
      this.ctx.resume();
    }
  }

  /**
   * Set mute state
   */
  setMute(val) {
    this.isMuted = val;
    this._initContext();
  }

  /**
   * Helper to create a basic gain node envelope
   */
  _createGain(duration, startVal = 0.15, endVal = 0.0) {
    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(startVal, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(Math.max(0.0001, endVal), this.ctx.currentTime + duration);
    return gain;
  }

  /**
   * Play a clean click sound
   */
  playClick() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const osc = this.ctx.createOscillator();
    const gain = this._createGain(0.08, 0.08);

    osc.type = "sine";
    osc.frequency.setValueAtTime(600, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(150, this.ctx.currentTime + 0.08);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.08);
  }

  /**
   * Play a pick-up sound when grabbing a fraction block
   */
  playPickUp() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const osc = this.ctx.createOscillator();
    const gain = this._createGain(0.06, 0.05);

    osc.type = "sine";
    osc.frequency.setValueAtTime(350, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(550, this.ctx.currentTime + 0.05);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.06);
  }

  /**
   * Play a snap sound when dropping a block onto the bridge slot
   */
  playSnap() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const osc = this.ctx.createOscillator();
    const gain = this._createGain(0.05, 0.12);

    osc.type = "triangle";
    osc.frequency.setValueAtTime(180, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(60, this.ctx.currentTime + 0.04);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.05);
  }

  /**
   * Play a coin ding sound on scoring rewards
   */
  playCoinSound() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const now = this.ctx.currentTime;
    const playDing = (freq, delay) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = "sine";
      osc.frequency.setValueAtTime(freq, now + delay);

      gain.gain.setValueAtTime(0, now + delay);
      gain.gain.linearRampToValueAtTime(0.08, now + delay + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + delay + 0.25);

      osc.connect(gain);
      gain.connect(this.ctx.destination);

      osc.start(now + delay);
      osc.stop(now + delay + 0.3);
    };

    playDing(987.77, 0); // B5
    playDing(1318.51, 0.06); // E6
  }

  /**
   * Play a lock break chime on the roadmap completion unlock
   */
  playLockBreak() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const now = this.ctx.currentTime;

    const oscClick = this.ctx.createOscillator();
    const gainClick = this.ctx.createGain();
    oscClick.type = "triangle";
    oscClick.frequency.setValueAtTime(1200, now);
    gainClick.gain.setValueAtTime(0.15, now);
    gainClick.gain.exponentialRampToValueAtTime(0.0001, now + 0.05);

    oscClick.connect(gainClick);
    gainClick.connect(this.ctx.destination);
    oscClick.start(now);
    oscClick.stop(now + 0.06);

    setTimeout(() => {
      if (this.isMuted || !this.ctx) return;
      const tNow = this.ctx.currentTime;
      const oscClank1 = this.ctx.createOscillator();
      const oscClank2 = this.ctx.createOscillator();
      const gainClank = this.ctx.createGain();

      oscClank1.type = "sawtooth";
      oscClank1.frequency.setValueAtTime(320, tNow);
      oscClank1.frequency.linearRampToValueAtTime(150, tNow + 0.25);

      oscClank2.type = "sawtooth";
      oscClank2.frequency.setValueAtTime(325, tNow);
      oscClank2.frequency.linearRampToValueAtTime(152, tNow + 0.25);

      gainClank.gain.setValueAtTime(0.08, tNow);
      gainClank.gain.exponentialRampToValueAtTime(0.0001, tNow + 0.25);

      const lp = this.ctx.createBiquadFilter();
      lp.type = "lowpass";
      lp.frequency.setValueAtTime(500, tNow);

      oscClank1.connect(lp);
      oscClank2.connect(lp);
      lp.connect(gainClank);
      gainClank.connect(this.ctx.destination);

      oscClank1.start(tNow);
      oscClank2.start(tNow);
      oscClank1.stop(tNow + 0.26);
      oscClank2.stop(tNow + 0.26);
    }, 50);
  }

  /**
   * Play a magical success chime arpeggio
   */
  playSuccess() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const now = this.ctx.currentTime;
    const notes = [
      { f: 523.25, d: 0.0 }, // C5
      { f: 659.25, d: 0.08 }, // E5
      { f: 783.99, d: 0.16 }, // G5
      { f: 1046.50, d: 0.24 } // C6
    ];

    notes.forEach((note) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = "sine";
      osc.frequency.setValueAtTime(note.f, now + note.d);

      gain.gain.setValueAtTime(0, now + note.d);
      gain.gain.linearRampToValueAtTime(0.08, now + note.d + 0.04);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + note.d + 0.4);

      osc.connect(gain);
      gain.connect(this.ctx.destination);

      osc.start(now + note.d);
      osc.stop(now + note.d + 0.45);
    });
  }

  /**
   * Play a low failure sweep on wrong snaps
   */
  playFailure() {
    this._initContext();
    if (this.isMuted || !this.ctx) return;

    const now = this.ctx.currentTime;
    const duration = 0.5;

    const osc1 = this.ctx.createOscillator();
    const osc2 = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();

    osc1.type = "sawtooth";
    osc1.frequency.setValueAtTime(110, now);
    osc1.frequency.linearRampToValueAtTime(65, now + duration);

    osc2.type = "sawtooth";
    osc2.frequency.setValueAtTime(112, now);
    osc2.frequency.linearRampToValueAtTime(67, now + duration);

    filter.type = "lowpass";
    filter.frequency.setValueAtTime(200, now);

    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    osc1.connect(filter);
    osc2.connect(filter);
    filter.connect(gain);
    gain.connect(this.ctx.destination);

    osc1.start(now);
    osc2.start(now);
    osc1.stop(now + duration);
    osc2.stop(now + duration);
  }
}
