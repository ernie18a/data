# Accumulation [ShuZik]

- url: https://www.tradingview.com/script/40x0cUXQ-accumulation-shuzik/
- type: indicator
- pine_id: PUB;220e1873d23e4d97b2176c7d0d916891
- version: 4.0

## Description

Impulse + Accumulation [ShuZik]

This indicator detects strong directional price impulses based on Fair Value Gaps (FVG) and visualizes the market structure between impulse movements.

The blue blocks represent impulse zones. An impulse is detected when one or multiple nearby FVGs appear in the same direction and the total price movement exceeds the selected minimum impulse size. Nearby imbalances are merged into one larger impulse when they are part of the same directional move.

The accumulation blocks are drawn between confirmed impulse zones. These zones represent consolidation, correction, or accumulation phases after a strong move. Accumulation blocks can be filtered by minimum candle count, maximum range relative to the previous impulse, and average candle size.

Accumulation blocks are colored by total volume. Instead of hiding low-volume zones, the indicator displays all valid accumulation blocks and allows the user to assign custom colors to different volume ranges.

Main features:
- Detects bullish and bearish impulse zones
- Merges nearby FVGs into one impulse
- Draws accumulation zones between impulses
- Supports customizable impulse color
- Supports customizable accumulation colors by volume range
- Uses dashed borders matching the block color
- Includes adjustable filters for consolidation quality

## Source Code

