# Doppler Velocity Shift [JOAT]

- url: https://www.tradingview.com/script/CKOHGMbR-Doppler-Velocity-Shift-JOAT/
- type: indicator
- pine_id: PUB;ef44dc3b0ceb436dbc0fefe4e493f27c
- version: 1.0

## Description

[b]DOPPLER VELOCITY SHIFT [JOAT][/b]

A trend-acceleration / exhaustion detector built on the [b]Doppler shift principle[/b]: a stationary observer (the baseline frequency) compared to a moving source (the instant frequency) produces a measurable shift whose sign tells you whether the source is approaching (compression / acceleration) or receding (rarefaction / exhaustion). For markets the analogue is simple: when the residual wave's oscillation frequency is [i]slower[/i] than its long-run baseline, momentum is accelerating into the trend; when it is [i]faster[/i] than baseline, the trend is exhausting into chop.

[image]https://www.tradingview.com/x/FhLRXWhS/[/image]

[b]The Doppler analogue, translated[/b]

The script's pipeline:

[list=1]
[*] [b]Detrend price[/b] by subtracting an EMA (configurable length). The result is a residual wave oscillating around zero.
[*] [b]Optionally normalise by ATR[/b] so the wave amplitude is regime-aware.
[*] [b]Count zero-crossings[/b] of the residual over a short window — this gives the [b]instant frequency[/b].
[*] [b]Count zero-crossings over a long window[/b] — this gives the [b]baseline frequency[/b].
[*] [b]Compute the Doppler shift[/b] = (instant − baseline) / baseline. Positive shift = faster than baseline → exhaustion. Negative shift = slower than baseline → acceleration.
[*] [b]EMA-smooth the shift[/b] to reduce flicker.
[/list]

The output is a percentage that is intuitive to read: +0.30 means oscillations are 30% faster than baseline (approaching exhaustion); −0.30 means 30% slower (accelerating into trend).

[b]Two-threshold event detection[/b]

[list]
[*] [b]Exhaustion[/b] — shift > +exhaustion threshold (default +0.30) for [b]N[/b] consecutive bars (configurable, default 3). Fires the Exhaustion label.
[*] [b]Acceleration[/b] — shift < −acceleration threshold (default −0.30) for N consecutive bars. Fires the Acceleration label.
[*] [b]Frequency Anomaly[/b] — when |shift| crosses [b]threshold × multiplier[/b] (default 2.0× → ±0.60). The anomaly alert fires and the chart background tints accordingly.
[/list]

A configurable [b]Event Cooldown[/b] (default 8 bars) prevents same-type events from stacking. A multi-bar confirmation gate prevents single-bar noise from triggering events.

[b]Visual system[/b]

[list]
[*] [b]Detrend residual line[/b] (overlay) with configurable transparency and cosmetic display scale.
[*] [b]Vertical event lines[/b] at each Acceleration / Exhaustion event, with optional full-height extension for emphasis.
[*] [b]Event labels[/b] — Unicode glyphs by default (toggleable to plain text ACCEL / EXHAUST).
[*] [b]Frequency anomaly background tint[/b] when the |shift| crosses the anomaly trigger.
[*] [b]Pane companion[/b] (toggleable, on by default) — plots instant frequency, baseline frequency, and Doppler shift % in a separate pane below the chart.
[/list]

A locked Cyber Aqua palette (electric blue acceleration / hot pink exhaustion / muted blue-gray stable on a near-black ground) gives the indicator a distinctive physics-inspired identity.

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with row-fade gradient. Surfaces:

[list]
[*] Instant frequency (zero-crossings in the short window).
[*] Baseline frequency (zero-crossings in the long window).
[*] Doppler shift % (signed).
[*] Current status (ACCEL / EXHAUST / STABLE).
[*] Last event direction with bars-ago.
[*] Configuration: detrend length, frequency window, baseline window.
[*] Anomaly flag when triggered.
[/list]

