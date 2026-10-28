# Harmonic Ratio Scanner [forexobroker]

- url: https://www.tradingview.com/script/e9urGRku-Harmonic-Ratio-Scanner-forexobroker/
- type: indicator
- pine_id: PUB;830c5a9386d34d39bf623a9a3a6dc3ec
- version: 1.0

## Description

Harmonic Ratio Scanner detects simple harmonic ratios between consecutive price swings. Instead of waiting for rare full XABCD patterns, this indicator finds individual Fibonacci retracement ratios that occur frequently and provide actionable trade setups.

🔶 WHAT MAKES THIS UNIQUE

Traditional harmonic scanners require complete 5-point patterns (Gartley, Butterfly, Bat, Crab). These are complex, rare, and often subjective. The Harmonic Ratio Scanner takes a fundamentally different approach: it measures the ratio between any two consecutive swings.

If swing B retraces 61.8% of swing A, that single ratio represents natural market rhythm at a Fibonacci level. These individual ratios occur far more frequently than full patterns, giving traders more opportunities while still capturing the core principle of harmonic trading.

🔶 HOW IT WORKS

1. The indicator detects swing highs and lows using pivot logic
2. It stores the most recent swings in memory
3. For each pair of consecutive swings, it calculates the retracement ratio
4. If the ratio matches a known harmonic value (within configurable tolerance), a harmonic ratio is detected
5. The swing direction determines if the ratio is bullish or bearish

🔶 DETECTABLE RATIOS

- 38.2% - Shallow retracement (continuation likely)
- 50.0% - Half retracement (optional, disabled by default)
- 61.8% - Golden ratio (highest probability)
- 78.6% - Deep retracement (strong reversal zone)

Each ratio can be individually enabled or disabled.

🔶 SIGNAL LOGIC

BUY signals fire when:
- A bullish harmonic ratio is detected (swing low forming after swing high)
- Volume confirms the setup (above 20-period SMA)
- Bar is confirmed (no repainting)

SELL signals fire under inverse conditions.

A 15-bar cooldown prevents signal clustering.

🔶 VISUAL GUIDE

- Colored lines connect the detected harmonic swings
- Ratio percentage labels appear at swing midpoints
- Green lines and arrows for bullish ratios
- Pink lines and arrows for bearish ratios
- Info table displays the last detected ratio, direction, and active filters

🔶 RECOMMENDED SETTINGS

- Swing trading (1H-4H): Default settings work well
- Scalping (5m-15m): Reduce swing lookback to 3, increase tolerance to 5%
- Position trading (Daily): Increase swing lookback to 8-10
- For more signals: Enable the 50% ratio
- For higher quality: Disable 38.2%, keep only 61.8% and 78.6%

🔶 ALERTS

9 alert conditions available including buy/sell signals, ratio detection, bullish/bearish ratio alerts, and volume surge notifications. JSON-formatted alerts supported for webhook integration.

🔶 LIMITATIONS

- Swing detection requires lookback bars to confirm. There is an inherent delay equal to the swing lookback setting.
- Not all harmonic ratios lead to reversals. The ratio identifies a zone of interest, not a guaranteed outcome.
- On very low timeframes, swing noise may produce false ratios. Increase the minimum swing size filter.
- This indicator does not repaint. Swings are confirmed only after the lookback period completes.
- Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Harmonic Ratio Scanner [forexobroker]", shorttitle="HRS [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ─────────────────────────────────────────────────────────────────
g_swing = "Swing Detection"
swingLen    = input.int(5, "Swing Lookback", minval=2, maxval=20, group=g_swing, tooltip="Number of bars to confirm a swing high/low")
minSwingPts = input.float(0.5, "Min Swing Size (ATR mult)", minval=0.1, maxval=5.0, step=0.1, group=g_swing, tooltip="Minimum swing size as ATR multiple to filter noise")

g_ratio = "Harmonic Ratios"
tol         = input.float(3.0, "Ratio Tolerance (%)", minval=0.5, maxval=10.0, step=0.5, group=g_ratio, tooltip="Allowed deviation from perfect harmonic ratio")
use618      = input.bool(true, "Detect 61.8% Ratio", group=g_ratio)
use786      = input.bool(true, "Detect 78.6% Ratio", group=g_ratio)
use382      = input.bool(true, "Detect 38.2% Ratio", group=g_ratio)
use500      = input.bool(false, "Detect 50.0% Ratio", group=g_ratio)

g_signal = "Signal Settings"
cooldownBars = input.int(15, "Signal Cooldown", minval=5, maxval=50, group=g_signal, tooltip="Minimum bars between signals")
volSmaLen    = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_signal)

