# Liquidity Sweep Confirmation

- url: https://www.tradingview.com/script/Yd1nQt6D/
- type: indicator
- pine_id: PUB;9e15ebf3bf664103b0141a8e793478fa
- version: 2.0

## Description

Description
Overview

Liquidity Sweep Confirmation + Trailing TP is a price action indicator designed to identify high-probability reversal and continuation opportunities using liquidity concepts inspired by institutional trading behavior.

The indicator focuses on two key ideas:

Liquidity Sweeps – when price briefly moves above a swing high or below a swing low and then rejects the move.

Confirmation Breaks – when price confirms the rejection by breaking the short-term structure in the opposite direction.

In addition, the indicator includes a dynamic Trailing Take Profit (Trailing TP) system to help lock in profits as the trade moves in your favor.

How It Works
BUY Signal (Liquidity Sweep Long)

A BUY signal is generated when:

A swing low is formed.

Price sweeps below that swing low.

Price rejects the move and starts moving upward.

The rejection structure is confirmed by a bullish break.

This setup suggests that sellers were trapped below liquidity and price is likely to move higher.

SELL Signal (Liquidity Sweep Short)

A SELL signal is generated when:

A swing high is formed.

Price sweeps above that swing high.

Price rejects the move and starts moving downward.

The rejection structure is confirmed by a bearish break.

This setup suggests that buyers were trapped above liquidity and price is likely to move lower.

Trailing Take Profit (TP)

After a BUY or SELL signal, the indicator automatically activates a trailing take profit:

For BUY trades, the trailing TP follows the highest price reached since entry.

For SELL trades, the trailing TP follows the lowest price reached since entry.

The trailing distance is adjustable via the Trailing TP % input.

When price closes beyond the trailing level, a TP signal is triggered and the position is considered closed.

Features

Liquidity-based BUY and SELL signals

Confirmation logic to reduce false sweeps

Built-in Trailing Take Profit system

Customizable swing sensitivity

Customizable trailing percentage

Alert conditions for BUY, SELL, and TP events

Inputs

Swing Length – Defines how many bars are used to detect swing highs and lows.

Trailing TP % – Percentage distance for the trailing take profit.

Alerts

The indicator provides alert conditions for:

BUY Signal

SELL Signal

Long Trailing TP Hit

Short Trailing TP Hit

You can create TradingView alerts using these conditions for automation or notifications.

Best Used For

Price action trading

Liquidity and sweep-based strategies

Trend reversals

Scalping, intraday, and swing trading

Markets with strong liquidity behavior (Forex, Crypto, Indices, Futures)

Important Notes

The indicator is based on swing structure and liquidity behavior, not volume data.

Signals may perform best when aligned with higher-timeframe trend and market context.

Trailing TP is designed for trade management and does not guarantee profit protection in fast-moving markets.

Disclaimer

This indicator is for educational and informational purposes only and should not be considered financial advice. Always test and validate any strategy before using it in live trading.

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep Confirmation", overlay=true, max_labels_count=500)

// Swing ayarı
pivotLen = input.int(3, "Swing Length", minval=1)

// Swingler
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// Sweep takibi
var bool sweptHigh = false
var bool sweptLow  = false

// Sweep oluşumu
if not na(lastHigh) and high > lastHigh
    sweptHigh := true

if not na(lastLow) and low < lastLow
    sweptLow := true

// Rejection yapıları
rejectionLow  = ta.lowest(low, 3)
rejectionHigh = ta.highest(high, 3)

// SELL Confirmation
sellSignal =
     sweptHigh and
     close < rejectionLow[1]

// BUY Confirmation
buySignal =
     sweptLow and
     close > rejectionHigh[1]

// Reset
if buySignal
    sweptLow := false

if sellSignal
    sweptHigh := false

// Sinyaller
plotshape(
     buySignal,
     title="BUY",
     location=location.belowbar,
     color=color.lime,
     style=shape.labelup,
     text="BUY")

plotshape(
     sellSignal,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

// Alarm
alertcondition(
     buySignal,
     title="BUY Alert",
     message="Liquidity Sweep BUY")

alertcondition(
     sellSignal,
     title="SELL Alert",
     message="Liquidity Sweep SELL")
     //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI 70/30 TP (FIXED & WORKING)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiLen = input.int(14, "RSI Length")
rsi = ta.rsi(close, rsiLen)

// SENİN SİNYALLERLE POZİSYON TAKİBİ
var bool inLong = false
var bool inShort = false

if buySignal
    inLong := true
    inShort := false

if sellSignal
    inShort := true
    inLong := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI EXTREME TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LONG için RSI 70'e ulaştı mı?
rsiLongExtreme = inLong and rsi >= 70

// SHORT için RSI 30'a indi mi?
rsiShortExtreme = inShort and rsi <= 30

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP KOŞULLARI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// RSI 70 gördükten sonra tekrar altına düşerse TP
longTP =
     inLong and
     rsiLongExtreme[1] and
     rsi < 70

// RSI 30 gördükten sonra tekrar üstüne çıkarsa TP
shortTP =
     inShort and
     rsiShortExtreme[1] and
     rsi > 30

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RESET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if longTP
    inLong := false

if shortTP
    inShort := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(longTP,
     title="RSI TP LONG",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.blue,
     text="TP")

plotshape(shortTP,
     title="RSI TP SHORT",
     location=location.belowbar,
     style=shape.labelup,
     color=color.orange,
     text="TP")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longTP,
     title="RSI LONG TP",
     message="RSI TP LONG")

alertcondition(shortTP,
     title="RSI SHORT TP",
     message="RSI TP SHORT")
````
