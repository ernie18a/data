# Adaptive Expansion Framework 

- url: https://www.tradingview.com/script/iDCNB5qn-Adaptive-Expansion-Framework/
- type: indicator
- pine_id: PUB;531d4b775af346edbba3126ab00dc6c6
- version: 1.0

## Description

Adaptive Expansion Framework (AEF)

AEF combines six classic volatility/structure concepts into one clean overlay so you can read market structure and expansion potential at a glance, without stacking five separate indicators.

WHAT IT COMBINES
1. Regression channel — a straight linear-regression channel (mid ± stdev) defines the prevailing structure and slope.
2. Equilibrium zone — an inner band around the regression line marks "fair value," helping separate mean-reversion from continuation context.
3. Volatility compression — Bollinger band-width is ranked as a percentile against its own lookback; when volatility coils into the lowest percentiles, the equilibrium band brightens and the chart gets a faint tint.
4. Range vs trend detection — Kaufman-style efficiency ratio plus slope classify the tape as Compression, Trending, or Ranging.
5. Breakout detection — a close beyond a channel wall, confirmed by range expansion (and optional volume), flags a breakout.
6. Expansion projection — on a confirmed break, a measured-move target (full channel height) is projected forward, with a 0–100 breakout-quality grade attached.

BREAKOUT QUALITY SCORE (0–100)
Each breakout is graded from four inputs: range expansion (35%), volume (25%), how compressed volatility was just before the break (25%), and how decisively price pierced the wall (15%). Grades A/B/C/D help filter weak or suspect breaks from clean ones.

DASHBOARD
Shows current regime, efficiency %, compression percentile, price position vs equilibrium, and the last signal with its quality grade.

HOW TO USE
- Use the regime label to pick context: fade extremes inside the channel when Ranging, look for breaks when Compression resolves.
- Treat the projection target as a reference level, not a guarantee.
- Higher-grade breakouts (A/B) that resolve a compression phase tend to be the cleaner setups; low-efficiency C/D breaks are more prone to fade.

KEY INPUTS
- Regression length: structural context window.
- Channel width (stdev x) and Equilibrium band: zone sizing.
- Compression percentile: how tight volatility must get to flag a setup.
- Trend efficiency threshold: range vs trend sensitivity.
- Breakout range x ATR / optional volume: how decisive a break must be.

BEHAVIOR ON THE LAST BAR
The channel, equilibrium band and projection are drawn on the most recent bar and update live. Breakout signals are evaluated on closing crosses, so on the currently forming (real-time) bar a signal can appear and disappear until the bar closes. Always confirm signals on closed bars before acting.

NOTES
This is an analysis tool, not a signal service. It does not predict price and is not financial advice. Test settings on your own instrument and timeframe before relying on it. Defaults are tuned for liquid index instruments on intraday timeframes (volume confirmation is off by default).

## Source Code

