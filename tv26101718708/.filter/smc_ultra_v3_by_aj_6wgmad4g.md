# SMC ULTRA V3 by a.j

- url: https://www.tradingview.com/script/6wgMaD4G-SMC-ULTRA-V3-by-a-j/
- type: indicator
- pine_id: PUB;4a489f65161a418e97ea6b213b79fc66
- version: 1.0

## Description

What's new in this version:

Additional details: RSI Filter: Blocks buy signals above 70 and sell signals below 30
HTF Trend: Checks if the daily trend (or any frame you choose) matches the signal
Volume Delta: Differentiates between buy and sell pressure within the same candlestick
Dynamic OBs: The box automatically turns gray when the price breaks through it
SL/TP Lines: Lines automatically drawn based on your chosen ATR and R:R
Dashboard: Live dashboard: Score, RSI, Vol Ratio, Delta, HTF, Signal, ATR, SL, TP, R:R
✅ Confirmed Signal: Yellow flag signal only when all filters are combined

## Source Code

````pine
//@version=6
indicator("Momentum Candles — Ultimate Smart Money",
     shorttitle = "SMC Ultra", overlay = true,
     max_boxes_count = 200, max_labels_count = 200, max_lines_count = 200)

// ══════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════
g1 = "⚙️ Momentum"
lookback   = input.int(20,    "Lookback Period",     minval=2, maxval=200, group=g1)
multiplier = input.float(1.5, "Strength Multiplier", minval=0.1, step=0.1, group=g1)

g2 = "🐋 Volume & Whale"
volLookback = input.int(20,    "Volume Lookback", minval=2, group=g2)
volMult     = input.float(2.0, "Vol Spike Mult",  minval=1.0, step=0.1, group=g2)
showAbsorb  = input.bool(true, "Show Absorption", group=g2)

g3 = "🧱 Order Blocks"
showOB     = input.bool(true, "Show Order Blocks", group=g3)
obExtend   = input.int(10,    "OB Extend Bars",   minval=1, maxval=50, group=g3)

g4 = "🕳️ Fair Value Gaps"
showFVG = input.bool(true, "Show FVG", group=g4)

g5 = "🪤 Wick Trap"
showTrap  = input.bool(true,  "Show Wick Traps", group=g5)
wickRatio = input.float(2.5,  "Wick/Body Ratio", minval=1.0, step=0.1, group=g5)

g6 = "📈 Filters"
useRSI = input.bool(true,   "RSI Filter",       group=g6)
rsiLen = input.int(14,      "RSI Length",       minval=2, group=g6)
rsiOB  = input.float(70.0,  "RSI Overbought",   minval=50, maxval=100, group=g6)
rsiOS  = input.float(30.0,  "RSI Oversold",     minval=0,  maxval=50,  group=g6)
useHTF = input.bool(true,   "HTF Trend Filter", group=g6)
htfTF  = input.timeframe("D","HTF Timeframe",   group=g6)

g7 = "🎯 Strategy Levels"
showLevels = input.bool(true,  "Show SL / TP Lines", group=g7)
rrRatio    = input.float(2.0,  "R:R Ratio",          minval=0.5, step=0.5, group=g7)
slMult     = input.float(1.0,  "SL Multiplier (ATR)", minval=0.1, step=0.1, group=g7)