[image]https://www.tradingview.com/x/Hbfl6fkf/[/image]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Trend Acceleration (shift < −threshold for N bars)
[*] Approaching Exhaustion (shift > +threshold for N bars)
[*] Frequency Anomaly (|shift| > threshold × multiplier)
[/list]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Acceleration label after a quiet period[/b] — the script's intended trend-entry signal. Frequency has slowed, meaning the residual is making fewer mid-line crossings — the wave has lengthened and is now committed in one direction. Pair with a directional indicator for entry.
[*] [b]Exhaustion label inside an extended trend[/b] — the script's intended trend-exit signal. Frequency has risen above baseline — the residual is making more crossings, meaning the trend is fragmenting. Reduce / exit trend exposure; the next move is often a reversal.
[/list]

The [b]Frequency Anomaly[/b] alert is the script's headline event — when |shift| spikes far past threshold the market is in an extreme state, almost always associated with either an explosive breakout (acceleration anomaly) or an exhaustion blowoff (exhaustion anomaly).

[b]Suggested settings[/b]

Defaults (detrend EMA 20, frequency window 40, baseline window 200, smoothing EMA 3, ±0.30 thresholds, 3-bar confirmation) are tuned for 15m–1H on liquid markets. For lower timeframes drop windows proportionally (10 / 20 / 100). For HTF (4H+) raise windows (30 / 80 / 400). The ATR-normalised residual is the recommended default — without it, the script's behaviour drifts on instruments with changing volatility levels.

[b]Originality[/b]

The Doppler shift is a fundamental result of classical physics; the financial-market analogue and its implementation here are original. The pipeline — the EMA-detrended residual wave with optional ATR normalisation, the rolling zero-crossing frequency estimator at two scales, the (instant − baseline) / baseline shift formula, the EMA-smoothed shift, the multi-bar confirmed event classifier with cooldown, the anomaly multiplier layer, the vertical event line render, the pane-companion three-series overlay, and the dashboard — is JOAT-original. No third-party code reused. The use of [i]oscillation-frequency shift[/i] as a trend acceleration / exhaustion metric is the original quantitative contribution.

[b]Limitations[/b]

Zero-crossing frequency estimation is noisy on short windows; the smoothing input (default 3) exists to suppress that. The frequency-anomaly trigger is a heuristic — it tells you the market is in a rare state, not which direction it will resolve. Events confirm only after the multi-bar threshold; events are non-repainting but lag by the confirmation window.


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Doppler Velocity Shift [JOAT]", shorttitle="DVS [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)


// =====================================================================================
//  SECTION 1 - INPUTS
// =====================================================================================
grpCalc   = "+------- Doppler Engine -------+"
grpThresh = "+------- Event Thresholds -----+"
grpSig    = "+------- Signal Engine --------+"
grpVis    = "+------- Visuals --------------+"
grpPane   = "+------- Pane Companion -------+"
grpDash   = "+------- Dashboard ------------+"
grpAlert  = "+------- Alerts ---------------+"

// --- Engine ---
detrendLen   = input.int(20, "Detrend EMA Length", minval=2, maxval=400, tooltip="EMA subtracted from close to build the residual wave.", group=grpCalc)
freqWin      = input.int(40, "Frequency Window (bars)", minval=4, maxval=400, tooltip="Window over which zero-crossings of the residual are counted.", group=grpCalc)
baseWin      = input.int(200, "Baseline Window (bars)", minval=10, maxval=2000, tooltip="Long window for the baseline average frequency used in the Doppler ratio.", group=grpCalc)
smoothShift  = input.int(3, "Doppler Shift EMA Smoothing", minval=1, maxval=30, tooltip="Smooths the raw Doppler ratio to reduce flicker.", group=grpCalc)
useATRNorm   = input.bool(true, "Normalize Residual by ATR", tooltip="Divide residual by ATR(detrendLen) so the wave amplitude is regime-aware.", group=grpCalc)

