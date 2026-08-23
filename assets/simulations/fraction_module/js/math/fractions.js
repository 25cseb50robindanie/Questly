/**
 * Exact fraction helpers. Gameplay never relies on float sums.
 */
export function gcd(a, b) {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y) {
    const t = y;
    y = x % y;
    x = t;
  }
  return x || 1;
}

export function lcm(a, b) {
  return Math.abs(a * b) / gcd(a, b);
}

export function makeFrac(num, den) {
  if (den === 0) throw new Error("Denominator cannot be 0");
  return { num, den };
}

export function cloneFrac(f) {
  return { num: f.num, den: f.den };
}

export function simplify(f) {
  const g = gcd(f.num, f.den);
  return { num: f.num / g, den: f.den / g };
}

export function isSimplified(f) {
  return gcd(f.num, f.den) === 1;
}

export function toNumber(f) {
  return f.num / f.den;
}

export function labelOf(f) {
  if (f.num === 0) return "0";
  if (f.den === 1) return String(f.num);
  return `${f.num}/${f.den}`;
}

export function equalFrac(a, b) {
  return a.num * b.den === b.num * a.den;
}

export function compareFrac(a, b) {
  return a.num * b.den - b.num * a.den;
}

export function addFrac(a, b) {
  const den = lcm(a.den, b.den);
  const num = a.num * (den / a.den) + b.num * (den / b.den);
  return { num, den };
}

export function sumFracs(list) {
  return list.reduce((acc, f) => addFrac(acc, f), { num: 0, den: 1 });
}

/** Split a piece into two equal halves (1/2 → 1/4 + 1/4). */
export function splitFrac(f) {
  return [
    { num: f.num, den: f.den * 2 },
    { num: f.num, den: f.den * 2 }
  ];
}

export function canSplit(f) {
  return f.num > 0 && f.den > 0 && f.den * 2 <= 24;
}

export function formatMixed(f) {
  const s = simplify(f);
  return labelOf(s);
}
