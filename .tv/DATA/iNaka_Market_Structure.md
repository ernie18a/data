<!-- tradingview-pine-id: PUB;06bbf309f86848d2907073b45543e3f2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# iNaka Market Structure

Source: https://www.tradingview.com/script/CGHdUL59-iNaka-Market-Structure/

## Description

iNaka Market Structure marks Break of Structure (BOS), Change of Character (CHoCH) and liquidity
sweeps from confirmed swing pivots, and scores every break from 0 to 100 so a decisive break and a
marginal one are distinguishable without eyeballing the candles.

It is one self-contained engine, not a combination of existing indicators. ATR appears only as a unit
of measurement, so that a threshold means the same thing on gold as on a currency pair; it is never
used as a signal.

WHAT IT DRAWS
- A dashed line at the active Ref High and Ref Low: the most recent confirmed swing high and swing low
  that price has not yet broken. Dotted instead of dashed means the level is an equal-high/equal-low
  cluster.
- BOS or CHoCH labels carrying the 0-100 strength score, with a line drawn back to the pivot that was
  broken.
- "sweep" marks where price ran a level intrabar and closed back inside it.
- A status panel showing the current bias, the leg count, and both active levels.

HOW IT WORKS
1. Pivots. A pivot high is a bar whose high exceeds the Pivot Left bars before it and the Pivot Right
   bars after it; a pivot low is the mirror. Two resolutions run in parallel on the same bars, Major
   (default 15/15) and Minor (default 5/5), and you choose which one drives the labels, the bar
   colouring and the alerts.

2. Reference levels. The most recent confirmed pivot on each side becomes a reference level. At most
   one is live per side: one above price, one below. After a break, that side has no level at all
   until the next pivot confirms - and because a pivot is only confirmed Pivot Right bars after it
   prints, the level that replaces it is always at least that old.

3. Equal highs and equal lows. If a new pivot lands within Equal-Level Tolerance of the live reference,
   it is treated as the same level being retested rather than a new one. The original level and its bar
   index are kept and the level is flagged as a cluster. A double or triple top is therefore one level
   tested three times, not three separate levels drifting down toward price.

4. Sweeps. If price trades through a live level but closes back inside it, that is reported as a sweep,
   not a break: liquidity was taken and structure held. Each level reports its sweep once, so a level
   poked twenty times inside a range produces one mark rather than twenty.

5. Breaks. A close through the level consumes it. If the prevailing bias already pointed that way, the
   break is a BOS (continuation of the current leg). If it pointed the other way, it is a CHoCH, the
   first break of a new leg. Bias starts undefined, so the first reported break on a chart is always a
   BOS rather than a change of character with nothing to change from.

6. Break strength, 0 to 100, is the sum of four terms:
   - up to 40 for displacement: how far beyond the level the bar closed, measured in ATR, saturating
     at 1 ATR
   - up to 25 for the leg count: how many consecutive breaks the current direction has produced,
     saturating at 3
   - 20 if the break follows a sweep on its own side inside the Sweep Arm window, i.e. a break that
     first ran the stops resting behind it
   - 15 if the level broken was an equal-high/low cluster, on the reasoning that repeated tests leave
     more resting orders behind a level

WHAT IS DIFFERENT ABOUT IT
These are the specific design choices the engine makes, and the reasons it exists:
- Breaking and reporting are separate decisions. A close through a level always consumes it, so a
  level can never sit stranded below price and then fire a stale break dozens of bars later. The
  filters decide whether that break is reported at all: the bit, the label, the alert and the bias
  update. The bias therefore advances only on reported breaks, so a CHoCH is always measured against the last bias you actually saw drawn. The leg count
  deliberately does not: it advances on every break, because gating it would let one filtered break
  starve every later break's score.
- Every break carries a composite 0-100 score built from four separately weighted, individually
  explained terms - displacement, leg count, a side-matched sweep, and whether the broken level was a
  cluster - and Min Break Strength filters on that score. The score is a ranking of breaks against
  each other, not a probability.
- Equal levels cluster rather than replace. A near-equal pivot keeps the older level instead of
  overwriting it, so a level that has been tested repeatedly stays anchored where the market actually
  respected it.
- Two resolutions are computed in parallel on every bar, Major and Minor, with independent pivot
  lengths and independent state. You choose which one reports; both stay live.
