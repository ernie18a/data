# PPR Action Price

- url: https://www.tradingview.com/script/jdyaqVsn-PPR-Action-Price/
- type: indicator
- pine_id: PUB;5fd6fb9f1cf24526b6930abeb5b3290a
- version: 8.0

## Description

Indicator finds PPR action price and adding label below each candle. This indicator best works on Forex and 4 hours timeline. Enjoy!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sotrosh

//@version=6
indicator("PPR Action Price", overlay=true, max_labels_count=500)
buyTextColor = input.color(color.rgb(33, 243, 65), "BUY Label Color")
sellTextColor = input.color(color.rgb(243, 33, 121, 15), "SELL Label Color")
isVWAPFilter = input.bool(false, title="VWAP FIlter")
isEMAFilter = input.bool(false, title="EMA FIlter")
emaLength = input.int(
     20,
     title = "EMA Length",
     minval = 1,
     maxval = 200,
     step = 1,
     active = isEMAFilter
)

is_candle_upside(opened, closed) => opened < closed

is_current_candle_upside = is_candle_upside(open, close)

is_ppr_buy = is_current_candle_upside and not(is_candle_upside(open[1], close[1])) and not(is_candle_upside(open[2], close[2])) and close > high[1]
is_ppr_sell = is_candle_upside(open[1], close[1]) and is_candle_upside(open[2], close[2]) and not(is_current_candle_upside) and close < low[1]

// VWAP
vwap = ta.vwap

if isVWAPFilter and is_ppr_buy and (close < vwap or open < vwap)
    is_ppr_buy := false

if isVWAPFilter and is_ppr_sell and (close > vwap or open > vwap)
    is_ppr_sell := false

// EMA
ema = ta.ema(close, emaLength)

if isEMAFilter and is_ppr_buy and (close < ema or open < ema)
    is_ppr_buy := false

if isEMAFilter and is_ppr_sell and (close > ema or open > ema)
    is_ppr_sell := false

if is_ppr_buy
    label.new(
        bar_index,
        low,
        "PPR BUY",
        style=label.style_none,
        color=color.green,
        textcolor=buyTextColor,
        size=size.normal
    )
else if is_ppr_sell
    label.new(
        bar_index,
        low,
        "PPR SELL",
        style=label.style_none,
        color=color.green,
        textcolor=sellTextColor,
        size=size.normal
    )
````
