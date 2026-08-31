<!-- tradingview-pine-id: PUB;57948d0f755946b3804a3ab1ebd05ecd -->
<!-- tradingviewscripts-format: 1 -->
# Trend Integrity Oscillator [MQLSoftware]

Source: https://www.tradingview.com/script/D7nAOUi2-Trend-Integrity-Oscillator-MQLSoftware/

## Description

Trend Integrity Oscillator answers one question in a measurable way: is the current pullback a pause inside an intact trend, or the start of a reversal? Instead of pairing two generic oscillators and eyeballing their relationship, it separates the two things that actually diverge in a pullback — trend efficiency and structural integrity — and then measures the outcome of that divergence on the chart's own history.

This is a visual analytical tool for chart study. It does not execute trades and does not provide financial advice.

Key Features

[*]Outcome signals on the price chart: when a pullback resumes, the ▲/▼ marker prints this chart's measured resume rate for that direction; when the structure is closed through, ✕ BREAK prints at the violated anchor
[*]Pullback Survival Zone on the price chart: while a pullback is armed, the pullback territory is shaded and the survival line marks the P75 depth of all pullbacks on this chart that eventually resumed — between that line and the anchor is territory most survivors never visited
[*]Anchor line — the structural pivot whose confirmed close-through turns a pullback into a reversal (frozen at arm time for the live episode)
[*]Trend Efficiency line 0–100 — multiscale signed efficiency computed on three horizons (chart window plus two senior windows equal in wall-clock time to auto-selected higher timeframes), weighted toward the seniors
[*]Structure Integrity area 0–100 — a composite of three confirmed-pivot facts: anchor hold, pivot-chain consistency, and retracement depth ranked against this chart's own resumed pullbacks
[*]Pullback state machine — aligned → pullback armed → resumed / broken, confirmed bars only
[*]Measured base rates in the panel: how often armed pullbacks actually resumed on this chart, per direction, with sample sizes; live pullback depth percentile
[*]Phase lane, pane event marks, optional armed bar-paint and pane tint, five alerts + one dynamic alert

Core Concept — what is original here

1. Multiscale signed efficiency. sER(n) = (close − close[n]) / path(n): a Kaufman-style efficiency ratio kept with its sign. +1 means the last n bars traveled their entire path upward, −1 downward, ~0 churn. Three horizons are blended 0.5/0.3/0.2 with the seniors heaviest, and everything is computed straight on chart bars — the script contains zero request.security calls, so the higher-timeframe re-resolution bug class is structurally impossible.

2. Structure Integrity 0–100. Not a second oscillator but a composite of three confirmed-pivot facts: (a) anchor hold — how firmly price holds the structural anchor pivot, ATR-scaled; (b) pivot-chain consistency — the share of recent pivot steps that agree with the structural direction; (c) retracement depth — the live pullback ranked as a percentile against the depths of pullbacks on this chart that eventually resumed. Self-calibrating; no fixed depth settings.

3. The pullback state machine. ARMED = trend efficiency flips against the trend while the structure holds. RESUMED = efficiency recovers, or price prints a confirmed close beyond the pre-pullback extreme. BROKEN = a confirmed close beyond the anchor pivot as it stood when the pullback started — a reversal, not a pullback. A structural direction flip during an armed episode counts as a failed pullback; nothing is silently dropped.

4. Measured base rates. The panel reports observed frequencies with sample sizes — measured per chart, per direction, not asserted. Below 10 completed episodes the panel says "collecting" instead of quoting noise.

Anatomy of the Display

On the price chart (the overlay layer):

[*]Survival Zone while a pullback is armed: neutral slate = ordinary pullback territory, amber band = deeper than 75% of this chart's resumed pullbacks, dotted amber = the survival line, solid line = the frozen anchor
[*]▲/▼ resume markers with the measured per-direction resume rate printed on them (tooltip: bars in pullback, max depth, base rate with n)
[*]✕ BREAK marker at the anchor price on the confirmed close-through
[*]Optional amber bar tint while armed (off by default)

In the oscillator pane:

[*]Trend Efficiency line — teal above the bull threshold, ember below the bear threshold; brighter when |efficiency| is high; soft glow
[*]Structure Integrity — quiet slate area (3-bar display smoothing; the engine reads the raw series); turns amber while a pullback is armed
[*]Midline 50 and dotted 60/40 guides — the guides sit exactly on the direction-flip hysteresis thresholds
[*]Phase lane (top strip): trend color = aligned, amber = pullback armed, grey = no established state
[*]Pane event marks: • pullback armed, ▲/▼ trend resumed, ✕ structure broken; optional pane tint while armed
[*]Panel: Trend, Structure (tooltip shows the three components), State, base rates per direction, live pullback depth percentile

Notes on Repainting

[*]All state transitions, signal markers, base-rate counters and alerts fire on confirmed bars only and never move once printed
[*]The oscillator lines, the live zone's right edge, the anchor line and the panel's live rows update intrabar — visual context, not signals
[*]The survival line and the episode anchor are frozen at arm time — they do not follow price during the episode
[*]Pivots confirm with the standard pivot lag (Pivot Length bars each side) and never move once confirmed
[*]No request.security anywhere in the script

