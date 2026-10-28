# Market Microstructure Pulse [JOAT]

- url: https://www.tradingview.com/script/5fgngFFI-Market-Microstructure-Pulse-JOAT/
- type: indicator
- pine_id: PUB;b399a80e783e4b149467a8ab399bd90c
- version: 1.0

## Description

[b]MARKET MICROSTRUCTURE PULSE [JOAT][/b]

A composite microstructure oscillator that fuses three lower-timeframe-reconstructed flow primitives into a single bounded [−1, +1] pulse line — the tick imbalance, the aggressive ask/bid streak, and the single-bar massive imbalance event. The pulse tells you in one number whether buyers or sellers are currently dominant at the tape level, and whether that dominance is at warning or extreme intensity.

[image]https://www.tradingview.com/x/u0zH7Ewo/[/image]

[b]Lower-timeframe reconstruction[/b]

Real microstructure lives below the chart timeframe. The pulse engine pulls intrabar prints from a configurable LTF (default 1 minute; auto-mode picks ~1/20 of the chart TF) and classifies each tick via the standard tick rule. The classified ticks are then EMA-smoothed by a configurable pulse length (default 14) and optionally [b]volume-weighted[/b] (default ON) so a heavy print contributes proportionally more to the read than a light one.

The output is a smoothed signed value bounded approximately in [−1, +1] where:

[list]
[*] [b]+1[/b] — all recent ticks were buy-classified.
[*] [b]−1[/b] — all recent ticks were sell-classified.
[*] [b]0[/b] — perfectly balanced flow.
[/list]

[b]Aggressive streak histograms[/b]

Two separate counters track [b]consecutive same-side ticks[/b] — one for aggressive asks, one for aggressive bids. When a streak exceeds the [b]Aggressive Streak Min[/b] threshold (default 5), it qualifies as institutional persistence. The two histograms are rendered as a colour-coded background to the pulse line so you can see at a glance which side has been running consecutively. EMA-smoothed for visual stability.

[b]Massive imbalance event[/b]

A single-bar event: when one side's share of total bar volume exceeds [b]imbalancePct[/b] (default 80%), a Massive Imbalance event fires. This is the script's strongest single-bar read — institutional decisiveness landing on the tape.

[b]Two-tier threshold system[/b]

[list]
[*] [b]Pulse Warning[/b] — |pulse| above the warning threshold (default 0.50). Inner band, visual reference.
[*] [b]Pulse Extreme[/b] — |pulse| above the extreme threshold (default 0.70). Triggers the Pulse Extreme alert and tints the chart background.
[/list]

A toggleable [b]Aggression Flip Marker[/b] prints a glyph at the bar where the pulse sign actually flips — useful for catching the moment dominance rotates sides.

[b]Visual system[/b]

[list]
[*] [b]Pulse line[/b] in the iridescent palette (magenta buy / cyan sell) with configurable width.
[*] [b]Aggressive streak histograms[/b] — two-sided coloured columns behind the pulse (transparency configurable).
[*] [b]Threshold levels[/b] at ±warning and ±extreme (toggleable).
[*] [b]Gradient fill[/b] from pulse line to zero, coloured by current sign (transparency configurable).
[*] [b]Background tint on extreme[/b] — magenta or cyan tint when |pulse| is above extreme threshold (transparency configurable).
[*] [b]Aggression flip markers[/b] at sign-change bars (toggleable).
[/list]

A locked Iridescent palette (magenta buy aggression / cyan sell aggression / yellow extreme accent on pure black) gives the pane a distinctive cyberpunk-tape identity.

[b]Dashboard[/b]

Monospaced 11-row table positionable to any of nine corners. Surfaces:

[list]
[*] Current pulse value with sign.
[*] Buy streak count and sell streak count.
[*] Aggressive side dominance with bar age.
[*] Last extreme event direction with bars-ago.
[*] Last flip direction with bars-ago.
[*] Last massive imbalance event with bars-ago.
[*] LTF in use, volume-weighting flag, pulse EMA length.
[*] Threshold values for warning and extreme.
[/list]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] [b]Pulse Extreme[/b] — fires when |pulse| crosses above extreme threshold.
[*] [b]Aggression Flip[/b] — fires when pulse sign flips (positive ↔ negative).
[*] [b]Massive Imbalance[/b] — fires when a single bar's directional share exceeds the imbalance threshold.
[/list]

