# Rajiv MTF VWAP + EMA Cross 

- url: https://www.tradingview.com/script/yA31QHRX-Rajiv-MTF-VWAP-EMA-Cross/
- type: indicator
- pine_id: PUB;c98a489702c74f1d8cad09cecb503b84
- version: 1.0

## Description

This indicator is designed for NIFTY and BANKNIFTY option buying using:

Multi-Timeframe VWAP Alignment
EMA Crossover Confirmation
Fixed Risk-to-Reward Targets
Automatic Entry, Stop Loss, and Target Levels

The goal is to trade only when the trend is aligned across multiple timeframes and momentum confirms the move.

Indicators Used
1. Multi-Timeframe VWAP

The script checks:

Current Chart VWAP
VWAP TF1 (default 5m)
VWAP TF2 (default 15m)
VWAP TF3 (default 30m)
Bullish Condition

Price must be above:

Current VWAP
5m VWAP
15m VWAP
30m VWAP
Bearish Condition

Price must be below:

Current VWAP
5m VWAP
15m VWAP
30m VWAP

This helps ensure the market is trending in the same direction across multiple timeframes.

2. EMA Crossover

Default Settings:

Fast EMA = 9
Slow EMA = 21
BUY CE

9 EMA crosses above 21 EMA.

BUY PE

9 EMA crosses below 21 EMA.

Entry Rules
BUY CE

All conditions must be true:

✅ Price above Current VWAP
✅ Price above 5m VWAP
✅ Price above 15m VWAP
✅ Price above 30m VWAP
✅ 9 EMA crosses above 21 EMA

Signal shown:

BUY CE
BUY PE

All conditions must be true:

✅ Price below Current VWAP
✅ Price below 5m VWAP
✅ Price below 15m VWAP
✅ Price below 30m VWAP
✅ 9 EMA crosses below 21 EMA

Signal shown:

BUY PE
Risk Management
Stop Loss

ATR-based stop loss:

SL = ATR × 1.5
Targets
Target 1

Risk : Reward = 1 : 2

Example:

Entry = 100
SL = 95

Risk = 5

Target 1 = 110
Target 2

Risk : Reward = 1 : 3

Target 3

Risk : Reward = 1 : 4

Chart Elements
Dark Blue Line
Entry Price
Red Line
Stop Loss
Lime Line
Target 1 (1:2 RR)
Green Line
Target 2 (1:3 RR)
Aqua Line
Target 3 (1:4 RR)
Recommended Settings
Scalping
Chart: 3 Minute
VWAP TF1: 5m
VWAP TF2: 15m
VWAP TF3: 30m
Intraday
Chart: 5 Minute
VWAP TF1: 5m
VWAP TF2: 15m
VWAP TF3: 30m
Conservative
Chart: 15 Minute
VWAP TF1: 15m
VWAP TF2: 30m
VWAP TF3: 60m
Best Market Conditions

Works best when:

✅ NIFTY is trending
✅ BANKNIFTY is trending
✅ Opening Range Breakout days
✅ Strong directional sessions

Avoid:

❌ Sideways markets
❌ Low-volatility afternoons
❌ Major event/news whipsaws

Trading Logic Summary

BUY CE

All VWAPs bullish + 9 EMA crosses above 21 EMA

BUY PE

All VWAPs bearish + 9 EMA crosses below 21 EMA

Risk Management

Stop Loss = 1R
Target 1 = 2R
Target 2 = 3R
Target 3 = 4R

This makes the strategy trend-following, multi-timeframe aligned, and centered around a minimum 1:2 reward-to-risk objective on every signal.

## Source Code

