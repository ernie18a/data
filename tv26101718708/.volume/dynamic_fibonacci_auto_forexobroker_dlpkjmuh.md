# Dynamic Fibonacci Auto [forexobroker]

- url: https://www.tradingview.com/script/DlpkjmUh-Dynamic-Fibonacci-Auto-forexobroker/
- type: indicator
- pine_id: PUB;62d407d2f1044b4a81e1eed9dab3471e
- version: 1.0

## Description

🔶 OVERVIEW

Dynamic Fibonacci Auto calculates Fibonacci retracement and extension levels automatically from confirmed swing highs and swing lows, updating dynamically as new pivots form. The indicator highlights the 50%-61.8% "Golden Zone" -- the area where the highest-probability retracements tend to find support or resistance -- and fires entry signals when price bounces from this zone with trend, volume, and candle direction confirmation.

This tool is designed for traders who use Fibonacci levels as a core part of their analysis but want to eliminate the manual process of dragging retracement tools onto the chart every time a new swing forms. It works on any instrument and any timeframe, automatically adapting its levels to the most recent confirmed market structure.

🔶 CONCEPTS

Fibonacci retracement levels are derived from the mathematical Fibonacci sequence and are used to identify potential support and resistance levels during a pullback within a trend. The key levels -- 23.6%, 38.2%, 50%, 61.8%, and 78.6% -- represent proportions of a prior move where price is statistically more likely to find a reaction. The 50%-61.8% range is known as the "Golden Zone" because it represents a deep enough retracement to offer favorable risk-reward, yet not so deep that it suggests the prior trend has failed. Extension levels (127.2%, 161.8%) project potential targets beyond the original swing.

🔶 HOW IT WORKS

- Detects swing highs and swing lows using a configurable pivot lookback length on both sides
- Determines trend direction based on whether the most recent swing low preceded the most recent swing high (uptrend) or vice versa
- Calculates all standard Fibonacci retracement levels (23.6%, 38.2%, 50%, 61.8%, 78.6%) and extension levels (127.2%, 161.8%) from the last confirmed swing range
- Draws levels as horizontal lines with a highlighted Golden Zone box between the 50% and 61.8% levels
- Fires signals when price enters the Golden Zone, forms a directional candle (bullish for uptrend, bearish for downtrend), closes above the zone midpoint, confirms with EMA trend alignment and volume filter

🔶 HOW TO USE

1. Add the indicator to any chart -- Fibonacci levels and the Golden Zone appear automatically once swing points are detected
2. Watch for price to pull back into the highlighted Golden Zone (the shaded area between 50% and 61.8%)
3. BUY arrows fire during uptrends when price bounces bullishly from the Golden Zone; SELL arrows fire during downtrends
4. Signal labels show the nearest Fibonacci level, current price, and suggested SL/TP levels based on ATR
5. Use extension levels (127.2%, 161.8%) as potential profit targets beyond the original swing. Always confirm with broader market context and define your stop-loss.

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- ATR-based stop-loss and take-profit levels on signal labels
- Visual Golden Zone highlight with optional background tint when price is inside the zone

🔶 SETTINGS GUIDE

- Swing Detection Length -- Bars to the left and right required to confirm a pivot point
- Trend EMA Length -- Period for the EMA used to confirm trend direction on bounce signals
- Volume SMA Length -- Period for the volume filter
- Signal Cooldown -- Minimum bars between signals
- Show 23.6% / 38.2% / 50% / 61.8% / 78.6% -- Toggle individual Fibonacci levels
- ATR Length -- Period for stop-loss and take-profit calculation
- SL ATR Multiplier -- Stop-loss distance as a multiple of ATR
- Show SL/TP on Labels -- Toggle stop-loss and take-profit display
- Show Extension Levels -- Toggle 127.2% and 161.8% extension lines
- Show Golden Zone Fill -- Toggle the shaded box between 50% and 61.8%
- Show Golden Zone Background -- Toggle background tint when price is inside the zone
- Show Info Table -- Toggle the dashboard

🔶 ALERTS

