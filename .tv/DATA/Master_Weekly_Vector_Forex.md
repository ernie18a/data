<!-- tradingview-pine-id: PUB;ea4f8b7490564a6280db64ca6493315d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Master Weekly Vector Forex

Source: https://www.tradingview.com/script/v4lfPK1D-Master-Weekly-Vector-Forex/

## Description

Weekly Vector Forex indicator is essentially a combined volume/vector + mitigation + gap + multi-timeframe trend + weekly POC framework. It is designed to answer several different questions on one chart: where unusually strong volume appeared, whether price has returned to those areas, where gaps remain open, where weekly volume concentrated, and how far current price sits above or below important moving averages.

Here is what each part is doing.

1. Vector candles

The foundation is the Traders Reality/PVSRA vector-candle calculation from the imported library.

The candles are separated into four vector types:

Green — major bullish vector
Red — major bearish vector
Blue — secondary bullish vector
Violet — secondary bearish vector

Normal candles remain grey/dark grey.

The point of a vector candle is not simply that price moved strongly. The PVSRA calculation uses volume and candle spread to identify unusually active candles. So you're effectively highlighting areas where activity was substantially different from the surrounding market.

You also have the option to recolor the actual chart candles using those vector colors.

2. Vector shadows / unmitigated vectors

This is one of the main features we built.

When a vector appears, the indicator creates a horizontal zone extending to the right.

So instead of losing sight of an important vector after another 50 or 100 candles appear, its price area remains visible.

Conceptually:

VECTOR
██████────────────────────────────────────────→

             price has not returned here
             = UNMITIGATED VECTOR

You can define the zone using either:

Body only

or

Body + wick

That gives you control over how strict you want the vector recovery calculation to be.

3. Unmitigated, partially recovered and fully recovered

The indicator tracks the lifecycle of each vector.

An untouched vector remains an unmitigated vector.

If price starts entering the vector area, it becomes partially recovered.

For example:

Vector originally:

████████████████████ 100%

Price returns:

████████░░░░░░░░░░░░

40% recovered
60% left

The indicator can therefore display:

40% REC
60% LEFT

This is useful because there is a large difference between a completely untouched vector and one that has already been 95% mitigated.

4. The shadow actually shrinks

The recovery isn't merely a label.

As price penetrates the vector, the remaining box is adjusted to represent the unrecovered portion.

That means visually you're concentrating on the part of the vector that price has not yet revisited.

Once it reaches 100%, it is considered completely recovered.

5. Fully recovered vectors become green

Once the vector reaches 100% recovery, it stops extending indefinitely.

The completed zone is retained as a historical recovered area and displayed in:

Green with 70% transparency.

You can control how many recently recovered zones remain visible.

For example:

RED/BLUE/VIOLET/GREEN SHADOW → outstanding vector

ORANGE → partially recovered

GREEN 70% transparent → completely recovered

This makes it much easier to distinguish old completed business from outstanding areas.

6. Gap detection

We also kept your gap system.

The indicator searches for price gaps and extends those areas horizontally.

You have separate bullish and bearish gap colors.

The gap remains visible until price fills it.

So you effectively have two different kinds of outstanding areas:

VECTOR ZONES
Volume-driven areas

GAP ZONES
Price discontinuities

They are related concepts but they are deliberately tracked separately.

7. Multi-timeframe SMA dashboard

The table in the upper-right is your broader market-location dashboard.

You currently have:

        1H  4H  8H  1D  3D  1W  1M  6M  1Y  2Y  3Y  5Y
SMA 30
SMA 50
SMA 200

For each timeframe, the script calculates how far current price is from that SMA.

TradingView's request.security() evaluates the SMA inside the requested timeframe rather than simply calculating an SMA of duplicated higher-timeframe values. That's the correct architecture for a multi-timeframe SMA calculation.

The calculation is essentially:

Distance=
SMA
CurrentPrice−SMA
	​

×100

Therefore:

+3.20% means price is 3.20% above the moving average.

−3.20% means price is 3.20% below it.

And we made the visual rule very simple:

🟢 Green = above SMA

🔴 Red = below SMA

You don't need additional "bullish" or "bearish" text because the sign and color already communicate it.

8. Important point about the very long SMA columns

There is one distinction you should understand.

The genuine TradingView timeframes are straightforward through:

1H / 4H / 8H / 1D / 3D / 1W / 1M / 6M / 1Y

Pine timeframe strings are defined as a multiplier plus a supported unit, and request.security() uses those timeframe contexts to evaluate the requested expression.

The 2Y / 3Y / 5Y columns in our current version are constructed from annual (12M) data because the direct 24M, 36M, and 60M implementation we initially tried was invalid.

There is also a practical limitation: something such as a true SMA 200 of five-year candles would require an extraordinary amount of historical data.

So I would treat the extreme long-term columns differently from your core 1H–1Y signals.

Your most actionable dashboard is really:

1H → immediate
4H → short-term structure
8H → intermediate
1D → daily
3D → broader swing
1W → macro structure
1M → major macro
6M → very long-term
1Y → structural extreme
9. Weekly POC

Another major component is the weekly Point of Control.

Your script collects price and volume throughout each week and estimates the price bucket that accumulated the most volume.

That becomes the week's POC.

Conceptually:

Price

1.1850  ███
1.1800  █████
1.1750  ███████████████  ← POC
1.1700  ███████
1.1650  ███

The POC is therefore an approximation of the week's highest-volume price area.

One qualification: this is not exchange-level centralized Forex volume profile. Spot FX is decentralized, and your script is constructing the POC from the volume data available through the chart feed.

So I would call it an approximate weekly POC based on TradingView's available volume data, not an absolute global FX POC.

10. Monday defines the week

We designed the weekly structure around:

Monday → start of trading week

with the completed weeks stored backwards:

THIS WEEK
W-1 = last week
W-2 = two weeks ago
W-3 = three weeks ago
...

That makes the historical structure intuitive.

