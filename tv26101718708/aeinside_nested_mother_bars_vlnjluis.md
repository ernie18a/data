# AE_Inside Nested Mother Bars

- url: https://www.tradingview.com/script/vlnJLUis-AE-Inside-Nested-Mother-Bars/
- type: indicator
- pine_id: PUB;01d4ef64b36641a3960e91345e045428
- version: 1.0

## Description

AE_Inside Nested Mother Bars

AE_Inside Nested Mother Bars is a price-action tool designed to automatically detect and map Mother Bar / Inside Bar structures, including nested inside ranges.

The idea is simple:
When price compresses inside a previous candle's body, mark the range and let price decide how it resolves.

What it does
The indicator:
- Detects candles whose body remains inside the previous candle's body
- Requires a configurable minimum number of inside candles before confirming a Mother Bar range
- Automatically draws the confirmed range as a shaded zone
- Supports nested Mother Bars, allowing new structures to form while another range is still active
- Extends the active range until a confirmed candle close breaks above or below it
- Preserves completed ranges historically
- Optionally displays breakout markers
- Limits historical zones to keep the chart manageable

Important detail
The calculation is based on the candle body, not simply the wick high/low.
This means the indicator is looking for genuine body compression inside the Mother Bar rather than treating every overlapping candle as an Inside Bar.

How I use it
I don't treat every Mother Bar as a trade signal.
The zone is primarily a map of compression.
Once price breaks the range, the more interesting question becomes:
What does price do after the break?
Does it continue?
Does it retest the range?
Does it fail and return inside?
Does another nested structure form?
The Mother Bar gives the location. Price action provides the information about the resolution.

Companion indicator
The example chart may also show AE_MTaskRSI as a separate companion indicator.
AE_MTaskRSI is not part of AE_Inside Nested Mother Bars. It is shown separately to demonstrate how price compression can be viewed alongside RSI structure.

Settings
- Minimum Inside Candles — minimum number of qualifying inside candles required to confirm a range.
- Maximum Stored Zones — controls how many completed historical ranges are retained.
- Range Color — controls the zone color.
- Shade Transparency — controls zone transparency.
- Show Breakouts — enables/disables breakout markers.

Notes
This indicator is intended as a visual price-action and market-structure tool, not as a standalone buy/sell signal.
The breakout markers simply identify confirmed closes outside an active Mother Bar range. They do not predict direction or guarantee continuation.
© A3rl

Disclaimer
This indicator is provided for educational and informational purposes only and does not constitute investment, trading, or financial advice.
The levels, zones, and breakout markers are visual reference tools and are not guaranteed support, resistance, entry, exit, or target levels. Past market behavior does not guarantee future results.
Trading leveraged financial markets involves substantial risk. Always apply appropriate risk management and make your own trading decisions. You are solely responsible for your trading and investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © A3rl


//@version=6
indicator("AE_Inside Nested Mother Bars", "AE_Inside Nested Bars",
     overlay=true, max_boxes_count=500)

// SETTINGS
minInside = input.int(2, "Minimum Inside Candles", minval=2)
maxZones = input.int(80, "Maximum Stored Zones", minval=1, maxval=400)
zoneColor = input.color(color.gray, "Range Color")
zoneTransparency = input.int(85, "Shade Transparency", minval=0, maxval=100)
showBreakouts = input.bool(true, "Show Breakouts")

// BODY VALUES
bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

prevHigh = math.max(open[1], close[1])
prevLow  = math.min(open[1], close[1])

// CANDIDATE MOTHERS
var array<float> candHigh = array.new_float()
var array<float> candLow = array.new_float()
var array<int> candStart = array.new_int()
var array<int> candCount = array.new_int()

// CONFIRMED MOTHERS
var array<float> zoneHigh = array.new_float()
var array<float> zoneLow = array.new_float()
var array<box> zoneBoxes = array.new<box>()
var array<box> historyBoxes = array.new<box>()

