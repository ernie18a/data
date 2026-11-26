# Wyckoff Phase Classifier

- url: https://www.tradingview.com/script/9ap94IDt-Wyckoff-Phase-Classifier/
- type: indicator
- pine_id: PUB;881d52eab174416b8df6eb708e6b9bb2
- version: 5.0

## Description

🏗️ Wyckoff Phase Classifier — Detect Accumulation, Reaccumulation & Distribution

Automatically detects where a stock is in the Wyckoff cycle. Labels each phase directly on the chart — with BU▲ / BE▼ sentiment tags — draws key support/resistance levels, shades the background by pattern type, and fires alerts when critical events happen — Spring, SOS, UTAD, SOW.

One-click market presets for WIG20, mWIG40/sWIG80 and NewConnect (or fully custom).

---
📖 THE THREE PATTERNS IT DETECTS
---

ACCUMULATION (after a downtrend)
SC → AR → ST → Spring → Test → SOS → LPS → Markup ↑
Smart money builds a position at the bottom. Selling Climax absorbs supply, Automatic Rally establishes the range top, Secondary Test confirms support. Spring shakes out weak hands below support and recovers. Sign of Strength breaks out. Markup begins.

REACCUMULATION (pause inside an uptrend)
BC → AR → ST → Spring → Test → SOS → LPS → Markup ↑
Same structure but starts with a Buying Climax at a local top. Price consolidates before the next leg up.

DISTRIBUTION (top formation before a markdown)
BC → AR → ST → UTAD → SOW → LPSY → Markdown ↓
Same BC entry as reaccumulation — but instead of a Spring below support, price does an Upthrust After Distribution (UTAD): a false breakout above resistance that immediately fails. Sign of Weakness follows. Markdown confirmed.

---
🧭 MARKUP ≠ ACCUMULATION (and Markdown ≠ Distribution)
---

A common confusion. They are different phases that follow each other — never overlap:

Accumulation  →  RANGE (sideways), smart money quietly buys
Markup        →  TREND ↑, price rises directionally, smart money already holds the position

Distribution  →  RANGE (sideways at the top), smart money quietly sells
Markdown      →  TREND ↓, price falls directionally, smart money already exited

The full Wyckoff cycle:

   Accumulation  →  Markup  →  Distribution  →  Markdown  →  Accumulation  →  …
       ↑              ↑              ↑              ↑
    sideways       trend ↑       sideways       trend ↓
    range                          range

Reaccumulation is a miniature accumulation INSIDE a markup (a pause/correction in the uptrend). On a multi-timeframe view this is where things look layered — D1 shows the macro Markup, while 1h shows a smaller Reaccumulation forming inside it. They are two different indicators on two different timeframes, each painting independently.

Visually in this indicator:
- Range phases (Accumulation, Reaccumulation, Distribution) → background tint
- Trend phases (Markup, Markdown) → a colored line tracing highs (Markup) or lows (Markdown)

This separates "where price is consolidating" from "where price is trending" so the chart never gets flooded with a multi-month background fill.

---
🌀 SUB-CYCLES INSIDE A MARKUP
---

Markup is rarely a clean uninterrupted trend. Mini-cycles often form inside it. The state machine catches them:

While in MARKUP (phase 8), if a new climax pivot high appears with a bearish close (close in lower 55% of the bar), the indicator starts a sub-cycle — BC label, then AR, ST, and bifurcation:
→ Spring → SOS = Reaccumulation, markup resumes after SOS
→ UTAD → SOW → MARKDOWN = macro markup invalidated, markdown line starts

The markup line pauses while the sub-cycle's range is active (range background paints instead). After the sub-cycle's SOS the markup line resumes. After a sub-cycle's MARKDOWN the markup line ends and the markdown line begins.

Sub-BC criteria are slightly stricter than top-level BC (closePos ≤ 0.55 vs ≤ 0.60) — tight enough to skip shallow LPS-style pullbacks, loose enough to catch real sub-BCs with moderate bearish closes.

---
🔀 HOW BIFURCATION WORKS
---

Accumulation vs Distribution is decided after the Secondary Test. Two things can happen next:

→ Spring: low dips below support, close recovers above = accumulation path
→ UTAD: high breaks above resistance, close falls back below = distribution path

The indicator runs one state machine and branches automatically at that point. Background is ORANGE during pre-bifurcation (phases BC/AR/ST, is_reaccum=true). When Spring fires it shifts to PURPLE (reaccumulation confirmed). When UTAD fires it shifts to RED (distribution confirmed).

---
🔍 MINIMUM RANGE FILTER
---

AR is only accepted if the distance between support and resistance is at least minRangePct. This eliminates micro-cycles in sideways, low-liquidity markets — a common false-positive source on GPW smallcaps.

Preset values: WIG20 = 8% / mWIG40 = 8% / NewConnect = 15%

---
📊 WHAT YOU SEE ON THE CHART
---

Labels on each confirmed phase — each tagged with ▲BU (bullish event) or ▼BE (bearish event):

PS  ▲BU — Preliminary Support (first institutional buying before SC)
PSY ▼BE — Preliminary Supply (first institutional selling before BC)
SC  ▲BU — Selling Climax (capitulation bottom)
BC  ▼BE — Buying Climax (exhaustion top)
AR  ▲BU / ▼BE — Automatic Rally (after SC) or Automatic Reaction (after BC)
ST  ▲BU / ▼BE — Secondary Test (validates support or resistance)
Spring ▲BU — False breakdown (accumulation confirmed)
UTAD   ▼BE — False breakout (distribution confirmed)
Test   ▲BU — Low-vol retest of Spring area
SOS    ▲BU — Sign of Strength (breakout, markup incoming)
SOW    ▼BE — Sign of Weakness (breakdown, markdown incoming)
LPS    ▲BU — Last Point of Support (final entry before markup)
LPSY   ▼BE — Last Point of Supply (final exit before markdown)
MARKUP ↑ ▲BU / MARKDOWN ↓ ▼BE — Phase confirmed

Background shading by pattern type (range phases only):
🔵 Cyan    = Accumulation range (SC path, phases 1–7)
🟠 Orange  = Pre-bifurcation (BC/AR/ST with is_reaccum=true — outcome unknown, Spring or UTAD pending)
🟣 Purple  = Reaccumulation confirmed (Spring fired, phases 4–7 — markup expected)
🔴 Red     = Distribution range (UTAD path, phases 23–25)

Trend phase lines (no background fill — keeps the chart clean):
🟢 Green line tracing highs  = Markup active (persists until a new SC/BC cycle is confirmed)
🔴 Red line tracing lows     = Markdown active (persists until a new SC/BC cycle is confirmed)

Markup line stays active throughout the trend — it persists past phase 8 timeout and only clears when a new top-level SC cycle confirms. Sub-BCs inside markup do NOT clear it (the macro markup is preserved through the sub-cycle).
Markdown line clears as soon as the post-MARKDOWN AR rally fires — markdown is over once the bounce confirms.

Dashed lines — support and resistance, extend right until reset
Table (top right) — current pattern, current phase, preset, support/resistance, spring low, vol/MA ratio. The pattern row reads "BC/AR — pre-bifurkacja" while the cycle is still ambiguous and shifts to "REAKUMULACJA ↑" or "DYSTRYBUCJA ↓" once Spring or UTAD fires.

---
⚙️  MARKET PRESETS
---

One dropdown configures all 7 thresholds simultaneously:

                  WIG20    mWIG40/sWIG80    NewConnect
Climax mult       2.0x         1.5x           1.5x
Test vol max      0.70x        0.70x          0.80x
Spring tolerance  0.5%         1.0%           2.0%
ST tolerance      2.0%         3.0%           5.0%
Min range         8%           8%             15%
SOS/SOW move      1.5%         1.0%           0.5%
Phase timeout     60 bars      100 bars       120 bars

Select "— Custom —" to override any value manually.

---
⚙️  KEY PARAMETERS (Custom mode)
---

Pivot lookback / confirmation — bars left/right to confirm a swing. Default 3/2 = 2-bar lag on D1, non-repainting.
Climax vol multiplier — volume must exceed MA × this to qualify as BC or SC.
Test/Spring max vol — tests and Springs should be quiet. Default 0.7x MA.
Spring/UTAD tolerance — how far price can break through support/resistance before invalidation. Deep Springs (beyond tolerance but with a hammer candle) are caught automatically regardless of this value.
Min range (%) — minimum support–resistance spread to accept a cycle.
Phase timeout — resets state machine if no progression within N bars.

---
🎯 WHAT TO LOOK FOR
---

