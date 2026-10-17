# Supertrend Transition Framework

- url: https://www.tradingview.com/script/jNWzxJTx-Supertrend-Transition-Framework/
- type: indicator
- pine_id: PUB;70d899e9771e4a2199923831d738b5a1
- version: 1.0

## Description

Supertrend Transition Framework is not a basic Supertrend clone.

The Supertrend line is the visible base layer. The main contribution is a neutral transition layer that describes profile agreement, boundary distance, transition pressure, flip age, boundary touches, flip cascade context, and trail behavior.

This script is designed for traders who want a trend-direction reference from ATR-based trailing boundaries while also seeing context around boundary proximity, profile agreement, recent transitions, and trail behavior.

It is a context and visualization tool only. It does not provide trade-action instructions and it is not a trading system.

What it shows

- A manually calculated ATR-based Supertrend boundary.
- Optional fast, base, and slow Supertrend profiles.
- Profile agreement across enabled Supertrend profiles.
- Boundary distance measured in ATR units.
- Transition pressure based on proximity to the active boundary.
- Flip age for the base profile.
- Boundary touch context.
- Flip cascade context across profiles.
- Trail slope context.
- ATR input drift.
- A compact state fingerprint.
- A context table with Compact, Standard, and Detailed layouts.
- Optional capped event labels.
- Factual alert conditions.

Manual Supertrend profiles

The script calculates Supertrend profiles directly from current chart bars.

Each profile uses:

- ATR length
- ATR multiplier
- band source
- flip source
- enable switch
- optional line display
- visual settings

The default profiles are:

- Fast profile: ATR length 7, multiplier 2.0
- Base profile: ATR length 10, multiplier 3.0
- Slow profile: ATR length 21, multiplier 4.0

The base profile is the primary visible boundary by default. Fast and slow profile lines are available but are not shown by default to keep the chart clean.

The default inputs are common starting points. They are not optimized settings.

Profile Agreement

The script compares the valid Supertrend profile directions.

Agreement Score ranges from about -100 to +100:

- +100 means all valid profiles are upward.
- -100 means all valid profiles are downward.
- near 0 means profiles are mixed.

Agreement requires the base profile to be valid and at least two valid profiles to be available. A single valid profile is not treated as profile agreement.

Possible agreement states include:

- Need profiles
- Need base profile
- Warming up
- Need 2+ valid profiles
- Agreement upward
- Agreement downward
- Mixed profiles

Boundary Distance

The base Supertrend boundary is used as the active boundary.

The script calculates the distance from the selected price to the active boundary in ATR units.

This is shown as Boundary distance.

This field describes current distance only. It is not a risk model, projected level, or instruction.

Transition Pressure

Transition Pressure describes proximity to the active Supertrend boundary.

It is calculated from the distance to the boundary and the selected pressure ATR window.

A higher value means price is closer to the active boundary.

This does not tell users what will happen next. It only describes proximity to the active boundary.

Flip Age

Flip Age counts how many bars have passed since the base profile last changed direction.

This helps users see how long the current base structure has persisted.

Boundary Touch Context

A boundary touch is observed when price touches or approaches the active Supertrend boundary within the selected ATR tolerance.

The script tracks Boundary touch age.

The touch event is rising-edge based, so it does not repeatedly fire every bar while price stays near the boundary.

Flip Cascade Context

The script tracks whether fast, base, and slow profiles have recently changed into the same current base direction within the selected cascade lookback.

Cascade context can read as:

- No cascade
- Partial cascade
- Full cascade
- n/a

This is descriptive only.

Trail Slope Context

The script measures how the base Supertrend trail has changed over the selected trail slope lookback.

Trail slope context can read as:

- Rising trail
- Falling trail
- Flat trail
- n/a

ATR Input Drift

Because Supertrend uses ATR, the script includes a simple ATR input drift readout.

ATR input drift compares the current base ATR to a prior base ATR value over the selected lookback.

It can read as:

- ATR input rising
- ATR input falling
- ATR input steady
- n/a

This is not a volatility-regime classifier. It only describes how the ATR input used by the base profile has changed.

Transition State and Transition Context

The main State is direction and agreement focused.

Possible states include:

- Need profiles
- Need base profile
- Warming up
- Need 2+ valid profiles
- Upward agreement
- Downward agreement
- Upward base / mixed profiles
- Downward base / mixed profiles
- Mixed profiles

Transition Context is shown separately so that boundary proximity does not hide the direction/agreement state.

Transition Context can show:

- Boundary touched
- Cascade active
- Full cascade
- High boundary pressure
- Moderate boundary pressure
- Low boundary pressure
- n/a

State Fingerprint

The Fingerprint is a compact summary row for quick reading.

Example:

B+ A+ P34 C2 F18

Meaning:

- B+ means the base profile is upward.
- B- means the base profile is downward.
- B0 means the base profile is unavailable.
- A+ means upward profile agreement.
- A- means downward profile agreement.
- A0 means mixed or unavailable agreement.
- P shows boundary pressure.
- C shows cascade count.
- F shows base flip age.

The fingerprint is a compact context summary. It is not an instruction.

Context table

The context table is on by default.

Compact layout shows:

- State
- Fingerprint
- Transition context
- Base direction
- Agreement
- Boundary distance
- Flip age

Standard layout adds:

- Agreement score
- Boundary pressure
- Boundary distance ATR
- Cascade
- Trail slope
- Last boundary touch
- Alert mode
- Label mode
- Bar status

Detailed layout adds research fields, including:

- Fast direction
- Base direction
- Slow direction
- Enabled profiles
- Valid profiles
- Up / Down profile count
- Agreement ready
- Fast / Base / Slow readiness
- Fast / Base / Slow ATR
- Base trail
- Trail slope %
- ATR drift %
- Cascade count
- Pressure window
- Touch tolerance
- Cooldown state
- Last event age
- Label cap
- State ID
- Active settings

The context table is the primary research surface. The script does not add extra chart plots for these research fields.

Labels and alerts

Labels are optional and off by default.

Label modes:

- Off
- Base flips
- All events

Labels are capped by a user-defined maximum. Older labels are deleted after the cap is reached.

Labels are confirmed-bar visual records by default.

Alert mode and label mode are disclosed separately in the context table. Alerts are confirmed on close by default, and intrabar alert behavior can be enabled from the settings.

The final event engine is shared by alerts and labels. Event cooldown and one-event-per-bar behavior apply to final events.

