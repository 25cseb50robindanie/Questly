/* ==========================================================================
   QUESTLY - GAMIFIED LEARNING LOGIN PORTAL ENGINE & AUDIO/ANIMATION
   ========================================================================== */

// --- 1. WEB AUDIO SYNTHESIZER FOR GAME & SPLASH EFFECTS ---
class SoundEngine {
  constructor() {
    this.ctx = null;
    this.enabled = true;
  }

  init() {
    if (!this.ctx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        this.ctx = new AudioContext();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playClick() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(800, this.ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(400, this.ctx.currentTime + 0.05);
      gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.05);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.05);
    } catch (e) {}
  }

  playHover() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(520, this.ctx.currentTime);
      gain.gain.setValueAtTime(0.05, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.04);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.04);
    } catch (e) {}
  }

  playLevelUp() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const now = this.ctx.currentTime;
      const notes = [440, 554.37, 659.25, 880, 1108.73];
      notes.forEach((freq, idx) => {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(freq, now + idx * 0.09);
        gain.gain.setValueAtTime(0.3, now + idx * 0.09);
        gain.gain.exponentialRampToValueAtTime(0.01, now + idx * 0.09 + 0.35);
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start(now + idx * 0.09);
        osc.stop(now + idx * 0.09 + 0.35);
      });
    } catch (e) {}
  }

  playWhoosh() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const now = this.ctx.currentTime;
      const bufferSize = this.ctx.sampleRate * 0.4;
      const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
      }

      const noise = this.ctx.createBufferSource();
      noise.buffer = buffer;

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.setValueAtTime(300, now);
      filter.frequency.exponentialRampToValueAtTime(1400, now + 0.2);
      filter.frequency.exponentialRampToValueAtTime(200, now + 0.4);
      filter.Q.value = 3;

      const gain = this.ctx.createGain();
      gain.gain.setValueAtTime(0.01, now);
      gain.gain.linearRampToValueAtTime(0.35, now + 0.15);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);

      noise.connect(filter);
      filter.connect(gain);
      gain.connect(this.ctx.destination);

      noise.start(now);
      noise.stop(now + 0.4);
    } catch (e) {}
  }

  playSplash() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const now = this.ctx.currentTime;
      const bufferSize = this.ctx.sampleRate * 0.8;
      const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (this.ctx.sampleRate * 0.25));
      }

      const noise = this.ctx.createBufferSource();
      noise.buffer = buffer;

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(1200, now);
      filter.frequency.exponentialRampToValueAtTime(300, now + 0.6);

      const gain = this.ctx.createGain();
      gain.gain.setValueAtTime(0.5, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.8);

      noise.connect(filter);
      filter.connect(gain);
      gain.connect(this.ctx.destination);

      noise.start(now);
      noise.stop(now + 0.8);

      [520, 780, 1040, 1300].forEach((freq, idx) => {
        const osc = this.ctx.createOscillator();
        const g = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, now + idx * 0.08);
        osc.frequency.exponentialRampToValueAtTime(freq * 1.5, now + idx * 0.08 + 0.12);
        g.gain.setValueAtTime(0.12, now + idx * 0.08);
        g.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.08 + 0.12);
        osc.connect(g);
        g.connect(this.ctx.destination);
        osc.start(now + idx * 0.08);
        osc.stop(now + idx * 0.08 + 0.12);
      });
    } catch (e) {}
  }
}

const sounds = new SoundEngine();
window.sounds = sounds;

