# Kalman + SMA + Swings )

- url: https://www.tradingview.com/script/GnAt00px/
- type: indicator
- pine_id: PUB;835b16c5d2de4f4db7759b57c6877283
- version: 1.0

## Description

This is for those who benefited from the code and developed it further.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GLRSMEER

//@version=6
indicator('Kalman + SMA + Swings )', overlay = true, max_bars_back = 5000)

//=====================================================
// KALMAN SETTINGS
//=====================================================

group_kalman = 'KALMAN SETTINGS'

srcOpt = input.string('Close', 'Kalman Price Source',
     options = ['Close', 'Open', 'High', 'Low', 'HL2', 'HLC3'], group = group_kalman)

processNoise = input.float(0.01, 'Process Noise', step = 0.001, group = group_kalman)
measurementNoise = input.float(3.0, 'Measurement Noise', step = 0.1, group = group_kalman)

showKalman = input.bool(true, 'Show Kalman Filter', group = group_kalman)

//=====================================================
// SMA SETTINGS
//=====================================================

group_ma = 'SMA SETTINGS'

showMA = input.bool(true, 'Show SMA Lines', group = group_ma)

len1 = input.int(5, 'SMA 5')
len2 = input.int(8, 'SMA 8')
len3 = input.int(13, 'SMA 13')
len4 = input.int(50, 'SMA 50')
len5 = input.int(100, 'SMA 100')
len6 = input.int(200, 'SMA 200')

//=====================================================
// SWING SETTINGS
//=====================================================

group_swing = "SWING SETTINGS"

showSwings = input.bool(true, "Show Swing High/Low", group = group_swing)
swingLen = input.int(5, "Swing Length", minval = 1, group = group_swing)

//=====================================================
// PRICE SOURCE
//=====================================================

src = srcOpt == 'Close' ? close :
      srcOpt == 'Open' ? open :
      srcOpt == 'High' ? high :
      srcOpt == 'Low' ? low :
      srcOpt == 'HL2' ? hl2 : hlc3

//=====================================================
// KALMAN FILTER (UP = GREEN / DOWN = RED)
//=====================================================

var float kalman = na
var float error_estimate = 1.0

if na(kalman)
    kalman := src

prediction = kalman
kalman_gain = error_estimate / (error_estimate + measurementNoise)

kalman := prediction + kalman_gain * (src - prediction)
error_estimate := (1 - kalman_gain) * error_estimate + processNoise

kalman_up = kalman >= kalman[1]

kalmanColor = kalman_up ? color.lime : color.red

plot(showKalman ? kalman : na, color = kalmanColor, linewidth = 3, title = "Kalman")

//=====================================================
// SMA
//=====================================================

sma1 = ta.sma(close, len1)
sma2 = ta.sma(close, len2)
sma3 = ta.sma(close, len3)
sma4 = ta.sma(close, len4)
sma5 = ta.sma(close, len5)
sma6 = ta.sma(close, len6)

plot(showMA ? sma1 : na, color=color.lime)
plot(showMA ? sma2 : na, color=color.orange)
plot(showMA ? sma3 : na, color=color.aqua)
plot(showMA ? sma4 : na, color=color.blue)
plot(showMA ? sma5 : na, color=color.fuchsia)
plot(showMA ? sma6 : na, color=color.purple)

//=====================================================
// SWINGS
//=====================================================

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

plotshape(showSwings and not na(swingHigh),
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.tiny,
     offset = -swingLen)

plotshape(showSwings and not na(swingLow),
     style = shape.triangleup,
     location = location.belowbar,
     color = color.lime,
     size = size.tiny,
     offset = -swingLen)
````
