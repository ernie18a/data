# EV Bollinger Bands 

- url: https://www.tradingview.com/script/Ths4WPYT-EV-Bollinger-Bands/
- type: indicator
- pine_id: PUB;e29a34636664465c8ad4aa657796d30e
- version: 1.0

## Description

EV Bollinger Bands is a significantly upgraded version of the classic Bollinger Bands indicator, built for traders who want cleaner signals and deeper market context — without the visual noise.

What's new vs standard BB:

🎨 Dynamic Band Colors
Bands turn green when expanding (volatility increasing), red when contracting, and gray during a squeeze — giving you instant visual context without reading numbers.

🔴 Squeeze Detection (Keltner Channel Method)
Automatically detects when BB compresses inside the Keltner Channel. The squeeze state is shown in the dashboard in real time.

⚡ Squeeze Momentum Dots
Small dots appear only on key momentum events: when momentum flips direction, accelerates during a squeeze, or when bandwidth hits historical lows — signaling an imminent breakout.

📐 Mean Reversion Signals
Triangle signals appear when price touches a band AND RSI confirms extreme conditions AND a reversal candle forms. Filters out weak touches.

📊 Live Dashboard (Top Right)
Real-time panel showing:
• %B — where price sits inside the bands (0–100%)
• Bandwidth — how wide the bands are (⚡ alerts when at historical lows)
• Squeeze status — ON / OFF
• Momentum direction — Strong / Weak, bullish or bearish
• Mean Reversion signal — active or not

📌 Anchored Live Levels
Upper, Lower and Basis lines extend to the right with real-time price labels. Choose between fixed (on close) or real-time update mode.

🔔 10 Alert Conditions
Breakouts, re-entries, squeeze on/off, mean reversion signals.

Compatible with all markets and timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © EV Quant Lab

//@version=6
indicator("EV Bollinger Bands ", shorttitle="Bollinger Bands", overlay=true, max_lines_count=100, max_labels_count=100)

// ─────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────
var g1 = "Bollinger Bands"
var g2 = "Squeeze (Keltner)"
var g3 = "Momentum Signals"
var g4 = "Mean Reversion Signals"
var g5 = "Dashboard"
var g6 = "Live Levels"
var g7 = "Alerts"

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
src       = input.source(close, "Source",     group=g1)
basisType = input.string("SMA", "Basis Type", options=["SMA","EMA"], group=g1)
bbLen     = input.int(20,   "BB Length",      minval=1, group=g1)
bbMult    = input.float(2.0,"BB Multiplier",  minval=0.1, step=0.1, group=g1)
showBasis = input.bool(true, "Show Basis Line", group=g1)
fillBands = input.bool(true, "Fill Between Bands", group=g1)

useSqueeze = input.bool(true,  "Enable Squeeze Detection", group=g2)
kcLen      = input.int(20,    "KC Length",        minval=1, group=g2)
kcAtrLen   = input.int(10,    "KC ATR Length",    minval=1, group=g2)
kcAtrMult  = input.float(1.5, "KC ATR Multiplier",minval=0.1, step=0.1, group=g2)

showMomDots = input.bool(true, "Show Momentum Dots (signal only)", group=g3)
momLen      = input.int(20, "Momentum Length", minval=5, group=g3)

showMR   = input.bool(true, "Show Mean Reversion Signals", group=g4)
mrRsiLen = input.int(14, "RSI Length", minval=2, group=g4)

showDash = input.bool(true, "Show Dashboard", group=g5)

showLiveLevels = input.bool(true,  "Show Live Levels",       group=g6)
extendRight    = input.bool(true,  "Extend To The Right",    group=g6)
liveLineWidth  = input.int(2,      "Live Line Width",        minval=1, maxval=5, group=g6)
showLiveLabels = input.bool(true,  "Show Live Labels",       group=g6)
updateMode     = input.string("On Close (Fixed)", "Update Mode", options=["On Close (Fixed)", "Real-Time (Moving)"], group=g6)

