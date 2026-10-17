# BSS 20C

- url: https://www.tradingview.com/script/9eIng3dI-BSS-20C/
- type: indicator
- pine_id: PUB;69db085fa9ae4c7484926fce55b58aa8
- version: 1.0

## Description

Buy and sell signal with the profit booking indication $

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kamalbme

//@version=5
indicator("BSS 20C", overlay=true)

// ─── EMA Calculations ───────────────────────────────────────────────────────
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)

// ─── Plot EMAs ───────────────────────────────────────────────────────────────
plot(ema10, title="EMA 10", color=color.blue, linewidth=2)
plot(ema20, title="EMA 20", color=color.black, linewidth=2)

// ─── Crossover Conditions ────────────────────────────────────────────────────
bullishCross = ta.crossover(ema10, ema20)
bearishCross = ta.crossunder(ema10, ema20)

// ─── Trade State Tracking ────────────────────────────────────────────────────
var bool inBuyTrade  = false
var bool inSellTrade = false

if bullishCross
    inBuyTrade  := true
    inSellTrade := false

if bearishCross
    inSellTrade := true
    inBuyTrade  := false

// ─── Profit Booking Conditions ───────────────────────────────────────────────
buyExit  = inBuyTrade  and (close < ema10)
sellExit = inSellTrade and (close > ema10)

if buyExit
    inBuyTrade := false

if sellExit
    inSellTrade := false

// ─── Signal Labels ───────────────────────────────────────────────────────────
var label lbl = na

// Buy Signal — "Buy" below crossover candle
if bullishCross
    label.new(
         bar_index,
         low - ta.atr(14),
         text      = "Buy",
         color     = color.new(color.green, 100),
         textcolor = color.green,
         style     = label.style_label_up,
         size      = size.normal
         )

// Sell Signal — "Sell" above crossover candle
if bearishCross
    label.new(
         bar_index,
         high + ta.atr(14),
         text      = "Sell",
         color     = color.new(color.red, 100),
         textcolor = color.red,
         style     = label.style_label_down,
         size      = size.normal
         )

// Profit Book — "$" above candle on buy exit
if buyExit
    label.new(
         bar_index,
         high + ta.atr(14),
         text      = "$",
         color     = color.new(color.orange, 100),
         textcolor = color.orange,
         style     = label.style_label_down,
         size      = size.normal
         )

// Profit Book — "$" below candle on sell exit
if sellExit
    label.new(
         bar_index,
         low - ta.atr(14),
         text      = "$",
         color     = color.new(color.orange, 100),
         textcolor = color.orange,
         style     = label.style_label_up,
         size      = size.normal
         )

// ─── Entry Level Lines ───────────────────────────────────────────────────────
var line entryLine = na

if bullishCross
    line.delete(entryLine)
    entryLine := line.new(
         bar_index, high,
         bar_index + 10, high,
         color   = color.green,
         width   = 1,
         style   = line.style_dashed,
         extend  = extend.none
         )

if bearishCross
    line.delete(entryLine)
    entryLine := line.new(
         bar_index, low,
         bar_index + 10, low,
         color  = color.red,
         width  = 1,
         style  = line.style_dashed,
         extend = extend.none
         )

// ─── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(bullishCross, title="Buy Signal",       message="EMA 10 crossed above EMA 20 — Buy. Entry above candle high.")
alertcondition(bearishCross, title="Sell Signal",      message="EMA 10 crossed below EMA 20 — Sell. Entry below candle low.")
alertcondition(buyExit,      title="Buy Profit Book",  message="Candle closed below EMA 10 — Book Buy profit.")
alertcondition(sellExit,     title="Sell Profit Book", message="Candle closed above EMA 10 — Book Sell profit.")
````