- Sweeps are one-shot per level. A sweep is treated as an event, not as a condition that re-reports on
  every touch for as long as price hovers under the level.

SETTINGS
Structure
- Structure Resolution: which resolution is reported, Major or Minor. Both are always computed.
- Major Pivot Left / Right (15 / 15) and Minor Pivot Left / Right (5 / 5). Pivot Right is also the
  confirmation lag: a pivot is only known that many bars after it prints.

Break Rules
- Equal-Level Tolerance (ATR), default 0.10. How close a new pivot must be to count as an equal
  high/low. 0 disables clustering.
- Break Displacement (ATR), default 0. How far beyond the level the close must be for the break to be
  reported. 0 reports every close-through.
- Displacement ATR Length, default 14. Used by both the displacement gate and the tolerance.
- Sweep Arm (bars), default 3. How long after a sweep a same-side break still earns the sweep bonus.
  0 disables the bonus.
- Min Break Strength, default 0. Breaks scoring below this are not labelled or alerted.

Display
- Toggles for the reference levels, break marks, sweep marks, the score on labels, bar colouring by
  bias, and the status panel; how many marks to keep on the chart; and the three colours.

HOW TO USE IT
- Start at defaults on the timeframe you actually trade. Major answers "what is the structural
  direction"; Minor answers "what is happening inside the current leg".
- Treat a CHoCH as the first evidence that a leg has ended and a BOS as evidence that it continues.
  The leg count in the panel tells you how extended the current sequence already is - note it counts
  every break, including ones a filter hid, so it can move with no new label on screen.
- If the chart is too busy, raise Break Displacement or Min Break Strength rather than lengthening the
  pivots. Longer pivots delay every level; the filters only hide the marginal breaks.
- A sweep followed by a same-side break is the sequence the strength score rewards most: the level was
  defended, the stops behind it were taken, and then it broke anyway.

LIMITATIONS, WHICH YOU SHOULD READ BEFORE USING IT
- Pivots confirm Pivot Right bars after they print. A level therefore becomes active that many bars
  late, and a break occurring inside that window is not seen. That lag is exactly what makes the engine
  non-repainting on closed bars; it is inherent to confirmed pivots and no setting removes it.
- Within a forming bar, levels and marks can appear and disappear as the bar's high, low and close
  move. Set every alert to "Once Per Bar Close".
- Reference levels ratchet. A newly confirmed pivot replaces the live one even when it sits lower for a
  Ref High, because the rule is "most recent confirmed pivot", not "highest untouched pivot".
- The strength weights are a starting calibration chosen so the score stays interpretable. They are not
  an optimised or validated result. Use the score to rank breaks against each other, not as a
  probability of anything.
- Only the most recent marks are kept on the chart (default 60 of each kind). Scroll far enough back
  and the older BOS, CHoCH and sweep marks have been deleted, and the two reference lines, which run from
  their pivot to the right edge, leave the frame once you scroll back past their pivot. A blank
  history is the drawing budget, not a fault.
- Break labels are placed at the midpoint of the line drawn back to the broken pivot, not on the break
  bar itself, so on a long line the label sits well to the left of where the break happened.
- This is an analysis tool. It does not generate entries or exits, does not size or manage a position,
  and makes no claim about profitability.

ALERTS
Six conditions: Bullish BOS, Bearish BOS, Bullish CHoCH, Bearish CHoCH, Bullish sweep, Bearish sweep.
All fire on the selected resolution. Set them to "Once Per Bar Close".

