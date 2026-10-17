# Crucible Range Compression [JOAT]

- url: https://www.tradingview.com/script/w6BunZ3T-Crucible-Range-Compression-JOAT/
- type: indicator
- pine_id: PUB;76fe340149854cf2a01f3728ffe997ec
- version: 1.0

## Description

[b]Crucible Range Compression [JOAT][/b]

Crucible Range Compression detects volatility-compression episodes by blending three independent contraction proxies — Bollinger Band Width percentile, ATR percentile, and body-range Z-score — into a single intensity score. While compressed, the script tracks Cumulative Volume Delta inside the compression window to predict breakout direction. On confirmed compression exit it projects a chamber-width target line. A history strip records each completed compression with its outcome.

[image]https://www.tradingview.com/x/qIJqtH45/[/image]

[b]What makes it different[/b]
[list]
[*] Single-metric volatility-contraction indicators (BBW or ATR alone) can be misled by price-level changes. The composite intensity uses three normalized metrics, each over a percentile lookback, so contraction across multiple lenses is required for a true compression read.
[*] The compression chamber is drawn as a dynamic box (top and bottom bounds expanding while the compression remains active) with three nested concentric rings that visually tighten as intensity increases. A clear visual countdown to breakout.
[*] Inside the chamber, CVD slope predicts breakout direction before the breakout occurs. A direction-bias gauge surfaces this prediction in a 21-segment vertical scale.
[*] Two forward projection lines appear AFTER compression exits but BEFORE the breakout candle confirms — bull target at chamber-high plus width, bear target at chamber-low minus width. Once the direction confirms, only the active target survives.
[*] A false-breakout signal fires when price breaks in the opposite direction of CVD's bias. A high-value warning that a fast reversal is likely.
[/list]

[b]How it works[/b]
[list=1]
[*] Bollinger Band Width equals (upper minus lower) divided by basis. Convert to percentile rank over a 100-bar lookback.
[*] ATR(14) percentile rank over the same lookback.
[*] Body range equals the absolute distance between close and open. Body Z equals (body minus sma(body, 20)) divided by stdev(body, 20). Map to a 0-1 score where small bodies equal 1.
[*] Intensity equals 0.40 times (1 minus BBW%) plus 0.40 times (1 minus ATR%) plus 0.20 times body score. Range 0 to 1 where 1 equals maximum compression.
[*] Compression active when intensity exceeds the user threshold (default 0.7). Chamber bounds are the running max / min of high / low while active.
[*] CVD inside the chamber: delta equals plus volume on up bars, minus volume on down bars, zero otherwise, summed since chamber start. Slope equals total delta divided by bars in chamber.
[*] On exit (intensity drops below threshold), if close above chamber high and CVD bias above 0, bull breakout. If close below chamber low and CVD bias below 0, bear breakout. If price breaks one way but CVD predicted the other, false-breakout signal.
[*] Target on confirmed direction equals breakout close plus or minus chamber width.
[/list]

[b]Reading the chart[/b]
[list]
[*] Outer compression chamber box, transparency-modulated by intensity, anchored at compression start.
[*] Three nested concentric rings inside the chamber, smaller and smaller, tinted by direction bias.
[*] Iridescent candle recolor scales transparency with intensity (faded while compressed, vivid on expansion).
[*] Forward projection lines (bull target and bear target) appear at compression exit and disappear when one direction confirms.
[*] A confirmed target line plus price label persists until hit or expired.
[*] bgcolor pulses: 3-bar fade on compression entry, 2-bar fade on confirmed breakout (bull / bear).
[*] Chamber exit pulse: border alpha cycles for 3 bars when compression exits.
[*] A right-edge intensity gauge label with intensity %, state, bias, bars in.
[*] A right-side 21-segment direction-bias gauge mirroring CVD slope.
[*] Pre-compression bgcolor highlight when intensity is approaching the threshold.
[*] An intensity history mini-strip on the right edge showing the last 10 intensity values as colored line segments.
[*] A compression history strip (last 10 completed compressions with outcomes).
[*] A daily compression counter.
[/list]

[b]Signals[/b]
[list]
[*] Compression entry (intensity crosses above threshold)
[*] Compression exit (intensity drops below threshold, breakout pending)
[*] Bull breakout confirmed
[*] Bear breakout confirmed
[*] False breakout (direction mismatch with CVD bias)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references.

[b]Inputs[/b]
[list]
[*] [b]Compression[/b]: BB length, BB stdev multiplier, percentile lookback, activation threshold, chamber initial length, target line extension bars.
[*] [b]Visual[/b]: bullish, bearish, neutral colors. Chamber, nested rings, candles, target line, pulses, gauge toggles.
[*] [b]On-chart[/b]: compression history, intensity strip, pre-compression highlight, bias gauge, projection lines, target hit/miss labels, false-breakout revert line, state block, cycle counter, exit pulse.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Breakout entries[/b]: wait for the confirmed bull / bear breakout signal AND the CVD-bias gauge to be aligned. False-breakout signals when these disagree are reasons to pass or fade.
[*] [b]Range trading[/b]: while compression is active (chamber visible), reactions to chamber high / low are intra-range scalp setups.
[*] [b]Target management[/b]: once the breakout fires and the target line appears, common practice is to scale out at chamber-mid first, then chamber-target. The chamber width is the implied move.
[*] [b]Compression history[/b]: see how previous compressions resolved on the current instrument. A series of Win entries means the setup has been productive recently.
[/list]

[b]Limitations[/b]
[list]
[*] Compression detection requires warm-up history (100 bars for the percentile calculations). On very young charts the script is inert.
[*] CVD bias inside a chamber is a probability, not a guarantee. False breakouts happen when liquidity sweeps stops on the predicted side first.
[*] For instruments with very thin volume data, the CVD direction signal is less reliable.
[*] The chamber width is a measured-move proxy. Actual move size can exceed or fall short.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (overlay). Any symbol, any timeframe (more bars equals more reliable percentile context). No request.security calls.