You don't have to calculate dates mentally.

11. Each previous week can have its own color

You specifically wanted to be able to visually separate weeks.

So there are individual settings for:

W-1
W-2
W-3
W-4
...
W-13

You can assign a different color to every one.

This becomes useful when several weekly POCs are relatively close together.

Instead of seeing eight identical horizontal lines, you immediately know which week produced which level.

12. The POC lines are horizontal

We fixed the earlier problem where the current-week drawing was interfering with your most recent candles.

The intended representation is:

──────────────────────────── W-1 POC

not:

             |
             |
             |
             |

The whole purpose is to identify a price level, so horizontal representation is appropriate.

13. Current-week POC can start later

You also wanted the current week's developing POC not to interfere with the beginning of the week's chart.

There is therefore a setting:

Display Current Week From

with:

Monday
Tuesday
Wednesday
Thursday
Friday

The default we used was Wednesday.

Historical completed weeks are still retained normally.

This only controls when the developing THIS WEEK POC becomes visible.

14. Weekly POC percentage

Beside the POC, the indicator calculates the distance between current price and that POC.

For example:

W-1 | 17 Aug 2026 | POC 1.16850 | +1.42%

means current price is approximately 1.42% above last week's POC.

A negative result:

-0.83%

means current price is below that POC.

That gives you more information than simply drawing a horizontal line.

15. Label collision protection

This was another important change.

Originally the weekly POC labels and vector recovery labels could overlap.

You could end up with:

W-2 POC 1.16...
48% REC
52% LEF...

on top of each other.

The current system reserves the price locations occupied by vector labels and then searches for a free location for the weekly label.

If it needs to move the weekly label away from its actual POC, it uses a small dotted connector to show which level the label belongs to.

Also:

Vector labels stay closer to price.

Weekly labels are positioned farther to the right.

That separates the two information systems.

16. You can control the amount of information

There are multiple visibility and size controls.

You can independently control things such as:

SMA table on/off
Weekly POC on/off
Current-week POC on/off
Weekly labels on/off
Vector shadows on/off
Partial-recovery percentages on/off
Recovered zones on/off
Gaps on/off
Vector text size
Weekly text size
SMA table text size
Number of historical weeks
Number of recovery labels
Number of recovered vectors retained

That's important because this indicator contains a lot of information. On a 3-minute chart you may want a different visual configuration than on a daily chart.

17. What the indicator is actually telling you

The strongest way to use it is not to treat any single component as an automatic buy/sell signal.

Instead you're building confluence.

Imagine price is approaching an old area and you see:

Unmitigated bearish vector
        ↓
Previous weekly POC
        ↓
SMA 200
        ↓
Weekly structure bearish

That is much more interesting than finding a random red vector.

Likewise:

Old bullish vector partially recovered
             +
Major gap
             +
W-2 POC
             +
Price above 30/50/200 SMA on 4H
             +
Price above 30/50 SMA on 1D

Now you're looking at several independent pieces of information around the same price region.

That is where this indicator becomes useful.

The way I'd mentally divide it

Think of Master Weekly Vector Forex as four layers:

Layer	What you're asking
Vectors	Where did abnormal volume/activity appear?
Recovery + gaps	What areas has price not finished revisiting?
Weekly POC	Where did weekly volume concentrate?
SMA dashboard	Where is price relative to broader trend structure?

The chart itself gives you the location.

The SMA table gives you the multi-timeframe environment.

And the recovery system tells you which historical areas are still outstanding versus already completed.

One technical point to keep in mind: request.security() can include developing/unconfirmed higher-timeframe values on realtime bars depending on how the request is structured, so the current SMA dashboard should be considered live/developing for an unfinished higher-timeframe candle rather than assumed to be a permanently confirmed historical value. TradingView explicitly documents that distinction.

That is the full logic of the indicator as it stands now.

---

## Source Code

````pine
//@version=6
indicator(
     "Master Weekly Vector Forex",
     shorttitle = "MWVF",
     overlay = true,
     max_boxes_count = 500,
     max_labels_count = 500,
     max_lines_count = 500)

import TradersReality/Traders_Reality_Lib/1 as trLib


// ============================================================================
// 01 — VECTOR CANDLE COLORS
// ============================================================================

groupVectorColors = "01 — Vector Candle Colors"

redVectorColor = input.color(
     color.red, "Major Bear Vector", group = groupVectorColors)

greenVectorColor = input.color(
     color.lime, "Major Bull Vector", group = groupVectorColors)

violetVectorColor = input.color(
     color.fuchsia, "Secondary Bear Vector", group = groupVectorColors)

blueVectorColor = input.color(
     color.blue, "Secondary Bull Vector", group = groupVectorColors)