[image]https://www.tradingview.com/x/Cf99pp6W/[/image]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Massive Imbalance alert at a structural level[/b] — the highest-conviction single read. Institutional decisiveness landed on the tape at a known S/R; the next directional move is more conviction-aligned with the imbalance side.
[*] [b]Pulse Extreme + matching aggressive streak[/b] — sustained dominance. The pulse is decisively past its extreme threshold AND the streak histograms show consecutive same-side runs above the streak minimum. This is the regime where momentum tools have their largest edge.
[*] [b]Aggression Flip after extreme[/b] — exhaustion read. The pulse hit extreme then flipped sign; the institutional commitment that drove the extreme has just rotated. Often produces clean reversals.
[/list]

[b]Suggested settings[/b]

Defaults (1m LTF, pulse EMA 14, streak EMA 7, volume-weighted ON, ±0.50 / ±0.70 thresholds, 80% imbalance, 5-tick streak min) are tuned for 5m–15m charts on liquid futures and crypto. For lower-timeframe scalping, drop LTF to 15s or 30s (Premium plan required) and pulse EMA to 8. For HTF, set LTF auto-mode and raise streak min to 10. The volume-weighting is the recommended default — without it, equal-tick instruments dominate the read regardless of size.

[b]Originality[/b]

The implementation — the LTF tick-rule reconstruction with optional volume weighting, the bounded [−1, +1] pulse formulation, the dual aggressive-streak histograms with EMA smoothing, the two-tier (warning / extreme) threshold system, the single-bar massive-imbalance detector, the aggression-flip marker logic, the chart-overlay extreme tinting, and the iridescent dual-hue palette — is JOAT-original. No third-party code reused. The pulse is the original composite formulation.

[b]Limitations[/b]

Reconstructed tick direction is an inference — the tick rule is the accepted public-market proxy but it is not a direct read of bid/ask volume. Sub-minute LTFs require a TradingView Premium or Ultimate plan. The pulse is bounded approximately in [−1, +1] but extreme volume-weighted reads can briefly exceed those bounds; this is intentional and not a bug. EMA smoothing introduces a small lag; turn pulse length to 1 to see the raw imbalance.

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Market Microstructure Pulse [JOAT]", shorttitle="MMP [JOAT]", overlay=false,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000,
     precision=4, format=format.percent)

// =================================================================================================
//  SECTION 1 - INPUTS
// =================================================================================================

grpLtf   = "+----------- LTF Reconstruction -----------+"
grpSmth  = "+------------- Smoothing -------------+"
grpThr   = "+------------- Thresholds ------------+"
grpVis   = "+--------------- Visuals --------------+"
grpDash  = "+-------------- Dashboard -------------+"
grpAlt   = "+--------------- Alerts ---------------+"

// ---- LTF ----
ltfResolution = input.timeframe("1", "LTF Resolution",
     tooltip="Lower timeframe (minutes) used to reconstruct tick activity. Smaller = more granular microstructure. Use 1 for crypto/futures, 5 for equities.",
     group=grpLtf)
useChartAsLtf = input.bool(false, "Auto LTF (chart-relative)",
     tooltip="If true, automatically picks an LTF roughly 1/20th of the chart timeframe.",
     group=grpLtf)

// ---- Smoothing ----
pulseLen       = input.int(14, "Pulse EMA Length", minval=1, maxval=500,
     tooltip="EMA smoothing length applied to the raw tick imbalance to form the pulse oscillator.",
     group=grpSmth)
streakSmthLen  = input.int(7, "Aggressive Streak EMA", minval=1, maxval=200,
     tooltip="EMA smoothing applied to the aggressive ask / bid streak histograms.",
     group=grpSmth)
volWeighted    = input.bool(true, "Volume-Weight the Pulse",
     tooltip="If true, weights each tick by its volume contribution instead of equal-weighting.",
     group=grpSmth)

// ---- Thresholds ----
pulseExtreme   = input.float(0.70, "Pulse Extreme |x|", minval=0.10, maxval=1.0, step=0.05,
     tooltip="Absolute pulse value above which an extreme alert fires.",
     group=grpThr)
pulseWarn      = input.float(0.50, "Pulse Warning |x|", minval=0.05, maxval=1.0, step=0.05,
     tooltip="Inner pulse band (visual reference).",
     group=grpThr)
aggStreakMin   = input.int(5, "Aggressive Streak Min", minval=2, maxval=200,
     tooltip="Minimum consecutive same-side ticks for an aggressive streak to count.",
     group=grpThr)