[b]Defaults[/b]
20-bar BB, 2.0 BB stdev, 100-bar percentile lookback, 0.7 activation threshold, 20-bar initial chamber length, 40-bar target extension, mint / red / gray palette, top-right medium dashboard.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// ════════════════════════════════════════════════════════════════════
//   JOAT — Crucible Range Compression [JOAT]
//   Detects compound volatility compression (BBW + ATR + body-Z) and
//   predicts breakout direction via signed-volume slope during squeeze.
// ════════════════════════════════════════════════════════════════════

indicator("Crucible Range Compression [JOAT]", "CRC [JOAT]",
     overlay              = true,
     explicit_plot_zorder = true,
     max_lines_count      = 500,
     max_labels_count     = 500,
     max_boxes_count      = 500,
     behind_chart         = false)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_cmp  = "Compression"
g_vis  = "Visual"
g_hud  = "HUD / Telemetry"
g_dash = "Dashboard"

bbLen        = input.int(20,    "Bollinger Length",                  minval=5,                           group=g_cmp,
     tooltip="SMA and stdev length for Bollinger Band Width. The same window feeds the BBW percentile rank.")

bbStdMult    = input.float(2.0, "Bollinger Standard Dev Multiplier", minval=0.5, maxval=4.0, step=0.1,   group=g_cmp,
     tooltip="Standard-deviation multiplier for Bollinger bands. Wider settings smooth the BBW signal; tighter settings make compression bursts more frequent.")

pctLookback  = input.int(100,   "Percentile Lookback",               minval=20,  maxval=500,             group=g_cmp,
     tooltip="Lookback window for the BBW and ATR percentile ranks. Larger windows expose true regime compression; smaller windows react to local quiet pockets.")

activeThresh = input.float(0.7, "Activation Threshold (Intensity)",  minval=0.3, maxval=0.95, step=0.05, group=g_cmp,
     tooltip="Composite intensity (0..1) required to enter the compression state. Higher thresholds yield fewer, higher-conviction setups.")

chamberLen   = input.int(20,    "Chamber Initial Range Length",      minval=5,                           group=g_cmp,
     tooltip="Bars used to seed the compression chamber high/low at the moment compression activates. The chamber then expands to enclose any subsequent extreme during the squeeze.")

extendBars   = input.int(40,    "Target Line Extension Bars",        minval=10,                          group=g_cmp,
     tooltip="Number of bars the post-breakout target line extends to the right.")

bullColor    = input.color(#00ffbb, "Bullish",        inline="cBull",                                    group=g_vis,
     tooltip="Primary bullish color — JOAT brand mint.")
bearColor    = input.color(#ff1100, "Bearish",        inline="cBull",                                    group=g_vis,
     tooltip="Primary bearish color — JOAT brand red.")
neutralColor = input.color(#9090b0, "Neutral / Chamber Color", inline="cNeutral",                        group=g_vis,
     tooltip="Neutral color used for the compression chamber when direction bias is undecided.")

showChamber  = input.bool(true, "Show Compression Chamber",                                              group=g_vis,
     tooltip="Toggle the outer compression chamber rectangle.")
showNested   = input.bool(true, "Show Nested Tightening Rings",                                          group=g_vis,
     tooltip="Toggle the three nested inner rings that visualize tightening intensity.")
showCandles  = input.bool(true, "Iridescent Candles by Compression",                                     group=g_vis,
     tooltip="Toggle iridescent candle recolor where saturation collapses inside the squeeze and blooms back into the directional color on breakout.")
showTarget   = input.bool(true, "Show Breakout Target Line",                                             group=g_vis,
     tooltip="Toggle the projected target line drawn on confirmed bullish or bearish breakout.")
showPulse    = input.bool(true, "Show Background Pulses",                                                group=g_vis,
     tooltip="Toggle neutral pulse on compression entry and directional pulse on breakout.")
showGauge    = input.bool(true, "Show Intensity Gauge Label",                                            group=g_vis,
     tooltip="Toggle the right-edge intensity readout label.")

showHistory       = input.bool(true, "Show Compression History Labels",                                  group=g_hud,
     tooltip="Plot a small label above each completed compression chamber summarizing duration, direction, and target outcome. Capped at 10 FIFO.")
showIntensityStrip = input.bool(true, "Show Intensity History Mini-Strip",                              group=g_hud,
     tooltip="Right-edge stacked horizontal bars showing the last 10 intensity readings. Brighter segments mark deeper compression. Rebuilt each bar.")
showPreCompress   = input.bool(true, "Show Pre-Compression Highlight",                                   group=g_hud,
     tooltip="Faint background tint on bars where intensity is climbing toward the activation threshold (compression building state).")
showBiasGauge     = input.bool(true, "Show Direction Bias Gauge",                                        group=g_hud,
     tooltip="Replace the text bias readout with a 21-segment vertical color band whose pointer position reflects normalized CVD slope.")
showProjections   = input.bool(true, "Show Compression Exit Projection Lines",                          group=g_hud,
     tooltip="Faint bull and bear target projection lines drawn the instant compression exits, before a confirmed breakout. The losing projection is removed once breakout direction is confirmed.")
showTargetHistory = input.bool(true, "Show Target Hit / Miss Labels",                                    group=g_hud,
     tooltip="Drop a small persistent label when the active breakout target is reached or expires. Capped at 15 FIFO.")
showRevertLine    = input.bool(true, "Show False-Breakout Reversion Line",                              group=g_hud,
     tooltip="Plot a horizontal mean-revert line at the chamber midpoint when a false breakout is detected. Cleared on the next compression event.")