- Bullish Fib Bounce -- Price bounces bullishly from Golden Zone in uptrend
- Bearish Fib Bounce -- Price bounces bearishly from Golden Zone in downtrend
- Price in Golden Zone -- Price enters the 50%-61.8% zone
- New Swing High -- New confirmed swing high detected
- New Swing Low -- New confirmed swing low detected
- Any Fib Signal -- Any confirmed Fibonacci bounce signal
- Unconfirmed Bull Bounce -- Golden Zone bounce without full filter confirmation
- Unconfirmed Bear Bounce -- Golden Zone bounce without full filter confirmation
- Fib Range Expansion -- Fibonacci range expands significantly (new wider swing detected)

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Fibonacci levels are not guaranteed support/resistance -- they represent areas of potential interest, not certainties.
- Swing detection requires lookback bars on both sides, so levels update with a delay equal to the Swing Detection Length setting.
- In strongly trending markets with shallow pullbacks, price may not reach the Golden Zone before continuing.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Dynamic Fibonacci Auto [forexobroker]", shorttitle="DFA [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
grp_core = "Core Settings"
swingLen     = input.int(10, "Swing Detection Length", minval=3, maxval=30, group=grp_core, tooltip="Lookback for pivot high/low detection")
trendEmaLen  = input.int(50, "Trend EMA Length", minval=10, maxval=200, group=grp_core, tooltip="EMA for trend direction confirmation on bounce signals")
volSmaLen    = input.int(20, "Volume SMA Length", minval=5, maxval=50, group=grp_core)
cooldownBars = input.int(15, "Signal Cooldown (bars)", minval=5, maxval=50, group=grp_core)

grp_fib = "Fibonacci Levels"
show236  = input.bool(true, "Show 23.6%", group=grp_fib)
show382  = input.bool(true, "Show 38.2%", group=grp_fib)
show500  = input.bool(true, "Show 50.0%", group=grp_fib)
show618  = input.bool(true, "Show 61.8%", group=grp_fib)
show786  = input.bool(true, "Show 78.6%", group=grp_fib)

grp_adv = "Advanced Settings"
atrLen       = input.int(14, "ATR Length", minval=5, maxval=50, group=grp_adv)
slMultiplier = input.float(1.5, "SL ATR Multiplier", minval=0.5, maxval=5.0, step=0.5, group=grp_adv, tooltip="Stop-loss as ATR multiple")
showSLTP     = input.bool(true, "Show SL/TP on Labels", group=grp_adv)
showExtLines = input.bool(true, "Show Extension Levels", group=grp_adv, tooltip="Show 127.2% and 161.8% extension levels")

grp_vis = "Visual Settings"
showTable    = input.bool(true, "Show Info Table", group=grp_vis)
showZoneFill = input.bool(true, "Show Golden Zone Fill", group=grp_vis)
showBg       = input.bool(true, "Show Golden Zone Background", group=grp_vis, tooltip="Background tint when price is in golden zone")
neonCyan     = input.color(#00d4ff, "Buy Color", group=grp_vis)
neonPink     = input.color(#ff2d78, "Sell Color", group=grp_vis)
neonGreen    = input.color(#39ff14, "Bullish Accent", group=grp_vis)
neonPurple   = input.color(#a855f7, "Level Color", group=grp_vis)
neonOrange   = input.color(#ffaa00, "Golden Zone Color", group=grp_vis)

// ─── SWING DETECTION ───────────────────────────────────────────────────────────
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastSwHigh    = na
var int   lastSwHighBar = na
var float lastSwLow     = na
var int   lastSwLowBar  = na

if not na(swingHigh)
    lastSwHigh    := swingHigh
    lastSwHighBar := bar_index - swingLen

if not na(swingLow)
    lastSwLow    := swingLow
    lastSwLowBar := bar_index - swingLen

// ─── FIBONACCI LEVEL CALCULATION ───────────────────────────────────────────────
isUptrend   = not na(lastSwHighBar) and not na(lastSwLowBar) ? lastSwLowBar < lastSwHighBar : bool(na)
fibRange    = lastSwHigh - lastSwLow
validFib    = not na(lastSwHigh) and not na(lastSwLow) and fibRange > 0

fib236 = validFib ? (isUptrend ? lastSwHigh - fibRange * 0.236 : lastSwLow + fibRange * 0.236) : na
fib382 = validFib ? (isUptrend ? lastSwHigh - fibRange * 0.382 : lastSwLow + fibRange * 0.382) : na
fib500 = validFib ? (isUptrend ? lastSwHigh - fibRange * 0.500 : lastSwLow + fibRange * 0.500) : na
fib618 = validFib ? (isUptrend ? lastSwHigh - fibRange * 0.618 : lastSwLow + fibRange * 0.618) : na
fib786 = validFib ? (isUptrend ? lastSwHigh - fibRange * 0.786 : lastSwLow + fibRange * 0.786) : na

// Extension levels (beyond the swing range)
fib1272 = validFib ? (isUptrend ? lastSwHigh + fibRange * 0.272 : lastSwLow - fibRange * 0.272) : na
fib1618 = validFib ? (isUptrend ? lastSwHigh + fibRange * 0.618 : lastSwLow - fibRange * 0.618) : na

// ATR for stop/target
atrVal = ta.atr(atrLen)

// Track proximity to each fib level
distTo236 = validFib ? math.abs(close - fib236) : na
distTo382 = validFib ? math.abs(close - fib382) : na
distTo500 = validFib ? math.abs(close - fib500) : na
distTo618 = validFib ? math.abs(close - fib618) : na
distTo786 = validFib ? math.abs(close - fib786) : na

// ─── SIGNAL COUNTER ────────────────────────────────────────────────────────────
var int totalBullSignals = 0
var int totalBearSignals = 0

// ─── FIBONACCI LINES ───────────────────────────────────────────────────────────
var line ln236 = na, var line ln382 = na, var line ln500 = na, var line ln618 = na, var line ln786 = na
var line ln1272 = na, var line ln1618 = na
var line lnHigh = na, var line lnLow = na

if validFib and barstate.islast
    startBar = math.min(na(lastSwHighBar) ? bar_index : lastSwHighBar, na(lastSwLowBar) ? bar_index : lastSwLowBar)
    endBar   = bar_index + 20

    line.delete(lnHigh), line.delete(lnLow)
    lnHigh := line.new(startBar, lastSwHigh, endBar, lastSwHigh, color=color.new(neonGreen, 30), width=2, style=line.style_solid)
    lnLow  := line.new(startBar, lastSwLow, endBar, lastSwLow, color=color.new(neonPink, 30), width=2, style=line.style_solid)

    if show236
        line.delete(ln236)
        ln236 := line.new(startBar, fib236, endBar, fib236, color=color.new(neonPurple, 50), width=1, style=line.style_dashed)
    if show382
        line.delete(ln382)
        ln382 := line.new(startBar, fib382, endBar, fib382, color=color.new(neonPurple, 40), width=1, style=line.style_dashed)
    if show500
        line.delete(ln500)
        ln500 := line.new(startBar, fib500, endBar, fib500, color=color.new(neonOrange, 20), width=2, style=line.style_solid)
    if show618
        line.delete(ln618)
        ln618 := line.new(startBar, fib618, endBar, fib618, color=color.new(neonOrange, 10), width=2, style=line.style_solid)
    if show786
        line.delete(ln786)
        ln786 := line.new(startBar, fib786, endBar, fib786, color=color.new(neonPurple, 50), width=1, style=line.style_dashed)

    // Extension levels
    if showExtLines and not na(fib1272)
        line.delete(ln1272)
        ln1272 := line.new(startBar, fib1272, endBar, fib1272, color=color.new(neonCyan, 50), width=1, style=line.style_dotted)
    if showExtLines and not na(fib1618)
        line.delete(ln1618)
        ln1618 := line.new(startBar, fib1618, endBar, fib1618, color=color.new(neonCyan, 40), width=1, style=line.style_dotted)

// ─── GOLDEN ZONE BOX ──────────────────────────────────────────────────────────
var box goldenBox = na
if validFib and showZoneFill and barstate.islast
    startBar = math.min(na(lastSwHighBar) ? bar_index : lastSwHighBar, na(lastSwLowBar) ? bar_index : lastSwLowBar)
    gzTop = isUptrend ? fib500 : fib618
    gzBot = isUptrend ? fib618 : fib500
    box.delete(goldenBox)
    goldenBox := box.new(startBar, math.max(gzTop, gzBot), bar_index + 20, math.min(gzTop, gzBot), border_color=color.new(neonOrange, 60), bgcolor=color.new(neonOrange, 88), border_width=1)

// ─── GOLDEN ZONE BOUNCE DETECTION ──────────────────────────────────────────────
trendEma = ta.ema(close, trendEmaLen)
volSma   = ta.sma(volume, volSmaLen)
volFilter = volume > volSma
confirmed = barstate.isconfirmed

gzTop = validFib ? math.max(fib500, fib618) : na
gzBot = validFib ? math.min(fib500, fib618) : na

inGoldenZone = validFib ? (low <= gzTop and high >= gzBot) : false
bullBounce   = inGoldenZone and close > open and close > (gzTop + gzBot) / 2
bearBounce   = inGoldenZone and close < open and close < (gzTop + gzBot) / 2

var int lastSigBar = 0
cooldownOk = bar_index - lastSigBar >= cooldownBars

bullFibSig = confirmed and bullBounce and volFilter and cooldownOk and isUptrend == true and close > trendEma
bearFibSig = confirmed and bearBounce and volFilter and cooldownOk and isUptrend == false and close < trendEma

if bullFibSig
    lastSigBar := bar_index
    totalBullSignals += 1

if bearFibSig
    lastSigBar := bar_index
    totalBearSignals += 1

// ─── 3-LAYER GLOW ARROWS ──────────────────────────────────────────────────────
plotshape(bullFibSig, title="Buy Glow 1", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 70), size=size.huge)
plotshape(bullFibSig, title="Buy Glow 2", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 40), size=size.large)
plotshape(bullFibSig, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 0), size=size.normal, text="BUY", textcolor=color.white)

plotshape(bearFibSig, title="Sell Glow 1", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 70), size=size.huge)
plotshape(bearFibSig, title="Sell Glow 2", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 40), size=size.large)
plotshape(bearFibSig, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 0), size=size.normal, text="SELL", textcolor=color.white)

