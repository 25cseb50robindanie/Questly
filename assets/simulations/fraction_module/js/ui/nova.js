/**
 * Dendy — Questly's signature Dinosaur/Fox companion and AI tutor.
 */
export function novaSvg(id = "dendy") {
  return `
    <svg id="${id}" class="nova-svg dendy-svg expression-neutral" viewBox="0 0 140 160" aria-hidden="true">
      <defs>
        <!-- Shadow -->
        <filter id="dendy-drop" x="-10%" y="-10%" width="120%" height="130%">
          <feDropShadow dx="0" dy="3" stdDeviation="2" flood-color="#131A26" flood-opacity="0.15"/>
        </filter>
      </defs>

      <!-- Ground Shadow -->
      <ellipse cx="70" cy="152" rx="34" ry="7" fill="rgba(19, 26, 38, 0.18)"/>

      <!-- Floating Dendy Body Group -->
      <g class="dendy-body-group">
        <!-- Left Ear -->
        <path d="M 44 48 C 36 28, 22 14, 18 10 C 22 36, 32 60, 36 68 Z" fill="#8667C2" stroke="#131A26" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>
        <path d="M 40 48 C 34 32, 25 22, 23 18 C 26 38, 32 56, 35 62 Z" fill="#E2D8F3"/>

        <!-- Right Ear -->
        <path d="M 96 48 C 104 28, 118 14, 122 10 C 118 36, 108 60, 104 68 Z" fill="#8667C2" stroke="#131A26" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>
        <path d="M 100 48 C 106 32, 115 22, 117 18 C 114 38, 108 56, 105 62 Z" fill="#E2D8F3"/>

        <!-- Cute Little Dinosaur Spikes behind head -->
        <polygon points="64,16 70,8 76,16" fill="#FFD166" stroke="#131A26" stroke-width="2"/>
        <polygon points="52,22 56,15 62,24" fill="#FFD166" stroke="#131A26" stroke-width="2"/>
        <polygon points="78,24 84,15 88,22" fill="#FFD166" stroke="#131A26" stroke-width="2"/>

        <!-- Main Head Shape with Cheek Tufts -->
        <path d="M 70 24
                 C 38 24, 32 50, 30 72
                 C 20 78, 16 86, 18 92
                 C 26 90, 30 86, 34 82
                 C 36 114, 60 128, 70 128
                 C 80 128, 104 114, 106 82
                 C 110 86, 114 90, 122 92
                 C 124 86, 120 78, 110 72
                 C 108 50, 102 24, 70 24 Z"
              fill="#8667C2" stroke="#131A26" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"/>

        <!-- White Muzzle Plate / Cheeks -->
        <path d="M 34 82
                 C 48 70, 60 76, 70 78
                 C 80 76, 92 70, 106 82
                 C 102 110, 84 126, 70 126
                 C 56 126, 38 110, 34 82 Z"
              fill="#FFFDF9" stroke="#131A26" stroke-width="2.5" stroke-linejoin="round"/>

        <!-- Forehead Glossy Highlight -->
        <ellipse cx="82" cy="38" rx="8" ry="4" transform="rotate(-20 82 38)" fill="rgba(255, 255, 255, 0.45)"/>

        <!-- Rosy Blush Cheeks -->
        <ellipse cx="40" cy="88" rx="7" ry="4" fill="#FF8B94" opacity="0.85"/>
        <ellipse cx="100" cy="88" rx="7" ry="4" fill="#FF8B94" opacity="0.85"/>

        <!-- Cute Little Black Nose -->
        <path d="M 66 84 Q 70 82 74 84 Q 70 88 66 84 Z" fill="#131A26"/>

        <!-- === EXPRESSIONS === -->

        <!-- 1. NEUTRAL / IDLE FACE -->
        <g class="nova-face-normal">
          <!-- Eyes -->
          <circle cx="50" cy="66" r="6" fill="#131A26"/>
          <circle cx="52" cy="64" r="2.2" fill="#FFFFFF"/>
          <circle cx="90" cy="66" r="6" fill="#131A26"/>
          <circle cx="92" cy="64" r="2.2" fill="#FFFFFF"/>
          <!-- Gentle Smile -->
          <path d="M 64 92 Q 70 98 76 92" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
        </g>

        <!-- 2. HAPPY / SUCCESS FACE -->
        <g class="nova-face-happy">
          <!-- Joyful Crescent Eyes -->
          <path d="M 44 68 Q 50 60 56 68" fill="none" stroke="#131A26" stroke-width="3.5" stroke-linecap="round"/>
          <path d="M 84 68 Q 90 60 96 68" fill="none" stroke="#131A26" stroke-width="3.5" stroke-linecap="round"/>
          <!-- Big Smile with Tongue -->
          <path d="M 62 92 Q 70 106 78 92 Z" fill="#FF8B94" stroke="#131A26" stroke-width="2.5"/>
        </g>

        <!-- 3. THINKING FACE -->
        <g class="nova-face-thinking">
          <!-- Looking Up Eyes -->
          <circle cx="50" cy="64" r="6" fill="#131A26"/>
          <circle cx="52" cy="61" r="2.5" fill="#FFFFFF"/>
          <circle cx="90" cy="64" r="6" fill="#131A26"/>
          <circle cx="92" cy="61" r="2.5" fill="#FFFFFF"/>
          <!-- Raised Eyebrow -->
          <path d="M 44 56 Q 50 50 56 56" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
          <path d="M 84 58 Q 90 58 96 58" fill="none" stroke="#131A26" stroke-width="2" stroke-linecap="round"/>
          <!-- Curious mouth -->
          <ellipse cx="70" cy="94" rx="4" ry="5" fill="#FF8B94" stroke="#131A26" stroke-width="2"/>
        </g>

        <!-- 4. WORRIED / CONFUSED FACE -->
        <g class="nova-face-worried">
          <circle cx="50" cy="66" r="6.5" fill="#FFFFFF" stroke="#131A26" stroke-width="2.5"/>
          <circle cx="50" cy="66" r="3" fill="#131A26"/>
          <circle cx="90" cy="66" r="6.5" fill="#FFFFFF" stroke="#131A26" stroke-width="2.5"/>
          <circle cx="90" cy="66" r="3" fill="#131A26"/>
          <!-- Wavy worried mouth -->
          <path d="M 64 96 Q 67 92 70 96 Q 73 100 76 96" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
        </g>

        <!-- 5. ECSTATIC / CELEBRATING FACE -->
        <g class="nova-face-ecstatic">
          <!-- Star Eyes -->
          <polygon points="50,58 52,64 58,66 52,68 50,74 48,68 42,66 48,64" fill="#FFD166" stroke="#131A26" stroke-width="1"/>
          <polygon points="90,58 92,64 98,66 92,68 90,74 88,68 82,66 88,64" fill="#FFD166" stroke="#131A26" stroke-width="1"/>
          <!-- Giant Grin -->
          <path d="M 60 90 Q 70 110 80 90 Z" fill="#FF8B94" stroke="#131A26" stroke-width="2.5"/>
          <path d="M 65 100 Q 70 96 75 100" fill="none" stroke="#131A26" stroke-width="2"/>
        </g>
      </g>
    </svg>
  `;
}