// --- 2. PARTICLE ENGINE FOR COSMIC STARDUST ---
class ParticleEngine {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    this.particles = [];
    this.resize();
    window.addEventListener('resize', () => this.resize());
    this.initParticles(70);
    this.animate();
  }

  resize() {
    this.width = this.canvas.width = window.innerWidth;
    this.height = this.canvas.height = window.innerHeight;
  }

  initParticles(count) {
    this.particles = [];
    for (let i = 0; i < count; i++) {
      this.particles.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        size: Math.random() * 2 + 0.5,
        speedX: (Math.random() - 0.5) * 0.3,
        speedY: (Math.random() - 0.5) * 0.3,
        alpha: Math.random() * 0.8 + 0.2,
        pulseSpeed: Math.random() * 0.02 + 0.005,
        color: ['#00f0ff', '#ffffff', '#ffd700', '#c084fc'][Math.floor(Math.random() * 4)]
      });
    }
  }

  animate() {
    this.ctx.clearRect(0, 0, this.width, this.height);
    this.particles.forEach(p => {
      p.x += p.speedX;
      p.y += p.speedY;
      p.alpha += Math.sin(Date.now() * p.pulseSpeed) * 0.01;

      if (p.x < 0) p.x = this.width;
      if (p.x > this.width) p.x = 0;
      if (p.y < 0) p.y = this.height;
      if (p.y > this.height) p.y = 0;

      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      this.ctx.fillStyle = p.color;
      this.ctx.globalAlpha = Math.max(0.1, Math.min(1, p.alpha));
      this.ctx.shadowBlur = p.size * 3;
      this.ctx.shadowColor = p.color;
      this.ctx.fill();
    });
    this.ctx.globalAlpha = 1;
    this.ctx.shadowBlur = 0;
    requestAnimationFrame(() => this.animate());
  }
}

