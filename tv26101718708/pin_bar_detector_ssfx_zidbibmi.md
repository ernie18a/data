# Pin Bar Detector [SSFX]

- url: https://www.tradingview.com/script/ziDBibMI-Pin-Bar-Detector-SSFX/
- type: indicator
- pine_id: PUB;20b0ed6e7a854e0ca279b7c5ce26ad50
- version: 1.0

## Description

Pin Bar Detector [SSFX] is an indicator designed to automatically identify Bullish Pin Bars and Bearish Pin Bars directly on the chart based on candle structure and wick proportions. It is built for price action traders who want a fast and objective way to spot rejection candles without manually checking every bar.

The script evaluates each candle using three main components:
[list]
[*]Body size relative to the full candle range
[*]Main wick size
[*]Opposite wick size
[/list]
For a Bullish Pin Bar, the indicator looks for candles with:
[list]
[*]a small body
[*]a long lower wick
[*]a small upper wick
[/list]
For a Bearish Pin Bar, the indicator looks for candles with:
[list]
[*]a small body
[*]a long upper wick
[*]a small lower wick
[/list]
One of the main strengths of this script is its flexibility. Users can adjust how strict the pin bar definition should be through the available inputs:
[list]
[*]Max body % of candle range: sets the maximum body size allowed relative to the full candle range
[*]Min long wick % of candle range: requires the main wick to represent at least a certain percentage of the full candle range
[*]Max opposite wick % of candle range: limits the size of the opposite wick so the candle keeps a clean pin bar structure
[/list]
In addition to wick and body structure, the indicator also includes an optional candle color filter for stricter confirmation:
[list]
[*]Bullish Pin Bar must close bullish 
[*]Bearish Pin Bar must close bearish 
[/list]
This helps filter out candles that visually resemble pin bars but close with weaker confirmation.

For visualization, the indicator supports:
[list]
[*]bullish markers below bullish pin bars
[*]bearish markers above bearish pin bars
[*]optional text labels
[*]optional candle coloring for detected pin bars
[*]built-in alert conditions for TradingView alerts
[/list]
This indicator can be useful in many price action situations, such as:
[list]
[*]spotting reversal candles at support and resistance
[*]identifying rejection candles in trending markets
[*]combining with market structure, supply and demand, trendlines, or moving averages
[*]scanning for price action setups across multiple timeframes
[/list]
Disclaimer: This indicator is for educational and research purposes only. It does not provide financial advice or guarantee trading performance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SimplySafeFx

//@version=6
indicator("Pin Bar Detector [SSFX]", overlay = true, max_labels_count = 500)

//==============================
// Inputs
//==============================
grpLogic = "Pin Bar Logic"
maxBodyPct        = input.float(20.0, "Max body % of candle range", minval = 1, maxval = 100, step = 0.5, group = grpLogic)
minLongWickPct    = input.float(70.0, "Min long wick % of candle range", minval = 1, maxval = 100, step = 0.5, group = grpLogic)
maxOppWickPct     = input.float(20.0, "Max opposite wick % of candle range", minval = 0, maxval = 100, step = 0.5, group = grpLogic)

grpFilter = "Color Filter"
requireBullGreen  = input.bool(true, "Bullish pin bar must close green", group = grpFilter)
requireBearRed    = input.bool(true, "Bearish pin bar must close red", group = grpFilter)

grpDisplay = "Display"
showBullish        = input.bool(true, "Show Bullish Pin Bar", group = grpDisplay)
showBearish        = input.bool(true, "Show Bearish Pin Bar", group = grpDisplay)
showBarColor       = input.bool(false, "Color pin bar candles", group = grpDisplay)
showLabel          = input.bool(true, "Show labels", group = grpDisplay)

//==============================
// Candle calculations
//==============================
candleRange = high - low
bodySize    = math.abs(close - open)
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low

validRange = candleRange > 0

bodyPct     = validRange ? bodySize / candleRange * 100 : 0.0
upperWickPct= validRange ? upperWick / candleRange * 100 : 0.0
lowerWickPct= validRange ? lowerWick / candleRange * 100 : 0.0

isGreen = close > open
isRed   = close < open

//==============================
// Bullish Pin Bar
//==============================
bullishPinRaw =
     validRange and
     bodyPct <= maxBodyPct and
     lowerWickPct >= minLongWickPct and
     upperWickPct <= maxOppWickPct

bullishPin = bullishPinRaw and (not requireBullGreen or isGreen)

//==============================
// Bearish Pin Bar
//==============================
bearishPinRaw =
     validRange and
     bodyPct <= maxBodyPct and
     upperWickPct >= minLongWickPct and
     lowerWickPct <= maxOppWickPct

bearishPin = bearishPinRaw and (not requireBearRed or isRed)

//==============================
// Optional labels
//==============================
if showLabel and showBullish and bullishPin
    label.new(bar_index, low, "Bull Pin", style = label.style_label_up, color = color.lime, textcolor = color.white, size = size.tiny)

if showLabel and showBearish and bearishPin
    label.new(bar_index, high, "Bear Pin", style = label.style_label_down, color = color.red, textcolor = color.white, size = size.tiny)

//==============================
// Optional bar color
//==============================
barcolor(
     showBarColor
     ? bullishPin ? color.lime
     : bearishPin ? color.red
     : na
     : na
)
//==============================
// Alerts
//==============================
alertcondition(bullishPin, title = "Bullish Pin Bar", message = "Bullish Pin Bar detected on {{ticker}} - {{interval}}")
alertcondition(bearishPin, title = "Bearish Pin Bar", message = "Bearish Pin Bar detected on {{ticker}} - {{interval}}")
````
