# SoSa Smart Trend Pro

- url: https://www.tradingview.com/script/ulTws6m4-SoSa-Smart-Trend-Pro/
- type: indicator
- pine_id: PUB;b4637f5f49914cdc9a99461ace0e5c17
- version: 1.0

## Description

SoSa Smart Trend Pro
Advanced All-in-One Trading Indicator

SoSa Smart Trend Pro is a powerful institutional-grade trading indicator designed to help traders identify high-probability opportunities through advanced trend analysis, volume confirmation, momentum filters, Fair Value Gap detection, market structure analysis, and session-based trading tools.

Built for Forex, Stocks, Futures, Indices, and Cryptocurrency markets, SoSa Smart Trend Pro combines multiple professional trading concepts into a single indicator, allowing traders to make faster, smarter, and more confident decisions.

🚀 Core Features
📈 Advanced Trend Detection

Choose from multiple moving average types:

EMA
SMA
WMA
VWMA
RMA
HMA
DEMA
TEMA
Bollinger Basis

The moving average dynamically changes color to instantly identify market conditions:

🟢 Bullish Trend

🔴 Bearish Trend

🟡 Neutral Market

🕯️ Smart Engulfing Pattern Detection

Automatically detects:

Bullish Engulfing Patterns
Bearish Engulfing Patterns

Advanced body-size filtering helps eliminate weak setups and highlights stronger reversal opportunities.

📊 Volume Confirmation System

Filters market signals using real-time volume analysis.

Features include:

Volume SMA comparison
Adjustable volume multiplier
High-volume breakout confirmation

Helping traders avoid low-quality entries during weak market participation.

⚡ Institutional Fair Value Gap Detection

Automatically identifies market imbalances used by professional traders.

Includes:

Bullish Fair Value Gaps
Bearish Fair Value Gaps
ATR-based minimum gap sizing
Adjustable zone extensions
Dynamic FVG management

Ideal for identifying retracements, continuation setups, and liquidity zones.

🗽 New York Session Tracker

Monitor the most active trading session with:

Automatic New York Session Box
Session High & Low Tracking
Session Labels
Extended High/Low Levels

Perfect for traders who focus on market open volatility and liquidity sweeps.

🔵 Dynamic Support & Resistance Levels

Automatically plots key market structure zones based on pivot analysis.

Benefits:

Identifies potential reversal areas
Highlights important reaction zones
Improves entry and exit timing
📉 RSI Momentum Filter

Built-in Relative Strength Index analysis:

Custom RSI Length
Overbought Detection
Oversold Detection
Trade Confirmation Filter

Adds an additional layer of momentum validation.

〰️ MACD Confirmation Engine

Uses MACD crossover and histogram strength to confirm momentum.

Detects:

Bullish Momentum
Bearish Momentum
Trend Continuation Opportunities

Reducing false entries and increasing signal quality.

〰️ Bollinger Bands Integration

Monitor market volatility with built-in Bollinger Bands.

Features:

Adjustable Length
Adjustable Deviation Multiplier
Volatility Expansion Detection

Useful for breakout and mean-reversion strategies.

🎯 Smart Buy & Sell Signals

Signals are generated only when multiple confirmations align.

Signal conditions may include:

✅ Trend Direction

✅ Moving Average Confirmation

✅ Engulfing Pattern Detection

✅ Volume Confirmation

✅ RSI Validation

✅ MACD Confirmation

This multi-layer approach helps filter market noise and improve trade quality.

📊 Confidence Score Technology

Every trade signal includes a confidence rating from 0% to 100%.

The score is calculated using:

Trend Strength
Volume Activity
Fair Value Gap Confirmation
Engulfing Patterns
MACD Momentum
Price Structure Alignment

Allowing traders to quickly assess the quality of each setup.

🖥️ Professional Market Dashboard

The integrated information panel displays:

Market Trend
Volume Status
RSI Condition
MACD Status
Fair Value Gap Activity
New York Session Status
Confidence Score
Current Trading Signal

All critical market information is available in one location.

🔔 Real-Time Trading Alerts

Receive alerts for:

Buy Signals
Sell Signals
RSI Overbought Conditions
RSI Oversold Conditions
Bullish FVG Detection
Bearish FVG Detection
New York Session Open

Stay connected to the market without constantly watching the chart.

💎 Why Traders Choose SoSa Smart Trend Pro

✔ Combines multiple indicators into one