// --- 3. MULTILINGUAL DICTIONARY (English, Tamil, Odia) ---
const QUESTLY_I18N = {
  en: {
    heroTagline: "Explore ✦ Learn ✦ Grow",
    heroSubtext: "The Gamified Learning Universe",
    speechDefault: "Welcome adventurer! Ready for today's quest?",
    speechWalk: "🐾 Dendy is bringing the Quest Water! 🌊",
    speechSplash: "✨ The Questly Universe is Unlocked! Dive in!",
    signInTab: "Sign In",
    createAccountTab: "Create Account",
    userPlaceholder: "Username or Email",
    passPlaceholder: "Password",
    rememberMe: "Remember Me",
    forgotPass: "Forgot Password?",
    loginBtn: "Login",
    newToQuestly: "New to Questly?",
    createAccountLink: "Create an Account ❯",
    regCodename: "Explorer Codename",
    regEmail: "Student or Parent Email",
    regPass: "Create Secret Password",
    regBtn: "Begin Adventure",
    alreadyHaveAccount: "Already have an account?",
    fillFields: "Please fill in all fields.",
    welcomeBack: (name) => `Welcome back, ${name}! Ready to explore?`,
    socialAlert: (provider) => `Connected via ${provider}! Welcome aboard.`,
    loginSuccess: "Portal Unlocked! Welcome.",
    replayIntro: "🌊 Replay Dendy Splash Intro ✨"
  },
  ta: {
    heroTagline: "ஆராய் ✦ கற்போம் ✦ வெல்வோம்",
    heroSubtext: "விளையாட்டு வழிக் கல்வி உலகம்",
    speechDefault: "வணக்கம் வீரனே! இன்றைய வினாடி வினாவிற்கு தயாரா?",
    speechWalk: "🐾 டெண்டி ஞான தீர்த்தத்தை கொண்டு வருகிறது! 🌊",
    speechSplash: "✨ க்வெஸ்ட்லி கல்வி உலகம் திறக்கப்பட்டது!",
    signInTab: "உள்நுழைய",
    createAccountTab: "புதிய கணக்கு",
    userPlaceholder: "பயனர்பெயர் அல்லது மின்னஞ்சல்",
    passPlaceholder: "கடவுச்சொல்",
    rememberMe: "என்னை நினைவில் கொள்",
    forgotPass: "கடவுச்சொல் மறந்ததா?",
    loginBtn: "உள்நுழைய",
    newToQuestly: "புதியவரா?",
    createAccountLink: "புதிய கணக்கு தொடங்க ❯",
    regCodename: "வீரர் பெயர்",
    regEmail: "மாணவர் / பெற்றோர் மின்னஞ்சல்",
    regPass: "புதிய ரகசிய கடவுச்சொல்",
    regBtn: "பயணத்தை தொடங்கு",
    alreadyHaveAccount: "ஏற்கனவே கணக்கு உள்ளதா?",
    fillFields: "தயவுசெய்து அனைத்து விவரங்களையும் நிரப்பவும்.",
    welcomeBack: (name) => `மீண்டும் நல்வரவு, ${name}!`,
    socialAlert: (provider) => `${provider} மூலம் இணைக்கப்பட்டது! நல்வரவு.`,
    loginSuccess: "கதவு திறக்கப்பட்டது! நல்வரவு.",
    replayIntro: "🌊 டெண்டி அறிமுக அனிமேஷனை மீண்டும் பார்க்க ✨"
  },
  or: {
    heroTagline: "ଅନୁସନ୍ଧାନ ✦ ଶିଖନ୍ତୁ ✦ ବୃଦ୍ଧି କରନ୍ତୁ",
    heroSubtext: "ଖେଳ ମାଧ୍ୟମରେ ଶିକ୍ଷା ଜଗତ",
    speechDefault: "ସ୍ୱାଗତ ସାହସୀ! ଆଜିର ପ୍ରଶ୍ନୋତ୍ତର ପାଇଁ ପ୍ରସ୍ତୁତ କି?",
    speechWalk: "🐾 ଡେଣ୍ଡି ଜ୍ଞାନ ଜଳ ଆଣୁଛି! 🌊",
    speechSplash: "✨ କ୍ୱେଷ୍ଟଲି ଜଗତ ଉନ୍ମୋଚିତ ହେଲା!",
    signInTab: "ପ୍ରବେଶ କରନ୍ତୁ",
    createAccountTab: "ନୂତନ ଖାତା",
    userPlaceholder: "ଉପଭୋକ୍ତା ନାମ କିମ୍ବା ଇମେଲ",
    passPlaceholder: "ପାସୱାର୍ଡ",
    rememberMe: "ମୋତେ ମନେ ରଖନ୍ତୁ",
    forgotPass: "ପାସୱାର୍ଡ ଭୁଲିଗଲେ କି?",
    loginBtn: "ପ୍ରବେଶ କରନ୍ତୁ",
    newToQuestly: "କ୍ୱେଷ୍ଟଲିରେ ନୂଆ କି?",
    createAccountLink: "ନୂତନ ଖାତା ଖୋଲନ୍ତୁ ❯",
    regCodename: "ସାହସୀ ନାମ",
    regEmail: "ଇମେଲ ଠିକଣା",
    regPass: "ଗୁପ୍ତ ପାସୱାର୍ଡ",
    regBtn: "ଅଭିଯାନ ଆରମ୍ଭ କରନ୍ତୁ",
    alreadyHaveAccount: "ପୂର୍ବରୁ ଖାତା ଅଛି କି?",
    fillFields: "ଦୟାକରି ସମସ୍ତ ବିବରଣୀ ପୂରଣ କରନ୍ତୁ।",
    welcomeBack: (name) => `ପୁନର୍ବାର ସ୍ୱାଗତ, ${name}!`,
    socialAlert: (provider) => `${provider} ସହିତ ସଂଯୁକ୍ତ ହେଲା!`,
    loginSuccess: "ଦ୍ୱାର ଉନ୍ମୁକ୍ତ ହେଲା!",
    replayIntro: "🌊 ପରିଚୟ ପୁନର୍ବାର ଦେଖନ୍ତୁ ✨"
  }
};