Typical Analysis Workflow

[*]Read the State row: ALIGNED means efficiency and structure agree; NO ALIGNMENT means stand aside or dig deeper
[*]When PULLBACK ARMED appears, check the live depth percentile — a pullback deeper than most that ever resumed deserves more suspicion
[*]Use the base rates as context: a market where pullbacks resume 50% of the time is a coin flip and the panel will say so honestly
[*]Treat ✕ structure broken as the line between "pullback" and "reversal" — the anchor pivot was closed through

Configuration

[*]Response: Fast / Balanced / Strict — measured smoothing presets, not guesses
[*]Auto Senior Horizons on by default; two manual timeframe inputs when disabled
[*]Pivot Length, Min Integrity to Arm
[*]Chart Overlay group: signals on price, survival zone, completed episodes to keep, anchor line mode (During pullbacks / Always / Off), bar paint, pane tint
[*]All identity colors are inputs (dark-theme defaults; pick deeper tones on light charts)

Markets and Timeframes
Any symbol and timeframe. The engine is percentile- and ATR-based, so it self-calibrates per instrument. On low-history charts the panel reports "collecting" until the sample is real.

Alerts
Pullback armed · Trend resumed · Structure broken · Alignment started · Deep pullback (live depth crossed P75 of resumed history, once per episode) · plus one dynamic alert() with direction and integrity context.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//@version=6
//
// Trend Integrity Oscillator [MQLSoftware]
//
// Answers one question in a measurable way: is the current pullback a pause inside
// an intact trend, or the start of a reversal? Instead of pairing two generic
// oscillators and eyeballing their "relationship", it separates the two things that
// actually diverge in a pullback and MEASURES the outcome of that divergence.
// Original contribution (four algorithmic elements):
//   1. Multiscale signed efficiency as the trend engine — sER(n) = (close - close[n])
//      / path(n): Kaufman-style efficiency kept WITH its sign, computed on three
//      horizons equal in wall-clock time to the chart / HTF1 / HTF2 windows and
//      weighted toward the seniors (0.5/0.3/0.2). Computed straight on chart bars —
//      the script contains zero request.security calls, so the whole HTF
//      re-resolution bug class is structurally impossible.
//   2. Structure Integrity 0-100 — an authored composite of three confirmed-pivot
//      facts: how firmly price holds above/below the structural anchor pivot, how
//      consistent the recent pivot chain is with the trend direction, and how deep
//      the current retracement is relative to this chart's OWN history of pullbacks
//      that resumed (percentile-ranked, self-calibrating; no fixed depth settings).
//   3. Pullback state machine — aligned → pullback armed → resumed / broken, on
//      confirmed bars only. Armed = efficiency flips against the trend while the
//      structure holds. Resumed = efficiency recovers with the anchor intact.
//      Broken = a confirmed close beyond the anchor pivot: reversal, not pullback.
//   4. Measured base rates — the panel reports how often armed pullbacks actually
//      resumed on THIS chart's history (per direction, with n), and ranks the live
//      pullback's depth against the depths of pullbacks that resumed. Observed
//      frequencies, not assumptions.
//
// Repaint policy: state transitions, event marks, base-rate counters and alerts fire
// on CONFIRMED bars only. The oscillator lines and the panel's live rows update
// intrabar — they are visual context, not signals. Pivots confirm with the usual
// pivot lag (Pivot Length bars) and never move once confirmed.