regularCandleUpColor = input.color(
     #999999, "Regular Bull", group = groupVectorColors)

regularCandleDownColor = input.color(
     #4d4d4d, "Regular Bear", group = groupVectorColors)

setCandleColors = input.bool(
     true, "Color Candles", group = groupVectorColors)


// ============================================================================
// 02 — VECTOR ZONES
// ============================================================================

groupVectorZones = "02 — Vector Zones"

showVectorZones = input.bool(
     true, "Show Vector Shadows", group = groupVectorZones)

zoneType = input.string(
     "Body only",
     "Vector Zone Size",
     options = ["Body only", "Body with wicks"],
     group = groupVectorZones)

recoveryType = input.string(
     "Body with wicks",
     "Recovery Uses",
     options = ["Body only", "Body with wicks"],
     group = groupVectorZones)

maxOpenVectors = input.int(
     120, "Maximum Open Vectors",
     minval = 10, maxval = 250,
     group = groupVectorZones)

showPartialPercent = input.bool(
     true, "Show Partial Recovery %",
     group = groupVectorZones)

partialLabelsToShow = input.int(
     8, "Maximum Recovery Labels",
     minval = 1, maxval = 30,
     group = groupVectorZones)

recentRecoveredCount = input.int(
     5, "Recent Fully Recovered Zones",
     minval = 1, maxval = 30,
     group = groupVectorZones)


// ============================================================================
// 03 — VECTOR RECOVERY
// ============================================================================

groupRecovery = "03 — Vector Recovery"

unmitigatedTransparency = input.int(
     88, "Unmitigated Transparency",
     minval = 0, maxval = 100,
     group = groupRecovery)

partialColor = input.color(
     color.orange, "Partially Recovered",
     group = groupRecovery)

partialTransparency = input.int(
     82, "Partial Transparency",
     minval = 0, maxval = 100,
     group = groupRecovery)

recoveredColor = input.color(
     color.green, "Fully Recovered",
     group = groupRecovery)

recoveredTransparency = input.int(
     70, "Full Recovery Transparency",
     minval = 0, maxval = 100,
     group = groupRecovery)

showRecoveredZones = input.bool(
     true, "Show Recent Full Recoveries",
     group = groupRecovery)


// ============================================================================
// 04 — PVSRA SOURCE
// ============================================================================

groupSource = "04 — PVSRA Source"

overrideSym = input.bool(
     false, "Override Chart Symbol",
     group = groupSource)

pvsraSym = input.string(
     "INDEX:BTCUSD", "Override Symbol",
     group = groupSource)


// ============================================================================
// 05 — GAPS
// ============================================================================

groupGaps = "05 — Gaps"

showGaps = input.bool(
     true, "Show Gaps",
     group = groupGaps)

gapDeviationPercent = input.float(
     30.0, "Minimum Gap Deviation %",
     minval = 1, maxval = 100,
     group = groupGaps)

maxGaps = input.int(
     50, "Maximum Open Gaps",
     minval = 1, maxval = 100,
     group = groupGaps)

bullGapColor = input.color(
     color.new(color.green, 88),
     "Bull Gap", group = groupGaps)

bearGapColor = input.color(
     color.new(color.red, 88),
     "Bear Gap", group = groupGaps)


// ============================================================================
// 06 — SMA DISTANCE TABLE
// ============================================================================

groupSMA = "06 — SMA Distance Table"

showSMATable = input.bool(
     true, "SHOW SMA TABLE",
     group = groupSMA)

sma1Length = input.int(
     30, "SMA 30",
     minval = 1, group = groupSMA)

sma2Length = input.int(
     50, "SMA 50",
     minval = 1, group = groupSMA)

sma3Length = input.int(
     200, "SMA 200",
     minval = 1, group = groupSMA)

smaTableSizeInput = input.string(
     "Normal", "Table Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = groupSMA)


// ============================================================================
// 07 — WEEKLY POC
// ============================================================================

groupPOC = "07 — Weekly POC"

showWeeklyPOC = input.bool(
     true, "SHOW WEEKLY POC",
     group = groupPOC)

showCurrentWeekPOC = input.bool(
     true, "Show Current Week POC",
     group = groupPOC)

weeksToShow = input.int(
     8, "Previous Weeks To Show",
     minval = 1, maxval = 13,
     group = groupPOC)

profileBins = input.int(
     32, "POC Price Bins",
     minval = 10, maxval = 100,
     group = groupPOC)

pocLineWidth = input.int(
     2, "POC Line Width",
     minval = 1, maxval = 4,
     group = groupPOC)

pocLineStyleInput = input.string(
     "Dashed", "POC Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupPOC)

pocTransparency = input.int(
     15, "POC Line Transparency",
     minval = 0, maxval = 100,
     group = groupPOC)

showPOCLabels = input.bool(
     true, "Show Weekly Labels",
     group = groupPOC)

lineLabelGap = input.int(
     3, "Gap Between POC Line & Label",
     minval = 1, maxval = 15,
     group = groupPOC)

pocLabelSizeInput = input.string(
     "Normal", "Weekly Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = groupPOC)


// ============================================================================
// 08 — CURRENT WEEK
// ============================================================================

groupCurrent = "08 — Current Week"

currentWeekStartDay = input.string(
     "Wednesday", "Display Current Week From",
     options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
     group = groupCurrent)

currentWeekColor = input.color(
     color.aqua, "THIS WEEK",
     group = groupCurrent)


// ============================================================================
// 09 — INDIVIDUAL WEEK COLORS
// ============================================================================

groupWeekColors = "09 — Individual Week Colors"

week1Color  = input.color(color.yellow, "W-1", group = groupWeekColors)
week2Color  = input.color(color.orange, "W-2", group = groupWeekColors)
week3Color  = input.color(color.purple, "W-3", group = groupWeekColors)
week4Color  = input.color(color.blue, "W-4", group = groupWeekColors)
week5Color  = input.color(color.fuchsia, "W-5", group = groupWeekColors)
week6Color  = input.color(color.teal, "W-6", group = groupWeekColors)
week7Color  = input.color(color.gray, "W-7", group = groupWeekColors)
week8Color  = input.color(color.silver, "W-8", group = groupWeekColors)
week9Color  = input.color(color.maroon, "W-9", group = groupWeekColors)
week10Color = input.color(color.navy, "W-10", group = groupWeekColors)
week11Color = input.color(color.olive, "W-11", group = groupWeekColors)
week12Color = input.color(color.lime, "W-12", group = groupWeekColors)
week13Color = input.color(color.red, "W-13", group = groupWeekColors)


// ============================================================================
// 10 — DISPLAY
// ============================================================================

groupDisplay = "10 — Display"

vectorTextSizeInput = input.string(
     "Normal", "Vector Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = groupDisplay)

vectorLabelOffset = input.int(
     3, "Vector Labels Distance Right",
     minval = 1, maxval = 15,
     group = groupDisplay)

weeklySafeDistance = input.int(
     30, "Weekly Labels Distance Right",
     minval = 18, maxval = 100,
     group = groupDisplay)


// ============================================================================
// HELPERS
// ============================================================================

getTextSize(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

getLineStyle(string s) =>
    switch s
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

getWeekColor(int n) =>
    switch n
        1 => week1Color
        2 => week2Color
        3 => week3Color
        4 => week4Color
        5 => week5Color
        6 => week6Color
        7 => week7Color
        8 => week8Color
        9 => week9Color
        10 => week10Color
        11 => week11Color
        12 => week12Color
        13 => week13Color
        => color.gray

startDayNumber(string s) =>
    switch s
        "Monday" => dayofweek.monday
        "Tuesday" => dayofweek.tuesday
        "Wednesday" => dayofweek.wednesday
        "Thursday" => dayofweek.thursday
        "Friday" => dayofweek.friday
        => dayofweek.wednesday

monthName(int m) =>
    switch m
        1 => "Jan"
        2 => "Feb"
        3 => "Mar"
        4 => "Apr"
        5 => "May"
        6 => "Jun"
        7 => "Jul"
        8 => "Aug"
        9 => "Sep"
        10 => "Oct"
        11 => "Nov"
        12 => "Dec"
        => ""

formatDate(int t) =>
    if na(t)
        "-"
    else
        str.tostring(dayofmonth(t)) + " " +
         monthName(month(t)) + " " +
         str.tostring(year(t))

distancePct(float level) =>
    if not na(level) and level != 0
        ((close - level) / level) * 100.0
    else
        na

formatPct(float value) =>
    if na(value)
        "N/A"
    else
        string prefix = value > 0 ? "+" : ""
        prefix + str.tostring(value, "#.##") + "%"

distanceColor(float value) =>
    if na(value)
        color.gray
    else if value > 0
        color.lime
    else if value < 0
        color.red
    else
        color.white

vectorTextSize = getTextSize(vectorTextSizeInput)
smaTextSize = getTextSize(smaTableSizeInput)
pocTextSize = getTextSize(pocLabelSizeInput)
pocLineStyle = getLineStyle(pocLineStyleInput)


// ============================================================================
// PVSRA / VECTOR CALCULATION
// ============================================================================

string sourceTicker = overrideSym ? pvsraSym : syminfo.tickerid

pvsraVolume = request.security(
     sourceTicker, timeframe.period, volume,
     barmerge.gaps_off, barmerge.lookahead_off)

pvsraHigh = request.security(
     sourceTicker, timeframe.period, high,
     barmerge.gaps_off, barmerge.lookahead_off)

pvsraLow = request.security(
     sourceTicker, timeframe.period, low,
     barmerge.gaps_off, barmerge.lookahead_off)

pvsraClose = request.security(
     sourceTicker, timeframe.period, close,
     barmerge.gaps_off, barmerge.lookahead_off)

pvsraOpen = request.security(
     sourceTicker, timeframe.period, open,
     barmerge.gaps_off, barmerge.lookahead_off)

[pvsraColor, alertFlag, averageVolume, volumeSpread, highestVolumeSpread] =
     trLib.calcPvsra(
         pvsraVolume,
         pvsraHigh,
         pvsraLow,
         pvsraClose,
         pvsraOpen,
         redVectorColor,
         greenVectorColor,
         violetVectorColor,
         blueVectorColor,
         regularCandleDownColor,
         regularCandleUpColor)

barcolor(setCandleColors ? pvsraColor : na)

majorBearVector = pvsraColor == redVectorColor
majorBullVector = pvsraColor == greenVectorColor
secondaryBearVector = pvsraColor == violetVectorColor
secondaryBullVector = pvsraColor == blueVectorColor

isBearVector = majorBearVector or secondaryBearVector
isBullVector = majorBullVector or secondaryBullVector
isVector = isBearVector or isBullVector


// ============================================================================
// VECTOR STORAGE
// ============================================================================

var vectorBoxes = array.new_box()
var vectorBull = array.new_bool()
var vectorStart = array.new_int()
var vectorTop = array.new_float()
var vectorBottom = array.new_float()
var vectorRecovery = array.new_float()

var recoveredBoxes = array.new_box()
var recoveryLabels = array.new_label()


// ============================================================================
// CREATE VECTOR SHADOW
// ============================================================================

if isVector and showVectorZones

    float zoneTop =
         zoneType == "Body only" ?
         math.max(pvsraOpen, pvsraClose) :
         pvsraHigh

    float zoneBottom =
         zoneType == "Body only" ?
         math.min(pvsraOpen, pvsraClose) :
         pvsraLow

    color originalVectorColor =
         majorBullVector ? greenVectorColor :
         majorBearVector ? redVectorColor :
         secondaryBullVector ? blueVectorColor :
         violetVectorColor

    box newVector = box.new(
         left = bar_index,
         top = zoneTop,
         right = bar_index + 1,
         bottom = zoneBottom,
         xloc = xloc.bar_index,
         extend = extend.right,
         border_color = color.new(originalVectorColor, 70),
         border_width = 1,
         bgcolor = color.new(
             originalVectorColor,
             unmitigatedTransparency))

    array.push(vectorBoxes, newVector)
    array.push(vectorBull, isBullVector)
    array.push(vectorStart, bar_index)
    array.push(vectorTop, zoneTop)
    array.push(vectorBottom, zoneBottom)
    array.push(vectorRecovery, 0.0)


// ============================================================================
// VECTOR RECOVERY ENGINE
// ============================================================================

if array.size(vectorBoxes) > 0

    int i = array.size(vectorBoxes) - 1

    while i >= 0

        box currentBox = array.get(vectorBoxes, i)
        bool bullVector = array.get(vectorBull, i)
        int startBar = array.get(vectorStart, i)

        float originalTop = array.get(vectorTop, i)
        float originalBottom = array.get(vectorBottom, i)
        float previousRecovery = array.get(vectorRecovery, i)

        float vectorHeight = originalTop - originalBottom

        if bar_index > startBar and vectorHeight > 0

            float testHigh =
                 recoveryType == "Body only" ?
                 math.max(open, close) :
                 high

            float testLow =
                 recoveryType == "Body only" ?
                 math.min(open, close) :
                 low

            float recovery = 0.0

            if bullVector
                recovery :=
                     math.min(
                         100.0,
                         math.max(
                             0.0,
                             originalTop - testLow) /
                         vectorHeight * 100.0)
            else
                recovery :=
                     math.min(
                         100.0,
                         math.max(
                             0.0,
                             testHigh - originalBottom) /
                         vectorHeight * 100.0)

            float bestRecovery =
                 math.max(previousRecovery, recovery)

            array.set(vectorRecovery, i, bestRecovery)

            if bestRecovery > 0 and bestRecovery < 100

                if bullVector
                    float remainingTop =
                         originalTop -
                         vectorHeight * bestRecovery / 100.0

                    box.set_top(currentBox, remainingTop)
                    box.set_bottom(currentBox, originalBottom)

                else
                    float remainingBottom =
                         originalBottom +
                         vectorHeight * bestRecovery / 100.0

                    box.set_top(currentBox, originalTop)
                    box.set_bottom(currentBox, remainingBottom)

                box.set_bgcolor(
                     currentBox,
                     color.new(partialColor, partialTransparency))

                box.set_border_color(
                     currentBox,
                     color.new(partialColor, 65))

            if bestRecovery >= 100

                box.set_extend(currentBox, extend.none)
                box.set_right(currentBox, bar_index)
                box.set_top(currentBox, originalTop)
                box.set_bottom(currentBox, originalBottom)

                if showRecoveredZones

                    box.set_bgcolor(
                         currentBox,
                         color.new(
                             recoveredColor,
                             recoveredTransparency))

                    box.set_border_color(
                         currentBox,
                         color.new(recoveredColor, 40))

                    array.push(recoveredBoxes, currentBox)

                else
                    box.delete(currentBox)

                array.remove(vectorBoxes, i)
                array.remove(vectorBull, i)
                array.remove(vectorStart, i)
                array.remove(vectorTop, i)
                array.remove(vectorBottom, i)
                array.remove(vectorRecovery, i)

        i -= 1


// ============================================================================
// VECTOR LIMITS
// ============================================================================

while array.size(vectorBoxes) > maxOpenVectors

    box oldVector = array.shift(vectorBoxes)

    array.shift(vectorBull)
    array.shift(vectorStart)
    array.shift(vectorTop)
    array.shift(vectorBottom)
    array.shift(vectorRecovery)

    box.delete(oldVector)

while array.size(recoveredBoxes) > recentRecoveredCount

    box oldRecovered = array.shift(recoveredBoxes)
    box.delete(oldRecovered)


// ============================================================================
// VECTOR RECOVERY LABELS
// ============================================================================

if barstate.islast

    while array.size(recoveryLabels) > 0
        label oldRecoveryLabel = array.pop(recoveryLabels)
        label.delete(oldRecoveryLabel)

    if showPartialPercent and array.size(vectorBoxes) > 0

        int recoveryCount = 0
        int p = array.size(vectorBoxes) - 1

        while p >= 0 and recoveryCount < partialLabelsToShow

            float recovered = array.get(vectorRecovery, p)

            if recovered > 0 and recovered < 100

                box recoveryBox = array.get(vectorBoxes, p)

                float recoveryLabelY =
                     (box.get_top(recoveryBox) +
                     box.get_bottom(recoveryBox)) / 2.0

                float remaining = 100.0 - recovered

                string recoveryText =
                     str.tostring(recovered, "#.#") +
                     "% REC\n" +
                     str.tostring(remaining, "#.#") +
                     "% LEFT"

                label newRecoveryLabel =
                     label.new(
                         x = bar_index + vectorLabelOffset,
                         y = recoveryLabelY,
                         text = recoveryText,
                         xloc = xloc.bar_index,
                         style = label.style_label_left,
                         textcolor = partialColor,
                         color = color.new(color.black, 75),
                         size = vectorTextSize)

                array.push(recoveryLabels, newRecoveryLabel)
                recoveryCount += 1

            p -= 1


// ============================================================================
// GAPS
// ============================================================================

float averageRange = ta.sma(high - low, 14)

float minimumGap =
     gapDeviationPercent / 100.0 * averageRange

bool gapUp =
     not na(minimumGap) and
     low > high[1] and
     low - high[1] >= minimumGap

bool gapDown =
     not na(minimumGap) and
     high < low[1] and
     low[1] - high >= minimumGap

var gapBoxes = array.new_box()
var gapBull = array.new_bool()
var gapStart = array.new_int()

if showGaps and (gapUp or gapDown)

    float gapTop = gapUp ? low : low[1]
    float gapBottom = gapUp ? high[1] : high

    box newGap =
         box.new(
             left = bar_index - 1,
             top = gapTop,
             right = bar_index,
             bottom = gapBottom,
             xloc = xloc.bar_index,
             extend = extend.right,
             border_color =
                 gapUp ?
                 color.new(color.green, 60) :
                 color.new(color.red, 60),
             bgcolor =
                 gapUp ?
                 bullGapColor :
                 bearGapColor)

    array.push(gapBoxes, newGap)
    array.push(gapBull, gapUp)
    array.push(gapStart, bar_index)


// ============================================================================
// GAP RECOVERY
// ============================================================================

if array.size(gapBoxes) > 0

    int g = array.size(gapBoxes) - 1

    while g >= 0

        box currentGap = array.get(gapBoxes, g)
        bool currentGapBull = array.get(gapBull, g)
        int currentGapStart = array.get(gapStart, g)

        if bar_index > currentGapStart

            bool filled =
                 currentGapBull ?
                 low <= box.get_bottom(currentGap) :
                 high >= box.get_top(currentGap)

            if filled
                box.delete(currentGap)
                array.remove(gapBoxes, g)
                array.remove(gapBull, g)
                array.remove(gapStart, g)

        g -= 1

while array.size(gapBoxes) > maxGaps

    box oldGap = array.shift(gapBoxes)
    array.shift(gapBull)
    array.shift(gapStart)
    box.delete(oldGap)


// ============================================================================
// SMA FUNCTIONS
// ============================================================================

getSMA(string tf, int len) =>
    request.security(
         syminfo.tickerid,
         tf,
         ta.sma(close, len),
         barmerge.gaps_off,
         barmerge.lookahead_off)

// Long-term columns use the valid 12M timeframe.
// 2Y = SMA period sampled every 2 years.
// 3Y = SMA period sampled every 3 years.
// 5Y = SMA period sampled every 5 years.
//
// Equivalent annual-bar lengths:
// 2Y SMA30 = 60 annual observations, etc.

getLongSMA(int len, int years) =>
    request.security(
         syminfo.tickerid,
         "12M",
         ta.sma(close, len * years),
         barmerge.gaps_off,
         barmerge.lookahead_off)

smaCell(
     table tbl,
     int column,
     int row,
     float smaValue) =>

    float dist = distancePct(smaValue)

    table.cell(
         tbl,
         column,
         row,
         formatPct(dist),
         text_color = distanceColor(dist),
         text_size = smaTextSize)


// ============================================================================
// SMA 30
// ============================================================================

sma30_1H = getSMA("60", sma1Length)
sma30_4H = getSMA("240", sma1Length)
sma30_8H = getSMA("480", sma1Length)
sma30_1D = getSMA("D", sma1Length)
sma30_3D = getSMA("3D", sma1Length)
sma30_1W = getSMA("W", sma1Length)
sma30_1M = getSMA("M", sma1Length)
sma30_6M = getSMA("6M", sma1Length)
sma30_1Y = getSMA("12M", sma1Length)
sma30_2Y = getLongSMA(sma1Length, 2)
sma30_3Y = getLongSMA(sma1Length, 3)
sma30_5Y = getLongSMA(sma1Length, 5)


// ============================================================================
// SMA 50
// ============================================================================

sma50_1H = getSMA("60", sma2Length)
sma50_4H = getSMA("240", sma2Length)
sma50_8H = getSMA("480", sma2Length)
sma50_1D = getSMA("D", sma2Length)
sma50_3D = getSMA("3D", sma2Length)
sma50_1W = getSMA("W", sma2Length)
sma50_1M = getSMA("M", sma2Length)
sma50_6M = getSMA("6M", sma2Length)
sma50_1Y = getSMA("12M", sma2Length)
sma50_2Y = getLongSMA(sma2Length, 2)
sma50_3Y = getLongSMA(sma2Length, 3)
sma50_5Y = getLongSMA(sma2Length, 5)


// ============================================================================
// SMA 200
// ============================================================================

sma200_1H = getSMA("60", sma3Length)
sma200_4H = getSMA("240", sma3Length)
sma200_8H = getSMA("480", sma3Length)
sma200_1D = getSMA("D", sma3Length)
sma200_3D = getSMA("3D", sma3Length)
sma200_1W = getSMA("W", sma3Length)
sma200_1M = getSMA("M", sma3Length)
sma200_6M = getSMA("6M", sma3Length)
sma200_1Y = getSMA("12M", sma3Length)
sma200_2Y = getLongSMA(sma3Length, 2)
sma200_3Y = getLongSMA(sma3Length, 3)
sma200_5Y = getLongSMA(sma3Length, 5)


// ============================================================================
// SINGLE SMA TABLE
// ============================================================================

var table smaTable =
     table.new(
         position.top_right,
         13,
         4,
         bgcolor = color.new(color.black, 15),
         frame_color = color.new(color.gray, 55),
         frame_width = 1)

if barstate.islast

    table.clear(smaTable, 0, 0, 12, 3)

    if showSMATable

        table.cell(smaTable, 0, 0, "SMA",
             text_color = color.yellow, text_size = smaTextSize)

        table.cell(smaTable, 1, 0, "1H",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 2, 0, "4H",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 3, 0, "8H",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 4, 0, "1D",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 5, 0, "3D",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 6, 0, "1W",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 7, 0, "1M",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 8, 0, "6M",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 9, 0, "1Y",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 10, 0, "2Y",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 11, 0, "3Y",
             text_color = color.white, text_size = smaTextSize)

        table.cell(smaTable, 12, 0, "5Y",
             text_color = color.white, text_size = smaTextSize)


        // SMA 30

        table.cell(smaTable, 0, 1, "30",
             text_color = color.white, text_size = smaTextSize)

        smaCell(smaTable, 1, 1, sma30_1H)
        smaCell(smaTable, 2, 1, sma30_4H)
        smaCell(smaTable, 3, 1, sma30_8H)
        smaCell(smaTable, 4, 1, sma30_1D)
        smaCell(smaTable, 5, 1, sma30_3D)
        smaCell(smaTable, 6, 1, sma30_1W)
        smaCell(smaTable, 7, 1, sma30_1M)
        smaCell(smaTable, 8, 1, sma30_6M)
        smaCell(smaTable, 9, 1, sma30_1Y)
        smaCell(smaTable, 10, 1, sma30_2Y)
        smaCell(smaTable, 11, 1, sma30_3Y)
        smaCell(smaTable, 12, 1, sma30_5Y)


        // SMA 50

        table.cell(smaTable, 0, 2, "50",
             text_color = color.white, text_size = smaTextSize)

        smaCell(smaTable, 1, 2, sma50_1H)
        smaCell(smaTable, 2, 2, sma50_4H)
        smaCell(smaTable, 3, 2, sma50_8H)
        smaCell(smaTable, 4, 2, sma50_1D)
        smaCell(smaTable, 5, 2, sma50_3D)
        smaCell(smaTable, 6, 2, sma50_1W)
        smaCell(smaTable, 7, 2, sma50_1M)
        smaCell(smaTable, 8, 2, sma50_6M)
        smaCell(smaTable, 9, 2, sma50_1Y)
        smaCell(smaTable, 10, 2, sma50_2Y)
        smaCell(smaTable, 11, 2, sma50_3Y)
        smaCell(smaTable, 12, 2, sma50_5Y)


        // SMA 200

        table.cell(smaTable, 0, 3, "200",
             text_color = color.white, text_size = smaTextSize)

        smaCell(smaTable, 1, 3, sma200_1H)
        smaCell(smaTable, 2, 3, sma200_4H)
        smaCell(smaTable, 3, 3, sma200_8H)
        smaCell(smaTable, 4, 3, sma200_1D)
        smaCell(smaTable, 5, 3, sma200_3D)
        smaCell(smaTable, 6, 3, sma200_1W)
        smaCell(smaTable, 7, 3, sma200_1M)
        smaCell(smaTable, 8, 3, sma200_6M)
        smaCell(smaTable, 9, 3, sma200_1Y)
        smaCell(smaTable, 10, 3, sma200_2Y)
        smaCell(smaTable, 11, 3, sma200_3Y)
        smaCell(smaTable, 12, 3, sma200_5Y)


// ============================================================================
// WEEKLY POC STORAGE
// ============================================================================

var weekPrices = array.new_float()
var weekVolumes = array.new_float()

var completedPOCs = array.new_float()
var completedWeekTimes = array.new_int()
var completedWeekStartBars = array.new_int()

var int currentWeekTime = na
var int currentWeekStartBar = na


// ============================================================================
// APPROXIMATE WEEKLY POC
// ============================================================================

calculatePOC(
     array<float> prices,
     array<float> volumes,
     int bins) =>

    float result = na

    int count =
         math.min(
             array.size(prices),
             array.size(volumes))

    if count > 0

        float profileLow = array.get(prices, 0)
        float profileHigh = profileLow

        if count > 1

            for i = 1 to count - 1

                float profilePrice = array.get(prices, i)

                profileLow := math.min(profileLow, profilePrice)
                profileHigh := math.max(profileHigh, profilePrice)

        if profileHigh == profileLow

            result := profileLow

        else

            float step =
                 (profileHigh - profileLow) / bins

            array<float> bucketVolume =
                 array.new_float(bins, 0.0)

            for i = 0 to count - 1

                float profilePrice = array.get(prices, i)
                float profileVol = nz(array.get(volumes, i))

                int bucket =
                     int(
                         math.floor(
                             (profilePrice - profileLow) /
                             step))

                bucket :=
                     math.max(
                         0,
                         math.min(bins - 1, bucket))

                float previousBucketVolume =
                     array.get(bucketVolume, bucket)

                array.set(
                     bucketVolume,
                     bucket,
                     previousBucketVolume + profileVol)

            float highestBucketVolume = -1.0
            int winningBucket = 0

            for i = 0 to bins - 1

                float currentBucketVolume =
                     array.get(bucketVolume, i)

                if currentBucketVolume > highestBucketVolume

                    highestBucketVolume := currentBucketVolume
                    winningBucket := i

            result :=
                 profileLow +
                 (winningBucket + 0.5) * step

    result


// ============================================================================
// WEEK CHANGE
// ============================================================================

bool newWeek = timeframe.change("W")

if barstate.isfirst
    currentWeekTime := time("W")
    currentWeekStartBar := bar_index

if newWeek

    float finishedWeekPOC =
         calculatePOC(
             weekPrices,
             weekVolumes,
             profileBins)

    if not na(finishedWeekPOC)

        array.unshift(completedPOCs, finishedWeekPOC)
        array.unshift(completedWeekTimes, currentWeekTime)
        array.unshift(completedWeekStartBars, currentWeekStartBar)

        while array.size(completedPOCs) > 13

            array.pop(completedPOCs)
            array.pop(completedWeekTimes)
            array.pop(completedWeekStartBars)

    array.clear(weekPrices)
    array.clear(weekVolumes)

    currentWeekTime := time("W")
    currentWeekStartBar := bar_index


// ============================================================================
// COLLECT CURRENT WEEK DATA
// ============================================================================

array.push(weekPrices, hlc3)
array.push(weekVolumes, nz(volume))

float currentPOC =
     calculatePOC(
         weekPrices,
         weekVolumes,
         profileBins)


// ============================================================================
// CURRENT WEEK DISPLAY FILTER
// ============================================================================

int selectedDay =
     startDayNumber(currentWeekStartDay)

bool showCurrentPOCNow =
     dayofweek >= selectedDay and
     dayofweek <= dayofweek.friday


// ============================================================================
// WEEKLY DRAWING STORAGE
// ============================================================================

var pocLines = array.new_line()
var pocLabels = array.new_label()
var pocConnectors = array.new_line()
var labelYValues = array.new_float()


clearWeeklyObjects() =>

    while array.size(pocLines) > 0
        line oldPOCLine = array.pop(pocLines)
        line.delete(oldPOCLine)

    while array.size(pocLabels) > 0
        label oldPOCLabel = array.pop(pocLabels)
        label.delete(oldPOCLabel)

    while array.size(pocConnectors) > 0
        line oldPOCConnector = array.pop(pocConnectors)
        line.delete(oldPOCConnector)


// ============================================================================
// LABEL COLLISION CONTROL
// ============================================================================

float labelSpacing =
     math.max(
         syminfo.mintick * 20,
         nz(
             ta.atr(14),
             syminfo.mintick * 100) * 0.10)

findFreeLabelY(float desired) =>

    float result = desired

    if array.size(labelYValues) > 0

        int attempts = 0
        bool collision = true

        while collision and attempts < 30

            collision := false

            for j = 0 to array.size(labelYValues) - 1

                float existing =
                     array.get(labelYValues, j)

                if math.abs(result - existing) < labelSpacing

                    result += labelSpacing
                    collision := true

            attempts += 1

    array.push(labelYValues, result)

    result


// ============================================================================
// DRAW WEEKLY POCS
// ============================================================================

if barstate.islast

    clearWeeklyObjects()
    array.clear(labelYValues)

    // Reserve vector label price levels.

    if showPartialPercent and array.size(vectorBoxes) > 0

        int reserveCount = 0
        int reserveIndex = array.size(vectorBoxes) - 1

        while reserveIndex >= 0 and
              reserveCount < partialLabelsToShow

            float reservedRecovery =
                 array.get(vectorRecovery, reserveIndex)

            if reservedRecovery > 0 and reservedRecovery < 100

                box reservedBox =
                     array.get(vectorBoxes, reserveIndex)

                float reservedY =
                     (box.get_top(reservedBox) +
                     box.get_bottom(reservedBox)) / 2.0

                array.push(labelYValues, reservedY)
                reserveCount += 1

            reserveIndex -= 1


    int safeWeeklyOffset =
         math.max(
             weeklySafeDistance,
             vectorLabelOffset + 15)

    int weeklyLabelX =
         bar_index + safeWeeklyOffset

    int weeklyLineEndX =
         weeklyLabelX - lineLabelGap


    // ========================================================================
    // CURRENT WEEK
    // ========================================================================

    if showWeeklyPOC and
       showCurrentWeekPOC and
       showCurrentPOCNow and
       not na(currentPOC)

        float currentLabelY =
             findFreeLabelY(currentPOC)

        line currentPOCLine =
             line.new(
                 x1 = currentWeekStartBar,
                 y1 = currentPOC,
                 x2 = weeklyLineEndX,
                 y2 = currentPOC,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = color.new(
                     currentWeekColor,
                     pocTransparency),
                 style = pocLineStyle,
                 width = pocLineWidth)

        array.push(pocLines, currentPOCLine)

        if showPOCLabels

            float currentDistance =
                 distancePct(currentPOC)

            string currentPOCText =
                 "THIS WEEK | POC " +
                 str.tostring(currentPOC, format.mintick) +
                 " | " +
                 formatPct(currentDistance)

            if math.abs(currentLabelY - currentPOC) >
               syminfo.mintick

                line currentConnector =
                     line.new(
                         x1 = weeklyLineEndX,
                         y1 = currentPOC,
                         x2 = weeklyLabelX,
                         y2 = currentLabelY,
                         xloc = xloc.bar_index,
                         extend = extend.none,
                         color = color.new(currentWeekColor, 50),
                         style = line.style_dotted,
                         width = 1)

                array.push(pocConnectors, currentConnector)

            label currentPOCLabel =
                 label.new(
                     x = weeklyLabelX,
                     y = currentLabelY,
                     text = currentPOCText,
                     xloc = xloc.bar_index,
                     style = label.style_label_left,
                     textcolor = currentWeekColor,
                     color = color.new(color.black, 65),
                     size = pocTextSize)

            array.push(pocLabels, currentPOCLabel)


    // ========================================================================
    // PREVIOUS WEEKS
    // ========================================================================

    if showWeeklyPOC

        int availableWeeks =
             math.min(
                 weeksToShow,
                 array.size(completedPOCs))

        if availableWeeks > 0

            for w = 0 to availableWeeks - 1

                float historicalPOC =
                     array.get(completedPOCs, w)

                int historicalWeekTime =
                     array.get(completedWeekTimes, w)

                int historicalStartBar =
                     array.get(completedWeekStartBars, w)

                int weekNumber = w + 1

                color weekColor =
                     getWeekColor(weekNumber)

                float historicalLabelY =
                     findFreeLabelY(historicalPOC)

                line historicalPOCLine =
                     line.new(
                         x1 = historicalStartBar,
                         y1 = historicalPOC,
                         x2 = weeklyLineEndX,
                         y2 = historicalPOC,
                         xloc = xloc.bar_index,
                         extend = extend.none,
                         color = color.new(
                             weekColor,
                             pocTransparency),
                         style = pocLineStyle,
                         width = pocLineWidth)

                array.push(pocLines, historicalPOCLine)

                if showPOCLabels

                    float historicalDistance =
                         distancePct(historicalPOC)

                    string historicalPOCText =
                         "W-" +
                         str.tostring(weekNumber) +
                         " | " +
                         formatDate(historicalWeekTime) +
                         " | POC " +
                         str.tostring(
                             historicalPOC,
                             format.mintick) +
                         " | " +
                         formatPct(historicalDistance)

                    if math.abs(
                         historicalLabelY -
                         historicalPOC) >
                         syminfo.mintick

                        line historicalConnector =
                             line.new(
                                 x1 = weeklyLineEndX,
                                 y1 = historicalPOC,
                                 x2 = weeklyLabelX,
                                 y2 = historicalLabelY,
                                 xloc = xloc.bar_index,
                                 extend = extend.none,
                                 color = color.new(weekColor, 50),
                                 style = line.style_dotted,
                                 width = 1)

                        array.push(
                             pocConnectors,
                             historicalConnector)

                    label historicalPOCLabel =
                         label.new(
                             x = weeklyLabelX,
                             y = historicalLabelY,
                             text = historicalPOCText,
                             xloc = xloc.bar_index,
                             style = label.style_label_left,
                             textcolor = weekColor,
                             color = color.new(color.black, 70),
                             size = pocTextSize)

                    array.push(
                         pocLabels,
                         historicalPOCLabel)


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
     majorBullVector,
     "Major Bull Vector",
     "Major bullish vector formed.")

alertcondition(
     majorBearVector,
     "Major Bear Vector",
     "Major bearish vector formed.")

alertcondition(
     secondaryBullVector,
     "Secondary Bull Vector",
     "Secondary bullish vector formed.")

alertcondition(
     secondaryBearVector,
     "Secondary Bear Vector",
     "Secondary bearish vector formed.")

alertcondition(
     gapUp,
     "New Bull Gap",
     "New bullish gap formed.")

alertcondition(
     gapDown,
     "New Bear Gap",
     "New bearish gap formed.")
````
