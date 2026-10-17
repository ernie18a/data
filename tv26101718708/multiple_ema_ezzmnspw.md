# Multiple EMA

- url: https://www.tradingview.com/script/EzzmnSpw-Multiple-EMA/
- type: indicator
- pine_id: PUB;7972f204e5274fc283a719706e3871d9
- version: 1.0

## Description

[b]Description:
[/b]
Plots up to 9 EMAs on a single chart, combining short-term EMAs with three layers of the Vegas Tunnel — a strategy based on the EMA 144/169 pair — scaled across multiple timeframes.

[b]EMA breakdown:
[/b]
EMA1 (9), EMA2 (20), EMA3 (50) — standard short/mid-term trend EMAs
EMA4 (144) & EMA5 (169) — Vegas Tunnel for the 1m timeframe
EMA6 (432) & EMA7 (507) — Vegas Tunnel for the 3m timeframe (×3)
EMA8 (720) & EMA9 (845) — Vegas Tunnel for the 5m timeframe (×5)

[b]How to use:
[/b]
Apply to a 1-minute chart to see all three tunnel layers simultaneously.
Price trading between an EMA pair (the "tunnel") signals a consolidation/decision zone; a clean break and close outside the tunnel signals a potential trend entry.
The three layers provide confluence — when price breaks through all tunnels, the trend signal is stronger.
All lengths are customizable if you want to scale to different base timeframes.

## Source Code

````pine
//@version=6
indicator(title="Multiple EMA", shorttitle="EMA", precision=8, overlay=true)

len1 = input.int(9, title="EMA1 Length")
len2 = input.int(20, title="EMA2 Length")
len3 = input.int(50, title="EMA3 Length")
len4 = input.int(144, title="EMA4 Length")
len5 = input.int(169, title="EMA5 Length")
len6 = input.int(432, title="EMA6 Length")
len7 = input.int(507, title="EMA7 Length")
len8 = input.int(720, title="EMA8 Length")
len9 = input.int(845, title="EMA9 Length")

lineWidth = input.int(1, minval=1, title="Line width")

src = input.source(close, title="Source")

EMA1 = len1 != 0 ? ta.ema(src, len1) : na
EMA2 = len2 != 0 ? ta.ema(src, len2) : na
EMA3 = len3 != 0 ? ta.ema(src, len3) : na
EMA4 = len4 != 0 ? ta.ema(src, len4) : na
EMA5 = len5 != 0 ? ta.ema(src, len5) : na
EMA6 = len6 != 0 ? ta.ema(src, len6) : na
EMA7 = len7 != 0 ? ta.ema(src, len7) : na
EMA8 = len8 != 0 ? ta.ema(src, len8) : na
EMA9 = len9 != 0 ? ta.ema(src, len9) : na

plot(EMA1, color=#00BCD4, title="EMA1", linewidth=lineWidth)
plot(EMA2, color=#FF9802, title="EMA2", linewidth=lineWidth)
plot(EMA3, color=#2A63FF, title="EMA3", linewidth=lineWidth)
plot(EMA4, color=#4DAF50, title="EMA4", linewidth=lineWidth)
plot(EMA5, color=#9C27B0, title="EMA5", linewidth=lineWidth)
plot(EMA6, color=#E65100, title="EMA6", linewidth=lineWidth)
plot(EMA7, color=#811922, title="EMA7", linewidth=lineWidth)
plot(EMA8, color=#0C329A, title="EMA8", linewidth=lineWidth)
plot(EMA9, color=#00332A, title="EMA9", linewidth=lineWidth)
````
