# Quantified Relative Volume - Overlay

- url: https://www.tradingview.com/script/vDom4cSE-Quantified-Relative-Volume-Overlay/
- type: indicator
- pine_id: PUB;a9e9504f35a543bb85dc1e0bd5bad1d1
- version: 4.0

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

show_highlighter = input.bool(true, 'Show Candle Highlighter Outline', group = 'Candle Highlighter')
highlighter_threshold = input.float(75, 'Body/Range Threshold (%)', minval = 0, maxval = 100, step = 1, group = 'Candle Highlighter', tooltip = 'Mindestanteil des Kerzenkörpers an der gesamten Kerzenlänge (High-Low), ab dem die Kerze markiert wird.')
highlighter_fill_color = input.color(color.new(color.yellow, 90), 'Highlighter Fill Color', group = 'Candle Highlighter')
highlighter_padding_pct = input.float(20, 'Outline Padding (% of candle range)', minval = 0, maxval = 100, step = 1, group = 'Candle Highlighter', tooltip = 'Wie viel größer als High/Low der Rahmen sein soll, als Prozentsatz der Kerzen-Range (High-Low).')
useWickInclusive = input.bool(true, 'Doji/Null-Range Kerzen ignorieren', group = 'Candle Highlighter', tooltip = 'Wenn High=Low (Range=0), wird die Kerze nicht markiert, um Division durch 0 zu vermeiden.')

import TradingView/ta/6
[currentVolume, pastVolume, _] = ta.relativeVolume(10, '1D', true)

rvol = pastVolume > 0 ? currentVolume / pastVolume : na
is_high_rvol = not na(rvol) and rvol > volratio

is_long_candle = close > open
is_short_candle = close < open

is_excluded_market = syminfo.type == 'forex' or syminfo.type == 'cfd'

is_long_signal = is_high_rvol and is_long_candle and not is_excluded_market
is_short_signal = is_high_rvol and is_short_candle and not is_excluded_market

barcolor(show_long and show_barcolor and is_long_signal ? long_color : show_short and show_barcolor and is_short_signal ? short_color : na)

plotshape(show_long and show_arrows and is_long_signal, title = 'Long Signal', location = location.belowbar, style = shape.arrowup, size = size.small, color = long_arrow_color)
plotshape(show_short and show_arrows and is_short_signal, title = 'Short Signal', location = location.abovebar, style = shape.arrowdown, size = size.small, color = short_arrow_color)

alertcondition(is_long_signal, 'QRVOL Long Signal', 'High RVol on bullish candle - possible long signal')
alertcondition(is_short_signal, 'QRVOL Short Signal', 'High RVol on bearish candle - possible short signal')

// --- Candle Highlighter: separate visual layer (outline via plotcandle), doesn't fight with barcolor ---
bodySize = math.abs(close - open)
candleRange = high - low
bodyRatio = candleRange > 0 ? (bodySize / candleRange) * 100 : (useWickInclusive ? 0 : 100)
isHighlighted = bodyRatio >= highlighter_threshold

pad = candleRange * (highlighter_padding_pct / 100)
outlineTop = high + pad
outlineBottom = low - pad
plotcandle(outlineTop, outlineTop, outlineBottom, outlineBottom, title = 'Highlighter Outline', color = show_highlighter and isHighlighted ? highlighter_fill_color : na, wickcolor = na, bordercolor = show_highlighter and isHighlighted ? highlighter_fill_color : na)
````
