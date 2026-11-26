# Live Weekly EMAs (10, 20, 50, 200)

- url: https://www.tradingview.com/script/pUyWFHxg-Live-Weekly-EMAs-10-20-50-200/
- type: indicator
- pine_id: PUB;053252e306124166ae9266d4107a2611
- version: 1.0

## Description

Weekly EMA lines to populate into the daily chart to identify META opportunities.

## Source Code

````pine
//@version=5
indicator("Live Weekly EMAs (10, 20, 50, 200)", overlay=true)

// --- INPUTS ---
len0 = input.int(10, title="Length 0", group="EMA Settings")
len1 = input.int(20, title="Length 1", group="EMA Settings")
len2 = input.int(50, title="Length 2", group="EMA Settings")
len3 = input.int(200, title="Length 3", group="EMA Settings")

tf = input.timeframe("W", title="Higher Timeframe")

// --- CALCULATION ---
// Using lookahead=barmerge.lookahead_on to see live values on lower timeframes
ema0 = request.security(syminfo.tickerid, tf, ta.ema(close, len0), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
ema1 = request.security(syminfo.tickerid, tf, ta.ema(close, len1), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
ema2 = request.security(syminfo.tickerid, tf, ta.ema(close, len2), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
ema3 = request.security(syminfo.tickerid, tf, ta.ema(close, len3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// --- PLOTTING ---
plot(ema0, color=color.new(color.blue, 0), linewidth=1, title="Weekly EMA 10")
plot(ema1, color=color.new(color.red, 0), linewidth=2, title="Weekly EMA 20")
plot(ema2, color=color.new(color.green, 0), linewidth=2, title="Weekly EMA 50")
plot(ema3, color=color.new(color.purple, 0), linewidth=3, title="Weekly EMA 200")
````