g_vis = "Visuals"
showTable    = input.bool(true, "Show Info Table", group=g_vis)
showSwings   = input.bool(true, "Draw Swing Lines", group=g_vis)
showRatioLbl = input.bool(true, "Show Ratio Labels", group=g_vis)

// ─── COLORS ─────────────────────────────────────────────────────────────────
color C_CYAN   = #00d4ff
color C_PINK   = #ff2d78
color C_GREEN  = #39ff14
color C_PURPLE = #a855f7
color C_ORANGE = #ffaa00

// ─── SWING DETECTION ────────────────────────────────────────────────────────
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

atrVal = ta.atr(14)
minSwingSize = atrVal * minSwingPts

// Store recent swings using arrays
var array<float> swingPrices = array.new_float(0)
var array<int>   swingBars   = array.new_int(0)
var array<bool>  swingIsHigh = array.new_bool(0)

maxSwings = 10

if not na(swingHigh)
    array.unshift(swingPrices, swingHigh)
    array.unshift(swingBars, bar_index - swingLen)
    array.unshift(swingIsHigh, true)
    if array.size(swingPrices) > maxSwings
        array.pop(swingPrices)
        array.pop(swingBars)
        array.pop(swingIsHigh)

if not na(swingLow)
    array.unshift(swingPrices, swingLow)
    array.unshift(swingBars, bar_index - swingLen)
    array.unshift(swingIsHigh, false)
    if array.size(swingPrices) > maxSwings
        array.pop(swingPrices)
        array.pop(swingBars)
        array.pop(swingIsHigh)

// ─── HARMONIC RATIO CHECK ───────────────────────────────────────────────────
isHarmonicRatio(float ratio) =>
    bool result = false
    tolDec = tol / 100.0
    if use618 and math.abs(ratio - 0.618) < tolDec
        result := true
    if use786 and math.abs(ratio - 0.786) < tolDec
        result := true
    if use382 and math.abs(ratio - 0.382) < tolDec
        result := true
    if use500 and math.abs(ratio - 0.500) < tolDec
        result := true
    result

getRatioName(float ratio) =>
    tolDec = tol / 100.0
    string name = ""
    if math.abs(ratio - 0.618) < tolDec
        name := "61.8%"
    else if math.abs(ratio - 0.786) < tolDec
        name := "78.6%"
    else if math.abs(ratio - 0.382) < tolDec
        name := "38.2%"
    else if math.abs(ratio - 0.500) < tolDec
        name := "50.0%"
    name

// ─── SCAN FOR HARMONIC RATIOS ───────────────────────────────────────────────
var float lastRatio     = na
var string lastRatioName = ""
var bool lastRatioBull  = false
var int lastRatioBar    = 0

foundRatio     = false
ratioVal       = 0.0
ratioName      = ""
ratioBullish   = false
ratioSwingABar = 0
ratioSwingAPrice = 0.0
ratioSwingBBar = 0
ratioSwingBPrice = 0.0
ratioSwingCBar = 0
ratioSwingCPrice = 0.0