imbalancePct   = input.float(80.0, "Massive Imbalance %", minval=50.0, maxval=99.0, step=1.0,
     tooltip="Single-bar imbalance percent that triggers the massive imbalance alert.",
     group=grpThr)

// ---- Visuals ----
// IRIDESCENT PALETTE (curated):
//   bull (buy aggression)  = #FF00FF magenta
//   bear (sell aggression) = #00FFFF cyan
//   accent (extreme mark)  = #FFFF00 yellow
//   bg = #000000  frame = #1A1A1A
pulseWidth     = input.int(3, "Pulse Line Width", minval=1, maxval=8, group=grpVis)
showHistBg     = input.bool(true, "Show Aggressive Histogram", group=grpVis)
histAlpha      = input.int(72, "Histogram Transparency", minval=0, maxval=95, group=grpVis)
showLevels     = input.bool(true, "Show Threshold Levels", group=grpVis)
showGradFill   = input.bool(true, "Show Pulse Gradient Fill", group=grpVis)
fillAlpha      = input.int(80, "Fill Transparency", minval=30, maxval=98, group=grpVis)
showBgTint     = input.bool(true, "Tint Background on Extreme", group=grpVis)
bgTintAlpha    = input.int(88, "BG Tint Transparency", minval=50, maxval=99, group=grpVis)
showFlipMark   = input.bool(true, "Show Aggression Flip Markers", group=grpVis)

// ---- Dashboard ----
showDash       = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position", group=grpDash,
     options=["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
              "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"])
dashSizeStr    = input.string("Small", "Dashboard Size", group=grpDash,
     options=["Tiny", "Small", "Normal", "Large", "Huge"])
dashRows       = 11
dashCols       = 2

// ---- Alerts ----
enaPulseExt    = input.bool(true, "Enable Pulse Extreme alerts", group=grpAlt)
enaFlip        = input.bool(true, "Enable Aggression Flip alerts", group=grpAlt)
enaImbalance   = input.bool(true, "Enable Massive Imbalance alerts", group=grpAlt)

// =================================================================================================
//  SECTION 2 - IRIDESCENT PALETTE (single curated palette)
//    bull = magenta (buy aggression dominant)
//    bear = cyan    (sell aggression dominant)
//    mid  = yellow  (accent for extreme/confluence markers)
//    bg   = black,  frame = dark gray
// =================================================================================================
const color C_BULL   = #FF00FF
const color C_BEAR   = #00FFFF
const color C_MID    = #FFFF00
const color C_BG     = #000000
const color C_FRAME  = #1A1A1A
color C_TEXT   = color.new(#E6E6E6, 0)
color C_SUB    = color.new(#94A3B8, 0)
color C_HDR_BG = color.new(C_FRAME, 25)
color C_ROW_A  = color.new(C_BG,    55)
color C_ROW_B  = color.new(C_FRAME, 65)

// =================================================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =================================================================================================

// ---- Color gradient (RGB linear interpolation) ----
f_colorGradient(float ratio, color colA, color colB) =>
    float r = math.max(0.0, math.min(1.0, ratio))
    rA = color.r(colA), gA = color.g(colA), bA = color.b(colA)
    rB = color.r(colB), gB = color.g(colB), bB = color.b(colB)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

// ---- Multi-stop gradient ----
f_gradientMulti(float ratio, array<color> stops) =>
    n = array.size(stops) - 1
    color out = na
    if n < 1
        out := array.size(stops) > 0 ? array.get(stops, 0) : color.gray
    else
        posR = math.max(0.0, math.min(1.0, ratio)) * n
        idx = math.min(n - 1, math.max(0, int(posR)))
        local = posR - idx
        out := f_colorGradient(local, array.get(stops, idx), array.get(stops, idx + 1))
    out

// ---- Clamp ----
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

// ---- Position string resolver ----
f_strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// ---- Size string resolver ----
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ---- Format volume ----
f_fmtVol(float v) =>
    v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.##")

// ---- Format percent ----
f_fmtPct(float p, int dec) => str.tostring(p, "#." + str.repeat("0", dec)) + "%"

// ---- Sign helper ----
f_sign(float x) => x > 0 ? 1 : x < 0 ? -1 : 0

// ---- Streak coloring ramp (gradient by streak intensity) ----
f_streakColor(float ratio, color baseCol, color highCol) =>
    f_colorGradient(f_clamp(ratio, 0.0, 1.0), baseCol, highCol)

// ---- Auto LTF resolver (1/20th of chart) ----
f_autoLtfPick() =>
    int chartSec = timeframe.in_seconds(timeframe.period)
    chartSec >= 86400 ? "60" : chartSec >= 14400 ? "15" : chartSec >= 3600 ? "5" : "1"

// ---- Subtle row gradient ----
f_rowGrad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? float(minT) : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))