bool breakoutUp = false
bool breakoutDn = false
bool confirmedBar = false

if barstate.isconfirmed

    // 1. UPDATE EXISTING CONFIRMED RANGES
    if array.size(zoneHigh) > 0
        for i = array.size(zoneHigh) - 1 to 0
            hi = array.get(zoneHigh, i)
            lo = array.get(zoneLow, i)
            bx = array.get(zoneBoxes, i)

            // CLOSE BREAKOUT
            up = close > hi
            dn = close < lo

            if up or dn
                breakoutUp := breakoutUp or up
                breakoutDn := breakoutDn or dn

                // Preserve completed historical range
                box.set_right(bx, bar_index - 1)
                array.push(historyBoxes, bx)

                array.remove(zoneHigh, i)
                array.remove(zoneLow, i)
                array.remove(zoneBoxes, i)
            else
                box.set_right(bx, bar_index)

    // 2. UPDATE CANDIDATE MOTHERS
    if array.size(candHigh) > 0
        for i = array.size(candHigh) - 1 to 0
            hi = array.get(candHigh, i)
            lo = array.get(candLow, i)
            start = array.get(candStart, i)
            count = array.get(candCount, i)

            // BODY MUST REMAIN INSIDE ORIGINAL MOTHER
            inside = bodyHigh <= hi and bodyLow >= lo

            if inside
                count += 1

                if count >= minInside
                    // Candidate becomes confirmed.
                    // Prevent duplicate identical ranges.
                    bool duplicate = false

                    if array.size(zoneHigh) > 0
                        for j = 0 to array.size(zoneHigh) - 1
                            if array.get(zoneHigh, j) == hi and array.get(zoneLow, j) == lo
                                duplicate := true

                    if not duplicate
                        bx = box.new(
                             left=start,
                             top=hi,
                             right=bar_index,
                             bottom=lo,
                             bgcolor=color.new(zoneColor, zoneTransparency),
                             border_color=color.new(zoneColor, 70))

                        array.push(zoneHigh, hi)
                        array.push(zoneLow, lo)
                        array.push(zoneBoxes, bx)

                        confirmedBar := true

                    array.remove(candHigh, i)
                    array.remove(candLow, i)
                    array.remove(candStart, i)
                    array.remove(candCount, i)
                else
                    array.set(candCount, i, count)

            else
                // Candidate failed before confirmation
                array.remove(candHigh, i)
                array.remove(candLow, i)
                array.remove(candStart, i)
                array.remove(candCount, i)

    // 3. START NEW MOTHER CANDIDATE
    // This runs even when another range is active.
    // It allows nested Mother Bars.
    firstInside = bodyHigh <= prevHigh and bodyLow >= prevLow

    if firstInside
        bool duplicate = false

        if array.size(candHigh) > 0
            for i = 0 to array.size(candHigh) - 1
                if array.get(candHigh, i) == prevHigh and array.get(candLow, i) == prevLow
                    duplicate := true

        if array.size(zoneHigh) > 0
            for i = 0 to array.size(zoneHigh) - 1
                if array.get(zoneHigh, i) == prevHigh and array.get(zoneLow, i) == prevLow
                    duplicate := true

        if not duplicate
            array.push(candHigh, prevHigh)
            array.push(candLow, prevLow)
            array.push(candStart, bar_index - 1)
            array.push(candCount, 1)

    // 4. LIMIT HISTORICAL DRAWINGS
    while array.size(historyBoxes) > maxZones
        oldBox = array.shift(historyBoxes)
        box.delete(oldBox)

// BREAKOUT MARKERS
plotshape(showBreakouts and breakoutUp,
     title="Breakout Up",
     style=shape.triangleup,
     location=location.abovebar,
     color=color.green,
     size=size.tiny)

plotshape(showBreakouts and breakoutDn,
     title="Breakout Down",
     style=shape.triangledown,
     location=location.belowbar,
     color=color.red,
     size=size.tiny)
````
