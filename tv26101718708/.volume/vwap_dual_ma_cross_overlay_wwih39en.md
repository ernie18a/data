# VWAP & Dual MA Cross Overlay

- url: https://www.tradingview.com/script/WwIH39En-VWAP-Dual-MA-Cross-Overlay/
- type: indicator
- pine_id: PUB;87d8b58ef2664746aa498c333746eee0
- version: 1.0

## Description

VWAP & Dual Moving Average Cross Overlay
This clean, chart-overlay indicator tracks market momentum by combining VWAP with two customisable moving averages (4 EMA and 9 EMA by default).

Key Features:On-Chart Overlay: Plots lines directly over price action for clean, seamless tracking.EMA/SMA Toggle: Instantly switch between Exponential and Simple Moving Averages via settings.Instant Cross Alerts: 
Visual green and red triangles highlight exactly when either moving average crosses through the VWAP line.

## Source Code

````pine
//@version=6
indicator('VWAP & Dual MA Cross Overlay', overlay = true)

// Inputs
ma_type = input.string('EMA', title = 'MA Type', options = ['EMA', 'SMA'])
ma1_length = input.int(4, title = 'MA 1 Length')
ma2_length = input.int(9, title = 'MA 2 Length')
show_cross = input.bool(true, title = 'Show VWAP Cross Signals')

// Calculations
vwap_val = ta.vwap

// Moving Average Function
get_ma(type, src, len) =>
    type == 'EMA' ? ta.ema(src, len) : ta.sma(src, len)

ma1 = get_ma(ma_type, close, ma1_length)
ma2 = get_ma(ma_type, close, ma2_length)

// Plotting Lines directly on the chart
plot(vwap_val, color = color.blue, title = 'VWAP', linewidth = 2)
plot(ma1, color = color.green, title = 'MA 1 (4)')
plot(ma2, color = color.red, title = 'MA 2 (9)')

// Cross Detection with VWAP
ma1_cross_up = ta.crossover(ma1, vwap_val)
ma1_cross_down = ta.crossunder(ma1, vwap_val)
ma2_cross_up = ta.crossover(ma2, vwap_val)
ma2_cross_down = ta.crossunder(ma2, vwap_val)

// Plot Shapes for MA 1 (4) Crosses
plotshape(show_cross and ma1_cross_up, title = 'MA 1 Cross Up VWAP', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(show_cross and ma1_cross_down, title = 'MA 1 Cross Down VWAP', style = shape.triangledown, location = location.abovebar, color = color.green, size = size.small)

// Plot Shapes for MA 2 (9) Crosses
plotshape(show_cross and ma2_cross_up, title = 'MA 2 Cross Up VWAP', style = shape.triangleup, location = location.belowbar, color = color.red, size = size.small)
plotshape(show_cross and ma2_cross_down, title = 'MA 2 Cross Down VWAP', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)
````