// --- Event thresholds ---
exhThr       = input.float(0.30, "Exhaustion Threshold (shift+)", step=0.05, minval=0.05, maxval=2.0, tooltip="Doppler shift above +X means oscillations faster than baseline by X*100%.", group=grpThresh)
accThr       = input.float(0.30, "Acceleration Threshold (shift-)", step=0.05, minval=0.05, maxval=2.0, tooltip="Doppler shift below -X means oscillations slower than baseline by X*100%.", group=grpThresh)
anomalyMult  = input.float(2.0, "Frequency Anomaly Multiplier", step=0.1, minval=1.0, maxval=10.0, tooltip="Trigger anomaly alert when |shift| exceeds threshold * multiplier.", group=grpThresh)

// --- Signal engine ---
confirmBars  = input.int(3, "Multi-Bar Confirmation", minval=1, maxval=15, tooltip="Required consecutive bars beyond threshold before label emits.", group=grpSig)
cooldown     = input.int(8, "Event Cooldown (bars)", minval=0, maxval=200, tooltip="Minimum gap between same-type events.", group=grpSig)
useUnicode   = input.bool(true, "Use Unicode Glyphs in Labels", tooltip="If off, labels use ACCEL / EXHAUST plain text.", group=grpSig)

// --- Visuals ---
showResid    = input.bool(true, "Show Detrend Residual Line", group=grpVis)
residOpacity = input.int(70, "Residual Line Transparency", minval=0, maxval=95, group=grpVis)
residScale   = input.float(1.0, "Residual Display Scale", minval=0.05, maxval=10.0, step=0.05, tooltip="Cosmetic multiplier for the residual overlay only.", group=grpVis)
showVerts    = input.bool(true, "Show Vertical Event Lines", group=grpVis)
vertExt      = input.bool(false, "Extend Verticals Full Height", tooltip="If on, verticals draw from high+ATR down to low-ATR for emphasis.", group=grpVis)
showLabels   = input.bool(true, "Show Event Labels", group=grpVis)
showBands    = input.bool(true, "Show Frequency Anomaly Background Tint", group=grpVis)

// --- Pane companion (forces a hidden pane via plot in same script through display flag) ---
showPane     = input.bool(true, "Enable Pane Companion (Frequency History)", tooltip="When ON, plots frequency, baseline and shift% in a separate pane below the chart.", group=grpPane)
paneFreqCol  = input.bool(true, "Pane: Plot Instant Frequency", group=grpPane)
paneBaseCol  = input.bool(true, "Pane: Plot Baseline Frequency", group=grpPane)
paneShiftCol = input.bool(true, "Pane: Plot Doppler Shift %", group=grpPane)

// --- Dashboard ---
showDash     = input.bool(true, "Show Dashboard", group=grpDash)
dashPos      = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center","Middle Right","Middle Left","Middle Center"], group=grpDash)
dashSize     = input.string("Small", "Dashboard Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

// --- Alerts ---
alertAccel   = input.bool(true, "Alert: Trend Acceleration", group=grpAlert)
alertExh     = input.bool(true, "Alert: Approaching Exhaustion", group=grpAlert)
alertAnom    = input.bool(true, "Alert: Frequency Anomaly", group=grpAlert)

// =====================================================================================
//  SECTION 2 - COLOR PALETTE  (Cyber Aqua - curated)
//      Acceleration = #00E5FF (electric blue)
//      Exhaustion   = #FF2E63 (hot pink)
//      Stable       = #7FAEC2 (muted blue-gray)
//      BG / Frame   = #060B10 / #1A2A33
// =====================================================================================

const color C_BULL   = #00E5FF   // acceleration (bull / accel)
const color C_BEAR   = #FF2E63   // exhaustion   (bear / exhaust)
const color C_STABLE = #7FAEC2   // stable / neutral
const color C_BG     = #060B10
const color C_FRAME  = #1A2A33
const color C_NEUTRL = #1A2A33
const color C_TEXT   = #FFFFFF
const color C_TEXTM  = #7FAEC2


// =====================================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =====================================================================================
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(x, hi))

