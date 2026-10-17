# Ichimoku Kinko Hyo: Basic Strategy

- url: https://www.tradingview.com/script/XZcsLIEW-Ichimoku-Kinko-Hyo-Basic-Strategy/
- type: strategy
- pine_id: PUB;mjtrpkHRaDRSrqc8bJqlqNrLVGT5EIYw
- version: 1.0

## Description

[b]Ichimoku Kinko Hyo: Basic Strategy[/b]

Entry/Exit orders are placed when three basic signals are triggered.
[b]Ichimoku Signals:[/b]
1) Tenkan-Sen/Kijun-Sen Cross
[i]Bullish:[/i] Tenkan-Sen is above the Kijun-Sen.
[i]Bearish:[/i] Tenkan-Sen is below the Kijun-Sen.
2) Chikou-Span Cross
[i]Bullish:[/i] Chikou-Span is above the close of 26 bars ago.
[i]Bearish:[/i] Chikou-Span is below the close of 26 bars ago.
3) Price versus Kumo Cloud
[i]Bullish:[/i] Close is above the Kumo Cloud.
[i]Bearish:[/i] Close is below the Kumo Cloud.

[b]Notes:[/b]
1) Long-only or short-only direction is feasible by checkbox. Stop and reverse strategy is taken by default.
2) Built-in Ichimoku indicator is strictly wrong because of counting one extra bar for all Ichimoku components.
Including the current bar like moving average is correct way in Japan. This problem is fixed in my script.

## Source Code

````pine
strategy("Ichimoku Kinko Hyo: Basic Strategy", overlay=true)

//Inputs
ts_bars = input(9, minval=1, title="Tenkan-Sen Bars")
ks_bars = input(26, minval=1, title="Kijun-Sen Bars")
ssb_bars = input(52, minval=1, title="Senkou-Span B Bars")
cs_offset = input(26, minval=1, title="Chikou-Span Offset")
ss_offset = input(26, minval=1, title="Senkou-Span Offset")
long_entry = input(true, title="Long Entry")
short_entry = input(true, title="Short Entry")

middle(len) => avg(lowest(len), highest(len))

// Ichimoku Components
tenkan = middle(ts_bars)
kijun = middle(ks_bars)
senkouA = avg(tenkan, kijun)
senkouB = middle(ssb_bars)

// Plot Ichimoku Kinko Hyo
plot(tenkan, color=#0496ff, title="Tenkan-Sen")
plot(kijun, color=#991515, title="Kijun-Sen")
plot(close, offset=-cs_offset+1, color=#459915, title="Chikou-Span")
sa=plot(senkouA, offset=ss_offset-1, color=green, title="Senkou-Span A")
sb=plot(senkouB, offset=ss_offset-1, color=red, title="Senkou-Span B")
fill(sa, sb, color = senkouA > senkouB ? green : red, title="Cloud color")

ss_high = max(senkouA[ss_offset-1], senkouB[ss_offset-1])
ss_low = min(senkouA[ss_offset-1], senkouB[ss_offset-1])

// Entry/Exit Signals
tk_cross_bull = tenkan > kijun
tk_cross_bear = tenkan < kijun
cs_cross_bull = mom(close, cs_offset-1) > 0
cs_cross_bear = mom(close, cs_offset-1) < 0
price_above_kumo = close > ss_high
price_below_kumo = close < ss_low

bullish = tk_cross_bull and cs_cross_bull and price_above_kumo
bearish = tk_cross_bear and cs_cross_bear and price_below_kumo

strategy.entry("Long", strategy.long, when=bullish and long_entry)
strategy.entry("Short", strategy.short, when=bearish and short_entry)

strategy.close("Long", when=bearish and not short_entry)
strategy.close("Short", when=bullish and not long_entry)
````
