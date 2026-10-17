# Agent Doji Session Zones US100

- url: https://www.tradingview.com/script/yJPbcBzj-Agent-Doji-Session-Zones-US100/
- type: indicator
- pine_id: PUB;c4c2ec104f6345ff84b53393e2c74fd2
- version: 1.0

## Description

Overview

AVE Agent US100 Doji Session Zones is an intraday charting tool developed specifically for the US100 index.

The indicator detects small-body candles during a defined New York trading window and converts each qualifying candle into a temporary price zone. When a valid candle appears between 9:30 AM and 11:00 AM GMT-4, the script draws a box from the candle’s high to its low and extends the zone until 12:30 PM.

A dashed midpoint is also displayed at 50% of the candle’s total range.

Detection logic

A candle qualifies when both conditions are met:

The candle body is no greater than 0.5 US100 index points
The combined length of the upper and lower wicks is no greater than 30 US100 index points

The candle body is calculated using the absolute difference between the open and close.

The total wick size is calculated by adding the upper wick and lower wick together. The two wicks do not need to be equal. One wick may be larger than the other, provided their combined size stays within the allowed limit.

Session filter

New zones are created only during the following period:

Detection start: 9:30 AM GMT-4
Detection end: 11:00 AM GMT-4
Zone extension: 12:30 PM GMT-4

Candles outside the detection period do not create new zones.

Zone construction

For every qualifying candle, the indicator draws:

A box covering the complete candle range
An upper boundary at the candle high
A lower boundary at the candle low
A dashed midpoint at 50% of the range
A horizontal extension until 12:30 PM GMT-4

The zone is intended to represent a short-term area of balance or indecision that formed during the selected US100 session.

Session visualization

The script also provides visual session guidance:

The chart background is darkened outside the 9:30 AM to 12:30 PM session
A blue background marker highlights 11:00 AM
A red background marker highlights 12:30 PM

These markers separate the candle-detection period from the later observation period.

How to use it

The indicator is designed as a discretionary analysis tool rather than a complete trading system.

Traders may use the zones to observe:

Reactions at the zone high or low
Rejections from the zone boundaries
Breakouts above or below the zone
Retests after a breakout
Price interaction with the midpoint
Acceptance or rejection of the original candle range

The tool does not automatically determine market direction and does not provide direct buy or sell signals.

Entries, stop-losses, profit targets, confirmations and risk-management rules must be defined separately by the trader.

Originality and purpose

The script combines several related functions into one US100-specific workflow:

Fixed-point small-body candle detection
Combined upper- and lower-wick measurement
New York session filtering
Automatic projection of the full candle range
Midpoint visualization
Session timing markers

The purpose is not simply to identify standard Doji candles. The script converts qualifying US100 candles into time-limited intraday zones that can be monitored for later price interaction during the same session.

These components are designed to work together as one structured chart-analysis process.

Intended market and timeframe

This version is designed specifically for the US100 index.

Because it uses fixed index-point thresholds, it may not behave correctly on other instruments such as forex pairs, gold, cryptocurrencies or US500.

It is mainly intended for lower intraday timeframes such as:

1-minute
3-minute
5-minute

The exact number of detected zones may vary depending on the broker’s US100 price feed.

Customizable settings

Users can adjust:

Zone border color
Zone background color
Zone midpoint color

The body threshold, combined wick threshold and session times are fixed in the current version.

Limitations
The indicator does not predict future market direction.
It does not generate automatic entries or exits.
It does not include stop-loss or take-profit calculations.
Fixed point values may behave differently across brokers.
A candle that looks visually small may still fail the filter because its exact body or wick size is too large.
Session timing is based on GMT-4 and may not automatically adapt to daylight-saving changes.
Multiple qualifying candles may produce overlapping zones.
Historical reactions do not guarantee future results.
Disclaimer

This indicator is provided for educational and analytical purposes only. It is not financial advice and does not guarantee profitable results. Traders should test the indicator independently and use appropriate risk management before applying it to live trading.

## Source Code

````pine
//@version=6
indicator(
     "AVE Agent US100 Indicator",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500
)

// === DOJI ZONE COLOR SETTINGS ===
dojiZoneBorderColor = input.color(
     color.black,
     "Doji Zone Border Color"
)

dojiZoneBackgroundColor = input.color(
     color.new(color.gray, 60),
     "Doji Zone Background Color"
)

dojiZoneMidlineColor = input.color(
     color.gray,
     "Doji Zone Midline Color"
)

// === CALC ===
body = math.abs(close - open)

// Every candle body equal to or smaller than 0.5 points
noBody = body <= 0.7

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// US100 adjustment:
// Upper and lower wick may each be up to 15 points
totalWicks = upperWick + lowerWick
wickOK = totalWicks <= 25

isDoji = noBody and wickOK
validDoji = isDoji

// === SESSION (UTC-4) ===
startTime = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     9,
     30
)

endTime = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     11,
     0
)

extendTime = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     12,
     30
)

// === DOJI ZONE LOGIC ===
if time >= startTime and time <= endTime and validDoji
    float top = high
    float bottom = low
    float mid = (top + bottom) / 2

    int timeframeMilliseconds =
         timeframe.in_seconds(timeframe.period) * 1000

    int barsToExtend =
         math.max(
              0,
              int((extendTime - time) / timeframeMilliseconds)
         )

    int rightIndex = bar_index + barsToExtend

    box.new(
         left = bar_index,
         top = top,
         right = rightIndex,
         bottom = bottom,
         xloc = xloc.bar_index,
         border_color = dojiZoneBorderColor,
         bgcolor = dojiZoneBackgroundColor
    )

    line.new(
         x1 = bar_index,
         y1 = mid,
         x2 = rightIndex,
         y2 = mid,
         xloc = xloc.bar_index,
         color = dojiZoneMidlineColor,
         style = line.style_dashed
    )

// ======================================================
// SESSION VISUAL
// ======================================================

sessionStart = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     9,
     30
)

sessionEnd = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     12,
     30
)

blueStart = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     11,
     0
)

blueEnd = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     11,
     1
)

redStart = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     12,
     30
)

redEnd = timestamp(
     "GMT-4",
     year,
     month,
     dayofmonth,
     12,
     31
)

// Outside-session background
bgcolor(
     time < sessionStart or time >= sessionEnd
         ? color.new(color.black, 70)
         : na,
     title = "Outside Session Background Color"
)

// 11:00 AM marker
bgcolor(
     time >= blueStart and time < blueEnd
         ? color.new(color.blue, 40)
         : na,
     title = "11:00 AM Marker Color"
)

// 12:30 PM marker
bgcolor(
     time >= redStart and time < redEnd
         ? color.new(color.red, 70)
         : na,
     title = "12:30 Marker Color"
)
````
