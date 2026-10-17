# Daily MAs by Godzilla Trader

- url: https://www.tradingview.com/script/G8NnzAcO-Daily-MAs-by-Godzilla-Trader/
- type: indicator
- pine_id: PUB;abfc0797f2b8489db1dcef86a48641d1
- version: 2.0

## Description

Live daily moving averages for the S&P 500. Plots 5, 10, 20, 21, 50, 100 and 200 period MAs with a real-time dashboard showing current levels. Updates intraday as price moves. Free to use.

## Source Code

````pine
//@version=6
// ============================================================
//  LEGACY PREVIEW — DISCONTINUED (June 2026 version)
//  This early open-source preview is no longer maintained.
//
//  The live, fully maintained Godzilla Trader suite:
//    - Live Moving Averages by GT
//    - SD Levels by GT (expected moves updated daily)
//    - Weinstein Stage Analysis by Godzilla Trader
//    - The O'Neil Suite by Godzilla Trader (flagship)
//
//  Access via godzillatrader.substack.com
// ============================================================
indicator("Daily MAs by Godzilla Trader", overlay=true)
ema21 = ta.ema(close, 21)
plot(ema21, "21 EMA", color=color.new(color.yellow, 0), linewidth=2)
var label note = na
note := barstate.islast ? label.new(bar_index, ema21, "LEGACY SCRIPT — see godzillatrader.substack.com for the live suite", color=color.new(color.black, 20), textcolor=color.yellow, style=label.style_label_left, size=size.normal) : note
````