// --- 4. DYNAMIC LANGUAGE SWITCHER ---
function onLanguageChange(lang) {
  if (window.sounds) window.sounds.playClick();
  const dict = QUESTLY_I18N[lang] || QUESTLY_I18N.en;

  const loginLang = document.getElementById('login-language');
  const regLang = document.getElementById('reg-language');
  if (loginLang) loginLang.value = lang;
  if (regLang) regLang.value = lang;

  const tagline = document.querySelector('.questly-hero-tagline');
  if (tagline) tagline.innerHTML = dict.heroTagline;

  const subtext = document.getElementById('tagline-subtext');
  if (subtext) subtext.textContent = dict.heroSubtext;

  const speech = document.getElementById('foxy-speech-text');
  if (speech) speech.textContent = dict.speechDefault;

  const speechWalk = document.getElementById('dendy-speech-bubble-text');
  if (speechWalk) speechWalk.textContent = dict.speechWalk;

  const tabLogin = document.getElementById('tab-login');
  if (tabLogin) tabLogin.querySelector('span').textContent = dict.signInTab;

  const tabReg = document.getElementById('tab-register');
  if (tabReg) tabReg.querySelector('span').textContent = dict.createAccountTab;

  const loginUser = document.getElementById('login-username');
  if (loginUser) loginUser.placeholder = dict.userPlaceholder;

  const loginPass = document.getElementById('login-password');
  if (loginPass) loginPass.placeholder = dict.passPlaceholder;

  const lblRemember = document.getElementById('lbl-remember-me');
  if (lblRemember) lblRemember.textContent = dict.rememberMe;

  const lblForgot = document.getElementById('lbl-forgot-pw');
  if (lblForgot) lblForgot.textContent = dict.forgotPass;

  const btnLoginText = document.getElementById('btn-login-text');
  if (btnLoginText) btnLoginText.textContent = dict.loginBtn;

  const lblNew = document.getElementById('lbl-new-questly');
  if (lblNew) lblNew.textContent = dict.newToQuestly;

  const linkCreate = document.getElementById('link-create-account');
  if (linkCreate) linkCreate.textContent = dict.createAccountLink;

  const regUser = document.getElementById('reg-username');
  if (regUser) regUser.placeholder = dict.regCodename;

  const regEmail = document.getElementById('reg-email');
  if (regEmail) regEmail.placeholder = dict.regEmail;

  const regPass = document.getElementById('reg-password');
  if (regPass) regPass.placeholder = dict.regPass;

  const btnRegText = document.getElementById('btn-register-text');
  if (btnRegText) btnRegText.textContent = dict.regBtn;
}

// --- 5. TAB SWITCHER (SIGN IN / REGISTER) ---
function switchAuthTab(tab) {
  if (window.sounds) window.sounds.playClick();
  const tabLogin = document.getElementById('tab-login');
  const tabRegister = document.getElementById('tab-register');
  const formLogin = document.getElementById('questly-login-form');
  const formRegister = document.getElementById('questly-register-form');
  const sessionCard = document.getElementById('questly-session-card');
  const alertBox = document.getElementById('portal-alert');

  if (alertBox) alertBox.style.display = 'none';
  if (sessionCard) sessionCard.style.display = 'none';

  if (tab === 'login') {
    if (tabLogin) tabLogin.classList.add('active');
    if (tabRegister) tabRegister.classList.remove('active');
    if (formLogin) {
      formLogin.classList.add('active');
      formLogin.style.display = 'flex';
    }
    if (formRegister) {
      formRegister.classList.remove('active');
      formRegister.style.display = 'none';
    }
  } else {
    if (tabRegister) tabRegister.classList.add('active');
    if (tabLogin) tabLogin.classList.remove('active');
    if (formRegister) {
      formRegister.classList.add('active');
      formRegister.style.display = 'flex';
    }
    if (formLogin) {
      formLogin.classList.remove('active');
      formLogin.style.display = 'none';
    }
  }
}

