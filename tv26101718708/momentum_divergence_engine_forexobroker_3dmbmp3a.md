# Momentum Divergence Engine [forexobroker]

- url: https://www.tradingview.com/script/3DmBmP3a-Momentum-Divergence-Engine-forexobroker/
- type: indicator
- pine_id: PUB;ff4d91205c5e4fe097c0090c766630fb
- version: 1.0

## Description

Momentum Divergence Engine detects all four types of RSI divergence automatically using mathematically confirmed pivot points. Rather than forcing traders to visually compare RSI swings against price swings -- a subjective and error-prone process -- this indicator codifies the exact rules for regular and hidden divergence, then layers volume confirmation, trend filtering, and a signal cooldown to reduce noise.

The tool is designed for swing traders and intraday traders who use divergence as a core part of their decision-making. It works on any instrument and any timeframe, providing a systematic framework that removes the guesswork from divergence detection while keeping the trader in full control of sensitivity settings.

🔶 CONCEPTS

Divergence occurs when price and an oscillator (here, RSI) disagree about the direction of momentum. Regular divergence suggests a potential reversal: price makes a new extreme while RSI fails to confirm it, indicating that the momentum behind the move is weakening. Hidden divergence suggests continuation: price makes a shallower pullback while RSI makes a deeper one, signaling that the underlying trend still has strength. Understanding the distinction between these four patterns -- regular bullish, regular bearish, hidden bullish, and hidden bearish -- is essential for interpreting signals correctly.

🔶 HOW IT WORKS

- Calculates RSI and identifies pivot highs and pivot lows on both price and RSI using configurable left/right bar counts
- Compares the current pivot to the previous pivot, requiring both to fall within a maximum bar distance to filter out stale comparisons
- Classifies the relationship as regular bullish (price lower low, RSI higher low), regular bearish (price higher high, RSI lower high), hidden bullish (price higher low, RSI lower low), or hidden bearish (price lower high, RSI higher high)
- Applies a triple filter before firing a signal: volume must exceed its SMA, price must align with the EMA trend direction, and a configurable cooldown must have elapsed since the last signal
- Draws dashed lines on the price chart connecting the two pivot points that formed the divergence

🔶 HOW TO USE

1. Add the indicator to any chart -- it begins scanning for divergences immediately
2. Watch for glowing BUY/SELL arrows, which appear only after all filters pass on a confirmed bar
3. Check the dashboard in the top-right corner for current RSI value, zone (overbought/oversold/neutral), last divergence type, strength, trend direction, and volume status
4. Use signal labels for quick context: each label shows the divergence type, RSI reading, divergence strength in RSI points, and relative volume
5. Combine with your own support/resistance levels or other confluence tools for entry timing, and always define your stop-loss before entering a trade

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Detects all four divergence types: regular bullish, regular bearish, hidden bullish, hidden bearish
- Visual divergence lines drawn directly on the price chart connecting the two pivots
- Real-time dashboard showing RSI zone, divergence type, strength, trend, volume status, and cooldown timer

🔶 SETTINGS GUIDE

- RSI Length -- Period for RSI calculation (default 14)
- Pivot Left Bars -- Number of bars to the left required to confirm a pivot point
- Pivot Right Bars -- Number of bars to the right required to confirm a pivot point
- Max Bars Between Pivots -- Maximum distance between two pivots for a valid divergence comparison
- Trend EMA Length -- Period for the EMA used in the trend direction filter
- Signal Cooldown -- Minimum bars between consecutive signals to prevent clustering
- Volume SMA Length -- Period for the volume simple moving average used in the volume filter
- Require EMA Trend Filter -- When enabled, bullish divergence requires price near or below EMA, bearish near or above
- Show Regular Divergence -- Toggle regular divergence detection on or off
- Show Hidden Divergence -- Toggle hidden divergence detection on or off
- Show Dashboard -- Toggle the real-time info table
- Show Divergence Lines on Price -- Toggle the dashed connecting lines between pivots

🔶 ALERTS