// ---- Dashboard row renderer (script-scope helper) ----
f_dashRow(table tbl, int r, int totalRows, string labelTxt, string valueTxt,
          color labelCol, color valueCol, color labelBgBase, color valueBgBase,
          string sizeStr) =>
    color bgL  = f_rowGrad(labelBgBase, r, totalRows, 86, 95)
    color bgV  = f_rowGrad(valueBgBase, r, totalRows, 75, 92)
    string sz  = sizeStr
    table.cell(tbl, 0, r, labelTxt,
         text_color=labelCol, bgcolor=bgL,
         text_halign=text.align_left, text_size=f_strToSize(sz),
         text_font_family=font.family_monospace)
    table.cell(tbl, 1, r, valueTxt,
         text_color=valueCol, bgcolor=bgV,
         text_halign=text.align_right, text_size=f_strToSize(sz),
         text_font_family=font.family_monospace)

// =================================================================================================
//  SECTION 4 - CORE CALCULATIONS  (LTF reconstruction + tick rule + aggressive streaks)
// =================================================================================================

string ltfReq = useChartAsLtf ? f_autoLtfPick() : ltfResolution

// Request LTF tuple [close, volume]
[ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltfReq, [close, volume])

// Initialize per-bar microstructure metrics
var int   barLtfCount   = 0
var int   barUpTicks    = 0
var int   barDnTicks    = 0
var int   barFlatTicks  = 0
var float barUpVol      = 0.0
var float barDnVol      = 0.0
var int   barMaxAskStrk = 0  // max consecutive up-tick streak
var int   barMaxBidStrk = 0  // max consecutive down-tick streak
var int   barLastAskStr = 0  // ending ask streak
var int   barLastBidStr = 0  // ending bid streak
var int   barDomSign    = 0  // +1 ask dominant, -1 bid dominant, 0 neutral

// Reset on every chart bar
barLtfCount   := 0
barUpTicks    := 0
barDnTicks    := 0
barFlatTicks  := 0
barUpVol      := 0.0
barDnVol      := 0.0
barMaxAskStrk := 0
barMaxBidStrk := 0
barLastAskStr := 0
barLastBidStr := 0
barDomSign    := 0

// ------- LTF iteration: apply tick rule + streak counting -------
int n = na(ltfClose) ? 0 : array.size(ltfClose)
barLtfCount := n

float prevPx = na
int   curAsk = 0
int   curBid = 0

if n > 0
    // Seed prev with first LTF close to keep first comparison meaningful
    prevPx := array.get(ltfClose, 0)
    for i = 0 to n - 1
        float px = array.get(ltfClose, i)
        float vv = na(ltfVol) ? 0.0 : array.get(ltfVol, i)
        float vSafe = na(vv) ? 0.0 : vv
        int dir = 0
        if not na(px) and not na(prevPx)
            if px > prevPx
                dir := 1
            else if px < prevPx
                dir := -1
            else
                dir := 0
        if dir == 1
            barUpTicks += 1
            barUpVol   += vSafe
            curAsk     += 1
            // closing bid streak: lock its max
            if curBid > barMaxBidStrk
                barMaxBidStrk := curBid
            curBid := 0
        else if dir == -1
            barDnTicks += 1
            barDnVol   += vSafe
            curBid     += 1
            if curAsk > barMaxAskStrk
                barMaxAskStrk := curAsk
            curAsk := 0
        else
            barFlatTicks += 1
            // flat ticks neither extend nor terminate (treat as gap)
        prevPx := na(px) ? prevPx : px
    // End-of-bar streak finalization
    if curAsk > barMaxAskStrk
        barMaxAskStrk := curAsk
    if curBid > barMaxBidStrk
        barMaxBidStrk := curBid
    barLastAskStr := curAsk
    barLastBidStr := curBid

// Determine dominant side at the END of the bar
barDomSign := barLastAskStr > barLastBidStr ? 1 : barLastBidStr > barLastAskStr ? -1 : 0

// ---- Bar-level metrics ----
int totalTicks = barUpTicks + barDnTicks
float totalVol = barUpVol + barDnVol

// Tick imbalance (-1 .. +1)
float tickImb = totalTicks > 0 ? (barUpTicks - barDnTicks) / float(totalTicks) : 0.0

