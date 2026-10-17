# OHLC + Range % TAIWO

- url: https://www.tradingview.com/script/YuOtfEYS-OHLC-Range-TAIWO/
- type: indicator
- pine_id: PUB;214d551f494049bb8d9c65a11ebf11ee
- version: 1.0

## Description

The script give a daily range of each candle on each time frame

## Source Code

````pine
//@version=6
indicator("OHLC + Range %", overlay=true)

// Range % = (High - Low) / Open × 100
rangePct = ((high - low) / open) * 100

// Show in OHLC/status line
plot(
     rangePct,
     title="Range %",
     display=display.status_line,
     color=color.new(color.orange, 100)
)

// Optional hidden plot (keeps indicator active)
plot(na, display=display.none)
````
