<!-- tradingview-pine-id: PUB;a9e9504f35a543bb85dc1e0bd5bad1d1 -->
<!-- tradingviewscripts-format: 1 -->
# Quantified Relative Volume - Overlay

Source: https://www.tradingview.com/script/vDom4cSE-Quantified-Relative-Volume-Overlay/

## Description

Quantified Relative Volume - Overlay (QRVOL-O)

QRVOL-O marks price candles that occur on abnormally high relative volume, directly on the price chart.

It calculates relative volume (RVol) by comparing the current bar's volume to the average volume at the same time of day over the past 10 sessions (via TradingView's ta.relativeVolume()). When RVol clears your chosen threshold, the candle is flagged as a signal and classified by direction:

Long signal: high RVol on a bullish candle (close > open) — candle is tinted green.
Short signal: high RVol on a bearish candle (close < open) — candle is tinted red.
Doji bars (close == open) are ignored.
Optional arrows (off by default) can be enabled to mark long/short signals below/above the bar. Built-in alert conditions let you set TradingView alerts for long and short signals separately.

Settings:

Volume Ratio: RVol threshold that defines "high" volume.
Candle coloring: on/off, with separate colors for long and short signals.
Arrows: on/off, with separate colors for long and short signals.
QRVOL-O is a companion to the volume-pane indicator "Quantified Relative Volume" (QRVOL), which shows the same RVol logic as a colored volume histogram with record labels (HVE/HVY/HVQ). Use them together for a combined volume-pane + price-chart view, or independently.

This indicator does not predict future price movement or provide investment advice — it is a volume-based visualization tool. Always combine it with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator('Quantified Relative Volume - Overlay', shorttitle = 'QRVOL-O', overlay = true)

volratio = input.float(3.0, 'Volume Ratio', minval = 0.1, group = 'Volume')

show_barcolor = input.bool(true, 'Color Signal Candles', group = 'Candles')
long_color = input.color(color.new(color.lime, 0), 'Long Signal Color', group = 'Candles', inline = 'long')
short_color = input.color(color.new(color.red, 0), 'Short Signal Color', group = 'Candles', inline = 'short')

show_arrows = input.bool(false, 'Show Arrows', group = 'Arrows')
long_arrow_color = input.color(color.lime, 'Long Arrow Color', group = 'Arrows')
short_arrow_color = input.color(color.red, 'Short Arrow Color', group = 'Arrows')

show_long = input.bool(true,'',group = 'Candles', inline = 'long')
show_short = input.bool(false,'',group = 'Candles', inline = 'short')

import TradingView/ta/6
[currentVolume, pastVolume, _] = ta.relativeVolume(10, '1D', true)

rvol = pastVolume > 0 ? currentVolume / pastVolume : na
is_high_rvol = not na(rvol) and rvol > volratio

is_long_candle = close > open
is_short_candle = close < open

is_long_signal = is_high_rvol and is_long_candle
is_short_signal = is_high_rvol and is_short_candle

barcolor(show_long and show_barcolor and is_long_signal ? long_color : show_short and show_barcolor and is_short_signal ? short_color : na)

plotshape(show_long and show_arrows and is_long_signal, title = 'Long Signal', location = location.belowbar, style = shape.arrowup, size = size.small, color = long_arrow_color)
plotshape(show_short and show_arrows and is_short_signal, title = 'Short Signal', location = location.abovebar, style = shape.arrowdown, size = size.small, color = short_arrow_color)

alertcondition(is_long_signal, 'QRVOL Long Signal', 'High RVol on bullish candle - possible long signal')
alertcondition(is_short_signal, 'QRVOL Short Signal', 'High RVol on bearish candle - possible short signal')
````
