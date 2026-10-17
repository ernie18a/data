# NY Session Bullish Engulfing

- url: https://www.tradingview.com/script/qZpFGO0l/
- type: indicator
- pine_id: PUB;3697959322c14e5d8102b026166b2cdb
- version: 1.0

## Description

Simple bullish engulfing pattern detector filtered by NY trading session (8am-5pm EST).

HOW IT WORKS:
- Detects classic bullish engulfing patterns
- Only triggers during NY session hours
- Green triangle appears below qualifying candles

BEST FOR:
- XAU/USD M1 timeframe
- Forex pairs during NY session
- Reversal confirmations

USAGE:
- Combine with support/resistance zones
- Not a standalone system
- Use as confluence signal

Settings allow you to adjust NY session hours.

## Source Code

````pine
//@version=6
indicator("NY Session Bullish Engulfing", overlay=true)

// Configuración sesión NY
ny_start = input.int(8, "NY Start Hour EST", minval=0, maxval=23)
ny_end = input.int(17, "NY End Hour EST", minval=0, maxval=23)

// Detección sesión NY
current_hour = hour(time, "America/New_York")
is_ny_session = current_hour >= ny_start and current_hour < ny_end

// Lógica Bullish Engulfing
prev_bearish = close[1] < open[1]
current_bullish = close > open
body_engulfs = open <= close[1] and close >= open[1]

bullish_engulfing = prev_bearish and current_bullish and body_engulfs and is_ny_session

// Visualización
plotshape(bullish_engulfing, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Bullish Engulfing")

// Alerta
alertcondition(bullish_engulfing, "Bullish Engulfing NY", "Bullish Engulfing detectado en sesión NY")

// Color barras
barcolor(bullish_engulfing ? color.new(color.green, 50) : na)
````