- Buy Signal -- Bullish divergence confirmed with all filters
- Sell Signal -- Bearish divergence confirmed with all filters
- Any Signal -- Either bullish or bearish divergence
- Regular Bull Div -- Regular bullish divergence detected (before filtering)
- Regular Bear Div -- Regular bearish divergence detected (before filtering)
- Hidden Bull Div -- Hidden bullish divergence detected (before filtering)
- Hidden Bear Div -- Hidden bearish divergence detected (before filtering)
- RSI Overbought -- RSI crosses above 70
- RSI Oversold -- RSI crosses below 30

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past divergence patterns do not guarantee future price reversals or continuations.
- Pivot detection requires bars to the right to confirm, so signals are inherently delayed by the Pivot Right Bars setting.
- Hidden divergence signals can be less reliable in choppy, range-bound markets.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Momentum Divergence Engine [forexobroker]", shorttitle="MDE [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
string g_rsi     = "RSI Settings"
int    rsiLen    = input.int(14, "RSI Length", minval=2, group=g_rsi)
int    pivotLeft = input.int(5, "Pivot Left Bars", minval=2, group=g_rsi, tooltip="Bars to the left of pivot for divergence detection")
int    pivotRight = input.int(3, "Pivot Right Bars", minval=2, group=g_rsi, tooltip="Bars to the right confirming pivot")
int    maxBars   = input.int(60, "Max Bars Between Pivots", minval=10, group=g_rsi, tooltip="Maximum distance between two pivots for divergence")

string g_filt    = "Filters"
int    emaLen    = input.int(50, "Trend EMA Length", minval=5, group=g_filt)
int    cooldown  = input.int(15, "Signal Cooldown (bars)", minval=1, group=g_filt)
int    volSmaLen = input.int(20, "Volume SMA Length", minval=1, group=g_filt)
bool   reqTrend  = input.bool(true, "Require EMA Trend Filter", group=g_filt, tooltip="Bull div requires price near/below EMA; bear div near/above")

string g_div     = "Divergence Types"
bool   showReg   = input.bool(true, "Show Regular Divergence", group=g_div)
bool   showHid   = input.bool(true, "Show Hidden Divergence", group=g_div)

string g_vis     = "Visuals"
bool   showTable = input.bool(true, "Show Dashboard", group=g_vis)
bool   showDivLines = input.bool(true, "Show Divergence Lines on Price", group=g_vis)

// ─── COLORS ───────────────────────────────────────────────────────────────────
color neonCyan   = #00d4ff
color neonPink   = #ff2d78
color neonGreen  = #39ff14
color neonPurple = #a855f7
color neonGold   = #ffaa00

// ─── RSI CALCULATION ──────────────────────────────────────────────────────────
float rsiVal     = ta.rsi(close, rsiLen)

// ─── PIVOT DETECTION ──────────────────────────────────────────────────────────
float pricePivHi = ta.pivothigh(high, pivotLeft, pivotRight)
float pricePivLo = ta.pivotlow(low, pivotLeft, pivotRight)
float rsiPivHi   = ta.pivothigh(rsiVal, pivotLeft, pivotRight)
float rsiPivLo   = ta.pivotlow(rsiVal, pivotLeft, pivotRight)

// ─── STORE PREVIOUS PIVOTS ───────────────────────────────────────────────────
var float prevPriceHi  = na
var float prevRsiHi    = na
var int   prevHiBar    = na
var float prevPriceLo  = na
var float prevRsiLo    = na
var int   prevLoBar    = na

var float currPriceHi  = na
var float currRsiHi    = na
var int   currHiBar    = na
var float currPriceLo  = na
var float currRsiLo    = na
var int   currLoBar    = na

// ─── UPDATE PIVOTS ────────────────────────────────────────────────────────────
if not na(pricePivHi) and not na(rsiPivHi)
    prevPriceHi := currPriceHi
    prevRsiHi   := currRsiHi
    prevHiBar   := currHiBar
    currPriceHi := pricePivHi
    currRsiHi   := rsiPivHi
    currHiBar   := bar_index - pivotRight

if not na(pricePivLo) and not na(rsiPivLo)
    prevPriceLo := currPriceLo
    prevRsiLo   := currRsiLo
    prevLoBar   := currLoBar
    currPriceLo := pricePivLo
    currRsiLo   := rsiPivLo
    currLoBar   := bar_index - pivotRight

// ─── DIVERGENCE DETECTION ─────────────────────────────────────────────────────
bool regBullDiv = false
bool regBearDiv = false
bool hidBullDiv = false
bool hidBearDiv = false

string divType = ""
float divStrength = 0.0

// Regular Bullish: Price lower low, RSI higher low
if showReg and not na(prevPriceLo) and not na(currPriceLo) and not na(prevRsiLo) and not na(currRsiLo)
    bool priceLowerLow = currPriceLo < prevPriceLo
    bool rsiHigherLow  = currRsiLo > prevRsiLo
    bool withinRange   = not na(currLoBar) and not na(prevLoBar) and (currLoBar - prevLoBar) <= maxBars
    if priceLowerLow and rsiHigherLow and withinRange and not na(pricePivLo)
        regBullDiv := true
        divType := "REGULAR BULL"
        divStrength := math.abs(currRsiLo - prevRsiLo)

// Regular Bearish: Price higher high, RSI lower high
if showReg and not na(prevPriceHi) and not na(currPriceHi) and not na(prevRsiHi) and not na(currRsiHi)
    bool priceHigherHigh = currPriceHi > prevPriceHi
    bool rsiLowerHigh    = currRsiHi < prevRsiHi
    bool withinRange     = not na(currHiBar) and not na(prevHiBar) and (currHiBar - prevHiBar) <= maxBars
    if priceHigherHigh and rsiLowerHigh and withinRange and not na(pricePivHi)
        regBearDiv := true
        divType := "REGULAR BEAR"
        divStrength := math.abs(currRsiHi - prevRsiHi)

// Hidden Bullish: Price higher low, RSI lower low
if showHid and not na(prevPriceLo) and not na(currPriceLo) and not na(prevRsiLo) and not na(currRsiLo)
    bool priceHigherLow = currPriceLo > prevPriceLo
    bool rsiLowerLow    = currRsiLo < prevRsiLo
    bool withinRange    = not na(currLoBar) and not na(prevLoBar) and (currLoBar - prevLoBar) <= maxBars
    if priceHigherLow and rsiLowerLow and withinRange and not na(pricePivLo) and not regBullDiv
        hidBullDiv := true
        divType := "HIDDEN BULL"
        divStrength := math.abs(currRsiLo - prevRsiLo)

// Hidden Bearish: Price lower high, RSI higher high
if showHid and not na(prevPriceHi) and not na(currPriceHi) and not na(prevRsiHi) and not na(currRsiHi)
    bool priceLowerHigh = currPriceHi < prevPriceHi
    bool rsiHigherHigh  = currRsiHi > prevRsiHi
    bool withinRange    = not na(currHiBar) and not na(prevHiBar) and (currHiBar - prevHiBar) <= maxBars
    if priceLowerHigh and rsiHigherHigh and withinRange and not na(pricePivHi) and not regBearDiv
        hidBearDiv := true
        divType := "HIDDEN BEAR"
        divStrength := math.abs(currRsiHi - prevRsiHi)

// ─── FILTERS ──────────────────────────────────────────────────────────────────
float emaVal     = ta.ema(close, emaLen)
float volSma     = ta.sma(volume, volSmaLen)
bool  volConfirm = volume > volSma

var int lastSigBar = 0
int barsSinceSig   = bar_index - lastSigBar
bool cooldownOk    = barsSinceSig >= cooldown

bool trendOkBull = reqTrend ? close <= emaVal * 1.02 : true
bool trendOkBear = reqTrend ? close >= emaVal * 0.98 : true

// ─── FINAL SIGNALS ────────────────────────────────────────────────────────────
bool bullSignal = (regBullDiv or hidBullDiv) and barstate.isconfirmed and volConfirm and cooldownOk and trendOkBull
bool bearSignal = (regBearDiv or hidBearDiv) and barstate.isconfirmed and volConfirm and cooldownOk and trendOkBear

if bullSignal or bearSignal
    lastSigBar := bar_index

// ─── DIVERGENCE LINES ON PRICE ────────────────────────────────────────────────
if showDivLines and bullSignal and not na(prevLoBar) and not na(currLoBar)
    line.new(prevLoBar, prevPriceLo, currLoBar, currPriceLo, color=neonGreen, width=2, style=line.style_dashed)

if showDivLines and bearSignal and not na(prevHiBar) and not na(currHiBar)
    line.new(prevHiBar, prevPriceHi, currHiBar, currPriceHi, color=neonPink, width=2, style=line.style_dashed)

// ─── EMA PLOT ─────────────────────────────────────────────────────────────────
plot(emaVal, "Trend EMA", color=color.new(neonPurple, 50), linewidth=1)

// ─── 3-LAYER GLOW ARROWS ─────────────────────────────────────────────────────
plotshape(bullSignal, "Buy Glow 3", shape.triangleup, location.belowbar, color.new(neonGreen, 70), size=size.huge)
plotshape(bullSignal, "Buy Glow 2", shape.triangleup, location.belowbar, color.new(neonGreen, 40), size=size.large)
plotshape(bullSignal, "Buy Signal",  shape.triangleup, location.belowbar, neonGreen, size=size.normal, text="BUY", textcolor=neonGreen)

plotshape(bearSignal, "Sell Glow 3", shape.triangledown, location.abovebar, color.new(neonPink, 70), size=size.huge)
plotshape(bearSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(neonPink, 40), size=size.large)
plotshape(bearSignal, "Sell Signal",  shape.triangledown, location.abovebar, neonPink, size=size.normal, text="SELL", textcolor=neonPink)

// ─── BARCOLOR ─────────────────────────────────────────────────────────────────
barcolor(bullSignal ? neonGreen : bearSignal ? neonPink : na, title="Signal Bar Color")

// ─── SIGNAL LABELS ────────────────────────────────────────────────────────────
if bullSignal
    label.new(bar_index, low, divType + "\nRSI: " + str.tostring(rsiVal, "#.0") + "\nStrength: " + str.tostring(divStrength, "#.0") + "\nVol: " + str.tostring(volume / volSma, "#.0") + "x", style=label.style_label_up, color=color.new(neonGreen, 20), textcolor=color.white, size=size.small)

if bearSignal
    label.new(bar_index, high, divType + "\nRSI: " + str.tostring(rsiVal, "#.0") + "\nStrength: " + str.tostring(divStrength, "#.0") + "\nVol: " + str.tostring(volume / volSma, "#.0") + "x", style=label.style_label_down, color=color.new(neonPink, 20), textcolor=color.white, size=size.small)

// ─── DASHBOARD TABLE ──────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.white, 80))
    string rsiZone = rsiVal > 70 ? "OVERBOUGHT" : rsiVal < 30 ? "OVERSOLD" : "NEUTRAL"
    color rsiClr = rsiVal > 70 ? neonPink : rsiVal < 30 ? neonGreen : neonGold
    string lastDiv = divType != "" ? divType : "NONE"
    color lastDivClr = str.contains(divType, "BULL") ? neonGreen : str.contains(divType, "BEAR") ? neonPink : color.gray
    string trendDir = close > emaVal ? "BULLISH" : "BEARISH"
    color trendClr = close > emaVal ? neonGreen : neonPink

    table.cell(dash, 0, 0, "MDE", text_color=neonCyan, text_size=size.normal, bgcolor=color.new(color.black, 30))
    table.cell(dash, 1, 0, "Engine", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 30))
    table.cell(dash, 0, 1, "RSI", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(rsiVal, "#.0") + " (" + rsiZone + ")", text_color=rsiClr, text_size=size.small)
    table.cell(dash, 0, 2, "Divergence", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, lastDiv, text_color=lastDivClr, text_size=size.small)
    table.cell(dash, 0, 3, "Strength", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, divStrength > 0 ? str.tostring(divStrength, "#.0") + " pts" : "—", text_color=neonGold, text_size=size.small)
    table.cell(dash, 0, 4, "Trend", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, trendDir, text_color=trendClr, text_size=size.small)
    table.cell(dash, 0, 5, "Volume", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, volConfirm ? "PASS" : "FAIL", text_color=volConfirm ? neonGreen : neonPink, text_size=size.small)
    table.cell(dash, 0, 6, "Cooldown", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, cooldownOk ? "READY" : str.tostring(cooldown - barsSinceSig) + " bars", text_color=cooldownOk ? neonGreen : neonGold, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if bullSignal
    alert('{"indicator":"MDE","signal":"BUY","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"rsi":' + str.tostring(rsiVal) + ',"div_type":"' + divType + '","strength":' + str.tostring(divStrength) + '}', alert.freq_once_per_bar_close)
    alert("MDE Bullish Divergence on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if bearSignal
    alert('{"indicator":"MDE","signal":"SELL","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"rsi":' + str.tostring(rsiVal) + ',"div_type":"' + divType + '","strength":' + str.tostring(divStrength) + '}', alert.freq_once_per_bar_close)
    alert("MDE Bearish Divergence on " + syminfo.tickerid, alert.freq_once_per_bar_close)

// ─── 9x ALERTCONDITION ───────────────────────────────────────────────────────
alertcondition(bullSignal, "MDE Buy Signal", "MDE Bullish divergence on {{ticker}} at {{close}} on {{interval}}")
alertcondition(bearSignal, "MDE Sell Signal", "MDE Bearish divergence on {{ticker}} at {{close}} on {{interval}}")
alertcondition(bullSignal or bearSignal, "MDE Any Signal", "MDE Divergence on {{ticker}} at {{close}} on {{interval}}")
alertcondition(regBullDiv, "MDE Regular Bull Div", "MDE Regular bullish divergence on {{ticker}} {{interval}}")
alertcondition(regBearDiv, "MDE Regular Bear Div", "MDE Regular bearish divergence on {{ticker}} {{interval}}")
alertcondition(hidBullDiv, "MDE Hidden Bull Div", "MDE Hidden bullish divergence on {{ticker}} {{interval}}")
alertcondition(hidBearDiv, "MDE Hidden Bear Div", "MDE Hidden bearish divergence on {{ticker}} {{interval}}")
alertcondition(rsiVal > 70, "MDE RSI Overbought", "MDE RSI overbought on {{ticker}} {{interval}}")
alertcondition(rsiVal < 30, "MDE RSI Oversold", "MDE RSI oversold on {{ticker}} {{interval}}")
````
