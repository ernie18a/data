# Turtle Soup Reversal Map [AGPro Series]

- url: https://www.tradingview.com/script/jxwPmNiq-Turtle-Soup-Reversal-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;0b9e0c61d42e402b8cc6daecbedbd199
- version: 3.0

## Description

Turtle Soup Reversal Map [AGPro Series]

🔹 Overview

Turtle Soup Reversal Map is a mean-reversion pattern detector inspired by Linda Raschke's classic "Turtle Soup" setup — a counter-attack on failed 20-bar breakouts. When price pierces a multi-bar extreme and then closes back inside the prior range, institutional traders often interpret it as trapped breakout participants being flushed. This script automates the detection, qualifies each setup with a transparent 0–100 score, and projects a reference target alongside an auto-resolving rejection zone. It is designed for traders who want a disciplined, rule-based way to spot failed breakouts without drawing them manually.


🔹 Unique Edge

Unlike generic liquidity-sweep or wick-rejection indicators, Turtle Soup Reversal Map is built around Raschke's specific 20-bar-extreme rule — a pattern with decades of documented performance in swing-trading literature. Three characteristics separate it from similar tools:

• Strict N-bar-extreme definition (not a simple swing-high/low fade). Price must violate the exact prior-lookback extreme, not just a minor pivot.

• Five-component adaptive quality score — wick rejection, volume spike, overshoot magnitude, higher-timeframe trend alignment, and key-level proximity. Each component is a transparent weighted contribution, with clear A+ / A / B / C grades.

• Full lifecycle state engine — Pending → Fired → Target/Stop/Invalidated. Setups that do not confirm within their window are auto-invalidated (not left hanging), and live win-rate plus average R-multiple are tracked over the most recent resolved setups.


🔹 Methodology

The script continuously monitors for price piercing the highest high or lowest low of the prior N bars (default 20, range 10–50). When a sweep occurs, a Pending setup is created. Confirmation is then evaluated in one of two user-selectable modes:

• Same-Bar Close — the violating bar must close back inside the prior range on the same bar (faster, more signals).

• Next-Bar Close — Raschke's original specification; the next bar must close back inside the prior range (slower, higher reliability).

If confirmation fires, the setup becomes Fired and a reference target is projected from the confirmation close (default 2.5 × ATR(14)). Stop is placed at the sweep extreme plus a configurable ATR buffer. Setups that fail to confirm within their window, or where price overshoots the stop before confirmation, are automatically invalidated.

The quality score blends: wick-to-range ratio at the extreme bar, relative volume spike versus its 20-bar average, overshoot magnitude (ATR-normalized with a sweet-spot curve), counter-trend alignment against a user-defined higher timeframe, and proximity to round numbers or recent pivot levels.


🔹 Signals & Alerts

The script produces three alert types, all configurable:

• Pending — sweep detected, awaiting confirmation.

• Fired — confirmation closed back inside prior range.

• Invalidated — setup dismissed due to overshoot or window timeout.

Each alert message includes direction (Bull/Bear), current grade, ticker, and timeframe. Fired setups are visualized with a labeled confirmation marker, a dashed target-projection line, a dotted stop-reference line, and an auto-closing rejection zone. Labels display the Soup-Bull / Soup-Bear name, grade, and numeric score.


🔹 Key Inputs

• Lookback Bars — size of the extreme window (default 20, range 10–50).

• Confirmation Mode — Same-Bar Close or Next-Bar Close.

• Invalidation Distance (ATR) — stop buffer beyond the sweep extreme (default 0.5).

• Target Projection (ATR) — reference reversal target distance from entry (default 2.5).

• Quality Score Components — each of the five score components can be toggled independently for custom configurations.

• HTF for Trend — higher timeframe used for the trend-alignment component (default 240 min).

• Stats Sample Size — rolling window of resolved setups used for win-rate and average reward metrics (default 30).

• Visual & Panel Options — zones, lines, labels, target projection, panel location, font sizes, and per-element toggles.


🔹 How to Use

1. Apply to any liquid instrument and timeframe. The pattern's rule set is symbol-agnostic but performs differently across assets — review the live Win Rate and Avg Reward metrics in the panel to calibrate expectations.

2. Watch the Status field in the panel. Idle means no active setup; Pending Bull/Bear means a sweep has occurred and the script is waiting for confirmation; Fired Bull/Bear means confirmation closed and a target has been projected.