showStateBlock    = input.bool(true, "Show Right-Edge State Block",                                      group=g_hud,
     tooltip="Stack 4 persistent labels at the right edge showing intensity, state, bias, and bars in compression / target.")
showCycleCounter  = input.bool(true, "Show Compression Cycle Counter",                                   group=g_hud,
     tooltip="Persistent right-edge label tallying today's compression cycles with win / loss split (resets at session change).")
showExitPulse     = input.bool(true, "Show Chamber Exit Pulse",                                          group=g_hud,
     tooltip="Pulse the chamber border alpha for 3 bars after compression exits to telegraph an imminent breakout.")

showDash     = input.bool(true, "Show Dashboard",                                                        group=g_dash,
     tooltip="Toggle the institutional dashboard panel.")
dashPos      = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize     = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

alphaForVal(float v, int lo, int hi) =>
    float clamped = math.max(0.0, math.min(1.0, v))
    int   span    = hi - lo
    math.round(lo + (1.0 - clamped) * span)

sumSinceBar(float cumSeries, float anchorVal) =>
    cumSeries - anchorVal

clamp01(float v) =>
    math.max(0.0, math.min(1.0, v))

trimLabelArr(array<label> arr, int cap) =>
    while array.size(arr) > cap
        label old = array.shift(arr)
        if not na(old)
            label.delete(old)

trimLineArr(array<line> arr, int cap) =>
    while array.size(arr) > cap
        line old = array.shift(arr)
        if not na(old)
            line.delete(old)

// ════════════════════════════════════════════════════════════════════
// CORE — Compression Math
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

bb_basis = ta.sma(close, bbLen)
bb_dev   = bbStdMult * ta.stdev(close, bbLen)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
bbw      = (bb_upper - bb_lower) / math.max(bb_basis, syminfo.mintick)
bbw_pct  = ta.percentrank(bbw, pctLookback)

atr14   = ta.atr(14)
atr_pct = ta.percentrank(atr14, pctLookback)

body_len   = math.abs(close - open)
body_mean  = ta.sma(body_len, 20)
body_std   = ta.stdev(body_len, 20)
body_z     = body_std > 0 ? (body_len - body_mean) / body_std : 0.0
body_score = clamp01(1.0 - (body_z + 2.0) / 4.0)

bbw_score = 1.0 - bbw_pct / 100.0
atr_score = 1.0 - atr_pct / 100.0
intensity = 0.4 * bbw_score + 0.4 * atr_score + 0.2 * body_score

cvd_step = close > open ? volume : close < open ? -volume : 0.0
var float cvd_cum = 0.0
cvd_cum := cvd_cum + cvd_step

// ════════════════════════════════════════════════════════════════════
// CORE — State Machine + Chamber + Direction Bias
// ════════════════════════════════════════════════════════════════════
var bool   compressionActive  = false
var bool   compressionFire    = false
var bool   compressionExit    = false
var int    compressionStartBar = na
var int    barsInCompression   = 0
var int    lastCompressionBars = 0
var float  chamber_high        = na
var float  chamber_low         = na
var float  chamber_high_locked = na
var float  chamber_low_locked  = na
var float  cvd_anchor          = na
var float  cvd_slope           = 0.0
var int    direction_bias      = 0
var int    locked_dir_bias     = 0
var float  cvd_slope_absmax    = 1.0

compressionFire := false
compressionExit := false

bool prevActive = compressionActive
bool newActive  = intensity > activeThresh

float chamberInitHigh = ta.highest(high, chamberLen)
float chamberInitLow  = ta.lowest(low,  chamberLen)

if confirmedBar
    if newActive and not prevActive
        compressionActive   := true
        compressionFire     := true
        compressionStartBar := bar_index
        barsInCompression   := 1
        chamber_high        := chamberInitHigh
        chamber_low         := chamberInitLow
        cvd_anchor          := cvd_cum
        cvd_slope           := 0.0
        direction_bias      := 0
    else if newActive and prevActive
        compressionActive := true
        barsInCompression := barsInCompression + 1
        chamber_high      := math.max(chamber_high, high)
        chamber_low       := math.min(chamber_low,  low)
        float cvd_window = sumSinceBar(cvd_cum, cvd_anchor)
        cvd_slope        := cvd_window / math.max(barsInCompression, 1)
        direction_bias   := cvd_slope > 0 ? 1 : cvd_slope < 0 ? -1 : 0
        cvd_slope_absmax := math.max(cvd_slope_absmax, math.abs(cvd_slope))
    else if not newActive and prevActive
        compressionActive   := false
        compressionExit     := true
        chamber_high_locked := chamber_high
        chamber_low_locked  := chamber_low
        locked_dir_bias     := direction_bias
        lastCompressionBars := barsInCompression
    else
        compressionActive := false

// ════════════════════════════════════════════════════════════════════
// CORE — Breakout Classification + Target Projection
// ════════════════════════════════════════════════════════════════════
bool bullBreakout  = compressionExit and locked_dir_bias ==  1 and close > chamber_high_locked and confirmedBar
bool bearBreakout  = compressionExit and locked_dir_bias == -1 and close < chamber_low_locked  and confirmedBar
bool falseBreakout = compressionExit and ((close > chamber_high_locked and locked_dir_bias == -1) or (close < chamber_low_locked and locked_dir_bias ==  1))

var float chamberRange = na
chamberRange := na(chamber_high_locked) or na(chamber_low_locked) ? na : chamber_high_locked - chamber_low_locked

var float targetPrice = na
if bullBreakout
    targetPrice := close + chamberRange
if bearBreakout
    targetPrice := close - chamberRange

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
bool sigCompressionFire = compressionFire and confirmedBar
bool sigCompressionExit = compressionExit and confirmedBar
bool sigBull            = bullBreakout
bool sigBear            = bearBreakout
bool sigFalse           = falseBreakout and confirmedBar