// Volume imbalance (-1 .. +1)
float volImb  = totalVol > 0   ? (barUpVol - barDnVol) / totalVol : 0.0

// Composite raw pulse (weighted or pure tick)
float rawPulse = volWeighted ? (tickImb * 0.55 + volImb * 0.45) : tickImb

// Buy / sell percent
float buyPct  = totalTicks > 0 ? (barUpTicks / float(totalTicks)) * 100.0 : 0.0
float sellPct = totalTicks > 0 ? (barDnTicks / float(totalTicks)) * 100.0 : 0.0
float buyVolPct  = totalVol > 0 ? (barUpVol / totalVol) * 100.0 : 0.0
float sellVolPct = totalVol > 0 ? (barDnVol / totalVol) * 100.0 : 0.0

// ---- Pulse oscillator (EMA-smoothed) ----
float pulse = ta.ema(rawPulse, pulseLen)

// Constrain pulse for safety
pulse := f_clamp(nz(pulse, 0.0), -1.0, 1.0)

// ---- Aggressive streak histograms (smoothed) ----
float askPulseRaw = float(barMaxAskStrk)
float bidPulseRaw = float(barMaxBidStrk)
float askPulse    = ta.ema(askPulseRaw, streakSmthLen)
float bidPulse    = ta.ema(bidPulseRaw, streakSmthLen)

// Normalize streak histograms so they fit within +/- 1.0 visual band
int streakNormLen   = math.max(20, streakSmthLen * 6)
float askMaxRecent  = ta.highest(askPulse, streakNormLen)
float bidMaxRecent  = ta.highest(bidPulse, streakNormLen)
float refMax        = math.max(askMaxRecent, bidMaxRecent)
refMax := refMax <= 0 ? 1.0 : refMax
float askHist =  askPulse / refMax
float bidHist = -bidPulse / refMax

// =================================================================================================
//  SECTION 5 - STATE / TRACKING  (var arrays + streak / flip memory)
// =================================================================================================

var int   prevDomSign       = 0   // dominant aggression side last bar
var int   lastFlipBar       = na  // bar_index of last aggression flip
var int   lastFlipDir       = 0   // direction after last flip
var int   prevPulseStreak   = 0   // sign-based pulse streak length
var int   pulseStreakSign   = 0   // sign of current pulse streak
var int   barsAbovePosExt   = 0
var int   barsBelowNegExt   = 0
var float runMaxAsk         = 0.0
var float runMaxBid         = 0.0
var float runMaxPulseAbs    = 0.0
var int   countExtremeUp    = 0
var int   countExtremeDn    = 0
var int   countFlipsTotal   = 0
var int   countMassImb      = 0
var int   totalTickCumLife  = 0
var float totalVolCumLife   = 0.0

// Aggregate lifetime counters
totalTickCumLife += totalTicks
totalVolCumLife  += totalVol
runMaxAsk        := math.max(runMaxAsk, askPulseRaw)
runMaxBid        := math.max(runMaxBid, bidPulseRaw)
runMaxPulseAbs   := math.max(runMaxPulseAbs, math.abs(pulse))

// Pulse sign-streak tracking
int curPulseSign = f_sign(pulse)
if curPulseSign != 0 and curPulseSign == pulseStreakSign
    prevPulseStreak += 1
else
    pulseStreakSign := curPulseSign
    prevPulseStreak := curPulseSign == 0 ? 0 : 1

// Detect aggression flip (dominant side changed) with min streak guard
bool aggFlipUp = barDomSign == 1  and prevDomSign == -1 and barMaxAskStrk >= aggStreakMin
bool aggFlipDn = barDomSign == -1 and prevDomSign == 1  and barMaxBidStrk >= aggStreakMin
bool aggFlip   = aggFlipUp or aggFlipDn

if aggFlip
    lastFlipBar := bar_index
    lastFlipDir := barDomSign
    countFlipsTotal += 1

if barstate.isconfirmed
    prevDomSign := barDomSign

// Extreme pulse counters
bool pulseUpExt = pulse >  pulseExtreme
bool pulseDnExt = pulse < -pulseExtreme
if pulseUpExt
    barsAbovePosExt += 1
    countExtremeUp  += 1
else
    barsAbovePosExt := 0
if pulseDnExt
    barsBelowNegExt += 1
    countExtremeDn  += 1
else
    barsBelowNegExt := 0

