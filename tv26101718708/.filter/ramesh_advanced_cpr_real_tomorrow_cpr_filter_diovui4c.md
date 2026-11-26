# RaMeSh Advanced CPR + Real Tomorrow CPR Filter

- url: https://www.tradingview.com/script/diOVui4C-RaMeSh-Advanced-CPR-Real-Tomorrow-CPR-Filter/
- type: indicator
- pine_id: PUB;cb488b45279541ceb91878e74d843b1c
- version: 1.0

## Description

RaMeSh Advanced CPR + Tomorrow CPR Filter

A professional intraday trading framework built around Central Pivot Range (CPR), VWAP, trend confirmation, volume analysis, and projected Tomorrow CPR filtering.

This indicator is designed for traders who want high-probability breakout opportunities while avoiding low-quality market conditions.

Key Features
Dynamic CPR Analysis
Automatically plots Today’s CPR
Detects:
Narrow CPR
Wide CPR
Trend continuation zones
Helps identify breakout and range-bound sessions
Tomorrow CPR Projection
Projects Tomorrow’s CPR in real time using current session OHLC
Optional filter mode:
When enabled, trades are filtered using projected Tomorrow Narrow CPR conditions
Useful for identifying strong trending sessions in advance
Smart Trade Filters

This indicator combines multiple confirmations before generating signals:

CPR breakout logic
VWAP confirmation
15-minute EMA trend alignment
Volume confirmation
Intraday session filter
India VIX-based volatility filter
Inside/Outside CPR market structure
Included Levels
Pivot
BC / TC
R1 / R2 / R3
S1 / S2 / S3
Previous Day High / Low
VWAP
15m EMA Trend
Signal Logic

BUY signals appear when:

Price trades above CPR
Trend is bullish
VWAP confirms strength
Volume supports breakout
Market volatility conditions are favorable

SELL signals appear when:

Price trades below CPR
Trend is bearish
VWAP confirms weakness
Volume supports breakdown
Market volatility conditions are favorable
Best Usage

Recommended for:

NIFTY
BANKNIFTY
FINNIFTY
Intraday index trading
5-minute and 15-minute charts
Designed For
CPR traders
Intraday breakout traders
Trend-following traders
Professional scalpers
Notes
Tomorrow CPR is projection-based and evolves during the live session
Works best during high liquidity market hours
Combine with proper risk management for best results

## Source Code

````pine
//@version=5
indicator("RaMeSh Advanced CPR + Real Tomorrow CPR Filter", overlay=true)

//━━━━━━━━━━ INPUTS ━━━━━━━━━━//
showPivot = input.bool(true, "Show Pivot")
showBC    = input.bool(true, "Show BC")
showTC    = input.bool(true, "Show TC")

showR1 = input.bool(true, "Show R1")
showR2 = input.bool(true, "Show R2")
showR3 = input.bool(true, "Show R3")

showS1 = input.bool(true, "Show S1")
showS2 = input.bool(true, "Show S2")
showS3 = input.bool(true, "Show S3")

showPDH = input.bool(true, "Show Previous Day High")
showPDL = input.bool(true, "Show Previous Day Low")

showVWAP = input.bool(true, "Show VWAP")
showTrendEMA = input.bool(true, "Show 15m Trend EMA")

//━━━━━━━━━━ TOMORROW CPR FILTER ━━━━━━━━━━//
showTomorrowCPR = input.bool(false, "Show Tomorrow CPR Filter")

//━━━━━━━━━━ PREVIOUS DAY DATA ━━━━━━━━━━//
prevHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead=barmerge.lookahead_on)

prevLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead=barmerge.lookahead_on)

prevClose = request.security(
     syminfo.tickerid,
     "D",
     close[1],
     lookahead=barmerge.lookahead_on)

//━━━━━━━━━━ TODAY CPR ━━━━━━━━━━//
pivot = (prevHigh + prevLow + prevClose) / 3

bc = (prevHigh + prevLow) / 2

tc = (2 * pivot) - bc