Published open-source under the Mozilla Public License 2.0.
```

**Conditional addition — only if you take the Minor fallback in chart-plan step 5.** Publishing a
chart on non-default settings without disclosing them is the violation-1 family, which binds every
visibility type. Add this line immediately above `Published open-source under the Mozilla Public
License 2.0.`:

```
The chart shown uses Structure Resolution = Minor. All other settings are at their defaults.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Inakatrader - iNaka Market Structure (MS v1)
//
// Built on confirmed ta.pivothigh / ta.pivotlow pivots, with equal-level clustering, an ATR
// displacement gate, explicit sweep classification and a 0-100 break-strength score.
//
// WHAT IT MARKS
//   BOS   - price CLOSES beyond the active reference level IN the direction of the prevailing bias
//           (continuation of the current leg).
//   CHoCH - price CLOSES beyond the active reference level AGAINST the prevailing bias
//           (the first break of a new leg — a change of character).
//   Sweep - the level is traded through intrabar but RECLAIMED by the close: liquidity was taken and
//           structure did NOT break. A sweep is never reported as a BOS, and each level can only be
//           swept once — a level poked twenty times in a range reports one sweep, not twenty.
//
// HOW A LEVEL IS CHOSEN
//   A reference level is the most recent CONFIRMED pivot that price has not yet broken — one above
//   (Ref High) and one below (Ref Low). A new pivot landing within "Equal-Level Tolerance" of the
//   current reference is treated as the SAME level being retested (an equal high / equal low), so the
//   older level is kept and flagged as a cluster rather than being replaced.
//
// BREAKING vs REPORTING (read this before tuning)
//   A level is CONSUMED whenever price closes through it — structure broke, full stop, and the level
//   never lingers below price waiting to fire a stale break dozens of bars later.
//   "Break Displacement" and "Min Break Strength" decide whether that break is REPORTED (bit, label,
//   alert). The bias and the BOS/CHoCH classification advance ONLY on reported breaks, so a CHoCH is
//   always measured against the last bias you actually saw drawn.
//   The LEG COUNT deliberately does NOT work that way: it advances on every break, reported or not,
//   because gating it would let one filtered break starve every later break's strength score. The
//   consequence is visible: with a filter raised, the panel's Legs can reset on a break that was
//   never drawn.
//
// A REFERENCE LEVEL CAN RATCHET
//   Intake runs before the break test, so a newly confirmed pivot replaces a live level even when it
//   sits LOWER (for a Ref High). Resistance steps down toward price rather than holding at the highest
//   untouched swing — "most recent confirmed pivot" working as intended, not a bug.
//   An equal-high/low cluster keeps its ORIGINAL pivot bar and reports one sweep for its whole life,
//   so a long-lived cluster eventually draws a long break line back to where the cluster started.
//
// NON-REPAINT NOTE (important)
//   A pivot is only confirmed "Pivot Right" bars after it prints, so a reference level becomes active
//   that many bars late, and a break occurring inside that window is not seen. That lag is what makes
//   the engine non-repainting — historical and realtime marks agree ON CLOSED BARS.
//   Within a forming bar, levels and marks can still appear and disappear as the bar's high/low/close
//   move. Set every alert to "Once Per Bar Close".
//
// v1 (2026-08-25) — first release. Status panel anchored bottom-left.
//@version=6
indicator("iNaka Market Structure", shorttitle="iNaka MS", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// === STRUCTURE SETTINGS ===
// =====================================================================
MS_GROUP = "Structure"
ms_resolution = input.string("Major", "Structure Resolution", options=["Major", "Minor"], group=MS_GROUP, tooltip="Which of the two resolutions drives the labels, bar colouring and alerts. Major = slower, structural. Minor = faster, intraday. Both are always computed; this only chooses which one is reported.")
maj_left      = input.int(15, "Major Pivot Left",  minval=1, group=MS_GROUP, tooltip="Bars to the LEFT that must be lower (for a pivot high) for the Major resolution.")
maj_right     = input.int(15, "Major Pivot Right", minval=1, group=MS_GROUP, tooltip="Bars to the RIGHT that must be lower. This is also the confirmation LAG: a Major pivot is only known this many bars after it prints.")
min_left      = input.int(5,  "Minor Pivot Left",  minval=1, group=MS_GROUP, tooltip="Same as Major Pivot Left, for the faster Minor resolution.")
min_right     = input.int(5,  "Minor Pivot Right", minval=1, group=MS_GROUP, tooltip="Same as Major Pivot Right, for the faster Minor resolution.")

// =====================================================================
// === BREAK RULES ===
// =====================================================================
BRK_GROUP = "Break Rules"
eq_tol       = input.float(0.10, "Equal-Level Tolerance (ATR)", minval=0, step=0.05, group=BRK_GROUP, tooltip="A new pivot within this many ATR of the current reference counts as an EQUAL high/low: the older level is kept and marked as a cluster instead of being replaced. 0 disables clustering (every new pivot replaces the level). This is an ATR MULTIPLE, not points.")
disp_k       = input.float(0.0,  "Break Displacement (ATR)",    minval=0, step=0.05, group=BRK_GROUP, tooltip="How far beyond the level the close must be for the break to be REPORTED, in ATR multiples. 0 = report every close-through (default). Raising it hides marginal breaks. The level is still consumed either way so it can never strand below price, but the bias and the BOS/CHoCH classification only advance on breaks that are actually reported. ATR MULTIPLE, not points.")
disp_len     = input.int(14, "Displacement ATR Length", minval=1, group=BRK_GROUP, tooltip="ATR length used by both the displacement gate and the equal-level tolerance. Until this many bars exist the ATR is unavailable, and both settings behave as if set to 0.")
sweep_arm    = input.int(3,  "Sweep Arm (bars)", minval=0, group=BRK_GROUP, tooltip="After a sweep, a break in the SAME direction within this many bars scores the sweep bonus in the strength score (a break that first ran the stops on its own side is treated as stronger). 0 disables the bonus.")
min_strength = input.float(0, "Min Break Strength", minval=0, maxval=100, step=5, group=BRK_GROUP, tooltip="Breaks scoring below this (0-100) are not reported: no label, no alert. As with Break Displacement, the level is still consumed, but the bias and the BOS/CHoCH classification only advance on reported breaks. The leg count still advances on every break, so it can change with no label drawn. 0 = report everything.")

// =====================================================================
// === DISPLAY ===
// =====================================================================
VIZ_GROUP = "Display"
show_levels   = input.bool(true,  "Show active reference levels", group=VIZ_GROUP, tooltip="Dashed lines at the current unbroken Ref High / Ref Low of the selected resolution. Dotted instead of dashed means the level is an equal-high/low cluster.")
show_breaks   = input.bool(true,  "Show BOS / CHoCH marks",       group=VIZ_GROUP, tooltip="Draws a line back to the pivot that was broken, labelled BOS or CHoCH.")
show_sweeps   = input.bool(true,  "Show sweep marks",             group=VIZ_GROUP, tooltip="Marks the first bar that runs a level intrabar and closes back inside it.")
show_strength = input.bool(true,  "Show strength score on labels",group=VIZ_GROUP, tooltip="Appends the 0-100 break-strength score to each BOS/CHoCH label.")
color_bars    = input.bool(false, "Colour bars by bias",          group=VIZ_GROUP, tooltip="Paints every bar with the prevailing structural bias of the selected resolution.")
show_table    = input.bool(true,  "Show status table",            group=VIZ_GROUP, tooltip="Small panel with the current bias, leg count and active levels.")
keep_marks    = input.int(60, "Keep last N marks", minval=5, maxval=200, group=VIZ_GROUP, tooltip="Older BOS/CHoCH and sweep drawings are deleted beyond this count. Break marks and sweep marks are budgeted SEPARATELY, so the cap is 200 rather than 250: 200 of each is 400 labels, inside TradingView's hard limit of 500.")
bull_col      = input.color(#089981, "Bullish", inline="col", group=VIZ_GROUP)
bear_col      = input.color(#F23645, "Bearish", inline="col", group=VIZ_GROUP)
sweep_col     = input.color(#F7A600, "Sweep",   inline="col", group=VIZ_GROUP)

// =====================================================================
// === EVENT BIT FLAGS ===
// Returned packed in a single int so the engine can be lifted into a
// strategy's MTF transport unchanged (one primitive, no objects).
// =====================================================================
int EV_BULL_BOS   = 1
int EV_BULL_CHOCH = 2
int EV_BEAR_BOS   = 4
int EV_BEAR_CHOCH = 8
int EV_BULL_SWEEP = 16
int EV_BEAR_SWEEP = 32

msHas(int ev, int bit) => int(ev / bit) % 2 == 1

// =====================================================================
// === STRUCTURE CONTEXT (one object per resolution) ===
// bool/int fields carry explicit defaults on purpose: an un-defaulted
// UDT field is na, and `not na_bool` is na — which silently disables
// every guard that reads it.
// =====================================================================
type msCtx
    float refHigh      = na
    float refLow       = na
    int   refHighBar   = na
    int   refLowBar    = na
    bool  refHighEq    = false
    bool  refLowEq     = false
    bool  refHighSwept = false
    bool  refLowSwept  = false
    int   bias         = 0
    int   legs         = 0
    int   armUp        = 0
    int   armDn        = 0

// =====================================================================
// === THE ENGINE ===
// Called unconditionally, once per resolution, every bar.
// Returns [events, strength, brokenLevel, brokenPivotBar].
// =====================================================================
msUpdate(msCtx c, simple int L, simple int R, float atrv, simple float eqTol, simple float dispK, simple int armBars, simple float minStr) =>
    int   ev     = 0
    float strv   = na
    float brkLvl = na
    int   brkBar = na

    // --- 1. pivots. ta.* must run on every bar, so these are never gated ---
    float ph = ta.pivothigh(high, L, R)
    float pl = ta.pivotlow(low,  L, R)

    // --- 2. ATR-derived bands. na * 0 is na in Pine, so guard the warmup explicitly ---
    bool  atrOk  = not na(atrv) and atrv > 0
    float eqBand = eqTol > 0 and atrOk ? eqTol * atrv : 0.0
    float disp   = dispK > 0 and atrOk ? dispK * atrv : 0.0

    // --- 3. sweep arms decay (side-matched: an up-arm only ever strengthens an up-break) ---
    if c.armUp > 0
        c.armUp := c.armUp - 1
    if c.armDn > 0
        c.armDn := c.armDn - 1

    // --- 4. level intake: a near-equal pivot keeps the OLDER level and marks it a cluster ---
    if not na(ph)
        if not na(c.refHigh) and eqBand > 0 and math.abs(ph - c.refHigh) <= eqBand
            c.refHighEq := true
        else
            c.refHigh      := ph
            c.refHighBar   := bar_index - R
            c.refHighEq    := false
            c.refHighSwept := false
    if not na(pl)
        if not na(c.refLow) and eqBand > 0 and math.abs(pl - c.refLow) <= eqBand
            c.refLowEq := true
        else
            c.refLow      := pl
            c.refLowBar   := bar_index - R
            c.refLowEq    := false
            c.refLowSwept := false

    // --- 5. sweep: level run intrabar, reclaimed on close. Once per level, never a break ---
    if not na(c.refHigh) and not c.refHighSwept and high > c.refHigh and close <= c.refHigh
        ev             := ev + EV_BEAR_SWEEP
        c.refHighSwept := true
        c.armDn        := armBars > 0 ? armBars + 1 : 0   // +1 offsets the same-bar decay; 0 stays 0
    if not na(c.refLow) and not c.refLowSwept and low < c.refLow and close >= c.refLow
        ev            := ev + EV_BULL_SWEEP
        c.refLowSwept := true
        c.armUp       := armBars > 0 ? armBars + 1 : 0

    // --- 6. break. A close through the level ALWAYS consumes it; the bias and the event advance
    //        only if the report gate passes. The leg count is deliberately NOT gated (see below) ---
    bool brokeUp = false

    if not na(c.refHigh) and close > c.refHigh
        brokeUp       := true
        bool  isChoCh  = c.bias == -1                      // bias 0 (no structure yet) => BOS, not CHoCH
        int   newLegs  = isChoCh ? 1 : c.legs + 1
        float d        = atrOk ? (close - c.refHigh) / atrv : 0.0
        float s        = 40.0 * math.min(d, 1.0) + 25.0 * math.min(newLegs / 3.0, 1.0) + (c.armUp > 0 ? 20.0 : 0.0) + (c.refHighEq ? 15.0 : 0.0)
        if close > c.refHigh + disp and s >= minStr
            ev     := ev + (isChoCh ? EV_BULL_CHOCH : EV_BULL_BOS)
            strv   := s
            brkLvl := c.refHigh
            brkBar := c.refHighBar
            c.bias := 1                                   // gated: the BOS/CHoCH bits must mean what their labels say
        c.legs         := newLegs                         // NOT gated: gating starves every later break's score
        c.refHigh      := na
        c.refHighBar   := na
        c.refHighEq    := false
        c.refHighSwept := false

    if not brokeUp and not na(c.refLow) and close < c.refLow
        bool  isChoCh = c.bias == 1
        int   newLegs = isChoCh ? 1 : c.legs + 1
        float d       = atrOk ? (c.refLow - close) / atrv : 0.0
        float s       = 40.0 * math.min(d, 1.0) + 25.0 * math.min(newLegs / 3.0, 1.0) + (c.armDn > 0 ? 20.0 : 0.0) + (c.refLowEq ? 15.0 : 0.0)
        if close < c.refLow - disp and s >= minStr
            ev     := ev + (isChoCh ? EV_BEAR_CHOCH : EV_BEAR_BOS)
            strv   := s
            brkLvl := c.refLow
            brkBar := c.refLowBar
            c.bias := -1                                  // gated — see above
        c.legs        := newLegs                          // NOT gated — see above
        c.refLow      := na
        c.refLowBar   := na
        c.refLowEq    := false
        c.refLowSwept := false

    [ev, strv, brkLvl, brkBar]

// =====================================================================
// === RUN BOTH RESOLUTIONS ===
// =====================================================================
float atr_val = ta.atr(disp_len)

var msCtx majorCtx = msCtx.new()
var msCtx minorCtx = msCtx.new()

[maj_ev, maj_strength, maj_lvl, maj_bar] = msUpdate(majorCtx, maj_left, maj_right, atr_val, eq_tol, disp_k, sweep_arm, min_strength)
[min_ev, min_strength_v, min_lvl, min_bar] = msUpdate(minorCtx, min_left, min_right, atr_val, eq_tol, disp_k, sweep_arm, min_strength)

// --- the reported resolution ---
bool  use_major = ms_resolution == "Major"
int   act_ev    = use_major ? maj_ev       : min_ev
float act_str   = use_major ? maj_strength : min_strength_v
float act_lvl   = use_major ? maj_lvl      : min_lvl
int   act_bar   = use_major ? maj_bar      : min_bar
int   act_bias  = use_major ? majorCtx.bias       : minorCtx.bias
int   act_legs  = use_major ? majorCtx.legs       : minorCtx.legs
float act_high  = use_major ? majorCtx.refHigh    : minorCtx.refHigh
float act_low   = use_major ? majorCtx.refLow     : minorCtx.refLow
int   act_hibar = use_major ? majorCtx.refHighBar : minorCtx.refHighBar
int   act_lobar = use_major ? majorCtx.refLowBar  : minorCtx.refLowBar
bool  act_hieq  = use_major ? majorCtx.refHighEq  : minorCtx.refHighEq
bool  act_loeq  = use_major ? majorCtx.refLowEq   : minorCtx.refLowEq

bool bull_bos   = msHas(act_ev, EV_BULL_BOS)
bool bull_choch = msHas(act_ev, EV_BULL_CHOCH)
bool bear_bos   = msHas(act_ev, EV_BEAR_BOS)
bool bear_choch = msHas(act_ev, EV_BEAR_CHOCH)
bool bull_sweep = msHas(act_ev, EV_BULL_SWEEP)
bool bear_sweep = msHas(act_ev, EV_BEAR_SWEEP)

// =====================================================================
// === DRAWING ===
// Ring-buffered, with breaks and sweeps kept in SEPARATE buffers so a
// noisy range cannot evict the break labels while their lines survive.
// =====================================================================
var array<line>  brk_lines  = array.new<line>()
var array<label> brk_labels = array.new<label>()
var array<label> swp_labels = array.new<label>()

msTrim(int keep) =>
    while array.size(brk_lines) > keep
        line.delete(array.shift(brk_lines))
    while array.size(brk_labels) > keep
        label.delete(array.shift(brk_labels))
    while array.size(swp_labels) > keep
        label.delete(array.shift(swp_labels))
    true

msDrawBreak(int pivotBar, float lvl, string tag, float strength, color col, bool up) =>
    array.push(brk_lines, line.new(pivotBar, lvl, bar_index, lvl, xloc.bar_index, color=col, style=line.style_solid, width=1))
    string txt = show_strength and not na(strength) ? tag + " " + str.tostring(math.round(strength)) : tag
    array.push(brk_labels, label.new(int(math.round(0.5 * (pivotBar + bar_index))), lvl, txt, xloc.bar_index, yloc.price, color=color(na), textcolor=col, style=up ? label.style_label_down : label.style_label_up, size=size.small))
    msTrim(keep_marks)

if show_breaks and (bull_bos or bull_choch)
    msDrawBreak(act_bar, act_lvl, bull_choch ? "CHoCH" : "BOS", act_str, bull_col, true)
if show_breaks and (bear_bos or bear_choch)
    msDrawBreak(act_bar, act_lvl, bear_choch ? "CHoCH" : "BOS", act_str, bear_col, false)

if show_sweeps and bear_sweep
    array.push(swp_labels, label.new(bar_index, high, "sweep", xloc.bar_index, yloc.price, color=color(na), textcolor=sweep_col, style=label.style_label_down, size=size.tiny))
    msTrim(keep_marks)
if show_sweeps and bull_sweep
    array.push(swp_labels, label.new(bar_index, low, "sweep", xloc.bar_index, yloc.price, color=color(na), textcolor=sweep_col, style=label.style_label_up, size=size.tiny))
    msTrim(keep_marks)

// --- active reference levels: one line each, redrawn on the last bar only ---
var line hi_line = na
var line lo_line = na
if show_levels and barstate.islast
    line.delete(hi_line)
    line.delete(lo_line)
    if not na(act_high) and not na(act_hibar)
        hi_line := line.new(act_hibar, act_high, bar_index + 8, act_high, xloc.bar_index, color=bear_col, style=act_hieq ? line.style_dotted : line.style_dashed, width=1)
    if not na(act_low) and not na(act_lobar)
        lo_line := line.new(act_lobar, act_low, bar_index + 8, act_low, xloc.bar_index, color=bull_col, style=act_loeq ? line.style_dotted : line.style_dashed, width=1)

barcolor(color_bars ? (act_bias > 0 ? bull_col : act_bias < 0 ? bear_col : color.gray) : na)

// =====================================================================
// === STATUS TABLE ===
// =====================================================================
var table st = table.new(position.bottom_left, 2, 5, border_width=1)
if show_table and barstate.islast
    color biasCol = act_bias > 0 ? bull_col : act_bias < 0 ? bear_col : color.gray
    table.cell(st, 0, 0, "iNaka MS",     text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=size.small)
    table.cell(st, 1, 0, ms_resolution,  text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=size.small)
    table.cell(st, 0, 1, "Bias", text_color=color.gray, text_size=size.small)
    table.cell(st, 1, 1, act_bias > 0 ? "Bullish" : act_bias < 0 ? "Bearish" : "None", text_color=biasCol, text_size=size.small)
    table.cell(st, 0, 2, "Legs", text_color=color.gray, text_size=size.small)
    table.cell(st, 1, 2, str.tostring(act_legs), text_color=biasCol, text_size=size.small)
    table.cell(st, 0, 3, "Ref High", text_color=color.gray, text_size=size.small)
    table.cell(st, 1, 3, na(act_high) ? "-" : str.tostring(act_high, format.mintick) + (act_hieq ? " (eq)" : ""), text_color=bear_col, text_size=size.small)
    table.cell(st, 0, 4, "Ref Low", text_color=color.gray, text_size=size.small)
    table.cell(st, 1, 4, na(act_low) ? "-" : str.tostring(act_low, format.mintick) + (act_loeq ? " (eq)" : ""), text_color=bull_col, text_size=size.small)

// =====================================================================
// === DATA WINDOW OUTPUTS ===
// =====================================================================
plot(act_bias, "Bias (1/-1/0)",  display=display.data_window)
plot(act_legs, "Leg count",      display=display.data_window)
plot(act_str,  "Break strength", display=display.data_window)
plot(act_high, "Ref High",       display=display.data_window)
plot(act_low,  "Ref Low",        display=display.data_window)

// =====================================================================
// === ALERTS — set every one of these to "Once Per Bar Close" ===
// =====================================================================
alertcondition(bull_bos,   "Bullish BOS",   "iNaka MS: bullish BOS")
alertcondition(bull_choch, "Bullish CHoCH", "iNaka MS: bullish CHoCH")
alertcondition(bear_bos,   "Bearish BOS",   "iNaka MS: bearish BOS")
alertcondition(bear_choch, "Bearish CHoCH", "iNaka MS: bearish CHoCH")
alertcondition(bull_sweep, "Bullish sweep", "iNaka MS: low swept and reclaimed")
alertcondition(bear_sweep, "Bearish sweep", "iNaka MS: high swept and reclaimed")
````