// ─── BAR COLORING ──────────────────────────────────────────────────────────────
barcolor(bullFibSig ? neonCyan : bearFibSig ? neonPink : na)

// ─── GOLDEN ZONE BACKGROUND ───────────────────────────────────────────────────
gzBgCol = showBg and inGoldenZone ? color.new(neonOrange, 92) : na
bgcolor(gzBgCol, title="Golden Zone Background")

// ─── SIGNAL LABELS WITH SL/TP ──────────────────────────────────────────────────
if bullFibSig
    nearestFib = math.abs(close - fib500) < math.abs(close - fib618) ? "50.0%" : "61.8%"
    slPrice = close - atrVal * slMultiplier
    tpPrice = close + atrVal * slMultiplier * 2
    lblText = "FIB BOUNCE BUY\nLevel: " + nearestFib + "\nPrice: " + str.tostring(close, format.mintick)
    lblText += showSLTP ? "\nSL: " + str.tostring(slPrice, format.mintick) + "\nTP: " + str.tostring(tpPrice, format.mintick) : ""
    label.new(bar_index, low, lblText, style=label.style_label_up, color=neonCyan, textcolor=color.white, size=size.small)

if bearFibSig
    nearestFib = math.abs(close - fib500) < math.abs(close - fib618) ? "50.0%" : "61.8%"
    slPrice = close + atrVal * slMultiplier
    tpPrice = close - atrVal * slMultiplier * 2
    lblText = "FIB BOUNCE SELL\nLevel: " + nearestFib + "\nPrice: " + str.tostring(close, format.mintick)
    lblText += showSLTP ? "\nSL: " + str.tostring(slPrice, format.mintick) + "\nTP: " + str.tostring(tpPrice, format.mintick) : ""
    label.new(bar_index, high, lblText, style=label.style_label_down, color=neonPink, textcolor=color.white, size=size.small)

