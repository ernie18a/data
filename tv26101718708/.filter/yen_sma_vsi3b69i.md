# Yen SMA

- url: https://www.tradingview.com/script/VSi3b69i-Yen-SMA/
- type: indicator
- pine_id: PUB;b0405fe5ec3e438ebc146588f5ba0733
- version: 1.0

## Description

50 day moving average study that has outer lines overlayed by 10.  For credit spreads, only trade if price is inside orange lines.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © onatski

//@version=6
indicator(title="Yen SMA", shorttitle="Yen SMA", overlay=true, timeframe="", timeframe_gaps=true)
len = input.int(50, minval=1, title="Length")
olay = input.int(10, minval=1, title="Overlay")
src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display = display.none)
out = ta.sma(src, len)
out1o = out + olay
out1u = out - olay
out2o = out + (olay*2)
out2u = out - (olay*2)
plot(out, color=color.black, title="MA", offset=offset)
plot(out1o, color=color.orange, title="MA1O", offset=offset)
plot(out1u, color=color.orange, title="MA1U", offset=offset)
plot(out2o, color=color.purple, title="MA2O", offset=offset)
plot(out2u, color=color.purple, title="MA2U", offset=offset)
````