The Spring is the highest-conviction signal — a false breakdown that immediately reverses. Alert fires the moment close recovers above support. The candle must look like a hammer (close in upper 55%+ of the bar's range) — eliminates shallow false Springs.

UTAD is the distribution equivalent — requires a bearish rejection candle (close in lower 45% of range). If you see UTAD on a stock after a multi-month uptrend, treat it as a serious warning — especially if ESPI Front-Runner shows a DUMP LEAK on the same candle.

SOS + elevated volume after Spring = markup almost certain.

Spring without SOS follow-through within timeout bars = state resets. A failed Spring is a valid signal in the opposite direction.

PS / PSY labels (Preliminary Support / Supply) fire when volume is elevated (85%+ of climax threshold) but not yet at climax level. They are informational-only — they do not start a cycle, just warn that institutional interest is building.

---
💡 SYNERGY WITH THE TOOLKIT
---

AutomatOff + ST/Test: algo silence during a Secondary Test confirms no one wants to fight the support
VW Drift ACCUM + Spring: low-vol drift into support while Spring fires = institutional absorption
ESPI Front-Runner DUMP LEAK + BC: climax top with front-running = distribution BC (BRY / PXM pattern)
VP Change KLASTER↓ + UTAD: new volume cluster forming at resistance before false breakout = pre-planned distribution

---
⚠️  LIMITATIONS
---

OHLCV only — no order book, no tick data. Spring and UTAD require the recovery/failure within the same bar (close-based). On low-liquidity stocks, one large order can trigger a false Spring.
Pivots lag by pivotRight bars (default 2). On D1 this is 2 trading days.
Sub-cycles are supported INSIDE a markup (sub-BC at climax high during phase 8) but not yet inside a markdown. Deeply nested structures may still need manual zoom-out.
Pre-bifurcation phases (BC/AR/ST with is_reaccum=true) show ORANGE — outcome unknown, could resolve into either reaccumulation (purple after Spring) or distribution (red after UTAD). Do not trade until Spring or UTAD fires.
Deep Springs (close far below support but with hammer candle) update the support level to the new low. This is by design — the machine anchors to where the actual reversal happened.

---

Open source. Part of the Łowca Cwaniaków / GPW Anomaly Detection Toolkit — indicators built specifically for detecting smart money footprints on the Warsaw Stock Exchange.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fis_wse
//
// Wyckoff Phase Classifier v3 — "Cykl cwaniaka"
// Detects Wyckoff accumulation, reaccumulation AND distribution phases.
//
// ACCUMULATION:   SC  → AR → ST → Spring → Test → SOS → LPS  → Markup ↑
// REACCUMULATION: BC  → AR → ST → Spring → Test → SOS → LPS  → Markup ↑
// DISTRIBUTION:   BC  → AR → ST → UTAD   → SOW  → LPSY       → Markdown ↓
//
// Bifurcation after ST:
//   low < support  AND close > support  → Spring  → accumulation path
//   high > resistance AND close < resistance → UTAD → distribution path
//
// Optimised for GPW small/mid-cap (D1, 1h). Works on any OHLCV market.
//
// v3 changes:
//   - Preset system (WIG20 / mWIG40/sWIG80 / NewConnect / Custom)
//   - minRangePct: minimum support–resistance spread to accept a cycle
//   - Volume/price checks now reference the pivot bar, not the current bar (pv_*)
//
// Part of the Łowca Cwaniaków / GPW Anomaly Detection Toolkit

//@version=6
indicator("Wyckoff Phase Classifier — Cykl cwaniaka", shorttitle="Wyckoff", overlay=true,
     max_labels_count=500, max_lines_count=200, max_boxes_count=100)

// ─────────────────────────────────────────
// 📋  MARKET PRESET 
// ─────────────────────────────────────────

g_preset  = "📋 Market Preset"
presetStr = input.string("Mid Cap (mWIG40 / sWIG80)", "Market preset",
     options=["Large Cap (WIG20)", "Mid Cap (mWIG40 / sWIG80)", "Small Cap (NewConnect)", "— Custom —"],
     group=g_preset,
     tooltip="Auto-configures all thresholds for the selected market segment.\nSelect '— Custom —' to set values manually.")

showFullNames = input.bool(false, "Show full phase names on labels",
     group=g_preset,
     tooltip="OFF: compact labels (SC, AR, ST…).\nON: full labels (SC — Selling Climax, AR — Auto Rally…). Useful for presentations / screenshots.")

_pL = presetStr == "Large Cap (WIG20)"
_pM = presetStr == "Mid Cap (mWIG40 / sWIG80)"
_pS = presetStr == "Small Cap (NewConnect)"
_pC = presetStr == "— Custom —"

// ─────────────────────────────────────────
// ⚙️  SETTINGS
// ─────────────────────────────────────────

g_pivot = "Pivot Detection"
pivotLeft  = input.int(3, "Pivot lookback (left bars)",      minval=1, maxval=20, group=g_pivot,
     tooltip="Bars to the left of a swing required to confirm it as a pivot.")
pivotRight = input.int(2, "Pivot confirmation (right bars)", minval=1, maxval=10, group=g_pivot,
     tooltip="Bars to the right required. Lower = faster but may repaint. 2 = 2-bar lag on D1.")

g_vol = "Volume Thresholds"
volLen      = input.int(20,   "Volume MA length",                   minval=5,   maxval=200, group=g_vol)
climaxMult_ = input.float(2.0,"Climax vol multiplier (Custom)",     minval=1.0, maxval=8.0, step=0.1, group=g_vol,
     tooltip="Preset values — WIG20: 2.0x  mWIG40: 1.5x  NewConnect: 1.5x")
testVolMax_ = input.float(0.7,"Test/Spring/LPSY max vol (Custom)",  minval=0.1, maxval=1.5, step=0.05, group=g_vol,
     tooltip="Preset values — WIG20: 0.70x  mWIG40: 0.70x  NewConnect: 0.80x")
sowVolMin   = input.float(1.0,"SOW/SOS min vol ratio",              minval=0.5, maxval=5.0, step=0.1, group=g_vol,
     tooltip="Sign of Strength / Sign of Weakness must have volume ABOVE MA × this.")

g_price = "Price Thresholds"
stTol_     = input.float(3.0,"ST test tolerance (%) (Custom)",     minval=0.1, maxval=10.0, step=0.1, group=g_price,
     tooltip="Preset values — WIG20: 2.0%  mWIG40: 3.0%  NewConnect: 5.0%")
springTol_ = input.float(1.0,"Spring/UTAD tolerance (%) (Custom)", minval=0.1, maxval=5.0,  step=0.1, group=g_price,
     tooltip="Preset values — WIG20: 0.5%  mWIG40: 1.0%  NewConnect: 2.0%")
movePct_   = input.float(1.0,"SOS/SOW min bar move (%) (Custom)",  minval=0.1, maxval=10.0, step=0.1, group=g_price,
     tooltip="Preset values — WIG20: 1.5%  mWIG40: 1.0%  NewConnect: 0.5%")
minRange_  = input.float(10.0,"Min range support→resistance (%) (Custom)", minval=1.0, maxval=50.0, step=0.5, group=g_price,
     tooltip="AR is only accepted if the support–resistance spread is at least this wide.\nFilters out micro-cycles in choppy/sideways markets.\nPreset values — WIG20: 8%  mWIG40: 8%  NewConnect: 15%")
resetBars_ = input.int(80,   "Phase timeout (bars) (Custom)",       minval=10, maxval=500, group=g_price,
     tooltip="Preset values — WIG20: 60  mWIG40: 100  NewConnect: 120")

// ── Preset resolver ─────────────────────
climaxMult = _pC ? climaxMult_ : _pL ? 2.0  : _pM ? 1.5  : _pS ? 1.5  : climaxMult_
testVolMax = _pC ? testVolMax_ : _pL ? 0.70 : _pM ? 0.70 : _pS ? 0.80 : testVolMax_
stTol      = _pC ? stTol_      : _pL ? 2.0  : _pM ? 3.0  : _pS ? 5.0  : stTol_
springTol  = _pC ? springTol_  : _pL ? 0.5  : _pM ? 1.0  : _pS ? 2.0  : springTol_
movePct    = _pC ? movePct_    : _pL ? 1.5  : _pM ? 1.0  : _pS ? 0.5  : movePct_
minRange   = _pC ? minRange_   : _pL ? 8.0  : _pM ? 8.0  : _pS ? 15.0 : minRange_   // Mid Cap: 8% catches stable mWIG40 cycles
resetBars  = _pC ? resetBars_  : _pL ? 60   : _pM ? 100  : _pS ? 120  : resetBars_

g_vis = "Visual Settings"
showLabels = input.bool(true, "Show phase labels",         group=g_vis)
showBuBe   = input.bool(true, "Show BU▲/BE▼ tag on labels", group=g_vis)
showLines  = input.bool(true, "Show key level lines",      group=g_vis)
showBg     = input.bool(true, "Show background shading",   group=g_vis)
showTable  = input.bool(true, "Show current phase table",  group=g_vis)
showLegend = input.bool(true, "Show color legend",         group=g_vis,
     tooltip="Bottom-right legend mapping background tints to Wyckoff phase names.")
lbSize     = input.string(size.small, "Label size", options=[size.tiny, size.small, size.normal], group=g_vis)

// Accumulation / neutral colours
colBC      = input.color(#F87171,                "BC color",         group=g_vis)  // rose-400  (distribution top)
colSC      = input.color(#22D3EE,                "SC color",         group=g_vis)  // cyan-400  (capitulation bottom — bullish)
colAR      = input.color(#FBBF24,                "AR color",         group=g_vis)  // amber-400 (neutral bounce)
colST      = input.color(#FDE68A,                "ST color",         group=g_vis)  // amber-200 (neutral retest)
colSpring  = input.color(#4ADE80,                "Spring color",     group=g_vis)  // green-400 (bullish reversal)
colTest    = input.color(#86EFAC,                "Test color",       group=g_vis)  // green-300 (spring confirmation)
colSOS     = input.color(#16A34A,                "SOS color",        group=g_vis)  // green-700 (confirmed breakout)
colLPS     = input.color(#0EA5E9,                "LPS color",        group=g_vis)  // sky-500   (last support hold)
// Distribution colours
colUTAD    = input.color(#FB923C,                "UTAD color",       group=g_vis)  // orange-400 (false breakout)
colSOW     = input.color(#EF4444,                "SOW color",        group=g_vis)  // red-500   (weakness confirmed)
colLPSY    = input.color(#B91C1C,                "LPSY color",       group=g_vis)  // red-700   (final supply)
// Backgrounds — pattern-specific. Distinct hue per category so warm colors
// (red/orange/pink) don't all blur together at high transparency.
colBgAccum         = input.color(color.new(#22D3EE, 85), "Accumulation bg",        group=g_vis)  // cyan   — SC path, pre-breakout
colBgPreBif        = input.color(color.new(#FACC15, 85), "Pre-bifurcation bg",     group=g_vis)  // yellow — BC/AR/ST, outcome unknown (was orange — clashed with distribution)
colBgReaccum       = input.color(color.new(#9B59B6, 85), "Reaccumulation bg",      group=g_vis)  // purple — Spring confirmed
colBgMarkupShade   = input.color(color.new(#4ADE80, 85), "Markup phase shading",   group=g_vis)  // green  — phase 6/7/8 active markup
colBgDistr         = input.color(color.new(#F87171, 85), "Distribution bg",        group=g_vis)  // rose   — UTAD/SOW/LPSY
colBgMarkdownShade = input.color(color.new(#EF4444, 75), "Markdown phase shading", group=g_vis)  // red    — phase 26 active markdown (least transparent — critical signal)
colBgMarkup        = input.color(color.new(#16A34A, 0),  "Markup line color",      group=g_vis)  // green-700 — markup trend line (full opacity)
colBgMarkdown      = input.color(color.new(#DC2626, 0),  "Markdown line color",    group=g_vis)  // red-600   — markdown trend line (full opacity)

// ─────────────────────────────────────────
// 📐  CALCULATIONS
// ─────────────────────────────────────────

volMa        = ta.sma(volume, volLen)
isClimaxVol  = volume > volMa * climaxMult
isLowVol     = volume < volMa * testVolMax
isStrongVol  = volume > volMa * sowVolMin

// Close position within bar range (0 = at low, 1 = at high)
closePos     = (high - low) > 0 ? (close - low) / (high - low) : 0.5

// Bar move as % of open (positive = bullish, negative = bearish)
barMovePct   = open > 0 ? (close - open) / open * 100 : 0.0

// ── At-pivot-bar versions ─────────────────────────────────────────────────────
// Pivot confirmation fires on bar N, but the actual pivot was at bar N-pivotRight.
// Volume/price checks MUST reference the pivot bar, not the current bar.
// (pivotRight is a simple int input → [pivotRight] indexing is legal in Pine Script)
pv_closePos    = (high[pivotRight] - low[pivotRight]) > 0
                  ? (close[pivotRight] - low[pivotRight]) / (high[pivotRight] - low[pivotRight])
                  : 0.5
pv_isClimaxVol = volume[pivotRight] > volMa[pivotRight] * climaxMult
pv_isLowVol    = volume[pivotRight] < volMa[pivotRight] * testVolMax

// Confirmed pivots — non-repainting, lag = pivotRight bars
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low,   pivotLeft, pivotRight)

// Prior trend: SMA direction over lookback window
// 50-bar SMA compared 50 bars back = ~2.5 months on D1.
// Prevents SC firing during distribution (prices still above 50-bar SMA from 50 bars ago)
// and prevents BC firing during accumulation (prices still below).
trendSma   = ta.sma(close, 50)
priorTrend = trendSma[50] < trendSma ? 1 : -1   // 1 = uptrend, -1 = downtrend

// ─────────────────────────────────────────
// 🏗️  STATE MACHINE
// ─────────────────────────────────────────
//
// ACCUMULATION / REACCUMULATION path  (bullish outcome):
//   0  = IDLE
//   1  = SC   Selling Climax
//   10 = BC   Buying Climax (reaccum start)
//   2  = AR   Automatic Reaction / Rally
//   3  = ST   Secondary Test          ← BIFURCATION POINT
//   4  = SPRING  false breakdown → close above support
//   5  = TEST    low-vol retest of Spring
//   6  = SOS     Sign of Strength
//   7  = LPS     Last Point of Support
//   8  = MARKUP
//
// DISTRIBUTION path  (bearish outcome):
//   Shares 10 (BC) → 2 (AR) → 3 (ST), then diverges:
//   23 = UTAD    false breakout above resistance → close below resistance
//   24 = SOW     Sign of Weakness, breaks below support
//   25 = LPSY    Last Point of Supply, weak rally
//   26 = MARKDOWN

var int   phase      = 0
var float support    = na     // key support  (SC low or AR low)
var float resistance = na     // key resistance (AR high or BC high)
var float spring_lo  = na     // Spring low watermark
var int   phase_bar  = 0      // bar_index when current phase was set
var bool  is_reaccum = false  // true = pattern started from BC (uptrend)
var bool  is_subcycle = false // true = cycle started from within MARKUP/MARKDOWN (sub-BC in phase 8)
                              // — used to keep markupActive set across the sub-cycle's AR confirm

// ── Persistent trend background flags ────────────────────────────────────────
// phase == 8/26 resets to 0 after resetBars (so the machine can detect a new
// SC/BC), but the MARKUP / MARKDOWN background should persist until a new
// confirmed cycle begins (AR flush of SC/BC pending label).
var bool  markupActive   = false  // stays true after MARKUP fires
var bool  markdownActive = false  // stays true after MARKDOWN fires
var float markupSupport  = na    // last LPS support when MARKUP fired — kept for diagnostics
var float markupHigh     = na    // highest close during active markup — used for trailing-stop markdown trigger
var float md_lowest      = na    // lowest close since entering phase 26 — used to gate AR confirmation
var float sow_low        = na    // lowest close since entering phase 24/25 — used for distribution invalidation

// ── Pending SC / BC label ─────────────────────────────────────────────────────
// SC and BC labels are NOT drawn immediately on detection.
// They are stored here and drawn only when AR is confirmed (= the cycle is real).
// This prevents label spam on 1h where many high-vol pivots fire + immediately reset.
var int    pend_bar   = na
var float  pend_price = na
var string pend_txt   = ""
var string pend_sty   = label.style_label_up
var color  pend_col   = color.gray

// ── helpers ──────────────────────────────

_near(float a, float b, float pct) =>
    not na(a) and not na(b) and math.abs(a - b) / b * 100 <= pct


// Returns short or full label name depending on showFullNames toggle
_lname(string short, string full) =>
    showFullNames ? short + " — " + full : short

// Appends bullish/bearish tag when showBuBe is enabled
_tag(bool isBull) =>
    showBuBe ? (isBull ? " ▲BU" : " ▼BE") : ""

_lbl(int bIdx, float price, string txt, string sty, color col) =>
    if showLabels
        label.new(bIdx, price, txt,
             style     = sty,
             color     = col,
             textcolor = color.white,
             size      = lbSize)

// ── PHASE 0 → SC or BC ───────────────────
// Also detects PS (Preliminary Support) and PSY (Preliminary Supply):
// standalone informational labels that mark the first institutional absorption
// BEFORE the climax event.  They do NOT start a cycle — only SC/BC do.
//
// Volume tiers:
//   PS / PSY : vol > MA × (climaxMult × 0.85)   — near-climax, clearly elevated
//   SC / BC  : vol > MA × climaxMult             — climax (pv_isClimaxVol)
// 0.85 threshold keeps PS/PSY rare (only the most significant pre-climax bars).
// 0.65 was too loose — generated label spam on 1h.

pv_isPreClimaxVol = volume[pivotRight] > volMa[pivotRight] * (climaxMult * 0.85) and not pv_isClimaxVol

// ── MARKUP PEAK TRACKING ──────────────────────────────────────────────────────
// Track highest close while markup is active. Used as the trailing-stop reference
// for failed-markup detection (5× stTol drawdown from peak = MARKDOWN).
// markupHigh updates on every markupActive bar, regardless of phase (8, 10, 2, 0…),
// so sub-cycles within macro markup also extend the peak.
if markupActive and (na(markupHigh) or close > markupHigh)
    markupHigh := close

// ── MARKUP FAILURE — phase 0 + markupActive ──────────────────────────────────
// Phase 8 timed out → machine went IDLE, but markupActive is still true.
// Trailing-stop trigger: close drops 5× stTol below the highest-close-during-markup
// → MARKDOWN. For mWIG40 (stTol=3%) that's a 15% drawdown from peak.
if phase == 0 and markupActive and not na(markupHigh)
    if close < markupHigh * (1.0 - stTol * 5.0 / 100.0)
        markupActive   := false
        markdownActive := true
        markupSupport  := na
        markupHigh     := na
        phase          := 26
        phase_bar      := bar_index
        _lbl(bar_index, low,
             (showFullNames ? "MARKDOWN ↓ — Nieudany Markup" : "MARKDOWN ↓") + _tag(false),
             label.style_label_up, colSOW)

if phase == 0
    // SC: high-vol pivot LOW at pivot bar, close in upper 40%+ of bar (supply absorbed)
    // priorTrend == -1: require a confirmed prior downtrend before labelling as Selling Climax.
    // Without this guard, drops within an ongoing distribution (where trend is still UP or sideways)
    // would incorrectly fire SC and paint the chart green. E.g. Goldman Sachs 2024.
    if not na(pl) and pv_isClimaxVol and pv_closePos >= 0.40 and priorTrend == -1
        phase       := 1
        support     := pl
        resistance  := na
        spring_lo   := na
        is_reaccum  := false
        is_subcycle := false   // top-level SC, not a sub-cycle
        phase_bar   := bar_index
        // Store pending — label drawn only when AR confirms the cycle is real
        pend_bar   := bar_index - pivotRight
        pend_price := pl
        pend_txt   := _lname("SC", "Selling Climax") + _tag(true) + "\n" + str.tostring(pl, "#.##")
        pend_sty   := label.style_label_up
        pend_col   := colSC

    // BC: high-vol pivot HIGH in uptrend, close in lower 60% (demand exhausted, bearish candle)
    else if not na(ph) and pv_isClimaxVol and pv_closePos <= 0.60 and priorTrend == 1
        phase       := 10
        resistance  := ph
        support     := na
        spring_lo   := na
        is_reaccum  := true
        // If macro markup is still active (phase 8 timed out but markupActive persists),
        // treat this BC as a sub-cycle so AR confirm doesn't kill the macro markup line.
        // Without this, the macro markup gets clobbered every time the machine times out
        // and re-detects a fresh BC (KGHM Jul 2025 → Jan 2026 case: original markup
        // erased when BC 309 fired top-level after the resetBars timeout).
        is_subcycle := markupActive
        phase_bar   := bar_index
        // Store pending — label drawn only when AR confirms the cycle is real
        pend_bar   := bar_index - pivotRight
        pend_price := ph
        pend_txt   := _lname("BC", "Buying Climax") + _tag(false) + "\n" + str.tostring(ph, "#.##")
        pend_sty   := label.style_label_down
        pend_col   := colBC

    // PS: Preliminary Support — first institutional buying in downtrend, sub-climax vol.
    // Marks "demand starting to absorb supply" before the final SC climax.
    // Close must be in middle-to-upper portion of bar (0.30+) — buyers are pushing back.
    else if not na(pl) and priorTrend == -1 and pv_isPreClimaxVol and pv_closePos >= 0.30
        _lbl(bar_index - pivotRight, pl,
             _lname("PS", "Preliminary Support") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
             label.style_label_up, color.new(colSC, 40))

    // PSY: Preliminary Supply — first institutional selling in uptrend, sub-climax vol.
    // Marks "supply starting to absorb demand" before the final BC climax.
    // Close must be in middle-to-lower portion of bar (≤ 0.70) — sellers are pushing back.
    else if not na(ph) and priorTrend == 1 and pv_isPreClimaxVol and pv_closePos <= 0.70
        _lbl(bar_index - pivotRight, ph,
             _lname("PSY", "Preliminary Supply") + _tag(false) + "\n" + str.tostring(ph, "#.##"),
             label.style_label_down, color.new(colBC, 40))

// ── PHASE 1 (SC) → AR ────────────────────
// AR accepted only if spread support→resistance >= minRange%

if phase == 1
    if not na(ph)
        spread = not na(support) and support > 0 ? (ph - support) / support * 100 : 0.0
        if spread >= minRange
            resistance := ph
            phase      := 2
            phase_bar  := bar_index
            // Flush pending SC label now that AR confirmed the cycle
            if showLabels and not na(pend_bar)
                label.new(pend_bar, pend_price, pend_txt, style=pend_sty,
                     color=pend_col, textcolor=color.white, size=lbSize)
            pend_bar       := na
            markupActive   := false   // new accumulation cycle overrides markup bg
            markdownActive := false
            markupSupport  := na
            markupHigh     := na
            _lbl(bar_index - pivotRight, ph,
                 _lname("AR", "Auto Rally") + _tag(true) + "\n" + str.tostring(ph, "#.##"),
                 label.style_label_down, colAR)
        // pivot high too close to support → too small a range, reset
        else if spread > 0 and spread < minRange
            phase      := 0
            support    := na
            resistance := na
            spring_lo  := na
            pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 10 (BC) → AR ───────────────────
// AR = first pivot LOW after BC; spread = resistance→support
//
// RESISTANCE TRACKING: if price makes a new high after the initial BC pivot,
// update resistance upward.  This handles the common case where volume climax
// fires one bar BEFORE the actual price top.  Without this, the spread to AR
// is calculated from the wrong top and the AR is rejected as too narrow.

if phase == 10
    // Track the highest pivot high — keep resistance at the real top.
    // Resistance LEVEL always updates so AR-spread is calculated from the real peak.
    // BC LABEL only relocates if the new pivot also has climax characteristics
    // (climax vol + bearish close) — otherwise the label drifts onto non-climax
    // peaks and ends up at a bar where price was much lower than pend_price.
    if not na(ph) and ph > resistance
        resistance := ph
        if pv_isClimaxVol and pv_closePos <= 0.60
            pend_bar   := bar_index - pivotRight
            pend_price := ph
            pend_txt   := _lname("BC", "Buying Climax") + _tag(false) + "\n" + str.tostring(ph, "#.##")
    if not na(pl)
        spread = not na(resistance) and resistance > 0 ? (resistance - pl) / resistance * 100 : 0.0
        if spread >= minRange
            support   := pl
            phase     := 2
            phase_bar := bar_index
            // Flush pending BC label now that AR confirmed the cycle
            if showLabels and not na(pend_bar)
                label.new(pend_bar, pend_price, pend_txt, style=pend_sty,
                     color=pend_col, textcolor=color.white, size=lbSize)
            pend_bar       := na
            // Top-level cycle: clear trend flags. Sub-cycle (started from MARKUP):
            // keep markupActive — we're still in macro markup until distribution confirms.
            if not is_subcycle
                markupActive   := false
                markdownActive := false
                markupSupport  := na
                markupHigh     := na
            _lbl(bar_index - pivotRight, pl,
                 _lname("AR", "Auto Reaction") + _tag(false) + "\n" + str.tostring(pl, "#.##"),
                 label.style_label_up, colAR)
        else if spread > 0 and spread < minRange
            phase      := 0
            support    := na
            resistance := na
            spring_lo  := na
            pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 2 (AR) → ST ────────────────────
// Accumulation:  ST = pivot LOW  near support    (secondary test of SC level, low vol)
// Distribution:  ST = pivot HIGH near resistance (secondary test of BC level, low vol)
//
// TOLERANCE NOTE:
//   Accumulation ST tests a specific price level (SC low) → tight tolerance (stTol).
//   Reaccumulation/Distribution ST is a weak rally back TOWARD the BC top that may
//   fall significantly short — gap of 5-10% between ST high and BC top is common.
//   Using stTol × 4 (e.g. 12% for mWIG40) captures realistic distribution STs.

if phase == 2
    if is_reaccum
        // Distribution / reaccumulation path — wider tolerance (4× stTol)
        // ST = rally that fails BELOW resistance (failed retest of BC). Slight overshoot
        // by springTol is OK (small wick above BC), but anything beyond that is UTAD
        // territory or a real breakout — both handled by separate logic, not here.
        stTolReaccum = stTol * 4.0
        stCeiling    = resistance * (1.0 + springTol / 100.0)
        stFloor      = resistance * (1.0 - stTolReaccum / 100.0)
        if not na(ph) and not na(resistance) and ph >= stFloor and ph <= stCeiling and pv_isLowVol
            phase     := 3
            phase_bar := bar_index
            _lbl(bar_index - pivotRight, ph,
                 _lname("ST", "Secondary Test") + _tag(false) + "\n" + str.tostring(ph, "#.##"),
                 label.style_label_down, colST)

        // SOS direct (reaccum path): price decisively re-takes BC with strong vol →
        // BC was not a real top, the macro markup is resuming. Skip ST/Spring entirely.
        else if not na(resistance) and close > stCeiling and barMovePct >= movePct and isStrongVol
            phase     := 6
            phase_bar := bar_index
            _lbl(bar_index, high,
                 _lname("SOS", "Sign of Strength") + _tag(true) + "\n" + str.tostring(high, "#.##"),
                 label.style_label_down, colSOS)

        // SOW direct (reaccum path, before ST forms): close decisively below AR support
        // → distribution confirmed without waiting for ST → UTAD chain. Threshold 1.5× stTol
        // catches both single-bar capitulation AND slow grinding breakdowns; no vol/momentum
        // requirement so a sustained drift below support eventually fires.
        // Without this, slow breakdowns (gradual drop with weak vol) leave the machine
        // stuck in phase 2 until resetBars timeout — meanwhile the chart still shows the
        // stale 'przed bifurkacją' state with support/resistance levels far above price.
        else if not na(support) and close < support * (1.0 - stTol * 1.5 / 100.0)
            phase     := 24
            phase_bar := bar_index
            _lbl(bar_index, low,
                 _lname("SOW", "Sign of Weakness") + _tag(false) + "\n" + str.tostring(low, "#.##"),
                 label.style_label_up, colSOW)
    else
        // Accumulation path — tight tolerance
        // ST = pullback that holds ABOVE support (test of SC low). Slight undershoot by
        // springTol is OK (small wick below support), beyond that is Spring territory.
        stCeiling = support * (1.0 + stTol / 100.0)
        stFloor   = support * (1.0 - springTol / 100.0)
        if not na(pl) and not na(support) and pl >= stFloor and pl <= stCeiling and pv_isLowVol
            phase     := 3
            phase_bar := bar_index
            _lbl(bar_index - pivotRight, pl,
                 _lname("ST", "Secondary Test") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
                 label.style_label_up, colST)

        // SOS direct from phase 2 (skip ST/Spring): strong breakout above AR resistance.
        // Handles fast accumulations where price doesn't pause for a Secondary Test —
        // climbs off SC and breaks AR high with conviction. Without this, the entire
        // markup phase progresses silently and markupActive never sets (no green line).
        else if not na(resistance) and close > resistance and barMovePct >= movePct and isStrongVol
            phase     := 6
            phase_bar := bar_index
            _lbl(bar_index, high,
                 _lname("SOS", "Sign of Strength") + _tag(true) + "\n" + str.tostring(high, "#.##"),
                 label.style_label_down, colSOS)

        // Failed accumulation (before ST forms): close decisively below SC support →
        // SC was not a real bottom. No BC ever formed, so this isn't distribution — just reset
        // and let the machine find a new SC. Without this, the machine stays in phase 2
        // until resetBars timeout, painting stale support/resistance levels.
        else if not na(support) and close < support * (1.0 - stTol * 1.5 / 100.0)
            phase      := 0
            support    := na
            resistance := na
            spring_lo  := na
            pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 3 (ST) → SPRING or UTAD ────────
// Bifurcation:
//   Spring: low dips below support AND close recovers above  → accumulation
//   UTAD:   high breaks above resistance AND close falls back → distribution

if phase == 3 and not na(support)

    // ── Spring path ──────────────────────
    // Three conditions must all hold:
    //   1. low dips below support (false breakdown)
    //   2. close recovers above support (supply absorbed)
    //   3. close in the upper 45%+ of the bar's range — hammer/reversal candle
    //      Standard threshold for a textbook Spring: clean recovery within springTol.
    springBreak = support * (1.0 - springTol / 100.0)
    if low <= support and low >= springBreak and close >= support * 0.995 and closePos >= 0.55
        spring_lo := low
        phase     := 4
        phase_bar := bar_index
        _lbl(bar_index, low,
             _lname("Spring", "False Breakdown") + _tag(true) + "\n" + str.tostring(low, "#.##"),
             label.style_label_up, colSpring)

    // Too deep below support →
    // Check for DEEP SPRING first: bar breaks far below support but CLOSES strongly
    // (closePos >= 0.40 = closes in upper 60%+ of its range = hammer/reversal candle).
    // The looser closePos here is intentional — the breakdown depth itself is the bullish
    // tell, the wick recovery doesn't have to be as clean as the standard hammer.
    // Handles wide-range reaccumulations where the Spring low is 5-15% below support
    // and the standard springTol path would miss it.
    else if low < springBreak and closePos >= 0.40
        spring_lo := low
        support   := low    // anchor new support at the deep Spring low
        phase     := 4
        phase_bar := bar_index
        _lbl(bar_index, low,
             _lname("Spring", "False Breakdown") + _tag(true) + "\n" + str.tostring(low, "#.##"),
             label.style_label_up, colSpring)

    // Still too deep AND bar does not look like a reversal candle →
    // Accumulation path:  failed Spring → reset
    // Distribution path:  deep breakdown = SOW without UTAD (aggressive distribution)
    else if low < springBreak
        if is_reaccum and barMovePct <= -movePct and isStrongVol
            phase     := 24
            phase_bar := bar_index
            _lbl(bar_index, low,
                 _lname("SOW", "Sign of Weakness") + _tag(false) + "\n" + str.tostring(low, "#.##"),
                 label.style_label_up, colSOW)
        else
            phase      := 0
            support    := na
            resistance := na
            spring_lo  := na
            pend_bar   := na

    // ── UTAD path (only if reaccum / BC start) ───
    // Mirror of Spring logic:
    //   1. high pokes above resistance (false breakout)
    //   2. close falls back below resistance (demand failed)
    //   3. close is in the lower 45% of the bar's range — must look like a bearish rejection candle
    //      (eliminates "barely ticked above resistance" false UTAD signals)
    else if is_reaccum and not na(resistance)
        utadBreak = resistance * (1.0 + springTol / 100.0)
        if high >= resistance and high <= utadBreak and close <= resistance * 1.005 and closePos <= 0.45
            phase     := 23
            phase_bar := bar_index
            _lbl(bar_index, high,
                 _lname("UTAD", "False Breakout") + _tag(false) + "\n" + str.tostring(high, "#.##"),
                 label.style_label_down, colUTAD)
        // Too far above resistance → reset
        else if high > utadBreak
            phase      := 0
            support    := na
            resistance := na
            spring_lo  := na
            pend_bar   := na

    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 4 (SPRING) → TEST or SOS ───────

if phase == 4 and not na(support) and not na(resistance)
    // Test: low-vol pullback near support/spring area
    if not na(pl) and pv_isLowVol and pl >= support * 0.98
        phase     := 5
        phase_bar := bar_index
        _lbl(bar_index - pivotRight, pl,
             _lname("Test", "Low Vol Retest") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
             label.style_label_up, colTest)
    // SOS direct: strong up-bar closes above resistance
    if close > resistance and barMovePct >= movePct and isStrongVol
        phase     := 6
        phase_bar := bar_index
        _lbl(bar_index, high,
             _lname("SOS", "Sign of Strength") + _tag(true) + "\n" + str.tostring(high, "#.##"),
             label.style_label_down, colSOS)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 5 (TEST) → SOS ─────────────────

if phase == 5 and not na(resistance)
    if close > resistance and barMovePct >= movePct and isStrongVol
        phase     := 6
        phase_bar := bar_index
        _lbl(bar_index, high,
             _lname("SOS", "Sign of Strength") + _tag(true) + "\n" + str.tostring(high, "#.##"),
             label.style_label_down, colSOS)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 6 (SOS) → LPS ──────────────────
// Failed-SOS guard: if close drops decisively below support before LPS forms,
// the SOS was a fake breakout — reset to phase 0 instead of waiting for timeout.
// Threshold 1.5× stTol mirrors phase 2 acc-branch failed-accumulation logic.
// Without this, fake SOS into shakeout (e.g. Boryszew, MODIVO) leaves the
// machine stuck in phase 6 with stale "MARKUP setup" framing while price falls.

if phase == 6 and not na(support)
    if not na(pl) and pv_isLowVol and pl > support
        phase     := 7
        phase_bar := bar_index
        _lbl(bar_index - pivotRight, pl,
             _lname("LPS", "Last Point of Support") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
             label.style_label_up, colLPS)
    else if close < support * (1.0 - stTol * 1.5 / 100.0)
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 7 (LPS) → more LPS or MARKUP ──────────────
// Each new pivot low above support with low vol = another LPS (stair-step up).
// Resets timeout so markup can be waited out longer.
// Failed-LPS guard: if close drops 1.5× stTol below the (possibly stair-stepped)
// support, accumulation has failed — reset to phase 0. Without this guard,
// shakeout patterns where price breaks LPS support before recovering (Boryszew)
// silently roll into MARKUP, and patterns where price never recovers (MODIVO)
// leave the machine hung in phase 7 with misleading "MARKUP setup" state.

if phase == 7 and not na(resistance)
    // MARKUP fires on first close above resistance — no isStrongVol gate.
    // The strong-vol confirmation already happened at SOS (phase 2/4/5 → 6 transition).
    // Requiring it again at phase 7 → 8 caused MARKUP to fire 5-15 bars late (or never),
    // missing the actual breakout. Many healthy markups have below-MA volume on
    // continuation bars after SOS — gating MARKUP on vol punishes those moves.
    if close > resistance
        phase          := 8
        phase_bar      := bar_index
        // Suppress duplicate MARKUP label when re-entering markup from a sub-cycle
        // (markupActive stayed true through the BC→AR→SOS→LPS→MARKUP sub-cycle).
        if not markupActive
            _lbl(bar_index, high, (showFullNames ? "MARKUP ↑ — Trend wzrostowy" : "MARKUP ↑") + _tag(true), label.style_label_down, colSOS)
        markupActive   := true
        markdownActive := false
        markupSupport  := support   // save LPS floor for failed-markup detection
    else if not na(support) and not na(pl) and pv_isLowVol and pl > support
        support   := pl         // step support up with each LPS
        phase_bar := bar_index  // extend timeout
        _lbl(bar_index - pivotRight, pl,
             _lname("LPS", "Last Point of Support") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
             label.style_label_up, colLPS)
    else if not na(support) and close < support * (1.0 - stTol * 1.5 / 100.0)
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 8 (MARKUP) — track LPS pullbacks AND detect sub-BC ──────────────────
// After MARKUP fires, two things can happen:
//   1. Higher-low pullbacks → labelled as LPS (markup continues)
//   2. A new climax pivot high (sub-BC) — possible Reaccumulation OR Distribution
//      forming inside the existing markup. We start a sub-cycle (phase 10) without
//      waiting for the resetBars timeout so deep pullbacks within markup get
//      properly classified instead of being silently absorbed.
//
// Sub-BC criteria are stricter than top-level BC to avoid label clutter
// during continuous markups:
//   - pv_closePos <= 0.45 (close in lower 45% — clearly bearish reversal candle)
//     Top-level BC uses 0.60; sub-BC requires a more decisive bearish close
//     to filter out shallow LPS pullbacks during healthy markup.
//   - ph >= markupHigh × 0.95 — sub-BC pivot must be within 5% of the markup
//     peak. Distributions form AT or NEAR the top, not 10%+ below it. Prevents
//     internal markup consolidations from being miscategorised as distribution
//     starts (Polimex D1 2026 BC clusters).
//   - same climax volume threshold (pv_isClimaxVol)
//
// The is_subcycle flag prevents the sub-cycle's AR confirm from clearing
// markupActive — the macro markup persists through the sub-cycle. It only
// clears if the sub-cycle resolves into MARKDOWN (phase 25 → 26 transition
// already handles this).

if phase == 8
    // Failed markup: close drops 5× stTol below the markup peak (trailing stop) → MARKDOWN.
    if not na(markupHigh) and close < markupHigh * (1.0 - stTol * 5.0 / 100.0)
        markupActive   := false
        markdownActive := true
        markupSupport  := na
        markupHigh     := na
        phase          := 26
        phase_bar      := bar_index
        _lbl(bar_index, low,
             (showFullNames ? "MARKDOWN ↓ — Nieudany Markup" : "MARKDOWN ↓") + _tag(false),
             label.style_label_up, colSOW)
    // Sub-BC: new climax pivot high near markup peak → start sub-cycle
    else if not na(ph) and pv_isClimaxVol and pv_closePos <= 0.45 and (na(markupHigh) or ph >= markupHigh * 0.95)
        phase       := 10
        resistance  := ph
        support     := na
        spring_lo   := na
        is_reaccum  := true
        is_subcycle := true   // sub-cycle within macro markup
        phase_bar   := bar_index
        // Pending BC label — flushed when AR confirms (existing logic in phase 10)
        pend_bar    := bar_index - pivotRight
        pend_price  := ph
        pend_txt    := _lname("BC", "Buying Climax") + _tag(false) + "\n" + str.tostring(ph, "#.##")
        pend_sty    := label.style_label_down
        pend_col    := colBC
        // markupActive STAYS true — macro markup not over until distribution confirms
    else if not na(support) and not na(pl) and pv_isLowVol and pl > support
        support := pl
        _lbl(bar_index - pivotRight, pl,
             _lname("LPS", "Last Point of Support") + _tag(true) + "\n" + str.tostring(pl, "#.##"),
             label.style_label_up, colLPS)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na
        // markupHigh / markupSupport intentionally kept — needed for phase-0 trailing-stop detection

// ── DISTRIBUTION INVALIDATION — phase 24/25 ──────────────────────────────────
// Track lowest close since entering SOW. If price rallies 2× stTol above the
// SOW low, the distribution thesis is invalidated — bears couldn't hold the
// breakdown. Reset to phase 0 immediately rather than waiting for the
// resetBars timeout (which is months long on D1).
//
// Threshold 2× stTol gives ~6% for mWIG40 — asymmetric vs markup trailing stop
// (5× stTol = 15% drawdown). Distributions break down sharply, so a 6% rally
// from the lowest close is a meaningful invalidation; using 9-15% would wait
// too long and miss the reversal.
//
// Example (PXM May 2026): SOW fires, lowest close ~7.80, current 8.32 → +6.7%
// rally > 6% threshold → distribution invalidated, phase 0 IDLE.

if phase == 24 or phase == 25
    if na(sow_low) or close < sow_low
        sow_low := close
    if not na(sow_low) and close > sow_low * (1.0 + stTol * 2.0 / 100.0)
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na
        sow_low    := na
        // markupActive intentionally NOT reset — if macro markup was alive before
        // this failed distribution, it remains alive; otherwise it stays false.

// Auto-clear sow_low when machine has left the SOW/LPSY phases (any reason)
if phase != 24 and phase != 25 and not na(sow_low)
    sow_low := na

// ── PHASE 23 (UTAD) → SOW ────────────────

if phase == 23 and not na(support)
    if close < support and barMovePct <= -movePct and isStrongVol
        phase     := 24
        phase_bar := bar_index
        _lbl(bar_index, low,
             _lname("SOW", "Sign of Weakness") + _tag(false) + "\n" + str.tostring(low, "#.##"),
             label.style_label_up, colSOW)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 24 (SOW) → LPSY ────────────────

if phase == 24 and not na(resistance)
    if not na(ph) and pv_isLowVol and ph < resistance
        phase     := 25
        phase_bar := bar_index
        _lbl(bar_index - pivotRight, ph,
             _lname("LPSY", "Last Point of Supply") + _tag(false) + "\n" + str.tostring(ph, "#.##"),
             label.style_label_down, colLPSY)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 25 (LPSY) → more LPSY or MARKDOWN ──────────
// Each new weak rally below resistance = another LPSY. Resets timeout.
// Distribution consolidations can last many months — need the extra time.

if phase == 25
    if not na(resistance) and not na(ph) and pv_isLowVol and ph < resistance
        phase_bar := bar_index  // extend timeout
        _lbl(bar_index - pivotRight, ph,
             _lname("LPSY", "Last Point of Supply") + _tag(false) + "\n" + str.tostring(ph, "#.##"),
             label.style_label_down, colLPSY)
    if not na(support) and close < support and isStrongVol
        phase          := 26
        phase_bar      := bar_index
        markdownActive := true
        markupActive   := false
        markupSupport  := na
        markupHigh     := na
        _lbl(bar_index, low, (showFullNames ? "MARKDOWN ↓ — Trend spadkowy" : "MARKDOWN ↓") + _tag(false), label.style_label_up, colSOW)
    if bar_index - phase_bar > resetBars
        phase      := 0
        support    := na
        resistance := na
        spring_lo  := na
        pend_bar   := na

// ── PHASE 26 (MARKDOWN) → AR ↑ → reset ───────────────
// First MEANINGFUL pivot high after markdown = Automatic Rally.
//
// AR gating — without it, the first tiny bounce after MARKDOWN ends the markdown
// line prematurely and the indicator reports IDLE while price is still in free-fall.
// (KGHM Mar 2026 example: MARKDOWN at 290 → tiny bounce to 288.7 → "AR" fires →
// markdown line stops → price actually drops to 240, but chart shows nothing.)
//
// Two requirements:
//   1. Pivot bar must be AFTER markdown entry bar (no stale pivots from the markup)
//   2. Pivot high must be ≥ 3× stTol above the lowest close since markdown started
//      (mWIG40: 9% bounce; filters out small dead-cat bounces)

if phase == 26
    // Track lowest close since entering markdown — reference for AR-gating
    if na(md_lowest) or close < md_lowest
        md_lowest := close

    pivotIsAfterMd  = not na(ph) and (bar_index - pivotRight) > phase_bar
    pivotIsRealRally = not na(ph) and not na(md_lowest) and ph >= md_lowest * (1.0 + stTol * 3.0 / 100.0)

    if pivotIsAfterMd and pivotIsRealRally
        _lbl(bar_index - pivotRight, ph,
             _lname("AR", "Auto Rally") + _tag(true) + "\n" + str.tostring(ph, "#.##"),
             label.style_label_down, colAR)
        markdownActive := false   // AR rally ends the active markdown move — stop the trend line
        md_lowest      := na
        spring_lo      := na
        // If the AR pivot looks like a new BC at the rally top, seed a fresh
        // distribution cycle instead of going IDLE. Catches markdown→new-high
        // reversals (e.g. PXM W1 Apr 2026: MARKDOWN at ~7 → rally to 9.97).
        //
        // Volume gate relaxed from climax (1.5× MA) to above-MA — the post-markdown
        // context (markdown → 9% rally → bearish-close swing high) is itself a strong
        // signal; requiring climax vol is redundant and misses weekly cases where
        // exhaustion rallies have moderate volume. Bearish closePos still required.
        pv_isAboveMaVol = volume[pivotRight] > volMa[pivotRight]
        if pv_isAboveMaVol and pv_closePos <= 0.60
            phase       := 10
            resistance  := ph
            support     := na
            is_reaccum  := true
            is_subcycle := false
            phase_bar   := bar_index
            pend_bar    := bar_index - pivotRight
            pend_price  := ph
            pend_txt    := _lname("BC", "Buying Climax") + _tag(false) + "\n" + str.tostring(ph, "#.##")
            pend_sty    := label.style_label_down
            pend_col    := colBC
        else
            phase      := 0
            support    := na
            resistance := na
            pend_bar   := na
    if bar_index - phase_bar > resetBars
        phase          := 0
        support        := na
        resistance     := na
        spring_lo      := na
        pend_bar       := na
        markdownActive := false   // markdown lost momentum (no AR within timeout) — stop the line
        md_lowest      := na

// ─────────────────────────────────────────
// 🎨  PLOTTING — BACKGROUND & LEVEL LINES
// ─────────────────────────────────────────

// Pattern-path flags
// Accumulation:       started from SC (is_reaccum=false), phases 1–7
// Pre-bifurcation:    started from BC (is_reaccum=true), phases 10 / 2 / 3 — Spring or UTAD not yet fired
// Reaccumulation:     is_reaccum=true, phases 4–7 — Spring confirmed, markup expected
// Distribution:       phases 23–25 — UTAD path confirmed

// Phase classification for backgrounds:
//   Phase 1-3 = pre-Spring consolidation → cyan (accum) or yellow (reaccum pre-bif)
//   Phase 4-7 = Spring/Test/SOS/LPS — accumulation completing, range still active
//               Phases 6-7 are post-SOS BUT pre-MARKUP (close > resistance not yet
//               re-confirmed after LPS). They share range coloring with phase 4-5
//               because price can still break LPS support and invalidate the cycle
//               (Boryszew shakeout, MODIVO failed-LPS). Markup is reserved for phase 8.
//   Phase 8   = active markup (close > resistance confirmed, uses markupActive flag + line)
//   Phase 23-25 = distribution
//   Phase 26 = active markdown
inAccumRange       = not is_reaccum and (phase >= 1 and phase <= 7)
inPreBifurcation   = is_reaccum and (phase == 10 or phase == 2 or phase == 3)
inReaccumConfirmed = is_reaccum and (phase >= 4 and phase <= 7)
inDistrRange       = phase >= 23 and phase <= 25
inRange            = inAccumRange or inPreBifurcation or inReaccumConfirmed or inDistrRange
// markupActive / markdownActive persist beyond the resetBars timeout of phase 8/26,
// so the trend line stays visible throughout the whole trend — not just 80 bars after the signal.
// They are cleared only when a new confirmed SC/BC cycle (AR flush) begins, OR when phase 26
// resolves into AR (markdownActive cleared explicitly there).
inMarkup      = markupActive   and not inRange
inMarkdown    = markdownActive and not inRange

// Active markup period (phase 8) AND post-timeout persistence (phase 0 + markupActive)
// — both get a green tint so the chart never has an "unlabelled gap" inside an
// active markup, even when the trend line breaks for non-new-high bars.
// Phase 6/7 (post-SOS, pre-MARKUP-confirmed) intentionally NOT included — those
// are still range-completion phases that can fail (failed LPS → reset).
inMarkupShade   = phase == 8 or (markupActive   and phase == 0)
inMarkdownShade = phase == 26 or (markdownActive and phase == 0)

// Intermediate distribution shading: when markup is active but price has dropped
// 3× stTol from peak (mWIG40: 9%; WIG20: 6%; NewConnect: 15%) — between healthy
// markup and trailing-stop MARKDOWN trigger at 5× stTol — shade as distribution
// rose tint instead of markup green. Catches the slow-roll-over pattern
// (e.g. PXM Apr-Dec 2024 GS distribution call) where price is distributing but
// hasn't yet broken the trailing-stop threshold.
inMarkupDistributing = inMarkupShade and not na(markupHigh) and close < markupHigh * (1.0 - stTol * 3.0 / 100.0)
inMarkupHealthy      = inMarkupShade and not inMarkupDistributing

bgCol = (inAccumRange         ? colBgAccum         :
         inPreBifurcation     ? colBgPreBif        :
         inReaccumConfirmed   ? colBgReaccum       :   // purple — Spring/Test consolidation
         inMarkupHealthy      ? colBgMarkupShade   :   // green  — markup near recent peak
         inMarkupDistributing ? colBgDistr         :   // rose   — markup, but price 8%+ below peak
         inDistrRange         ? colBgDistr         :
         inMarkdownShade      ? colBgMarkdownShade : na)

bgcolor(showBg ? bgCol : na, title="Wyckoff background")

// ── Markup / Markdown — trend line tracing highs/lows ────────────────────────
// Lines plot ONLY while the trend is intact:
//   - Markup line draws only when high >= previous markup peak (= still making new highs)
//   - Markdown line draws only when low <= previous markdown trough (= still making new lows)
// Without this gating, the markup line traces declining highs after a top is in,
// and the markdown line traces rising lows during the recovery rally — exact opposite
// of what the user expects. Trough/peak trackers reset when the corresponding active
// flag clears (the next start gets a fresh peak/trough).
var float mu_peak   = na
var float md_trough = na

// Reset trackers when the trend flag transitions off
if not inMarkup
    mu_peak := na
if not inMarkdown
    md_trough := na

// Plot decision — uses PREVIOUS bar's tracker so today's high/low can extend the line
draw_mu = inMarkup   and (na(mu_peak)   or high >= mu_peak)
draw_md = inMarkdown and (na(md_trough) or low  <= md_trough)

// Update trackers (after the draw decision)
if inMarkup and (na(mu_peak) or high > mu_peak)
    mu_peak := high
if inMarkdown and (na(md_trough) or low < md_trough)
    md_trough := low

plot(showBg and draw_mu ? high : na, "Markup trend line",
     color = colBgMarkup,   linewidth = 2, style = plot.style_linebr)
plot(showBg and draw_md ? low  : na, "Markdown trend line",
     color = colBgMarkdown, linewidth = 2, style = plot.style_linebr)


var line ln_support    = na
var line ln_resistance = na

if showLines
    if inRange and not na(support)
        if not na(ln_support)
            line.delete(ln_support)
        ln_support := line.new(bar_index - 1, support, bar_index, support,
             color=color.new(colSC, 30), style=line.style_dashed, width=1, extend=extend.right)

    if inRange and not na(resistance)
        if not na(ln_resistance)
            line.delete(ln_resistance)
        ln_resistance := line.new(bar_index - 1, resistance, bar_index, resistance,
             color=color.new(colAR, 30), style=line.style_dashed, width=1, extend=extend.right)

    if not inRange and phase == 0
        if not na(ln_support)
            line.set_extend(ln_support, extend.none)
        if not na(ln_resistance)
            line.set_extend(ln_resistance, extend.none)

// ─────────────────────────────────────────
// 📋  TABLE — Current Phase
// ─────────────────────────────────────────

phaseName(int p) =>
    switch p
        0  => "IDLE — szukam wzorca"
        1  => "SC — Selling Climax"
        10 => "BC — Buying Climax"
        2  => "AR — Auto Reaction/Rally"
        3  => "ST — Secondary Test"
        4  => "SPRING — False Breakdown"
        5  => "TEST — Low Vol Retest"
        6  => "SOS — Sign of Strength"
        7  => "LPS — Last Point of Support"
        8  => "MARKUP ↑"
        23 => "UTAD — False Breakout"
        24 => "SOW — Sign of Weakness"
        25 => "LPSY — Last Point of Supply"
        26 => "MARKDOWN ↓"
        => "?"

phaseColor(int p) =>
    switch p
        0  => color.new(#546E7A, 20)
        1  => color.new(colSC,    20)
        10 => color.new(colBC,    20)
        2  => color.new(colAR,    20)
        3  => color.new(colST,    20)
        4  => color.new(colSpring,20)
        5  => color.new(colTest,  20)
        6  => color.new(colSOS,   20)
        7  => color.new(colLPS,   20)
        8  => color.new(colSOS,   20)
        23 => color.new(colUTAD,  20)
        24 => color.new(colSOW,   20)
        25 => color.new(colLPSY,  20)
        26 => color.new(colSOW,   20)
        => color.gray

patternLabel() =>
    // Trend phases — always override pattern classification
    if phase == 8
        "MARKUP ↑"                       // active markup (LPS confirmed close > resistance)
    else if phase == 26
        "MARKDOWN ↓"                     // active markdown (LPSY confirmed close < support)
    // Persistent trend flags after phase 8/26 reset (markup/markdown still in force)
    else if markupActive   and phase == 0
        "MARKUP ↑"                       // markup persists past phase 8 timeout
    else if markdownActive and phase == 0
        "MARKDOWN ↓"                     // markdown persists past phase 26 timeout
    // Range phases
    else if phase == 0
        "IDLE — szukam wzorca"
    else if phase >= 23
        "DYSTRYBUCJA ↓"                  // UTAD/SOW/LPSY (phases 23–25)
    // Phase 6-7 (post-SOS, pre-MARKUP-confirmed) intentionally NOT labelled
    // as "MARKUP ↑" — markup is confirmed only at phase 8 (close > resistance).
    // Phases 6/7 fall through below into "AKUMULACJA ↑" / "REAKUMULACJA ↑"
    // because they're still part of the range-completion path, not the trend.
    else if is_reaccum and (phase == 10 or phase == 2 or phase == 3)
        "BC/AR — przed bifurkacją"       // Spring or UTAD not yet confirmed
    else if is_reaccum
        "REAKUMULACJA ↑"                 // phase 4-7: Spring/Test/SOS/LPS, pre-MARKUP
    else
        "AKUMULACJA ↑"                   // SC path, phases 1-7

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 8,
         bgcolor=color.new(#1E1E2E, 10), border_color=#444444, border_width=1, frame_width=1)

    table.cell(t, 0, 0, "WYCKOFF",        text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 0, patternLabel(),   text_color=color.white, text_size=size.small, bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 1, "Preset",         text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 1, presetStr,        text_color=#88BBFF, text_size=size.tiny,  bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 2, "Faza",           text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 2, phaseName(phase), text_color=color.white, text_size=size.small, bgcolor=phaseColor(phase))

    table.cell(t, 0, 3, "Support",        text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 3, na(support)    ? "—" : str.tostring(support,    "#.##"),
         text_color=color.new(colSC, 0), text_size=size.small, bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 4, "Resistance",     text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 4, na(resistance) ? "—" : str.tostring(resistance, "#.##"),
         text_color=color.new(colAR, 0), text_size=size.small, bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 5, "Spring Low",     text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 5, na(spring_lo)  ? "—" : str.tostring(spring_lo,  "#.##"),
         text_color=color.new(colSpring, 0), text_size=size.small, bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 6, "Vol / MA",       text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 6, str.tostring(volMa > 0 ? volume / volMa : 0, "#.##") + "x",
         text_color=color.white, text_size=size.small, bgcolor=color.new(#1E1E2E,10))

    table.cell(t, 0, 7, "Phase #",        text_color=#AAAAAA, text_size=size.small, bgcolor=color.new(#1E1E2E,10))
    table.cell(t, 1, 7, str.tostring(phase),
         text_color=#555555, text_size=size.tiny, bgcolor=color.new(#1E1E2E,10))

// ─────────────────────────────────────────
// 🎨  LEGEND — Background colour key
// ─────────────────────────────────────────
// Maps the chart's background tints to the Wyckoff phases they represent.
// Position fixed bottom-right so it doesn't fight the phase table at top-right.

if showLegend and barstate.islast
    var table lg = table.new(position.bottom_right, 2, 7,
         bgcolor=color.new(#1E1E2E, 10), border_color=#444444, border_width=1, frame_width=1)

    legendBg = color.new(#1E1E2E, 10)
    legendTx = color.white
    // Swatches use full-opacity hex (matching the input color defaults) so they
    // stand out against the dark legend background. The chart-tint colors are
    // 75-85% transparent which made the legend swatches nearly invisible.

    table.cell(lg, 0, 0, "TŁO",                text_color=#AAAAAA, text_size=size.small, bgcolor=legendBg)
    table.cell(lg, 1, 0, "FAZA",               text_color=#AAAAAA, text_size=size.small, bgcolor=legendBg)

    table.cell(lg, 0, 1, "  ",                 bgcolor=#22D3EE,    text_size=size.small)
    table.cell(lg, 1, 1, " Akumulacja (SC→AR→ST) ",        text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

    table.cell(lg, 0, 2, "  ",                 bgcolor=#FACC15,    text_size=size.small)
    table.cell(lg, 1, 2, " BC/AR — przed bifurkacją ",     text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

    table.cell(lg, 0, 3, "  ",                 bgcolor=#9B59B6,    text_size=size.small)
    table.cell(lg, 1, 3, " Reakumulacja (Spring/Test) ",   text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

    table.cell(lg, 0, 4, "  ",                 bgcolor=#4ADE80,    text_size=size.small)
    table.cell(lg, 1, 4, " Markup ↑ (SOS→LPS→trend) ",     text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

    table.cell(lg, 0, 5, "  ",                 bgcolor=#F87171,    text_size=size.small)
    table.cell(lg, 1, 5, " Dystrybucja (UTAD→SOW→LPSY) ",  text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

    table.cell(lg, 0, 6, "  ",                 bgcolor=#EF4444,    text_size=size.small)
    table.cell(lg, 1, 6, " Markdown ↓ (trend spadkowy) ",  text_color=legendTx, text_size=size.tiny, bgcolor=legendBg)

// ─────────────────────────────────────────
// 🔔  ALERTS
// ─────────────────────────────────────────

// Accumulation / Reaccumulation
alertcondition(phase == 4,
     title="Wyckoff — Spring wykryty",
     message="🌱 Wyckoff Spring: fałszywy breakdown poniżej supportu. Close wrócił powyżej. Szukaj SOS.")

alertcondition(phase == 6,
     title="Wyckoff — SOS wykryty",
     message="🚀 Wyckoff SOS: Sign of Strength, wybicie powyżej resistance. Potencjalny Markup.")

alertcondition(phase == 8,
     title="Wyckoff — Markup potwierdzony",
     message="📈 Wyckoff Markup ↑: LPS trzyma, ponownie powyżej oporu. Faza wzrostu aktywna.")

// Distribution
alertcondition(phase == 23,
     title="Wyckoff — UTAD wykryty",
     message="⚠️ Wyckoff UTAD: fałszywe wybicie powyżej resistance. Close wrócił poniżej. Szukaj SOW.")

alertcondition(phase == 24,
     title="Wyckoff — SOW wykryty",
     message="📉 Wyckoff SOW: Sign of Weakness, przebicie poniżej supportu. Potencjalny Markdown.")

alertcondition(phase == 26,
     title="Wyckoff — Markdown potwierdzony",
     message="🔻 Wyckoff Markdown ↓: LPSY nie dotarło do oporu, kurs ponownie poniżej supportu.")

alertcondition(phase == 26 and markupActive[1],
     title="Wyckoff — Markup nieudany → Markdown",
     message="❌ Wyckoff: Markup zakończył się fiaskiem — przebicie LPS supportu z impetem. Markdown aktywny.")

// Reset
alertcondition(phase == 0 and phase[1] != 0,
     title="Wyckoff — Reset sekwencji",
     message="⚠️ Wyckoff: sekwencja zresetowana — wzorzec nie potwierdził się lub timeout.")
````