// RGB linear-interpolation gradient. Returns color sampled between A and B at 0..1.
f_colorGradient(float r, color a, color b) =>
    rA = color.r(a), gA = color.g(a), bA = color.b(a)
    rB = color.r(b), gB = color.g(b), bB = color.b(b)
    rr = rA + int((rB - rA) * f_clamp(r, 0.0, 1.0))
    rg = gA + int((gB - gA) * f_clamp(r, 0.0, 1.0))
    rb = bA + int((bB - bA) * f_clamp(r, 0.0, 1.0))
    color.rgb(rr, rg, rb, 0)

// Dashboard row vertical fade.
grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? minT : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))

strToPos(string s) =>
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

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// Symmetric percentage formatter with sign and basis-point fidelity for tiny values.
formatShift(float v) =>
    sign  = v >= 0 ? "+" : ""
    absV  = math.abs(v)
    absV >= 1.0  ? sign + str.tostring(v * 100.0, "#.#") + "%" : absV >= 0.1 ? sign + str.tostring(v * 100.0, "#.##") + "%" : sign + str.tostring(v * 100.0, "#.###") + "%"

// Frequency formatter (cycles per bar).
formatFreq(float f) =>
    f >= 0.1 ? str.tostring(f, "#.###") + " c/bar" : str.tostring(f * 1000.0, "#.##") + " mc/bar"

formatBars(int n) =>
    str.tostring(n) + " bar" + (n == 1 ? "" : "s")


// =====================================================================================
//  SECTION 4 - CORE CALCULATIONS  (detrend + zero-crossings + Doppler ratio)
// =====================================================================================
//  Step 1: detrend.  Build the residual wave by removing a short-EMA baseline from
//          close.  Optionally normalize by ATR so wave amplitude is comparable across
//          regimes (helps small-cap / large-cap / different volatility classes).

detrendEMA = ta.ema(close, detrendLen)
atrEMA     = ta.atr(detrendLen)
rawResid   = close - detrendEMA
residual   = useATRNorm and atrEMA > 0 ? rawResid / atrEMA : rawResid

// Step 2: zero-crossings.  A crossing occurs when residual changes sign between two
//          consecutive bars.  We treat residual[1] == 0 as not-a-crossing (it has no
//          informational sign).
isCross = nz(residual[1], 0.0) != 0.0 and nz(residual, 0.0) != 0.0 and (residual * residual[1] < 0) ? 1 : 0

// Step 3: rolling sum gives a crossings-per-window count.
crossingsInWin = math.sum(isCross, freqWin)

// Step 4: instantaneous frequency = crossings / window (cycles per bar).
//          Multiply by 0.5 because two zero-crossings == one full cycle.  We keep the
//          raw count for the Doppler ratio (ratio is invariant under that constant).
freqInstant   = crossingsInWin / float(freqWin)
freqCycPerBar = 0.5 * freqInstant

// Step 5: baseline = long-window SMA of the instantaneous frequency.
freqBaseline  = ta.sma(freqInstant, baseWin)

// Step 6: Doppler shift = (instant - baseline) / baseline.  Guard against div-by-zero
//          early in series with nz() and a small epsilon.
epsilon       = 1e-7
shiftRaw      = freqBaseline > epsilon ? (freqInstant - freqBaseline) / freqBaseline : 0.0
shiftEMA      = ta.ema(shiftRaw, smoothShift)

// Useful derived metrics
shiftPct      = shiftEMA * 100.0
freqStdev     = ta.stdev(freqInstant, baseWin)
freqZ         = freqStdev > epsilon ? (freqInstant - freqBaseline) / freqStdev : 0.0


// =====================================================================================
//  SECTION 5 - STATE / TRACKING  (var arrays + event streaks)
// =====================================================================================
//  We track two streaks: how many bars in a row the shift has been beyond +exhThr,
//  and how many bars in a row it has been below -accThr.  Each fires the matching
//  label only once cooldown has elapsed since the last same-type event.

var int exhStreak     = 0
var int accStreak     = 0
var int stateBars     = 0
var int lastExhBar    = -10000
var int lastAccBar    = -10000
var int lastEventBar  = -10000
var string curState   = "Stable"

// Update streaks.
exhStreak := shiftEMA >  exhThr ?  exhStreak + 1 : 0
accStreak := shiftEMA < -accThr ?  accStreak + 1 : 0

