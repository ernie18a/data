# ULTIMATE SMC BREAKOUT AI

- url: https://www.tradingview.com/script/i4n0nCUu-ULTIMATE-SMC-BREAKOUT-AI/
- type: indicator
- pine_id: PUB;9b8d87a808a24350afc9564a1aa47758
- version: 1.0

## Description

This is a Pine Script v5 trading indicator named "ULTIMATE SMC BREAKOUT AI". Summary of what it does and how it works:

Purpose

Detects breakout entries aligned with trend, plots suggested entry, stop-loss and two take-profit levels, highlights order blocks, an equilibrium line, and potential reversal zones. Provides alert conditions for buy/sell breakouts and reversal zones.
User inputs (configurable)

Fast/slow EMA lengths (default 50, 200)
ATR length and SL multiplier (default ATR14, SL = 1.2 * ATR)
TP1 and TP2 risk-reward multipliers (default 1.5 and 3.0)
Confirmation bars (default 2)
Toggles to show EMAs, Order Blocks, Equilibrium, Reversal Zones
Core logic

Trend filter: computes fast and slow EMAs. upTrend if EMA_fast > EMA_slow and price > EMA_fast; downTrend if EMA_fast < EMA_slow and price < EMA_fast. EMAs plotted if enabled.
Market structure breakout: defines a 20-bar swing high/low. A bullish breakout is price > prior swingHigh; bearish breakout is price < prior swingLow. A breakout must persist for confirmBars to be considered confirmed.
Entry signals: buySignal requires confirmed bullish breakout + upTrend; sellSignal requires confirmed bearish breakout + downTrend. buyFinal/sellFinal are first-bar triggers (only on the breakout bar).
ATR-based SL/TP: uses ATR to set SL distance (SL = entry ± ATR * slATR). Risk = distance entry↔SL. TP1 and TP2 set at entry ± (risk * tpRR).
Labels: when buyFinal/sellFinal occur the script places an on-chart label with ENTRY, TP1, TP2 prices.
Additional plotted/annotated elements

Order Blocks: highlights single-bar bullish order blocks (prior bar bearish, current close > prior high) and bearish order blocks (prior bar bullish, current close < prior low) as semi-transparent green/red boxes extending ~15 bars forward.
Equilibrium zone: plots mid-price of 50-bar highest high and lowest low (a yellow line).
Predictive Reversal Zones: marks potential reversal boxes when:
Liquidity sweep detected (current high > highest high of 10 bars prior OR current low < lowest low of 10 bars prior),
RSI conditions (RSI > 75 for bearish reversal, RSI < 25 for bullish reversal),
Candle direction confirming (bearish candle for bearish reversal, bullish for bullish reversal). These draw colored boxes and labels for "REVERSAL BUY/SELL ZONE".
Background color: faint green for upTrend, faint red for downTrend.
Alerts

Built-in alertconditions for BUY SIGNAL, SELL SIGNAL, Bullish Reversal, Bearish Reversal (triggerable in TradingView alerts).
Practical notes / behavior

Breakouts use a 20-bar swing lookback and require confirmationBars (default 2) — shorter/longer confirmation changes sensitivity.
SL/TP are purely mechanical from ATR—no partial fills, order execution logic, or trade management beyond TP1/TP2 drawn.
Order blocks detection is simplistic (single-bar pattern) and not a complex multi-bar block identification.
Reversal zones use a combination of liquidity sweep + extreme RSI + candle direction; they are predictive markers, not guarantees.
Designed for overlay on price; many plotted boxes/labels may clutter smaller timeframes or active instruments.

## Source Code

