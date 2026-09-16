<!-- tradingview-pine-id: PUB;d4ac0bbd6b614082ade006d27b22cba6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FIA Trend + Momentum 10/20/50

Source: https://www.tradingview.com/script/ejmic683-FIA-Trend-Momentum-10-20-50/

## Description

Für TradingView würde ich die Beschreibung auf Englisch halten und klar erklären, was der Indikator macht, ohne ihn als „Trading-System“ zu verkaufen.

## FIA Trend + Momentum 10/20/50

The **FIA Trend + Momentum 10/20/50** indicator combines short-term EMA trend structure with RSI, MACD and Higher Timeframe confirmation.

It is designed to make trend direction and momentum easier to identify at a glance while keeping the chart visually simple.

### EMA Trend Structure

The indicator uses three Exponential Moving Averages:

EMA 10 for the short-term trend
EMA 20 for the medium-term trend
EMA 50 for the broader trend

The background color changes automatically depending on the EMA structure:

**Green**
EMA 10 > EMA 20 > EMA 50
Clearly bullish trend structure.

**Blue**
EMA 10 < EMA 20 while EMA 20 > EMA 50
Short-term weakness within a broader positive trend.

**Orange**
EMA 10 > EMA 20 while EMA 20 < EMA 50
Short-term strength while the broader trend has not yet turned fully bullish.

**Red**
EMA 10 < EMA 20 < EMA 50
Clearly bearish trend structure.

### RSI

The indicator includes a classic RSI calculation with a default length of 14.

RSI above 50 supports bullish momentum.

RSI below 50 supports bearish momentum.

The indicator also checks whether RSI is currently rising or falling.

### MACD

The classic MACD settings are used:

Fast Length: 12
Slow Length: 26
Signal Length: 9

The MACD is used to evaluate:

Bullish or bearish momentum
Signal line crossovers
Increasing or decreasing histogram momentum

### Higher Timeframe Confirmation

The indicator also checks the EMA 10/20/50 structure on a selectable Higher Timeframe.

This can be used as an additional trend filter to avoid taking setups that move against the broader market direction.

### Setup Score

A scoring system combines several conditions.

The maximum score is 6 points:

EMA trend structure: 2 points
RSI confirmation: 1 point
MACD confirmation: 1 point
MACD momentum: 1 point
Higher Timeframe trend: 1 point

The minimum score required for a setup can be adjusted in the indicator settings.

### BUY and SELL Signals

BUY and SELL labels are generated when multiple conditions align.

The logic combines:

EMA trend structure
RSI momentum
MACD direction
MACD momentum
Higher Timeframe confirmation
Pullback or MACD crossover conditions

The signals are designed as additional confirmation and should not be interpreted as automatic trade instructions.

### Alerts

Built-in alerts are available for:

EMA 10/20 bullish crossover
EMA 10/20 bearish crossover
EMA 20/50 bullish crossover
EMA 20/50 bearish crossover
FIA BUY setup
FIA SELL setup

### Important

This indicator is designed as a **trend and momentum analysis tool**.

It should not be used as a standalone trading system.

Always consider price action, market structure, support and resistance levels, volatility and proper risk management before making trading decisions.

For educational purposes only.

**Not financial advice.**

---

## Source Code

````pine
//@version=6
indicator("FIA Trend + Momentum 10/20/50", shorttitle="FIA Trend+Momentum", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────

groupEMA = "1. EMA Trend"
groupRSI = "2. RSI"
groupMACD = "3. MACD"
groupHTF = "4. Higher Timeframe"
groupSIG = "5. Signals"
groupVIS = "6. Visuals"

// EMA Settings
ema10Length = input.int(10, "EMA 10", minval=1, group=groupEMA)
ema20Length = input.int(20, "EMA 20", minval=1, group=groupEMA)
ema50Length = input.int(50, "EMA 50", minval=1, group=groupEMA)

// RSI Settings
rsiLength = input.int(14, "RSI Length", minval=2, group=groupRSI)
rsiBullLevel = input.float(50, "RSI Midline", minval=0, maxval=100, group=groupRSI)

// MACD Settings
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMACD)
macdSlow = input.int(26, "MACD Slow", minval=2, group=groupMACD)
macdSignal = input.int(9, "MACD Signal", minval=1, group=groupMACD)

// Higher Timeframe
higherTF = input.timeframe("5", "Higher Timeframe", group=groupHTF)
useHTF = input.bool(true, "Use Higher Timeframe Filter", group=groupHTF)

// Signals
minScore = input.int(5, "Minimum Setup Score", minval=3, maxval=6, group=groupSIG)
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupSIG)

// Visuals
showEMAs = input.bool(true, "Show EMAs", group=groupVIS)
showBackground = input.bool(true, "Show Trend Background", group=groupVIS)
bgTransparency = input.int(85, "Background Transparency", minval=0, maxval=100, group=groupVIS)

// ─────────────────────────────────────────────
// EMA CALCULATION
// ─────────────────────────────────────────────

ema10 = ta.ema(close, ema10Length)
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)

// ─────────────────────────────────────────────
// EMA TREND STRUCTURE
// ─────────────────────────────────────────────

// Green
allUp = ema10 > ema20 and ema20 > ema50

// Blue
medUpShortDown = ema10 < ema20 and ema20 > ema50

// Orange
medDownShortUp = ema10 > ema20 and ema20 < ema50

// Red
allDown = ema10 < ema20 and ema20 < ema50

