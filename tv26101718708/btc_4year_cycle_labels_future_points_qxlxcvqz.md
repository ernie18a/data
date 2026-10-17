# BTC 4-Year Cycle Labels + Future Points

- url: https://www.tradingview.com/script/qXlxcVqZ-BTC-4-Year-Cycle-Labels-Future-Points/
- type: indicator
- pine_id: PUB;95c588a2a7af4ddb97e57f960d41496b
- version: 2.0

## Description

**BTC 4-Year Cycle Labels + Future Points**

This script is a simple visual roadmap for Bitcoin’s historical 4-year rhythm. It marks the major cycle tops and cycle lows that have defined Bitcoin’s previous macro cycles, then projects the next theoretical cycle points forward using the same measured cycle spacing.

The idea behind this tool is not to claim that Bitcoin must repeat the past perfectly. Markets evolve. Liquidity changes. Participants become more sophisticated. The ETF era, institutional flows, macro policy, and global adoption can all distort or even break patterns that once looked obvious.

But that is exactly why this indicator exists.

Bitcoin has spent more than a decade moving through recognizable expansion and contraction phases. Each cycle has had a major euphoric top, followed by a long bear-market drawdown and eventual accumulation low. This script takes those historical turning points and places them directly on the chart so the structure can be seen clearly.

The historical cycle labels included are:

**Cycle Tops**

* 25 Nov 2013
* 11 Dec 2017
* 08 Nov 2021
* Projected: 06 Oct 2025

**Cycle Lows**

* 12 Jan 2015
* 10 Dec 2018
* 07 Nov 2022
* Projected: 05 Oct 2026

The projected dates are based on the recurring spacing from prior Bitcoin cycle pivots. In this version, the projection uses a default 1428-day cycle spacing, which carries the 2021 top forward into the projected 2025 top, and the 2022 low forward into the projected 2026 low.

The script also includes background cycle zones. The red-shaded regions represent the historical top-to-low bear-market windows, while the green-shaded regions represent the broader expansion and recovery phases between cycle lows and tops.

This makes it easier to visually compare where Bitcoin is now relative to prior cycle structure.

The purpose of this script is to answer one question:

**Is Bitcoin still following the old cycle, or is the cycle finally breaking?**

If the projected window continues to hold, then Bitcoin may still be moving inside a recognizable 4-year structure. If price behavior begins to diverge meaningfully from the historical rhythm, that may be evidence that the market is entering a new regime.

This script is best used on higher timeframes, especially weekly and monthly Bitcoin charts. It is not designed for short-term trading signals. It does not generate buy or sell alerts. It does not predict a specific price target. The future labels only mark projected time windows, not guaranteed outcomes.

Useful ways to use this indicator:

* Compare the current Bitcoin cycle against prior macro cycles.
* Study the timing between historical tops and lows.
* Observe whether Bitcoin is compressing, extending, or breaking its 4-year rhythm.
* Use the projected future labels as time-based reference points.
* Combine with macro liquidity, on-chain data, sentiment, trend structure, and risk models.

Important note:
The projected cycle top and cycle low should be treated as a time-map, not a prophecy. The market does not owe anyone a repeat. Patterns become fragile when everyone sees them. The value of the script is not that it guarantees the future, but that it gives traders and investors a clean framework for watching whether the old cycle continues to matter.

Bitcoin has always forced the market to question what it thinks it knows.

Maybe the 4-year cycle continues.

Maybe it shifts.

Maybe it breaks completely.

Where we go from here is a choice the market leaves to us.

## Source Code