Factual alert conditions include:

- Base Supertrend flipped upward
- Base Supertrend flipped downward
- Profiles reached upward agreement
- Profiles reached downward agreement
- Profiles became mixed
- Boundary pressure reached threshold
- Boundary touch observed
- Cascade context changed

Customization

Users can adjust:

- band source
- flip source
- confirmed-bar event mode
- automatic warm-up behavior
- fast/base/slow profile enable settings
- fast/base/slow ATR lengths
- fast/base/slow multipliers
- fast/base/slow line visibility
- fast/base/slow colors, widths, and transparency
- agreement threshold
- pressure ATR window
- high pressure threshold
- boundary touch tolerance
- cascade lookback
- trail slope lookback
- trail slope flat threshold
- ATR drift lookback
- ATR drift threshold
- minimum state bars for events
- event cooldown
- context table layout
- context table position
- table text size
- event label mode
- background tint
- label cap
- table colors
- label colors
- tint transparency

Visual settings do not affect calculations.

Plot-budget design

The script keeps chart plots minimal.

Only the fast, base, and slow Supertrend trails are plotted as lines.

Labels are used for optional event records instead of shape plots, and they are capped. No extra chart plots are used for research fields.

Different from other tools

This script does not use Keltner channels, session shading, volatility-regime classification, VWAP, volume weighting, RSI divergence, or moving-average structure analysis.

It focuses only on ATR-based Supertrend boundaries and their transition context.

Limitations

Supertrend is ATR-based and changes when ATR length, multiplier, or source settings change.

ATR-based boundaries lag price by design.

A profile agreement state can persist, unwind, or flip.

Boundary pressure does not tell users that a boundary change will occur.

A mixed profile state does not tell users that direction will change.

Defaults are starting points, not optimized settings.

The script describes current and recently observed structure. It is not financial advice and not a trading system.

Japanese notes

このスクリプトは通常のSupertrendライン表示だけではなく、Fast / Base / Slow の一致、境界までの距離、境界圧力、Flip age、Boundary touch、Cascade、Trail slope、ATR drift、Fingerprint、Context tableでSupertrendの転換文脈を可視化する補助ツールです。売買判断や将来の値動きを示すものではなく、現在のATRベース境界とその周辺状況を整理するためのツールです。

## Source Code

````pine
//@version=6
// =============================================================================
// Supertrend Transition Framework   ("ST Transition")
// -----------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License,
// v. 2.0. If a copy of the MPL was not distributed with this file, You can
// obtain one at https://mozilla.org/MPL/2.0/ .
//
// SPDX-License-Identifier: MPL-2.0
// -----------------------------------------------------------------------------
// Original work, written from scratch. No community or third-party code copied.
//
// Supertrend is used only as the visible, ATR-based base layer. The contribution
// is a neutral transition-context layer built on top of it: multi-profile
// agreement, base boundary distance in ATR units, transition pressure (proximity
// to the active boundary), flip age, boundary-touch context, flip cascade
// context, trail slope context, an ATR-input drift readout, a compact state
// fingerprint, a context table, capped factual labels and factual alerts.
//
// This is a trend-context and visualization tool. It is NOT a trading system,
// it does NOT issue trade-action instructions, and it does NOT forecast price.
// ATR is used only for Supertrend boundary construction and for boundary-distance
// normalization. No Keltner channels, no session shading, no volatility-regime
// classification, no VWAP, no volume weighting, no RSI, no moving-average
// structure scoring. Nothing here is financial advice.
// =============================================================================

indicator(title = "Supertrend Transition Framework", shorttitle = "ST Transition", overlay = true, max_labels_count = 500)

// =============================================================================
// 1. INPUT GROUPS
// =============================================================================
g_calc = "Calculation"
g_fast = "Fast profile"
g_base = "Base profile"
g_slow = "Slow profile"
g_thr  = "Structure thresholds"
g_disp = "Display"
g_tbl  = "Context table style"
g_vis  = "Visual customization"

// ---- Calculation ----
bandSrc      = input.source(hl2,   "Band source",                   group = g_calc, display = display.none)
flipSrc      = input.source(close, "Flip source",                   group = g_calc, display = display.none)
confirmClose = input.bool(true,    "Confirm events on bar close",   group = g_calc, display = display.none)
autoWarm     = input.bool(true,    "Use automatic warm-up",         group = g_calc, display = display.none)