````pine
//@version=5
indicator("Accumulation [ShuZik]", overlay=true, max_boxes_count=200, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

impulseColor = input.color(color.new(color.blue, 80), "Impulse Color", group="Main")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME SETTINGS TABLE
// Values order in every row: 1H / 4H / 1D
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tfGroup = "TF Settings  |  1H / 4H / 1D"

h1ImpulseSize = input.float(1180.0, "Impulse $ ________", minval=0, step=10, group=tfGroup, inline="imp")
h4ImpulseSize = input.float(2500.0, "", minval=0, step=10, group=tfGroup, inline="imp")
d1ImpulseSize = input.float(5000.0, "", minval=0, step=10, group=tfGroup, inline="imp")

h1MinBlockBars = input.int(16, "Min Bars _________", minval=1, step=1, group=tfGroup, inline="bars")
h4MinBlockBars = input.int(8, "", minval=1, step=1, group=tfGroup, inline="bars")
d1MinBlockBars = input.int(5, "", minval=1, step=1, group=tfGroup, inline="bars")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG CHAIN SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

logicGroup = "FVG Chain Logic"

fvgLookback = input.int(2, "FVG Lookback", minval=1, maxval=10, group=logicGroup)
maxCorrectionBars = input.int(3, "Max Correction Bars", minval=0, maxval=20, group=logicGroup)
maxCorrectionPct = input.float(40.0, "Max Correction %", minval=0, maxval=100, step=5, group=logicGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TIMEFRAME SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

is1H = timeframe.isminutes and timeframe.multiplier == 60
is4H = timeframe.isminutes and timeframe.multiplier == 240
is1D = timeframe.isdaily and timeframe.multiplier == 1

minImpulseSize =
     is1H ? h1ImpulseSize :
     is4H ? h4ImpulseSize :
     is1D ? d1ImpulseSize :
     h1ImpulseSize

minBlockBars =
     is1H ? h1MinBlockBars :
     is4H ? h4MinBlockBars :
     is1D ? d1MinBlockBars :
     h1MinBlockBars

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

volColor1k = input.color(color.new(color.gray, 90), "0-1K", group="Accumulation Volume Colors", inline="v1")
volColor2k = input.color(color.new(color.gray, 90), "1-2K", group="Accumulation Volume Colors", inline="v1")
volColor3k = input.color(color.new(color.orange, 90), "2-3K", group="Accumulation Volume Colors", inline="v1")
volColor4k = input.color(color.new(color.yellow, 90), "3-4K", group="Accumulation Volume Colors", inline="v1")
volColor5k = input.color(color.new(color.green, 90), "4-5K", group="Accumulation Volume Colors", inline="v1")

volColor6k = input.color(color.new(color.teal, 90), "5-6K", group="Accumulation Volume Colors", inline="v2")
volColor7k = input.color(color.new(color.aqua, 90), "6-7K", group="Accumulation Volume Colors", inline="v2")
volColor8k = input.color(color.new(color.purple, 90), "7-8K", group="Accumulation Volume Colors", inline="v2")
volColor9k = input.color(color.new(color.fuchsia, 90), "8-9K", group="Accumulation Volume Colors", inline="v2")
volColor10k = input.color(color.new(color.red, 90), "9K+", group="Accumulation Volume Colors", inline="v2")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bodyHigh(_i) =>
    math.max(open[_i], close[_i])

bodyLow(_i) =>
    math.min(open[_i], close[_i])

getBlockColor(_vol) =>
    _vol < 1000 ? volColor1k :
     _vol < 2000 ? volColor2k :
     _vol < 3000 ? volColor3k :
     _vol < 4000 ? volColor4k :
     _vol < 5000 ? volColor5k :
     _vol < 6000 ? volColor6k :
     _vol < 7000 ? volColor7k :
     _vol < 8000 ? volColor8k :
     _vol < 9000 ? volColor9k :
     volColor10k

getRange(_start, _end) =>
    float top = na
    float bottom = na

    for i = 0 to 500
        bi = bar_index - i

        if bi >= _start and bi <= _end
            top := na(top) ? high[i] : math.max(top, high[i])
            bottom := na(bottom) ? low[i] : math.min(bottom, low[i])

    [top, bottom]

isImpulseBodyOutsideBlock(_start, _end, _dir, _blockTop, _blockBottom) =>
    bool outside = false

    for i = 0 to 500
        bi = bar_index - i

        if bi >= _start and bi <= _end
            if _dir == 1 and bodyHigh(i) > _blockTop
                outside := true

            if _dir == -1 and bodyLow(i) < _blockBottom
                outside := true

    outside

drawImpulse(_start, _end, _top, _bottom) =>
    box.new(
         left=_start,
         top=_top,
         right=_end,
         bottom=_bottom,
         bgcolor=impulseColor,
         border_color=impulseColor,
         border_style=line.style_dashed
     )

drawBlock(_start, _end) =>
    float top = na
    float bottom = na
    float vol = 0.0
    int count = 0

    for i = 0 to 500
        bi = bar_index - i

        if bi >= _start and bi <= _end
            top := na(top) ? high[i] : math.max(top, high[i])
            bottom := na(bottom) ? low[i] : math.min(bottom, low[i])
            vol += volume[i]
            count += 1

    if count >= minBlockBars and not na(top) and not na(bottom)
        c = getBlockColor(vol)

        box.new(
             left=_start,
             top=top,
             right=_end,
             bottom=bottom,
             bgcolor=c,
             border_color=c,
             border_style=line.style_dashed
         )

        if color.t(c) < 100
            labelOffset = math.max((top - bottom) * 0.03, syminfo.mintick * 10)

            label.new(
                 x=math.round((_start + _end) / 2),
                 y=top + labelOffset,
                 text=str.tostring(math.round(vol)),
                 style=label.style_none,
                 textcolor=color.black,
                 size=size.tiny
             )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullFvg = low > high[fvgLookback]
bearFvg = high < low[fvgLookback]

newDir = bullFvg ? 1 : bearFvg ? -1 : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAIN STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool chainActive = false
var int chainDir = 0
var int chainStart = na
var int chainEnd = na
var float chainTop = na
var float chainBottom = na
var int lastFvgBar = na

var int lastEnd = na
var float lastTop = na
var float lastBottom = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT CHAIN CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barsSinceLastFvg = chainActive and not na(lastFvgBar) ? bar_index - lastFvgBar : na
chainRange = chainActive ? chainTop - chainBottom : na

bullCorrection =
     chainActive and chainDir == 1 and not na(chainRange) and chainRange > 0 ?
     (chainTop - low) / chainRange * 100 :
     0.0

bearCorrection =
     chainActive and chainDir == -1 and not na(chainRange) and chainRange > 0 ?
     (high - chainBottom) / chainRange * 100 :
     0.0

correctionOk =
     not chainActive ? true :
     chainDir == 1 ? bullCorrection <= maxCorrectionPct :
     chainDir == -1 ? bearCorrection <= maxCorrectionPct :
     true

timeOk =
     not chainActive or na(barsSinceLastFvg) ? true :
     barsSinceLastFvg <= maxCorrectionBars

chainShouldContinue = chainActive and timeOk and correctionOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN CHAIN LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newDir != 0
    fvgStart = bar_index - fvgLookback
    fvgEnd = bar_index
    [fvgTop, fvgBottom] = getRange(fvgStart, fvgEnd)

    if not chainActive
        chainActive := true
        chainDir := newDir
        chainStart := fvgStart
        chainEnd := fvgEnd
        chainTop := fvgTop
        chainBottom := fvgBottom
        lastFvgBar := bar_index
    else
        sameDirection = newDir == chainDir

        if sameDirection and chainShouldContinue
            chainEnd := fvgEnd
            chainTop := math.max(chainTop, fvgTop)
            chainBottom := math.min(chainBottom, fvgBottom)
            lastFvgBar := bar_index
        else
            chainSize = chainTop - chainBottom
            validImpulseByBlock = true

            if not na(lastEnd)
                blockStart = lastEnd + 1
                blockEnd = chainStart - 1

                if blockEnd >= blockStart
                    [blockTop, blockBottom] = getRange(blockStart, blockEnd)
                    validImpulseByBlock := isImpulseBodyOutsideBlock(chainStart, chainEnd, chainDir, blockTop, blockBottom)

            if chainSize >= minImpulseSize and validImpulseByBlock
                if not na(lastEnd)
                    drawBlock(lastEnd + 1, chainStart - 1)

                drawImpulse(chainStart, chainEnd, chainTop, chainBottom)

                lastEnd := chainEnd
                lastTop := chainTop
                lastBottom := chainBottom

            chainActive := true
            chainDir := newDir
            chainStart := fvgStart
            chainEnd := fvgEnd
            chainTop := fvgTop
            chainBottom := fvgBottom
            lastFvgBar := bar_index

else if chainActive
    if not chainShouldContinue
        finalSize = chainTop - chainBottom
        validImpulseByBlock = true

        if not na(lastEnd)
            blockStart = lastEnd + 1
            blockEnd = chainStart - 1

            if blockEnd >= blockStart
                [blockTop, blockBottom] = getRange(blockStart, blockEnd)
                validImpulseByBlock := isImpulseBodyOutsideBlock(chainStart, chainEnd, chainDir, blockTop, blockBottom)

        if finalSize >= minImpulseSize and validImpulseByBlock
            if not na(lastEnd)
                drawBlock(lastEnd + 1, chainStart - 1)

            drawImpulse(chainStart, chainEnd, chainTop, chainBottom)

            lastEnd := chainEnd
            lastTop := chainTop
            lastBottom := chainBottom

        chainActive := false
        chainDir := 0
        chainStart := na
        chainEnd := na
        chainTop := na
        chainBottom := na
        lastFvgBar := na
````