// ════════════════════════════════════════════════════════════════════
// VISUALS — Compression Chamber Box
// ════════════════════════════════════════════════════════════════════
var box chamberBox  = na
var box ringBox1    = na
var box ringBox2    = na
var box ringBox3    = na
var int exitPulse   = 0

color borderCol = direction_bias == 1 ? bullColor : direction_bias == -1 ? bearColor : chart.fg_color

int   chamberAlpha = alphaForVal(intensity, 70, 92)
color chamberFill  = color.new(neutralColor, chamberAlpha)
int   borderAlpha  = 50
if showExitPulse and exitPulse > 0
    borderAlpha := exitPulse == 3 ? 30 : exitPulse == 2 ? 60 : 30
color chamberBord  = color.new(borderCol, borderAlpha)

if showChamber and confirmedBar
    if compressionFire
        if not na(chamberBox)
            box.delete(chamberBox)
        chamberBox := box.new(left   = compressionStartBar,
                              top    = chamber_high,
                              right  = bar_index,
                              bottom = chamber_low,
                              border_color = chamberBord,
                              border_width = 1,
                              bgcolor      = chamberFill,
                              extend       = extend.none)
    else if compressionActive and not na(chamberBox)
        box.set_right(chamberBox, bar_index)
        box.set_top(chamberBox,   chamber_high)
        box.set_bottom(chamberBox,chamber_low)
        box.set_border_color(chamberBox, chamberBord)
        box.set_bgcolor(chamberBox,      chamberFill)
    else if exitPulse > 0 and not na(chamberBox)
        box.set_border_color(chamberBox, chamberBord)

if confirmedBar
    if compressionExit
        exitPulse := 3
    else if exitPulse > 0
        exitPulse := exitPulse - 1

// ════════════════════════════════════════════════════════════════════
// VISUALS — Nested Tightening Rings
// ════════════════════════════════════════════════════════════════════
if showNested and showChamber and confirmedBar
    if compressionFire
        if not na(ringBox1)
            box.delete(ringBox1)
        if not na(ringBox2)
            box.delete(ringBox2)
        if not na(ringBox3)
            box.delete(ringBox3)
        float r1 = 0.75 * (1.0 - 0.25 * intensity)
        float r2 = 0.50 * (1.0 - 0.35 * intensity)
        float r3 = 0.25 * (1.0 - 0.50 * intensity)
        float mid = (chamber_high + chamber_low) / 2.0
        float half = (chamber_high - chamber_low) / 2.0
        ringBox1 := box.new(compressionStartBar, mid + half * r1, bar_index, mid - half * r1,
             border_color = color.new(neutralColor, 60), border_width = 1,
             bgcolor      = color.new(neutralColor, alphaForVal(intensity, 70, 90)), extend = extend.none)
        ringBox2 := box.new(compressionStartBar, mid + half * r2, bar_index, mid - half * r2,
             border_color = color.new(neutralColor, 55), border_width = 1,
             bgcolor      = color.new(neutralColor, alphaForVal(intensity, 65, 88)), extend = extend.none)
        ringBox3 := box.new(compressionStartBar, mid + half * r3, bar_index, mid - half * r3,
             border_color = color.new(borderCol,    50), border_width = 1,
             bgcolor      = color.new(borderCol,    alphaForVal(intensity, 60, 85)), extend = extend.none)
    else if compressionActive and not na(ringBox1)
        float r1 = 0.75 * (1.0 - 0.25 * intensity)
        float r2 = 0.50 * (1.0 - 0.35 * intensity)
        float r3 = 0.25 * (1.0 - 0.50 * intensity)
        float mid = (chamber_high + chamber_low) / 2.0
        float half = (chamber_high - chamber_low) / 2.0
        box.set_left(ringBox1,         compressionStartBar)
        box.set_right(ringBox1,        bar_index)
        box.set_top(ringBox1,          mid + half * r1)
        box.set_bottom(ringBox1,       mid - half * r1)
        box.set_bgcolor(ringBox1,      color.new(neutralColor, alphaForVal(intensity, 70, 90)))
        box.set_border_color(ringBox1, color.new(neutralColor, 60))
        box.set_left(ringBox2,         compressionStartBar)
        box.set_right(ringBox2,        bar_index)
        box.set_top(ringBox2,          mid + half * r2)
        box.set_bottom(ringBox2,       mid - half * r2)
        box.set_bgcolor(ringBox2,      color.new(neutralColor, alphaForVal(intensity, 65, 88)))
        box.set_border_color(ringBox2, color.new(neutralColor, 55))
        box.set_left(ringBox3,         compressionStartBar)
        box.set_right(ringBox3,        bar_index)
        box.set_top(ringBox3,          mid + half * r3)
        box.set_bottom(ringBox3,       mid - half * r3)
        box.set_bgcolor(ringBox3,      color.new(borderCol, alphaForVal(intensity, 60, 85)))
        box.set_border_color(ringBox3, color.new(borderCol, 50))
    else if compressionExit
        if not na(ringBox1)
            box.delete(ringBox1)
            ringBox1 := na
        if not na(ringBox2)
            box.delete(ringBox2)
            ringBox2 := na
        if not na(ringBox3)
            box.delete(ringBox3)
            ringBox3 := na

// ════════════════════════════════════════════════════════════════════
// VISUALS — Iridescent Candle Recolor
// ════════════════════════════════════════════════════════════════════
color baseGrad   = color.from_gradient(intensity, 0.0, 1.0, chart.fg_color, neutralColor)
color dirColor   = direction_bias == 1 ? bullColor : direction_bias == -1 ? bearColor : neutralColor
color candleColor = compressionActive ? color.from_gradient(intensity, 0.0, 1.0, baseGrad, dirColor) : (close >= open ? bullColor : bearColor)