enableBreakoutAlerts = input.bool(true, "Alerts: Band Breakouts",  group=g7)
enableReEntryAlerts  = input.bool(true, "Alerts: Re-Entry",        group=g7)
enableSqueezeAlerts  = input.bool(true, "Alerts: Squeeze On/Off",  group=g7)
enableMRAlerts       = input.bool(true, "Alerts: Mean Reversion",  group=g7)

// ─────────────────────────────────────────────
// BB + KC
// ─────────────────────────────────────────────
basis = basisType == "EMA" ? ta.ema(src, bbLen) : ta.sma(src, bbLen)
dev   = ta.stdev(src, bbLen) * bbMult
upper = basis + dev
lower = basis - dev

kcBasis   = basisType == "EMA" ? ta.ema(src, kcLen) : ta.sma(src, kcLen)
kcRange   = ta.atr(kcAtrLen) * kcAtrMult
kcUpper   = kcBasis + kcRange
kcLower   = kcBasis - kcRange
squeezeOn = useSqueeze and (upper < kcUpper) and (lower > kcLower)

// ─────────────────────────────────────────────
// %B + BANDWIDTH
// ─────────────────────────────────────────────
percentB  = (close - lower) / (upper - lower)
bandwidth = (upper - lower) / basis * 100
bwMin     = ta.lowest(bandwidth, 125)
bwAtLow   = bandwidth <= bwMin * 1.05

// ─────────────────────────────────────────────
// MOMENTUM
// ─────────────────────────────────────────────
momVal      = ta.linreg(src - math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen)), momLen, 0)
momFlipUp   = momVal > 0 and momVal[1] <= 0
momFlipDown = momVal < 0 and momVal[1] >= 0
momAccelUp  = momVal > 0 and momVal > momVal[1] and momVal[1] <= momVal[2]
momAccelDn  = momVal < 0 and momVal < momVal[1] and momVal[1] >= momVal[2]