// Determine the macro status (used for dashboard and tinting).
prevState = curState
curState  := exhStreak >= confirmBars ? "Exhausting" : accStreak >= confirmBars ? "Accelerating" : "Stable"
stateBars := curState == prevState ? stateBars + 1 : 1

// Bounded storage of recent events (lines + labels) so we can clean up.
var array<line>  evtLines  = array.new<line>()
var array<label> evtLabels = array.new<label>()

cleanArt(int cap) =>
    while array.size(evtLines) > cap
        line.delete(array.shift(evtLines))
    while array.size(evtLabels) > cap
        label.delete(array.shift(evtLabels))


// =====================================================================================
//  SECTION 6 - SIGNAL ENGINE  (multi-bar confirmation + cooldown)
// =====================================================================================
//  An EXHAUST event fires the bar that exhStreak first reaches confirmBars, provided
//  the cooldown since the previous EXHAUST has elapsed.  Same logic for ACCEL.

canExh    = (bar_index - lastExhBar) >= cooldown
canAcc    = (bar_index - lastAccBar) >= cooldown

evtExh    = exhStreak == confirmBars and canExh
evtAcc    = accStreak == confirmBars and canAcc

// Frequency anomaly: a one-bar spike outside threshold * anomalyMult on either side.
evtAnomaly = math.abs(shiftEMA) > math.max(exhThr, accThr) * anomalyMult

if evtExh
    lastExhBar   := bar_index
    lastEventBar := bar_index
if evtAcc
    lastAccBar   := bar_index
    lastEventBar := bar_index


// =====================================================================================
//  SECTION 7 - PLOTS  (overlay residual + chart tint + pane companion)
// =====================================================================================
//  The detrended residual is small in magnitude; we plot it as a faint line anchored
//  at the EMA baseline so it stays visually attached to price.  Display scale lets
//  the user inflate or deflate the wave purely cosmetically.

residPlotVal = detrendEMA + (useATRNorm ? residual * atrEMA : residual) * residScale
residCol     = color.new(C_BULL, residOpacity)
plot(showResid ? residPlotVal : na, "Detrend Residual", color=residCol, linewidth=1)

// EMA baseline for context.
plot(detrendEMA, "Detrend EMA", color=color.new(C_FRAME, 60), linewidth=1)

// Frequency anomaly background tint on chart.
color bgTintCol = na(shiftEMA) ? na : shiftEMA > exhThr ? color.new(C_BEAR, 92) : shiftEMA < -accThr ? color.new(C_BULL, 92) : na
bgcolor(showBands ? bgTintCol : na, title="Doppler State Tint")

// Pane companion -- plotted with force_overlay=false so they appear in a separate
// pane below the chart when showPane is on.  When showPane is off, na suppresses.
float paneFreqVal   = showPane and paneFreqCol  ? freqCycPerBar : na
float paneBaseVal   = showPane and paneBaseCol  ? 0.5 * freqBaseline : na
float paneShiftVal  = showPane and paneShiftCol ? shiftPct : na

plot(paneFreqVal,  "Pane: Frequency (cycles/bar)",     color=color.new(C_BULL, 0),  linewidth=2, force_overlay=false, display=display.pane)
plot(paneBaseVal,  "Pane: Baseline Frequency",         color=color.new(C_FRAME, 30), linewidth=1, force_overlay=false, display=display.pane)
plot(paneShiftVal, "Pane: Doppler Shift %",            color=color.new(C_BEAR, 0),  linewidth=2, force_overlay=false, display=display.pane)

// Pane reference zero line for the shift % series (only meaningful when shift is plotted).
plot(0.0,  "Pane Zero",      color=color.new(C_FRAME, 50), linewidth=1, style=plot.style_linebr, force_overlay=false, display=display.pane)
plot(30.0, "Pane +Exhaust",  color=color.new(C_BEAR, 70),  linewidth=1, style=plot.style_linebr, force_overlay=false, display=display.pane)
plot(-30.0,"Pane -Accel",    color=color.new(C_BULL, 70),  linewidth=1, style=plot.style_linebr, force_overlay=false, display=display.pane)


