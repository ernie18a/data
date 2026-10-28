# ATR High Low Max3D

- url: https://www.tradingview.com/script/W66gmrGL-ATR-High-Low-Max3D/
- type: indicator
- pine_id: PUB;4459ee9ac5cc488c8d0ed4ad7c1e47ba
- version: 1.0

## Description

Shows in Status line
- ATR
- candle high + ATR
- candle low - ATR
- Max ATR over last 3 days
- 1.5x 1D ATR

## Source Code

````pine
//@version=6
indicator("ATR High Low Max3D", overlay = false)

lookbackDays = 3
lookbackBars = lookbackDays * 24

// Standard ATR uses 14 periods and RMA smoothing
atr_length = input.int(14, "ATR Length", minval = 1)
atr_val    = ta.atr(atr_length)
maxATR = ta.highest(atr_val, lookbackBars)
atr1D = request.security(syminfo.tickerid, "1D", ta.atr(14))

// --- Calculations ---
high_plus_atr = high + atr_val
low_minus_atr = low - atr_val

// --- Status Line Displays ---
// 'display.status_line' ensures values show in the legend but remain invisible on the chart
plot(atr_val, "ATR", color = color.gray, display = display.status_line)
plot(high_plus_atr, "High + ATR", color = color.green, display = display.status_line)
plot(low_minus_atr, "Low - ATR", color = color.red, display = display.status_line)
plot(maxATR, "Highest 1H ATR in 3 days", color=color.orange, display = display.status_line)
plot(atr1D * 1.5, "1.5x 1D ATR", color=color.orange, display = display.status_line)
````
