export const SUBJECTS = [
  {
    id: "math",
    title: "Math",
    blurb: "Build number sense through adventures.",
    unlocked: true,
    accent: "#118AB2"
  },
  {
    id: "science",
    title: "Science",
    blurb: "Coming soon on Questly.",
    unlocked: false,
    accent: "#06D6A0"
  },
  {
    id: "language",
    title: "Language",
    blurb: "Coming soon on Questly.",
    unlocked: false,
    accent: "#FF8B94"
  }
];

export const MATH_TOPICS = [
  {
    id: "fractions-ratios",
    title: "Fractions & Ratios",
    blurb: "See parts of a whole, then build equivalent amounts.",
    unlocked: true
  },
  {
    id: "decimals",
    title: "Decimals",
    blurb: "Unlock after Fractions & Ratios.",
    unlocked: false
  },
  {
    id: "percents",
    title: "Percents",
    blurb: "Unlock after Fractions & Ratios.",
    unlocked: false
  }
];

export const CHAPTERS = [
  {
    id: "canyon-crossings",
    title: "Chapter 1 · Canyon Crossings",
    blurb: "Nova’s valley bridges crumbled. Learn fractions, then rebuild them.",
    moduleId: "fraction-module",
    unlocked: true
  },
  {
    id: "ratio-recipes",
    title: "Chapter 2 · Ratio Recipes",
    blurb: "Locked until Chapter 1 is mastered.",
    unlocked: false
  },
  {
    id: "mixed-spans",
    title: "Chapter 3 · Mixed Spans",
    blurb: "Locked until Chapter 1 is mastered.",
    unlocked: false
  }
];

export const JOURNEY_STAGES = [
  { id: "concept", label: "Concept", name: "Concept Learning" },
  { id: "explore", label: "Experiment", name: "Interactive Exploration" },
  { id: "practice", label: "Practice", name: "Guided Mini Challenges" },
  { id: "game", label: "Game", name: "Fraction Forge" },
  { id: "challenge", label: "Challenge", name: "Final Challenge" },
  { id: "results", label: "Results", name: "Results" },
  { id: "revision", label: "Mastered", name: "Revision" }
];

export const CONCEPT_BEATS = [
  {
    id: "intro",
    nova: "Today we're learning fractions! A fraction shows equal parts of a whole.",
    caption: "Fractions Intro"
  },
  {
    id: "whole",
    nova: "This pizza is one whole. Look at its golden crust!",
    caption: "1 whole pizza"
  },
  {
    id: "halves",
    nova: "If we divide it into two equal parts... We call each piece one-half (1/2)!",
    caption: "Split into halves → 1/2"
  },
  {
    id: "quarters",
    nova: "If we divide it into four equal parts... We call each piece one-quarter (1/4)!",
    caption: "Split into quarters → 1/4"
  },
  {
    id: "eighths",
    nova: "And if we divide it into eight equal parts... We call each piece one-eighth (1/8)!",
    caption: "Split into eighths → 1/8"
  },
  {
    id: "equivalent",
    nova: "Watch closely: two quarters cover exactly the same space as one half. 2/4 and 1/2 are equivalent fractions!",
    caption: "Equivalence: 2/4 = 1/2"
  }
];

export const EXPLORE_GOALS = [
  {
    id: "two-quarters",
    title: "Cover one half",
    hint: "Place two 1/4 pieces so they cover the same space as 1/2."
  },
  {
    id: "eighths-to-quarter",
    title: "Build a quarter",
    hint: "Merge two 1/8 bars — they become 2/8. Simplify to 1/4."
  }
];

export const GUIDED_PUZZLES = [
  {
    id: "g1",
    title: "First Crossing",
    novaIntro: "This tiny bridge needs 3/4. Try placing 1/2, then add another piece.",
    target: { num: 3, den: 4 },
    inventory: [
      { num: 1, den: 2 },
      { num: 1, den: 4 },
      { num: 1, den: 4 }
    ],
    scoring: false,
    hints: [
      "Start with the blue 1/2 plank.",
      "1/2 is the same as 2/4. We still need one more 1/4.",
      "1/2 + 1/4 = 3/4. That fills the gap completely."
    ]
  },
  {
    id: "g2",
    title: "Two-Thirds Trail",
    novaIntro: "This gap is 2/3. Experiment. Four sixths make the same amount.",
    target: { num: 2, den: 3 },
    inventory: [
      { num: 1, den: 6 },
      { num: 1, den: 6 },
      { num: 1, den: 6 },
      { num: 1, den: 6 },
      { num: 1, den: 3 }
    ],
    scoring: false,
    hints: [
      "2/3 is the same as 4/6.",
      "You can use one 1/3 (that's 2/6) plus two 1/6 pieces.",
      "Four 1/6 planks also equal 2/3."
    ]
  },
  {
    id: "g3",
    title: "Eighths Creek",
    novaIntro: "Need 5/8. You may split a plank if a piece feels too big.",
    target: { num: 5, den: 8 },
    inventory: [
      { num: 1, den: 2 },
      { num: 1, den: 4 },
      { num: 1, den: 8 }
    ],
    scoring: false,
    hints: [
      "1/2 is 4/8. We need 5/8, so add one 1/8.",
      "Double-click a 1/4 to split it into two 1/8 pieces.",
      "4/8 + 1/8 = 5/8."
    ]
  }
];

