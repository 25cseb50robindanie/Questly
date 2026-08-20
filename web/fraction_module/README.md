# Questly · Fraction Module (Canyon Crossings)

A full **Questly learning journey** for fractions, equivalent fractions, simplification, and ratios. Fraction Forge is **stage 4**, not the whole product.

## Intended flow

```
Questly Home → Math → Fractions & Ratios → Chapter Selection → Fraction Module
  1. Concept Learning
  2. Interactive Exploration
  3. Guided Mini Challenges
  4. Main Game (Fraction Forge)
  5. Final Challenge
  6. Results
  7. Revision → Back to Questly
```

Stages are sequential. The player cannot open the forge before seeing the idea and experimenting.

## Guide

**Nova** is an original Questly explorer. Feedback is spoken in Nova’s bubble — never `alert()`, never a raw “Wrong” stamp.

## How to run

```bash
python -m http.server 8000
```

Open `http://localhost:8000`. ES modules require a local server.

## Questly events

`gameId`: `fraction_forge`

- `QUESTLY_GAME_START` when the module begins
- `QUESTLY_GAME_PROGRESS` after each forge level
- `QUESTLY_GAME_COMPLETE` on the results screen (`score`, `stars`, `mistakes`, `completed: true`)

## Controls

- Drag pieces onto pizza, bars, bridge spans, or ratio towers
- Drop onto **Split**, **Merge**, or **Simplify** (or double-click: split if simple, simplify if not)
- Concept page has a single **Continue** control

## Stack

Vanilla HTML/CSS/JS, inline SVG, Web Audio, `localStorage` key `questly_fraction_module_v2`.
