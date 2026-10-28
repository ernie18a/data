# Auto Anchored VP - True TPO Logic

- url: https://www.tradingview.com/script/2trJlI1x-Auto-Anchored-VP-True-TPO-Logic/
- type: indicator
- pine_id: PUB;50926c7a13704e9498f18c417923812b
- version: 3.0

## Description

[b]Auto Anchored VP — True TPO Logic[/b]

This indicator is an open-source attempt to replicate TradingView's native Anchored Volume Profile as closely as possible within the constraints of Pine Script. It is published for educational purposes — both as a useful tool and as a reference for understanding why accurate volume profile calculation is difficult to achieve in Pine Script.

[b]The Problem — Why Pine Script Cannot Build a True AVP[/b]

TradingView's native Anchored Volume Profile is calculated on the backend in Java, with access to tick-by-tick trade data. Every individual transaction is placed at its exact price, producing a true tick-level volume distribution. This is the gold standard — the most accurate possible representation of where volume actually traded.

Pine Script does not have access to tick data. It only sees OHLCV bars — one open, high, low, close, and volume value per candle. There is no way to know, within Pine Script, how much of a bar's volume traded at 76,200 versus 76,800. This is a hard platform limitation, not a solvable coding problem.

As a result, every Pine Script volume profile implementation is an approximation. The question is not whether it is perfect — it cannot be — but how close it can get.

[b]The Approach — Even TPO Distribution[/b]

This indicator takes the most statistically neutral approach available in Pine Script: each bar's volume is distributed evenly across every price bin it spans based on its high-low range.

If a bar trades from 75,000 to 77,000 and covers 10 bins, each bin receives one tenth of that bar's volume. This makes no assumptions about where within the bar the volume concentrated — it treats every price the bar visited as equally likely. Across hundreds of bars, this averaging effect produces a profile that closely approximates the true tick-level distribution.

The chart above shows both profiles side by side. The levels are close but not identical — the difference is the gap between tick-level precision and bar-level approximation. For most practical trading purposes the levels are functionally equivalent.

[b]The Dual-Bin Value Area Algorithm[/b]

The Value Area expansion uses the standard dual-bin comparison — at each step, the combined volume of the next 2 bins above is compared against the next 2 bins below, and the Value Area expands toward whichever side has more volume. This matches the original Steidlmayer methodology used in professional TPO profiles and is the same logic TradingView's backend applies.

[b]How to Read the Levels[/b]
[list]
[*][b]POC — Point of Control[/b]
The price bin with the highest volume for the previous week. The market's fairest price. Price gravitates back toward it when it deviates.
[*][b]VAH — Value Area High[/b]
The upper boundary of the 70% volume zone. Acts as support when price is above it, resistance when price breaks below and retests from underneath.
[*][b]VAL — Value Area Low[/b]
The lower boundary of the 70% volume zone. Acts as resistance on rallies from below, support when price holds above it.
[/list]

[b]Why Previous Week[/b]

The anchor covers the complete prior weekly range — a fully closed, committed profile. The current week's profile is incomplete until Friday close. Reacting to a closed profile means every level has been fully tested and accepted by the market.

[b]Settings[/b]
[list]
[*][b]Number of Rows[/b] — bin resolution. 200 is the recommended default balancing precision and performance.
[*][b]Value Area %[/b] — standard is 70%.
[*][b]Colors[/b] — fully customizable.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Auto Anchored Volume Profile", shorttitle="AVP", overlay=true,
          max_lines_count=100, max_labels_count=100)

// ══════════════════════════════════════════════════════════════════════════
// WHAT IS THE AUTO ANCHORED VOLUME PROFILE?
//
// A Volume Profile shows WHERE volume traded across price, instead of over
// time. This script auto-anchors to the most recently completed week and
// builds a TPO-style profile from every bar in that range.
//
// THREE LEVELS ARE DRAWN:
//   POC (Point of Control) - the single price with the most traded volume,
//        the "fairest" price the market agreed on that week.
//   VAH / VAL (Value Area High / Low) - the band that contains the chosen
//        percentage (default 70%) of all traded volume. Price tends to
//        rotate inside this band and react at its edges.
//
// HOW IT WORKS:
//   The week's high-low range is divided into bins. Each bar's volume is
//   spread evenly across the bins its range covers. The fullest bin is the
//   POC; the value area then grows outward from the POC, two bins at a time,
//   until it captures the target volume percentage.
//
// RECOMMENDED TIMEFRAME: 15m - 4H
// ═══════════════════════════════════════════════════════════════════════════

// ── Inputs ───────────────────────────────────────────────────────────────────
var g = "Auto Anchored VP Settings"

rowsCount  = input.int  (200,  "Number of Rows",          minval=10, maxval=1000, group=g)
vaPercent  = input.float(70.0, "Value Area Volume %",     minval=0.0, maxval=100.0, group=g)
extend_fwd = input.int  (30,   "Extend Lines Forward (hours)", minval=1, maxval=500, group=g)
show_label = input.bool (true, "Show Labels",             group=g)

