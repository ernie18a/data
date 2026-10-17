# Revenue per diluted share

- url: https://www.tradingview.com/script/KHA2lTer-Revenue-per-diluted-share/
- type: indicator
- pine_id: PUB;4253dbde9ab34928998442375fdde6ee
- version: 1.0

## Description

This displays revenue per diluted share, taking into account known new share issues.
Generated withClaude.

## Source Code

````pine
//@version=5
indicator("Revenue per Share", overlay=false, format=format.price, precision=2)

// 1. Pull the financial data
rev = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "TTM", ignore_invalid_symbol=true)
shares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol=true)

// 2. Calculate the base Revenue per Share
rps = rev / shares

// 3. Detect ONLY the days where the data updates (or the very last day on the chart)
is_new_point = ta.change(rps) != 0 or (na(rps[1]) and not na(rps)) or barstate.islast

// 4. Keep the value on those specific days, but force the days in between to be empty
smooth_rps = is_new_point ? rps : na

// 5. Plot the smooth result line
plot(smooth_rps, title="Rev/Share", color=color.teal, linewidth=2, style=plot.style_line)

// 6. Draw the text labels on the chart
if is_new_point and not na(rps)
    label.new(x=bar_index, y=rps, text="$" + str.tostring(rps, "#.##"), color=color.new(color.white, 100), textcolor=color.teal, style=label.style_none, size=size.normal)
````