// ─── FIBONACCI LEVEL LABELS ────────────────────────────────────────────────────
if validFib and barstate.islast
    labelX = bar_index + 22
    if show236
        label.new(labelX, fib236, "23.6%", style=label.style_none, textcolor=neonPurple, size=size.tiny)
    if show382
        label.new(labelX, fib382, "38.2%", style=label.style_none, textcolor=neonPurple, size=size.tiny)
    if show500
        label.new(labelX, fib500, "50.0%", style=label.style_none, textcolor=neonOrange, size=size.small)
    if show618
        label.new(labelX, fib618, "61.8%", style=label.style_none, textcolor=neonOrange, size=size.small)
    if show786
        label.new(labelX, fib786, "78.6%", style=label.style_none, textcolor=neonPurple, size=size.tiny)
    if showExtLines and not na(fib1272)
        label.new(labelX, fib1272, "127.2%", style=label.style_none, textcolor=neonCyan, size=size.tiny)
    if showExtLines and not na(fib1618)
        label.new(labelX, fib1618, "161.8%", style=label.style_none, textcolor=neonCyan, size=size.tiny)

// ─── INFO TABLE ────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table infoTbl = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 60))
    table.cell(infoTbl, 0, 0, "Dynamic Fibonacci Auto", text_color=neonOrange, text_size=size.small, bgcolor=color.new(color.black, 10))
    table.merge_cells(infoTbl, 0, 0, 1, 0)
    trendText = not validFib ? "N/A" : isUptrend ? "▲ Uptrend" : "▼ Downtrend"
    trendCol  = not validFib ? color.gray : isUptrend ? neonGreen : neonPink
    table.cell(infoTbl, 0, 1, "Trend", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 1, trendText, text_color=trendCol, text_size=size.tiny)
    table.cell(infoTbl, 0, 2, "Swing High", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 2, str.tostring(lastSwHigh, format.mintick), text_color=neonGreen, text_size=size.tiny)
    table.cell(infoTbl, 0, 3, "Swing Low", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 3, str.tostring(lastSwLow, format.mintick), text_color=neonPink, text_size=size.tiny)
    table.cell(infoTbl, 0, 4, "Golden Zone", text_color=color.white, text_size=size.tiny)
    gzText = validFib ? str.tostring(math.min(fib500, fib618), format.mintick) + " - " + str.tostring(math.max(fib500, fib618), format.mintick) : "N/A"
    table.cell(infoTbl, 1, 4, gzText, text_color=neonOrange, text_size=size.tiny)
    table.cell(infoTbl, 0, 5, "In GZ", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 5, inGoldenZone ? "YES" : "NO", text_color=inGoldenZone ? neonOrange : color.gray, text_size=size.tiny)
    table.cell(infoTbl, 0, 6, "Fib Range", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 6, validFib ? str.tostring(fibRange, format.mintick) : "N/A", text_color=neonPurple, text_size=size.tiny)

    // Nearest level
    table.cell(infoTbl, 0, 7, "Nearest Fib", text_color=color.white, text_size=size.tiny)
    nearLbl = "N/A"
    if validFib
        minDist = distTo500
        nearLbl := "50.0%"
        if not na(distTo236) and distTo236 < minDist
            minDist := distTo236
            nearLbl := "23.6%"
        if not na(distTo382) and distTo382 < minDist
            minDist := distTo382
            nearLbl := "38.2%"
        if not na(distTo618) and distTo618 < minDist
            minDist := distTo618
            nearLbl := "61.8%"
        if not na(distTo786) and distTo786 < minDist
            minDist := distTo786
            nearLbl := "78.6%"
    table.cell(infoTbl, 1, 7, nearLbl, text_color=neonOrange, text_size=size.tiny)

    // Signal counts
    table.cell(infoTbl, 0, 8, "Buy Signals", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 8, str.tostring(totalBullSignals), text_color=neonCyan, text_size=size.tiny)
    table.cell(infoTbl, 0, 9, "Sell Signals", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 9, str.tostring(totalBearSignals), text_color=neonPink, text_size=size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if bullFibSig
    alert('{"indicator":"DFA","signal":"BUY","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"level":"golden_zone","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)

if bearFibSig
    alert('{"indicator":"DFA","signal":"SELL","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"level":"golden_zone","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)

alertcondition(bullFibSig, title="Bullish Fib Bounce", message="DFA Bullish Golden Zone Bounce on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearFibSig, title="Bearish Fib Bounce", message="DFA Bearish Golden Zone Bounce on {{ticker}} {{interval}} at {{close}}")
alertcondition(inGoldenZone, title="Price in Golden Zone", message="DFA Price in Golden Zone on {{ticker}} {{interval}}")
alertcondition(not na(swingHigh), title="New Swing High", message="DFA New Swing High detected on {{ticker}} {{interval}}")
alertcondition(not na(swingLow), title="New Swing Low", message="DFA New Swing Low detected on {{ticker}} {{interval}}")
alertcondition(bullFibSig or bearFibSig, title="Any Fib Signal", message="DFA Fibonacci signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullBounce and not bullFibSig, title="Unconfirmed Bull Bounce", message="DFA Unconfirmed bullish bounce in GZ on {{ticker}} {{interval}}")
alertcondition(bearBounce and not bearFibSig, title="Unconfirmed Bear Bounce", message="DFA Unconfirmed bearish bounce in GZ on {{ticker}} {{interval}}")
alertcondition(validFib and fibRange > fibRange[1] * 1.5, title="Fib Range Expansion", message="DFA Fibonacci range expanded significantly on {{ticker}} {{interval}}")
````