emaBull = allUp
emaBear = allDown

// ─────────────────────────────────────────────
// BACKGROUND COLORS
// ─────────────────────────────────────────────

bgColor =
     allUp ? color.new(color.green, bgTransparency) :
     medUpShortDown ? color.new(color.blue, bgTransparency) :
     medDownShortUp ? color.new(color.orange, bgTransparency) :
     allDown ? color.new(color.red, bgTransparency) :
     na

bgcolor(
     showBackground ? bgColor : na,
     title="FIA Trend Background"
)

// ─────────────────────────────────────────────
// RSI
// ─────────────────────────────────────────────

rsi = ta.rsi(close, rsiLength)

rsiBull = rsi > rsiBullLevel
rsiBear = rsi < rsiBullLevel

rsiRising = rsi > rsi[1]
rsiFalling = rsi < rsi[1]

// ─────────────────────────────────────────────
// MACD
// ─────────────────────────────────────────────

[macdLine, macdSignalLine, macdHistogram] =
     ta.macd(close, macdFast, macdSlow, macdSignal)

macdBull = macdLine > macdSignalLine
macdBear = macdLine < macdSignalLine

macdCrossUp = ta.crossover(macdLine, macdSignalLine)
macdCrossDown = ta.crossunder(macdLine, macdSignalLine)

macdMomentumBull = macdHistogram > macdHistogram[1]
macdMomentumBear = macdHistogram < macdHistogram[1]

// ─────────────────────────────────────────────
// HIGHER TIMEFRAME EMA
// ─────────────────────────────────────────────

htfEMA10 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close, ema10Length),
     lookahead=barmerge.lookahead_off
)

htfEMA20 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close, ema20Length),
     lookahead=barmerge.lookahead_off
)

htfEMA50 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close, ema50Length),
     lookahead=barmerge.lookahead_off
)

htfBull = htfEMA10 > htfEMA20 and htfEMA20 > htfEMA50
htfBear = htfEMA10 < htfEMA20 and htfEMA20 < htfEMA50

// ─────────────────────────────────────────────
// LONG SCORE
// ─────────────────────────────────────────────

longScore = 0

longScore += emaBull ? 2 : 0
longScore += rsiBull ? 1 : 0
longScore += macdBull ? 1 : 0
longScore += macdMomentumBull ? 1 : 0
longScore += htfBull ? 1 : 0

// ─────────────────────────────────────────────
// SHORT SCORE
// ─────────────────────────────────────────────

shortScore = 0

shortScore += emaBear ? 2 : 0
shortScore += rsiBear ? 1 : 0
shortScore += macdBear ? 1 : 0
shortScore += macdMomentumBear ? 1 : 0
shortScore += htfBear ? 1 : 0

// ─────────────────────────────────────────────
// SETUPS
// ─────────────────────────────────────────────

longSetup =
     longScore >= minScore and
     (not useHTF or htfBull)

shortSetup =
     shortScore >= minScore and
     (not useHTF or htfBear)

// ─────────────────────────────────────────────
// PULLBACKS
// ─────────────────────────────────────────────

longPullback =
     emaBull and
     low <= ema10 and
     close > ema10 and
     rsiRising and
     rsi > 45 and
     macdBull and
     (not useHTF or htfBull)

shortPullback =
     emaBear and
     high >= ema10 and
     close < ema10 and
     rsiFalling and
     rsi < 55 and
     macdBear and
     (not useHTF or htfBear)

// ─────────────────────────────────────────────
// BUY / SELL SIGNALS
// ─────────────────────────────────────────────

longEntry =
     showSignals and
     longSetup and
     (longPullback or macdCrossUp)

shortEntry =
     showSignals and
     shortSetup and
     (shortPullback or macdCrossDown)

buySignal =
     longEntry and
     not longEntry[1]

sellSignal =
     shortEntry and
     not shortEntry[1]

// ─────────────────────────────────────────────
// EMA LINES
// ─────────────────────────────────────────────

plot(
     showEMAs ? ema10 : na,
     title="EMA 10",
     color=color.green,
     linewidth=2
)

plot(
     showEMAs ? ema20 : na,
     title="EMA 20",
     color=color.yellow,
     linewidth=2
)

plot(
     showEMAs ? ema50 : na,
     title="EMA 50",
     color=color.red,
     linewidth=2
)

// ─────────────────────────────────────────────
// BUY / SELL MARKERS
// ─────────────────────────────────────────────

plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small
)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(
     ta.crossover(ema10, ema20),
     title="EMA 10/20 Bullish Cross",
     message="EMA 10 crosses above EMA 20 – {{ticker}}"
)

alertcondition(
     ta.crossunder(ema10, ema20),
     title="EMA 10/20 Bearish Cross",
     message="EMA 10 crosses below EMA 20 – {{ticker}}"
)

alertcondition(
     ta.crossover(ema20, ema50),
     title="EMA 20/50 Bullish Cross",
     message="EMA 20 crosses above EMA 50 – {{ticker}}"
)

alertcondition(
     ta.crossunder(ema20, ema50),
     title="EMA 20/50 Bearish Cross",
     message="EMA 20 crosses below EMA 50 – {{ticker}}"
)

alertcondition(
     buySignal,
     title="FIA BUY",
     message="FIA BUY setup 10/20/50 – {{ticker}}"
)

alertcondition(
     sellSignal,
     title="FIA SELL",
     message="FIA SELL setup 10/20/50 – {{ticker}}"
)
````