top = math.max(tc, bc)
bot = math.min(tc, bc)

//━━━━━━━━━━ CPR RANGE ━━━━━━━━━━//
cprRange = math.abs(top - bot)

//━━━━━━━━━━ REAL TOMORROW CPR ━━━━━━━━━━//

todayHigh = request.security(
     syminfo.tickerid,
     "D",
     high,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

todayLow = request.security(
     syminfo.tickerid,
     "D",
     low,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

todayClose = request.security(
     syminfo.tickerid,
     "D",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

// Tomorrow projected CPR
tomPivot = (todayHigh + todayLow + todayClose) / 3

tomBC = (todayHigh + todayLow) / 2

tomTC = (2 * tomPivot) - tomBC

tomTop = math.max(tomTC, tomBC)
tomBot = math.min(tomTC, tomBC)

// Tomorrow CPR Width
tomCPRRange = math.abs(tomTop - tomBot)

// Average Tomorrow CPR
avgTomCPR = ta.sma(tomCPRRange, 10)

// Tomorrow Narrow CPR
tomNarrowCPR = tomCPRRange < avgTomCPR * 0.8

//━━━━━━━━━━ INDIA VIX ━━━━━━━━━━//
vix = request.security(
     "NSE:INDIAVIX",
     timeframe.period,
     close)

//━━━━━━━━━━ VIX + CPR CONDITIONS ━━━━━━━━━━//
cond1 = vix < 15 and cprRange > 50
cond2 = vix >= 15 and vix < 20 and cprRange > 65
cond3 = vix >= 20 and vix < 25 and cprRange > 100
cond4 = vix >= 25 and vix < 30 and cprRange > 125
cond5 = vix >= 30 and cprRange > 150

dangerCPR = cond1 or cond2 or cond3 or cond4 or cond5

//━━━━━━━━━━ CPR POSITION LOGIC ━━━━━━━━━━//
insideCPR = close >= bot and close <= top

belowCPR = close < bot
aboveCPR = close > top

//━━━━━━━━━━ VWAP ━━━━━━━━━━//
vwapValue = ta.vwap(close)

bullVWAP = close > vwapValue
bearVWAP = close < vwapValue

//━━━━━━━━━━ 15 MIN TREND FILTER ━━━━━━━━━━//
ema20_15m = request.security(
     syminfo.tickerid,
     "15",
     ta.ema(close, 20))

ema50_15m = request.security(
     syminfo.tickerid,
     "15",
     ta.ema(close, 50))

bullTrend = ema20_15m > ema50_15m
bearTrend = ema20_15m < ema50_15m

//━━━━━━━━━━ NARROW CPR ━━━━━━━━━━//
avgCPR = ta.sma(cprRange, 10)

narrowCPR = cprRange < avgCPR * 0.7

//━━━━━━━━━━ VOLUME FILTER ━━━━━━━━━━//
avgVol = ta.sma(volume, 5)

highVolume = volume > avgVol

//━━━━━━━━━━ TIME FILTER ━━━━━━━━━━//
tradeSession =
     hour >= 9 and
     (hour < 11 or (hour == 11 and minute <= 30))

//━━━━━━━━━━ COLORS ━━━━━━━━━━//
pivotColor = color.rgb(255, 0, 120)

cprColor = color.rgb(50, 100, 255)

rColor = color.rgb(76, 175, 80)

sColor = color.rgb(255, 82, 82)

pdColor = color.purple

//━━━━━━━━━━ TODAY CPR PLOTS ━━━━━━━━━━//
tcPlot = plot(
     showTC ? top : na,
     title="TC",
     color=cprColor,
     linewidth=2,
     style=plot.style_linebr)

bcPlot = plot(
     showBC ? bot : na,
     title="BC",
     color=cprColor,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showPivot ? pivot : na,
     title="Pivot",
     color=pivotColor,
     linewidth=2,
     style=plot.style_linebr)

//━━━━━━━━━━ TOMORROW CPR PLOTS ━━━━━━━━━━//
tomTCPlot = plot(
     showTomorrowCPR ? tomTop : na,
     title="Tomorrow TC",
     color=color.green,
     linewidth=2,
     offset=1,
     style=plot.style_stepline)

tomBCPlot = plot(
     showTomorrowCPR ? tomBot : na,
     title="Tomorrow BC",
     color=color.red,
     linewidth=2,
     offset=1,
     style=plot.style_stepline)

plot(
     showTomorrowCPR ? tomPivot : na,
     title="Tomorrow Pivot",
     color=color.yellow,
     linewidth=2,
     offset=1,
     style=plot.style_stepline)

fill(
     tomTCPlot,
     tomBCPlot,
     color=color.new(color.orange, 85))

//━━━━━━━━━━ CPR FILL ━━━━━━━━━━//
fill(
     tcPlot,
     bcPlot,
     color = dangerCPR
          ? color.new(color.red, 78)
          : color.new(color.blue, 92))

//━━━━━━━━━━ BACKGROUND ━━━━━━━━━━//
bgcolor(
     belowCPR
     ? color.new(color.orange, 88)
     : aboveCPR
     ? color.new(color.green, 90)
     : na)

//━━━━━━━━━━ VWAP PLOT ━━━━━━━━━━//
plot(
     showVWAP ? vwapValue : na,
     color=color.white,
     linewidth=2)

//━━━━━━━━━━ TREND EMA PLOTS ━━━━━━━━━━//
plot(
     showTrendEMA ? ema20_15m : na,
     color=color.green,
     linewidth=1)

plot(
     showTrendEMA ? ema50_15m : na,
     color=color.red,
     linewidth=1)

//━━━━━━━━━━ STANDARD PIVOTS ━━━━━━━━━━//
r1 = (2 * pivot) - prevLow
s1 = (2 * pivot) - prevHigh

r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)

r3 = prevHigh + 2 * (pivot - prevLow)
s3 = prevLow - 2 * (prevHigh - pivot)

//━━━━━━━━━━ RESISTANCE LEVELS ━━━━━━━━━━//
plot(showR1 ? r1 : na, title="R1", color=rColor)
plot(showR2 ? r2 : na, title="R2", color=rColor)
plot(showR3 ? r3 : na, title="R3", color=rColor)

//━━━━━━━━━━ SUPPORT LEVELS ━━━━━━━━━━//
plot(showS1 ? s1 : na, title="S1", color=sColor)
plot(showS2 ? s2 : na, title="S2", color=sColor)
plot(showS3 ? s3 : na, title="S3", color=sColor)

//━━━━━━━━━━ PREVIOUS DAY HIGH/LOW ━━━━━━━━━━//
plot(showPDH ? prevHigh : na, title="PDH", color=pdColor)
plot(showPDL ? prevLow : na, title="PDL", color=pdColor)

//━━━━━━━━━━ LABELS ━━━━━━━━━━//
newDay = ta.change(time("D"))

if dangerCPR and newDay
    label.new(
         bar_index,
         top,
         "Strong Support at CPR",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

if narrowCPR and newDay
    label.new(
         bar_index,
         bot,
         "Tradable Day",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

//━━━━━━━━━━ TRADE QUALITY CONDITIONS ━━━━━━━━━━//
buyQuality =
     aboveCPR and
     bullVWAP and
     bullTrend and
     highVolume and
     tradeSession and
     not dangerCPR and
     (showTomorrowCPR ? tomNarrowCPR : true) and
     not insideCPR

sellQuality =
     belowCPR and
     bearVWAP and
     bearTrend and
     highVolume and
     tradeSession and
     not dangerCPR and
     (showTomorrowCPR ? tomNarrowCPR : true) and
     not insideCPR

//━━━━━━━━━━ SIGNALS ━━━━━━━━━━//
plotshape(
     buyQuality,
     title="BUY",
     location=location.belowbar,
     color=color.lime,
     style=shape.labelup,
     text="BUY",
     size=size.tiny)

plotshape(
     sellQuality,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL",
     size=size.tiny)
````
