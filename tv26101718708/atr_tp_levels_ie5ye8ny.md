# ATR TP Levels

- url: https://www.tradingview.com/script/iE5yE8NY-ATR-TP-Levels/
- type: indicator
- pine_id: PUB;56a6ea94ca2f427c899af3f40f10dd05
- version: 1.0

## Description

ATR TP Levels is a trade management tool for swing traders operating on the daily timeframe. Instead of guessing profit targets, it calculates three take profit levels directly from the ATR (Average True Range) recorded on the day you opened the trade — locking volatility as a fixed ruler for the entire duration of the position.

[b]Why ATR-based exits?[/b]
Most traders set targets based on round numbers or arbitrary percentages. ATR-based targets are different — they reflect the actual volatility of the instrument at the moment you entered.

[b]Recommended setup — the 2 ATR combo[/b]
This indicator is designed to pair with a 2 ATR stop loss below your entry. With the default take profit levels set at 3, 4, and 5 ATR above entry, the risk/reward ratios are:

TP1 at 3 ATR → 1.5:1 R/R — first partial close
TP2 at 4 ATR → 2:1 R/R — second partial close
TP3 at 5 ATR → 2.5:1 R/R — third partial close

The multipliers and close percentages are fully customizable — every trader has a different style, risk tolerance, and position sizing approach. Adjust the ATR multipliers to match how far you typically expect a move to extend, and set the close percentages to reflect how aggressively you want to scale out. There are no right or wrong values here — the defaults are a starting point, not a prescription.

[b]How to use it[/b]

Add ATR(14) to your chart. When your trade opens, note the ATR value on that candle.
Open the indicator settings and fill in three values under Trade setup:

Entry price — your exact fill price
ATR at entry — the ATR(14) value from your entry candle
Quantity — your total position size in shares, contracts, or units


Set the trade open date (day, month, year) to the date you entered. The lines will draw from that bar forward.
Optionally adjust the ATR multipliers and close percentages under Take profit levels to match your strategy.


[b]Reading the labels[/b]
Each line shows a label at the right end in the format:
3.0 ATR → 0.150 (187.50, +2.34%)

3.0 ATR — how many ATRs from entry this level is
0.150 — how many units to close at this level (based on your quantity and close %)
187.50 — the exact price of this take profit level
+2.34% — percentage gain from your entry price


[b]Settings reference[/b]
Trade setup — entry price, ATR value, and total position quantity.
Trade open date — the date your trade was opened. Lines start from this bar so the chart stays clean and accurate to your actual trade.
Take profit levels — three independently configurable levels. Each has an ATR multiplier (how far the target is) and a close % (what fraction of your position to sell there). Defaults are 3/4/5 ATR at 15/20/25%.

[b]Notes[/b]

ATR is locked to your entry day — it does not update as the trade progresses. This is intentional. Your targets should reflect the volatility you accepted when you entered, not today's conditions.
Works on any instrument and timeframe, but is designed and calibrated for daily swing trades.
For short trades, you would need to flip the TP calculations — this version is long-only.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © frurak

//@version=6
indicator("ATR TP Levels", overlay=true)

entry       = input.float(0.0, "Entry price",  group="Trade setup")
atr_val     = input.float(0.0, "ATR at entry", group="Trade setup")
quantity    = input.float(1.0, "Quantity",      group="Trade setup", minval=0.01)

trade_day   = input.int(18,   "Day",   minval=1,    maxval=31,   group="Trade open date")
trade_month = input.int(4,    "Month", minval=1,    maxval=12,   group="Trade open date")
trade_year  = input.int(2026, "Year",  minval=2000, maxval=2100, group="Trade open date")

tp1_mult    = input.float(3.0,  "TP1   ATR multiplier", minval=0.1, step=0.5, group="Take profit levels")
tp1_pct     = input.float(15.0, "TP1   close %",        minval=1, maxval=100, step=5, group="Take profit levels")
tp2_mult    = input.float(4.0,  "TP2   ATR multiplier", minval=0.1, step=0.5, group="Take profit levels")
tp2_pct     = input.float(20.0, "TP2   close %",        minval=1, maxval=100, step=5, group="Take profit levels")
tp3_mult    = input.float(5.0,  "TP3   ATR multiplier", minval=0.1, step=0.5, group="Take profit levels")
tp3_pct     = input.float(25.0, "TP3   close %",        minval=1, maxval=100, step=5, group="Take profit levels")

trade_day_ts = timestamp(trade_year, trade_month, trade_day, 0, 0)

take_profit_1 = entry + tp1_mult * atr_val
take_profit_2 = entry + tp2_mult * atr_val
take_profit_3 = entry + tp3_mult * atr_val

tp1_qty  = math.round(quantity * tp1_pct / 100, 2)
tp2_qty  = math.round(quantity * tp2_pct / 100, 2)
tp3_qty  = math.round(quantity * tp3_pct / 100, 2)

tp1_gain = (take_profit_1 - entry) / entry * 100
tp2_gain = (take_profit_2 - entry) / entry * 100
tp3_gain = (take_profit_3 - entry) / entry * 100

var int start_bar = na
var int prev_ts   = na

if prev_ts != trade_day_ts
    start_bar := na
    prev_ts   := trade_day_ts

if time >= trade_day_ts and na(start_bar)
    start_bar := bar_index

if barstate.islast and not na(start_bar)
    line.new(start_bar, take_profit_1, bar_index + 50, take_profit_1, color=color.rgb(0, 0, 0), width=1, style=line.style_dashed)
    line.new(start_bar, take_profit_2, bar_index + 50, take_profit_2, color=color.rgb(0, 0, 0), width=1, style=line.style_dashed)
    line.new(start_bar, take_profit_3, bar_index + 50, take_profit_3, color=color.rgb(0, 0, 0), width=1, style=line.style_dashed)

    label.new(bar_index + 50, take_profit_1, str.tostring(tp1_mult) + " ATR → " + str.tostring(tp1_qty, "0.000") + " (" + str.tostring(take_profit_1, "0.00") + ", +" + str.tostring(tp1_gain, "0.00") + "%)", style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    label.new(bar_index + 50, take_profit_2, str.tostring(tp2_mult) + " ATR → " + str.tostring(tp2_qty, "0.000") + " (" + str.tostring(take_profit_2, "0.00") + ", +" + str.tostring(tp2_gain, "0.00") + "%)", style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    label.new(bar_index + 50, take_profit_3, str.tostring(tp3_mult) + " ATR → " + str.tostring(tp3_qty, "0.000") + " (" + str.tostring(take_profit_3, "0.00") + ", +" + str.tostring(tp3_gain, "0.00") + "%)", style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
````