3. Filter setups by grade. A+ and A setups have stronger confluence — particularly wick rejection, volume, and HTF alignment. B setups are acceptable under favorable market regimes; C grades are educational only.

4. Treat the target projection as a reference, not a trade instruction. The stop reference line marks where the structural invalidation lies. Always combine with your own risk management.

5. The historical Win Rate is computed over the last N resolved setups on the current chart; it reflects the pattern's fit with the current symbol and timeframe, not a guarantee.


🔹 Limitations & Transparency

This indicator identifies historical setups algorithmically. It does not predict future price movement, and no indicator does. Turtle Soup is a counter-trend mean-reversion pattern — in strong trending regimes, false signals increase; in consolidation and range-bound conditions, it performs best. The displayed Win Rate and Avg Reward are historical, rolling, chart-dependent, and should not be interpreted as future expectations. Target and stop references are geometric projections based on ATR, not optimized parameters.

🔹 Risk Disclosure

This script is a technical analysis tool for educational and research purposes. It is not a trading strategy, not a recommendation, and not financial advice. Past performance does not guarantee future results. Always conduct your own analysis and use proper risk management. Trade at your own risk.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Turtle Soup Reversal Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Turtle Soup reversal decision engine with adaptive 0-100 quality scoring.
// Detects 20-bar extreme sweeps that fail and reverse — Linda Raschke's
// classic mean-reversion setup, re-engineered with wick rejection, volume
// confirmation, overshoot magnitude, HTF trend alignment and key-level
// proximity scoring. Pending / Fired / Invalidated state engine with a
// clear next-action read, stop & target projection, stop-aware
// follow-through proof rate and realized-R tracking.
// Keywords: turtle soup, reversal, liquidity sweep, false breakout,
// mean reversion, Raschke, 20-bar extreme, failed breakout, setup quality.
// ─────────────────────────────────────────────────

//@version=6
indicator("Turtle Soup Reversal Map [AGPro Series]",
     shorttitle = "AG Pro TSRM",
     overlay    = true,
     max_labels_count = 300,
     max_lines_count  = 300,
     max_boxes_count  = 200)

// ═════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════
grpCore = "◆ Core Detection"
lookback      = input.int(20, "Lookback Bars",    minval=10, maxval=50, group=grpCore, tooltip="Number of bars defining the extreme high/low window. Raschke's original spec is 20. Higher values yield fewer but stronger setups.")
confirmMode   = input.string("Next-Bar Close", "Confirmation Mode", options=["Same-Bar Close","Next-Bar Close"], group=grpCore, tooltip="Same-Bar Close: setup fires on the violating bar's close. Faster but higher false-signal rate. Next-Bar Close: Raschke standard - requires the next bar to close back inside the prior range. More reliable.")
invalidateATR = input.float(0.5, "Invalidation Distance (ATR)", minval=0.2, maxval=3.0, step=0.1, group=grpCore, tooltip="Pending setups are invalidated if price moves this many ATR beyond the sweep extreme before confirmation. Also defines the protective stop placement once a setup fires.")

grpScore = "◆ Quality Score"
useWick    = input.bool(true, "Wick Rejection (25 pts)",     group=grpScore, tooltip="Scores the ratio of the rejection wick to total bar range at the extreme bar. Strong wicks indicate decisive rejection.")
useVolume  = input.bool(true, "Volume Spike (20 pts)",       group=grpScore, tooltip="Scores how much volume exceeded its moving average on the extreme bar. High volume confirms absorption of breakout attempts.")
useOver    = input.bool(true, "Overshoot Magnitude (15 pts)",group=grpScore, tooltip="Scores how far price pierced beyond the prior extreme, normalized by ATR. Moderate overshoots score best - tiny or extreme pierces score lower.")
useHTF     = input.bool(true, "HTF Trend Alignment (25 pts)",group=grpScore, tooltip="Mean-reversion edge - scores highest when the setup fades against the higher-timeframe trend (counter-trend mean reversion).")
useLevel   = input.bool(true, "Key Level Proximity (15 pts)",group=grpScore, tooltip="Scores proximity to round numbers and multi-bar pivot levels. Sweeps at obvious liquidity pools score higher.")
htfRes     = input.timeframe("240", "HTF for Trend", group=grpScore, tooltip="Higher timeframe used for trend alignment component.")
volLen     = input.int(20, "Volume Average Length", minval=5, maxval=100, group=grpScore)

