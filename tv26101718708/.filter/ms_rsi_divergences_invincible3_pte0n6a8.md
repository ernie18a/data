# MS & RSI Divergences [invincible3]

- url: https://www.tradingview.com/script/PtE0N6A8-MS-RSI-Divergences-invincible3/
- type: indicator
- pine_id: PUB;b1b4fa33139b4c929c6f8ec1645895e3
- version: 1.0

## Description

[b]MS & RSI Divergences [invincible3][/b]

MS & RSI Divergences [invincible3] is a market-structure-based trading tool designed to identify key swing highs, swing lows, RSI regular divergences, and swing-based volume profile zones directly on the main chart.

This indicator combines price action structure, momentum divergence, and volume distribution into one visual framework, helping traders analyze whether price movement is supported or weakened by momentum and volume.

The script detects confirmed pivot highs and lows using user-defined left and right lookback bars, then classifies each swing as:

HH — Higher High
LH — Lower High
HL — Higher Low
LL — Lower Low

It also draws a dotted ZigZag between confirmed swings, making the overall market structure easier to read. The active swing is dynamically updated, so if another stronger high or lower low appears before the opposite pivot forms, the script keeps only the strongest valid swing. This helps reduce duplicate or weak swing labels and keeps the chart cleaner.

[b]Key Features[/b]
[b]1. Market Structure Detection[/b]

The indicator automatically identifies major swing points and labels them as HH, LH, HL, or LL. This helps traders quickly understand whether the market is forming bullish continuation, bearish continuation, or possible reversal structure.

A sequence of HH + HL usually reflects bullish structure, while LH + LL usually reflects bearish structure.

[b]2. RSI Regular Divergence[/b]

The indicator uses RSI to detect regular divergences at confirmed swing points.

A bearish divergence is detected when price forms a higher high, but RSI forms a lower high. This can suggest weakening bullish momentum.

A bullish divergence is detected when price forms a lower low, but RSI forms a higher low. This can suggest weakening bearish momentum.

Divergence lines are drawn directly on price, with a “D” label marking the divergence area.

[b]3. Swing Volume Profile[/b]

For each completed swing leg, the indicator can draw a volume profile between the previous swing and the current swing.

This shows where the most trading activity occurred inside that swing range. The profile also includes a dashed POC line, which represents the price level with the highest volume concentration inside the swing.

This can help identify important reaction zones, support/resistance areas, and volume-based decision levels.

[b]4. Leg Statistics[/b]

The indicator can display swing-leg statistics, including:

Total leg volume
Volume delta approximation
POC price

The delta is estimated using candle direction, where bullish candles contribute positive volume and bearish candles contribute negative volume.

[b]Main Settings[/b]
[b]Market Structure Settings[/b]

Left Bars Lookback controls how many bars are checked on the left side of a pivot.

Right Bars Lookback controls how many bars are required after a pivot before it is confirmed.

Show MS Labels enables or disables HH, LH, HL, and LL labels.

Show Dotted ZigZag enables or disables the dotted swing connection line.

[b]RSI Divergence Settings[/b]

Show Regular Divergences enables or disables RSI divergence detection.

RSI Length controls the RSI calculation period.

You can also customize bullish and bearish divergence colors.

[b]Swing Volume Profile Settings[/b]

Show Swing Volume Profiles enables or disables the volume profile for each swing.

Profile Granularity controls the number of volume rows.

Profile Width controls how far the profile extends to the right.

Show Leg Stats displays volume, delta, and POC information.

Background Transparency controls the visibility of the profile background box.

[b]How to Use[/b]

Use the market structure labels to understand the current trend direction.

Use RSI divergence signals near HH, LH, HL, or LL areas to detect possible momentum weakness.

Use the swing volume profile and POC line to find price zones where volume was concentrated.

For stronger confirmation, combine this indicator with support/resistance, trendlines, higher-timeframe bias, or your own trading system.

[b]Important Notes[/b]

This indicator uses pivot-based logic, so swing labels appear only after the required right-side confirmation bars have closed.

The active swing can update until the opposite swing is confirmed. This is intentional because the script keeps the strongest high or lowest low before a new opposite pivot appears.

This tool is designed for analysis and decision support. It should not be used alone as a buy or sell signal.

[b]Best Used For[/b]
Price action analysis
Market structure reading
RSI divergence detection
Swing trading
Trend reversal analysis
Support and resistance confirmation
Volume profile-based swing analysis