if array.size(swingPrices) >= 3
    for i = 0 to math.min(array.size(swingPrices) - 3, 4)
        if foundRatio
            break
        p0 = array.get(swingPrices, i)
        p1 = array.get(swingPrices, i + 1)
        p2 = array.get(swingPrices, i + 2)
        b0 = array.get(swingBars, i)
        b1 = array.get(swingBars, i + 1)
        b2 = array.get(swingBars, i + 2)
        h0 = array.get(swingIsHigh, i)
        h1 = array.get(swingIsHigh, i + 1)
        swingA = math.abs(p1 - p2)
        swingB = math.abs(p0 - p1)
        if swingA > minSwingSize and swingB > 0
            ratio = swingB / swingA
            if isHarmonicRatio(ratio)
                foundRatio := true
                ratioVal := ratio
                ratioName := getRatioName(ratio)
                ratioBullish := h0 == false and h1 == true
                ratioSwingABar := b2
                ratioSwingAPrice := p2
                ratioSwingBBar := b1
                ratioSwingBPrice := p1
                ratioSwingCBar := b0
                ratioSwingCPrice := p0

newRatioDetected = foundRatio and ratioSwingCBar != lastRatioBar
if newRatioDetected
    lastRatio := ratioVal
    lastRatioName := ratioName
    lastRatioBull := ratioBullish
    lastRatioBar := ratioSwingCBar

// ─── DRAW SWING LINES AND RATIO LABELS ─────────────────────────────────────
if newRatioDetected and showSwings
    lineCol = ratioBullish ? C_GREEN : C_PINK
    line.new(ratioSwingABar, ratioSwingAPrice, ratioSwingBBar, ratioSwingBPrice, color=color.new(lineCol, 40), width=2)
    line.new(ratioSwingBBar, ratioSwingBPrice, ratioSwingCBar, ratioSwingCPrice, color=color.new(lineCol, 40), width=2)

if newRatioDetected and showRatioLbl
    lblCol = ratioBullish ? C_GREEN : C_PINK
    midBar = math.round((ratioSwingBBar + ratioSwingCBar) / 2)
    midPrice = (ratioSwingBPrice + ratioSwingCPrice) / 2
    label.new(midBar, midPrice, ratioName, color=color.new(lblCol, 60), textcolor=color.white, style=label.style_label_center, size=size.small)

// ─── SIGNAL LOGIC ───────────────────────────────────────────────────────────
var int lastSignalBar = 0
barsSinceSignal = bar_index - lastSignalBar
cooldownOk      = barsSinceSignal >= cooldownBars
volSma          = ta.sma(volume, volSmaLen)
volFilter       = volume > volSma

buySignal  = newRatioDetected and ratioBullish and cooldownOk and volFilter and barstate.isconfirmed
sellSignal = newRatioDetected and not ratioBullish and cooldownOk and volFilter and barstate.isconfirmed

if buySignal
    lastSignalBar := bar_index
if sellSignal
    lastSignalBar := bar_index

// ─── ALERTS (JSON in if-blocks) ─────────────────────────────────────────────
if buySignal
    alert('{"indicator":"Harmonic Ratio Scanner","signal":"BUY","ticker":"' + syminfo.ticker + '","interval":"' + timeframe.period + '","close":' + str.tostring(close) + ',"ratio":"' + ratioName + '"}', alert.freq_once_per_bar_close)
    alert("HRS BUY signal on " + syminfo.ticker + " - " + ratioName + " ratio at " + str.tostring(close), alert.freq_once_per_bar_close)

if sellSignal
    alert('{"indicator":"Harmonic Ratio Scanner","signal":"SELL","ticker":"' + syminfo.ticker + '","interval":"' + timeframe.period + '","close":' + str.tostring(close) + ',"ratio":"' + ratioName + '"}', alert.freq_once_per_bar_close)
    alert("HRS SELL signal on " + syminfo.ticker + " - " + ratioName + " ratio at " + str.tostring(close), alert.freq_once_per_bar_close)

