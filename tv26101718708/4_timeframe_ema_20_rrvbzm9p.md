# 4 Timeframe EMA 20

- url: https://www.tradingview.com/script/RRvbZm9p-4-Timeframe-EMA-20/
- type: indicator
- pine_id: PUB;f7fabd0f303d45799ad15c239edd46c0
- version: 1.0

## Description

[b]4 Timeframe EMA 20[/b] is a multi-timeframe overlay indicator that plots four EMA lines on a single chart using the same EMA length across four different timeframes: 5-minute, 15-minute, 1-hour, and 4-hour. This allows you to view short-term and higher-timeframe trend structure at the same time without switching between charts.

The script calculates each EMA with request.security(), so each line reflects the EMA value from its own timeframe while remaining visible on your current chart. By default, the indicator displays a 20-period EMA for all four timeframes with distinct colors and line styles for quick visual separation.

[b]Default appearance:[/b]

5m EMA 20: gray solid line.

15m EMA 20: blue dotted line.

1h EMA 20: orange dashed line.

4h EMA 20: red solid line.

[b]Customizable options:[/b]

EMA Length: change the EMA period used for all four timeframes.

Show 5m EMA: turn the 5-minute EMA on or off.

Show 15m EMA: turn the 15-minute EMA on or off.

Show 1h EMA: turn the 1-hour EMA on or off.

Show 4h EMA: turn the 4-hour EMA on or off.

Style tab controls: adjust each line’s color, thickness, visibility, and line presentation directly from TradingView’s built-in Style settings.

This indicator is useful for traders who want a fast read on trend alignment across execution and higher timeframes. For example, you can use the 5m and 15m EMAs for short-term structure while keeping the 1h and 4h EMAs on the chart as broader directional context.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © silverripples

//@version=6
indicator("4 Timeframe EMA 20", overlay=true)

emaLength = input.int(defval=20, title="EMA Length", minval=1, display=display.all - display.status_line)

show5m  = input.bool(defval=true, title="Show 5m EMA",  display=display.all - display.status_line)
show15m = input.bool(defval=true, title="Show 15m EMA", display=display.all - display.status_line)
show1h  = input.bool(defval=true, title="Show 1h EMA",  display=display.all - display.status_line)
show4h  = input.bool(defval=true, title="Show 4h EMA",  display=display.all - display.status_line)

ema5m  = request.security(syminfo.tickerid, "5", ta.ema(close, emaLength))
ema15m = request.security(syminfo.tickerid, "15", ta.ema(close, emaLength))
ema1h  = request.security(syminfo.tickerid, "60", ta.ema(close, emaLength))
ema4h  = request.security(syminfo.tickerid, "240", ta.ema(close, emaLength))

plot(show5m  ? ema5m  : na, title="EMA 20 - 5m",  color=color.gray,   linewidth=1, style=plot.style_line, linestyle=plot.linestyle_solid)
plot(show15m ? ema15m : na, title="EMA 20 - 15m", color=color.blue,   linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dotted)
plot(show1h  ? ema1h  : na, title="EMA 20 - 1h",  color=color.orange, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)
plot(show4h  ? ema4h  : na, title="EMA 20 - 4h",  color=color.red,    linewidth=1, style=plot.style_line, linestyle=plot.linestyle_solid)
````