momDotBull   = showMomDots and (momFlipUp or (squeezeOn and momAccelUp) or bwAtLow)
momDotBear   = showMomDots and (momFlipDown or (squeezeOn and momAccelDn) or bwAtLow)
momDotSignal = momDotBull or momDotBear
momDotColor  = momVal >= 0 ? color.new(#00c853, 0) : color.new(#ff1744, 0)

// ─────────────────────────────────────────────
// BAND COLORS — dynamic only, no background shading
// ─────────────────────────────────────────────
bandExpanding = bandwidth > bandwidth[1]
upperColor = squeezeOn ? color.new(color.gray, 20) : bandExpanding ? color.new(#00c853, 20) : color.new(#ff1744, 20)
lowerColor = squeezeOn ? color.new(color.gray, 20) : bandExpanding ? color.new(#00c853, 20) : color.new(#ff1744, 20)
basisColor = squeezeOn ? color.gray : bandExpanding ? color.new(#00c853, 0) : color.new(#ff1744, 0)

// ─────────────────────────────────────────────
// MEAN REVERSION
// ─────────────────────────────────────────────
rsi_val = ta.rsi(close, mrRsiLen)
mrBull  = close <= lower and rsi_val < 35 and close > open
mrBear  = close >= upper and rsi_val > 65 and close < open

// ─────────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────────
breakUp          = close > upper
breakDown        = close < lower
reEntryFromAbove = close < upper and close[1] > upper[1]
reEntryFromBelow = close > lower and close[1] < lower[1]

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
pUpper = plot(upper, "BB Upper", color=upperColor, linewidth=2)
pLower = plot(lower, "BB Lower", color=lowerColor, linewidth=2)
plot(showBasis ? basis : na, "BB Basis", color=basisColor, linewidth=1, style=plot.style_line)
fill(pUpper, pLower, color=fillBands ? color.new(color.blue, 92) : na, title="BB Fill")

atr14   = ta.atr(14)
momDotY = lower - atr14 * 0.4
plotshape(momDotSignal ? momDotY : na, "Momentum Signal", style=shape.circle,       location=location.absolute, color=momDotColor,   size=size.small)
plotshape(showMR and mrBull ? lower - atr14 * 0.9 : na, "MR Bull", style=shape.triangleup,   location=location.absolute, color=#00c853, size=size.small)
plotshape(showMR and mrBear ? upper + atr14 * 0.9 : na, "MR Bear", style=shape.triangledown, location=location.absolute, color=#ff1744, size=size.small)

// ─────────────────────────────────────────────
// DASHBOARD — Top Right, fixed
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#1a1a2e, 5), border_color=color.new(color.white, 70), border_width=1, frame_color=color.new(color.white, 50), frame_width=1)

if barstate.islast and showDash
    cell_bg = color.new(#1a1a2e, 0)
    hdr_bg  = color.new(#0d0d1f, 0)

    table.cell(dash, 0, 0, "EV BB ", text_color=color.white, text_size=size.small, bgcolor=hdr_bg, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    pbStr   = str.tostring(math.round(percentB * 100, 1)) + "%"
    pbColor = percentB > 0.8 ? color.new(#ff1744,0) : percentB < 0.2 ? color.new(#00c853,0) : color.white
    table.cell(dash, 0, 1, "%B",  text_color=color.gray, text_size=size.tiny,  bgcolor=cell_bg)
    table.cell(dash, 1, 1, pbStr, text_color=pbColor,    text_size=size.small, bgcolor=cell_bg, text_halign=text.align_center)

    bwStr   = str.tostring(math.round(bandwidth, 2)) + "%"
    bwLabel = bwAtLow ? "⚡ " + bwStr : bwStr
    bwColor = bwAtLow ? color.new(#ff9800, 0) : color.white
    table.cell(dash, 0, 2, "Bandwidth", text_color=color.gray, text_size=size.tiny,  bgcolor=cell_bg)
    table.cell(dash, 1, 2, bwLabel,     text_color=bwColor,    text_size=size.small, bgcolor=cell_bg, text_halign=text.align_center)

    sqStr   = squeezeOn ? "ON  🔴" : "OFF 🟢"
    sqColor = squeezeOn ? color.new(#ff9800,0) : color.new(#00c853,0)
    table.cell(dash, 0, 3, "Squeeze", text_color=color.gray, text_size=size.tiny,  bgcolor=cell_bg)
    table.cell(dash, 1, 3, sqStr,     text_color=sqColor,    text_size=size.small, bgcolor=cell_bg, text_halign=text.align_center)

    momDir      = momVal > 0 ? (momVal > momVal[1] ? "▲ Strong" : "▲ Weak") : (momVal < momVal[1] ? "▼ Strong" : "▼ Weak")
    momDirColor = momVal > 0 ? (momVal > momVal[1] ? color.new(#00c853,0) : color.new(#26a69a,0)) : (momVal < momVal[1] ? color.new(#ff1744,0) : color.new(#ef9a9a,0))
    table.cell(dash, 0, 4, "Momentum", text_color=color.gray,  text_size=size.tiny,  bgcolor=cell_bg)
    table.cell(dash, 1, 4, momDir,     text_color=momDirColor, text_size=size.small, bgcolor=cell_bg, text_halign=text.align_center)

    mrStr   = mrBull ? "Bull MR ▲" : mrBear ? "Bear MR ▼" : "—"
    mrColor = mrBull ? color.new(#00c853,0) : mrBear ? color.new(#ff1744,0) : color.gray
    table.cell(dash, 0, 5, "MR Signal", text_color=color.gray, text_size=size.tiny,  bgcolor=cell_bg)
    table.cell(dash, 1, 5, mrStr,       text_color=mrColor,    text_size=size.small, bgcolor=cell_bg, text_halign=text.align_center)

// ─────────────────────────────────────────────
// LIVE LEVELS
// ─────────────────────────────────────────────
ext = extendRight ? extend.right : extend.none

var line  lU = na
var line  lL = na
var line  lB = na
var label lbU = na
var label lbL = na
var label lbB = na
var float liveUpper = na
var float liveLower = na
var float liveBasis = na

doUpdate = updateMode == "Real-Time (Moving)" ? barstate.isrealtime : barstate.isconfirmed

if showLiveLevels
    if na(liveUpper)
        liveUpper := upper
        liveLower := lower
        liveBasis := basis
    if doUpdate
        liveUpper := upper
        liveLower := lower
        liveBasis := basis
    if barstate.isfirst
        lU := line.new(bar_index, liveUpper, bar_index + 1, liveUpper, xloc=xloc.bar_index, extend=ext, width=liveLineWidth)
        lL := line.new(bar_index, liveLower, bar_index + 1, liveLower, xloc=xloc.bar_index, extend=ext, width=liveLineWidth)
        lB := line.new(bar_index, liveBasis, bar_index + 1, liveBasis, xloc=xloc.bar_index, extend=ext, width=liveLineWidth)
    line.set_extend(lU, ext), line.set_extend(lL, ext), line.set_extend(lB, ext)
    line.set_width(lU, liveLineWidth), line.set_width(lL, liveLineWidth), line.set_width(lB, liveLineWidth)
    line.set_xy1(lU, bar_index, liveUpper), line.set_xy2(lU, bar_index + 1, liveUpper)
    line.set_xy1(lL, bar_index, liveLower), line.set_xy2(lL, bar_index + 1, liveLower)
    line.set_xy1(lB, bar_index, liveBasis), line.set_xy2(lB, bar_index + 1, liveBasis)
    if barstate.islast and showLiveLabels
        if na(lbU)
            lbU := label.new(bar_index, liveUpper, "", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white)
        if na(lbL)
            lbL := label.new(bar_index, liveLower, "", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white)
        if na(lbB)
            lbB := label.new(bar_index, liveBasis, "", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white)
        label.set_x(lbU, bar_index), label.set_y(lbU, liveUpper)
        label.set_text(lbU, "Upper: " + str.tostring(liveUpper, format.mintick))
        label.set_x(lbL, bar_index), label.set_y(lbL, liveLower)
        label.set_text(lbL, "Lower: " + str.tostring(liveLower, format.mintick))
        label.set_x(lbB, bar_index), label.set_y(lbB, liveBasis)
        label.set_text(lbB, "Basis: " + str.tostring(liveBasis, format.mintick))
    if not showLiveLabels
        if not na(lbU)
            label.delete(lbU), lbU := na
        if not na(lbL)
            label.delete(lbL), lbL := na
        if not na(lbB)
            label.delete(lbB), lbB := na
else
    if not na(lU)
        line.delete(lU), lU := na
    if not na(lL)
        line.delete(lL), lL := na
    if not na(lB)
        line.delete(lB), lB := na
    if not na(lbU)
        label.delete(lbU), lbU := na
    if not na(lbL)
        label.delete(lbL), lbL := na
    if not na(lbB)
        label.delete(lbB), lbB := na
    liveUpper := na
    liveLower := na
    liveBasis := na

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(enableBreakoutAlerts and breakUp,                        title="BB Breakout Up",        message="Bollinger: Close broke ABOVE the upper band")
alertcondition(enableBreakoutAlerts and breakDown,                      title="BB Breakout Down",       message="Bollinger: Close broke BELOW the lower band")
alertcondition(enableReEntryAlerts and reEntryFromAbove,                title="BB Re-Entry From Above", message="Bollinger: Price re-entered back INSIDE from above")
alertcondition(enableReEntryAlerts and reEntryFromBelow,                title="BB Re-Entry From Below", message="Bollinger: Price re-entered back INSIDE from below")
alertcondition(enableSqueezeAlerts and squeezeOn and not squeezeOn[1],  title="Squeeze ON",             message="Bollinger/Keltner: Squeeze ON")
alertcondition(enableSqueezeAlerts and not squeezeOn and squeezeOn[1],  title="Squeeze OFF",            message="Bollinger/Keltner: Squeeze OFF — volatility expanding")
alertcondition(enableMRAlerts and mrBull,                               title="Mean Reversion Bull",    message="BB: Mean Reversion Buy Signal on {{ticker}} {{interval}}")
alertcondition(enableMRAlerts and mrBear,                               title="Mean Reversion Bear",    message="BB: Mean Reversion Sell Signal on {{ticker}} {{interval}}")
````