// --- 6. PASSWORD VISIBILITY TOGGLE ---
function togglePasswordVisibility(inputId, btn) {
  if (window.sounds) window.sounds.playClick();
  const input = document.getElementById(inputId);
  if (!input) return;

  if (input.type === 'password') {
    input.type = 'text';
    btn.innerHTML = '<span class="toggle-eye-icon">🙈</span>';
  } else {
    input.type = 'password';
    btn.innerHTML = '<span class="toggle-eye-icon">👁</span>';
  }
}

// --- 7. CHECK ACTIVE SESSION & RENDER ---
function renderActiveSessionView() {
  let session = null;
  try {
    session = JSON.parse(localStorage.getItem('questly_user_session') || 'null');
  } catch (e) {}

  const sessionCard = document.getElementById('questly-session-card');
  const formLogin = document.getElementById('questly-login-form');
  const formRegister = document.getElementById('questly-register-form');
  const tabRow = document.getElementById('portal-tab-switch-row');

  if (session && session.loggedIn) {
    if (sessionCard) {
      sessionCard.style.display = 'block';
      const nameEl = document.getElementById('session-user-name');
      const stdEl = document.getElementById('session-standard-val');
      const langEl = document.getElementById('session-lang-val');
      if (nameEl) nameEl.textContent = `Welcome, ${session.name || 'Explorer'}!`;
      if (stdEl) stdEl.textContent = session.standard || 'Standard 8th';
      if (langEl) {
        const langMap = { en: '🇬🇧 English', ta: '🇮🇳 தமிழ் (Tamil)', or: '🇮🇳 ଓଡ଼ିଆ (Odia)' };
        langEl.textContent = langMap[session.language] || session.language || 'English';
      }
    }
    if (formLogin) formLogin.style.display = 'none';
    if (formRegister) formRegister.style.display = 'none';
    if (tabRow) tabRow.style.display = 'none';
  } else {
    if (sessionCard) sessionCard.style.display = 'none';
    if (tabRow) tabRow.style.display = 'flex';
    if (formLogin) formLogin.style.display = 'flex';
  }
}

// --- 8. LOGOUT / SWITCH ACCOUNT ---
function handleLogout() {
  if (window.sounds) window.sounds.playClick();
  localStorage.removeItem('questly_user_session');
  renderActiveSessionView();
  const speechText = document.getElementById('foxy-speech-text');
  if (speechText) speechText.textContent = "Switched to Guest. Ready for your quest?";
}

// --- 9. HANDLE LOGIN FORM SUBMIT ---
function handlePortalLogin(event) {
  event.preventDefault();
  const usernameInput = document.getElementById('login-username');
  const passwordInput = document.getElementById('login-password');
  const standardSelect = document.getElementById('login-standard');
  const languageSelect = document.getElementById('login-language');
  const alertBox = document.getElementById('portal-alert');
  const alertText = document.getElementById('portal-alert-text');
  const speechText = document.getElementById('foxy-speech-text');

  const username = usernameInput ? usernameInput.value.trim() : '';
  const password = passwordInput ? passwordInput.value.trim() : '';
  const standard = standardSelect ? standardSelect.value : 'Standard 8th';
  const language = languageSelect ? languageSelect.value : 'en';

  if (!username || !password) {
    if (alertBox && alertText) {
      alertText.textContent = QUESTLY_I18N[language]?.fillFields || "Please fill in all fields.";
      alertBox.style.display = 'flex';
    }
    if (window.sounds) window.sounds.playClick();
    return;
  }

  const session = {
    name: username,
    standard: standard,
    language: language,
    loggedIn: true,
    created: new Date().toISOString()
  };

  try {
    localStorage.setItem('questly_user_session', JSON.stringify(session));
  } catch (e) {}

  if (window.sounds) window.sounds.playLevelUp();
  if (speechText) speechText.textContent = QUESTLY_I18N[language]?.welcomeBack(username) || `Welcome back, ${username}!`;

  const loginBtn = document.getElementById('btn-portal-login');
  if (loginBtn) {
    loginBtn.innerHTML = `<span>✨ ${QUESTLY_I18N[language]?.loginSuccess || 'Logged In!'}</span>`;
  }

  setTimeout(() => {
    renderActiveSessionView();
    if (loginBtn) {
      loginBtn.innerHTML = `<span class="btn-cap-icon">🎓</span><span class="btn-text">Login</span><span class="btn-arrow-icon">❯</span>`;
    }
  }, 600);
}

