import { equalFrac, sumFracs } from "./fractions.js";

export const QUARTER = { num: 1, den: 4 };
export const HALF = { num: 1, den: 2 };

export const EXPLORE_GOAL_IDS = ["two-quarters", "eighths-to-quarter"];

function isFrac(p) {
  return p && (p.kind === "frac" || (typeof p.num === "number" && typeof p.den === "number"));
}

function fracPieces(list) {
  return (list || []).filter(isFrac);
}

/** True if any single piece or any subset sums exactly to target (equivalent fractions included). */
export function collectionEqualsTarget(pieces, target) {
  const fracs = fracPieces(pieces);
  if (!fracs.length) return false;
  if (fracs.some((p) => equalFrac(p, target))) return true;
  const n = fracs.length;
  const limit = 1 << n;
  for (let mask = 1; mask < limit; mask++) {
    const subset = [];
    for (let i = 0; i < n; i++) {
      if (mask & (1 << i)) subset.push(fracs[i]);
    }
    if (subset.length && equalFrac(sumFracs(subset), target)) return true;
  }
  return false;
}

/**
 * Build-a-quarter is satisfied by any equivalent of 1/4:
 * a 1/4 plank, 2/8, 1/8+1/8, 3/12, a crafted inventory piece, etc.
 * Starter shelf 1/4 pieces do not count until placed or recrafted.
 */
export function hasQuarterEquivalent({ placed = [], inventory = [] } = {}) {
  const pizza = placed.filter((p) => p.zone === "pizza");
  const bar = placed.filter((p) => p.zone === "bar");
  const crafted = (inventory || []).filter((p) => p.crafted);
  return (
    collectionEqualsTarget(pizza, QUARTER) ||
    collectionEqualsTarget(bar, QUARTER) ||
    collectionEqualsTarget(placed, QUARTER) ||
    collectionEqualsTarget(crafted, QUARTER)
  );
}

export function hasHalfCover({ placed = [] } = {}) {
  const pizza = placed.filter((p) => p.zone === "pizza");
  const bar = placed.filter((p) => p.zone === "bar");
  return (
    collectionEqualsTarget(pizza, HALF) ||
    collectionEqualsTarget(bar, HALF) ||
    collectionEqualsTarget(placed, HALF)
  );
}

export function evaluateExploreGoals(state = {}) {
  return {
    "eighths-to-quarter": hasQuarterEquivalent(state),
    "two-quarters": hasHalfCover(state)
  };
}

export function syncExploreGoalIds(previousIds, evaluation, goalIds = EXPLORE_GOAL_IDS) {
  const prev = previousIds || [];
  const next = goalIds.filter((id) => evaluation[id]);
  return {
    next,
    newlyCompleted: next.filter((id) => !prev.includes(id)),
    lost: prev.filter((id) => !next.includes(id)),
    allComplete: goalIds.every((id) => evaluation[id])
  };
}