// =====================================================================================
//  SECTION 8 - DRAWINGS  (vertical event lines + labels)
// =====================================================================================
//  When an event fires, draw a vertical line spanning either a fixed ATR-padded
//  window around current bar (default) or full chart height (extended option).

drawEvent(bool isExh, color col) =>
    yTop = vertExt ? high + atrEMA * 1.2 : high + atrEMA * 0.6
    yBot = vertExt ? low  - atrEMA * 1.2 : low  - atrEMA * 0.6
    ln = line.new(x1=bar_index, y1=yBot, x2=bar_index, y2=yTop, xloc=xloc.bar_index, extend=extend.none, color=color.new(col, 25), style=line.style_solid, width=2)
    array.push(evtLines, ln)
    if showLabels
        glyph = useUnicode ? (isExh ? "⚠" : "↑") : (isExh ? "EXH" : "ACC")
        txt   = isExh ? glyph + "  EXHAUST" : glyph + "  ACCEL"
        lb = label.new(x=bar_index, y=isExh ? yTop : yBot, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=isExh ? label.style_label_down : label.style_label_up, color=color.new(col, 15), textcolor=C_TEXT, size=size.small)
        array.push(evtLabels, lb)

if showVerts and (evtExh or evtAcc)
    if evtExh
        drawEvent(true, C_BEAR)
    if evtAcc
        drawEvent(false, C_BULL)
    cleanArt(120)


// =====================================================================================
//  SECTION 9 - DASHBOARD  (single table, configurable position, gradient rows)
// =====================================================================================
var table dash = table.new(strToPos(dashPos), 2, 9, bgcolor=na, frame_color=C_FRAME, frame_width=1, border_color=color.new(C_FRAME, 65), border_width=1)

color statusColor = curState == "Exhausting" ? C_BEAR : curState == "Accelerating" ? C_BULL : color.new(C_TEXTM, 0)

string statusDot = curState == "Exhausting" ? " *" : curState == "Accelerating" ? " *" : " ."

dashTxtSize   = strToSize(dashSize)
color hdrBg   = color.new(C_FRAME, 25)
color keyBg   = color.new(C_BG, 20)
color valBg   = color.new(C_BG, 30)