// --- 10. HANDLE REGISTRATION FORM SUBMIT ---
function handlePortalRegister(event) {
  event.preventDefault();
  const usernameInput = document.getElementById('reg-username');
  const emailInput = document.getElementById('reg-email');
  const standardSelect = document.getElementById('reg-standard');
  const languageSelect = document.getElementById('reg-language');

  const username = usernameInput ? usernameInput.value.trim() : 'Explorer';
  const email = emailInput ? emailInput.value.trim() : '';
  const standard = standardSelect ? standardSelect.value : 'Standard 8th';
  const language = languageSelect ? languageSelect.value : 'en';

  const session = {
    name: username,
    email: email,
    standard: standard,
    language: language,
    loggedIn: true,
    created: new Date().toISOString()
  };

  try {
    localStorage.setItem('questly_user_session', JSON.stringify(session));
  } catch (e) {}

  if (window.sounds) window.sounds.playLevelUp();
  const regBtn = document.getElementById('btn-portal-register');
  if (regBtn) {
    regBtn.innerHTML = `<span>🚀 Account Created!</span>`;
  }

  setTimeout(() => {
    renderActiveSessionView();
    if (regBtn) {
      regBtn.innerHTML = `<span class="btn-cap-icon">🚀</span><span class="btn-text">Begin Adventure</span><span class="btn-arrow-icon">❯</span>`;
    }
  }, 600);
}

// --- 11. SOCIAL LOGINS (Google / Apple) ---
function quickSocialLogin(provider) {
  if (window.sounds) window.sounds.playClick();
  const speechText = document.getElementById('foxy-speech-text');
  const lang = document.getElementById('login-language')?.value || 'en';
  const standard = document.getElementById('login-standard')?.value || 'Standard 8th';

  const demoName = provider === 'Google' ? 'Explorer Learner' : 'Explorer Scout';
  const session = {
    name: demoName,
    standard: standard,
    language: lang,
    loggedIn: true
  };

  try {
    localStorage.setItem('questly_user_session', JSON.stringify(session));
  } catch (e) {}

  if (speechText) {
    speechText.textContent = QUESTLY_I18N[lang]?.socialAlert(provider) || `Welcome ${demoName}!`;
  }

  if (window.sounds) window.sounds.playLevelUp();
  setTimeout(() => {
    renderActiveSessionView();
  }, 600);
}

// --- 12. FORGOT PASSWORD HINT ---
function handleForgotPassword() {
  if (window.sounds) window.sounds.playClick();
  const speechText = document.getElementById('foxy-speech-text');
  const lang = document.getElementById('login-language')?.value || 'en';
  const hints = {
    en: "💡 Tip: Contact your school educator or parent email to reset password!",
    ta: "💡 உதவி: கடவுச்சொல்லை மீட்டமைக்க உங்கள் ஆசிரியர் அல்லது பெற்றோரை அணுகவும்!",
    or: "💡 ସୂଚନା: ପାସୱାର୍ଡ ପୁନରୁଦ୍ଧାର ପାଇଁ ଶିକ୍ଷକଙ୍କ ସହିତ ଯୋଗାଯୋଗ କରନ୍ତୁ!"
  };
  if (speechText) speechText.textContent = hints[lang] || hints.en;
}

// --- 13. DENDY WATER SPLASH INTRO ANIMATION CONTROLLER ---
let splashIntroCompleted = false;

