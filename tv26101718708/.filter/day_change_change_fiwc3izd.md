# Day Change & % Change

- url: https://www.tradingview.com/script/FiwC3IzD-Day-Change-Change/
- type: indicator
- pine_id: PUB;5e7e591d3a0641ae80a28a59c6c38778
- version: 1.0

## Description

Shows Change and Change % while Backtesting Helps A lot if you Trade the Trend and Can Help you find the best stocks while Trading

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NicTradez
//@version=6
indicator("Day Change & % Change", overlay=true)

// ─── Get today's opening price ─────────────────────────────
dayOpen = request.security(syminfo.tickerid, "1D", open, lookahead=barmerge.lookahead_off)

// ─── Calculate dollar change and % change from day's open ──
dollarChange = close - dayOpen
pctChange    = dollarChange / dayOpen * 100

isUp = dollarChange >= 0
chgColor = isUp ? color.new(color.green, 0) : color.new(color.red, 0)

// ─── Format like TradingView's native display: +2.35 (+1.20%) ──
sign = isUp ? "+" : ""
displayText = sign + str.tostring(dollarChange, "#.##") + "  (" + sign + str.tostring(pctChange, "#.##") + "%)"

// ─── Table positioned top-right, like the native ticker box ──
var table t = table.new(position.top_right, 1, 1, border_width=0)
if barstate.islast
    table.cell(t, 0, 0, displayText,
         text_color=chgColor,
         text_size=size.large,
         bgcolor=color.new(color.black, 100))
````
