<!-- tradingview-pine-id: PUB;1e95a5cab5894c63a633f0a52cb9611e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Master Swing Confluence System

Source: https://www.tradingview.com/script/DHyfjfPx-Multi-Confirmation-Swing-Indicator/

## Description

Multi-Confirmation Swing Indicator is a multi-confirmation technical analysis indicator designed for traders who want to analyze trend direction, momentum, support/resistance, breakouts and potential swing entries from one chart.

Instead of relying on a single indicator, the system combines several independent components to provide a broader view of market structure.

The indicator combines:
EMA trend structure
RSI momentum confirmation
Smoothed Heikin Ashi
Dynamic trendlines with breakout detection
Volume-based support and resistance zones
Zone Shift trend detection
Trend initiation and retest levels
Impulse MACD
Swing BUY/SELL signals
Support/resistance breakout and hold signals

The objective is not to predict every market move, but to help traders determine whether multiple pieces of technical evidence are aligned.

How to Read the Indicator

The easiest way to use the indicator is to think of it as a confirmation system.

Don't treat every individual marker as a trade signal.

Instead, look for confluence.

🟢 Bullish Environment

A stronger bullish setup occurs when several of the following are aligned:

EMA 21 > EMA 55
Price is above the EMA structure.
EMA 21 and EMA 55 are rising.
RSI is above the bullish threshold.
Smoothed Heikin Ashi is bullish.
Zone Shift indicates an upward trend.
Price breaks above a resistance/trendline.
Former resistance begins behaving as support.
Impulse MACD confirms positive momentum.
A BUY signal appears after the above conditions align.

The more confirmations that agree, the stronger the overall technical picture.

🔴 Bearish Environment

A stronger bearish setup occurs when:

EMA 21 < EMA 55
Price is below the EMA structure.
EMA 21 and EMA 55 are falling.
RSI is below the bearish threshold.
Smoothed Heikin Ashi is bearish.
Zone Shift indicates a downward trend.
Price breaks below support/trendline.
Former support begins behaving as resistance.
Impulse MACD confirms negative momentum.
A SELL signal appears after the above conditions align.

Again, the objective is confirmation rather than prediction.

Understanding the Main Components
1. EMA Trend Structure

The EMA component uses three moving averages:

Fast EMA — 9
Trend EMA — 21
Major Trend EMA — 55

The basic interpretation is:

Bullish

Price > EMA 9 > EMA 21 > EMA 55

Bearish

Price < EMA 9 < EMA 21 < EMA 55

This helps identify whether short-, medium- and longer-term momentum are aligned.

The EMA settings can be adjusted from the indicator inputs.

2. RSI Confirmation

RSI is used as a momentum filter.

Default thresholds:

Bullish: RSI > 55
Bearish: RSI < 45

The purpose isn't to simply buy when RSI is high or sell when RSI is low.

Instead, RSI helps answer:

"Is momentum supporting the current trend?"

3. Smoothed Heikin Ashi

The Smoothed Heikin Ashi component attempts to reduce some of the noise present in normal candles.

It can help visually identify:

bullish phases
bearish phases
trend transitions
continuation periods

A series of bullish Smoothed Heikin Ashi candles together with bullish EMA structure provides stronger trend confirmation than either component alone.

Likewise for bearish conditions.

4. Dynamic Trendlines

The trendline component identifies swing highs and swing lows and creates dynamic trendlines from them.

It can identify:

Upward breakout

Price breaks through a descending resistance trendline.

Downward breakout

Price breaks through an ascending support trendline.

The B markers represent detected trendline breaks.

These are useful for identifying potential changes in short-term market structure.

5. Volume-Based Support & Resistance

The support/resistance component identifies potential zones around significant pivot areas while incorporating volume information.

The zones can help traders identify:

potential support
potential resistance
support breaks
resistance breaks
resistance becoming support
support becoming resistance
Example

If resistance is broken:

Resistance → Support

A subsequent successful retest of that level can provide additional bullish confirmation.

Similarly:

Support → Resistance

can provide bearish confirmation after a downside break.

6. Zone Shift

Zone Shift provides another view of the broader trend.

It uses a combination of:

EMA
HMA
price range/distance
trend initiation level

The indicator can switch between bullish and bearish states.

It also identifies potential retests of the trend initiation level.

This can be particularly useful for swing traders because it provides context beyond a single candle.

7. Impulse MACD

Impulse MACD provides an additional momentum layer.

It helps identify:

positive momentum
negative momentum
momentum expansion
momentum contraction

It should not be interpreted independently as a buy/sell system.

Instead, use it as another confirmation layer.

BUY Signal

The BUY signal is designed to appear when the primary swing-trend conditions become bullish.