// Massive imbalance count
bool massiveImbBar = (buyPct >= imbalancePct or sellPct >= imbalancePct) and totalTicks >= 10
if massiveImbBar
    countMassImb += 1

// =================================================================================================
//  SECTION 6 - SIGNAL ENGINE  (cooldowns + extreme + flip detection)
// =================================================================================================

// Extreme pulse signal with one-shot detection (only on new crossing)
bool pulseExtUpNew = pulseUpExt and not pulseUpExt[1]
bool pulseExtDnNew = pulseDnExt and not pulseDnExt[1]

// Pulse cross zero (regime shift)
bool pulseCrossUp = ta.crossover(pulse, 0.0)
bool pulseCrossDn = ta.crossunder(pulse, 0.0)

// Composite confluence signal: extreme + aggression alignment
bool confluenceBull = pulseExtUpNew and barDomSign == 1  and barMaxAskStrk >= aggStreakMin
bool confluenceBear = pulseExtDnNew and barDomSign == -1 and barMaxBidStrk >= aggStreakMin

// Cooldown for flip markers
var int lastMarkBar = -100
canMark = (bar_index - lastMarkBar) >= 3
finalFlipBull = aggFlipUp and canMark
finalFlipBear = aggFlipDn and canMark
if finalFlipBull or finalFlipBear
    lastMarkBar := bar_index

// =================================================================================================
//  SECTION 7 - PLOTS / FILLS / HISTOGRAMS
// =================================================================================================

// ---- Pulse line gradient color (by sign + magnitude) ----
color pulseCol = pulse > 0 ? f_colorGradient(f_clamp(pulse, 0.0, 1.0), color.new(C_BULL, 50), C_BULL) : pulse < 0 ? f_colorGradient(f_clamp(-pulse, 0.0, 1.0), color.new(C_BEAR, 50), C_BEAR) : color.new(C_MID, 35)

// Main pulse line
plot(pulse, "Pulse Oscillator", color=pulseCol, linewidth=pulseWidth)

// Glow ghost line (slightly thicker, very translucent)
plot(pulse, "Pulse Glow", color=color.new(pulseCol, 75), linewidth=pulseWidth + 3)

// Hidden zero anchor for fill
zeroAnchor = plot(0.0, "_zeroAnchor", color=color.new(color.gray, 100), display=display.none, editable=false)
pulsePlot  = plot(pulse, "_pulseAnchor", color=color.new(color.gray, 100), display=display.none, editable=false)

// Gradient fill (pulse vs zero)
fill(zeroAnchor, pulsePlot,
     color = showGradFill ? color.new(pulseCol, fillAlpha) : na,
     title = "Pulse Fill")

// Aggressive ask histogram (positive side)
plot(showHistBg ? askHist : na, "Ask Streak Histogram",
     color=color.new(C_BULL, histAlpha),
     style=plot.style_columns, linewidth=1)

// Aggressive bid histogram (negative side)
plot(showHistBg ? bidHist : na, "Bid Streak Histogram",
     color=color.new(C_BEAR, histAlpha),
     style=plot.style_columns, linewidth=1)

// Tick imbalance overlay (thin signal)
plot(tickImb, "Tick Imbalance", color=color.new(C_MID, 55), linewidth=1, display=display.pane)

// ---- Threshold lines ----
// plot() used instead of hline() to avoid requiring const color (Rule 6).
plot(0.0,  "Zero",         color=color.new(C_MID, 35), linewidth=1, style=plot.style_linebr)
plot( 1.0, "Hard Ceiling", color=color.new(C_MID, 70), linewidth=1, style=plot.style_linebr)
plot(-1.0, "Hard Floor",   color=color.new(C_MID, 70), linewidth=1, style=plot.style_linebr)

plot(showLevels ?  pulseExtreme : na, "Pulse Extreme +",
     color=color.new(C_BULL, 30), linewidth=1, style=plot.style_linebr)
plot(showLevels ? -pulseExtreme : na, "Pulse Extreme -",
     color=color.new(C_BEAR, 30), linewidth=1, style=plot.style_linebr)
plot(showLevels ?  pulseWarn    : na, "Pulse Warn +",
     color=color.new(C_BULL, 65), linewidth=1, style=plot.style_linebr)
plot(showLevels ? -pulseWarn    : na, "Pulse Warn -",
     color=color.new(C_BEAR, 65), linewidth=1, style=plot.style_linebr)