✔ Reduces chart clutter

✔ Improves signal quality

✔ Identifies institutional market imbalances

✔ Tracks trend, momentum, volume, and volatility

✔ Provides confidence-based trade scoring

✔ Suitable for scalpers, day traders, swing traders, and position traders

✔ Works across Forex, Crypto, Stocks, Futures, and Indices

Trade Smarter. Trade With Confidence.

SoSa Smart Trend Pro is built to provide a complete market analysis solution, combining trend identification, momentum confirmation, institutional concepts, and intelligent signal generation into one professional-grade trading tool. 📈🔥

Tagline:
"See the Trend. Trust the Signal. Trade with Confidence." 🚀

## Source Code

````pine
//@version=5
indicator("SmartTrend Pro v3", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════
//  MOVING AVERAGE
// ═══════════════════════════════════════════════════════
grpMA       = "📈 Moving Average"
showMA      = input.bool(true, "Show Moving Average", group=grpMA)
maType      = input.string("EMA", "MA Type", group=grpMA, options=["EMA","SMA","WMA","VWMA","RMA","HMA","DEMA","TEMA","Bollinger Basis"])
maLen       = input.int(21, "Length", minval=1, group=grpMA)
maBullColor = input.color(color.new(#00e676, 0), "Bull Color", group=grpMA)
maBearColor = input.color(color.new(#ff1744, 0), "Bear Color", group=grpMA)
maNeutColor = input.color(color.new(#ffea00, 0), "Neutral Color", group=grpMA)

// ═══════════════════════════════════════════════════════
//  ENGULFING CANDLES
// ═══════════════════════════════════════════════════════
grpEng        = "🕯️ Engulfing Candles"
showEngulfing = input.bool(true, "Show Engulfing", group=grpEng)
engBodyMult   = input.float(1.1, "Min Body Size Multiplier", group=grpEng, step=0.05)

// ═══════════════════════════════════════════════════════
//  VOLUME
// ═══════════════════════════════════════════════════════
grpVol     = "📊 Volume"
showVolume = input.bool(true, "Volume Confirmation", group=grpVol)
volMulti   = input.float(1.2, "Volume Multiplier (x SMA)", group=grpVol, step=0.1)
volLen     = input.int(20, "Volume SMA Length", group=grpVol)

// ═══════════════════════════════════════════════════════
//  FAIR VALUE GAP
// ═══════════════════════════════════════════════════════
grpFVG      = "⚡ Fair Value Gap"
showFVG     = input.bool(true,  "Show FVG", group=grpFVG)
fvgMaxCount = input.int(3, "Max FVGs on chart (1–10)", group=grpFVG, minval=1, maxval=10)
fvgExtend   = input.int(30, "Extend boxes (bars)", group=grpFVG, minval=1, maxval=200)
fvgBullClr  = input.color(color.new(#00e676, 75), "Bull FVG Color", group=grpFVG)
fvgBearClr  = input.color(color.new(#ff1744, 75), "Bear FVG Color", group=grpFVG)
fvgShowBull = input.bool(true, "Show Bullish FVGs", group=grpFVG)
fvgShowBear = input.bool(true, "Show Bearish FVGs", group=grpFVG)
fvgMinSize  = input.float(0.3, "Min FVG size (ATR x)", group=grpFVG, step=0.05)

// ═══════════════════════════════════════════════════════
//  NEW YORK SESSION
// ═══════════════════════════════════════════════════════
grpNY       = "🗽 New York Session"
showNY      = input.bool(true, "Show NY Session Box", group=grpNY)
nyStart     = input.string("0930-1700", "NY Session Time (Exchange TZ)", group=grpNY)
nyBoxColor  = input.color(color.new(#1565c0, 85), "Box Background", group=grpNY)
nyBorderClr = input.color(color.new(#42a5f5, 60), "Box Border", group=grpNY)
nyLabelClr  = input.color(color.new(#42a5f5, 0),  "Label Color", group=grpNY)
nyShowLabel = input.bool(true, "Show Label", group=grpNY)
nyShowHL    = input.bool(true, "Show High/Low Lines", group=grpNY)
nyHLColor   = input.color(color.new(#ffffff, 60), "High/Low Line Color", group=grpNY)

// ═══════════════════════════════════════════════════════
//  SUPPORT & RESISTANCE
// ═══════════════════════════════════════════════════════
grpSR    = "🔵 Support & Resistance"
showSR   = input.bool(true, "Show S&R Levels", group=grpSR)
srLen    = input.int(20, "Pivot Length", group=grpSR, minval=5)
srBullCl = input.color(color.new(#00e676, 70), "Support Color", group=grpSR)
srBearCl = input.color(color.new(#ff1744, 70), "Resistance Color", group=grpSR)

// ═══════════════════════════════════════════════════════
//  RSI FILTER
// ═══════════════════════════════════════════════════════
grpRSI  = "📉 RSI Filter"
showRSI = input.bool(true, "Use RSI Filter", group=grpRSI)
rsiLen  = input.int(14, "RSI Length", group=grpRSI)
rsiOB   = input.int(70, "Overbought Level", group=grpRSI)
rsiOS   = input.int(30, "Oversold Level", group=grpRSI)

// ═══════════════════════════════════════════════════════
//  MACD FILTER
// ═══════════════════════════════════════════════════════
grpMACD  = "〰️ MACD Filter"
useMACD  = input.bool(true, "Use MACD Confirmation", group=grpMACD)
macdFast = input.int(12, "MACD Fast", group=grpMACD)
macdSlow = input.int(26, "MACD Slow", group=grpMACD)
macdSig  = input.int(9,  "MACD Signal", group=grpMACD)

// ═══════════════════════════════════════════════════════
//  BOLLINGER BANDS
// ═══════════════════════════════════════════════════════
grpBB    = "〰️ Bollinger Bands"
showBB   = input.bool(true, "Show Bollinger Bands", group=grpBB)
bbLen    = input.int(20, "BB Length", group=grpBB)
bbMult   = input.float(2.0, "BB Multiplier", group=grpBB, step=0.1)
bbUpClr  = input.color(color.new(#2962ff, 80), "BB Upper Color", group=grpBB)
bbLowClr = input.color(color.new(#2962ff, 80), "BB Lower Color", group=grpBB)

// ═══════════════════════════════════════════════════════
//  SIGNALS
// ═══════════════════════════════════════════════════════
grpSig      = "🎯 Signals"
showSignals = input.bool(true, "Show Signals", group=grpSig)

// ═══════════════════════════════════════════════════════
//  PANEL
// ═══════════════════════════════════════════════════════
grpPanel  = "🖥️ Info Panel"
showPanel = input.bool(true, "Show Panel", group=grpPanel)

// ═══════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════
grpAlert     = "🔔 Alerts"
enableAlerts = input.bool(true, "Enable Alerts", group=grpAlert)

// ═══════════════════════════════════════════════════════
//  MA FUNCTIONS
// ═══════════════════════════════════════════════════════

hma(src, len) =>
    ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))

dema(src, len) =>
    e1 = ta.ema(src, len)
    2 * e1 - ta.ema(e1, len)

tema(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    3 * e1 - 3 * e2 + e3

maValue = switch maType
    "EMA"             => ta.ema(close, maLen)
    "SMA"             => ta.sma(close, maLen)
    "WMA"             => ta.wma(close, maLen)
    "VWMA"            => ta.vwma(close, maLen)
    "RMA"             => ta.rma(close, maLen)
    "HMA"             => hma(close, maLen)
    "DEMA"            => dema(close, maLen)
    "TEMA"            => tema(close, maLen)
    "Bollinger Basis" => ta.sma(close, maLen)
    =>                   ta.ema(close, maLen)

maDelta     = maValue - maValue[1]
maDelta2    = maValue[1] - maValue[2]
isBullTrend = close > maValue and maDelta > 0 and maDelta2 > 0
isBearTrend = close < maValue and maDelta < 0 and maDelta2 < 0
maColor     = isBullTrend ? maBullColor : isBearTrend ? maBearColor : maNeutColor

// UN solo plot — genera exactamente Color 0, 1, 2 (bull, bear, neutral)
plot(showMA ? maValue : na, "MA", color=maColor, linewidth=2)

// ═══════════════════════════════════════════════════════
//  BOLLINGER BANDS — dos plots = Color 0 y Color 1 del grupo BB
// ═══════════════════════════════════════════════════════

bbBasis   = ta.sma(close, bbLen)
bbDev     = bbMult * ta.stdev(close, bbLen)
bbUpper   = bbBasis + bbDev
bbLower   = bbBasis - bbDev

bbUpPlot  = plot(showBB ? bbUpper : na, "BB Upper", color=bbUpClr,  linewidth=1)
bbLowPlot = plot(showBB ? bbLower : na, "BB Lower", color=bbLowClr, linewidth=1)
fill(bbUpPlot, bbLowPlot, color=color.new(#2962ff, 93))

// ═══════════════════════════════════════════════════════
//  RSI
// ═══════════════════════════════════════════════════════

rsiVal        = ta.rsi(close, rsiLen)
rsiOkBuy      = showRSI ? rsiVal < rsiOB and rsiVal > rsiOS : true
rsiOkSell     = showRSI ? rsiVal > rsiOS and rsiVal < rsiOB : true
rsiOversold   = rsiVal <= rsiOS
rsiOverbought = rsiVal >= rsiOB

// ═══════════════════════════════════════════════════════
//  MACD
// ═══════════════════════════════════════════════════════

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBull = useMACD ? macdLine > signalLine and histLine > 0 : true
macdBear = useMACD ? macdLine < signalLine and histLine < 0 : true

// ═══════════════════════════════════════════════════════
//  ENGULFING
// ═══════════════════════════════════════════════════════

prevBody   = math.abs(close[1] - open[1])
currBody   = math.abs(close - open)
bullEngulf = close[1] < open[1] and close > open and open < close[1] and close > open[1] and currBody > prevBody * engBodyMult
bearEngulf = close[1] > open[1] and close < open and open > close[1] and close < open[1] and currBody > prevBody * engBodyMult

// ═══════════════════════════════════════════════════════
//  VOLUME
// ═══════════════════════════════════════════════════════

volSMA     = ta.sma(volume, volLen)
highVolume = volume > volSMA * volMulti

// ═══════════════════════════════════════════════════════
//  FAIR VALUE GAP
// ═══════════════════════════════════════════════════════

atr14 = ta.atr(14)

bullFVGraw = fvgShowBull and high[2] < low[0] and (close[1] - open[1]) > atr14[1] * fvgMinSize
bearFVGraw = fvgShowBear and low[2] > high[0] and (open[1] - close[1]) > atr14[1] * fvgMinSize

var array<box> bullBoxes = array.new<box>()
var array<box> bearBoxes = array.new<box>()

bullFVG = false
bearFVG = false

if showFVG and bullFVGraw
    newBox = box.new(bar_index - 2, low[0], bar_index + fvgExtend, high[2],
         border_color=color.new(#00e676, 30), border_width=1, bgcolor=fvgBullClr)
    array.push(bullBoxes, newBox)
    if array.size(bullBoxes) > fvgMaxCount
        box.delete(array.shift(bullBoxes))
    bullFVG := true

if showFVG and bearFVGraw
    newBox = box.new(bar_index - 2, low[2], bar_index + fvgExtend, high[0],
         border_color=color.new(#ff1744, 30), border_width=1, bgcolor=fvgBearClr)
    array.push(bearBoxes, newBox)
    if array.size(bearBoxes) > fvgMaxCount
        box.delete(array.shift(bearBoxes))
    bearFVG := true

// ═══════════════════════════════════════════════════════
//  NEW YORK SESSION BOX
// ═══════════════════════════════════════════════════════

inNY = not na(time(timeframe.period, nyStart))

var int   nyBarStart = na
var float nyHigh     = na
var float nyLow      = na
var box   nyBox      = na
var line  nyHLine    = na
var line  nyLLine    = na
var label nyLbl      = na

nyOpen  = inNY and not inNY[1]
nyClose = not inNY and inNY[1]

if showNY
    if nyOpen
        nyBarStart := bar_index
        nyHigh     := high
        nyLow      := low
        nyBox      := box.new(bar_index, high, bar_index + 1, low,
             border_color=nyBorderClr, border_width=1,
             bgcolor=nyBoxColor, border_style=line.style_dashed)
        if nyShowLabel
            nyLbl := label.new(bar_index, high, "🗽 New York",
                 style=label.style_label_down,
                 color=color.new(#1565c0, 60),
                 textcolor=nyLabelClr, size=size.small)

    if inNY and not na(nyBox)
        nyHigh := math.max(nyHigh, high)
        nyLow  := math.min(nyLow,  low)
        box.set_right(nyBox,  bar_index + 1)
        box.set_top(nyBox,    nyHigh)
        box.set_bottom(nyBox, nyLow)
        if nyShowLabel and not na(nyLbl)
            label.set_x(nyLbl, nyBarStart)
            label.set_y(nyLbl, nyHigh)

    if nyClose and nyShowHL and not na(nyBox)
        if not na(nyHLine)
            line.delete(nyHLine)
        if not na(nyLLine)
            line.delete(nyLLine)
        nyHLine := line.new(nyBarStart, nyHigh, bar_index, nyHigh,
             color=nyHLColor, width=1, style=line.style_dotted)
        nyLLine := line.new(nyBarStart, nyLow, bar_index, nyLow,
             color=nyHLColor, width=1, style=line.style_dotted)

// ═══════════════════════════════════════════════════════
//  SUPPORT & RESISTANCE
// ═══════════════════════════════════════════════════════

pivHigh = ta.pivothigh(high, srLen, srLen)
pivLow  = ta.pivotlow(low, srLen, srLen)

if showSR and not na(pivHigh)
    line.new(bar_index - srLen, pivHigh, bar_index + srLen, pivHigh,
         color=srBearCl, width=1, style=line.style_dashed)

if showSR and not na(pivLow)
    line.new(bar_index - srLen, pivLow, bar_index + srLen, pivLow,
         color=srBullCl, width=1, style=line.style_dashed)

// ═══════════════════════════════════════════════════════
//  SIGNAL LOGIC
// ═══════════════════════════════════════════════════════

priceClearlyAbove = close > maValue and low  > maValue
priceClearlyBelow = close < maValue and high < maValue
emaBullStreak     = maDelta > 0 and maDelta2 > 0
emaBearStreak     = maDelta < 0 and maDelta2 < 0

engOkBuy  = showEngulfing ? bullEngulf : true
volOkBuy  = showVolume    ? highVolume : true
buySignal = priceClearlyAbove and emaBullStreak and engOkBuy and volOkBuy and rsiOkBuy and macdBull

engOkSell  = showEngulfing ? bearEngulf : true
volOkSell  = showVolume    ? highVolume : true
sellSignal = priceClearlyBelow and emaBearStreak and engOkSell and volOkSell and rsiOkSell and macdBear

buyScore  = (priceClearlyAbove ? 17 : 0) + (emaBullStreak ? 17 : 0) + (bullEngulf ? 17 : 0) + (highVolume ? 16 : 0) + (bullFVG ? 16 : 0) + (macdBull ? 17 : 0)
sellScore = (priceClearlyBelow ? 17 : 0) + (emaBearStreak ? 17 : 0) + (bearEngulf ? 17 : 0) + (highVolume ? 16 : 0) + (bearFVG ? 16 : 0) + (macdBear ? 17 : 0)
confidence = buySignal ? math.min(buyScore, 100) : sellSignal ? math.min(sellScore, 100) : 0

// ═══════════════════════════════════════════════════════
//  SIGNAL VISUALS
// ═══════════════════════════════════════════════════════

atr = ta.atr(14)

if showSignals and buySignal
    label.new(bar_index, low - atr * 0.3,
         "▲  BUY  " + str.tostring(confidence) + "%",
         style=label.style_label_up, color=color.new(#00c853, 0),
         textcolor=color.white, size=size.small)

if showSignals and sellSignal
    label.new(bar_index, high + atr * 0.3,
         "▼  SELL  " + str.tostring(confidence) + "%",
         style=label.style_label_down, color=color.new(#ff1744, 0),
         textcolor=color.white, size=size.small)

plotshape(showSignals and buySignal,  "BUY",  shape.triangleup,   location.belowbar, color.new(#00c853, 0), size=size.small)
plotshape(showSignals and sellSignal, "SELL", shape.triangledown, location.abovebar, color.new(#ff1744, 0), size=size.small)
plotshape(rsiOversold,   "RSI Oversold",   shape.diamond, location.belowbar, color.new(#00e5ff, 0), size=size.tiny)
plotshape(rsiOverbought, "RSI Overbought", shape.diamond, location.abovebar, color.new(#ff6d00, 0), size=size.tiny)

// ═══════════════════════════════════════════════════════
//  INFO PANEL
// ═══════════════════════════════════════════════════════

var table infoPanel = table.new(position.top_right, 2, 9,
     bgcolor=color.new(#0a0a0f, 5), border_color=color.new(#2a2a3a, 0),
     border_width=1, frame_color=color.new(#3a3a5a, 0), frame_width=1)

if showPanel
    table.cell(infoPanel, 0, 0, "SmartTrend Pro v3",
         text_color=color.new(#7b8cff, 0), bgcolor=color.new(#0d0d1f, 0), text_size=size.small)
    table.cell(infoPanel, 1, 0, maType + " " + str.tostring(maLen),
         text_color=color.new(#aaaacc, 0), bgcolor=color.new(#0d0d1f, 0), text_size=size.small)

    trendTxt   = isBullTrend ? "▲ Bullish" : isBearTrend ? "▼ Bearish" : "→ Neutral"
    trendColor = isBullTrend ? maBullColor : isBearTrend ? maBearColor : maNeutColor
    table.cell(infoPanel, 0, 1, "Trend",  text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 1, trendTxt, text_color=trendColor,            text_size=size.small)

    volTxt   = highVolume ? "● High" : "○ Normal"
    volColor = highVolume ? color.new(#00e676, 0) : color.new(#888899, 0)
    table.cell(infoPanel, 0, 2, "Volume", text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 2, volTxt,   text_color=volColor,              text_size=size.small)

    rsiTxt   = rsiOverbought ? "Overbought" : rsiOversold ? "Oversold" : str.tostring(math.round(rsiVal))
    rsiColor = rsiOverbought ? color.new(#ff6d00, 0) : rsiOversold ? color.new(#00e5ff, 0) : color.new(#aaaacc, 0)
    table.cell(infoPanel, 0, 3, "RSI",  text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 3, rsiTxt, text_color=rsiColor,              text_size=size.small)

    macdTxt   = macdBull ? "▲ Bull Cross" : macdBear ? "▼ Bear Cross" : "— Neutral"
    macdColor = macdBull ? color.new(#00e676, 0) : macdBear ? color.new(#ff1744, 0) : color.new(#888899, 0)
    table.cell(infoPanel, 0, 4, "MACD",   text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 4, macdTxt,  text_color=macdColor,             text_size=size.small)

    fvgTxt   = bullFVG ? "▲ Bull FVG" : bearFVG ? "▼ Bear FVG" : "— None"
    fvgColor = bullFVG ? color.new(#00e676, 0) : bearFVG ? color.new(#ff1744, 0) : color.new(#555566, 0)
    table.cell(infoPanel, 0, 5, "FVG",   text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 5, fvgTxt,  text_color=fvgColor,              text_size=size.small)

    nyTxt   = inNY ? "🗽 Active" : "— Closed"
    nyColor = inNY ? color.new(#42a5f5, 0) : color.new(#555566, 0)
    table.cell(infoPanel, 0, 6, "NY Session", text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 6, nyTxt,        text_color=nyColor,               text_size=size.small)

    confTxt   = str.tostring(confidence) + "% Confidence"
    confColor = confidence >= 75 ? color.new(#00e676, 0) : confidence >= 50 ? color.new(#ffea00, 0) : color.new(#ff1744, 0)
    table.cell(infoPanel, 0, 7, "Score",  text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 7, confTxt,  text_color=confColor,             text_size=size.small)

    sigTxt   = buySignal ? "▲ BUY" : sellSignal ? "▼ SELL" : "— WAIT"
    sigColor = buySignal ? color.new(#00e676, 0) : sellSignal ? color.new(#ff1744, 0) : color.new(#ffea00, 0)
    table.cell(infoPanel, 0, 8, "Signal", text_color=color.new(#888899, 0), text_size=size.small)
    table.cell(infoPanel, 1, 8, sigTxt,   text_color=sigColor,              text_size=size.small)

// ═══════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════

alertcondition(enableAlerts and buySignal,    "SmartTrend — BUY",           "BUY Signal detected")
alertcondition(enableAlerts and sellSignal,   "SmartTrend — SELL",          "SELL Signal detected")
alertcondition(enableAlerts and rsiOversold,  "SmartTrend — RSI Oversold",  "RSI Oversold — Possible reversal up")
alertcondition(enableAlerts and rsiOverbought,"SmartTrend — RSI Overbought","RSI Overbought — Possible reversal down")
alertcondition(enableAlerts and bullFVG,      "SmartTrend — Bull FVG",      "Bullish FVG detected")
alertcondition(enableAlerts and bearFVG,      "SmartTrend — Bear FVG",      "Bearish FVG detected")
alertcondition(enableAlerts and nyOpen,       "SmartTrend — NY Open",       "New York Session has opened")
````
