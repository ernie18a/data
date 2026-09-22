<!-- tradingview-pine-id: PUB;655cedb1551340e6a9edf9f929aff6dc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FIA Trend + Momentum 20/50/200

Source: https://www.tradingview.com/script/Tu56lAAt-FIA-Trend-Momentum-20-50-200/

## Description

## FIA Trend + Momentum 20/50/200

The **FIA Trend + Momentum 20/50/200** indicator combines long-term trend structure with momentum analysis and multi-timeframe confirmation.

It is designed to make market direction easier to identify visually while also filtering potential setups through RSI, MACD and Higher Timeframe confirmation.

### EMA Trend Structure

The indicator uses three Exponential Moving Averages:

EMA 20 for the short-term trend
EMA 50 for the medium-term trend
EMA 200 for the long-term trend

The background changes automatically depending on the EMA structure.

**Green**
EMA 20 > EMA 50 > EMA 200
Clearly bullish trend structure.

**Blue**
EMA 20 < EMA 50 while EMA 50 > EMA 200
Short-term weakness within a broader bullish trend.

**Orange**
EMA 20 > EMA 50 while EMA 50 < EMA 200
Short-term strength while the broader trend has not yet turned fully bullish.

**Red**
EMA 20 < EMA 50 < EMA 200
Clearly bearish trend structure.

The background colors are based only on the EMA structure. RSI, MACD and Higher Timeframe confirmation do not change the background color.

### RSI

The indicator uses a classic RSI calculation with a default length of 14.

RSI above 50 supports bullish momentum.

RSI below 50 supports bearish momentum.

The indicator also checks whether RSI is currently rising or falling, which is used as additional confirmation for pullback setups.

### MACD

The indicator uses the classic MACD settings:

Fast Length: 12
Slow Length: 26
Signal Length: 9

The MACD is used to evaluate:

Bullish or bearish momentum
MACD signal-line crossovers
Increasing or decreasing histogram momentum

### Higher Timeframe Confirmation

A selectable Higher Timeframe filter is included.

The indicator calculates the EMA 20/50/200 structure on the selected Higher Timeframe and checks whether the broader trend confirms the current setup.

This filter can be enabled or disabled in the settings.

### Setup Score

The indicator uses a scoring system with a maximum of 6 points.

EMA trend structure: 2 points
RSI confirmation: 1 point
MACD confirmation: 1 point
MACD momentum: 1 point
Higher Timeframe trend: 1 point

The minimum score required for a valid setup can be adjusted in the settings.

The default minimum score is 5 out of 6.

### Pullback Logic

The indicator also searches for potential pullbacks within established trends.

A bullish pullback requires a bullish EMA structure, a retracement toward the EMA 20, a close back above the EMA 20, rising RSI and bullish MACD confirmation.

The bearish logic works in the opposite direction.

### BUY and SELL Signals

A BUY or SELL label is only generated when several conditions align.

A **BUY signal** requires a sufficiently strong bullish setup score and either:

a confirmed bullish pullback

or

a bullish MACD crossover.

A **SELL signal** requires a sufficiently strong bearish setup score and either:

a confirmed bearish pullback

or

a bearish MACD crossover.

Signals are only marked when the condition appears for the first time, helping to avoid repeated labels on consecutive candles.

The signals are intended as confirmation tools and should not be interpreted as automatic trading instructions.

### Alerts

Built-in alerts are available for:

EMA 20/50 bullish crossover
EMA 20/50 bearish crossover
EMA 50/200 Golden Cross
EMA 50/200 Death Cross
FIA BUY setup
FIA SELL setup

### Important

This indicator is designed as a **trend and momentum analysis tool**.

It combines:

**EMA = trend direction**
**RSI = momentum strength**
**MACD = momentum direction and change**
**Higher Timeframe = broader trend confirmation**

It should not be used as a standalone trading system.

Always consider price action, support and resistance levels, volatility, market structure and appropriate risk management before making trading decisions.

For educational purposes only.

**Not financial advice.**

---

## Source Code

````pine
//@version=6
indicator("FIA Trend + Momentum 20/50/200", shorttitle="FIA Trend+Momentum", overlay=true, max_labels_count=500)

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
ema20Length = input.int(20, "EMA 20", minval=1, group=groupEMA)
ema50Length = input.int(50, "EMA 50", minval=1, group=groupEMA)
ema200Length = input.int(200, "EMA 200", minval=1, group=groupEMA)

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

ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

// ─────────────────────────────────────────────
// EMA TREND STRUCTURE
// ─────────────────────────────────────────────

// Green
allUp = ema20 > ema50 and ema50 > ema200

// Blue
medUpShortDown = ema20 < ema50 and ema50 > ema200

// Orange
medDownShortUp = ema20 > ema50 and ema50 < ema200

// Red
allDown = ema20 < ema50 and ema50 < ema200

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

htfEMA200 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close, ema200Length),
     lookahead=barmerge.lookahead_off
)

htfBull = htfEMA20 > htfEMA50 and htfEMA50 > htfEMA200
htfBear = htfEMA20 < htfEMA50 and htfEMA50 < htfEMA200

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
     low <= ema20 and
     close > ema20 and
     rsiRising and
     rsi > 45 and
     macdBull and
     (not useHTF or htfBull)

shortPullback =
     emaBear and
     high >= ema20 and
     close < ema20 and
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
     showEMAs ? ema20 : na,
     title="EMA 20",
     color=color.green,
     linewidth=2
)

plot(
     showEMAs ? ema50 : na,
     title="EMA 50",
     color=color.yellow,
     linewidth=2
)

plot(
     showEMAs ? ema200 : na,
     title="EMA 200",
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
     ta.crossover(ema50, ema200),
     title="Golden Cross",
     message="EMA 50 crosses above EMA 200 – {{ticker}}"
)

alertcondition(
     ta.crossunder(ema50, ema200),
     title="Death Cross",
     message="EMA 50 crosses below EMA 200 – {{ticker}}"
)

alertcondition(
     buySignal,
     title="FIA BUY",
     message="FIA BUY setup – {{ticker}}"
)

alertcondition(
     sellSignal,
     title="FIA SELL",
     message="FIA SELL setup – {{ticker}}"
)
````