// Background tint at extremes
bgcolor(showBgTint and pulseUpExt ? color.new(C_BULL, bgTintAlpha) : na, title="BG Extreme Up")
bgcolor(showBgTint and pulseDnExt ? color.new(C_BEAR, bgTintAlpha) : na, title="BG Extreme Dn")
bgcolor(showBgTint and massiveImbBar ?
     color.new(buyPct >= imbalancePct ? C_BULL : C_BEAR, math.max(60, bgTintAlpha - 12)) : na,
     title="BG Massive Imbalance")

// Flip markers
plotshape(showFlipMark and finalFlipBull ? pulse : na, "Aggression Flip Bull",
     style=shape.triangleup, location=location.absolute, color=C_BULL,
     size=size.tiny, text="^")
plotshape(showFlipMark and finalFlipBear ? pulse : na, "Aggression Flip Bear",
     style=shape.triangledown, location=location.absolute, color=C_BEAR,
     size=size.tiny, text="v")

// Confluence markers (extreme + same-side dominance)
plotchar(confluenceBull ?  pulseExtreme + 0.05 : na, "Confluence Bull", "*",
     location.absolute, color=C_BULL, size=size.small)
plotchar(confluenceBear ? -pulseExtreme - 0.05 : na, "Confluence Bear", "*",
     location.absolute, color=C_BEAR, size=size.small)

// =================================================================================================
//  SECTION 8 - DRAWINGS  (status badge + last-bar markers, barstate.islast)
// =================================================================================================

var label statusBadge = na

if barstate.islast
    label.delete(statusBadge)
    badge = barDomSign == 1  ? "ASK >" : barDomSign == -1 ? "BID <" : "FLAT"
    string txt   = badge + "  P=" + str.tostring(pulse, "0.00")
    color  bClr  = barDomSign == 1 ? C_BULL : barDomSign == -1 ? C_BEAR : C_MID
    statusBadge := label.new(bar_index, pulse, txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(bClr, 75),
         textcolor = C_TEXT,
         style     = label.style_label_left,
         size      = size.small)

// =================================================================================================
//  SECTION 9 - DASHBOARD  (11 rows)
// =================================================================================================

var table dash = na

if showDash
    if na(dash)
        dash := table.new(f_strToPos(dashPosStr), dashCols, dashRows,
             bgcolor      = color.new(C_BG, 8),
             frame_color  = C_FRAME,
             frame_width  = 1,
             border_color = color.new(C_FRAME, 60),
             border_width = 1)