g8 = "🎨 Colors"
bullColor   = input.color(color.new(#00e676, 0),  "Bullish Momentum",  group=g8)
bearColor   = input.color(color.new(#ff1744, 0),  "Bearish Momentum",  group=g8)
smcColor    = input.color(color.new(#ffea00, 0),  "Smart Money",       group=g8)
neutralBull = input.color(color.new(#26a69a, 75), "Normal Bullish",    group=g8)
neutralBear = input.color(color.new(#ef5350, 75), "Normal Bearish",    group=g8)

g9 = "📊 Dashboard"
showDash = input.bool(true, "Show Dashboard", group=g9)
dashPos  = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g9)

g10 = "🔔 Alerts"
alertBull = input.bool(true, "Alert: Bullish Smart Money", group=g10)
alertBear = input.bool(true, "Alert: Bearish Smart Money", group=g10)

// ══════════════════════════════════════════════
//  LAYER 1 — MOMENTUM
// ══════════════════════════════════════════════
bodySize    = math.abs(close - open)
avgBody     = ta.sma(bodySize, lookback)
threshold   = avgBody * multiplier
isBullMom   = close > open and bodySize >= threshold
isBearMom   = close < open and bodySize >= threshold
isMomCandle = isBullMom or isBearMom

// ══════════════════════════════════════════════
//  LAYER 2 — VOLUME SPIKE + DELTA
// ══════════════════════════════════════════════
avgVol      = ta.sma(volume, volLookback)
isVolSpike  = volume >= avgVol * volMult
candleRange = math.max(high - low, 0.0001)
buyVol      = close > open ? volume : volume * (close - low) / candleRange
sellVol     = volume - buyVol
volDelta    = buyVol - sellVol
posDelta    = volDelta > 0
negDelta    = volDelta < 0

// ══════════════════════════════════════════════
//  LAYER 3 — SMART MONEY (momentum + vol + delta)
// ══════════════════════════════════════════════
isSmartBull  = isBullMom and isVolSpike and posDelta
isSmartBear  = isBearMom and isVolSpike and negDelta
isSmartMoney = isSmartBull or isSmartBear

// ══════════════════════════════════════════════
//  LAYER 4 — ABSORPTION
// ══════════════════════════════════════════════
bodyToRange  = bodySize / candleRange
isAbsorption = isVolSpike and bodyToRange < 0.25

// ══════════════════════════════════════════════
//  LAYER 5 — WICK TRAP
// ══════════════════════════════════════════════
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low
isBullTrap = lowerWick > bodySize * wickRatio and lowerWick > upperWick
isBearTrap = upperWick > bodySize * wickRatio and upperWick > lowerWick

// ══════════════════════════════════════════════
//  LAYER 6 — RSI FILTER
// ══════════════════════════════════════════════
rsiVal    = ta.rsi(close, rsiLen)
rsiOkBull = not useRSI or rsiVal < rsiOB
rsiOkBear = not useRSI or rsiVal > rsiOS

// ══════════════════════════════════════════════
//  LAYER 7 — HTF TREND FILTER
// ══════════════════════════════════════════════
htfClose = request.security(syminfo.tickerid, htfTF, close)
htfEMA   = request.security(syminfo.tickerid, htfTF, ta.ema(close, 20))
htfBull  = not useHTF or htfClose > htfEMA
htfBear  = not useHTF or htfClose < htfEMA

// ══════════════════════════════════════════════
//  CONFIRMED SIGNALS (all filters)
// ══════════════════════════════════════════════
filteredBull = isSmartBull and rsiOkBull and htfBull
filteredBear = isSmartBear and rsiOkBear and htfBear

// ══════════════════════════════════════════════
//  LAYER 8 — DYNAMIC ORDER BLOCKS
// ══════════════════════════════════════════════
isBullOB = showOB and filteredBull and close[1] < open[1]
isBearOB = showOB and filteredBear and close[1] > open[1]

var box[]   bullOBBoxes  = array.new_box()
var float[] bullOBBottom = array.new_float()
var box[]   bearOBBoxes  = array.new_box()
var float[] bearOBTop    = array.new_float()

if isBullOB
    b = box.new(bar_index - 1, open[1], bar_index + obExtend, close[1],
         bgcolor=color.new(#00e676, 85),
         border_color=color.new(#00e676, 40), border_width=1)
    array.push(bullOBBoxes, b)
    array.push(bullOBBottom, math.min(open[1], close[1]))

if isBearOB
    b = box.new(bar_index - 1, close[1], bar_index + obExtend, open[1],
         bgcolor=color.new(#ff1744, 85),
         border_color=color.new(#ff1744, 40), border_width=1)
    array.push(bearOBBoxes, b)
    array.push(bearOBTop, math.max(open[1], close[1]))

// Mitigate broken bull OBs
if array.size(bullOBBoxes) > 0
    for i = array.size(bullOBBoxes) - 1 to 0
        if close < array.get(bullOBBottom, i)
            bx = array.get(bullOBBoxes, i)
            box.set_bgcolor(bx, color.new(color.gray, 90))
            box.set_border_color(bx, color.new(color.gray, 70))
            array.remove(bullOBBoxes, i)
            array.remove(bullOBBottom, i)

// Mitigate broken bear OBs
if array.size(bearOBBoxes) > 0
    for i = array.size(bearOBBoxes) - 1 to 0
        if close > array.get(bearOBTop, i)
            bx = array.get(bearOBBoxes, i)
            box.set_bgcolor(bx, color.new(color.gray, 90))
            box.set_border_color(bx, color.new(color.gray, 70))
            array.remove(bearOBBoxes, i)
            array.remove(bearOBTop, i)

// ══════════════════════════════════════════════
//  LAYER 9 — FAIR VALUE GAPS
// ══════════════════════════════════════════════
bullFVG = showFVG and low > high[2]
bearFVG = showFVG and high < low[2]

if bullFVG
    box.new(bar_index - 2, high[2], bar_index, low,
         bgcolor=color.new(#00e676, 80),
         border_color=color.new(#00e676, 50), border_width=1)

if bearFVG
    box.new(bar_index - 2, high, bar_index, low[2],
         bgcolor=color.new(#ff1744, 80),
         border_color=color.new(#ff1744, 50), border_width=1)

// ══════════════════════════════════════════════
//  SMART MONEY SCORE (0–100)
// ══════════════════════════════════════════════
score = (isMomCandle ? 15 : 0) + (isVolSpike ? 20 : 0) + (isSmartMoney ? 15 : 0) + (isBullOB or isBearOB ? 15 : 0) + (bullFVG or bearFVG ? 10 : 0) + (isBullTrap or isBearTrap ? 10 : 0) + (rsiOkBull or rsiOkBear ? 8 : 0) + (htfBull and filteredBull or htfBear and filteredBear ? 7 : 0)

// ══════════════════════════════════════════════
//  ATR — SL / TP LEVELS
// ══════════════════════════════════════════════
atrVal = ta.atr(14)
slDist = atrVal * slMult
tpDist = slDist * rrRatio

if showLevels and filteredBull
    slP = low - slDist
    tpP = close + tpDist
    line.new(bar_index, slP, bar_index + 10, slP,
         color=color.new(bearColor, 0), width=2, style=line.style_dashed)
    line.new(bar_index, tpP, bar_index + 10, tpP,
         color=color.new(bullColor, 0), width=2, style=line.style_dashed)
    label.new(bar_index + 10, slP, "SL",
         style=label.style_label_left, color=color.new(bearColor, 0),
         textcolor=color.white, size=size.tiny)
    label.new(bar_index + 10, tpP, "TP",
         style=label.style_label_left, color=color.new(bullColor, 0),
         textcolor=color.white, size=size.tiny)

if showLevels and filteredBear
    slP = high + slDist
    tpP = close - tpDist
    line.new(bar_index, slP, bar_index + 10, slP,
         color=color.new(bearColor, 0), width=2, style=line.style_dashed)
    line.new(bar_index, tpP, bar_index + 10, tpP,
         color=color.new(bullColor, 0), width=2, style=line.style_dashed)
    label.new(bar_index + 10, slP, "SL",
         style=label.style_label_left, color=color.new(bearColor, 0),
         textcolor=color.white, size=size.tiny)
    label.new(bar_index + 10, tpP, "TP",
         style=label.style_label_left, color=color.new(bullColor, 0),
         textcolor=color.white, size=size.tiny)

// ══════════════════════════════════════════════
//  CANDLE RENDERING
// ══════════════════════════════════════════════
candleColor = filteredBull ? smcColor : filteredBear ? smcColor : isSmartBull ? color.new(smcColor, 40) : isSmartBear ? color.new(smcColor, 40) : isBullMom ? bullColor : isBearMom ? bearColor : close >= open ? neutralBull : neutralBear
wickColor   = isSmartMoney ? smcColor : isMomCandle ? candleColor : color.new(color.gray, 65)

plotcandle(open, high, low, close,
     title="Candle", color=candleColor,
     wickcolor=wickColor, bordercolor=candleColor)

// ══════════════════════════════════════════════
//  SHAPES & MARKERS
// ══════════════════════════════════════════════
plotshape(filteredBull, title="✅ Confirmed Long",
     style=shape.flag, location=location.belowbar,
     color=smcColor, size=size.normal)

plotshape(filteredBear, title="✅ Confirmed Short",
     style=shape.flag, location=location.abovebar,
     color=smcColor, size=size.normal)

plotshape(isSmartBull and not filteredBull, title="Smart Bull",
     style=shape.triangleup, location=location.belowbar,
     color=bullColor, size=size.small)

plotshape(isSmartBear and not filteredBear, title="Smart Bear",
     style=shape.triangledown, location=location.abovebar,
     color=bearColor, size=size.small)

plotshape(showAbsorb and isAbsorption, title="Absorption",
     style=shape.circle, location=location.abovebar,
     color=color.new(#00bcd4, 20), size=size.tiny)

plotshape(showTrap and isBullTrap, title="Bull Trap",
     style=shape.xcross, location=location.belowbar,
     color=color.new(#ff9800, 0), size=size.small)

plotshape(showTrap and isBearTrap, title="Bear Trap",
     style=shape.xcross, location=location.abovebar,
     color=color.new(#ff9800, 0), size=size.small)

plotshape(isVolSpike and not isMomCandle, title="Vol Spike",
     style=shape.diamond, location=location.belowbar,
     color=color.new(#ce93d8, 0), size=size.tiny)

// Score label on smart money candles
if isSmartMoney
    lY     = isSmartBull ? low - atrVal * 0.5 : high + atrVal * 0.5
    lStyle = isSmartBull ? label.style_label_up : label.style_label_down
    label.new(bar_index, lY, "⚡" + str.tostring(score),
         style=lStyle, color=color.new(smcColor, 20),
         textcolor=color.black, size=size.small)

// ══════════════════════════════════════════════
//  BACKGROUND
// ══════════════════════════════════════════════
bgcolor(filteredBull ? color.new(smcColor, 85) : filteredBear ? color.new(smcColor, 85) : isBullMom ? color.new(bullColor, 92) : isBearMom ? color.new(bearColor, 92) : na)

// ══════════════════════════════════════════════
//  DASHBOARD — גדול ומורחב
// ══════════════════════════════════════════════
tablePos = dashPos == "Top Right"    ? position.top_right    :
           dashPos == "Top Left"     ? position.top_left     :
           dashPos == "Bottom Right" ? position.bottom_right :
           position.bottom_left

var table dash = table.new(tablePos, 3, 14,
     bgcolor       = color.new(#0a0a0f, 55),
     border_color  = color.new(#333355, 30),
     border_width  = 1,
     frame_color   = color.new(#5555ff, 40),
     frame_width   = 2)

if showDash and barstate.islast

    // ── HEADER ──────────────────────────────
    table.cell(dash, 0, 0, "SMC Ultra",
         text_color=smcColor, text_size=size.normal,
         bgcolor=color.new(#111133, 60), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.tickerid,
         text_color=color.white, text_size=size.normal,
         bgcolor=color.new(#111133, 60), text_halign=text.align_center)
    table.cell(dash, 2, 0, timeframe.period + "m",
         text_color=color.new(#aaaaaa, 0), text_size=size.normal,
         bgcolor=color.new(#111133, 60), text_halign=text.align_center)

    // ── SCORE ───────────────────────────────
    scoreColor = score >= 70 ? smcColor : score >= 40 ? color.orange : color.gray
    scoreBar   = score >= 70 ? "████████" : score >= 50 ? "█████░░░" : score >= 30 ? "███░░░░░" : "█░░░░░░░"
    table.cell(dash, 0, 1, "⚡ SCORE",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(score) + " / 100",
         text_color=scoreColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 1, scoreBar,
         text_color=scoreColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── SIGNAL ──────────────────────────────
    sigText  = filteredBull ? "▲  LONG" : filteredBear ? "▼  SHORT" : "⏸  WAIT"
    sigColor = filteredBull ? bullColor  : filteredBear ? bearColor   : color.gray
    sigBg    = filteredBull ? color.new(#003300, 40) : filteredBear ? color.new(#330000, 40) : color.new(#1a1a1a, 40)
    table.cell(dash, 0, 2, "🎯 SIGNAL",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=sigBg, text_halign=text.align_left)
    table.cell(dash, 1, 2, sigText,
         text_color=sigColor, text_size=size.normal,
         bgcolor=sigBg, text_halign=text.align_center)
    table.cell(dash, 2, 2, filteredBull or filteredBear ? "✔ CONFIRMED" : "─",
         text_color=filteredBull or filteredBear ? smcColor : color.gray,
         text_size=size.small, bgcolor=sigBg, text_halign=text.align_center)

    // ── RSI ─────────────────────────────────
    rsiColor = rsiVal > rsiOB ? bearColor : rsiVal < rsiOS ? bullColor : color.white
    rsiText  = rsiVal > rsiOB ? "⚠ OVERBOUGHT" : rsiVal < rsiOS ? "⚠ OVERSOLD" : "NEUTRAL"
    table.cell(dash, 0, 3, "📉 RSI",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(rsiVal, 1)),
         text_color=rsiColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 3, rsiText,
         text_color=rsiColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── VOLUME ──────────────────────────────
    volColor = isVolSpike ? smcColor : color.white
    table.cell(dash, 0, 4, "🐋 VOL RATIO",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(volume / avgVol, 2)) + "×",
         text_color=volColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 4, isVolSpike ? "🔥 SPIKE" : "NORMAL",
         text_color=volColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── DELTA ───────────────────────────────
    deltaColor = volDelta > 0 ? bullColor : bearColor
    deltaText  = volDelta > 0 ? "▲  BUY PRESSURE" : "▼  SELL PRESSURE"
    table.cell(dash, 0, 5, "📊 VOL DELTA",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 5, volDelta > 0 ? "▲ BUY" : "▼ SELL",
         text_color=deltaColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 5, deltaText,
         text_color=deltaColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── HTF TREND ───────────────────────────
    htfColor = htfClose > htfEMA ? bullColor : bearColor
    htfText  = htfClose > htfEMA ? "▲  BULLISH" : "▼  BEARISH"
    table.cell(dash, 0, 6, "📅 HTF TREND",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 6, htfText,
         text_color=htfColor, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 6, htfTF + " EMA20",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── ATR ─────────────────────────────────
    table.cell(dash, 0, 7, "📏 ATR (14)",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(math.round(atrVal, 5)),
         text_color=color.white, text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 7, "VOLATILITY",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)

    // ── SL ──────────────────────────────────
    table.cell(dash, 0, 8, "🛑 STOP LOSS",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#1a0000, 50), text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(math.round(slDist, 5)),
         text_color=bearColor, text_size=size.small,
         bgcolor=color.new(#1a0000, 50), text_halign=text.align_center)
    table.cell(dash, 2, 8, str.tostring(math.round(slMult, 1)) + "× ATR",
         text_color=bearColor, text_size=size.small,
         bgcolor=color.new(#1a0000, 50), text_halign=text.align_center)

    // ── TP ──────────────────────────────────
    table.cell(dash, 0, 9, "🎯 TAKE PROFIT",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#001a00, 50), text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(math.round(tpDist, 5)),
         text_color=bullColor, text_size=size.small,
         bgcolor=color.new(#001a00, 50), text_halign=text.align_center)
    table.cell(dash, 2, 9, str.tostring(math.round(rrRatio, 1)) + "× SL",
         text_color=bullColor, text_size=size.small,
         bgcolor=color.new(#001a00, 50), text_halign=text.align_center)

    // ── R:R ─────────────────────────────────
    table.cell(dash, 0, 10, "⚖️  R : R",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 10, "1  :  " + str.tostring(rrRatio),
         text_color=smcColor, text_size=size.normal,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_center)
    table.cell(dash, 2, 10, rrRatio >= 2.0 ? "✔ GOOD" : "⚠ LOW",
         text_color=rrRatio >= 2.0 ? bullColor : color.orange,
         text_size=size.small, bgcolor=color.new(#0d0d1a, 50),
         text_halign=text.align_center)

    // ── PRICE ───────────────────────────────
    table.cell(dash, 0, 11, "💲 PRICE",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 11, str.tostring(close),
         text_color=close >= open ? bullColor : bearColor,
         text_size=size.small, bgcolor=color.new(#0d0d1a, 50),
         text_halign=text.align_center)
    table.cell(dash, 2, 11, close >= open ? "▲" : "▼",
         text_color=close >= open ? bullColor : bearColor,
         text_size=size.normal, bgcolor=color.new(#0d0d1a, 50),
         text_halign=text.align_center)

    // ── ABSORPTION / TRAP STATUS ─────────────
    table.cell(dash, 0, 12, "🧽 ABSORPTION",
         text_color=color.new(#aaaaaa,0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 50), text_halign=text.align_left)
    table.cell(dash, 1, 12, isAbsorption ? "⚠ DETECTED" : "─ NONE",
         text_color=isAbsorption ? color.new(#00bcd4,0) : color.gray,
         text_size=size.small, bgcolor=color.new(#0d0d1a, 50),
         text_halign=text.align_center)
    table.cell(dash, 2, 12, isBullTrap ? "🪤 BULL TRAP" : isBearTrap ? "🪤 BEAR TRAP" : "─",
         text_color=isBullTrap or isBearTrap ? color.new(#ff9800,0) : color.gray,
         text_size=size.small, bgcolor=color.new(#0d0d1a, 50),
         text_halign=text.align_center)

    // ── FOOTER ──────────────────────────────
    table.cell(dash, 0, 13, "Smart Money Candles",
         text_color=color.new(#555577,0), text_size=size.tiny,
         bgcolor=color.new(#070710, 60), text_halign=text.align_left)
    table.cell(dash, 1, 13, "Ahmad Jabarin",
         text_color=color.new(#555577,0), text_size=size.tiny,
         bgcolor=color.new(#070710, 60), text_halign=text.align_center)
    table.cell(dash, 2, 13, "v3.0",
         text_color=color.new(#555577,0), text_size=size.tiny,
         bgcolor=color.new(#070710, 60), text_halign=text.align_center)
// ══════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════
newFilteredBull = filteredBull and not filteredBull[1]
newFilteredBear = filteredBear and not filteredBear[1]

if alertBull and newFilteredBull
    alert("🟢 CONFIRMED LONG — " + syminfo.tickerid + " | Score: " + str.tostring(score) + "/100 | RSI: " + str.tostring(math.round(rsiVal, 1)) + " | HTF: " + (htfClose > htfEMA ? "BULL" : "BEAR") + " | Vol: " + str.tostring(math.round(volume / avgVol, 1)) + "×", alert.freq_once_per_bar_close)

if alertBear and newFilteredBear
    alert("🔴 CONFIRMED SHORT — " + syminfo.tickerid + " | Score: " + str.tostring(score) + "/100 | RSI: " + str.tostring(math.round(rsiVal, 1)) + " | HTF: " + (htfClose > htfEMA ? "BULL" : "BEAR") + " | Vol: " + str.tostring(math.round(volume / avgVol, 1)) + "×", alert.freq_once_per_bar_close)

alertcondition(filteredBull,  title="✅ Confirmed LONG",   message="CONFIRMED LONG on {{ticker}} | All filters passed | {{close}}")
alertcondition(filteredBear,  title="✅ Confirmed SHORT",  message="CONFIRMED SHORT on {{ticker}} | All filters passed | {{close}}")
alertcondition(isSmartBull,   title="Smart Money Bull",    message="Smart Money BULL on {{ticker}} | {{close}}")
alertcondition(isSmartBear,   title="Smart Money Bear",    message="Smart Money BEAR on {{ticker}} | {{close}}")
alertcondition(isAbsorption,  title="Absorption",          message="Whale Absorption on {{ticker}}")
alertcondition(isBullTrap,    title="Bull Wick Trap",      message="Stop Hunt DOWN on {{ticker}} — reversal UP")
alertcondition(isBearTrap,    title="Bear Wick Trap",      message="Stop Hunt UP on {{ticker}} — reversal DOWN")
alertcondition(bullFVG,       title="Bullish FVG",         message="Bullish FVG on {{ticker}}")
alertcondition(bearFVG,       title="Bearish FVG",         message="Bearish FVG on {{ticker}}")
````