The underlying logic considers factors such as:

EMA trend
EMA alignment
EMA slope
price position relative to the fast EMA
two-bar confirmation
RSI momentum

The system also prevents repeated BUY labels while the same bullish condition remains continuously active.

Ideal interpretation

Trend + momentum + structure + confirmation = stronger setup

Not:

"BUY label = guaranteed buy."

SELL Signal

The SELL signal works in the opposite direction.

It considers:

bearish EMA trend
bearish EMA alignment
declining EMA structure
price below the fast EMA
two-bar confirmation
RSI weakness

Repeated SELL signals are also filtered.

How I Recommend Using It

Rather than trading every signal, use a 3-stage approach.

Stage 1 — Identify the Trend

First ask:

Is the market bullish, bearish or unclear?

Look at:

EMA 21/55
EMA stacking
Zone Shift
Smoothed Heikin Ashi

If these disagree significantly, consider the market unclear.

Stage 2 — Look for Structure

Once the trend is identified, look for:

support/resistance
trendline breakout
breakout/retest
resistance becoming support
support becoming resistance

This helps avoid entering simply because an indicator changed color.

Stage 3 — Look for Momentum Confirmation

Finally check:

RSI
Impulse MACD
EMA slope
BUY/SELL confirmation

A setup where multiple components agree is generally more interesting than an isolated signal.

Example Bullish Setup

A potential swing-long setup could look like:

1. EMA 21 > EMA 55

↓

2. Price > EMA 9 > EMA 21

↓

3. Zone Shift turns bullish

↓

4. Resistance/trendline breaks

↓

5. Price retests the broken resistance

↓

6. RSI remains above bullish threshold

↓

7. Impulse MACD supports bullish momentum

↓

8. BUY signal appears

This creates a confluence-based setup rather than relying on one indicator.

Example Bearish Setup

The reverse:

EMA 21 < EMA 55

↓

Price < EMA 9 < EMA 21 < EMA 55

↓

Zone Shift bearish

↓

Support/trendline breaks

↓

Retest fails

↓

RSI below bearish threshold

↓

Impulse MACD bearish

↓

SELL signal

Again, this is a framework for analysis—not a guarantee of future price movement.

Best Use Cases

The indicator is primarily designed for:

Swing Trading

Good fit for traders holding positions for several candles to several weeks.

Trend Following

Useful when markets establish clear directional movement.

Breakout Trading

The trendline and support/resistance components can help identify structural breaks.

Breakout Retests

Useful for watching former resistance become support or former support become resistance.

Trend Confirmation

Useful when traders want multiple technical factors visible on a single chart.

What This Indicator Is NOT

This is important for the TradingView publication.

This indicator does not guarantee profitable trades or predict future prices.

It should not be treated as:

financial advice
a standalone automated trading system
a guarantee of trend continuation
a guaranteed entry/exit system
a substitute for risk management

Signals can fail, particularly during:

sideways markets
low-volume markets
sudden news events
high volatility
false breakouts

Always combine the indicator with appropriate position sizing and risk management.

---

## Source Code