// ---- Fast profile (common starting point, not optimized) ----
fastOn     = input.bool(true,                  "Enable",       group = g_fast, display = display.none)
fastLen    = input.int(7,                      "ATR length",   minval = 1,               group = g_fast, display = display.none)
fastMult   = input.float(2.0,                  "Multiplier",   minval = 0.1, step = 0.1, group = g_fast, display = display.none)
fastShow   = input.bool(false,                 "Show line",    group = g_fast, display = display.none)
fastColor  = input.color(color.new(#787b86,0), "Color",        group = g_fast, display = display.none)
fastWidth  = input.int(1,                      "Width",        minval = 1, maxval = 4,   group = g_fast, display = display.none)
fastTransp = input.int(40,                     "Transparency", minval = 0, maxval = 100, group = g_fast, display = display.none)

// ---- Base profile (primary visible boundary; common starting point) ----
baseOn     = input.bool(true,                  "Enable",       group = g_base, display = display.none)
baseLen    = input.int(10,                     "ATR length",   minval = 1,               group = g_base, display = display.none)
baseMult   = input.float(3.0,                  "Multiplier",   minval = 0.1, step = 0.1, group = g_base, display = display.none)
baseShow   = input.bool(true,                  "Show line",    group = g_base, display = display.none)
baseColor  = input.color(color.new(#2962ff,0), "Color",        group = g_base, display = display.none)
baseWidth  = input.int(2,                      "Width",        minval = 1, maxval = 4,   group = g_base, display = display.none)
baseTransp = input.int(0,                      "Transparency", minval = 0, maxval = 100, group = g_base, display = display.none)

// ---- Slow profile (common starting point, not optimized) ----
slowOn     = input.bool(true,                  "Enable",       group = g_slow, display = display.none)
slowLen    = input.int(21,                     "ATR length",   minval = 1,               group = g_slow, display = display.none)
slowMult   = input.float(4.0,                  "Multiplier",   minval = 0.1, step = 0.1, group = g_slow, display = display.none)
slowShow   = input.bool(false,                 "Show line",    group = g_slow, display = display.none)
slowColor  = input.color(color.new(#b2b5be,0), "Color",        group = g_slow, display = display.none)
slowWidth  = input.int(1,                      "Width",        minval = 1, maxval = 4,   group = g_slow, display = display.none)
slowTransp = input.int(40,                     "Transparency", minval = 0, maxval = 100, group = g_slow, display = display.none)

// ---- Structure thresholds ----
agreeThr      = input.int(60,    "Agreement threshold",          minval = 0, maxval = 100, group = g_thr, display = display.none)
pressWin      = input.float(2.0, "Pressure ATR window",          minval = 0.1, step = 0.1, group = g_thr, display = display.none)
highPress     = input.int(70,    "High pressure threshold",      minval = 0, maxval = 100, group = g_thr, display = display.none)
touchTol      = input.float(0.15,"Boundary touch tolerance ATR", minval = 0, step = 0.05,  group = g_thr, display = display.none)
cascadeLB     = input.int(20,    "Cascade lookback",             minval = 1, maxval = 200, group = g_thr, display = display.none)
slopeLB       = input.int(5,     "Trail slope lookback",         minval = 1,               group = g_thr, display = display.none)
slopeFlat     = input.float(0.02,"Trail slope flat threshold %", minval = 0, step = 0.01,  group = g_thr, display = display.none)
driftLB       = input.int(10,    "ATR drift lookback",           minval = 1,               group = g_thr, display = display.none)
driftThr      = input.float(5.0, "ATR drift threshold %",        minval = 0, step = 0.5,   group = g_thr, display = display.none)
minStateBars  = input.int(1,     "Minimum state bars for event", minval = 1, maxval = 20,  group = g_thr, display = display.none)
eventCooldown = input.int(0,     "Event cooldown bars",          minval = 0, maxval = 50,  group = g_thr, display = display.none)

// ---- Display ----
showTable  = input.bool(true,             "Show context table", group = g_disp, display = display.none)
tblLayout  = input.string("Compact",      "Table layout",       options = ["Compact", "Standard", "Detailed"], group = g_disp, display = display.none)
tblPosSel  = input.string("Top right padded", "Table position", options = ["Top right padded", "Top right", "Top center", "Middle right", "Bottom right", "Bottom center"], group = g_disp, display = display.none)
tblTextSel = input.string("Normal",       "Table text size",    options = ["Tiny", "Small", "Normal", "Large"], group = g_disp, display = display.none)
labelMode  = input.string("Off",          "Label mode",         options = ["Off", "Base flips", "All events"], group = g_disp, display = display.none)
showTint   = input.bool(false,            "Show background tint", group = g_disp, display = display.none)
oneEvent   = input.bool(true,             "One event per bar",  group = g_disp, display = display.none)
maxLabels  = input.int(50,                "Maximum event labels", minval = 10, maxval = 200, group = g_disp, display = display.none)
showRtStatus         = input.bool(true,  "Show realtime status",               group = g_disp, display = display.none)
showBarStatusCompact = input.bool(false, "Show bar status in compact layout",  group = g_disp, display = display.none)

// ---- Context table style ----
hdrTextSel  = input.string("Normal", "Header text size", options = ["Tiny", "Small", "Normal", "Large"], group = g_tbl, display = display.none)
frameWidth  = input.int(1,    "Frame width",  minval = 0, maxval = 5, group = g_tbl, display = display.none)
borderWidth = input.int(1,    "Border width", minval = 0, maxval = 5, group = g_tbl, display = display.none)
altRows     = input.bool(true,"Alternating rows", group = g_tbl, display = display.none)
stateHL     = input.bool(true,"State row highlight", group = g_tbl, display = display.none)
padSpacing  = input.int(2,    "Top right padded spacing", minval = 0, maxval = 8, group = g_tbl, display = display.none)
fixedCells  = input.bool(false,"Fixed cell sizing", group = g_tbl, display = display.none)
cellLblW    = input.float(0,  "Label/value width", minval = 0, maxval = 30, group = g_tbl, display = display.none)
rowHeight   = input.float(0,  "Row/header height", minval = 0, maxval = 10, group = g_tbl, display = display.none)

// ---- Visual customization ----
posColor   = input.color(#26a69a,                "Positive structure color", group = g_vis, display = display.none)
negColor   = input.color(#ef5350,                "Negative structure color", group = g_vis, display = display.none)
neutColor  = input.color(#b2b5be,                "Neutral structure color",  group = g_vis, display = display.none)
activeCol  = input.color(#ffa726,                "Active trail color",       group = g_vis, display = display.none)
tblBg      = input.color(color.new(#1e222d, 10), "Table background",         group = g_vis, display = display.none)
tblHdrBg   = input.color(color.new(#2a2e39, 0),  "Table header background",  group = g_vis, display = display.none)
tblText    = input.color(#d1d4dc,                "Table text color",         group = g_vis, display = display.none)
tblAltBg   = input.color(color.new(#2a2e39, 40), "Table alt row background", group = g_vis, display = display.none)
tblStateBg = input.color(color.new(#2962ff, 70), "Table state highlight",    group = g_vis, display = display.none)
tblBorder  = input.color(color.new(#363a45, 0),  "Table border color",       group = g_vis, display = display.none)
tblFrame   = input.color(color.new(#363a45, 0),  "Table frame color",        group = g_vis, display = display.none)
tintTransp = input.int(90,                        "Fill / tint transparency", minval = 0, maxval = 100, group = g_vis, display = display.none)
lblBgTransp= input.int(10,                        "Label transparency",       minval = 0, maxval = 100, group = g_vis, display = display.none)
lblTextCol = input.color(#ffffff,                "Label text color",         group = g_vis, display = display.none)

// =============================================================================
// 2. HELPER FUNCTIONS
// =============================================================================
f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_pos(string s) =>
    switch s
        "Top center"    => position.top_center
        "Middle right"  => position.middle_right
        "Bottom right"  => position.bottom_right
        "Bottom center" => position.bottom_center
        => position.top_right

f_dirTxt(int d) =>
    na(d) ? "—" : d > 0 ? "Upward" : "Downward"

f_dirCol(int d) =>
    na(d) ? neutColor : d > 0 ? posColor : negColor

f_agreeCol(string s) =>
    s == "Agreement upward" ? posColor : s == "Agreement downward" ? negColor : neutColor

f_num(float v, string fmt) =>
    na(v) ? "—" : str.tostring(v, fmt)

f_sign(float v, string fmt) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, fmt)

// Bars since a profile last changed direction.
// var state is per call-site, so each profile keeps independent history.
f_flipAge(int d) =>
    var int age = na
    if na(d)
        age := na
    else if na(d[1])
        age := 0
    else if d != d[1]
        age := 0
    else
        age := nz(age, 0) + 1
    age

// Manual Supertrend. Computes raw bands, final upper/lower bands, direction,
// trail and the ATR used. Guards early bars, na ATR and na previous bands.
// Returns [trail, direction, atrUsed, ready].
f_supertrend(simple int len, simple float mult, float bsrc, float fsrc, simple bool useWarm) =>
    float atr = ta.atr(len)
    float basicUpper = bsrc + mult * atr
    float basicLower = bsrc - mult * atr
    var float finalUpper = na
    var float finalLower = na
    var int  dir = 1
    finalUpper := na(finalUpper[1]) ? basicUpper : ((basicUpper < finalUpper[1] or fsrc[1] > finalUpper[1]) ? basicUpper : finalUpper[1])
    finalLower := na(finalLower[1]) ? basicLower : ((basicLower > finalLower[1] or fsrc[1] < finalLower[1]) ? basicLower : finalLower[1])
    int prevDir = nz(dir[1], 1)
    dir := prevDir
    if prevDir == -1 and fsrc > finalUpper[1]
        dir := 1
    else if prevDir == 1 and fsrc < finalLower[1]
        dir := -1
    float trail = dir > 0 ? finalLower : finalUpper
    bool ready = not na(atr) and (useWarm ? bar_index >= len : true)
    int   dirOut   = ready ? dir : na
    float trailOut = ready ? trail : na
    [trailOut, dirOut, atr, ready]

// =============================================================================
// 3. DERIVED GLOBALS  (needed by table helpers below)
// =============================================================================
string tblSize = f_size(tblTextSel)
string hdrSize = f_size(hdrTextSel)
bool   padded  = tblPosSel == "Top right padded"
string padStr  = padded ? str.repeat(" ", padSpacing) : ""

// Data row: label cell + value cell + right spacer. Alternating + state highlight.
f_drow(table t, int row, int idx, string lbl, string val, color valc, bool isState) =>
    color bg = isState and stateHL ? tblStateBg : (altRows and idx % 2 == 1 ? tblAltBg : tblBg)
    table.cell(t, 0, row, lbl, text_color = tblText, bgcolor = bg, text_size = tblSize, text_halign = text.align_left,  width = fixedCells ? cellLblW : 0, height = fixedCells ? rowHeight : 0)
    table.cell(t, 1, row, val, text_color = valc,    bgcolor = bg, text_size = tblSize, text_halign = text.align_right, width = fixedCells ? cellLblW : 0, height = fixedCells ? rowHeight : 0)
    table.cell(t, 2, row, padStr, bgcolor = na, text_size = tblSize)

f_header(table t, int row, string title, string sub) =>
    table.cell(t, 0, row, title, text_color = tblText, bgcolor = tblHdrBg, text_size = hdrSize, text_halign = text.align_left)
    table.cell(t, 1, row, sub,   text_color = tblText, bgcolor = tblHdrBg, text_size = hdrSize, text_halign = text.align_right)
    table.cell(t, 2, row, padStr, bgcolor = na, text_size = hdrSize)

// =============================================================================
// 4. MANUAL SUPERTREND PROFILES
// =============================================================================
[fastTrailR, fastDirR, fastAtr, fastReadyR] = f_supertrend(fastLen, fastMult, bandSrc, flipSrc, autoWarm)
[baseTrailR, baseDirR, baseAtr, baseReadyR] = f_supertrend(baseLen, baseMult, bandSrc, flipSrc, autoWarm)
[slowTrailR, slowDirR, slowAtr, slowReadyR] = f_supertrend(slowLen, slowMult, bandSrc, flipSrc, autoWarm)

// Apply enable switches. Direction convention: +1 up, -1 down, na = warming up.
float fastTrail = fastOn ? fastTrailR : na
int   fastDir   = fastOn and fastReadyR ? fastDirR : na
float baseTrail = baseOn ? baseTrailR : na
int   baseDir   = baseOn and baseReadyR ? baseDirR : na
float slowTrail = slowOn ? slowTrailR : na
int   slowDir   = slowOn and slowReadyR ? slowDirR : na

bool baseValid = baseOn and not na(baseDir)

// =============================================================================
// 5. SUPERTREND AGREEMENT SCORE
// Agreement is only meaningful across >= 2 valid profiles. A single valid
// profile is never reported as agreement (it would read a misleading +/-100).
// =============================================================================
int enabledCount = (fastOn ? 1 : 0) + (baseOn ? 1 : 0) + (slowOn ? 1 : 0)
int validCount   = (na(fastDir) ? 0 : 1) + (na(baseDir) ? 0 : 1) + (na(slowDir) ? 0 : 1)
int upCount      = ((not na(fastDir) and fastDir == 1) ? 1 : 0) + ((not na(baseDir) and baseDir == 1) ? 1 : 0) + ((not na(slowDir) and slowDir == 1) ? 1 : 0)
int downCount    = ((not na(fastDir) and fastDir == -1) ? 1 : 0) + ((not na(baseDir) and baseDir == -1) ? 1 : 0) + ((not na(slowDir) and slowDir == -1) ? 1 : 0)
int sumDir       = nz(fastDir) + nz(baseDir) + nz(slowDir)

// Per-profile readiness (enabled and with a valid direction). baseReady == baseValid.
bool fastReady = fastOn and not na(fastDir)
bool slowReady = slowOn and not na(slowDir)
bool baseReady = baseValid

// Agreement also requires the base anchor, so the score never contradicts a
// "Need base profile" State (e.g. base disabled but fast+slow both valid).
bool agreementReady = baseValid and validCount >= 2
float agreeScore = agreementReady ? 100.0 * sumDir / validCount : na

// Readiness-aware state. Base is the anchor; without it the table says so.
string agreeState = enabledCount == 0 ? "Need profiles" : not baseOn ? "Need base profile" : not baseValid ? "Warming up" : validCount < 2 ? "Need 2+ valid profiles" : (not na(agreeScore) and agreeScore >= agreeThr) ? "Agreement upward" : (not na(agreeScore) and agreeScore <= -agreeThr) ? "Agreement downward" : "Mixed profiles"

// =============================================================================
// 6. BASE BOUNDARY DISTANCE  (in ATR units)
// =============================================================================
float tiny       = 1e-10
float activeTrail = baseTrail
float rawDistance = baseValid ? close - activeTrail : na
float distanceATR = (baseValid and baseAtr > tiny) ? rawDistance / baseAtr : na
float absDistanceATR = na(distanceATR) ? na : math.abs(distanceATR)
float distanceToBoundaryATR = absDistanceATR

// =============================================================================
// 7. TRANSITION PRESSURE  (proximity to the active boundary; not a forecast)
// =============================================================================
float pressure = na(distanceToBoundaryATR) ? na : 100.0 * math.max(0.0, 1.0 - math.min(distanceToBoundaryATR / pressWin, 1.0))

// =============================================================================
// 8. FLIP AGE  (per profile) + BASE FLIP AGE
// =============================================================================
int fastFA = f_flipAge(fastDir)
int baseFA = f_flipAge(baseDir)
int slowFA = f_flipAge(slowDir)

// =============================================================================
// 9. BOUNDARY TOUCH CONTEXT
// =============================================================================
bool touchNow = false
if baseValid
    if baseDir == 1
        touchNow := (low <= activeTrail) or (absDistanceATR <= touchTol)
    else if baseDir == -1
        touchNow := (high >= activeTrail) or (absDistanceATR <= touchTol)

var int touchAge = na
if not baseValid
    touchAge := na
else if touchNow
    touchAge := 0
else if na(touchAge)
    touchAge := na
else
    touchAge := touchAge + 1

// =============================================================================
// 10. FLIP CASCADE CONTEXT
// =============================================================================
f_aligned(int d, int en, int fa) =>
    en == 1 and not na(d) and not na(baseDir) and d == baseDir and not na(fa) and fa <= cascadeLB
int cascadeCount = (f_aligned(fastDir, fastOn ? 1 : 0, fastFA) ? 1 : 0) + (f_aligned(baseDir, baseOn ? 1 : 0, baseFA) ? 1 : 0) + (f_aligned(slowDir, slowOn ? 1 : 0, slowFA) ? 1 : 0)
string cascadeText = (na(baseDir) or validCount < 1) ? "n/a" : (cascadeCount >= validCount and validCount >= 2) ? "Full cascade" : cascadeCount >= 2 ? "Partial cascade" : "No cascade"

// =============================================================================
// 11. TRAIL SLOPE CONTEXT
// =============================================================================
float baseTrailPrev = baseValid ? baseTrail[slopeLB] : na
float slopePct = (not na(baseTrail) and not na(baseTrailPrev) and math.abs(baseTrailPrev) > tiny) ? 100.0 * (baseTrail - baseTrailPrev) / math.abs(baseTrailPrev) : na
string slopeState = na(slopePct) ? "n/a" : slopePct > slopeFlat ? "Rising trail" : slopePct < -slopeFlat ? "Falling trail" : "Flat trail"

// =============================================================================
// 12. ATR INPUT DRIFT  (descriptive only; not a volatility regime)
// =============================================================================
float baseAtrPrev = baseValid ? baseAtr[driftLB] : na
float driftPct = (not na(baseAtr) and not na(baseAtrPrev) and baseAtrPrev > tiny) ? 100.0 * (baseAtr - baseAtrPrev) / baseAtrPrev : na
string driftState = na(driftPct) ? "n/a" : driftPct > driftThr ? "ATR input rising" : driftPct < -driftThr ? "ATR input falling" : "ATR input steady"

// =============================================================================
// 13. TRANSITION STATE  (direction / agreement focused; pressure is separate)
// Boundary proximity is surfaced in Transition Context below, so a high-pressure
// reading never hides the directional / agreement State.
// =============================================================================
string tState = na
int tStateId = na
if enabledCount == 0
    tState := "Need profiles"
    tStateId := 0
else if not baseOn
    tState := "Need base profile"
    tStateId := 1
else if not baseValid
    tState := "Warming up"
    tStateId := 2
else if validCount < 2
    tState := "Need 2+ valid profiles"
    tStateId := 3
else if baseDir == 1 and not na(agreeScore) and agreeScore >= agreeThr
    tState := "Upward agreement"
    tStateId := 4
else if baseDir == -1 and not na(agreeScore) and agreeScore <= -agreeThr
    tState := "Downward agreement"
    tStateId := 5
else if baseDir == 1
    tState := "Upward base / mixed profiles"
    tStateId := 6
else if baseDir == -1
    tState := "Downward base / mixed profiles"
    tStateId := 7
else
    tState := "Mixed profiles"
    tStateId := 8

// Transition Context: descriptive proximity / cascade context, kept separate
// from the directional State so agreement readings are never overridden.
string transitionContext = not baseValid ? "n/a" : touchNow ? "Boundary touched" : (cascadeCount >= 2 and cascadeCount < validCount) ? "Cascade active" : cascadeText == "Full cascade" ? "Full cascade" : (not na(pressure) and pressure >= highPress) ? "High boundary pressure" : (not na(pressure) and pressure >= highPress * 0.5) ? "Moderate boundary pressure" : "Low boundary pressure"

// =============================================================================
// 14. STATE FINGERPRINT  (compact, descriptive)
// =============================================================================
string fpB = na(baseDir) ? "B0" : baseDir > 0 ? "B+" : "B-"
string fpA = agreeState == "Agreement upward" ? "A+" : agreeState == "Agreement downward" ? "A-" : "A0"
string fpP = na(pressure) ? "P--" : "P" + str.tostring(math.round(pressure), "0")
string fpC = "C" + str.tostring(cascadeCount)
string fpF = na(baseFA) ? "F--" : "F" + str.tostring(baseFA)
string fingerprint = fpB + " " + fpA + " " + fpP + " " + fpC + " " + fpF

// =============================================================================
// 15. FINAL EVENT ENGINE  (one engine shared by BOTH alerts and labels)
// -----------------------------------------------------------------------------
// The cooldown, one-event-per-bar lock and priority all apply to the FINAL
// events, so alerts and labels never diverge. State-like events (agreement,
// boundary pressure) use pending latches: if they first become eligible during
// a cooldown window they are delayed, not lost, as long as the state persists.
// Point-in-time events (base flips, touch, cascade) simply respect the engine.
// =============================================================================

// --- State activity + persistence (consecutive bars the state has held) ---
bool agrUpActive   = agreeState == "Agreement upward"
bool agrDownActive = agreeState == "Agreement downward"
bool agrMixActive  = agreeState == "Mixed profiles"
bool pressActive   = not na(pressure) and pressure >= highPress

var int agrUpBars   = 0
var int agrDownBars = 0
var int agrMixBars  = 0
var int pressBars   = 0
agrUpBars   := agrUpActive   ? nz(agrUpBars) + 1   : 0
agrDownBars := agrDownActive ? nz(agrDownBars) + 1 : 0
agrMixBars  := agrMixActive  ? nz(agrMixBars) + 1  : 0
pressBars   := pressActive   ? nz(pressBars) + 1   : 0

// --- "Already fired this episode" latches; cleared when the state ends so a
//     stale pending state never survives across a state change. ---
var bool firedAgrUp   = false
var bool firedAgrDown = false
var bool firedAgrMix  = false
var bool firedPress   = false
if not agrUpActive
    firedAgrUp := false
if not agrDownActive
    firedAgrDown := false
if not agrMixActive
    firedAgrMix := false
if not pressActive
    firedPress := false

// --- Point-in-time conditions ---
var string prevCascade = na
var bool   prevTouch   = false
bool flipUp   = baseValid and not na(baseDir[1]) and baseDir == 1  and baseDir[1] == -1
bool flipDown = baseValid and not na(baseDir[1]) and baseDir == -1 and baseDir[1] == 1
bool touchObserved  = touchNow and not prevTouch          // rising edge: once per touch episode
bool cascadeChanged = not na(prevCascade) and prevCascade != cascadeText

// --- Pending (delayable) state events: active + persisted + not yet fired ---
bool pendingAgrUp   = agrUpActive   and agrUpBars   >= minStateBars and not firedAgrUp
bool pendingAgrDown = agrDownActive and agrDownBars >= minStateBars and not firedAgrDown
bool pendingAgrMix  = agrMixActive  and agrMixBars  >= minStateBars and not firedAgrMix
bool pendingPress   = pressActive   and pressBars   >= minStateBars and not firedPress

// --- Confirm-on-close gate. Controls only whether alerts may be intrabar;
//     labels stay confirmed-bar regardless (see the label section). ---
bool gate = confirmClose ? barstate.isconfirmed : true

// --- Eligibility (gated raw events) ---
bool elFlipUp   = flipUp         and gate
bool elFlipDown = flipDown       and gate
bool elAgrUp    = pendingAgrUp   and gate
bool elAgrDown  = pendingAgrDown and gate
bool elAgrMix   = pendingAgrMix  and gate
bool elCascade  = cascadeChanged and gate
bool elPress    = pendingPress   and gate
bool elTouch    = touchObserved  and gate

// --- Shared bar-based cooldown (cooldown N blocks the next N bars). Realtime
//     ticks do not decrement it because it compares committed bar indices. ---
var int lastFinalEventBar = na
bool cooldownOk = eventCooldown == 0 or na(lastFinalEventBar) or (bar_index - lastFinalEventBar) > eventCooldown

// --- Final events. Priority: flips > agreement > cascade > pressure > touch.
//     One event per bar => only the single highest-priority eligible event.  ---
bool finalFlipUp   = false
bool finalFlipDown = false
bool finalAgrUp    = false
bool finalAgrDown  = false
bool finalAgrMixed = false
bool finalCascade  = false
bool finalPress    = false
bool finalTouch    = false
if cooldownOk
    if oneEvent
        if elFlipUp
            finalFlipUp := true
        else if elFlipDown
            finalFlipDown := true
        else if elAgrUp
            finalAgrUp := true
        else if elAgrDown
            finalAgrDown := true
        else if elAgrMix
            finalAgrMixed := true
        else if elCascade
            finalCascade := true
        else if elPress
            finalPress := true
        else if elTouch
            finalTouch := true
    else
        finalFlipUp   := elFlipUp
        finalFlipDown := elFlipDown
        finalAgrUp    := elAgrUp
        finalAgrDown  := elAgrDown
        finalAgrMixed := elAgrMix
        finalCascade  := elCascade
        finalPress    := elPress
        finalTouch    := elTouch

bool anyFinal = finalFlipUp or finalFlipDown or finalAgrUp or finalAgrDown or finalAgrMixed or finalCascade or finalPress or finalTouch
if anyFinal
    lastFinalEventBar := bar_index
// Mark fired state episodes so each emits once and re-arms only after the state ends.
if finalAgrUp
    firedAgrUp := true
if finalAgrDown
    firedAgrDown := true
if finalAgrMixed
    firedAgrMix := true
if finalPress
    firedPress := true

// =============================================================================
// 16. ALERTS  (wired to the SAME final events as the labels; factual wording,
// no trade-action, no prediction, no performance claims)
// =============================================================================
alertcondition(finalFlipUp,   "Base Supertrend flipped upward",      "The base Supertrend profile changed to upward structure.")
alertcondition(finalFlipDown, "Base Supertrend flipped downward",    "The base Supertrend profile changed to downward structure.")
alertcondition(finalAgrUp,    "Profiles reached upward agreement",   "The enabled Supertrend profiles reached upward agreement.")
alertcondition(finalAgrDown,  "Profiles reached downward agreement", "The enabled Supertrend profiles reached downward agreement.")
alertcondition(finalAgrMixed, "Profiles became mixed",               "The enabled Supertrend profiles became mixed.")
alertcondition(finalPress,    "Boundary pressure reached threshold", "The boundary pressure reached the selected threshold.")
alertcondition(finalTouch,    "Boundary touch observed",             "Price touched or approached the active Supertrend boundary within the selected tolerance.")
alertcondition(finalCascade,  "Cascade context changed",             "The Supertrend profile cascade context changed.")

// =============================================================================
// 17. EVENT LABELS  (capped; off by default; the SAME final events as alerts)
// -----------------------------------------------------------------------------
// Labels are confirmed-bar visual records: drawn only on bar close so they do
// not repaint, even when Confirm-on-close is off (which only affects alerts).
// Agreement up/down are alert-only; the marker set is Flip+/-, Mixed, Cascade,
// Pressure, Touch. Final events already encode cooldown + one-event-per-bar.
// =============================================================================
var label[] evLabels = array.new<label>()

// Append one capped event label; delete the oldest once the cap is exceeded.
f_emitLabel(float y, string txt, color col) =>
    label lb = label.new(bar_index, y, txt, style = label.style_label_center, color = col, textcolor = lblTextCol, size = size.small, yloc = yloc.price)
    array.push(evLabels, lb)
    if array.size(evLabels) > maxLabels
        label.delete(array.shift(evLabels))

bool allowFlips = labelMode != "Off"
bool allowAll   = labelMode == "All events"
if barstate.isconfirmed and labelMode != "Off"
    if finalFlipUp and allowFlips
        f_emitLabel(baseTrail, "Flip+", color.new(posColor, lblBgTransp))
    if finalFlipDown and allowFlips
        f_emitLabel(baseTrail, "Flip-", color.new(negColor, lblBgTransp))
    if allowAll and finalAgrMixed
        f_emitLabel(high, "Mixed", color.new(neutColor, lblBgTransp))
    if allowAll and finalCascade
        f_emitLabel(baseDir == 1 ? low : high, "Cascade", color.new(activeCol, lblBgTransp))
    if allowAll and finalPress
        f_emitLabel(baseDir == 1 ? low : high, "Pressure", color.new(activeCol, lblBgTransp))
    if allowAll and finalTouch
        f_emitLabel(baseDir == 1 ? low : high, "Touch", color.new(neutColor, lblBgTransp))

// Commit point-in-time trackers for next bar.
prevCascade := cascadeText
prevTouch := touchNow

// =============================================================================
// 18. PLOTS  (kept far below the 64-plot limit; no Data-Window research plots)
// =============================================================================
// Break the line on a confirmed flip so flips do not draw a vertical connector.
float fastPlot = (fastOn and fastShow and not na(fastDir)) ? ((not na(fastDir[1]) and fastDir != fastDir[1]) ? na : fastTrail) : na
float basePlot = (baseOn and baseShow and not na(baseDir)) ? ((not na(baseDir[1]) and baseDir != baseDir[1]) ? na : baseTrail) : na
float slowPlot = (slowOn and slowShow and not na(slowDir)) ? ((not na(slowDir[1]) and slowDir != slowDir[1]) ? na : slowTrail) : na

plot(fastPlot, "Fast trail", color = color.new(fastColor, fastTransp), linewidth = fastWidth, display = display.all - display.status_line)
plot(basePlot, "Base trail", color = color.new(baseColor, baseTransp), linewidth = baseWidth, display = display.all - display.status_line)
plot(slowPlot, "Slow trail", color = color.new(slowColor, slowTransp), linewidth = slowWidth, display = display.all - display.status_line)

color tintCol = (showTint and baseValid) ? color.new(baseDir > 0 ? posColor : negColor, tintTransp) : na
bgcolor(tintCol, title = "Transition tint")

// =============================================================================
// 19. CONTEXT TABLE
// =============================================================================
var table  ctx = na
var string ctxSig = na

// Pre-format display strings.
string vState     = tState
string vTransCtx  = transitionContext
string vFinger    = fingerprint
string vBaseDir   = f_dirTxt(baseDir)
string vFastDir   = f_dirTxt(fastDir)
string vSlowDir   = f_dirTxt(slowDir)
string vAgree     = agreeState
string vAgreeScr  = f_sign(agreeScore, "0")
string vPress     = na(pressure) ? "—" : str.tostring(math.round(pressure), "0")
string vDist      = na(distanceToBoundaryATR) ? "—" : str.tostring(distanceToBoundaryATR, "0.00") + " ATR"
string vFlipAge   = na(baseFA) ? "—" : str.tostring(baseFA)
string vCascade   = cascadeText
string vSlopeSt   = slopeState
string vTouchAge  = na(touchAge) ? "—" : str.tostring(touchAge)
// Alert mode and Label mode are disclosed separately: alerts may be intrabar,
// but labels are always confirmed-bar visual records.
string vAlertMode = confirmClose ? "Confirmed close" : "Intrabar allowed"
string vLabelMode = labelMode == "Off" ? "Off (confirmed)" : labelMode + " (confirmed)"
string vBarStatus = showRtStatus ? (barstate.isrealtime ? "Realtime" : "Confirmed") : "—"
string vAtrTriple = f_num(fastAtr, "0.#####") + " / " + f_num(baseAtr, "0.#####") + " / " + f_num(slowAtr, "0.#####")
string vBaseTrail = f_num(baseTrail, format.mintick)
string vSlopePct  = na(slopePct) ? "—" : (slopePct > 0 ? "+" : "") + str.tostring(slopePct, "0.000") + "%"
string vDriftPct  = na(driftPct) ? "—" : (driftPct > 0 ? "+" : "") + str.tostring(driftPct, "0.0") + "%  " + driftState
string vCascCount = str.tostring(cascadeCount)
string vStateId   = na(tStateId) ? "—" : str.tostring(tStateId)
string vActive    = "ATR " + str.tostring(fastLen) + "/" + str.tostring(baseLen) + "/" + str.tostring(slowLen) + "  x" + str.tostring(fastMult, "0.0") + "/" + str.tostring(baseMult, "0.0") + "/" + str.tostring(slowMult, "0.0")
// Research-surface fields (Detailed layout). The table is the research surface;
// no Data Window-only plot() outputs are used anywhere in the script.
string vEnabled   = str.tostring(enabledCount)
string vValid     = str.tostring(validCount)
string vUpDown    = str.tostring(upCount) + " / " + str.tostring(downCount)
string vAgrReady  = agreementReady ? "Yes" : "No"
string vReady3    = (fastReady ? "Y" : "N") + " / " + (baseReady ? "Y" : "N") + " / " + (slowReady ? "Y" : "N")
string vPressWin  = str.tostring(pressWin, "0.0") + " ATR"
string vTouchTol  = str.tostring(touchTol, "0.00") + " ATR"
string vCdState   = eventCooldown == 0 ? "Off" : cooldownOk ? "Ready" : "Blocked " + str.tostring(lastFinalEventBar + eventCooldown + 1 - bar_index)
string vLastEvt   = na(lastFinalEventBar) ? "—" : str.tostring(bar_index - lastFinalEventBar)
string vLabelCap  = str.tostring(array.size(evLabels)) + " / " + str.tostring(maxLabels)

if barstate.islast
    string sig = tblPosSel + "|" + str.tostring(borderWidth) + "|" + str.tostring(frameWidth)
    if not showTable
        if not na(ctx)
            table.delete(ctx)
            ctx := na
            ctxSig := na
    else
        if na(ctx) or ctxSig != sig
            if not na(ctx)
                table.delete(ctx)
            ctx := table.new(f_pos(tblPosSel), 3, 28, frame_color = tblFrame, frame_width = frameWidth, border_color = tblBorder, border_width = borderWidth)
            ctxSig := sig
        table.clear(ctx, 0, 0, 2, 27)

        // Header row sits below an optional top-pad spacer row; content follows.
        int hdrRow = padded ? 1 : 0
        int base0  = hdrRow + 1
        if padded
            table.cell(ctx, 0, 0, "", bgcolor = na)
            table.cell(ctx, 1, 0, "", bgcolor = na)
            table.cell(ctx, 2, 0, padStr, bgcolor = na)

        f_header(ctx, hdrRow, "ST Transition", tblLayout)

        if tblLayout == "Compact"
            f_drow(ctx, base0 + 0, 0, "State",              vState,    f_dirCol(baseDir),      true)
            f_drow(ctx, base0 + 1, 1, "Fingerprint",        vFinger,   tblText,                false)
            f_drow(ctx, base0 + 2, 2, "Transition context", vTransCtx, tblText,                false)
            f_drow(ctx, base0 + 3, 3, "Base direction",     vBaseDir,  f_dirCol(baseDir),      false)
            f_drow(ctx, base0 + 4, 4, "Agreement",          vAgree,    f_agreeCol(agreeState), false)
            f_drow(ctx, base0 + 5, 5, "Boundary distance",  vDist,     tblText,                false)
            f_drow(ctx, base0 + 6, 6, "Flip age",           vFlipAge,  tblText,                false)
            if showBarStatusCompact
                f_drow(ctx, base0 + 7, 7, "Bar status",     vBarStatus, tblText,               false)
        else if tblLayout == "Standard"
            f_drow(ctx, base0 + 0,  0,  "State",                 vState,     f_dirCol(baseDir),      true)
            f_drow(ctx, base0 + 1,  1,  "Fingerprint",           vFinger,    tblText,                false)
            f_drow(ctx, base0 + 2,  2,  "Transition context",    vTransCtx,  tblText,                false)
            f_drow(ctx, base0 + 3,  3,  "Base direction",        vBaseDir,   f_dirCol(baseDir),      false)
            f_drow(ctx, base0 + 4,  4,  "Agreement score",       vAgreeScr,  f_agreeCol(agreeState), false)
            f_drow(ctx, base0 + 5,  5,  "Boundary pressure",     vPress,     tblText,                false)
            f_drow(ctx, base0 + 6,  6,  "Boundary distance ATR", vDist,      tblText,                false)
            f_drow(ctx, base0 + 7,  7,  "Cascade",               vCascade,   tblText,                false)
            f_drow(ctx, base0 + 8,  8,  "Trail slope",           vSlopeSt,   tblText,                false)
            f_drow(ctx, base0 + 9,  9,  "Last boundary touch",   vTouchAge,  tblText,                false)
            f_drow(ctx, base0 + 10, 10, "Alert mode",            vAlertMode, tblText,                false)
            f_drow(ctx, base0 + 11, 11, "Label mode",            vLabelMode, tblText,                false)
            f_drow(ctx, base0 + 12, 12, "Bar status",            vBarStatus, tblText,                false)
        else
            f_drow(ctx, base0 + 0,  0,  "State",                    vState,     f_dirCol(baseDir),  true)
            f_drow(ctx, base0 + 1,  1,  "Transition context",       vTransCtx,  tblText,            false)
            f_drow(ctx, base0 + 2,  2,  "Fast direction",           vFastDir,   f_dirCol(fastDir),  false)
            f_drow(ctx, base0 + 3,  3,  "Base direction",           vBaseDir,   f_dirCol(baseDir),  false)
            f_drow(ctx, base0 + 4,  4,  "Slow direction",           vSlowDir,   f_dirCol(slowDir),  false)
            f_drow(ctx, base0 + 5,  5,  "Enabled profiles",         vEnabled,   tblText,            false)
            f_drow(ctx, base0 + 6,  6,  "Valid profiles",           vValid,     tblText,            false)
            f_drow(ctx, base0 + 7,  7,  "Up / Down profiles",       vUpDown,    tblText,            false)
            f_drow(ctx, base0 + 8,  8,  "Agreement ready",          vAgrReady,  tblText,            false)
            f_drow(ctx, base0 + 9,  9,  "Fast / Base / Slow ready", vReady3,    tblText,            false)
            f_drow(ctx, base0 + 10, 10, "Fast / Base / Slow ATR",   vAtrTriple, tblText,            false)
            f_drow(ctx, base0 + 11, 11, "Base trail",               vBaseTrail, activeCol,          false)
            f_drow(ctx, base0 + 12, 12, "Trail slope %",            vSlopePct,  tblText,            false)
            f_drow(ctx, base0 + 13, 13, "ATR drift %",              vDriftPct,  tblText,            false)
            f_drow(ctx, base0 + 14, 14, "Cascade count",            vCascCount, tblText,            false)
            f_drow(ctx, base0 + 15, 15, "Flip age",                 vFlipAge,   tblText,            false)
            f_drow(ctx, base0 + 16, 16, "Boundary touch age",       vTouchAge,  tblText,            false)
            f_drow(ctx, base0 + 17, 17, "Pressure window",          vPressWin,  tblText,            false)
            f_drow(ctx, base0 + 18, 18, "Touch tolerance",          vTouchTol,  tblText,            false)
            f_drow(ctx, base0 + 19, 19, "Cooldown state",           vCdState,   tblText,            false)
            f_drow(ctx, base0 + 20, 20, "Last event age",           vLastEvt,   tblText,            false)
            f_drow(ctx, base0 + 21, 21, "Label cap",                vLabelCap,  tblText,            false)
            f_drow(ctx, base0 + 22, 22, "State ID",                 vStateId,   tblText,            false)
            f_drow(ctx, base0 + 23, 23, "Active settings",          vActive,    tblText,            false)
// =============================================================================
// End of Supertrend Transition Framework
// =============================================================================
````
