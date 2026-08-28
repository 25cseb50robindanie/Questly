/**
 * Dendy — Questly's signature Fox companion and AI tutor.
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
        <image href="assets/images/dendy_the_fox.png" x="10" y="10" width="120" height="135" preserveAspectRatio="xMidYMid meet" />
      </g>
    </svg>
  `;
}

