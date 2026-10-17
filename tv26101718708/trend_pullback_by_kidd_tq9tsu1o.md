# Trend Pullback by Kidd

- url: https://www.tradingview.com/script/TQ9tsU1o-Trend-Pullback-by-Kidd/
- type: indicator
- pine_id: PUB;8e48562047d64dcb98e05ef3a55958f9
- version: 1.0

## Description

Trend Pullback by Kidd — User Instructions
What This Indicator Does

This indicator looks for:

A trend already moving up or down
A small pullback against that trend
The first candle showing momentum back in the trend direction

It is designed for:

scalping
momentum continuation
pullback entries

Best used on:

NQ / MNQ
ES / MES
highly liquid markets
EMA Colors
20 EMA Colors
Green = bullish trend
Red = bearish trend
Yellow = sideways / weak trend
9 EMA
Blue line
Used as short-term momentum support/resistance
LONG Setup

The indicator looks for:

Trend moving UP
Small pullback downward
Green candle closes above previous candle high

When this happens:

LONG label appears
ENTRY line appears
SL line appears
SHORT Setup

The indicator looks for:

Trend moving DOWN
Small pullback upward
Red candle closes below previous candle low

When this happens:

SHORT label appears
ENTRY line appears
SL line appears
ENTRY

The green or red ENTRY line is the suggested entry area.

Green ENTRY = long trade
Red ENTRY = short trade
STOP LOSS

The SL line is based on:

pullback low for longs
pullback high for shorts

This is a structure-based stop loss.

Best Conditions

This indicator works best when:

the 20 EMA has a strong angle
price trends cleanly
pullbacks are controlled and shallow
momentum resumes quickly
Avoid Trading When

Avoid signals when:

20 EMA is yellow/flat
candles overlap heavily
market chops sideways
during dead lunchtime conditions
Recommended Timeframes

Best starting points:

1 minute
2 minute
5 minute
Suggested Markets

Works best on:

MNQ / NQ
MES / ES
high volume futures
Alert Setup

The indicator includes:

BULL ALERT
BEAR ALERT
BULL OR BEAR ALERT

Use:

“Once Per Bar Close”

This prevents premature signals before candles close.

Important Notes

This is:

a pullback continuation indicator
NOT:
a reversal indicator

The goal is:

trade WITH momentum
not against it

Strong trends usually perform best.

## Source Code

````pine
//@version=5
indicator("Trend Pullback by Kidd", overlay=true, max_labels_count=500, max_lines_count=500)

//=====================================================
// INPUTS
//=====================================================
emaFastLen    = input.int(9, "Fast EMA")
emaTrendLen   = input.int(20, "Trend EMA")
slopeBars     = input.int(4, "Trend Slope Bars")
pullbackBars  = input.int(5, "Pullback Lookback")
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
// TREND
//=====================================================
trendUp =
     close > emaTrend and
     emaTrend > emaTrend[slopeBars]

trendDown =
     close < emaTrend and
     emaTrend < emaTrend[slopeBars]

//=====================================================
// PULLBACK DETECTION
//=====================================================
pulledBackLong =
     ta.lowest(low, pullbackBars) <= emaFast

pulledBackShort =
     ta.highest(high, pullbackBars) >= emaFast

//=====================================================
// REENTRY CANDLE
//=====================================================
// LONG:
// Trend up
// Small pullback
// Green candle closes above previous candle high

longSignalRaw =
     trendUp and
     pulledBackLong and
     close > open and
     close > high[1]

// SHORT:
// Trend down
// Small pullback
// Red candle closes below previous candle low

shortSignalRaw =
     trendDown and
     pulledBackShort and
     close < open and
     close < low[1]

//=====================================================
// COOLDOWN
//=====================================================
var int lastSignalBar = na

canSignal =
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars

longSignal  = longSignalRaw and canSignal
shortSignal = shortSignalRaw and canSignal

if longSignal or shortSignal
    lastSignalBar := bar_index

//=====================================================
// ENTRY + STOP
//=====================================================
longEntry  = close
shortEntry = close

longStop  = ta.lowest(low, pullbackBars)
shortStop = ta.highest(high, pullbackBars)

//=====================================================
// EMA COLORS
//=====================================================
emaColor =
     trendUp ? color.lime :
     trendDown ? color.red :
     color.yellow

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
// SIGNAL LABELS
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
     message="BULL ALERT - Trend Pullback LONG")

alertcondition(
     shortSignal,
     title="BEAR ALERT",
     message="BEAR ALERT - Trend Pullback SHORT")

alertcondition(
     longSignal or shortSignal,
     title="BULL OR BEAR ALERT",
     message="BULL OR BEAR ALERT - Trend Pullback")
````