grpTarget = "◆ Target & Stats"
targetATR   = input.float(2.5, "Target Projection (ATR)", minval=0.5, maxval=6.0, step=0.1, group=grpTarget, tooltip="Projected reversal target distance from entry, measured in ATR units. This is a reference projection - not a trade instruction.")
statsWindow = input.int(30, "Stats Sample Size", minval=10, maxval=200, group=grpTarget, tooltip="Number of most recent resolved setups used for follow-through and average-reward metrics.")

grpVis = "◆ Visual"
showZones  = input.bool(true,  "Rejection Zones",   group=grpVis, tooltip="Compact, faded markers at the sweep extreme. Fired setups keep their directional color as history; failed (invalidated) sweeps are recolored to a neutral grey so success and failure stay visually distinct.")
showLines  = input.bool(true,  "Extreme Ref Lines", group=grpVis, tooltip="Marks the swept extreme for the active setup only. Removed automatically once the setup resolves to keep the chart clean.")
showLabels = input.bool(true,  "Setup Labels",      group=grpVis)
showTarget = input.bool(true,  "Target Projection", group=grpVis, tooltip="Draws matching dashed stop and target lines for the active fired setup, each with its own price tag (Stop / Target). All removed automatically on resolution.")
labelSize  = input.string("Normal", "Label Size",   options=["Tiny","Small","Normal","Large"], group=grpVis)
projBars   = input.int(25, "Projection Length (bars)", minval=10, maxval=100, group=grpVis)
labelCooldown = input.int(12, "Label Spacing (bars)", minval=0, maxval=80, group=grpVis, tooltip="Minimum number of bars between consecutive setup labels, across both directions. Higher values reduce label crowding. Setups are still tracked in the panel and stats even when their label is spaced out.")
maxLabels     = input.int(12, "Max Drawings on Chart", minval=2, maxval=80, group=grpVis, tooltip="Keeps only the most recent setup labels and zones on the chart. Older drawings are removed automatically to prevent crowding. Setups are still tracked in the panel, follow-through and reward statistics.")

grpPanel = "◆ Panel"
showPanel = input.bool(true, "Show Panel", group=grpPanel)
panelLoc  = input.string("Top Right", "Panel Location", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=grpPanel)
panelSize = input.string("Normal", "Panel Size", options=["Tiny","Small","Normal","Large"], group=grpPanel)
helpSize  = input.string("Small", "Help Text Size", options=["Tiny","Small","Normal","Large"], group=grpPanel)

grpAlert = "◆ Alerts"
alertPending = input.bool(true, "Alert on Pending",     group=grpAlert)
alertFired   = input.bool(true, "Alert on Fired",       group=grpAlert)
alertInvalid = input.bool(false,"Alert on Invalidated", group=grpAlert)

// ═════════════════════════════════════════════════
// AGPro Color Palette
// ═════════════════════════════════════════════════
headerBg      = color.rgb(37, 99, 235)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_panelPos(p) =>
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

// Luminance-aware contrast text (target luminance 145)
f_lum(c)       => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(bg)  => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)
f_readable(bg) => f_text_on(bg)

headerText  = f_text_on(headerBg)
panelValTxt = f_readable(panelBg)

// ═════════════════════════════════════════════════
// CORE CALCULATIONS
// ═════════════════════════════════════════════════
atr     = ta.atr(14)
atrSafe = na(atr) or atr <= 0 ? syminfo.mintick * 10 : atr
volMA   = ta.sma(volume, volLen)

// 20-bar extremes (exclude current bar)
priorHigh = ta.highest(high, lookback)[1]
priorLow  = ta.lowest(low, lookback)[1]

// Sweep detection (intrabar violation)
sweptHigh = high > priorHigh
sweptLow  = low  < priorLow