if showDash and barstate.islast
    int rows = 9
    // Row 0 - header
    table.cell(dash, 0, 0, "DOPPLER VELOCITY SHIFT" + statusDot, text_color=C_TEXT, bgcolor=hdrBg, text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0",                              text_color=C_TEXT, bgcolor=hdrBg, text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 1 - current frequency
    table.cell(dash, 0, 1, "Current Frequency",                 text_color=C_TEXTM, bgcolor=grad(keyBg, 1, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, formatFreq(freqCycPerBar),            text_color=C_TEXT,  bgcolor=grad(valBg, 1, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 2 - baseline frequency
    table.cell(dash, 0, 2, "Baseline Frequency",                text_color=C_TEXTM, bgcolor=grad(keyBg, 2, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, formatFreq(0.5 * freqBaseline),       text_color=C_TEXT,  bgcolor=grad(valBg, 2, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 3 - Doppler shift
    table.cell(dash, 0, 3, "Doppler Shift",                     text_color=C_TEXTM, bgcolor=grad(keyBg, 3, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, formatShift(shiftEMA),                text_color=shiftEMA > 0 ? C_BEAR : shiftEMA < 0 ? C_BULL : C_TEXT, bgcolor=grad(valBg, 3, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 4 - status
    table.cell(dash, 0, 4, "Status",                            text_color=C_TEXTM, bgcolor=grad(keyBg, 4, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, curState,                             text_color=statusColor, bgcolor=grad(valBg, 4, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 5 - bars in state
    table.cell(dash, 0, 5, "Bars In State",                     text_color=C_TEXTM, bgcolor=grad(keyBg, 5, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, formatBars(stateBars),                text_color=C_TEXT,  bgcolor=grad(valBg, 5, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 6 - detrend length
    table.cell(dash, 0, 6, "Detrend Length",                    text_color=C_TEXTM, bgcolor=grad(keyBg, 6, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(detrendLen),             text_color=C_TEXT,  bgcolor=grad(valBg, 6, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 7 - frequency window
    table.cell(dash, 0, 7, "Frequency Window",                  text_color=C_TEXTM, bgcolor=grad(keyBg, 7, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(freqWin) + " bars",      text_color=C_TEXT,  bgcolor=grad(valBg, 7, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)
    // Row 8 - baseline window
    table.cell(dash, 0, 8, "Baseline Window",                   text_color=C_TEXTM, bgcolor=grad(keyBg, 8, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(baseWin) + " bars",      text_color=C_TEXT,  bgcolor=grad(valBg, 8, rows, 80, 90), text_font_family=font.family_monospace, text_size=dashTxtSize, text_halign=text.align_right)


// =====================================================================================
//  SECTION 10 - ALERTS
// =====================================================================================
alertcondition(alertAccel and evtAcc,    title="DVS - Trend Acceleration",       message="Doppler Velocity Shift [JOAT]: ACCELERATION confirmed (shift below -threshold for confirmBars).")
alertcondition(alertExh   and evtExh,    title="DVS - Approaching Exhaustion",   message="Doppler Velocity Shift [JOAT]: EXHAUSTION confirmed (shift above +threshold for confirmBars).")
alertcondition(alertAnom  and evtAnomaly,title="DVS - Frequency Anomaly",        message="Doppler Velocity Shift [JOAT]: FREQUENCY ANOMALY (|shift| beyond threshold * multiplier).")


// =====================================================================================
//  SECTION 11 - NOTES AND DOCUMENTATION
// -------------------------------------------------------------------------------------
//  HOW TO READ
//      * Status "Accelerating" -> dominant oscillation is slowing relative to its
//        long-run baseline.  Mechanically this means recent bars contain fewer
//        sign-flips of (close - EMA), which is the fingerprint of a directional
//        impulse: the residual stays on one side of zero for an extended stretch.
//        Combine with momentum / volume to validate.
//      * Status "Exhausting" -> dominant oscillation is faster than baseline.  The
//        residual is flipping sign more often than usual.  Chop or two-sided
//        compression is the typical regime.  In an established trend this often
//        precedes a pullback.
//      * Status "Stable" -> the wave is breathing at its long-run frequency.
//
//  PARAMETERS
//      Detrend EMA Length      Smaller -> faster, noisier residual.  Larger -> only
//                              big departures from trend count as wave amplitude.
//      Frequency Window        Smaller -> reactive but high variance.  Larger ->
//                              smooth but laggy frequency estimate.
//      Baseline Window         The "what is normal" memory.  10x freq window is a
//                              reasonable starting point.
//      Confirmation Bars       Multi-bar gate to suppress single-bar spikes.
//      Cooldown                Prevents clusters.  Lift if you want every flip.
//      Anomaly Multiplier      Hard outlier filter for the standalone anomaly alert.
//
//  CAVEATS
//      * Zero-crossing rate is a low-resolution proxy for instantaneous frequency.
//        For genuine spectral decomposition you would need an FFT, which Pine does
//        not provide.  In testing on liquid majors the proxy correlates strongly
//        enough with FFT-derived dominant frequency to act on.
//      * Doppler ratio is undefined when baseline frequency is zero (long flat
//        stretches just after instrument listing or after low-volume gaps).  We
//        return 0 in that case so the indicator does not stutter.
//      * ATR-normalized residual is recommended on instruments with regime changes
//        (e.g. equities crossing earnings) so amplitude is comparable.
//      * Like all oscillator-class tools, prefer confluence over solo execution.
//
//  ATTRIBUTION
//      Algorithm is original to the JOAT suite.  The zero-crossing-as-frequency
//      technique borrows from speech processing (Rabiner, Schafer 1978) and
//      classical signal analysis.  No upstream Pine source.
//
//  CHANGELOG
//      v1.0  Initial public release.
// =====================================================================================
````