````pine
//@version=6
indicator("Master Swing Confluence System", shorttitle="Master Swing", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ============================================================================
// MASTER DISPLAY CONTROLS
// ============================================================================

groupMaster = "===== MASTER CONTROLS ====="

showTrendlines = input.bool(true, "Show Trendlines", group=groupMaster)
showSR         = input.bool(true, "Show Support / Resistance", group=groupMaster)
showEMA        = input.bool(true, "Show EMA Trend System", group=groupMaster)
showZoneShift  = input.bool(true, "Show Zone Shift", group=groupMaster)
showMultiMA    = input.bool(false, "Show Flexible Multi-MA", group=groupMaster)
showSHA        = input.bool(false, "Show Smoothed Heiken Ashi", group=groupMaster)
showIMACD      = input.bool(false, "Show Impulse MACD", group=groupMaster)
showBG         = input.bool(true, "Show Trend Background", group=groupMaster)
showSignals    = input.bool(true, "Show Buy / Sell Signals", group=groupMaster)
colorBars      = input.bool(false, "Color Price Bars", group=groupMaster)


// ============================================================================
// COLORS
// ============================================================================

groupColors = "===== COLORS ====="

bullColor = input.color(color.lime, "Bullish Color", group=groupColors)
bearColor = input.color(color.red, "Bearish Color", group=groupColors)
neutralColor = input.color(color.gray, "Neutral Color", group=groupColors)


// ============================================================================
// 1. TRENDLINES WITH BREAKS
// ============================================================================

groupTL = "===== TRENDLINES WITH BREAKS ====="

tlLength = input.int(14, "Swing Detection Lookback", minval=2, group=groupTL)
tlMult = input.float(1.0, "Slope Multiplier", minval=0, step=0.1, group=groupTL)

tlCalcMethod = input.string(
     "ATR",
     "Slope Calculation Method",
     options=["ATR", "Stdev", "Linreg"],
     group=groupTL)

tlBackpaint = input.bool(
     true,
     "Backpaint",
     tooltip="Disable to see real-time trendline information.",
     group=groupTL)

tlShowExt = input.bool(true, "Show Extended Lines", group=groupTL)

tlUpColor = input.color(color.teal, "Up Trendline Color", group=groupTL)
tlDnColor = input.color(color.red, "Down Trendline Color", group=groupTL)

tlSrc = close
tlN = bar_index

tlPH = ta.pivothigh(tlLength, tlLength)
tlPL = ta.pivotlow(tlLength, tlLength)

tlSlope = switch tlCalcMethod
    "ATR" =>
        ta.atr(tlLength) / tlLength * tlMult

    "Stdev" =>
        ta.stdev(tlSrc, tlLength) / tlLength * tlMult

    "Linreg" =>
        math.abs(
            ta.sma(tlSrc * tlN, tlLength) -
            ta.sma(tlSrc, tlLength) * ta.sma(tlN, tlLength)
        ) / math.max(ta.variance(tlN, tlLength), 0.000001) / 2 * tlMult

var float tlUpper = 0.0
var float tlLower = 0.0
var float tlSlopePH = 0.0
var float tlSlopePL = 0.0

tlOffset = tlBackpaint ? tlLength : 0

tlSlopePH := not na(tlPH) ? tlSlope : tlSlopePH
tlSlopePL := not na(tlPL) ? tlSlope : tlSlopePL

tlUpper := not na(tlPH) ? tlPH : tlUpper - tlSlopePH
tlLower := not na(tlPL) ? tlPL : tlLower + tlSlopePL

var int tlUPos = 0
var int tlDPos = 0

tlUPos := not na(tlPH) ? 0 :
     close > tlUpper - tlSlopePH * tlLength ? 1 : tlUPos

tlDPos := not na(tlPL) ? 0 :
     close < tlLower + tlSlopePL * tlLength ? 1 : tlDPos


// Extended trendlines

var line tlUpLine = line.new(
     na, na, na, na,
     color=tlUpColor,
     style=line.style_dashed,
     extend=extend.right)

var line tlDnLine = line.new(
     na, na, na, na,
     color=tlDnColor,
     style=line.style_dashed,
     extend=extend.right)

if showTrendlines and tlShowExt

    if not na(tlPH)

        line.set_xy1(
             tlUpLine,
             bar_index - tlOffset,
             tlBackpaint ? tlPH : tlUpper - tlSlopePH * tlLength)

        line.set_xy2(
             tlUpLine,
             bar_index - tlOffset + 1,
             tlBackpaint ? tlPH - tlSlopePH :
                 tlUpper - tlSlopePH * (tlLength + 1))

    if not na(tlPL)

        line.set_xy1(
             tlDnLine,
             bar_index - tlOffset,
             tlBackpaint ? tlPL : tlLower + tlSlopePL * tlLength)

        line.set_xy2(
             tlDnLine,
             bar_index - tlOffset + 1,
             tlBackpaint ? tlPL + tlSlopePL :
                 tlLower + tlSlopePL * (tlLength + 1))


tlUpperPlot = tlBackpaint ?
     tlUpper :
     tlUpper - tlSlopePH * tlLength

tlLowerPlot = tlBackpaint ?
     tlLower :
     tlLower + tlSlopePL * tlLength

plot(
     showTrendlines ? tlUpperPlot : na,
     "Trendline Upper",
     color=not na(tlPH) ? na : tlUpColor,
     offset=-tlOffset)

plot(
     showTrendlines ? tlLowerPlot : na,
     "Trendline Lower",
     color=not na(tlPL) ? na : tlDnColor,
     offset=-tlOffset)

tlBullBreak = tlUPos > tlUPos[1]
tlBearBreak = tlDPos > tlDPos[1]

plotshape(
     showTrendlines and tlBullBreak ? low : na,
     title="Trendline Bullish Break",
     style=shape.labelup,
     location=location.absolute,
     color=tlUpColor,
     text="TL B",
     textcolor=color.white,
     size=size.tiny)

plotshape(
     showTrendlines and tlBearBreak ? high : na,
     title="Trendline Bearish Break",
     style=shape.labeldown,
     location=location.absolute,
     color=tlDnColor,
     text="TL B",
     textcolor=color.white,
     size=size.tiny)


// ============================================================================
// 2. SUPPORT / RESISTANCE VOLUME BOXES
// ============================================================================

groupSR = "===== SUPPORT / RESISTANCE ====="

srLookback = input.int(20, "Lookback Period", minval=1, group=groupSR)
srVolLen = input.int(2, "Delta Volume Filter Length", minval=1, group=groupSR)
srBoxWidth = input.float(1.0, "Box Width", minval=0.1, maxval=1000, step=0.1, group=groupSR)

srShowBoxes = input.bool(true, "Show S/R Boxes", group=groupSR)
srShowLabels = input.bool(true, "Show S/R Break Labels", group=groupSR)


// Delta volume

var bool srIsBuyVolume = true

if close > open
    srIsBuyVolume := true
else if close < open
    srIsBuyVolume := false

srDeltaVolume = srIsBuyVolume ? volume : -volume

srVolHigh = ta.highest(srDeltaVolume / 2.5, srVolLen)
srVolLow = ta.lowest(srDeltaVolume / 2.5, srVolLen)

srPivotHigh = ta.pivothigh(close, srLookback, srLookback)
srPivotLow = ta.pivotlow(close, srLookback, srLookback)

srATR = ta.atr(200)
srWidth = srATR * srBoxWidth

var float srSupport = na
var float srSupportBottom = na
var float srResistance = na
var float srResistanceTop = na

var box srSupportBox = na
var box srResistanceBox = na

var color srSupportColor = color.new(color.green, 80)
var color srResistanceColor = color.new(color.red, 80)


// New support

if showSR and srShowBoxes and not na(srPivotLow) and srDeltaVolume > srVolHigh

    srSupport := srPivotLow
    srSupportBottom := srSupport - srWidth

    if not na(srSupportBox)
        box.delete(srSupportBox)

    srSupportColor := color.new(color.green, 80)

    srSupportBox := box.new(
         left=bar_index - srLookback,
         top=srSupport,
         right=bar_index + 1,
         bottom=srSupportBottom,
         border_color=color.green,
         border_width=1,
         bgcolor=srSupportColor,
         text="SUP",
         text_color=chart.fg_color,
         text_size=size.small)


// New resistance

if showSR and srShowBoxes and not na(srPivotHigh) and srDeltaVolume < srVolLow

    srResistance := srPivotHigh
    srResistanceTop := srResistance + srWidth

    if not na(srResistanceBox)
        box.delete(srResistanceBox)

    srResistanceColor := color.new(color.red, 80)

    srResistanceBox := box.new(
         left=bar_index - srLookback,
         top=srResistanceTop,
         right=bar_index + 1,
         bottom=srResistance,
         border_color=color.red,
         border_width=1,
         bgcolor=srResistanceColor,
         text="RES",
         text_color=chart.fg_color,
         text_size=size.small)


// Extend boxes

if showSR and not na(srSupportBox)
    box.set_right(srSupportBox, bar_index + 1)

if showSR and not na(srResistanceBox)
    box.set_right(srResistanceBox, bar_index + 1)


// S/R events

srResistanceBreak = not na(srResistance) and ta.crossover(low, srResistanceTop)
srResistanceHold = not na(srResistance) and ta.crossunder(high, srResistance)

srSupportHold = not na(srSupport) and ta.crossover(low, srSupport)
srSupportBreak = not na(srSupport) and ta.crossunder(high, srSupport)


// Track role reversal

var bool srResistanceIsSupport = false
var bool srSupportIsResistance = false

if srResistanceBreak
    srResistanceIsSupport := true

if srResistanceHold
    srResistanceIsSupport := false

if srSupportBreak
    srSupportIsResistance := true

if srSupportHold
    srSupportIsResistance := false


// Change box appearance

if srSupportBreak and not na(srSupportBox)
    box.set_bgcolor(srSupportBox, color.new(color.red, 85))
    box.set_border_color(srSupportBox, color.red)
    box.set_border_style(srSupportBox, line.style_dashed)

if srSupportHold and not na(srSupportBox)
    box.set_bgcolor(srSupportBox, srSupportColor)
    box.set_border_color(srSupportBox, color.green)
    box.set_border_style(srSupportBox, line.style_solid)

if srResistanceBreak and not na(srResistanceBox)
    box.set_bgcolor(srResistanceBox, color.new(color.green, 85))
    box.set_border_color(srResistanceBox, color.green)
    box.set_border_style(srResistanceBox, line.style_dashed)

if srResistanceHold and not na(srResistanceBox)
    box.set_bgcolor(srResistanceBox, srResistanceColor)
    box.set_border_color(srResistanceBox, color.red)
    box.set_border_style(srResistanceBox, line.style_solid)


// S/R markers

plotchar(
     showSR and srResistanceHold,
     "Resistance Holds",
     "◆",
     color=color.red,
     size=size.tiny,
     location=location.abovebar)

plotchar(
     showSR and srSupportHold,
     "Support Holds",
     "◆",
     color=color.green,
     size=size.tiny,
     location=location.belowbar)

plotchar(
     showSR and srResistanceBreak and srResistanceIsSupport[1],
     "Resistance Becomes Support",
     "◆",
     color=color.green,
     size=size.tiny,
     location=location.belowbar)

plotchar(
     showSR and srSupportBreak and srSupportIsResistance[1],
     "Support Becomes Resistance",
     "◆",
     color=color.red,
     size=size.tiny,
     location=location.abovebar)

if showSR and srShowLabels and srSupportBreak and not srSupportIsResistance[1]
    label.new(
         bar_index,
         srSupport,
         "Break Sup",
         style=label.style_label_down,
         color=color.maroon,
         textcolor=color.white,
         size=size.small)

if showSR and srShowLabels and srResistanceBreak and not srResistanceIsSupport[1]
    label.new(
         bar_index,
         srResistance,
         "Break Res",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)


// ============================================================================
// 3. MASTER EMA SWING SYSTEM
// ============================================================================

groupEMA = "===== MASTER EMA TREND ====="

emaFastLength = input.int(9, "Entry EMA", minval=1, group=groupEMA)
emaTrendLength = input.int(21, "Trend EMA", minval=1, group=groupEMA)
emaSlowLength = input.int(55, "Major Trend EMA", minval=1, group=groupEMA)

emaRSILength = input.int(14, "RSI Length", minval=1, group=groupEMA)
emaBullRSI = input.int(55, "Bull RSI", minval=1, maxval=100, group=groupEMA)
emaBearRSI = input.int(45, "Bear RSI", minval=1, maxval=100, group=groupEMA)

emaShowSignals = input.bool(true, "Show EMA Buy/Sell Signals", group=groupEMA)

ema9 = ta.ema(close, emaFastLength)
ema21 = ta.ema(close, emaTrendLength)
ema55 = ta.ema(close, emaSlowLength)

emaRSI = ta.rsi(close, emaRSILength)

emaBullTrend = ema21 > ema55
emaBearTrend = ema21 < ema55

emaStackBull =
     close > ema9 and
     ema9 > ema21 and
     ema21 > ema55

emaStackBear =
     close < ema9 and
     ema9 < ema21 and
     ema21 < ema55

ema21Up = ema21 > ema21[1]
ema55Up = ema55 > ema55[1]

ema21Down = ema21 < ema21[1]
ema55Down = ema55 < ema55[1]

emaBullTwoBars =
     close > ema9 and
     close[1] > ema9[1]

emaBearTwoBars =
     close < ema9 and
     close[1] < ema9[1]

emaBuyCondition =
     emaBullTrend and
     emaStackBull and
     emaBullTwoBars and
     ema21Up and
     ema55Up and
     emaRSI > emaBullRSI

emaSellCondition =
     emaBearTrend and
     emaStackBear and
     emaBearTwoBars and
     ema21Down and
     ema55Down and
     emaRSI < emaBearRSI

emaBuy = emaBuyCondition and not emaBuyCondition[1]
emaSell = emaSellCondition and not emaSellCondition[1]


ema9Plot = plot(
     showEMA ? ema9 : na,
     "EMA 9",
     color=color.white,
     linewidth=2)

ema21Plot = plot(
     showEMA ? ema21 : na,
     "EMA 21",
     color=color.orange,
     linewidth=2)

ema55Plot = plot(
     showEMA ? ema55 : na,
     "EMA 55",
     color=color.blue,
     linewidth=2)

fill(
     ema21Plot,
     ema55Plot,
     color=showEMA ?
         emaBullTrend ? color.new(color.green, 85) :
         emaBearTrend ? color.new(color.red, 85) :
         na :
         na)

plotshape(
     showEMA and emaShowSignals and showSignals and emaBuy,
     title="EMA BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY",
     textcolor=color.white)

plotshape(
     showEMA and emaShowSignals and showSignals and emaSell,
     title="EMA SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL",
     textcolor=color.white)


// ============================================================================
// 4. ZONE SHIFT
// ============================================================================

groupZS = "===== ZONE SHIFT ====="

zsLength = input.int(100, "Zone Length", minval=60, maxval=200, group=groupZS)
zsUpColor = input.color(color.lime, "Zone Bull Color", group=groupZS)
zsDnColor = input.color(color.blue, "Zone Bear Color", group=groupZS)

zsEMA = ta.ema(close, zsLength)
zsHMA = ta.hma(close, math.max(zsLength - 40, 1))

zsDist = ta.sma(high - low, 200)

zsMid = math.avg(zsEMA, zsHMA)
zsTop = zsMid + zsDist
zsBot = zsMid - zsDist

var bool zsTrend = false
var float zsTrendStart = na
var int zsLastRetest = 0

if barstate.isconfirmed

    if low > zsTop and low[1] < zsTop[1] and not zsTrend
        zsTrend := true
        zsTrendStart := low

    if high < zsBot and high[1] > zsBot[1] and zsTrend
        zsTrend := false
        zsTrendStart := high


zsColor = zsTrend ? zsUpColor : zsDnColor


// Retest

zsBullRetest =
     not na(zsTrendStart) and
     zsTrend and
     (
         (close > zsTrendStart and close[1] < zsTrendStart[1]) or
         (low > zsTrendStart and low[1] < zsTrendStart[1])
     ) and
     bar_index - zsLastRetest > 5

zsBearRetest =
     not na(zsTrendStart) and
     not zsTrend and
     (
         (close[1] > zsTrendStart and close < zsTrendStart[1]) or
         (high[1] > zsTrendStart and high < zsTrendStart[1])
     ) and
     bar_index - zsLastRetest > 5


if barstate.isconfirmed

    if zsBullRetest
        zsLastRetest := bar_index

    if zsBearRetest
        zsLastRetest := bar_index


plot(
     showZoneShift ? zsMid : na,
     "Zone Middle",
     color=bar_index % 2 == 0 ? chart.fg_color : na)

plot(
     showZoneShift ? zsTop : na,
     "Zone Top",
     color=chart.fg_color)

plot(
     showZoneShift ? zsBot : na,
     "Zone Bottom",
     color=chart.fg_color)

plot(
     showZoneShift and zsTrendStart != zsTrendStart[1] ?
         na :
         zsTrendStart,
     "Trend Initiation Level",
     style=plot.style_linebr,
     color=chart.fg_color)

plotshape(
     showZoneShift and zsBullRetest,
     title="Bullish Zone Retest",
     style=shape.diamond,
     location=location.belowbar,
     color=zsUpColor,
     size=size.tiny)

plotshape(
     showZoneShift and zsBearRetest,
     title="Bearish Zone Retest",
     style=shape.diamond,
     location=location.abovebar,
     color=zsDnColor,
     size=size.tiny)


// ============================================================================
// 5. FLEXIBLE MULTI-MA
// ============================================================================

groupMA = "===== FLEXIBLE MULTI-MA ====="

maType = input.string(
     "EMA",
     "MA Type",
     options=[
         "SMA",
         "EMA",
         "WMA",
         "VWMA",
         "RMA",
         "HMA",
         "DEMA",
         "TEMA"
     ],
     group=groupMA)

ma1Length = input.int(20, "MA 1 Length", minval=1, group=groupMA)
ma2Length = input.int(50, "MA 2 Length", minval=1, group=groupMA)
ma3Length = input.int(100, "MA 3 Length", minval=1, group=groupMA)
ma4Length = input.int(200, "MA 4 Length", minval=1, group=groupMA)

ma1Color = input.color(color.yellow, "MA 1 Color", group=groupMA)
ma2Color = input.color(color.blue, "MA 2 Color", group=groupMA)
ma3Color = input.color(color.red, "MA 3 Color", group=groupMA)
ma4Color = input.color(color.green, "MA 4 Color", group=groupMA)


f_ma(src, length, type) =>
    switch type
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "VWMA" => ta.vwma(src, length)
        "RMA" => ta.rma(src, length)
        "HMA" => ta.hma(src, length)
        "DEMA" =>
            ema1 = ta.ema(src, length)
            2.0 * ema1 - ta.ema(ema1, length)
        "TEMA" =>
            ema1 = ta.ema(src, length)
            ema2 = ta.ema(ema1, length)
            ema3 = ta.ema(ema2, length)
            3.0 * ema1 - 3.0 * ema2 + ema3
        => ta.ema(src, length)


ma1 = f_ma(close, ma1Length, maType)
ma2 = f_ma(close, ma2Length, maType)
ma3 = f_ma(close, ma3Length, maType)
ma4 = f_ma(close, ma4Length, maType)

plot(
     showMultiMA ? ma1 : na,
     "Flexible MA 1",
     color=ma1Color,
     linewidth=2)

plot(
     showMultiMA ? ma2 : na,
     "Flexible MA 2",
     color=ma2Color,
     linewidth=2)

plot(
     showMultiMA ? ma3 : na,
     "Flexible MA 3",
     color=ma3Color,
     linewidth=2)

plot(
     showMultiMA ? ma4 : na,
     "Flexible MA 4",
     color=ma4Color,
     linewidth=2)


// ============================================================================
// 6. SMOOTHED HEIKEN ASHI
// ============================================================================

groupSHA = "===== SMOOTHED HEIKEN ASHI ====="

shaBeforeLength = input.int(
     10,
     "Before HA Smooth Length",
     minval=1,
     group=groupSHA)

shaBeforeType = input.string(
     "EMA",
     "Before HA MA Type",
     options=[
         "SMA",
         "EMA",
         "WMA",
         "VWMA",
         "RMA",
         "HMA",
         "DEMA",
         "TEMA"
     ],
     group=groupSHA)

shaAfterLength = input.int(
     10,
     "After HA Smooth Length",
     minval=1,
     group=groupSHA)

shaAfterType = input.string(
     "EMA",
     "After HA MA Type",
     options=[
         "SMA",
         "EMA",
         "WMA",
         "VWMA",
         "RMA",
         "HMA",
         "DEMA",
         "TEMA"
     ],
     group=groupSHA)


// Pre-smoothing

shaOpenSmooth = f_ma(open, shaBeforeLength, shaBeforeType)
shaHighSmooth = f_ma(high, shaBeforeLength, shaBeforeType)
shaLowSmooth = f_ma(low, shaBeforeLength, shaBeforeType)
shaCloseSmooth = f_ma(close, shaBeforeLength, shaBeforeType)


// Heiken Ashi calculation

var float shaOpen = na

shaClose = (
     shaOpenSmooth +
     shaHighSmooth +
     shaLowSmooth +
     shaCloseSmooth
     ) / 4.0

shaOpen := na(shaOpen[1]) ?
     (shaOpenSmooth + shaCloseSmooth) / 2.0 :
     (shaOpen[1] + shaClose[1]) / 2.0

shaHigh = math.max(
     shaHighSmooth,
     math.max(shaOpen, shaClose))

shaLow = math.min(
     shaLowSmooth,
     math.min(shaOpen, shaClose))


// Post smoothing

shaOpenFinal = f_ma(shaOpen, shaAfterLength, shaAfterType)
shaHighFinal = f_ma(shaHigh, shaAfterLength, shaAfterType)
shaLowFinal = f_ma(shaLow, shaAfterLength, shaAfterType)
shaCloseFinal = f_ma(shaClose, shaAfterLength, shaAfterType)


// FIXED SHA COLOR
// This replaces the problematic shaCandleColor variable.

shaBull = shaCloseFinal >= shaOpenFinal

shaBodyColor = shaBull ?
     color.new(color.lime, 60) :
     color.new(color.red, 60)

shaWickColor = shaBull ?
     color.new(color.lime, 20) :
     color.new(color.red, 20)

shaBorderColor = shaBull ?
     color.new(color.lime, 10) :
     color.new(color.red, 10)


plotcandle(
     showSHA ? shaOpenFinal : na,
     showSHA ? shaHighFinal : na,
     showSHA ? shaLowFinal : na,
     showSHA ? shaCloseFinal : na,
     title="Smoothed Heiken Ashi",
     color=shaBodyColor,
     wickcolor=shaWickColor,
     bordercolor=shaBorderColor)


// ============================================================================
// 7. IMPULSE MACD
// ============================================================================

groupMACD = "===== IMPULSE MACD ====="

imacdLengthMA = input.int(
     34,
     "Impulse MACD MA Length",
     minval=1,
     group=groupMACD)

imacdSignalLength = input.int(
     9,
     "Impulse MACD Signal Length",
     minval=1,
     group=groupMACD)

imacdBarColors = input.bool(
     false,
     "Use Impulse MACD Bar Colors",
     group=groupMACD)


// Smoothed moving average

f_smma(src, length) =>
    ta.rma(src, length)


// Zero-lag EMA

f_zlema(src, length) =>
    ema1 = ta.ema(src, length)
    ema2 = ta.ema(ema1, length)
    d = ema1 - ema2
    ema1 + d


imacdSrc = hlc3

imacdHi = f_smma(high, imacdLengthMA)
imacdLo = f_smma(low, imacdLengthMA)
imacdMi = f_zlema(imacdSrc, imacdLengthMA)

imacdMD =
     imacdMi > imacdHi ?
         imacdMi - imacdHi :
     imacdMi < imacdLo ?
         imacdMi - imacdLo :
         0.0

imacdSignal = ta.sma(imacdMD, imacdSignalLength)
imacdHist = imacdMD - imacdSignal


imacdColor =
     imacdSrc > imacdMi ?
         imacdSrc > imacdHi ?
             color.lime :
             color.green :
     imacdSrc < imacdLo ?
         color.red :
         color.orange


// IMPORTANT:
// The original Impulse MACD was a separate pane indicator.
// Because this is one overlay script, its values are not plotted
// as a separate pane here. We use its state for confirmation.

imacdBull = imacdMD > imacdSignal and imacdMD > 0
imacdBear = imacdMD < imacdSignal and imacdMD < 0

imacdMomentumBull = imacdHist > 0
imacdMomentumBear = imacdHist < 0


// ============================================================================
// 8. MASTER CONFLUENCE SIGNAL
// ============================================================================

groupSignal = "===== MASTER CONFLUENCE SIGNAL ====="

useEMAFilter = input.bool(true, "Require EMA Trend", group=groupSignal)
useZoneFilter = input.bool(true, "Require Zone Shift Trend", group=groupSignal)
useSHAFilter = input.bool(true, "Require Smoothed HA Direction", group=groupSignal)
useMACDFilter = input.bool(true, "Require Impulse MACD", group=groupSignal)
useTLFilter = input.bool(false, "Require Trendline Break", group=groupSignal)
useSRFilter = input.bool(false, "Require S/R Break", group=groupSignal)


// Individual bullish conditions

masterBullEMA =
     emaBullTrend and
     emaStackBull

masterBearEMA =
     emaBearTrend and
     emaStackBear

masterBullZone = zsTrend
masterBearZone = not zsTrend

masterBullSHA = shaBull
masterBearSHA = not shaBull

masterBullMACD = imacdBull
masterBearMACD = imacdBear

masterBullTL = tlBullBreak
masterBearTL = tlBearBreak

masterBullSR = srResistanceBreak or srSupportHold
masterBearSR = srSupportBreak or srResistanceHold


// Confluence

masterBuyCondition =
     (not useEMAFilter or masterBullEMA) and
     (not useZoneFilter or masterBullZone) and
     (not useSHAFilter or masterBullSHA) and
     (not useMACDFilter or masterBullMACD) and
     (not useTLFilter or masterBullTL) and
     (not useSRFilter or masterBullSR)

masterSellCondition =
     (not useEMAFilter or masterBearEMA) and
     (not useZoneFilter or masterBearZone) and
     (not useSHAFilter or masterBearSHA) and
     (not useMACDFilter or masterBearMACD) and
     (not useTLFilter or masterBearTL) and
     (not useSRFilter or masterBearSR)


// Prevent repeated signals

masterBuy = masterBuyCondition and not masterBuyCondition[1]
masterSell = masterSellCondition and not masterSellCondition[1]


plotshape(
     showSignals and masterBuy,
     title="MASTER BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.white,
     size=size.normal)

plotshape(
     showSignals and masterSell,
     title="MASTER SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.normal)


// ============================================================================
// 9. TREND BACKGROUND
// ============================================================================

masterBullTrend =
     emaBullTrend and
     zsTrend

masterBearTrend =
     emaBearTrend and
     not zsTrend

bgcolor(
     showBG ?
         masterBullTrend ?
             color.new(color.green, 92) :
         masterBearTrend ?
             color.new(color.red, 92) :
             na :
         na)


// ============================================================================
// 10. BAR COLOR
// ============================================================================

masterBarColor =
     masterBullTrend ?
         bullColor :
     masterBearTrend ?
         bearColor :
         neutralColor

barcolor(
     colorBars ?
         masterBarColor :
         na)


// ============================================================================
// 11. ALERTS
// ============================================================================

// Trendline

alertcondition(
     tlBullBreak,
     title="Trendline Bullish Break",
     message="Price broke the down-trendline upward.")

alertcondition(
     tlBearBreak,
     title="Trendline Bearish Break",
     message="Price broke the up-trendline downward.")


// EMA

alertcondition(
     emaBuy,
     title="EMA BUY",
     message="Master EMA Swing BUY")

alertcondition(
     emaSell,
     title="EMA SELL",
     message="Master EMA Swing SELL")


// S/R

alertcondition(
     srResistanceBreak,
     title="Resistance Break",
     message="Resistance breakout detected.")

alertcondition(
     srSupportBreak,
     title="Support Break",
     message="Support breakdown detected.")


// Zone Shift

alertcondition(
     zsBullRetest,
     title="Bullish Zone Retest",
     message="Bullish Zone Shift retest detected.")

alertcondition(
     zsBearRetest,
     title="Bearish Zone Retest",
     message="Bearish Zone Shift retest detected.")


// Master

alertcondition(
     masterBuy,
     title="MASTER BUY",
     message="Master Swing Confluence BUY")

alertcondition(
     masterSell,
     title="MASTER SELL",
     message="Master Swing Confluence SELL")
````