// HTF trend (for alignment score)
htfClose   = request.security(syminfo.tickerid, htfRes, close, lookahead=barmerge.lookahead_off)
htfEMA50   = request.security(syminfo.tickerid, htfRes, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfTrendUp = htfClose > htfEMA50

// Key level proximity
pivotHigh = ta.pivothigh(high, 5, 5)
pivotLow  = ta.pivotlow(low, 5, 5)
var float lastPH = na
var float lastPL = na
if not na(pivotHigh)
    lastPH := pivotHigh
if not na(pivotLow)
    lastPL := pivotLow

f_roundProximity(p) =>
    if p <= 0
        10.0
    else
        scale   = math.pow(10, math.floor(math.log10(p)) - 1)
        nearest = math.round(p / scale) * scale
        math.abs(p - nearest) / atrSafe

// ═════════════════════════════════════════════════
// QUALITY SCORE
// ═════════════════════════════════════════════════
f_wickScore(isBear) =>
    rng = high - low
    if rng <= 0
        0.0
    else
        wick  = isBear ? (high - math.max(open, close)) : (math.min(open, close) - low)
        ratio = wick / rng
        math.min(25.0, ratio * 35.0)

f_volScore() =>
    if na(volMA) or volMA <= 0
        0.0
    else
        ratio = volume / volMA
        math.min(20.0, math.max(0.0, (ratio - 1.0) * 15.0))

f_overScore(isBear) =>
    over    = isBear ? (high - priorHigh) : (priorLow - low)
    overATR = over / atrSafe
    overATR <= 0 ? 0.0 : overATR < 0.2 ? overATR * 50.0 : overATR <= 1.0 ? 15.0 : math.max(0.0, 15.0 - (overATR - 1.0) * 7.5)

f_htfScore(isBear) =>
    isBear ? (htfTrendUp ? 25.0 : 10.0) : (not htfTrendUp ? 25.0 : 10.0)

f_levelScore(price) =>
    roundDist = f_roundProximity(price)
    pivotDist = not na(lastPH) and not na(lastPL) ? math.min(math.abs(price - lastPH), math.abs(price - lastPL)) / atrSafe : 10.0
    best = math.min(roundDist, pivotDist)
    best < 0.25 ? 15.0 : best < 0.5 ? 10.0 : best < 1.0 ? 5.0 : 0.0

f_score(isBear) =>
    s = 0.0
    s += useWick   ? f_wickScore(isBear) : 0.0
    s += useVolume ? f_volScore()        : 0.0
    s += useOver   ? f_overScore(isBear) : 0.0
    s += useHTF    ? f_htfScore(isBear)  : 0.0
    s += useLevel  ? f_levelScore(isBear ? high : low) : 0.0
    math.min(100.0, s)

f_grade(s) =>
    s >= 85 ? "A+" : s >= 70 ? "A" : s >= 55 ? "B" : "C"

// ═════════════════════════════════════════════════
// STATE ENGINE
// State: 0=Idle, 1=PendingBear, 2=PendingBull, 3=FiredBear, 4=FiredBull
// ═════════════════════════════════════════════════
var int   currentState = 0
var float setupExtreme = na
var float setupEntry   = na
var float setupTarget  = na
var float setupStop    = na
var float setupScore   = na
var int   setupBar     = na
var bool  ftReached    = false
var box   setupZone    = na
var line  setupRefLn   = na
var line  setupTargetLn= na
var line  setupStopLn  = na
var label tgtTag       = na
var label stopTag      = na

// Stats arrays
var array<int>   resultsArr = array.new<int>()    // 1 = target hit, 0 = stop hit
var array<float> rewardsArr = array.new<float>()  // realized R against displayed target
var array<int>   ftArr      = array.new<int>()    // 1 = reached 1R follow-through before stop

// Drawing registries — auto-cap to keep the chart clean
var int lastLabelBar = na
var array<label> labelArr = array.new<label>()
var array<box>   zoneArr  = array.new<box>()

f_push_label(lbl) =>
    array.push(labelArr, lbl)
    if array.size(labelArr) > maxLabels
        label.delete(array.shift(labelArr))

f_push_zone(bx) =>
    array.push(zoneArr, bx)
    if array.size(zoneArr) > maxLabels
        box.delete(array.shift(zoneArr))

confirmedBar = barstate.isconfirmed
// Warm-up guard — avoids unreliable/clipped setups during the first bars
canDetect = bar_index > lookback + volLen + 5 and not na(priorHigh) and not na(priorLow)

// Only allow one active setup at a time
newBearSetup = sweptHigh and currentState == 0 and canDetect
newBullSetup = sweptLow  and currentState == 0 and canDetect and not newBearSetup

// ─── New setup: initialize state & draw compact faded zone + ref line ───
if newBearSetup
    currentState := 1
    setupExtreme := high
    setupEntry   := close
    setupScore   := f_score(true)
    setupBar     := bar_index
    ftReached    := false
    setupTarget  := close - targetATR * atrSafe
    setupStop    := high + invalidateATR * atrSafe
    if showZones
        setupZone := box.new(bar_index - 2, high, bar_index + 4, priorHigh, border_color=color.new(bearColor, 55), bgcolor=color.new(bearColor, 90), border_width=1)
        f_push_zone(setupZone)
    if showLines
        setupRefLn := line.new(bar_index - lookback, priorHigh, bar_index + projBars, priorHigh, color=color.new(bearColor, 50), style=line.style_dotted, width=1)

if newBullSetup
    currentState := 2
    setupExtreme := low
    setupEntry   := close
    setupScore   := f_score(false)
    setupBar     := bar_index
    ftReached    := false
    setupTarget  := close + targetATR * atrSafe
    setupStop    := low - invalidateATR * atrSafe
    if showZones
        setupZone := box.new(bar_index - 2, priorLow, bar_index + 4, low, border_color=color.new(bullColor, 55), bgcolor=color.new(bullColor, 90), border_width=1)
        f_push_zone(setupZone)
    if showLines
        setupRefLn := line.new(bar_index - lookback, priorLow, bar_index + projBars, priorLow, color=color.new(bullColor, 50), style=line.style_dotted, width=1)

// ─── Confirmation (bar-close based → confirmed bars only) ───
isSameBar = confirmMode == "Same-Bar Close"

confirmBear = false
confirmBull = false

if currentState == 1 and confirmedBar
    if isSameBar and bar_index == setupBar
        confirmBear := close < priorHigh
    else if not isSameBar and bar_index == setupBar + 1
        confirmBear := close < priorHigh

if currentState == 2 and confirmedBar
    if isSameBar and bar_index == setupBar
        confirmBull := close > priorLow
    else if not isSameBar and bar_index == setupBar + 1
        confirmBull := close > priorLow

// Lines start a couple of bars to the right of the setup label so they never cross it
lnStart = bar_index + 2

if confirmBear
    currentState := 3
    setupEntry   := close
    setupStop    := setupExtreme + invalidateATR * atrSafe
    setupTarget  := close - targetATR * atrSafe
    ftReached    := false
    if showTarget
        setupTargetLn := line.new(lnStart, setupTarget, bar_index + projBars, setupTarget, color=color.new(bearColor, 20), style=line.style_dashed, width=2)
        setupStopLn   := line.new(lnStart, setupStop,   bar_index + projBars, setupStop,   color=color.new(neutralColor, 20), style=line.style_dashed, width=2)
        tgtTag        := label.new(bar_index + projBars, setupTarget, "Target  " + str.tostring(setupTarget, format.mintick), style=label.style_label_left, color=bearColor, textcolor=f_text_on(bearColor), size=f_size(labelSize))
        stopTag       := label.new(bar_index + projBars, setupStop,   "Stop  "   + str.tostring(setupStop,   format.mintick), style=label.style_label_left, color=neutralColor, textcolor=f_text_on(neutralColor), size=f_size(labelSize))

if confirmBull
    currentState := 4
    setupEntry   := close
    setupStop    := setupExtreme - invalidateATR * atrSafe
    setupTarget  := close + targetATR * atrSafe
    ftReached    := false
    if showTarget
        setupTargetLn := line.new(lnStart, setupTarget, bar_index + projBars, setupTarget, color=color.new(bullColor, 20), style=line.style_dashed, width=2)
        setupStopLn   := line.new(lnStart, setupStop,   bar_index + projBars, setupStop,   color=color.new(neutralColor, 20), style=line.style_dashed, width=2)
        tgtTag        := label.new(bar_index + projBars, setupTarget, "Target  " + str.tostring(setupTarget, format.mintick), style=label.style_label_left, color=bullColor, textcolor=f_text_on(bullColor), size=f_size(labelSize))
        stopTag       := label.new(bar_index + projBars, setupStop,   "Stop  "   + str.tostring(setupStop,   format.mintick), style=label.style_label_left, color=neutralColor, textcolor=f_text_on(neutralColor), size=f_size(labelSize))

// ─── Fired setup labels — anchored beyond the protective stop so the stop line never crosses the label ───
if showLabels and confirmBear and (na(lastLabelBar) or bar_index - lastLabelBar > labelCooldown)
    lblText = "Soup-Bear\n" + f_grade(setupScore) + "  " + str.tostring(math.round(setupScore)) + " / 100"
    lbl = label.new(bar_index, setupStop + atrSafe * 0.5, lblText, style=label.style_label_down, color=bearColor, textcolor=f_text_on(bearColor), size=f_size(labelSize))
    f_push_label(lbl)
    lastLabelBar := bar_index

if showLabels and confirmBull and (na(lastLabelBar) or bar_index - lastLabelBar > labelCooldown)
    lblText = "Soup-Bull\n" + f_grade(setupScore) + "  " + str.tostring(math.round(setupScore)) + " / 100"
    lbl = label.new(bar_index, setupStop - atrSafe * 0.5, lblText, style=label.style_label_up, color=bullColor, textcolor=f_text_on(bullColor), size=f_size(labelSize))
    f_push_label(lbl)
    lastLabelBar := bar_index

// ─── Follow-through tracking (reached 1R favorable before stop) ───
if currentState == 3 and not ftReached
    riskDist = setupStop - setupEntry
    if riskDist > 0 and low <= setupEntry - riskDist
        ftReached := true
if currentState == 4 and not ftReached
    riskDist = setupEntry - setupStop
    if riskDist > 0 and high >= setupEntry + riskDist
        ftReached := true

// ─── Invalidation (pending state) ───
timeoutBear = currentState == 1 and (isSameBar ? bar_index > setupBar : bar_index > setupBar + 1)
timeoutBull = currentState == 2 and (isSameBar ? bar_index > setupBar : bar_index > setupBar + 1)
invalidBear = currentState == 1 and confirmedBar and (high > setupStop or timeoutBear)
invalidBull = currentState == 2 and confirmedBar and (low  < setupStop or timeoutBull)

// ─── Resolution (fired state, confirmed bars only) ───
hitTargetBear = currentState == 3 and confirmedBar and low  <= setupTarget
hitStopBear   = currentState == 3 and confirmedBar and high >= setupStop
hitTargetBull = currentState == 4 and confirmedBar and high >= setupTarget
hitStopBull   = currentState == 4 and confirmedBar and low  <= setupStop

// Remove the active projection drawings (target/stop/ref lines + target tag) on resolution
f_clearLines() =>
    if not na(setupRefLn)
        line.delete(setupRefLn)
    if not na(setupTargetLn)
        line.delete(setupTargetLn)
    if not na(setupStopLn)
        line.delete(setupStopLn)
    if not na(tgtTag)
        label.delete(tgtTag)
    if not na(stopTag)
        label.delete(stopTag)

f_pushStats(isWin, rMult) =>
    array.push(resultsArr, isWin ? 1 : 0)
    array.push(rewardsArr, rMult)
    array.push(ftArr, ftReached ? 1 : 0)
    if array.size(resultsArr) > statsWindow
        array.shift(resultsArr)
        array.shift(rewardsArr)
        array.shift(ftArr)

// Record wins (target hit) — zone kept as faded history
if hitTargetBear or hitTargetBull
    riskBear   = setupStop  - setupEntry
    riskBull   = setupEntry - setupStop
    rewardBear = setupEntry - setupTarget
    rewardBull = setupTarget - setupEntry
    rMult = hitTargetBear ? (riskBear > 0 ? rewardBear / riskBear : 0.0) : (riskBull > 0 ? rewardBull / riskBull : 0.0)
    f_pushStats(true, rMult)
    f_clearLines()
    currentState  := 0
    setupBar      := na
    setupZone     := na
    setupRefLn    := na
    setupTargetLn := na
    setupStopLn   := na
    tgtTag        := na
    stopTag       := na

// Record losses (stop hit) — zone kept as faded history
if hitStopBear or hitStopBull
    f_pushStats(false, -1.0)
    f_clearLines()
    currentState  := 0
    setupBar      := na
    setupZone     := na
    setupRefLn    := na
    setupTargetLn := na
    setupStopLn   := na
    tgtTag        := na
    stopTag       := na

// Invalidated (never fired) — recolor its zone to a neutral faded "failed" marker, not counted in stats
if invalidBear or invalidBull
    f_clearLines()
    if not na(setupZone)
        box.set_bgcolor(setupZone, color.new(panelLabelCol, 90))
        box.set_border_color(setupZone, color.new(panelLabelCol, 65))
    currentState := 0
    setupBar     := na
    setupZone    := na
    setupRefLn   := na

// ═════════════════════════════════════════════════
// PANEL
// ═════════════════════════════════════════════════
f_stateText(s) =>
    s == 1 ? "Pending Bear" : s == 2 ? "Pending Bull" : s == 3 ? "Fired Bear" : s == 4 ? "Fired Bull" : "Idle"

f_stateCol(s) =>
    s == 1 or s == 3 ? bearColor : s == 2 or s == 4 ? bullColor : panelValTxt

f_actionText(s) =>
    s == 1 or s == 2 ? "Await confirm" : s == 3 ? "Manage short" : s == 4 ? "Manage long" : "Stand aside"

var table panel = na
if barstate.islast and showPanel
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(panelLoc), 2, 12, border_width=1, border_color=panelBorder, frame_color=panelBorder, frame_width=1)

    table.cell(panel, 0, 0, "AG Pro Turtle Soup Reversal Map", bgcolor=headerBg, text_color=headerText, text_size=f_size(panelSize), text_halign=text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Status",                  bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 1, f_stateText(currentState), bgcolor=panelBg, text_color=f_stateCol(currentState), text_size=f_size(panelSize), text_halign=text.align_right)

    scoreTxt = currentState == 0 or na(setupScore) ? "-" : f_grade(setupScore) + "  " + str.tostring(math.round(setupScore)) + " / 100"
    table.cell(panel, 0, 2, "Setup Quality", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 2, scoreTxt,        bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    table.cell(panel, 0, 3, "Next Action",              bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 3, f_actionText(currentState), bgcolor=panelBg, text_color=f_stateCol(currentState), text_size=f_size(panelSize), text_halign=text.align_right)

    stTxt = currentState == 0 or na(setupStop) or na(setupTarget) ? "-" : str.tostring(setupStop, format.mintick) + " → " + str.tostring(setupTarget, format.mintick)
    table.cell(panel, 0, 4, "Stop / Target", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 4, stTxt,           bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    rrTxt = "-"
    if currentState != 0 and not na(setupStop) and not na(setupTarget) and not na(setupEntry)
        isBearSide = currentState == 1 or currentState == 3
        riskD   = isBearSide ? setupStop - setupEntry : setupEntry - setupStop
        rewardD = isBearSide ? setupEntry - setupTarget : setupTarget - setupEntry
        rrTxt := riskD > 0 ? "1 : " + str.tostring(rewardD / riskD, "#.#") : "-"
    table.cell(panel, 0, 5, "Risk : Reward", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 5, rrTxt,           bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    nFt = array.size(ftArr)
    ftWins = 0
    for i = 0 to nFt - 1
        ftWins += array.get(ftArr, i)
    ftTxt = nFt > 0 ? str.tostring(math.round(ftWins / nFt * 100)) + "%  (" + str.tostring(nFt) + ")" : "- (0)"
    table.cell(panel, 0, 6, "Follow-Through", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 6, ftTxt,            bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    nRew = array.size(rewardsArr)
    sumR = 0.0
    for i = 0 to nRew - 1
        sumR += array.get(rewardsArr, i)
    avgR = nRew > 0 ? sumR / nRew : 0.0
    table.cell(panel, 0, 7, "Avg R", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 7, nRew > 0 ? str.tostring(avgR, "#.##") + "R" : "-", bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    table.cell(panel, 0, 8, "Lookback", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 8, str.tostring(lookback) + " bars", bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    table.cell(panel, 0, 9, "Confirmation", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(panelSize), text_halign=text.align_left)
    table.cell(panel, 1, 9, confirmMode,    bgcolor=panelBg, text_color=panelValTxt, text_size=f_size(panelSize), text_halign=text.align_right)

    table.cell(panel, 0, 10, "Read: A+ best · B+ tradeable · score 0–100", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(helpSize), text_halign=text.align_left)
    table.merge_cells(panel, 0, 10, 1, 10)
    table.cell(panel, 0, 11, "Follow-Through = reached 1R before stop", bgcolor=panelBg, text_color=panelLabelCol, text_size=f_size(helpSize), text_halign=text.align_left)
    table.merge_cells(panel, 0, 11, 1, 11)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
if alertPending and (newBearSetup or newBullSetup)
    dir = newBearSetup ? "Bear" : "Bull"
    alert("Turtle Soup Pending " + dir + " | Grade " + f_grade(setupScore) + " | " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

if alertFired and (confirmBear or confirmBull)
    dir = confirmBear ? "Bear" : "Bull"
    alert("Turtle Soup Fired " + dir + " | Grade " + f_grade(setupScore) + " | " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

if alertInvalid and (invalidBear or invalidBull)
    alert("Turtle Soup Invalidated | " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````