[b]Disclaimer[/b]

This indicator is for educational and analytical purposes only. It does not guarantee future price movement. Always use proper risk management and confirm signals with your own trading strategy before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3
//@version=6
indicator("MS & RSI Divergences [invincible3]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- Groups ---
G_MS    = "Market Structure"
G_RSI   = "RSI Divergence"
G_VP    = "Swing Volume Profile"
G_COL   = "Style & Colors"

// --- Inputs ---
lengthLeft  = input.int(20, "Left Bars Lookback", minval = 1, group = G_MS)
lengthRight = input.int(3, "Right Bars Lookback", minval = 1, group = G_MS)
showLabels  = input.bool(true, "Show MS Labels (HH/LL)", group = G_MS)
showZigZag  = input.bool(true, "Show Dotted ZigZag", group = G_MS)

// --- RSI Divergence ---
showReg     = input.bool(true, "Show Regular Divergences", group = G_RSI)
rsiLength   = input.int(14, "RSI Length", minval = 1, group = G_RSI)
bullDivCol  = input.color(#00ffbb, "Bullish Div Color", group = G_RSI)
bearDivCol  = input.color(#ff1100, "Bearish Div Color", group = G_RSI)

// --- Volume Profile ---
showVP      = input.bool(true, "Show Swing Volume Profiles", group = G_VP)
vpRows      = input.int(24, "Profile Granularity (Rows)", minval = 5, maxval = 100, group = G_VP)
vpWidth     = input.int(40, "Profile Width (Bars)", minval = 5, group = G_VP)
showStats   = input.bool(true, "Show Leg Stats (Vol/Delta/POC)", group = G_VP)
bgTransparency = input.int(92, "Background Transparency", minval = 0, maxval = 100, group = G_VP)

// --- Colors ---
bullColor   = input.color(#00bcd4, "Bullish Swing Color", group = G_COL)
bearColor   = input.color(#e91e63, "Bearish Swing Color", group = G_COL)
colorHH     = input.color(#089981, "Higher High", group = G_COL)
colorLH     = input.color(#ff9800, "Lower High", group = G_COL)
colorHL     = input.color(color.rgb(7, 205, 172), "Higher Low", group = G_COL)
colorLL     = input.color(#f23645, "Lower Low", group = G_COL)

// --- Core Series ---
rsiVal = ta.rsi(close, rsiLength)
ph = ta.pivothigh(lengthLeft, lengthRight)
pl = ta.pivotlow(lengthLeft, lengthRight)

// --- Current swing memory ---
var int   lastSwingType  = 0      // 1 = High, -1 = Low
var float lastSwingValue = na
var int   lastSwingIdx   = na
var label lastSwingLabel = na

// Current active leg start
var int   legStartIdx   = na
var float legStartValue = na

// Previous completed highs/lows for classification
var float prevHighP = na
var int   prevHighI = na
var float prevHighR = na

var float prevLowP = na
var int   prevLowI = na
var float prevLowR = na

// Base high/low used while same-side replacement is happening
var float baseHighP = na
var int   baseHighI = na
var float baseHighR = na

var float baseLowP = na
var int   baseLowI = na
var float baseLowR = na

// Objects belonging to current active leg only
var box[]   curBoxes  = array.new_box()
var line[]  curLines  = array.new_line()
var label[] curLabels = array.new_label()

// --- Helpers ---
formatVol(float vol) =>
    float aVol = math.abs(vol)
    aVol >= 1000000 ? str.tostring(vol / 1000000, "#.###") + "M" :
     aVol >= 1000 ? str.tostring(vol / 1000, "#.###") + "K" :
     str.tostring(vol, "#")

deleteCurrentLegObjects() =>
    if array.size(curBoxes) > 0
        for i = 0 to array.size(curBoxes) - 1
            box.delete(array.get(curBoxes, i))
    if array.size(curLines) > 0
        for i = 0 to array.size(curLines) - 1
            line.delete(array.get(curLines, i))
    if array.size(curLabels) > 0
        for i = 0 to array.size(curLabels) - 1
            label.delete(array.get(curLabels, i))

    array.clear(curBoxes)
    array.clear(curLines)
    array.clear(curLabels)

makeMSLabel(int pIdx, float price, string ms, bool isHigh) =>
    label out = na
    if showLabels
        color c = ms == "HH" ? colorHH :
                  ms == "LH" ? colorLH :
                  ms == "HL" ? colorHL : colorLL

        out := label.new(
             pIdx,
             price,
             ms,
             color = c,
             textcolor = color.white,
             style = isHigh ? label.style_label_down : label.style_label_up,
             size = size.small
        )
    out

drawHighDivergence(int pIdx, float price, float rsiAtPivot) =>
    if showReg and not na(baseHighP) and not na(baseHighI) and not na(baseHighR)
        if price > baseHighP and rsiAtPivot < baseHighR
            line l = line.new(baseHighI, baseHighP, pIdx, price, color = bearDivCol, width = 2)
            label lb = label.new(
                 int(math.round((baseHighI + pIdx) / 2.0)),
                 (baseHighP + price) / 2.0,
                 "D",
                 color = bearDivCol,
                 textcolor = color.white,
                 size = size.small,
                 style = label.style_label_center
            )
            array.push(curLines, l)
            array.push(curLabels, lb)

drawLowDivergence(int pIdx, float price, float rsiAtPivot) =>
    if showReg and not na(baseLowP) and not na(baseLowI) and not na(baseLowR)
        if price < baseLowP and rsiAtPivot > baseLowR
            line l = line.new(baseLowI, baseLowP, pIdx, price, color = bullDivCol, width = 2)
            label lb = label.new(
                 int(math.round((baseLowI + pIdx) / 2.0)),
                 (baseLowP + price) / 2.0,
                 "D",
                 color = bullDivCol,
                 textcolor = color.white,
                 size = size.small,
                 style = label.style_label_center
            )
            array.push(curLines, l)
            array.push(curLabels, lb)

// --- Profile Drawing Function ---
drawSwingProfile(int startI, int endI, float startP, float endP, bool isUp) =>
    if (showVP or showStats) and not na(startI)
        color mainCol = isUp ? bullColor : bearColor
        float topP    = math.max(startP, endP)
        float botP    = math.min(startP, endP)
        float pRange  = topP - botP
        float vStep   = pRange / vpRows

        if pRange > 0
            float[] binVols  = array.new_float(vpRows, 0.0)
            float totalVol   = 0.0
            float totalDelta = 0.0

            int loopS = math.min(startI, endI)
            int loopE = math.max(startI, endI)

            for i = loopS to loopE
                int lookback = bar_index - i
                if lookback >= 0
                    float bV = nz(volume[lookback])
                    float bC = close[lookback]
                    float bO = open[lookback]
                    float bP = hlc3[lookback]

                    totalVol   += bV
                    totalDelta += bV * (bC >= bO ? 1 : -1)

                    int realBin = int(math.min(vpRows - 1, math.floor((bP - botP) / vStep)))
                    if realBin >= 0
                        array.set(binVols, realBin, array.get(binVols, realBin) + bV)

            float maxV = array.max(binVols)

            int pocBin = 0
            float mV = -1.0
            for i = 0 to vpRows - 1
                if array.get(binVols, i) > mV
                    mV := array.get(binVols, i)
                    pocBin := i

            float pocPrice = botP + (pocBin + 0.5) * vStep

            if showVP
                box bgBox = box.new(
                     startI,
                     topP,
                     endI,
                     botP,
                     bgcolor = color.new(mainCol, bgTransparency),
                     border_color = color.new(mainCol, 80)
                )
                array.push(curBoxes, bgBox)

                for i = 0 to vpRows - 1
                    float bV = array.get(binVols, i)
                    int bW = maxV > 0 ? int(math.round((bV / maxV) * vpWidth)) : 0

                    if bW > 0
                        box hBox = box.new(
                             endI,
                             botP + (i + 1) * vStep,
                             endI + bW,
                             botP + i * vStep,
                             bgcolor = color.new(mainCol, 40),
                             border_color = na
                        )
                        array.push(curBoxes, hBox)

                line pocLine = line.new(
                     startI,
                     pocPrice,
                     endI + vpWidth,
                     pocPrice,
                     color = mainCol,
                     style = line.style_dashed,
                     width = 2
                )
                array.push(curLines, pocLine)

            if showStats
                string txt = "Leg Vol: " + formatVol(totalVol) +
                     "\nDelta: " + (totalDelta >= 0 ? "+" : "") + formatVol(totalDelta) +
                     "\nPOC: " + str.tostring(pocPrice, "#.##")

                label statLabel = label.new(
                     endI,
                     isUp ? topP : botP,
                     txt,
                     textcolor = mainCol,
                     style = isUp ? label.style_label_down : label.style_label_up,
                     color = #00000000,
                     size = size.small,
                     textalign = text.align_left
                )
                array.push(curLabels, statLabel)

// --- Draw/rebuild active leg ---
drawActiveLeg(int startI, int endI, float startP, float endP, bool isUp) =>
    if not na(startI)
        drawSwingProfile(startI, endI, startP, endP, isUp)

        if showZigZag
            line zz = line.new(startI, startP, endI, endP, color = color.gray, style = line.style_dotted)
            array.push(curLines, zz)

// --- Pivot High Processing ---
if not na(ph)
    int pIdx = bar_index[lengthRight]
    float rsiP = rsiVal[lengthRight]

    bool newHighLeg = lastSwingType != 1

    if newHighLeg
        // Previous leg becomes final; do not delete it, only release references.
        array.clear(curBoxes)
        array.clear(curLines)
        array.clear(curLabels)

        legStartIdx   := lastSwingIdx
        legStartValue := lastSwingValue

        baseHighP := prevHighP
        baseHighI := prevHighI
        baseHighR := prevHighR

        drawActiveLeg(legStartIdx, pIdx, legStartValue, ph, true)

        string ms = na(baseHighP) or ph > baseHighP ? "HH" : "LH"
        lastSwingLabel := makeMSLabel(pIdx, ph, ms, true)

        drawHighDivergence(pIdx, ph, rsiP)

        prevHighP := ph
        prevHighI := pIdx
        prevHighR := rsiP

        lastSwingType  := 1
        lastSwingIdx   := pIdx
        lastSwingValue := ph

    else
        // FIX: if another pivot high appears before a new pivot low,
        // keep only the strongest/highest high as the active swing.
        bool replaceHigh = ph > lastSwingValue

        if replaceHigh
            if not na(lastSwingLabel)
                label.delete(lastSwingLabel)

            deleteCurrentLegObjects()

            drawActiveLeg(legStartIdx, pIdx, legStartValue, ph, true)

            string ms = na(baseHighP) or ph > baseHighP ? "HH" : "LH"
            lastSwingLabel := makeMSLabel(pIdx, ph, ms, true)

            drawHighDivergence(pIdx, ph, rsiP)

            prevHighP := ph
            prevHighI := pIdx
            prevHighR := rsiP

            lastSwingIdx   := pIdx
            lastSwingValue := ph

// --- Pivot Low Processing ---
if not na(pl)
    int pIdx = bar_index[lengthRight]
    float rsiP = rsiVal[lengthRight]

    bool newLowLeg = lastSwingType != -1

    if newLowLeg
        // Previous leg becomes final; do not delete it, only release references.
        array.clear(curBoxes)
        array.clear(curLines)
        array.clear(curLabels)

        legStartIdx   := lastSwingIdx
        legStartValue := lastSwingValue

        baseLowP := prevLowP
        baseLowI := prevLowI
        baseLowR := prevLowR

        drawActiveLeg(legStartIdx, pIdx, legStartValue, pl, false)

        string ms = na(baseLowP) or pl < baseLowP ? "LL" : "HL"
        lastSwingLabel := makeMSLabel(pIdx, pl, ms, false)

        drawLowDivergence(pIdx, pl, rsiP)

        prevLowP := pl
        prevLowI := pIdx
        prevLowR := rsiP

        lastSwingType  := -1
        lastSwingIdx   := pIdx
        lastSwingValue := pl

    else
        // Same logic for lows: keep only the lowest low before next high.
        bool replaceLow = pl < lastSwingValue

        if replaceLow
            if not na(lastSwingLabel)
                label.delete(lastSwingLabel)

            deleteCurrentLegObjects()

            drawActiveLeg(legStartIdx, pIdx, legStartValue, pl, false)

            string ms = na(baseLowP) or pl < baseLowP ? "LL" : "HL"
            lastSwingLabel := makeMSLabel(pIdx, pl, ms, false)

            drawLowDivergence(pIdx, pl, rsiP)

            prevLowP := pl
            prevLowI := pIdx
            prevLowR := rsiP

            lastSwingIdx   := pIdx
            lastSwingValue := pl
````