indicator("Trend Integrity Oscillator [MQLSoftware]", shorttitle="MQLSoftware - Trend Integrity", overlay=false, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── CONSTANTS ────────────────────────────────────────────────────────────────
// Neo Slate design tokens — MQLSoftware brand palette
color NS_WHITE = color.rgb(225, 230, 240)
color NS_LBL   = color.rgb(170, 178, 195)
color NS_SEC   = color.rgb( 90,  98, 115)
color NS_BG    = color.new(color.rgb(  8, 11, 18),  4)
color NS_ROW   = color.new(color.rgb( 16, 20, 30),  6)
color NS_INK   = color.rgb( 10,  14,  22)

// Product identity — teal × ember, the unused color axis in the line
color TIO_BULL_DEF  = #2BD9C7  // trend up — teal
color TIO_BEAR_DEF  = #FF6B4A  // trend down — ember
color TIO_STRUC_DEF = #8B93A8  // structure integrity — slate
color TIO_ARM_DEF   = #FFAF14  // pullback armed — amber
color TIO_BRK_DEF   = #FF4669  // structure broken — rose

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string GRP_E  = "◆ Engine"
var string GRP_S  = "◆ States & Events"
var string GRP_R  = "◆ Rendering"
var string GRP_ST = "◆ Statistics & Panel"
var string GRP_O  = "◆ Chart Overlay"

string speedInp  = input.string("Balanced", "Response", group = GRP_E, options = ["Fast", "Balanced", "Strict"],
     tooltip = "How fast the trend efficiency line reacts. Fast = 24-bar smoothing, more flips. Balanced = 48-bar (recommended). Strict = 96-bar, swing reading. Presets were measured on real history, not guessed.")
bool  autoHtf    = input.bool(true, "Auto Senior Horizons", group = GRP_E,
     tooltip = "Auto = the two senior efficiency horizons are derived from the chart timeframe (e.g. 15m chart reads 1h and 4h windows). Disable to pin them manually below.")
string htf1Inp   = input.timeframe("60",  "Senior Horizon 1", group = GRP_E)
string htf2Inp   = input.timeframe("240", "Senior Horizon 2", group = GRP_E)
int   pivLenInp  = input.int(5, "Pivot Length", group = GRP_E, minval = 2, maxval = 20,
     tooltip = "Bars on each side required to confirm a swing pivot. Pivots define the structural anchor and the pivot chain. Larger = fewer, more significant pivots.")

int   intMinInp  = input.int(50, "Min Integrity to Arm", group = GRP_S, minval = 0, maxval = 90,
     tooltip = "A pullback only ARMS while Structure Integrity is at or above this value. Below it the structure is already too damaged to call the move a pullback.")

bool  showTrend  = input.bool(true, "Trend Efficiency Line", group = GRP_R, inline = "r1")
color colBull    = input.color(TIO_BULL_DEF, "", group = GRP_R, inline = "r1")
color colBear    = input.color(TIO_BEAR_DEF, "", group = GRP_R, inline = "r1",
     tooltip = "Bull / bear colors of the trend efficiency line. Defaults are tuned for the dark theme; pick deeper tones on light charts.")
bool  showStruc  = input.bool(true, "Structure Integrity Area", group = GRP_R, inline = "r2")
color colStruc   = input.color(TIO_STRUC_DEF, "", group = GRP_R, inline = "r2")
bool  showLane   = input.bool(true, "Phase Lane", group = GRP_R,
     tooltip = "The thin strip at the top of the pane: trend color = aligned, amber = pullback armed, rose = structure broken, grey = no established state.")
bool  showMarks  = input.bool(true, "Event Marks", group = GRP_R,
     tooltip = "PB = pullback armed, ▲/▼ = trend resumed, ✕ = structure broken. All marks are placed on confirmed bars only.")
bool  showFill   = input.bool(true, "Midline Gradient Fill", group = GRP_R)
color colArm     = input.color(TIO_ARM_DEF, "Armed", group = GRP_R, inline = "r3")
color colBrk     = input.color(TIO_BRK_DEF, "Broken", group = GRP_R, inline = "r3")

bool   showPanel = input.bool  (true,        "Statistics Panel", group = GRP_ST)
string panelPos  = input.string("Top Right", "Position",  group = GRP_ST, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
string panelSize = input.string("Normal",    "Text Size", group = GRP_ST, options = ["Tiny", "Small", "Normal"])

bool   showSigs   = input.bool(true, "Resume / Break Signals on Price", group = GRP_O,
     tooltip = "Prints the confirmed episode outcomes on the main chart: ▲/▼ with this chart's measured resume rate when the trend resumes, ✕ BREAK at the anchor when the structure is closed through. Signals are placed on confirmed bars only and never move.")
bool   showZone   = input.bool(true, "Pullback Survival Zone", group = GRP_O,
     tooltip = "While a pullback is armed, shades the pullback territory on the main chart and draws the SURVIVAL LINE — the P75 depth of all pullbacks on this chart that eventually resumed. Above the line = ordinary pullback territory; between the line and the anchor = territory where most survivors never went. Needs 10 completed resumed episodes; before that only the anchor is drawn.")
int    zoneHist   = input.int(8, "Completed Episodes to Keep", group = GRP_O, minval = 0, maxval = 24,
     tooltip = "How many finished episode zones stay on the chart as faded history. 0 = only the live episode.")
string anchorMode = input.string("During pullbacks", "Anchor Line", group = GRP_O, options = ["During pullbacks", "Always", "Off"],
     tooltip = "The structural anchor pivot — the line whose confirmed close-through turns a pullback into a reversal. During pullbacks = only while an episode is armed (frozen arm-time anchor). Always = also the rolling anchor while merely aligned.")
bool   barPaint   = input.bool(false, "Paint Bars While Armed", group = GRP_O,
     tooltip = "Tints the main-chart candles amber while a pullback is armed. Display only.")
bool   paneTint   = input.bool(true, "Pane Tint While Armed", group = GRP_O)

// ─── HELPERS ──────────────────────────────────────────────────────────────────
// Percentile rank of v inside a: % of stored values <= v
f_prank(array<float> a, float v) =>
    int n = a.size()
    if n == 0 or na(v)
        float(na)
    else
        int cnt = 0
        for i = 0 to n - 1
            if a.get(i) <= v
                cnt += 1
        100.0 * cnt / n

// Below minN the sample is too small to quote a percentage — say so instead of
// printing statistical noise.
f_rate(int c, int n, int minN = 10) =>
    n >= minN ? str.tostring(100.0 * c / n, "#") + "%" : "collecting"

f_trimBoxes(array<box> a, int maxN) =>
    while a.size() > maxN
        box.delete(a.shift())

f_trimLines(array<line> a, int maxN) =>
    while a.size() > maxN
        line.delete(a.shift())

f_trimLabels(array<label> a, int maxN) =>
    while a.size() > maxN
        label.delete(a.shift())

// 5-block meter for a 0-100 value — instant visual read in the panel
f_blocks(float p) =>
    na(p) ? "" : p >= 90 ? "  ▰▰▰▰▰" : p >= 70 ? "  ▰▰▰▰▱" : p >= 50 ? "  ▰▰▰▱▱" : p >= 30 ? "  ▰▰▱▱▱" : p >= 10 ? "  ▰▱▱▱▱" : "  ▱▱▱▱▱"

// ─── TREND ENGINE — multiscale signed efficiency ─────────────────────────────
// sER(n) = net displacement over n bars divided by the path traveled: +1 means the
// last n bars spent their entire path going up, -1 all down, ~0 churn.
f_srer(int _n) =>
    float _path = math.sum(math.abs(close - close[1]), _n)
    nz(_path) > 0 ? (close - close[_n]) / _path : 0.0

int tfSec = timeframe.in_seconds(timeframe.period)

// Auto ladder: two senior windows one and two rungs above the chart timeframe.
string htf1Auto = tfSec <= 300 ? "60" : tfSec <= 900 ? "240" : tfSec <= 3600 ? "D" : tfSec <= 14400 ? "D" : tfSec <= 86400 ? "W" : "M"
string htf2Auto = tfSec <= 300 ? "240" : tfSec <= 900 ? "D" : tfSec <= 3600 ? "W" : tfSec <= 14400 ? "W" : tfSec <= 86400 ? "M" : "3M"
string htf1Tf   = autoHtf ? htf1Auto : htf1Inp
string htf2Tf   = autoHtf ? htf2Auto : htf2Inp

int r1 = math.max(1, math.round(timeframe.in_seconds(htf1Tf) / math.max(1, tfSec)))
int r2 = math.max(1, math.round(timeframe.in_seconds(htf2Tf) / math.max(1, tfSec)))
int n1 = math.min(1500, 20 * r1)
int n2 = math.min(1500, 20 * r2)

float effRaw = 0.5 * f_srer(n2) + 0.3 * f_srer(n1) + 0.2 * f_srer(20)

// Response presets: smoothing length + direction hysteresis band. The three points
// on the speed/whipsaw curve were measured on BTC 1h May–Jul history during the
// engine's original tuning; they are carried here unchanged.
int   effSmooth = speedInp == "Fast" ? 24 : speedInp == "Strict" ? 96 : 48
float effHyst   = speedInp == "Fast" ? 0.05 : 0.08

var float eff = na
eff := na(eff) ? effRaw : eff + 2.0 / (effSmooth + 1) * (effRaw - eff)

// Direction with hysteresis latch — churn holds the last decided direction.
var int effDir = 0
effDir := eff > effHyst ? 1 : eff < -effHyst ? -1 : effDir

// Display gain: smoothed multiscale efficiency lives mostly inside ±0.4, so the
// raw ±1 mapping would pin the line to the midline. /0.4 is a monotone rescale
// that puts the ±hysteresis direction thresholds exactly on the 60/40 guides.
float trendVal = 50 + 50 * math.max(-1.0, math.min(1.0, eff / 0.4))

// ─── STRUCTURE ENGINE — confirmed pivots ─────────────────────────────────────
float atr14 = ta.atr(14)
float phVal = ta.pivothigh(high, pivLenInp, pivLenInp)
float plVal = ta.pivotlow(low, pivLenInp, pivLenInp)

var array<float> phA = array.new<float>()
var array<float> plA = array.new<float>()
if not na(phVal)
    phA.push(phVal)
    if phA.size() > 6
        phA.shift()
if not na(plVal)
    plA.push(plVal)
    if plA.size() > 6
        plA.shift()

// Structural direction: latched, flips only when BOTH pivot families agree.
var int sdir = 0
if (not na(phVal) or not na(plVal)) and phA.size() >= 2 and plA.size() >= 2
    bool hh = phA.get(phA.size() - 1) > phA.get(phA.size() - 2)
    bool hl = plA.get(plA.size() - 1) > plA.get(plA.size() - 2)
    sdir := hh and hl ? 1 : not hh and not hl ? -1 : sdir

// Anchor pivot: the structural line in the sand. Up-structure leans on the last
// confirmed pivot low; down-structure on the last confirmed pivot high.
float anchor = sdir == 1 and plA.size() > 0 ? plA.get(plA.size() - 1) : sdir == -1 and phA.size() > 0 ? phA.get(phA.size() - 1) : na

// Impulse span between the two most recent opposite pivots — the yardstick that
// retracement depth is measured against.
float impulse = phA.size() > 0 and plA.size() > 0 ? math.abs(phA.get(phA.size() - 1) - plA.get(plA.size() - 1)) : na

// Running extreme of the current leg — resets when the structural direction flips.
var float runExt = na
if sdir != nz(sdir[1])
    runExt := sdir == 1 ? high : low
runExt := sdir == 1 ? math.max(nz(runExt, high), high) : sdir == -1 ? math.min(nz(runExt, low), low) : na

// Live retracement depth as a fraction of the impulse span.
float depth = na
if sdir != 0 and not na(runExt) and not na(impulse) and impulse > 0
    depth := sdir == 1 ? (runExt - close) / impulse : (close - runExt) / impulse
    depth := math.max(0.0, depth)

// Depth history — the depths of pullbacks that RESUMED on this chart. The live
// pullback is ranked against this distribution (self-calibration, SLA pattern).
var array<float> depthsRes = array.new<float>()
float depthPct = f_prank(depthsRes, depth)

// ── Structure Integrity 0-100 — three authored components ──
// 1. Anchor hold (0-40): how firmly price sits on the right side of the anchor,
//    scaled by ATR so it adapts to the instrument.
float cAnchor = na
if sdir != 0 and not na(anchor)
    float d = sdir == 1 ? close - anchor : anchor - close
    cAnchor := 40 * math.max(0.0, math.min(1.0, d / math.max(atr14, syminfo.mintick)))

// 2. Pivot chain consistency (0-30): share of recent same-family pivot steps that
//    agree with the structural direction (higher lows for up, lower highs for down).
f_chain(array<float> a, int dirWanted) =>
    int steps = math.min(3, a.size() - 1)
    if steps <= 0
        float(na)
    else
        int ok = 0
        for i = 1 to steps
            float prev = a.get(a.size() - 1 - i)
            float curr = a.get(a.size() - i)
            if (dirWanted == 1 and curr > prev) or (dirWanted == -1 and curr < prev)
                ok += 1
        30.0 * ok / steps

float cChain = sdir == 1 ? f_chain(plA, 1) : sdir == -1 ? f_chain(phA, -1) : na

// 3. Retracement depth (0-30): shallow vs this chart's own resumed-pullback history.
//    Before the sample exists, fall back to the raw fraction of the impulse.
float cDepth = na
if sdir != 0 and not na(depth)
    cDepth := not na(depthPct) and depthsRes.size() >= 10 ? 30 * (100 - depthPct) / 100 : 30 * math.max(0.0, math.min(1.0, 1 - depth))

float integrity = sdir == 0 ? na : nz(cAnchor) + nz(cChain) + nz(cDepth)

// ─── STATE MACHINE — aligned → pullback armed → resumed / broken ─────────────
// All transitions on confirmed bars only. States: 0 idle · 1 aligned · 2 armed.
var int   state      = 0
var int   stateBar   = na
var float epMaxDepth = na
// Episode reference levels, FROZEN at arm time. The rolling anchor keeps climbing
// into the pullback's own lows as new minor pivots confirm, which would make a
// break almost guaranteed — the episode must be judged against the structure as
// it stood when the pullback started.
var float epAnchor   = na
var float epExt      = na
var float epImpulse  = na
var int   epStartBar = na
var bool  epDeepFired = false

// Base-rate counters, per direction
var int nArmBull = 0
var int cResBull = 0
var int nArmBear = 0
var int cResBear = 0

bool armedFire  = false
bool resumeFire = false
bool breakFire  = false
bool alignFire  = false
bool deepFire   = false
var float lastBreakLvl = na

if barstate.isconfirmed
    // A structural direction flip resets the machine. An armed episode that dies
    // this way is a failed pullback — count it, don't silently drop it.
    if sdir != nz(sdir[1])
        if state == 2
            if nz(sdir[1]) == 1
                nArmBull += 1
            else if nz(sdir[1]) == -1
                nArmBear += 1
        state := 0
    if sdir != 0
        // Structure break: a confirmed close beyond the reference anchor ends any
        // state. Armed episodes are judged against their FROZEN arm-time anchor.
        float refAnchor = state == 2 ? epAnchor : anchor
        bool broken = not na(refAnchor) and (sdir == 1 ? close < refAnchor : close > refAnchor)
        if broken and state != 0
            breakFire    := true
            lastBreakLvl := refAnchor
            if state == 2
                if sdir == 1
                    nArmBull += 1
                else
                    nArmBear += 1
            state := 0
        else if state == 0
            if effDir == sdir and nz(integrity) >= intMinInp
                state     := 1
                stateBar  := bar_index
                alignFire := true
        else if state == 1
            // Arm: efficiency flips against the trend while the structure holds.
            if (sdir == 1 ? eff < 0 : eff > 0) and nz(integrity) >= intMinInp
                state       := 2
                stateBar    := bar_index
                epMaxDepth  := nz(depth)
                epAnchor    := anchor
                epExt       := runExt
                epImpulse   := impulse
                epStartBar  := bar_index
                epDeepFired := false
                armedFire   := true
        else if state == 2
            epMaxDepth := math.max(nz(epMaxDepth), nz(depth))
            // Deep-pullback event: the live depth crossed P75 of this chart's
            // resumed-pullback history — once per episode, confirmed bars only.
            if not epDeepFired and depthsRes.size() >= 10 and not na(depthPct) and depthPct >= 75
                epDeepFired := true
                deepFire    := true
            // Resume: efficiency recovers beyond the hysteresis band, OR price
            // prints a confirmed close beyond the pre-pullback extreme — the
            // trend proved continuation regardless of what the oscillator says.
            if (sdir == 1 ? eff > effHyst : eff < -effHyst) or (not na(epExt) and (sdir == 1 ? close > epExt : close < epExt))
                state      := 1
                stateBar   := bar_index
                resumeFire := true
                if sdir == 1
                    nArmBull += 1
                    cResBull += 1
                else
                    nArmBear += 1
                    cResBear += 1
                if not na(epMaxDepth) and epMaxDepth > 0
                    depthsRes.push(epMaxDepth)
                    if depthsRes.size() > 200
                        depthsRes.shift()

// ─── RENDERING ────────────────────────────────────────────────────────────────
color trendCol = effDir == -1 ? colBear : colBull
color trendPlotCol = showTrend ? color.new(trendCol, math.abs(eff) >= 0.15 ? 0 : 30) : na

// Structure integrity area — quiet slate backdrop; warms up while a pullback is
// armed. Display-only 3-bar smoothing keeps the area readable; the state machine
// always reads the RAW integrity series.
float intSm   = ta.ema(nz(integrity, 50), 3)
float intDisp = na(integrity) ? na : intSm
color strucFillCol = showStruc ? color.new(state == 2 ? colArm : colStruc, state == 2 ? 72 : 82) : na
color strucLineCol = showStruc ? color.new(state == 2 ? colArm : colStruc, 35) : na
plot(intDisp, "Structure Integrity", color = strucFillCol, style = plot.style_area, histbase = 0)
plot(intDisp, "Structure Integrity Line", color = strucLineCol, linewidth = 1)

plot(showTrend ? trendVal : na, "Trend Glow", color = color.new(trendCol, 84), linewidth = 7)
pTrend = plot(showTrend ? trendVal : na, "Trend Efficiency", color = trendPlotCol, linewidth = 2)
pMid   = plot(50, "Midline", color = color.new(NS_SEC, 60), linewidth = 1, display = display.pane)
fill(pTrend, pMid, top_value = 100, bottom_value = 0, top_color = showFill ? color.new(trendCol, 55) : color.new(trendCol, 100), bottom_color = color.new(trendCol, 100), title = "Trend Fill")

// 60/40 = the Balanced/Strict ±0.08 direction-flip thresholds after display gain.
hline(60, "Bull Threshold", color = color.new(NS_SEC, 75), linestyle = hline.style_dotted)
hline(40, "Bear Threshold", color = color.new(NS_SEC, 75), linestyle = hline.style_dotted)

// Phase lane — the state strip at the top of the pane (PRL lane idiom).
color laneCol = not showLane ? na : state == 2 ? colArm : state == 1 ? color.new(trendCol, 15) : color.new(NS_SEC, 55)
plot(showLane ? 106 : na, "Phase Lane", color = laneCol, linewidth = 5, style = plot.style_line)

// Event marks — confirmed-bar events only. Display toggles never touch the logic.
plotchar(showMarks and armedFire ? 104 : na, "Pullback Armed", "•", location.absolute, colArm, size = size.tiny)
plotshape(showMarks and resumeFire and sdir == 1 ? 8 : na, "Resumed ▲", shape.triangleup, location.absolute, colBull, size = size.tiny)
plotshape(showMarks and resumeFire and sdir == -1 ? 8 : na, "Resumed ▼", shape.triangledown, location.absolute, colBear, size = size.tiny)
plotchar(showMarks and breakFire ? 104 : na, "Structure Broken", "✕", location.absolute, colBrk, size = size.tiny)

// Armed context tints — display only.
bgcolor(paneTint and state == 2 ? color.new(colArm, 93) : na, title = "Pane Tint While Armed")
barcolor(barPaint and state == 2 ? color.new(colArm, 25) : na, title = "Armed Bar Paint")

// ─── CHART OVERLAY — the price-pane layer (force_overlay) ────────────────────
// Signals are placed on CONFIRMED episode events and never move. The live zone's
// right edge and the anchor line extend intrabar — visual context, not signals.
float depthP75 = depthsRes.size() >= 10 ? array.percentile_linear_interpolation(depthsRes, 75) : na

var box   zNorm = box(na)
var box   zRisk = box(na)
var line  zSurv = line(na)
var line  zAnch = line(na)
var array<box>   zBoxes = array.new<box>()
var array<line>  zLines = array.new<line>()
var array<label> sLbls  = array.new<label>()

// Episode ended on this confirmed bar (resumed, broken, or killed by a direction
// flip): freeze the live zone into faded history.
bool epEnded = state != 2 and nz(state[1]) == 2
if epEnded
    if not na(zNorm)
        zNorm.set_right(bar_index)
        zNorm.set_bgcolor(color.new(colStruc, 93))
        zBoxes.push(zNorm)
        zNorm := box(na)
    if not na(zRisk)
        zRisk.set_right(bar_index)
        zRisk.set_bgcolor(color.new(colArm, 95))
        zBoxes.push(zRisk)
        zRisk := box(na)
    if not na(zSurv)
        zSurv.set_x2(bar_index)
        zSurv.set_color(color.new(colArm, 70))
        zLines.push(zSurv)
        zSurv := line(na)
    f_trimBoxes(zBoxes, zoneHist * 2)
    f_trimLines(zLines, zoneHist)

// Fresh episode: build the survival zone from the FROZEN arm-time levels.
if armedFire and showZone and not na(epExt) and not na(epAnchor)
    float survLvl = na(depthP75) or na(epImpulse) ? na : sdir == 1 ? epExt - depthP75 * epImpulse : epExt + depthP75 * epImpulse
    // Clamp the survival line inside the extreme→anchor span.
    survLvl := na(survLvl) ? na : sdir == 1 ? math.max(survLvl, epAnchor) : math.min(survLvl, epAnchor)
    // Normal territory stays neutral slate for BOTH directions — the amber risk
    // band must be the only warm surface, otherwise bear episodes blur together.
    if not na(survLvl)
        zNorm := box.new(epStartBar, math.max(epExt, survLvl), bar_index, math.min(epExt, survLvl), border_color = na, bgcolor = color.new(colStruc, 88), force_overlay = true)
        zRisk := box.new(epStartBar, math.max(survLvl, epAnchor), bar_index, math.min(survLvl, epAnchor), border_color = na, bgcolor = color.new(colArm, 85), force_overlay = true)
        zSurv := line.new(epStartBar, survLvl, bar_index, survLvl, color = color.new(colArm, 15), style = line.style_dotted, width = 2, force_overlay = true)
    else
        // Not enough resumed history yet — shade the whole span, no survival split.
        zNorm := box.new(epStartBar, math.max(epExt, epAnchor), bar_index, math.min(epExt, epAnchor), border_color = na, bgcolor = color.new(colStruc, 90), force_overlay = true)

// Live zone follows the right edge intrabar.
if state == 2
    if not na(zNorm)
        zNorm.set_right(bar_index)
    if not na(zRisk)
        zRisk.set_right(bar_index)
    if not na(zSurv)
        zSurv.set_x2(bar_index)

// Anchor line — the structural line in the sand.
bool  anchOn  = anchorMode == "Always" ? state >= 1 : anchorMode == "During pullbacks" ? state == 2 : false
float anchLvl = state == 2 ? epAnchor : anchor
if anchOn and not na(anchLvl)
    if na(zAnch) or zAnch.get_y1() != anchLvl
        line.delete(zAnch)
        zAnch := line.new(bar_index - 1, anchLvl, bar_index, anchLvl, color = state == 2 ? color.new(colBrk, 25) : color.new(NS_SEC, 45), style = state == 2 ? line.style_solid : line.style_dotted, width = state == 2 ? 2 : 1, force_overlay = true)
    else
        zAnch.set_x2(bar_index)
        zAnch.set_color(state == 2 ? color.new(colBrk, 25) : color.new(NS_SEC, 45))
        zAnch.set_style(state == 2 ? line.style_solid : line.style_dotted)
        zAnch.set_width(state == 2 ? 2 : 1)
else if not na(zAnch)
    line.delete(zAnch)
    zAnch := line(na)

// Confirmed outcome signals on price. The % printed on a resume is the measured
// base rate for that direction on this chart (already including this episode).
if showSigs and resumeFire
    bool  up   = sdir == 1
    int   nDir = up ? nArmBull : nArmBear
    int   cDir = up ? cResBull : cResBear
    string txt = (up ? "▲" : "▼") + (nDir >= 10 ? " " + str.tostring(100.0 * cDir / nDir, "#") + "%" : " RESUME")
    string tip = "Pullback resumed (" + (up ? "bull" : "bear") + ")" +
         "\nBars in pullback: " + str.tostring(bar_index - nz(epStartBar, bar_index)) +
         "\nMax depth: " + (na(epMaxDepth) ? "—" : str.tostring(100 * epMaxDepth, "#") + "% of impulse") +
         "\nBase rate: " + f_rate(cDir, nDir) + " (n=" + str.tostring(nDir) + ")"
    sLbls.push(label.new(bar_index, up ? low : high, txt, style = up ? label.style_label_up : label.style_label_down, color = color.new(up ? colBull : colBear, 12), textcolor = NS_INK, size = size.small, tooltip = tip, force_overlay = true))
    f_trimLabels(sLbls, 60)
if showSigs and breakFire
    string btip = "Structure broken — the anchor pivot was closed through (confirmed bar). Reversal territory, not a pullback."
    sLbls.push(label.new(bar_index, nz(lastBreakLvl, close), "✕ BREAK", style = sdir == 1 ? label.style_label_upper_right : label.style_label_lower_right, color = color.new(colBrk, 16), textcolor = NS_WHITE, size = size.small, tooltip = btip, force_overlay = true))
    f_trimLabels(sLbls, 60)

// ─── PANEL ────────────────────────────────────────────────────────────────────
f_stateStr() =>
    state == 2 ? "PULLBACK ARMED" : state == 1 ? (sdir == 1 ? "ALIGNED ↑" : "ALIGNED ↓") : sdir == 0 ? "forming" : "NO ALIGNMENT"

var table pnl = table(na)
if barstate.islast and showPanel
    if not na(pnl)
        table.delete(pnl)
    string pPos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    string pSz  = panelSize == "Tiny" ? size.tiny : panelSize == "Small" ? size.small : size.normal
    pnl := table.new(pPos, 2, 8, bgcolor = NS_BG, border_width = 1, border_color = color.new(NS_SEC, 80))
    pnl.cell(0, 0, "TREND INTEGRITY", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 0, syminfo.ticker, text_color = NS_SEC, text_size = pSz, text_halign = text.align_right)
    pnl.cell(0, 1, "Trend", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 1, str.tostring(trendVal, "#") + (effDir == 1 ? " ↑" : effDir == -1 ? " ↓" : " ·") + f_blocks(trendVal), text_color = trendCol, text_size = pSz, text_halign = text.align_left)
    pnl.cell(0, 2, "Structure", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 2, na(integrity) ? "forming" : str.tostring(integrity, "#") + f_blocks(integrity), text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left,
         tooltip = "Anchor hold " + (na(cAnchor) ? "—" : str.tostring(cAnchor, "#")) + "/40 · Pivot chain " + (na(cChain) ? "—" : str.tostring(cChain, "#")) + "/30 · Depth " + (na(cDepth) ? "—" : str.tostring(cDepth, "#")) + "/30")
    pnl.cell(0, 3, "State", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 3, f_stateStr(), text_color = state == 2 ? colArm : state == 1 ? trendCol : NS_LBL, text_size = pSz, text_halign = text.align_left, bgcolor = state == 2 ? color.new(colArm, 88) : NS_ROW)
    pnl.cell(0, 4, "BASE RATES · this chart", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left,
         tooltip = "Measured over the loaded history on confirmed bars. A pullback episode starts when the trend efficiency flips against an intact structure (ARMED) and ends when efficiency recovers (resumed) or the anchor pivot is closed through (broken). Percentages appear once a direction has 10 completed episodes.")
    pnl.merge_cells(0, 4, 1, 4)
    pnl.cell(0, 5, "Bull pullbacks resumed", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 5, f_rate(cResBull, nArmBull) + "  (n=" + str.tostring(nArmBull) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
    pnl.cell(0, 6, "Bear pullbacks resumed", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 6, f_rate(cResBear, nArmBear) + "  (n=" + str.tostring(nArmBear) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
    pnl.cell(0, 7, "Live pullback depth", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
    pnl.cell(1, 7, state != 2 ? "—" : depthsRes.size() >= 10 and not na(depthPct) ? "P" + str.tostring(depthPct, "#") + " vs resumed" : "collecting", text_color = state == 2 ? colArm : NS_LBL, text_size = pSz, text_halign = text.align_left,
         tooltip = "Percentile of the live pullback's depth against the depths of pullbacks on this chart that eventually resumed. P90 = deeper than 90% of them — historically unusual for a pullback that survives.")

// ─── ALERTS ───────────────────────────────────────────────────────────────────
// All event flags are confirmed-gated inside the state machine; display inputs
// never touch them.
if armedFire or resumeFire or breakFire or deepFire
    string dirStr = sdir == 1 ? "bull" : "bear"
    string what = armedFire ? "pullback ARMED (" + dirStr + ", integrity " + str.tostring(integrity, "#") + ")" : resumeFire ? "trend RESUMED (" + dirStr + ")" : breakFire ? "structure BROKEN (" + dirStr + " anchor closed through)" : "pullback DEEPER than P75 of resumed history (" + dirStr + ")"
    alert(syminfo.ticker + " " + timeframe.period + " — " + what, alert.freq_once_per_bar_close)

alertcondition(armedFire,  "Pullback armed",    "Trend efficiency flipped against an intact structure — pullback armed (confirmed bar)")
alertcondition(resumeFire, "Trend resumed",     "Efficiency recovered with the anchor intact — pullback resumed (confirmed bar)")
alertcondition(breakFire,  "Structure broken",  "A confirmed close beyond the anchor pivot — reversal risk, not a pullback")
alertcondition(alignFire,  "Alignment started", "Trend efficiency and structure came into agreement (confirmed bar)")
alertcondition(deepFire,   "Deep pullback",     "The live pullback's depth crossed P75 of this chart's resumed-pullback history (confirmed bar)")
````
