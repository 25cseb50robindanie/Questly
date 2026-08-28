/**
 * Dendy — Questly's signature Purple Fox companion and AI tutor.
 */
export function novaSvg(id = "dendy") {
  return `
    <svg id="${id}" class="nova-svg dendy-svg expression-neutral" viewBox="0 0 140 160" aria-hidden="true">
      <defs>
        <filter id="dendy-drop" x="-10%" y="-10%" width="120%" height="130%">
          <feDropShadow dx="0" dy="3" stdDeviation="2" flood-color="#131A26" flood-opacity="0.15"/>
        </filter>
      </defs>

      <!-- Ground Shadow -->
      <ellipse cx="70" cy="150" rx="38" ry="8" fill="rgba(19, 26, 38, 0.15)"/>

      <!-- Floating Fox Body Group -->
      <g class="dendy-body-group">
        <!-- 1. Fox Ears (Pointy large triangular ears) -->
        <!-- Left Fox Ear -->
        <path d="M 50 52 C 40 22, 22 6, 18 2 C 22 28, 30 54, 38 68 Z"
              fill="#8667C2" stroke="#131A26" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>
        <!-- Left Inner Ear (Lavender) -->
        <path d="M 46 50 C 39 26, 26 14, 23 11 C 25 30, 31 50, 36 60 Z"
              fill="#E2D8F3"/>

        <!-- Right Fox Ear -->
        <path d="M 90 52 C 100 22, 118 6, 122 2 C 118 28, 110 54, 102 68 Z"
              fill="#8667C2" stroke="#131A26" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>
        <!-- Right Inner Ear (Lavender) -->
        <path d="M 94 50 C 101 26, 114 14, 117 11 C 115 30, 109 50, 104 60 Z"
              fill="#E2D8F3"/>

        <!-- 2. Fox Head Shape (with side cheek fur tufts) -->
        <path d="M 70 28
                 C 38 28, 34 50, 30 70
                 L 16 78
                 L 26 88
                 C 36 116, 56 128, 70 128
                 C 84 128, 104 116, 114 88
                 L 124 78
                 L 110 70
                 C 106 50, 102 28, 70 28 Z"
              fill="#8667C2" stroke="#131A26" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"/>

        <!-- 3. White Muzzle / Lower Face Plate (horizontal waves) -->
        <path d="M 26 88
                 C 44 72, 58 80, 70 82
                 C 82 80, 96 72, 114 88
                 C 104 114, 84 126, 70 126
                 C 56 126, 36 114, 26 88 Z"
              fill="#FFFDF9" stroke="#131A26" stroke-width="2.5" stroke-linejoin="round"/>

        <!-- Muzzle Wave Boundary Line -->
        <path d="M 26 88 C 44 72, 58 80, 70 82 C 82 80, 96 72, 114 88"
              fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>

        <!-- 4. Forehead Glossy Shine Highlight -->
        <ellipse cx="84" cy="42" rx="9" ry="4.5" transform="rotate(-25 84 42)" fill="rgba(255, 255, 255, 0.48)"/>

        <!-- 5. Blush Cheeks (Rosy ovals on cheeks) -->
        <ellipse cx="36" cy="94" rx="8" ry="4.5" fill="#FFB5A7" opacity="0.85"/>
        <ellipse cx="104" cy="94" rx="8" ry="4.5" fill="#FFB5A7" opacity="0.85"/>

        <!-- 6. Cute Little Black Nose -->
        <path d="M 66 88 Q 70 85 74 88 Q 70 93 66 88 Z" fill="#131A26"/>

        <!-- === EXPRESSIONS === -->

        <!-- 1. NEUTRAL / IDLE FACE (Big shiny eyes with double sparkles) -->
        <g class="nova-face-normal">
          <circle cx="48" cy="70" r="7" fill="#131A26"/>
          <circle cx="46" cy="68" r="2.6" fill="#FFFFFF"/>
          <circle cx="51" cy="73" r="1.3" fill="#FFFFFF"/>

          <circle cx="92" cy="70" r="7" fill="#131A26"/>
          <circle cx="90" cy="68" r="2.6" fill="#FFFFFF"/>
          <circle cx="95" cy="73" r="1.3" fill="#FFFFFF"/>

          <!-- Gentle Smile -->
          <path d="M 64 96 Q 70 102 76 96" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
        </g>

        <!-- 2. HAPPY / SUCCESS FACE -->
        <g class="nova-face-happy">
          <!-- Joyful Arch Eyes -->
          <path d="M 42 72 Q 48 62 54 72" fill="none" stroke="#131A26" stroke-width="3.5" stroke-linecap="round"/>
          <path d="M 86 72 Q 92 62 98 72" fill="none" stroke="#131A26" stroke-width="3.5" stroke-linecap="round"/>
          <!-- Big Smile with Tongue -->
          <path d="M 62 96 Q 70 108 78 96 Z" fill="#FF8B94" stroke="#131A26" stroke-width="2.5"/>
        </g>

        <!-- 3. THINKING FACE -->
        <g class="nova-face-thinking">
          <circle cx="48" cy="68" r="7" fill="#131A26"/>
          <circle cx="50" cy="65" r="2.8" fill="#FFFFFF"/>
          <circle cx="92" cy="68" r="7" fill="#131A26"/>
          <circle cx="94" cy="65" r="2.8" fill="#FFFFFF"/>
          <!-- Raised Eyebrows -->
          <path d="M 42 58 Q 48 52 54 58" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
          <path d="M 86 60 Q 92 60 98 60" fill="none" stroke="#131A26" stroke-width="2" stroke-linecap="round"/>
          <!-- Curious mouth -->
          <ellipse cx="70" cy="98" rx="4" ry="5" fill="#FF8B94" stroke="#131A26" stroke-width="2"/>
          <!-- Gold Question Mark -->
          <path d="M 112 36 Q 118 24 114 16 Q 106 12 102 20 M 108 26 L 108 30" fill="none" stroke="#FFD166" stroke-width="3" stroke-linecap="round"/>
          <circle cx="108" cy="36" r="1.8" fill="#FFD166"/>
        </g>

        <!-- 4. WORRIED / CONFUSED FACE -->
        <g class="nova-face-worried">
          <circle cx="48" cy="70" r="7.5" fill="#FFFFFF" stroke="#131A26" stroke-width="2.5"/>
          <circle cx="48" cy="70" r="3.2" fill="#131A26"/>
          <circle cx="92" cy="70" r="7.5" fill="#FFFFFF" stroke="#131A26" stroke-width="2.5"/>
          <circle cx="92" cy="70" r="3.2" fill="#131A26"/>
          <!-- Wavy worried mouth -->
          <path d="M 64 99 Q 67 95 70 99 Q 73 103 76 99" fill="none" stroke="#131A26" stroke-width="2.5" stroke-linecap="round"/>
        </g>

        <!-- 5. ECSTATIC / CELEBRATING FACE -->
        <g class="nova-face-ecstatic">
          <!-- Sparkle Star Eyes -->
          <polygon points="48,60 50,66 56,68 50,70 48,76 46,70 40,68 46,66" fill="#FFD166" stroke="#131A26" stroke-width="1.2"/>
          <polygon points="92,60 94,66 100,68 94,70 92,76 90,70 84,68 90,66" fill="#FFD166" stroke="#131A26" stroke-width="1.2"/>
          <!-- Giant Grin -->
          <path d="M 60 94 Q 70 112 80 94 Z" fill="#FF8B94" stroke="#131A26" stroke-width="2.5"/>
          <path d="M 65 104 Q 70 100 75 104" fill="none" stroke="#131A26" stroke-width="2"/>
        </g>
      </g>
    </svg>
  `;
}

