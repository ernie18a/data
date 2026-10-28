# First Hour High Low + 10:15 Mark_Kali

- url: https://www.tradingview.com/script/NChAaWZt-First-Hour-High-Low-10-15-Mark-Kali/
- type: indicator
- pine_id: PUB;2935fa8f0ed144e78223b52b113a0999
- version: 1.0

## Description

[b]First Hour High Low Indicator[/b]

This indicator automatically marks the First Hour High and First Hour Low of the trading session and extends those levels only within the same trading day. It is specially designed for intraday traders who focus on support-resistance reactions, failed breakouts, and failed breakdown setups.

The indicator also places a visual marker at 10:15 AM, showing the completion of the first trading hour.

[b]Key Features[/b]
Automatically detects the first hour range (9:15 AM – 10:15 AM)
[b]Draws:[/b]
First Hour High
First Hour Low
Lines remain restricted to the same trading day
Historical levels visible for manual backtesting
10:15 AM session completion marker
Clean chart visualization without clutter
[b]How I Use It[/b]

The first hour range often acts as an important intraday support and resistance zone.

I mainly use this indicator to identify:

Failed breakouts above First Hour High
Failed breakdowns below First Hour Low
Rejections from these levels
Support and resistance retests
Reversal opportunities after liquidity grabs

[b]In many cases:[/b]

Price breaks the First Hour High/Low,
Traders enter breakout trades,
But price quickly reverses back inside the range.

These failed moves can provide high probability trading opportunities with relatively small stop losses.

[b]Best Use Cases[/b]
Index trading
Options trading
Intraday momentum trading
Reversal trading
ORB (Opening Range Breakout) analysis
Manual chart study and backtesting
Recommended Timeframes

[b]Works best on:[/b]

1 Minute
3 Minute
5 Minute
15 Minute charts
Important Note

This indicator is a price action tool and should be used together with:

Volume
Market trend
Price structure
Risk management

No indicator guarantees profits. Always manage risk properly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kalidasdubey20

//@version=5
indicator("First Hour High Low + 10:15 Mark", overlay=true)

// ===== INPUTS =====
firstHourSession = input.session("0915-1015", "First Hour")
marketSession    = input.session("0915-1530", "Market Hours")

// ===== VARIABLES =====
var float fhHigh = na
var float fhLow  = na
var int startBar = na

// ===== SESSION CONDITIONS =====
inFirstHour = not na(time(timeframe.period, firstHourSession))
inMarket    = not na(time(timeframe.period, marketSession))

// ===== RESET EVERY NEW DAY =====
if ta.change(time("D"))
    fhHigh := na
    fhLow := na
    startBar := na

// ===== STORE FIRST BAR =====
if inMarket and na(startBar)
    startBar := bar_index

// ===== FIRST HOUR HIGH LOW =====
if inFirstHour
    fhHigh := na(fhHigh) ? high : math.max(fhHigh, high)
    fhLow  := na(fhLow)  ? low  : math.min(fhLow, low)

// ===== DETECT FIRST HOUR END =====
firstHourEnded = not inFirstHour and inFirstHour[1]

// ===== DRAW HIGH LOW LINES =====
if firstHourEnded

    // HIGH LINE
    line.new(
         x1 = startBar,
         y1 = fhHigh,
         x2 = startBar + 75,
         y2 = fhHigh,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.green,
         width = 2)

    // LOW LINE
    line.new(
         x1 = startBar,
         y1 = fhLow,
         x2 = startBar + 75,
         y2 = fhLow,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.red,
         width = 2)

    // 10:15 MARK
    label.new(
         x = bar_index,
         y = high,
         text = "10:15",
         style = label.style_label_down,
         color = color.yellow,
         textcolor = color.black,
         size = size.small)
````
