# Trend Pullback by Kidd

- url: https://www.tradingview.com/script/YJT0Djil-Trend-Pullback-by-Kidd/
- type: indicator
- pine_id: PUB;d8c6c72d76d8488b9c7981ed5558f231
- version: 2.0

## Description

Trend Pullback by Kidd — User Guide
Best Market
MNQ (Micro Nasdaq Futures)
Also works on NQ, MES, ES, MYM
Recommended Timeframe
Best:
1 Minute for entries
2 Minute for smoother signals

If the 1m feels too emotional or noisy:

switch to 2m
What The Lines Mean
Green / Red / Yellow Thick Line = 20 EMA

This is the main trend filter.

Green

Bullish trend
Look for LONGS only

Red

Bearish trend
Look for SHORTS only

Yellow

Chop / sideways market
Usually avoid trading

Blue Line = 9 EMA

Momentum / pullback guide

Strong trends often:

ride the 9 EMA
pull back to it
continue
LONG Setup

You want:

20 EMA GREEN
Price ABOVE 20 EMA
Small pullback downward
First green candle closes above previous red candle high
ENTRY appears

That is the continuation entry.

SHORT Setup

You want:

20 EMA RED
Price BELOW 20 EMA
Small pullback upward
First red candle closes below previous green candle low
ENTRY appears

That is the continuation short entry.

ENTRY Line

Green or red horizontal line:

suggested entry level
SL Line

Red horizontal line:

suggested stop loss

Usually placed:

below pullback low for longs
above pullback high for shorts
BEST CONDITIONS

This indicator works BEST when:

market is trending
20 EMA has strong angle
candles are moving cleanly
pullbacks are small
AVOID TRADING WHEN

Avoid:

flat yellow EMA
overlapping candles
tiny back-and-forth candles
sideways chop

That’s where most bad trades happen.

Important

This is NOT:

a guaranteed win system
a fully automated bot
a “take every signal” indicator

This is:

a trend continuation framework.

Best results come from:

patience
selecting cleaner trends
avoiding chop
managing trades manually
Suggested Trading Hours

Best MNQ movement usually:

9:30 AM – 11:00 AM EST
sometimes 2:00 PM – 4:00 PM EST
Suggested Workflow
Wait for clear trend
Wait for pullback
Wait for reclaim candle
Take entry
Cut weak trades quickly
Let strong momentum continue
Recommended Mindset

Do NOT try to:

catch every move
predict tops/bottoms
force trades

The goal is:

trend → pullback → continuation.

## Source Code

````pine
//@version=5
indicator("20 EMA Cross Momentum by Kidd", overlay=true, max_labels_count=500, max_lines_count=500)

//=====================================================
// INPUTS
//=====================================================
emaFastLen    = input.int(9, "Fast EMA")
emaTrendLen   = input.int(20, "Trend EMA")
lineLength    = input.int(8, "Line Length")
cooldownBars  = input.int(5, "Cooldown Bars")

showEMAs      = input.bool(true, "Show EMAs")
showLabels    = input.bool(true, "Show Labels")
showLines     = input.bool(true, "Show Entry / SL Lines")
showCandles   = input.bool(true, "Color Signal Candles")

//=====================================================
// EMAS
//=====================================================
emaFast  = ta.ema(close, emaFastLen)
emaTrend = ta.ema(close, emaTrendLen)

//=====================================================
// TREND COLORS
//=====================================================
trendUp =
     close > emaTrend and
     emaTrend > emaTrend[4]

trendDown =
     close < emaTrend and
     emaTrend < emaTrend[4]

emaColor =
     trendUp ? color.lime :
     trendDown ? color.red :
     color.yellow

//=====================================================
// 20 EMA CROSS MOMENTUM STRATEGY
//=====================================================

// LONG:
// Candle crosses and closes above 20 EMA
// Entry above candle high

bullCross =
     close > emaTrend and
     open < emaTrend and
     close > open

// SHORT:
// Candle crosses and closes below 20 EMA
// Entry below candle low

bearCross =
     close < emaTrend and
     open > emaTrend and
     close < open

//=====================================================
// COOLDOWN
//=====================================================
var int lastSignalBar = na

canSignal =
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars

longSignal  = bullCross and canSignal
shortSignal = bearCross and canSignal

if longSignal or shortSignal
    lastSignalBar := bar_index

//=====================================================
// ENTRY + STOP
//=====================================================
longEntry =
     high + syminfo.mintick

shortEntry =
     low - syminfo.mintick

longStop =
     low

shortStop =
     high

//=====================================================
// PLOTS
//=====================================================
plot(
     showEMAs ? emaFast : na,
     title="9 EMA",
     color=color.blue,
     linewidth=1)

plot(
     showEMAs ? emaTrend : na,
     title="20 EMA",
     color=emaColor,
     linewidth=3)

//=====================================================
// LABELS
//=====================================================
if showLabels and longSignal
    label.new(
         bar_index,
         low,
         "LONG",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

if showLabels and shortSignal
    label.new(
         bar_index,
         high,
         "SHORT",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//=====================================================
// ENTRY + SL LINES
//=====================================================
if showLines and longSignal

    line.new(
         bar_index,
         longEntry,
         bar_index + lineLength,
         longEntry,
         color=color.lime,
         width=2)

    line.new(
         bar_index,
         longStop,
         bar_index + lineLength,
         longStop,
         color=color.red,
         width=2)

    label.new(
         bar_index + lineLength,
         longEntry,
         "ENTRY",
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.white,
         size=size.small)

    label.new(
         bar_index + lineLength,
         longStop,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

if showLines and shortSignal

    line.new(
         bar_index,
         shortEntry,
         bar_index + lineLength,
         shortEntry,
         color=color.red,
         width=2)

    line.new(
         bar_index,
         shortStop,
         bar_index + lineLength,
         shortStop,
         color=color.red,
         width=2)

    label.new(
         bar_index + lineLength,
         shortEntry,
         "ENTRY",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

    label.new(
         bar_index + lineLength,
         shortStop,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//=====================================================
// CANDLE COLORING
//=====================================================
barcolor(
     showCandles and longSignal ? color.lime :
     showCandles and shortSignal ? color.fuchsia :
     na)

//=====================================================
// ALERTS
//=====================================================
alertcondition(
     longSignal,
     title="BULL ALERT",
     message="BULL ALERT - 20 EMA Cross Momentum LONG")

alertcondition(
     shortSignal,
     title="BEAR ALERT",
     message="BEAR ALERT - 20 EMA Cross Momentum SHORT")

alertcondition(
     longSignal or shortSignal,
     title="BULL OR BEAR ALERT",
     message="BULL OR BEAR ALERT - 20 EMA Cross Momentum")
````