````pine
//@version=5
indicator("ULTIMATE SMC BREAKOUT AI", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================
emaFastLen  = input.int(50, "Fast EMA")
emaSlowLen  = input.int(200, "Slow EMA")

atrLen      = input.int(14, "ATR Length")
slATR       = input.float(1.2, "SL ATR", step=0.1)

tp1RR       = input.float(1.5, "TP1 RR")
tp2RR       = input.float(3.0, "TP2 RR")

confirmBars = input.int(2, "Confirmation Bars")

showEMA     = input.bool(true, "Show EMA")
showOB      = input.bool(true, "Show Order Blocks")
showEQ      = input.bool(true, "Show Equilibrium")
showREV     = input.bool(true, "Show Reversal Zones")

//====================================================
// TREND FILTER
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

upTrend   = emaFast > emaSlow and close > emaFast
downTrend = emaFast < emaSlow and close < emaFast

plot(showEMA ? emaFast : na, color=color.lime, linewidth=2)
plot(showEMA ? emaSlow : na, color=color.red, linewidth=2)

//====================================================
// MARKET STRUCTURE
//====================================================
swingHigh = ta.highest(high, 20)
swingLow  = ta.lowest(low, 20)

bullBreak = close > swingHigh[1]
bearBreak = close < swingLow[1]

bullConfirm = bullBreak and ta.barssince(not bullBreak) >= confirmBars - 1
bearConfirm = bearBreak and ta.barssince(not bearBreak) >= confirmBars - 1

buySignal  = bullConfirm and upTrend
sellSignal = bearConfirm and downTrend

buyFinal  = buySignal and not buySignal[1]
sellFinal = sellSignal and not sellSignal[1]

//====================================================
// ATR TP/SL
//====================================================
atr = ta.atr(atrLen)

// BUY
buyEntry = close
buySL    = buyEntry - atr * slATR
buyRisk  = buyEntry - buySL

buyTP1   = buyEntry + buyRisk * tp1RR
buyTP2   = buyEntry + buyRisk * tp2RR

// SELL
sellEntry = close
sellSL    = sellEntry + atr * slATR
sellRisk  = sellSL - sellEntry

sellTP1   = sellEntry - sellRisk * tp1RR
sellTP2   = sellEntry - sellRisk * tp2RR

//====================================================
// SIGNAL LABELS
//====================================================
if buyFinal
    label.new(
         bar_index,
         low,
         "BUY\nENTRY: " + str.tostring(buyEntry, format.mintick) +
         "\nTP1: " + str.tostring(buyTP1, format.mintick) +
         "\nTP2: " + str.tostring(buyTP2, format.mintick),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal)

if sellFinal
    label.new(
         bar_index,
         high,
         "SELL\nENTRY: " + str.tostring(sellEntry, format.mintick) +
         "\nTP1: " + str.tostring(sellTP1, format.mintick) +
         "\nTP2: " + str.tostring(sellTP2, format.mintick),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

//====================================================
// ORDER BLOCKS
//====================================================
bullishOB = close[1] < open[1] and close > high[1]
bearishOB = close[1] > open[1] and close < low[1]

if showOB and bullishOB
    box.new(
         left=bar_index[1],
         top=open[1],
         right=bar_index + 15,
         bottom=low[1],
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if showOB and bearishOB
    box.new(
         left=bar_index[1],
         top=high[1],
         right=bar_index + 15,
         bottom=open[1],
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

//====================================================
// EQUILIBRIUM ZONE
//====================================================
highestEQ = ta.highest(high, 50)
lowestEQ  = ta.lowest(low, 50)

eqMid = (highestEQ + lowestEQ) / 2

plot(showEQ ? eqMid : na,
     color=color.yellow,
     linewidth=2)

//====================================================
// PREDICTIVE REVERSAL ZONES
//====================================================

// RSI
rsi = ta.rsi(close, 14)

// Liquidity Sweeps
buySideLiquidity  = high > ta.highest(high, 10)[1]
sellSideLiquidity = low < ta.lowest(low, 10)[1]

// Reversal Conditions
bearishReversal =
     buySideLiquidity and
     rsi > 75 and
     close < open

bullishReversal =
     sellSideLiquidity and
     rsi < 25 and
     close > open

// Bearish Reversal Zone
if showREV and bearishReversal
    box.new(
         left=bar_index,
         top=high,
         right=bar_index + 12,
         bottom=close,
         bgcolor=color.new(color.red, 80),
         border_color=color.red)

    label.new(
         bar_index,
         high,
         "REVERSAL SELL ZONE",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

// Bullish Reversal Zone
if showREV and bullishReversal
    box.new(
         left=bar_index,
         top=close,
         right=bar_index + 12,
         bottom=low,
         bgcolor=color.new(color.green, 80),
         border_color=color.lime)

    label.new(
         bar_index,
         low,
         "REVERSAL BUY ZONE",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

//====================================================
// BACKGROUND TREND
//====================================================
bgcolor(
     upTrend ? color.new(color.green, 93) :
     downTrend ? color.new(color.red, 93) : na)

//====================================================
// ALERTS
//====================================================
alertcondition(buyFinal, title="BUY SIGNAL", message="Confirmed BUY breakout")
alertcondition(sellFinal, title="SELL SIGNAL", message="Confirmed SELL breakout")

alertcondition(bullishReversal, title="Bullish Reversal", message="Possible BUY reversal zone")
alertcondition(bearishReversal, title="Bearish Reversal", message="Possible SELL reversal zone")
````