````pine
//@version=6
indicator("Adaptive Expansion Framework 🐘", "AEF", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ───────────────────────── Inputs ─────────────────────────
grpR = "Regression channel"
src    = input.source(close, "Source", group = grpR)
regLen = input.int(100, "Regression length", minval = 10, group = grpR)
chMult = input.float(2.0, "Channel width (stdev ×)", minval = 0.5, step = 0.1, group = grpR)
eqFrac = input.float(0.33, "Equilibrium band (× channel)", minval = 0.05, maxval = 0.9, step = 0.01, group = grpR)

grpV = "Volatility / regime"
compLook   = input.int(120, "Compression lookback", minval = 20, group = grpV)
compThresh = input.float(25.0, "Compression below (%ile)", minval = 5, maxval = 90, step = 5, group = grpV)
erLen      = input.int(20, "Efficiency length", minval = 2, group = grpV)
trendThr   = input.float(0.45, "Trend efficiency ≥", minval = 0.1, maxval = 0.95, step = 0.05, group = grpV)

grpB = "Breakout + expansion"
atrLen   = input.int(14, "ATR length", minval = 1, group = grpB)
expMult  = input.float(1.1, "Breakout range × ATR", minval = 0.3, step = 0.1, group = grpB)
projLen  = input.int(40, "Projection length (bars)", minval = 5, group = grpB)
useVol   = input.bool(false, "Require volume expansion", group = grpB)
volMult  = input.float(1.5, "Volume × avg", minval = 1.0, step = 0.1, group = grpB)

grpS = "Style"
chCol   = input.color(#5e35b1, "Channel", group = grpS, inline = "c1")
eqCol   = input.color(#26c6da, "Equilibrium", group = grpS, inline = "c1")
upCol   = input.color(#26a69a, "Up break", group = grpS, inline = "c2")
dnCol   = input.color(#ef5350, "Down break", group = grpS, inline = "c2")
showProj = input.bool(true, "Draw expansion projection", group = grpS)
showDash = input.bool(true, "Show dashboard", group = grpS)

// ───────────────────────── Core indicators (global) ─────────────────────────
atr    = ta.atr(atrLen)
avgVol = ta.sma(volume, 20)
reg    = ta.linreg(src, regLen, 0)
reg1   = ta.linreg(src, regLen, 1)
slope  = reg - reg1                       // true regression slope (same-bar offsets)
dev    = ta.stdev(src, regLen)

half   = chMult * dev
eqHalf = half * eqFrac

upperNow = reg + half
lowerNow = reg - half
eqUpNow  = reg + eqHalf
eqLoNow  = reg - eqHalf

// ───────────────────────── Volatility compression (percentile) ─────────────────────────
basis20 = ta.sma(src, 20)
dev20   = ta.stdev(src, 20)
bbw     = basis20 != 0 ? (4.0 * dev20) / basis20 : 0.0
bbwLo   = ta.lowest(bbw, compLook)
bbwHi   = ta.highest(bbw, compLook)
bbwPct  = bbwHi > bbwLo ? (bbw - bbwLo) / (bbwHi - bbwLo) * 100.0 : 100.0
compressed = bbwPct <= compThresh

// ───────────────────────── Range vs trend (efficiency ratio) ─────────────────────────
netMove = math.abs(src - src[erLen])
noise   = math.sum(math.abs(src - src[1]), erLen)
er      = noise != 0 ? netMove / noise : 0.0
trending = er >= trendThr

regime = compressed ? "Compression" : trending ? (slope >= 0 ? "Trending ▲" : "Trending ▼") : "Ranging"
regCol = compressed ? color.new(#ff9800, 0) : trending ? (slope >= 0 ? upCol : dnCol) : color.gray

// ───────────────────────── Breakout detection ─────────────────────────
rangeOk = ta.tr(true) > atr * expMult
volOk   = not useVol or na(volume) or volume > avgVol * volMult

breakUp = ta.crossover(close, upperNow) and rangeOk and volOk
breakDn = ta.crossunder(close, lowerNow) and rangeOk and volOk

// ───────────────────────── Breakout quality 0..100 ─────────────────────────
rangeScore = math.min(ta.tr(true) / (atr * expMult), 1.0)
volScore   = na(volume) ? 0.5 : math.min(volume / math.max(avgVol, 1.0), 1.5) / 1.5
compScore  = math.max(0.0, 1.0 - bbwPct[1] / 100.0)
pierceRaw  = breakUp ? (close - upperNow) / math.max(dev, atr * 0.1) : breakDn ? (lowerNow - close) / math.max(dev, atr * 0.1) : 0.0
pierceScore = math.min(math.max(pierceRaw, 0.0), 1.0)
quality = (0.35 * rangeScore + 0.25 * volScore + 0.25 * compScore + 0.15 * pierceScore) * 100.0
qInt    = int(math.round(quality))
qTier   = qInt >= 75 ? "A · high" : qInt >= 55 ? "B · solid" : qInt >= 35 ? "C · weak" : "D · suspect"

// ───────────────────────── Channel + equilibrium (straight lines + linefill) ─────────────────────────
var line lCh1 = na
var line lCh2 = na
var line lMid = na
var line lEq1 = na
var line lEq2 = na
var linefill fillUp = na
var linefill fillEq = na
var linefill fillDn = na

x1 = bar_index - regLen + 1
x2 = bar_index
midL = reg - slope * (regLen - 1)         // left endpoint = current value minus slope over the window
midR = reg

if barstate.islast
    if na(lMid)
        lCh1 := line.new(x1, midL + half, x2, midR + half, color = color.new(chCol, 25), width = 2)
        lEq1 := line.new(x1, midL + eqHalf, x2, midR + eqHalf, color = color.new(eqCol, 45), width = 1)
        lMid := line.new(x1, midL, x2, midR, color = color.new(chCol, 0), width = 1, style = line.style_dashed)
        lEq2 := line.new(x1, midL - eqHalf, x2, midR - eqHalf, color = color.new(eqCol, 45), width = 1)
        lCh2 := line.new(x1, midL - half, x2, midR - half, color = color.new(chCol, 25), width = 2)
        fillUp := linefill.new(lCh1, lEq1, color.new(chCol, 88))
        fillEq := linefill.new(lEq1, lEq2, color.new(eqCol, 80))
        fillDn := linefill.new(lEq2, lCh2, color.new(chCol, 88))
    else
        line.set_xy1(lCh1, x1, midL + half)
        line.set_xy2(lCh1, x2, midR + half)
        line.set_xy1(lEq1, x1, midL + eqHalf)
        line.set_xy2(lEq1, x2, midR + eqHalf)
        line.set_xy1(lMid, x1, midL)
        line.set_xy2(lMid, x2, midR)
        line.set_xy1(lEq2, x1, midL - eqHalf)
        line.set_xy2(lEq2, x2, midR - eqHalf)
        line.set_xy1(lCh2, x1, midL - half)
        line.set_xy2(lCh2, x2, midR - half)
    eqFillT = int(math.max(50, 80 - (100 - bbwPct) * 0.3))
    linefill.set_color(fillEq, color.new(eqCol, eqFillT))

// ───────────────────────── Expansion projection (measured move) ─────────────────────────
var line  projLine  = na
var label projLabel = na
channelH = half * 2.0

if (breakUp or breakDn) and showProj
    if not na(projLine)
        line.delete(projLine)
    if not na(projLabel)
        label.delete(projLabel)
    dir = breakUp ? 1.0 : -1.0
    target = close + dir * channelH
    pc = breakUp ? upCol : dnCol
    projLine := line.new(bar_index, target, bar_index + projLen, target, color = color.new(pc, 0), width = 2, style = line.style_dotted)
    txt = (breakUp ? "▲ Target " : "▼ Target ") + str.tostring(math.round(target)) + "  ·  Q " + str.tostring(qInt) + " (" + qTier + ")"
    projLabel := label.new(bar_index + projLen, target, txt, style = label.style_label_left, color = color.new(pc, 15), textcolor = color.white, size = size.small)

// ───────────────────────── Markers + background ─────────────────────────
bgcolor(breakUp ? color.new(upCol, 60) : breakDn ? color.new(dnCol, 60) : compressed ? color.new(#ff9800, 92) : na)
plotshape(breakUp ? lowerNow : na, "Break up",   shape.triangleup,   location.absolute, color.new(upCol, 0), text = "💥", textcolor = upCol, size = size.small)
plotshape(breakDn ? upperNow : na, "Break down", shape.triangledown, location.absolute, color.new(dnCol, 0), text = "💥", textcolor = dnCol, size = size.small)

// ───────────────────────── Dashboard ─────────────────────────
pricePos = close > eqUpNow ? "Above fair value" : close < eqLoNow ? "Below fair value" : "At equilibrium"
posCol   = close > eqUpNow ? upCol : close < eqLoNow ? dnCol : color.new(eqCol, 0)
lastSig  = breakUp ? "💥 Breakout ▲" : breakDn ? "💥 Breakout ▼" : compressed ? "🔒 Coiling" : "—"

var table dash = table.new(position.top_right, 2, 6, border_width = 1)
if showDash and barstate.islast
    table.cell(dash, 0, 0, "Adaptive Expansion", text_color = color.white, bgcolor = regCol, text_size = size.small)
    table.cell(dash, 1, 0, "🐘 @darshakssc", text_color = color.white, bgcolor = regCol, text_size = size.tiny)
    table.cell(dash, 0, 1, "Regime", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 1, regime, text_color = regCol, text_size = size.small)
    table.cell(dash, 0, 2, "Efficiency", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(math.round(er * 100)) + "%", text_color = color.gray, text_size = size.small)
    table.cell(dash, 0, 3, "Compression", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 3, str.tostring(math.round(bbwPct)) + " %ile", text_color = compressed ? color.new(#ff9800, 0) : color.gray, text_size = size.small)
    table.cell(dash, 0, 4, "Price", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 4, pricePos, text_color = posCol, text_size = size.small)
    table.cell(dash, 0, 5, "Last signal", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 5, lastSig + (breakUp or breakDn ? "  Q" + str.tostring(qInt) : ""), text_color = breakUp ? upCol : breakDn ? dnCol : color.gray, text_size = size.small)

// ───────────────────────── Data window + alerts ─────────────────────────
plot(reg, "Equilibrium", display = display.data_window)
plot(bbwPct, "Compression %ile", display = display.data_window)
plot(er * 100, "Efficiency %", display = display.data_window)
plot(quality, "Breakout quality", display = display.data_window)

alertcondition(compressed and not compressed[1], "Compression entered", "AEF: volatility compressed — expansion setup building")
alertcondition(breakUp, "Breakout up", "AEF: 💥 upside breakout from channel")
alertcondition(breakDn, "Breakout down", "AEF: 💥 downside breakout from channel")
alertcondition(breakUp and quality >= 75, "High-quality up break", "AEF: 💥 grade-A upside breakout")
alertcondition(breakDn and quality >= 75, "High-quality down break", "AEF: 💥 grade-A downside breakout")
````