export const GAME_LEVELS = [
  {
    id: "m1",
    title: "Valley Gutter",
    novaIntro: "Fraction Forge is live. Fill exactly 1/2 of the span.",
    type: "fraction",
    target: { num: 1, den: 2 },
    inventory: [
      { num: 1, den: 2 },
      { num: 1, den: 4 },
      { num: 1, den: 4 }
    ],
    xp: 40,
    coins: 8
  },
  {
    id: "m2",
    title: "Equivalent Crossing",
    novaIntro: "Same space, different pieces. Build 3/4 with halves and quarters.",
    type: "fraction",
    target: { num: 3, den: 4 },
    inventory: [
      { num: 1, den: 2 },
      { num: 1, den: 4 },
      { num: 1, den: 8 },
      { num: 1, den: 8 }
    ],
    xp: 55,
    coins: 12
  },
  {
    id: "m3",
    title: "Sixth Span",
    novaIntro: "2/3 of the canyon. Remember: 1/3 = 2/6.",
    type: "fraction",
    target: { num: 2, den: 3 },
    inventory: [
      { num: 1, den: 3 },
      { num: 1, den: 6 },
      { num: 1, den: 6 },
      { num: 1, den: 6 }
    ],
    xp: 70,
    coins: 14
  },
  {
    id: "m4",
    title: "Split the Beam",
    novaIntro: "Need 5/8. Double-click a piece to split it into two equal parts.",
    type: "fraction",
    target: { num: 5, den: 8 },
    inventory: [
      { num: 1, den: 2 },
      { num: 1, den: 4 }
    ],
    requireSplit: true,
    xp: 85,
    coins: 16
  },
  {
    id: "m5",
    title: "Ratio Towers",
    novaIntro: "Ratios compare two amounts. Stack red and blue supports in a 2:3 ratio.",
    type: "ratio",
    targetRatio: { red: 2, blue: 3 },
    inventory: [
      { kind: "ratio-red" },
      { kind: "ratio-red" },
      { kind: "ratio-red" },
      { kind: "ratio-red" },
      { kind: "ratio-blue" },
      { kind: "ratio-blue" },
      { kind: "ratio-blue" },
      { kind: "ratio-blue" },
      { kind: "ratio-blue" }
    ],
    xp: 100,
    coins: 20
  }
];

export const FINAL_CHALLENGE = {
  id: "royal",
  title: "The King's Bridge",
  novaIntro: "You've learned everything. Now build this bridge without my help.",
  xp: 200,
  coins: 50,
  sections: [
    {
      id: "sec-frac",
      title: "Span A · Fractions",
      type: "fraction",
      target: { num: 5, den: 6 },
      inventory: [
        { num: 1, den: 2 },
        { num: 1, den: 3 },
        { num: 1, den: 4 },
        { num: 1, den: 6 }
      ],
      requireEquivalent: true
    },
    {
      id: "sec-simp",
      title: "Span B · Simplify",
      type: "simplified",
      target: { num: 1, den: 2 },
      inventory: [
        { num: 1, den: 4 },
        { num: 1, den: 4 },
        { num: 2, den: 8 }
      ]
    },
    {
      id: "sec-ratio",
      title: "Span C · Ratio",
      type: "ratio",
      targetRatio: { red: 3, blue: 2 },
      inventory: [
        { kind: "ratio-red" },
        { kind: "ratio-red" },
        { kind: "ratio-red" },
        { kind: "ratio-red" },
        { kind: "ratio-blue" },
        { kind: "ratio-blue" },
        { kind: "ratio-blue" }
      ]
    }
  ]
};

export const TIME_ATTACK_POOL = [
  { target: { num: 1, den: 2 }, inventory: [{ num: 1, den: 2 }, { num: 1, den: 4 }, { num: 1, den: 4 }] },
  { target: { num: 3, den: 4 }, inventory: [{ num: 1, den: 2 }, { num: 1, den: 4 }, { num: 1, den: 8 }] },
  { target: { num: 2, den: 3 }, inventory: [{ num: 1, den: 3 }, { num: 1, den: 6 }, { num: 1, den: 6 }] },
  { target: { num: 5, den: 8 }, inventory: [{ num: 1, den: 2 }, { num: 1, den: 8 }, { num: 1, den: 8 }] },
  { target: { num: 1, den: 3 }, inventory: [{ num: 1, den: 6 }, { num: 1, den: 6 }, { num: 1, den: 3 }] }
];

export const PIECE_COLORS = {
  "1/2": "#118AB2",
  "1/3": "#06D6A0",
  "2/3": "#06D6A0",
  "1/4": "#FFD166",
  "2/4": "#FFD166",
  "3/4": "#FFD166",
  "1/6": "#C7B9E5",
  "2/6": "#C7B9E5",
  "1/8": "#FF8B94",
  "2/8": "#FF8B94",
  "3/8": "#FF8B94",
  "5/8": "#FF8B94",
  "ratio-red": "#FF8B94",
  "ratio-blue": "#118AB2"
};
