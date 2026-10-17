# UT Bot Alerts + 200 EMA Filter

- url: https://www.tradingview.com/script/65OOYCZs-UT-Bot-Alerts-200-EMA-Filter/
- type: indicator
- pine_id: PUB;c7bd806f481e4b7e8dd1a573956793f4
- version: 1.0

## Description

This indicator optimizes the classic UT Bot Alerts logic by fusing it with an institutional-grade trend filter (200 EMA). While the standard UT Bot is incredibly powerful at catching micro-trends, it is notoriously prone to severe "choppy market" losses and false entries when a market consolidates.

This script solves that vulnerability. It dynamically filters out counter-trend noise, ensuring you only receive execution-ready signals that align with the macro momentum of the market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hardy2004

//@version=5
indicator("UT Bot Alerts + 200 EMA Filter", overlay=true)

// --- Inputs ---
// UT Bot Settings
key_value  = input.float(2.0, title="UT Key Value (Sensitivity)")
atr_period = input.int(10, title="UT ATR Period")
// Filter Settings
use_ema_filter = input.bool(true, title="Filter with 200 EMA?")
ema_period     = input.int(200, title="EMA Period")

// --- UT Bot Logic ---
xATR = ta.atr(atr_period)
nLoss = key_value * xATR

var float xATRTrailingStop = na
src = close

xATRTrailingStop := if src > nz(xATRTrailingStop[1], 0) and src[1] > nz(xATRTrailingStop[1], 0)
    math.max(nz(xATRTrailingStop[1], 0), src - nLoss)
else if src < nz(xATRTrailingStop[1], 0) and src[1] < nz(xATRTrailingStop[1], 0)
    math.min(nz(xATRTrailingStop[1], 0), src + nLoss)
else if src > nz(xATRTrailingStop[1], 0)
    src - nLoss
else
    src + nLoss

var int position = 0
if src > nz(xATRTrailingStop[1], 0) and src[1] <= nz(xATRTrailingStop[1], 0)
    position := 1
else if src < nz(xATRTrailingStop[1], 0) and src[1] >= nz(xATRTrailingStop[1], 0)
    position := -1

ut_buy  = ta.crossunder(xATRTrailingStop, src)
ut_sell = ta.crossover(xATRTrailingStop, src)

// --- EMA Filter Logic ---
ema_filter = ta.ema(close, ema_period)
plot(ema_filter, color=color.blue, linewidth=2, title="200 EMA Filter")

// Apply conditions
filtered_buy  = use_ema_filter ? (ut_buy and close > ema_filter) : ut_buy
filtered_sell = use_ema_filter ? (ut_sell and close < ema_filter) : ut_sell

// --- Plots & Shapes ---
plotshape(filtered_buy, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(filtered_sell, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// --- Alerts ---
alertcondition(filtered_buy, title="UT Bot Filtered Buy", message="UT Bot BUY Signal (Trend Aligned)")
alertcondition(filtered_sell, title="UT Bot Filtered Sell", message="UT Bot SELL Signal (Trend Aligned)")
````