````pine
//@version=6
indicator("Rajiv MTF VWAP + EMA Cross 1:2 RR", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━ INPUTS
tf1 = input.timeframe("5", "VWAP TF 1")
tf2 = input.timeframe("15", "VWAP TF 2")
tf3 = input.timeframe("30", "VWAP TF 3")

fastEmaLen = input.int(9, "Fast EMA")
slowEmaLen = input.int(21, "Slow EMA")

atrLen = input.int(14, "ATR Length")
slATR  = input.float(1.5, "SL ATR Multiplier")

extendBars = input.int(40, "Line Extend Bars")

//━━━━━━━━ COLORS
entryColor = color.rgb(0, 51, 153)
slColor    = color.red
tg1Color   = color.lime
tg2Color   = color.green
tg3Color   = color.aqua

//━━━━━━━━ VWAP
vwapCurrent = ta.vwap(close)
vwap1 = request.security(syminfo.tickerid, tf1, ta.vwap(close), barmerge.gaps_off, barmerge.lookahead_off)
vwap2 = request.security(syminfo.tickerid, tf2, ta.vwap(close), barmerge.gaps_off, barmerge.lookahead_off)
vwap3 = request.security(syminfo.tickerid, tf3, ta.vwap(close), barmerge.gaps_off, barmerge.lookahead_off)

plot(vwapCurrent, "Current VWAP", color=color.yellow, linewidth=2)
plot(vwap1, "VWAP TF1", color=color.green)
plot(vwap2, "VWAP TF2", color=color.blue)
plot(vwap3, "VWAP TF3", color=color.orange)

//━━━━━━━━ EMA
fastEMA = ta.ema(close, fastEmaLen)
slowEMA = ta.ema(close, slowEmaLen)

plot(fastEMA, "Fast EMA", color=color.aqua, linewidth=2)
plot(slowEMA, "Slow EMA", color=color.purple, linewidth=2)

emaBullCross = ta.crossover(fastEMA, slowEMA)
emaBearCross = ta.crossunder(fastEMA, slowEMA)

//━━━━━━━━ CONDITIONS
bullVWAP = close > vwapCurrent and close > vwap1 and close > vwap2 and close > vwap3
bearVWAP = close < vwapCurrent and close < vwap1 and close < vwap2 and close < vwap3

buyCE = bullVWAP and emaBullCross
buyPE = bearVWAP and emaBearCross

//━━━━━━━━ ATR RISK
atr = ta.atr(atrLen)
risk = atr * slATR

//━━━━━━━━ LINES
var line entryLine = na
var line slLine = na
var line tg1Line = na
var line tg2Line = na
var line tg3Line = na

var label entryLabel = na
var label slLabel = na
var label tg1Label = na
var label tg2Label = na
var label tg3Label = na

if buyCE
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tg1Line)
    line.delete(tg2Line)
    line.delete(tg3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tg1Label)
    label.delete(tg2Label)
    label.delete(tg3Label)

    entry = close
    sl = entry - risk
    tg1 = entry + risk * 2.0
    tg2 = entry + risk * 3.0
    tg3 = entry + risk * 4.0

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color=entryColor, width=3)
    slLine    := line.new(bar_index, sl, bar_index + extendBars, sl, color=slColor, width=2)
    tg1Line   := line.new(bar_index, tg1, bar_index + extendBars, tg1, color=tg1Color, width=2)
    tg2Line   := line.new(bar_index, tg2, bar_index + extendBars, tg2, color=tg2Color, width=2)
    tg3Line   := line.new(bar_index, tg3, bar_index + extendBars, tg3, color=tg3Color, width=2)

    entryLabel := label.new(bar_index + extendBars, entry, "CE ENTRY", color=entryColor, textcolor=color.white)
    slLabel    := label.new(bar_index + extendBars, sl, "SL", color=slColor, textcolor=color.white)
    tg1Label   := label.new(bar_index + extendBars, tg1, "TARGET 1 - 1:2 RR", color=tg1Color, textcolor=color.black)
    tg2Label   := label.new(bar_index + extendBars, tg2, "TARGET 2 - 1:3 RR", color=tg2Color, textcolor=color.white)
    tg3Label   := label.new(bar_index + extendBars, tg3, "TARGET 3 - 1:4 RR", color=tg3Color, textcolor=color.black)

if buyPE
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tg1Line)
    line.delete(tg2Line)
    line.delete(tg3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tg1Label)
    label.delete(tg2Label)
    label.delete(tg3Label)

    entry = close
    sl = entry + risk
    tg1 = entry - risk * 2.0
    tg2 = entry - risk * 3.0
    tg3 = entry - risk * 4.0

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color=entryColor, width=3)
    slLine    := line.new(bar_index, sl, bar_index + extendBars, sl, color=slColor, width=2)
    tg1Line   := line.new(bar_index, tg1, bar_index + extendBars, tg1, color=tg1Color, width=2)
    tg2Line   := line.new(bar_index, tg2, bar_index + extendBars, tg2, color=tg2Color, width=2)
    tg3Line   := line.new(bar_index, tg3, bar_index + extendBars, tg3, color=tg3Color, width=2)

    entryLabel := label.new(bar_index + extendBars, entry, "PE ENTRY", color=entryColor, textcolor=color.white)
    slLabel    := label.new(bar_index + extendBars, sl, "SL", color=slColor, textcolor=color.white)
    tg1Label   := label.new(bar_index + extendBars, tg1, "TARGET 1 - 1:2 RR", color=tg1Color, textcolor=color.black)
    tg2Label   := label.new(bar_index + extendBars, tg2, "TARGET 2 - 1:3 RR", color=tg2Color, textcolor=color.white)
    tg3Label   := label.new(bar_index + extendBars, tg3, "TARGET 3 - 1:4 RR", color=tg3Color, textcolor=color.black)

//━━━━━━━━ WATERMARK
var label watermark = na
if barstate.islast
    label.delete(watermark)
    watermark := label.new(bar_index, high, "RAJIV", style=label.style_label_center, textcolor=color.new(color.blue, 60), color=color.new(color.white, 100), size=size.large)

//━━━━━━━━ SIGNALS
plotshape(buyCE, title="BUY CE", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY CE", textcolor=color.white)
plotshape(buyPE, title="BUY PE", style=shape.labeldown, location=location.abovebar, color=color.red, text="BUY PE", textcolor=color.white)

//━━━━━━━━ ALERTS
alertcondition(buyCE, title="BUY CE Alert", message="BUY CE: Rajiv MTF VWAP + EMA Bullish Cross | Target 1 = 1:2 RR")
alertcondition(buyPE, title="BUY PE Alert", message="BUY PE: Rajiv MTF VWAP + EMA Bearish Cross | Target 1 = 1:2 RR")
````