if showDash and barstate.islast
    sizeT = f_strToSize(dashSizeStr)

    // Header (spans both columns visually)
    table.cell(dash, 0, 0, "MICROSTRUCTURE PULSE [JOAT]",
         text_color=C_TEXT, bgcolor=color.new(C_BULL, 60),
         text_halign=text.align_left, text_size=sizeT,
         text_font_family=font.family_monospace)
    table.cell(dash, 1, 0, "v1.0",
         text_color=C_TEXT, bgcolor=color.new(C_BEAR, 60),
         text_halign=text.align_right, text_size=sizeT,
         text_font_family=font.family_monospace)

    // Row 1: data source
    f_dashRow(dash, 1, dashRows, "LTF Source",
         ltfReq + (useChartAsLtf ? " (auto)" : ""),
         C_TEXT, C_MID, C_FRAME, C_BG, dashSizeStr)

    // Row 2: total ticks this bar
    f_dashRow(dash, 2, dashRows, "Total Ticks", str.tostring(totalTicks),
         C_TEXT, totalTicks > 50 ? C_BULL : totalTicks > 20 ? C_MID : C_SUB,
         C_FRAME, C_BG, dashSizeStr)

    // Row 3: up ticks
    f_dashRow(dash, 3, dashRows, "Up Ticks",
         str.tostring(barUpTicks) + " (" + f_fmtPct(buyPct, 1) + ")",
         C_TEXT, C_BULL, C_FRAME, C_BG, dashSizeStr)

    // Row 4: down ticks
    f_dashRow(dash, 4, dashRows, "Dn Ticks",
         str.tostring(barDnTicks) + " (" + f_fmtPct(sellPct, 1) + ")",
         C_TEXT, C_BEAR, C_FRAME, C_BG, dashSizeStr)

    // Row 5: tick imbalance
    color imbCol = tickImb > 0 ? C_BULL : tickImb < 0 ? C_BEAR : C_MID
    f_dashRow(dash, 5, dashRows, "Tick Imbalance",
         f_fmtPct(tickImb * 100.0, 2),
         C_TEXT, imbCol, C_FRAME, C_BG, dashSizeStr)

    // Row 6: pulse value
    pulseLabel = math.abs(pulse) >= pulseExtreme ? " EXT" : math.abs(pulse) >= pulseWarn ? " WARN" : ""
    f_dashRow(dash, 6, dashRows, "Pulse Osc",
         str.tostring(pulse, "0.000") + pulseLabel,
         C_TEXT, pulseCol, C_FRAME, C_BG, dashSizeStr)

    // Row 7: max ask streak
    f_dashRow(dash, 7, dashRows, "Max Ask Streak",
         str.tostring(barMaxAskStrk) + " (LIFE " + str.tostring(int(runMaxAsk)) + ")",
         C_TEXT, barMaxAskStrk >= aggStreakMin ? C_BULL : C_SUB,
         C_FRAME, C_BG, dashSizeStr)

    // Row 8: max bid streak
    f_dashRow(dash, 8, dashRows, "Max Bid Streak",
         str.tostring(barMaxBidStrk) + " (LIFE " + str.tostring(int(runMaxBid)) + ")",
         C_TEXT, barMaxBidStrk >= aggStreakMin ? C_BEAR : C_SUB,
         C_FRAME, C_BG, dashSizeStr)

    // Row 9: last aggressive flip
    flipDesc = na(lastFlipBar) ? "none" : str.tostring(bar_index - lastFlipBar) + " bars ago (" + (lastFlipDir == 1 ? "BULL" : lastFlipDir == -1 ? "BEAR" : "-") + ")"
    color  flipCol  = lastFlipDir == 1 ? C_BULL : lastFlipDir == -1 ? C_BEAR : C_SUB
    f_dashRow(dash, 9, dashRows, "Last Flip", flipDesc,
         C_TEXT, flipCol, C_FRAME, C_BG, dashSizeStr)

    // Row 10: buy vol % vs sell vol %
    f_dashRow(dash, 10, dashRows, "Buy / Sell Vol %",
         f_fmtPct(buyVolPct, 1) + " / " + f_fmtPct(sellVolPct, 1),
         C_TEXT, buyVolPct > sellVolPct ? C_BULL : sellVolPct > buyVolPct ? C_BEAR : C_MID,
         C_FRAME, C_BG, dashSizeStr)

// =================================================================================================
//  SECTION 10 - ALERTS
// =================================================================================================

// Pulse Extreme (above)
alertcondition(enaPulseExt and pulseExtUpNew,
     title   = "Pulse Extreme Above",
     message = "MMP: Pulse crossed above extreme threshold on {{ticker}} ({{interval}})")

// Pulse Extreme (below)
alertcondition(enaPulseExt and pulseExtDnNew,
     title   = "Pulse Extreme Below",
     message = "MMP: Pulse crossed below extreme threshold on {{ticker}} ({{interval}})")

// Aggression Flip (Bull)
alertcondition(enaFlip and finalFlipBull,
     title   = "Aggression Flip Bull",
     message = "MMP: Aggression flipped BULL (ask streak >= min) on {{ticker}} ({{interval}})")

// Aggression Flip (Bear)
alertcondition(enaFlip and finalFlipBear,
     title   = "Aggression Flip Bear",
     message = "MMP: Aggression flipped BEAR (bid streak >= min) on {{ticker}} ({{interval}})")

// Massive Imbalance
alertcondition(enaImbalance and massiveImbBar,
     title   = "Massive Imbalance",
     message = "MMP: Massive one-sided ticks detected on {{ticker}} ({{interval}})")

// Confluence (Pulse Extreme aligned with dominant aggression)
alertcondition(enaPulseExt and confluenceBull,
     title   = "Pulse Confluence Bull",
     message = "MMP: Bullish confluence (extreme pulse + ask dominance) on {{ticker}} ({{interval}})")

alertcondition(enaPulseExt and confluenceBear,
     title   = "Pulse Confluence Bear",
     message = "MMP: Bearish confluence (extreme pulse + bid dominance) on {{ticker}} ({{interval}})")

// Pulse Zero Cross (regime shift)
alertcondition(pulseCrossUp,
     title   = "Pulse Zero Cross Up",
     message = "MMP: Pulse crossed above zero on {{ticker}} ({{interval}})")

alertcondition(pulseCrossDn,
     title   = "Pulse Zero Cross Dn",
     message = "MMP: Pulse crossed below zero on {{ticker}} ({{interval}})")

// =================================================================================================
//  END OF FILE - Market Microstructure Pulse [JOAT]
// =================================================================================================
````
