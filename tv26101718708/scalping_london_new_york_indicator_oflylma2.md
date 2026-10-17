# Scalping London New York Indicator

- url: https://www.tradingview.com/script/OFlYLMa2/
- type: indicator
- pine_id: PUB;17869fca6d4c495ebebaef771135c244
- version: 1.0

## Description

Scalping London New York SMA Signal Indicator is a short-term trend-following signal indicator designed for active forex chart analysis, especially on M1 and M5 charts.

The script uses a fast and slow Simple Moving Average to identify the market direction. A buy signal is displayed when the previous confirmed candle is bullish and the fast SMA is above the slow SMA. A sell signal is displayed when the previous confirmed candle is bearish and the fast SMA is below the slow SMA.

The indicator includes a session-style time filter, an optional long-only mode, trend background coloring, and alert conditions for both buy and sell signals. On a 5-minute chart, the moving average periods are automatically adjusted to approximate the original lower-timeframe settings.

Default settings:
Fast SMA: 60
Slow SMA: 280
Time Filter: Enabled
Start Hour: 7
End Hour: 17
Only Long: Disabled
Recommended timeframes: M1 and M5
Recommended market: Forex, especially JPY pairs such as USDJPY

This indicator is intended for chart analysis and signal monitoring only. It does not place trades or perform backtesting.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasayanFX

//@version=6
indicator("Scalping London New York Indicator", overlay=true)

// Inputs
maPeriodFastInput = input.int(60, "Fast SMA Period", minval=1)
maPeriodSlowInput = input.int(280, "Slow SMA Period", minval=1)
onlyLong = input.bool(false, "Only Long")
useTimeFilter = input.bool(true, "Use Time Filter")
startHour = input.int(7, "Start Hour", minval=0, maxval=23)
endHour = input.int(17, "End Hour", minval=0, maxval=23)
showBackground = input.bool(true, "Show Trend Background")
showText = input.bool(false, "Show Signal Text")

// Colors
longMAColor = color.rgb(255, 190, 60)
shortMAColor = color.rgb(0, 220, 255)
buyColor = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)
upBgColor = color.new(color.rgb(0, 120, 255), 94)
downBgColor = color.new(color.rgb(255, 70, 90), 94)

// Indicator Calculations
isM5 = timeframe.isminutes and timeframe.multiplier == 5

fastPeriod = isM5 ? math.max(1, int(maPeriodFastInput / 5)) : maPeriodFastInput
slowPeriod = isM5 ? math.max(1, int(maPeriodSlowInput / 5)) : maPeriodSlowInput

fastMA = ta.sma(close, fastPeriod)
slowMA = ta.sma(close, slowPeriod)

// Time Filter
currentHour = hour(time)

timeAllowed = not useTimeFilter ? true :
     startHour <= endHour ?
     currentHour >= startHour and currentHour <= endHour :
     currentHour >= startHour or currentHour <= endHour

// Signal Logic
longSignal = barstate.isconfirmed and timeAllowed and open[1] < close[1] and fastMA[1] > slowMA[1]
shortSignal = barstate.isconfirmed and timeAllowed and open[1] > close[1] and fastMA[1] < slowMA[1] and not onlyLong

// Plot Lines
plot(fastMA, title="Fast SMA", color=shortMAColor, linewidth=2)
plot(slowMA, title="Slow SMA", color=longMAColor, linewidth=2)

// Background
trendUp = fastMA > slowMA
trendDown = fastMA < slowMA

bgcolor(showBackground ? trendUp ? upBgColor : trendDown ? downBgColor : na : na)

// Signals without text
plotshape(
     longSignal and not showText,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=buyColor,
     size=size.small
)

plotshape(
     shortSignal and not showText,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=sellColor,
     size=size.small
)

// Signals with text
plotshape(
     longSignal and showText,
     title="Buy Signal Text",
     style=shape.triangleup,
     location=location.belowbar,
     color=buyColor,
     size=size.small,
     text="BUY",
     textcolor=buyColor
)

plotshape(
     shortSignal and showText,
     title="Sell Signal Text",
     style=shape.triangledown,
     location=location.abovebar,
     color=sellColor,
     size=size.small,
     text="SELL",
     textcolor=sellColor
)

// Alerts
alertcondition(longSignal, title="Buy Alert", message="Scalping London New York Buy Signal")
alertcondition(shortSignal, title="Sell Alert", message="Scalping London New York Sell Signal")
````
