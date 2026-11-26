# Daily Turnover (CR Clean)

- url: https://www.tradingview.com/script/T1Q9Y61D-Daily-Turnover-CR-Clean/
- type: indicator
- pine_id: PUB;34fd9718603f4afea1b65444063e2f3a
- version: 1.0

## Description

Daily Turnover (CR Clean) IT WILL CALCULATE LIQUIDITY

## Source Code

````pine
//@version=5
indicator("Daily Turnover (CR Clean)", overlay=true)

// === DAILY DATA ===
[d_close, d_volume] = request.security(syminfo.tickerid, "D", [close, volume])

turnover_d = (d_close * d_volume) / 1e7

// === COLOR LOGIC ===
bg_color = turnover_d < 10 ? color.red : color.green
text_col = color.white

// === TABLE ===
var table t = table.new(position.bottom_right, 2, 1, border_width=1)

// === UPDATE ONLY LAST BAR ===
if barstate.islast
    table.cell(t, 0, 0, "CD", text_color=text_col, bgcolor=bg_color)
    table.cell(t, 1, 0, str.tostring(turnover_d, "#.##"), text_color=text_col, bgcolor=bg_color)
````