function playSplashIntro(force = false) {
  const overlay = document.getElementById('dendy-splash-intro');
  const stage = document.getElementById('dendy-walk-stage');
  const speech = document.getElementById('dendy-intro-speech');
  const rig = document.getElementById('dendy-vector-rig');
  const bloom = document.getElementById('liquid-splash-bloom');
  const canvas = document.getElementById('water-splash-canvas');

  if (!overlay || !stage || !rig) return;

  if (!force && sessionStorage.getItem('questly_splash_seen')) {
    overlay.style.display = 'none';
    return;
  }

  overlay.style.display = 'flex';
  overlay.style.opacity = '1';
  bloom.classList.remove('active');
  stage.style.animation = 'none';
  rig.classList.remove('splashing');
  stage.offsetHeight; // trigger reflow

  // Start walking animation
  stage.style.animation = 'dendyWalkAcross 2.4s cubic-bezier(0.25, 1, 0.5, 1) forwards';

  // Speech bubble update on walk
  setTimeout(() => {
    if (window.sounds) window.sounds.playWhoosh();
  }, 400);

  // Splash triggering at 2.4s
  setTimeout(() => {
    if (splashIntroCompleted && !force) return;
    rig.classList.add('splashing');
    bloom.classList.add('active');
    if (speech) speech.style.opacity = '0';
    if (window.sounds) window.sounds.playSplash();

    triggerWaterDropletsPhysics(canvas);

    // Fade out overlay at 3.6s
    setTimeout(() => {
      overlay.style.transition = 'opacity 0.8s ease-out';
      overlay.style.opacity = '0';
      setTimeout(() => {
        overlay.style.display = 'none';
        sessionStorage.setItem('questly_splash_seen', 'true');
        splashIntroCompleted = true;
      }, 800);
    }, 1200);

  }, 2400);
}

function skipSplashIntro() {
  const overlay = document.getElementById('dendy-splash-intro');
  if (overlay) {
    overlay.style.transition = 'opacity 0.4s ease-out';
    overlay.style.opacity = '0';
    setTimeout(() => {
      overlay.style.display = 'none';
      sessionStorage.setItem('questly_splash_seen', 'true');
      splashIntroCompleted = true;
    }, 400);
  }
}

function triggerWaterDropletsPhysics(canvas) {
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const droplets = [];
  const cx = window.innerWidth / 2;
  const cy = window.innerHeight / 2;

  for (let i = 0; i < 90; i++) {
    const angle = Math.random() * Math.PI * 2;
    const speed = Math.random() * 12 + 4;
    droplets.push({
      x: cx,
      y: cy,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed - 2,
      radius: Math.random() * 5 + 2,
      alpha: 1,
      color: ['#38bdf8', '#00f0ff', '#ffffff', '#c084fc', '#60a5fa'][Math.floor(Math.random() * 5)]
    });
  }

  let frames = 0;
  function renderDroplets() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    droplets.forEach(d => {
      d.x += d.vx;
      d.y += d.vy;
      d.vy += 0.25; // gravity
      d.alpha -= 0.015;

      if (d.alpha > 0) {
        ctx.beginPath();
        ctx.arc(d.x, d.y, d.radius, 0, Math.PI * 2);
        ctx.fillStyle = d.color;
        ctx.globalAlpha = Math.max(0, d.alpha);
        ctx.fill();
      }
    });

    frames++;
    if (frames < 70) {
      requestAnimationFrame(renderDroplets);
    } else {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    }
  }
  renderDroplets();
}

// --- 14. INITIALIZE ON DOM READY ---
document.addEventListener('DOMContentLoaded', () => {
  new ParticleEngine('login-particle-canvas');
  playSplashIntro();
  renderActiveSessionView();

  // Attach hover sound to all interactive elements
  document.querySelectorAll('button, input, select, a').forEach(el => {
    el.addEventListener('mouseenter', () => {
      if (window.sounds) window.sounds.playHover();
    });
  });
});