var g_s = "Style"
pocColor  = input.color(color.new(#e2e676, 0), "POC Color",        group=g_s)
lineColor = input.color(color.new(#7e57c2, 0), "VAH / VAL Color",  group=g_s)
pocStyleI = input.string("Solid",  "POC Line Style",     options=["Solid", "Dashed", "Dotted"], group=g_s)
vaStyleI  = input.string("Dashed", "VAH / VAL Line Style", options=["Solid", "Dashed", "Dotted"], group=g_s)

f_style(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

hour_ms = 1000 * 60 * 60

// ── Timeframe guard ───────────────────────────────────────────────────────────
is_valid = timeframe.isintraday or timeframe.isdaily

if barstate.islast and not is_valid
    label.new(bar_index, high,
              "⚠️  Auto Anchored VP works best on intraday - daily timeframes.",
              xloc=xloc.bar_index, color=color.red, textcolor=color.white,
              style=label.style_label_left, size=size.normal)

// ── Week boundary ──────────────────────────────────────────────────────────────
isNewWeek = ta.change(time("W")) != 0

var int currentWeekStartBar   = na
var int previousWeekStartBar  = na
var int currentWeekStartTime  = na
var int previousWeekStartTime = na

if isNewWeek
    previousWeekStartBar  := currentWeekStartBar
    currentWeekStartBar   := bar_index
    previousWeekStartTime := currentWeekStartTime
    currentWeekStartTime  := time

// ── Profile build (on the last bar, for the most recent completed week) ────────
if is_valid and barstate.islast and not na(previousWeekStartBar)
    lookback = bar_index - previousWeekStartBar

    if lookback > 0 and lookback < 10000

        highestPrice = high
        lowestPrice  = low
        for i = 0 to lookback
            highestPrice := math.max(highestPrice, high[i])
            lowestPrice  := math.min(lowestPrice, low[i])

        priceRange = highestPrice - lowestPrice
        binSize    = priceRange / rowsCount

        array<float> volBins = array.new<float>(rowsCount, 0.0)
        totalVolume = 0.0

        // Distribute volume evenly across the High-Low range of each bar
        for i = 0 to lookback
            barLowBin  = math.floor((low[i]  - lowestPrice) / binSize)
            barHighBin = math.floor((high[i] - lowestPrice) / binSize)

            barLowBin  := math.max(0, math.min(rowsCount - 1, barLowBin))
            barHighBin := math.max(0, math.min(rowsCount - 1, barHighBin))

            binsSpanned = barHighBin - barLowBin + 1
            volPerBin   = volume[i] / binsSpanned

            for b = barLowBin to barHighBin
                volBins.set(b, volBins.get(b) + volPerBin)
                totalVolume += volPerBin

        // Find POC
        maxVol   = 0.0
        pocIndex = 0
        for i = 0 to rowsCount - 1
            if volBins.get(i) > maxVol
                maxVol   := volBins.get(i)
                pocIndex := i

        // STANDARD DUAL-BIN VALUE AREA ALGORITHM (2-by-2 comparison)
        vaVolumeTarget  = totalVolume * (vaPercent / 100.0)
        currentVaVolume = volBins.get(pocIndex)

        upperIndex = pocIndex
        lowerIndex = pocIndex

        while currentVaVolume < vaVolumeTarget and (upperIndex < rowsCount - 1 or lowerIndex > 0)
            volUp = 0.0
            if upperIndex + 1 < rowsCount
                volUp += volBins.get(upperIndex + 1)
            if upperIndex + 2 < rowsCount
                volUp += volBins.get(upperIndex + 2)

            volDown = 0.0
            if lowerIndex - 1 >= 0
                volDown += volBins.get(lowerIndex - 1)
            if lowerIndex - 2 >= 0
                volDown += volBins.get(lowerIndex - 2)

            if volUp == 0.0 and volDown == 0.0
                break

            if volUp >= volDown
                if upperIndex + 1 < rowsCount
                    upperIndex += 1
                    currentVaVolume += volBins.get(upperIndex)
                if currentVaVolume < vaVolumeTarget and upperIndex + 1 < rowsCount
                    upperIndex += 1
                    currentVaVolume += volBins.get(upperIndex)
            else
                if lowerIndex - 1 >= 0
                    lowerIndex -= 1
                    currentVaVolume += volBins.get(lowerIndex)
                if currentVaVolume < vaVolumeTarget and lowerIndex - 1 >= 0
                    lowerIndex -= 1
                    currentVaVolume += volBins.get(lowerIndex)

        vahPrice = lowestPrice + (upperIndex * binSize) + (binSize / 2)
        valPrice = lowestPrice + (lowerIndex * binSize) + (binSize / 2)
        pocPrice = lowestPrice + (pocIndex  * binSize) + (binSize / 2)

        int ext_t = time + extend_fwd * hour_ms

        // Lines project to the right by time, the same way the nPOC indicator does,
        // so both indicators' levels line up at the same right-side region.
        line.new(x1=previousWeekStartTime, y1=pocPrice, x2=ext_t, y2=pocPrice, xloc=xloc.bar_time, color=pocColor,  width=2, style=f_style(pocStyleI))
        line.new(x1=previousWeekStartTime, y1=vahPrice, x2=ext_t, y2=vahPrice, xloc=xloc.bar_time, color=lineColor, width=1, style=f_style(vaStyleI))
        line.new(x1=previousWeekStartTime, y1=valPrice, x2=ext_t, y2=valPrice, xloc=xloc.bar_time, color=lineColor, width=1, style=f_style(vaStyleI))

        // Labels float at the right line end, matching nPOC
        if show_label
            label.new(x=ext_t, y=vahPrice, text="VAH", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lineColor, style=label.style_label_left, size=size.small)
            label.new(x=ext_t, y=pocPrice, text="POC", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=pocColor,  style=label.style_label_left, size=size.small)
            label.new(x=ext_t, y=valPrice, text="VAL", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lineColor, style=label.style_label_left, size=size.small)
````