color borderCandle = compressionActive ? color.new(candleColor, 20) : candleColor
color wickCandle   = compressionActive ? color.new(candleColor, 35) : color.new(candleColor, 10)

plotcandle(showCandles ? open  : na,
           showCandles ? high  : na,
           showCandles ? low   : na,
           showCandles ? close : na,
           title       = "Iridescent",
           color       = candleColor,
           wickcolor   = wickCandle,
           bordercolor = borderCandle)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Pre-Compression Highlight (compression building)
// ════════════════════════════════════════════════════════════════════
bool preCompress = confirmedBar and intensity > 0.5 and intensity < activeThresh and not compressionActive
color preCompressTint = (showPreCompress and preCompress) ? color.new(bullColor, 96) : na
bgcolor(preCompressTint, title="CRC Pre-Compression")

// ════════════════════════════════════════════════════════════════════
// VISUALS — Breakout Target Line + Label
// ════════════════════════════════════════════════════════════════════
var line  targetLine = na
var label targetLbl  = na
var int   targetSetBar = na
var bool  targetActive = false
var color targetCol  = na

if showTarget and (bullBreakout or bearBreakout)
    if not na(targetLine)
        line.delete(targetLine)
    if not na(targetLbl)
        label.delete(targetLbl)
    targetCol    := bullBreakout ? bullColor : bearColor
    targetSetBar := bar_index
    targetActive := true
    targetLine := line.new(x1 = bar_index, y1 = targetPrice,
                           x2 = bar_index + extendBars, y2 = targetPrice,
                           color = targetCol, width = 3, style = line.style_solid,
                           extend = extend.none)
    targetLbl := label.new(x = bar_index + extendBars, y = targetPrice,
                           text = "TARGET " + str.tostring(targetPrice, format.mintick),
                           color = color.new(targetCol, 70),
                           textcolor = chart.fg_color, style = label.style_label_left,
                           size = size.small, xloc = xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Target Hit / Miss History
// ════════════════════════════════════════════════════════════════════
var array<label> targetHistory = array.new<label>()
var int cyclesToday = 0
var int winsToday   = 0
var int lossesToday = 0
if ta.change(time("D")) != 0
    cyclesToday := 0
    winsToday   := 0
    lossesToday := 0
if sigCompressionFire
    cyclesToday := cyclesToday + 1

if targetActive and not na(targetLine)
    bool reachedBull = not na(targetPrice) and high >= targetPrice and targetCol == bullColor
    bool reachedBear = not na(targetPrice) and low  <= targetPrice and targetCol == bearColor
    bool expired     = bar_index - targetSetBar > extendBars * 2
    if reachedBull or reachedBear or expired
        if showTargetHistory and confirmedBar
            string outcomeTxt = (reachedBull or reachedBear) ? "hit" : "miss"
            if reachedBull or reachedBear
                winsToday := winsToday + 1
            else
                lossesToday := lossesToday + 1
            color outcomeCol = (reachedBull or reachedBear) ? targetCol : neutralColor
            label tgtLbl = label.new(x = bar_index, y = targetPrice,
                 text       = "Target " + str.tostring(targetPrice, format.mintick) + "  " + outcomeTxt,
                 color      = color.new(outcomeCol, 70),
                 textcolor  = chart.fg_color,
                 style      = label.style_label_left,
                 size       = size.tiny,
                 xloc       = xloc.bar_index)
            array.push(targetHistory, tgtLbl)
            trimLabelArr(targetHistory, 15)
        line.delete(targetLine)
        if not na(targetLbl)
            label.delete(targetLbl)
        targetLine   := na
        targetLbl    := na
        targetActive := false

// ════════════════════════════════════════════════════════════════════
// VISUALS — Compression Exit Projection Lines (pre-confirmation)
// ════════════════════════════════════════════════════════════════════
var line  bullProjLine = na
var line  bearProjLine = na
var label bullProjLbl  = na
var label bearProjLbl  = na

if showProjections and sigCompressionExit and not na(chamber_high_locked) and not na(chamber_low_locked)
    if not na(bullProjLine)
        line.delete(bullProjLine)
    if not na(bearProjLine)
        line.delete(bearProjLine)
    if not na(bullProjLbl)
        label.delete(bullProjLbl)
    if not na(bearProjLbl)
        label.delete(bearProjLbl)
    float bullTgt = chamber_high_locked + chamberRange
    float bearTgt = chamber_low_locked  - chamberRange
    bullProjLine := line.new(x1 = bar_index, y1 = bullTgt,
         x2 = bar_index + extendBars, y2 = bullTgt,
         color = color.new(bullColor, 80), width = 1, style = line.style_dashed, extend = extend.none)
    bearProjLine := line.new(x1 = bar_index, y1 = bearTgt,
         x2 = bar_index + extendBars, y2 = bearTgt,
         color = color.new(bearColor, 80), width = 1, style = line.style_dashed, extend = extend.none)
    bullProjLbl  := label.new(x = bar_index + extendBars, y = bullTgt,
         text       = "bull T " + str.tostring(bullTgt, format.mintick),
         color      = color.new(bullColor, 85),
         textcolor  = chart.fg_color,
         style      = label.style_label_left,
         size       = size.tiny, xloc = xloc.bar_index)
    bearProjLbl  := label.new(x = bar_index + extendBars, y = bearTgt,
         text       = "bear T " + str.tostring(bearTgt, format.mintick),
         color      = color.new(bearColor, 85),
         textcolor  = chart.fg_color,
         style      = label.style_label_left,
         size       = size.tiny, xloc = xloc.bar_index)

if bullBreakout
    if not na(bearProjLine)
        line.delete(bearProjLine)
        bearProjLine := na
    if not na(bearProjLbl)
        label.delete(bearProjLbl)
        bearProjLbl := na
    if not na(bullProjLine)
        line.delete(bullProjLine)
        bullProjLine := na
    if not na(bullProjLbl)
        label.delete(bullProjLbl)
        bullProjLbl := na
if bearBreakout
    if not na(bullProjLine)
        line.delete(bullProjLine)
        bullProjLine := na
    if not na(bullProjLbl)
        label.delete(bullProjLbl)
        bullProjLbl := na
    if not na(bearProjLine)
        line.delete(bearProjLine)
        bearProjLine := na
    if not na(bearProjLbl)
        label.delete(bearProjLbl)
        bearProjLbl := na

// ════════════════════════════════════════════════════════════════════
// VISUALS — False-Breakout Reversion Zone
// ════════════════════════════════════════════════════════════════════
var line  revertLine = na
var label revertLbl  = na

if sigFalse and showRevertLine and not na(chamber_high_locked) and not na(chamber_low_locked)
    if not na(revertLine)
        line.delete(revertLine)
    if not na(revertLbl)
        label.delete(revertLbl)
    float mid = (chamber_high_locked + chamber_low_locked) / 2.0
    revertLine := line.new(x1 = bar_index, y1 = mid,
         x2 = bar_index + extendBars, y2 = mid,
         color = color.new(neutralColor, 60), width = 2, style = line.style_dotted, extend = extend.none)
    revertLbl  := label.new(x = bar_index + extendBars, y = mid,
         text      = "Mean revert " + str.tostring(mid, format.mintick),
         color     = color.new(neutralColor, 70),
         textcolor = chart.fg_color,
         style     = label.style_label_left,
         size      = size.tiny, xloc = xloc.bar_index)

if sigCompressionFire
    if not na(revertLine)
        line.delete(revertLine)
        revertLine := na
    if not na(revertLbl)
        label.delete(revertLbl)
        revertLbl := na

// ════════════════════════════════════════════════════════════════════
// VISUALS — Compression History Labels
// ════════════════════════════════════════════════════════════════════
var array<label> compressionHistory = array.new<label>()

if showHistory and sigCompressionExit and not na(compressionStartBar) and not na(chamber_high_locked)
    int    midBar = compressionStartBar + math.max(math.round((bar_index - compressionStartBar) / 2.0), 0)
    string dirTag = locked_dir_bias == 1 ? "BULL" : locked_dir_bias == -1 ? "BEAR" : "FLAT"
    color  hCol   = locked_dir_bias == 1 ? bullColor : locked_dir_bias == -1 ? bearColor : neutralColor
    string hTxt   = "Compress " + str.tostring(lastCompressionBars) + "b  " + dirTag
    label hLbl = label.new(x = midBar, y = chamber_high_locked,
         text       = hTxt,
         color      = color.new(hCol, 70),
         textcolor  = chart.fg_color,
         style      = label.style_label_down,
         yloc       = yloc.price,
         size       = size.tiny,
         xloc       = xloc.bar_index)
    array.push(compressionHistory, hLbl)
    trimLabelArr(compressionHistory, 10)

if showHistory and (sigBull or sigBear or sigFalse) and array.size(compressionHistory) > 0
    label lastLbl = array.get(compressionHistory, array.size(compressionHistory) - 1)
    if not na(lastLbl)
        string prev = label.get_text(lastLbl)
        string suffix = sigBull ? "  BULL hit T1" : sigBear ? "  BEAR hit T1" : "  FALSE breakout"
        if not str.contains(prev, "hit") and not str.contains(prev, "FALSE")
            label.set_text(lastLbl, prev + suffix)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Intensity History Mini-Strip (right edge)
// ════════════════════════════════════════════════════════════════════
var array<line> intensityStrip = array.new<line>()
const int STRIP_LEN = 10

if showIntensityStrip and barstate.islast
    while array.size(intensityStrip) > 0
        line old = array.shift(intensityStrip)
        if not na(old)
            line.delete(old)
    float stripHalf = atr14 * 2.5
    float stripMid  = close
    float stripTop  = stripMid + stripHalf
    float stripBot  = stripMid - stripHalf
    float segH      = (stripTop - stripBot) / STRIP_LEN
    int   anchorX   = bar_index + 35
    for i = 0 to STRIP_LEN - 1
        float v = nz(intensity[STRIP_LEN - 1 - i], 0.0)
        float yMid = stripBot + segH * (i + 0.5)
        int   a    = alphaForVal(v, 30, 90)
        color c    = color.from_gradient(v, 0.0, 1.0, color.new(neutralColor, 90), color.new(bullColor, 30))
        line seg = line.new(x1 = anchorX, y1 = yMid,
             x2 = anchorX + 3, y2 = yMid,
             color = color.new(c, a), width = 3,
             extend = extend.none, xloc = xloc.bar_index)
        array.push(intensityStrip, seg)
    trimLineArr(intensityStrip, STRIP_LEN)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Direction Bias Gauge (21-segment vertical band)
// ════════════════════════════════════════════════════════════════════
var array<line> biasGaugeLines = array.new<line>()
var label       biasGaugeLbl   = na
const int       BIAS_SEGS      = 21

if showBiasGauge and barstate.islast
    while array.size(biasGaugeLines) > 0
        line old = array.shift(biasGaugeLines)
        if not na(old)
            line.delete(old)
    if not na(biasGaugeLbl)
        label.delete(biasGaugeLbl)
        biasGaugeLbl := na
    float gHalf = atr14 * 3.0
    float gTop  = close + gHalf
    float gBot  = close - gHalf
    float segG  = (gTop - gBot) / BIAS_SEGS
    int   anchorX = bar_index + 4
    float biasNorm = cvd_slope_absmax > 0 ? math.max(-1.0, math.min(1.0, cvd_slope / cvd_slope_absmax)) : 0.0
    int   pIdx = math.round((biasNorm + 1.0) / 2.0 * (BIAS_SEGS - 1))
    for i = 0 to BIAS_SEGS - 1
        float yMid = gBot + segG * (i + 0.5)
        float t    = i * 1.0 / (BIAS_SEGS - 1)
        color cSeg = color.from_gradient(t, 0.0, 1.0, color.new(bearColor, 70), color.new(bullColor, 70))
        int   wSeg = (i == pIdx) ? 4 : 2
        int   aSeg = (i == pIdx) ? 0  : 40
        line seg = line.new(x1 = anchorX, y1 = yMid,
             x2 = anchorX + 2, y2 = yMid,
             color = color.new(cSeg, aSeg), width = wSeg,
             extend = extend.none, xloc = xloc.bar_index)
        array.push(biasGaugeLines, seg)
    string biasTag = biasNorm > 0.15 ? "BULL" : biasNorm < -0.15 ? "BEAR" : "FLAT"
    color  biasCol = biasNorm > 0.15 ? bullColor : biasNorm < -0.15 ? bearColor : neutralColor
    float  pointerY = gBot + segG * (pIdx + 0.5)
    biasGaugeLbl := label.new(x = anchorX + 4, y = pointerY,
         text       = "Bias " + str.tostring(biasNorm, "+0.00") + " " + biasTag,
         color      = color.new(biasCol, 70),
         textcolor  = chart.fg_color,
         style      = label.style_label_left,
         size       = size.tiny,
         xloc       = xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Background Pulses
// ════════════════════════════════════════════════════════════════════
var int firePulseBar  = na
var int bullPulseBar  = na
var int bearPulseBar  = na

if sigCompressionFire
    firePulseBar := bar_index
if sigBull
    bullPulseBar := bar_index
if sigBear
    bearPulseBar := bar_index

color pulseFire = na
if showPulse and not na(firePulseBar)
    int dF = bar_index - firePulseBar
    if dF >= 0 and dF <= 2
        pulseFire := color.new(neutralColor, 70 + dF * 10)

color pulseBull = na
if showPulse and not na(bullPulseBar)
    int dB = bar_index - bullPulseBar
    if dB >= 0 and dB <= 1
        pulseBull := color.new(bullColor, 70 + dB * 15)

color pulseBear = na
if showPulse and not na(bearPulseBar)
    int dR = bar_index - bearPulseBar
    if dR >= 0 and dR <= 1
        pulseBear := color.new(bearColor, 70 + dR * 15)

color bgFinal = not na(pulseBull) ? pulseBull : not na(pulseBear) ? pulseBear : pulseFire

bgcolor(bgFinal, title="CRC Pulse")

// ════════════════════════════════════════════════════════════════════
// VISUALS — Right-Edge Intensity Gauge Label
// ════════════════════════════════════════════════════════════════════
var label gaugeLbl = na

if showGauge and confirmedBar and barstate.islast
    if not na(gaugeLbl)
        label.delete(gaugeLbl)
    string stateTag = compressionActive ? "ACTIVE" : "QUIET"
    string dirTag   = direction_bias == 1 ? "BULL" : direction_bias == -1 ? "BEAR" : "FLAT"
    string txt = "INTENSITY " + str.tostring(intensity * 100, "0.0") + "%\n" + "STATE     " + stateTag + "\n" + "BIAS      " + dirTag
    color gaugeBg = compressionActive ? color.new(neutralColor, 60) : color.new(chart.bg_color, 50)
    gaugeLbl := label.new(x = bar_index + 5, y = close,
                          text       = txt,
                          color      = gaugeBg,
                          textcolor  = chart.fg_color,
                          style      = label.style_label_left,
                          size       = size.small,
                          xloc       = xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Right-Edge State Block (4 persistent labels)
// ════════════════════════════════════════════════════════════════════
var label sbIntensityLbl = na
var label sbStateLbl     = na
var label sbBiasLbl      = na
var label sbBarsLbl      = na
var label sbTargetLbl    = na

if showStateBlock and confirmedBar and barstate.islast
    if not na(sbIntensityLbl)
        label.delete(sbIntensityLbl)
    if not na(sbStateLbl)
        label.delete(sbStateLbl)
    if not na(sbBiasLbl)
        label.delete(sbBiasLbl)
    if not na(sbBarsLbl)
        label.delete(sbBarsLbl)
    if not na(sbTargetLbl)
        label.delete(sbTargetLbl)
    int    anchorX = bar_index + 30
    string stTag   = exitPulse > 0 ? "EXIT" : (bullBreakout or bearBreakout) ? "BREAKOUT" : compressionActive ? "ACTIVE" : "QUIET"
    color  stCol   = stTag == "BREAKOUT" ? (bullBreakout ? bullColor : bearColor) : stTag == "EXIT" ? neutralColor : stTag == "ACTIVE" ? bullColor : neutralColor
    float  biasNorm = cvd_slope_absmax > 0 ? math.max(-1.0, math.min(1.0, cvd_slope / cvd_slope_absmax)) : 0.0
    string biasTag  = biasNorm > 0.15 ? "BULL" : biasNorm < -0.15 ? "BEAR" : "FLAT"
    color  biasCol  = biasNorm > 0.15 ? bullColor : biasNorm < -0.15 ? bearColor : neutralColor
    string tgtTxt   = (targetActive and not na(targetPrice)) ? str.tostring(targetPrice, format.mintick) : "—"
    string tgtState = targetActive ? "  live" : "  /  miss"
    color  tgtCol   = (targetActive and targetCol == bullColor) ? bullColor : (targetActive and targetCol == bearColor) ? bearColor : neutralColor
    sbIntensityLbl := label.new(x = anchorX, y = close + atr14 * 2.0,
         text = "Intensity " + str.tostring(intensity * 100, "0") + "%",
         color = color.new(neutralColor, alphaForVal(intensity, 40, 80)),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)
    sbStateLbl := label.new(x = anchorX, y = close + atr14 * 1.0,
         text = "State " + stTag,
         color = color.new(stCol, 70),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)
    sbBiasLbl := label.new(x = anchorX, y = close,
         text = "Bias " + biasTag + " " + str.tostring(biasNorm, "+0.0"),
         color = color.new(biasCol, 70),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)
    sbBarsLbl := label.new(x = anchorX, y = close - atr14 * 1.0,
         text = "Bars in " + str.tostring(compressionActive ? barsInCompression : lastCompressionBars),
         color = color.new(neutralColor, 70),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)
    sbTargetLbl := label.new(x = anchorX, y = close - atr14 * 2.0,
         text = "Target " + tgtTxt + tgtState,
         color = color.new(tgtCol, 70),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Compression Cycle Counter
// ════════════════════════════════════════════════════════════════════
var label cycleLbl = na

if showCycleCounter and confirmedBar and barstate.islast
    if not na(cycleLbl)
        label.delete(cycleLbl)
    string cycTxt = "Compressions today: " + str.tostring(cyclesToday) + "  Win " + str.tostring(winsToday) + " / Loss " + str.tostring(lossesToday)
    cycleLbl := label.new(x = bar_index + 30, y = high * 1.05,
         text = cycTxt,
         color = color.new(neutralColor, 65),
         textcolor = chart.fg_color, style = label.style_label_left, size = size.tiny,
         xloc = xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 12,
     bgcolor      = color.new(#0a0a14, 0),
     border_color = color.new(#1f1f33, 0),
     border_width = 1,
     frame_color  = color.new(#1f1f33, 0),
     frame_width  = 1)

if showDash and barstate.islast
    var int initLast = 0
    if initLast == 0
        table.delete(dash)
        dash := table.new(posFromString(dashPos), 2, 12,
             bgcolor      = color.new(#0a0a14, 0),
             border_color = color.new(#1f1f33, 0),
             border_width = 1,
             frame_color  = color.new(#1f1f33, 0),
             frame_width  = 1)
        initLast := 1

    txtSize = sizeFromString(dashSize)

    table.cell(dash, 0, 0, "Crucible Range Compression [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.cell(dash, 1, 0, "",                                  text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    string intensityTxt = str.tostring(intensity * 100, "0.0") + "%"
    color  intensityBg  = intensity > 0.85 ? color.new(bullColor, 50) : intensity > activeThresh ? color.new(neutralColor, 40) : #1a1a26
    table.cell(dash, 0, 1, "Intensity",    text_color=chart.fg_color, bgcolor=#1a1a26,    text_size=txtSize)
    table.cell(dash, 1, 1, intensityTxt,   text_color=color.white,    bgcolor=intensityBg,text_size=txtSize)

    table.cell(dash, 0, 2, "BBW Percentile",                                 text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, str.tostring(bbw_pct, "0.0") + "%",               text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 3, "ATR Percentile",                                 text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, str.tostring(atr_pct, "0.0") + "%",               text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 4, "Body Score",                                     text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, str.tostring(body_score * 100, "0.0") + "%",      text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string stateStr = compressionExit ? "BREAKOUT" : compressionActive ? "ACTIVE" : "INACTIVE"
    color  stateBg  = stateStr == "BREAKOUT" ? color.new(bullColor, 40) : stateStr == "ACTIVE" ? color.new(neutralColor, 30) : #1a1a26
    table.cell(dash, 0, 5, "Compression State", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 5, stateStr,            text_color=color.white,    bgcolor=stateBg, text_size=txtSize)

    table.cell(dash, 0, 6, "Bars in Compression",                            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, str.tostring(barsInCompression),                  text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string biasStr = direction_bias == 1 ? "BULL" : direction_bias == -1 ? "BEAR" : "NEUTRAL"
    color  biasBg  = direction_bias == 1 ? color.new(bullColor, 40) : direction_bias == -1 ? color.new(bearColor, 40) : #1a1a26
    table.cell(dash, 0, 7, "Direction Bias",  text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, biasStr,           text_color=color.white,    bgcolor=biasBg,  text_size=txtSize)

    string chHiTxt = na(chamber_high) ? "—" : str.tostring(chamber_high, format.mintick)
    table.cell(dash, 0, 8, "Chamber High", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, chHiTxt,        text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string chLoTxt = na(chamber_low) ? "—" : str.tostring(chamber_low, format.mintick)
    table.cell(dash, 0, 9, "Chamber Low",  text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, chLoTxt,        text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string tgtTxt = (targetActive and not na(targetPrice)) ? str.tostring(targetPrice, format.mintick) : "—"
    color  tgtBg  = targetActive and targetCol == bullColor ? color.new(bullColor, 50) : targetActive and targetCol == bearColor ? color.new(bearColor, 50) : #1a1a26
    table.cell(dash, 0, 10, "Target",  text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 10, tgtTxt,    text_color=color.white,    bgcolor=tgtBg,   text_size=txtSize)

    table.cell(dash, 0, 11, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 11, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 11, 1, 11)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(sigCompressionFire, "CRC Compression Entry",  "Crucible Range Compression [JOAT] — Compression detected")
alertcondition(sigCompressionExit, "CRC Compression Exit",   "Crucible Range Compression [JOAT] — Compression exit — breakout pending")
alertcondition(sigBull,            "CRC Bull Breakout",      "Crucible Range Compression [JOAT] — Bullish breakout confirmed")
alertcondition(sigBear,            "CRC Bear Breakout",      "Crucible Range Compression [JOAT] — Bearish breakout confirmed")
alertcondition(sigFalse,           "CRC False Breakout",     "Crucible Range Compression [JOAT] — Direction mismatch (potential false breakout)")
````
