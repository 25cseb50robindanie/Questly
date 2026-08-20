/**
 * Nova — Questly explorer guide. Original character (not a fox copy).
 */
export function novaSvg(id = "nova") {
  return `
    <svg id="${id}" class="nova-svg expression-neutral" viewBox="0 0 120 160" aria-hidden="true">
      <ellipse cx="60" cy="148" rx="28" ry="6" fill="rgba(0,0,0,0.25)"/>
      <circle cx="60" cy="52" r="36" fill="rgba(199,185,229,0.22)" stroke="#C7B9E5" stroke-width="3"/>
      <circle cx="60" cy="52" r="32" fill="rgba(255,255,255,0.07)" stroke="rgba(255,255,255,0.25)" stroke-width="2"/>
      <path d="M34 92 C 34 76, 86 76, 86 92 L 98 148 L 22 148 Z" fill="#118AB2" stroke="#4C3970" stroke-width="4"/>
      <rect x="48" y="100" width="24" height="18" rx="4" fill="#4C3970"/>
      <circle cx="60" cy="109" r="5" fill="#FFD166"/>
      <path d="M60 102 L 64 110 L 72 112 L 66 118 L 68 126 L 60 122 L 52 126 L 54 118 L 48 112 L 56 110 Z" fill="#FFD166" stroke="#4C3970" stroke-width="1"/>
      <circle cx="60" cy="52" r="24" fill="#F4EFE6" stroke="#4C3970" stroke-width="3"/>
      <line x1="60" y1="18" x2="60" y2="28" stroke="#4C3970" stroke-width="3"/>
      <circle class="nova-antenna" cx="60" cy="14" r="6" fill="#FFD166" stroke="#4C3970" stroke-width="2"/>
      <g class="nova-face-normal">
        <circle cx="50" cy="50" r="4" fill="#29213D"/>
        <circle cx="70" cy="50" r="4" fill="#29213D"/>
        <path d="M54 66 Q 60 72 66 66" fill="none" stroke="#29213D" stroke-width="2.5" stroke-linecap="round"/>
      </g>
      <g class="nova-face-happy">
        <path d="M46 52 Q 50 44 54 52" fill="none" stroke="#29213D" stroke-width="3" stroke-linecap="round"/>
        <path d="M66 52 Q 70 44 74 52" fill="none" stroke="#29213D" stroke-width="3" stroke-linecap="round"/>
        <path d="M52 62 Q 60 74 68 62 Z" fill="#FF8B94" stroke="#4C3970" stroke-width="2"/>
      </g>
      <g class="nova-face-worried">
        <circle cx="50" cy="50" r="4.5" fill="none" stroke="#29213D" stroke-width="2.5"/>
        <circle cx="70" cy="50" r="4.5" fill="none" stroke="#29213D" stroke-width="2.5"/>
        <path d="M54 68 Q 60 62 66 68" fill="none" stroke="#29213D" stroke-width="3" stroke-linecap="round"/>
      </g>
      <g class="nova-face-ecstatic">
        <path d="M48 46 L 52 54 L 60 56 L 54 62 L 56 70 L 48 66 L 40 70 L 42 62 L 36 56 L 44 54 Z" fill="#FFD166" stroke="#4C3970" stroke-width="1"/>
        <path d="M72 46 L 76 54 L 84 56 L 78 62 L 80 70 L 72 66 L 64 70 L 66 62 L 60 56 L 68 54 Z" fill="#FFD166" stroke="#4C3970" stroke-width="1"/>
        <path d="M50 60 Q 60 82 70 60 Z" fill="#FF8B94" stroke="#4C3970" stroke-width="3"/>
      </g>
    </svg>
  `;
}