````pine
//@version=6
indicator("BTC 4-Year Cycle Labels + Future Points", overlay = true, max_labels_count = 50, max_lines_count = 20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showZones       = input.bool(true, "Show bull/bear background zones")
showLabels      = input.bool(true, "Show cycle labels")
showProjections = input.bool(true, "Show future projected points")

cycleDays = input.int(1428, "Projection spacing in days", minval = 1)

topLabelColor = input.color(color.rgb(242, 54, 69), "Top label color")
lowLabelColor = input.color(color.rgb(41, 98, 255), "Low label color")

bullBgColor = input.color(color.rgb(213, 235, 216), "Bull zone background")
bearBgColor = input.color(color.rgb(255, 210, 214), "Bear zone background")

bullTransp = input.int(78, "Bull zone transparency", minval = 0, maxval = 100)
bearTransp = input.int(78, "Bear zone transparency", minval = 0, maxval = 100)

topYMult = input.float(1.10, "Historical top label height multiplier", step = 0.01)
lowYMult = input.float(0.90, "Historical low label height multiplier", step = 0.01)

futureTopYMult = input.float(1.25, "Future top label Y multiplier", step = 0.01)
futureLowYMult = input.float(0.70, "Future low label Y multiplier", step = 0.01)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Date helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int MS_DAY = 24 * 60 * 60 * 1000

f_ts(int y, int m, int d) =>
    timestamp("Etc/UTC", y, m, d, 0, 0)

f_dateText(int ts) =>
    str.format_time(ts, "dd MMM yyyy", "Etc/UTC")

f_cycleText(string title, int ts) =>
    title + "\n" + f_dateText(ts)

f_inBar(int ts) =>
    not na(time_close) and time <= ts and time_close > ts

f_barOverlaps(int startTs, int endTs) =>
    not na(time_close) and time < endTs and time_close > startTs

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical cycle dates
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tTop2013 = f_ts(2013, 11, 25)
tLow2015 = f_ts(2015, 1, 12)

tTop2017 = f_ts(2017, 12, 11)
tLow2018 = f_ts(2018, 12, 10)

tTop2021 = f_ts(2021, 11, 8)
tLow2022 = f_ts(2022, 11, 7)

// Projected dates using 1428-day spacing
tTop2025 = tTop2021 + cycleDays * MS_DAY
tLow2026 = tLow2022 + cycleDays * MS_DAY

tTop2029 = tTop2025 + cycleDays * MS_DAY
tLow2030 = tLow2026 + cycleDays * MS_DAY

// Extend the final projected green area farther right
tFutureZoneEnd = tLow2030 + cycleDays * MS_DAY * 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical background zones
// Red = top-to-low bear window
// Green = everything else
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inBearZone =
     f_barOverlaps(tTop2013, tLow2015) or
     f_barOverlaps(tTop2017, tLow2018) or
     f_barOverlaps(tTop2021, tLow2022) or
     f_barOverlaps(tTop2025, tLow2026) or
     f_barOverlaps(tTop2029, tLow2030)

bgcolor(
     showZones
         ? inBearZone
             ? color.new(bearBgColor, bearTransp)
             : color.new(bullBgColor, bullTransp)
         : na
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Label helper
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_makeLabel(int ts, float y, string txt, bool isTop) =>
    label.new(
         x = ts,
         y = y,
         text = txt,
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = isTop ? label.style_label_down : label.style_label_up,
         color = isTop ? topLabelColor : lowLabelColor,
         textcolor = color.white,
         size = size.small
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showLabels and f_inBar(tTop2013)
    f_makeLabel(
         tTop2013,
         high * topYMult,
         f_cycleText("CYCLE TOP", tTop2013),
         true
     )

if showLabels and f_inBar(tLow2015)
    f_makeLabel(
         tLow2015,
         low * lowYMult,
         f_cycleText("CYCLE LOW", tLow2015),
         false
     )

if showLabels and f_inBar(tTop2017)
    f_makeLabel(
         tTop2017,
         high * topYMult,
         f_cycleText("CYCLE TOP", tTop2017),
         true
     )

if showLabels and f_inBar(tLow2018)
    f_makeLabel(
         tLow2018,
         low * lowYMult,
         f_cycleText("CYCLE LOW", tLow2018),
         false
     )

if showLabels and f_inBar(tTop2021)
    f_makeLabel(
         tTop2021,
         high * topYMult,
         f_cycleText("CYCLE TOP", tTop2021),
         true
     )

if showLabels and f_inBar(tLow2022)
    f_makeLabel(
         tLow2022,
         low * lowYMult,
         f_cycleText("CYCLE LOW", tLow2022),
         false
     )

// Projected dates become normal labels once price data reaches them
if showLabels and f_inBar(tTop2025)
    f_makeLabel(
         tTop2025,
         high * topYMult,
         f_cycleText("CYCLE TOP", tTop2025),
         true
     )

if showLabels and f_inBar(tLow2026)
    f_makeLabel(
         tLow2026,
         low * lowYMult,
         f_cycleText("CYCLE LOW", tLow2026),
         false
     )

if showLabels and f_inBar(tTop2029)
    f_makeLabel(
         tTop2029,
         high * topYMult,
         f_cycleText("CYCLE TOP", tTop2029),
         true
     )

if showLabels and f_inBar(tLow2030)
    f_makeLabel(
         tLow2030,
         low * lowYMult,
         f_cycleText("CYCLE LOW", tLow2030),
         false
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future projection label helper
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_updateProjectionLabel(
     label id,
     int ts,
     float y,
     string txt,
     bool isTop
 ) =>
    label out = id

    if na(out)
        out := f_makeLabel(ts, y, txt, isTop)
    else
        label.set_x(out, ts)
        label.set_y(out, y)
        label.set_text(out, txt)
        label.set_style(
             out,
             isTop ? label.style_label_down : label.style_label_up
         )
        label.set_color(
             out,
             isTop ? topLabelColor : lowLabelColor
         )
        label.set_textcolor(out, color.white)
        label.set_size(out, size.small)

    out

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future projection line helper
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_updateProjectionLine(line id, int ts, color c) =>
    line out = id

    y1 = close * 0.10
    y2 = close * 10.00

    if na(out)
        out := line.new(
             x1 = ts,
             y1 = y1,
             x2 = ts,
             y2 = y2,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = color.new(c, 35),
             style = line.style_dashed,
             width = 1
         )
    else
        line.set_x1(out, ts)
        line.set_y1(out, y1)
        line.set_x2(out, ts)
        line.set_y2(out, y2)
        line.set_color(out, color.new(c, 35))
        line.set_style(out, line.style_dashed)
        line.set_width(out, 1)

    out

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future background box helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_updateProjectionBox(
     box id,
     int leftTs,
     int rightTs,
     color bg,
     int transp
 ) =>
    box out = id

    topY = close * 1000.0
    bottomY = close * 0.001

    if na(out)
        out := box.new(
             left = leftTs,
             top = topY,
             right = rightTs,
             bottom = bottomY,
             xloc = xloc.bar_time,
             border_color = na,
             bgcolor = color.new(bg, transp)
         )
    else
        box.set_left(out, leftTs)
        box.set_right(out, rightTs)
        box.set_top(out, topY)
        box.set_bottom(out, bottomY)
        box.set_border_color(out, na)
        box.set_bgcolor(out, color.new(bg, transp))

    out

f_deleteProjectionBox(box id) =>
    box out = id

    if not na(out)
        box.delete(out)
        out := na

    out

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future projection objects
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label futureTopLabel = na
var label futureLowLabel = na

var line futureTopLine = na
var line futureLowLine = na

var label nextFutureTopLabel = na
var label nextFutureLowLabel = na

var line nextFutureTopLine = na
var line nextFutureLowLine = na

// Future background areas
var box futureBullBoxBeforeTop = na
var box futureBearBox2025 = na
var box futureBullBox2026 = na
var box futureBearBox2029 = na
var box futureBullBox2030 = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future background zones
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    if showZones and not na(time_close)
        futureStart = time_close

        // Green from the latest candle to the 2025 top,
        // only when the 2025 top is still ahead.
        if futureStart < tTop2025
            futureBullBoxBeforeTop := f_updateProjectionBox(
                 futureBullBoxBeforeTop,
                 futureStart,
                 tTop2025,
                 bullBgColor,
                 bullTransp
             )
        else
            futureBullBoxBeforeTop := f_deleteProjectionBox(
                 futureBullBoxBeforeTop
             )

        // Red from the 2025 top to the 2026 low.
        bear2025Left =
             futureStart > tTop2025
                 ? futureStart
                 : tTop2025

        if bear2025Left < tLow2026
            futureBearBox2025 := f_updateProjectionBox(
                 futureBearBox2025,
                 bear2025Left,
                 tLow2026,
                 bearBgColor,
                 bearTransp
             )
        else
            futureBearBox2025 := f_deleteProjectionBox(
                 futureBearBox2025
             )

        // Green from the 2026 low to the 2029 top.
        bull2026Left =
             futureStart > tLow2026
                 ? futureStart
                 : tLow2026

        if bull2026Left < tTop2029
            futureBullBox2026 := f_updateProjectionBox(
                 futureBullBox2026,
                 bull2026Left,
                 tTop2029,
                 bullBgColor,
                 bullTransp
             )
        else
            futureBullBox2026 := f_deleteProjectionBox(
                 futureBullBox2026
             )

        // Red from the 2029 top to the 2030 low.
        bear2029Left =
             futureStart > tTop2029
                 ? futureStart
                 : tTop2029

        if bear2029Left < tLow2030
            futureBearBox2029 := f_updateProjectionBox(
                 futureBearBox2029,
                 bear2029Left,
                 tLow2030,
                 bearBgColor,
                 bearTransp
             )
        else
            futureBearBox2029 := f_deleteProjectionBox(
                 futureBearBox2029
             )

        // Green after the 2030 low.
        bull2030Left =
             futureStart > tLow2030
                 ? futureStart
                 : tLow2030

        if bull2030Left < tFutureZoneEnd
            futureBullBox2030 := f_updateProjectionBox(
                 futureBullBox2030,
                 bull2030Left,
                 tFutureZoneEnd,
                 bullBgColor,
                 bullTransp
             )
        else
            futureBullBox2030 := f_deleteProjectionBox(
                 futureBullBox2030
             )
    else
        futureBullBoxBeforeTop := f_deleteProjectionBox(
             futureBullBoxBeforeTop
         )

        futureBearBox2025 := f_deleteProjectionBox(
             futureBearBox2025
         )

        futureBullBox2026 := f_deleteProjectionBox(
             futureBullBox2026
         )

        futureBearBox2029 := f_deleteProjectionBox(
             futureBearBox2029
         )

        futureBullBox2030 := f_deleteProjectionBox(
             futureBullBox2030
         )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Future projection labels + dashed vertical lines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast and showProjections
    topStillFuture =
         not na(time_close) and
         time_close <= tTop2025

    lowStillFuture =
         not na(time_close) and
         time_close <= tLow2026

    nextTopStillFuture =
         not na(time_close) and
         time_close <= tTop2029

    nextLowStillFuture =
         not na(time_close) and
         time_close <= tLow2030

    if topStillFuture
        futureTopLabel := f_updateProjectionLabel(
             futureTopLabel,
             tTop2025,
             close * futureTopYMult,
             f_cycleText("CYCLE TOP", tTop2025),
             true
         )

        futureTopLine := f_updateProjectionLine(
             futureTopLine,
             tTop2025,
             topLabelColor
         )

    if lowStillFuture
        futureLowLabel := f_updateProjectionLabel(
             futureLowLabel,
             tLow2026,
             close * futureLowYMult,
             f_cycleText("CYCLE LOW", tLow2026),
             false
         )

        futureLowLine := f_updateProjectionLine(
             futureLowLine,
             tLow2026,
             lowLabelColor
         )

    if nextTopStillFuture
        nextFutureTopLabel := f_updateProjectionLabel(
             nextFutureTopLabel,
             tTop2029,
             close * futureTopYMult,
             f_cycleText("CYCLE TOP", tTop2029),
             true
         )

        nextFutureTopLine := f_updateProjectionLine(
             nextFutureTopLine,
             tTop2029,
             topLabelColor
         )

    if nextLowStillFuture
        nextFutureLowLabel := f_updateProjectionLabel(
             nextFutureLowLabel,
             tLow2030,
             close * futureLowYMult,
             f_cycleText("CYCLE LOW", tLow2030),
             false
         )

        nextFutureLowLine := f_updateProjectionLine(
             nextFutureLowLine,
             tLow2030,
             lowLabelColor
         )
````
