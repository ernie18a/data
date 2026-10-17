# USDJPY from JPYUSD Futures

- url: https://www.tradingview.com/script/PIYaCuqg/
- type: indicator
- pine_id: PUB;20e827a9c814464aa9a42cd452d0913c
- version: 1.0

## Description

This indicator fetches CME:6J1! (JPY/USD futures) close price,converts it to USD/JPY using 1 / JPYUSD, and plots it as an overlay line on your USDJPY chart.Useful for comparing spot USDJPY with futures-derived USDJPY.

## Source Code

````pine
//@version=6
indicator("USDJPY from JPYUSD Futures (Robust)", overlay=true)

// Fetch CME:6J1! (JPY/USD futures) close price
jpyusd_close = request.security("CME:6J1!", timeframe.period, close)

// Convert JPY/USD to USD/JPY: 1 / JPYUSD
usdjpy_from_futures = 1.0 / jpyusd_close

// Fill NA values with the last valid value
usdjpy_smoothed = ta.valuewhen(not na(usdjpy_from_futures), usdjpy_from_futures, 0)

// Plot USD/JPY line derived from JPY/USD futures
plot(usdjpy_smoothed, "USDJPY from 6J1!", color=color.red, linewidth=2)
````