// ─── 3-LAYER GLOW ARROWS ───────────────────────────────────────────────────
plotshape(buySignal, "BUY Glow3", shape.triangleup, location.belowbar, color.new(C_GREEN, 70), size=size.huge)
plotshape(buySignal, "BUY Glow2", shape.triangleup, location.belowbar, color.new(C_GREEN, 40), size=size.large)
plotshape(buySignal, "BUY Signal", shape.triangleup, location.belowbar, color.new(C_GREEN, 0), size=size.normal, text="BUY", textcolor=color.white)

plotshape(sellSignal, "SELL Glow3", shape.triangledown, location.abovebar, color.new(C_PINK, 70), size=size.huge)
plotshape(sellSignal, "SELL Glow2", shape.triangledown, location.abovebar, color.new(C_PINK, 40), size=size.large)
plotshape(sellSignal, "SELL Signal", shape.triangledown, location.abovebar, color.new(C_PINK, 0), size=size.normal, text="SELL", textcolor=color.white)

// ─── BAR COLOR ──────────────────────────────────────────────────────────────
barcolor(buySignal ? C_GREEN : sellSignal ? C_PINK : na)

// ─── SIGNAL LABELS ──────────────────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "BUY\n" + ratioName + " Ratio\nHarmonic", color=C_GREEN, textcolor=color.white, style=label.style_label_up, size=size.small)

if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "SELL\n" + ratioName + " Ratio\nHarmonic", color=C_PINK, textcolor=color.white, style=label.style_label_down, size=size.small)

// ─── INFO TABLE ─────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table infoTbl = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 80), border_color=color.new(color.gray, 60), border_width=1)
    table.cell(infoTbl, 0, 0, "Harmonic Ratio Scanner", text_color=C_CYAN, text_size=size.small)
    table.cell(infoTbl, 1, 0, "", text_color=C_CYAN, text_size=size.small)
    table.merge_cells(infoTbl, 0, 0, 1, 0)
    table.cell(infoTbl, 0, 1, "Last Ratio", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTbl, 1, 1, na(lastRatio) ? "---" : lastRatioName, text_color=C_ORANGE, text_size=size.tiny)
    table.cell(infoTbl, 0, 2, "Direction", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTbl, 1, 2, na(lastRatio) ? "---" : (lastRatioBull ? "BULLISH" : "BEARISH"), text_color=lastRatioBull ? C_GREEN : C_PINK, text_size=size.tiny)
    table.cell(infoTbl, 0, 3, "Tolerance", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTbl, 1, 3, str.tostring(tol, "#.#") + "%", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 0, 4, "Ratios Active", text_color=color.gray, text_size=size.tiny)
    activeStr = (use618 ? "61.8 " : "") + (use786 ? "78.6 " : "") + (use382 ? "38.2 " : "") + (use500 ? "50.0" : "")
    table.cell(infoTbl, 1, 4, activeStr, text_color=C_PURPLE, text_size=size.tiny)

// ─── ALERT CONDITIONS (const strings) ───────────────────────────────────────
alertcondition(buySignal, "HRS Buy Signal", "Harmonic Ratio Scanner BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal, "HRS Sell Signal", "Harmonic Ratio Scanner SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal, "HRS Any Signal", "Harmonic Ratio Scanner signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(newRatioDetected, "HRS Ratio Detected", "Harmonic ratio detected on {{ticker}} {{interval}} at {{close}}")
alertcondition(newRatioDetected and ratioBullish, "HRS Bullish Ratio", "Bullish harmonic ratio on {{ticker}} {{interval}} at {{close}}")
alertcondition(newRatioDetected and not ratioBullish, "HRS Bearish Ratio", "Bearish harmonic ratio on {{ticker}} {{interval}} at {{close}}")
alertcondition(foundRatio, "HRS Active Ratio", "Active harmonic ratio on {{ticker}} {{interval}} at {{close}}")
alertcondition(volFilter, "HRS Volume Surge", "Volume above average on {{ticker}} {{interval}} at {{close}}")
alertcondition(not na(swingHigh) or not na(swingLow), "HRS Swing Detected", "Swing point detected on {{ticker}} {{interval}} at {{close}}")
````
