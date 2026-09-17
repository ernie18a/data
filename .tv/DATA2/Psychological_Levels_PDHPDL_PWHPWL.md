<!-- tradingview-pine-id: PUB;42965b2582704dae9f826afc98a45ae3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Psychological Levels + PDH/PDL + PWH/PWL

Source: https://www.tradingview.com/script/c3HlGggw/

## Description

Psychological Levels + PDH/PDL + PWH/PWL

This professional indicator combines three of the most powerful key zone concepts in Forex trading into one clean, fully customizable tool. Instead of using multiple separate indicators, you get psychological price levels, Previous Day High/Low and Previous Week High/Low all in one place — perfectly designed for confluence-based trading strategies.

📊 What's included:

🔘 Psychological Levels (1000 / 100 / 50 / 25 / 10 pip steps)
Psychological levels are price zones where human psychology naturally causes order clustering. Banks, institutions and retail traders all monitor the same round numbers — making these levels self-fulfilling support and resistance zones. Each level type has its own color, zone width and line style settings and can be toggled on or off independently.

🔵 PDH / PDL — Previous Day High & Low
The most watched intraday reference points in professional Forex trading. The line starts exactly at the candle where the previous day's high or low was formed and extends to the current bar. Institutional traders use these levels for bias, stop placement and profit targets. On GBP/USD and other volatile pairs, PDH/PDL are frequently used as magnets for price during the London and New York sessions.

🔷 PWH / PWL — Previous Week High & Low
The strongest reference levels for weekly bias and multi-day trade planning. The line starts at the exact candle of the previous week's high or low and extends through the current week. A break and hold above PWH is a strong bullish signal. A rejection at PWH or PWL combined with a psychological level creates a very high-confluence setup.

💡 How to use this indicator:
Add the indicator to your GBP/USD or any other Forex chart
Enable the psychological levels that fit your timeframe (100 and 50 pip for day trading, 25 and 10 pip for scalping)
Mark where PDH/PDL and PWH/PWL sit relative to psychological levels
Look for confluence — when PDH aligns with a 100-pip level, that zone is significantly stronger
Wait for a price action trigger (engulfing candle, break of structure) at the confluence zone
Place your stop loss beyond the full zone, target the next key level with minimum 1:2 R:R

🎯 Best confluence combinations:
PDH/PDL + psychological level = strong intraday zone
PWH/PWL + psychological level = strong multi-day zone
PDH + PWH + psychological level = extremely high-probability setup
Any of the above + VWAP = institutional-grade confluence

⚙️ Customization:
Every element is fully adjustable. Colors, line styles (solid, dashed, dotted), line thickness and zone widths can all be set independently. Labels for PDH/PDL and PWH/PWL can be toggled on or off. The indicator automatically detects JPY pairs and adjusts pip calculations accordingly.

📋 Technical details:
Pine Script v6
Compatible with all Forex pairs (majors, minors, exotics)
Works on all timeframes from M1 to Weekly
Maximum 500 lines and 500 boxes for optimal performance
No repainting — levels are fixed once the session closes
Optimized calculation within visible price range for smooth performance

👤 Ideal for:
Day traders and scalpers who trade GBP/USD, EUR/USD or other major pairs on the 5-minute to 1-hour timeframe and want a clean, structured way to identify the most important price zones without cluttering their chart.

---

## Source Code

````pine
//@version=6
indicator("Psychological Levels + PDH/PDL + PWH/PWL", overlay=true, max_lines_count=500, max_boxes_count=500)

// This indicator combines psychological price levels with Previous Day High/Low (PDH/PDL)
// and Previous Week High/Low (PWH/PWL) for a complete key zone overview.
//
// 🎯 FEATURES:
// ✅ Psychological Levels – 1000, 100, 50, 25 and 10 pip levels with individual color and zone settings
// ✅ PDH/PDL – Previous Day High and Low, line starts at the exact candle of the high/low
// ✅ PWH/PWL – Previous Week High and Low, line starts at the exact candle of the high/low
// ✅ All levels fully customizable (color, line style, width, labels on/off)
// ✅ Automatic JPY pair detection
// ✅ Works on all timeframes and all Forex pairs
//
// 💡 HOW TO USE:
// 1. Add the indicator to your chart
// 2. Select which psychological levels to display (100, 50, 25, 10)
// 3. PDH/PDL and PWH/PWL are shown automatically
// 4. Use confluence of multiple levels for high-probability setups
// 5. Customize colors and styles to match your chart theme
//
// 📊 LEVEL TYPES:
// 1000-pip: Major macro barriers (e.g. 1.3000, 1.4000)
// 100-pip:  Most significant round numbers (e.g. 1.3100, 1.3200)
// 50-pip:   Intermediate levels (e.g. 1.3150, 1.3250)
// 25-pip:   Granular levels for scalping
// 10-pip:   Precision levels for micro scalping
//
// PDH/PDL: Line starts at the candle of the previous day's high/low
//          and extends to the end of the current day
// PWH/PWL: Line starts at the candle of the previous week's high/low
//          and extends to the end of the current week

// ============================================================
// ===== PSYCHOLOGISCHE LEVEL – FARBEN =====
// ============================================================
zoneColor1000 = input.color(color.new(#b0b0b0, 85), "Zonen Farbe 1000er Level", group="Psych. Level – Farben")
lineColor1000 = input.color(#b0b0b0, "Linien Farbe 1000er Level", group="Psych. Level – Farben")

zoneColor100 = input.color(color.new(#b0b0b0, 85), "Zonen Farbe 100er Level", group="Psych. Level – Farben")
lineColor100 = input.color(#b0b0b0, "Linien Farbe 100er Level", group="Psych. Level – Farben")

zoneColor50 = input.color(color.new(#b0b0b0, 85), "Zonen Farbe 50er Level", group="Psych. Level – Farben")
lineColor50 = input.color(#b0b0b0, "Linien Farbe 50er Level", group="Psych. Level – Farben")

zoneColor25 = input.color(color.new(#b0b0b0, 85), "Zonen Farbe 25er Level", group="Psych. Level – Farben")
lineColor25 = input.color(#b0b0b0, "Linien Farbe 25er Level", group="Psych. Level – Farben")

zoneColor10 = input.color(color.new(#b0b0b0, 85), "Zonen Farbe 10er Level", group="Psych. Level – Farben")
lineColor10 = input.color(#b0b0b0, "Linien Farbe 10er Level", group="Psych. Level – Farben")

// ===== PSYCHOLOGISCHE LEVEL – DARSTELLUNG =====
lineStyle  = input.string("Solid", "Linien Stil", options=["Solid", "Dashed", "Dotted"], group="Psych. Level – Darstellung")
lineWidth  = input.int(1, "Linienstärke", minval=1, maxval=5, group="Psych. Level – Darstellung")

zoneWidth1000 = input.float(15.0, "Zonenbreite 1000er Level (Pips)", minval=0.1, step=0.5, group="Psych. Level – Zonenbreiten")
zoneWidth100  = input.float(8.0,  "Zonenbreite 100er Level (Pips)",  minval=0.1, step=0.5, group="Psych. Level – Zonenbreiten")
zoneWidth50   = input.float(5.0,  "Zonenbreite 50er Level (Pips)",   minval=0.1, step=0.5, group="Psych. Level – Zonenbreiten")
zoneWidth25   = input.float(3.0,  "Zonenbreite 25er Level (Pips)",   minval=0.1, step=0.5, group="Psych. Level – Zonenbreiten")
zoneWidth10   = input.float(2.0,  "Zonenbreite 10er Level (Pips)",   minval=0.1, step=0.5, group="Psych. Level – Zonenbreiten")

// ===== PSYCHOLOGISCHE LEVEL – AUSWAHL =====
show1000 = input.bool(true,  "1000er Schritte (z.B. 1.2000, 1.3000)", group="Psych. Level – Auswahl")
show100  = input.bool(true,  "100er Schritte  (z.B. 1.2100, 1.2200)", group="Psych. Level – Auswahl")
show50   = input.bool(true,  "50er Schritte   (z.B. 1.2150, 1.2250)", group="Psych. Level – Auswahl")
show25   = input.bool(false, "25er Schritte   (z.B. 1.2125, 1.2175)", group="Psych. Level – Auswahl")
show10   = input.bool(false, "10er Schritte   (z.B. 1.2110, 1.2120)", group="Psych. Level – Auswahl")

// ============================================================
// ===== PDH / PDL – EINSTELLUNGEN =====
// ============================================================
showPDH       = input.bool(true,  "Previous Day High anzeigen",       group="PDH / PDL")
showPDL       = input.bool(true,  "Previous Day Low anzeigen",        group="PDH / PDL")
colorPDH      = input.color(#2962ff, "Farbe PDH",                     group="PDH / PDL")
colorPDL      = input.color(#2962ff, "Farbe PDL",                     group="PDH / PDL")
widthPDHL     = input.int(1, "Linienstärke PDH/PDL", minval=1, maxval=5, group="PDH / PDL")
stylePDHL     = input.string("Solid", "Stil PDH/PDL", options=["Solid","Dashed","Dotted"], group="PDH / PDL")
showLabelPDHL = input.bool(true, "Labels PDH/PDL anzeigen",           group="PDH / PDL")

// ============================================================
// ===== PWH / PWL – EINSTELLUNGEN =====
// ============================================================
showPWH       = input.bool(true,  "Previous Week High anzeigen",      group="PWH / PWL")
showPWL       = input.bool(true,  "Previous Week Low anzeigen",       group="PWH / PWL")
colorPWH      = input.color(#0d1b6e, "Farbe PWH",                     group="PWH / PWL")
colorPWL      = input.color(#0d1b6e, "Farbe PWL",                     group="PWH / PWL")
widthPWHL     = input.int(1, "Linienstärke PWH/PWL", minval=1, maxval=5, group="PWH / PWL")
stylePWHL     = input.string("Solid", "Stil PWH/PWL", options=["Solid","Dashed","Dotted"], group="PWH / PWL")
showLabelPWHL = input.bool(true, "Labels PWH/PWL anzeigen",           group="PWH / PWL")

// ============================================================
// ===== HILFSFUNKTIONEN – LINIENSTILE =====
// ============================================================
getStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

psychLineStyle = getStyle(lineStyle)
pdhlStyle      = getStyle(stylePDHL)
pwhlStyle      = getStyle(stylePWHL)

// ============================================================
// ===== BASIS-PIP-WERT =====
// ============================================================
symbolString = syminfo.ticker
isJPYPair    = str.contains(symbolString, "JPY")
pipValue     = isJPYPair ? 0.01 : 0.0001
labelOffset  = isJPYPair ? 0.003 : 0.00003

// ============================================================
// ===== SICHTBARER PREISBEREICH =====
// ============================================================
priceHigh   = ta.highest(high, 500)
priceLow    = ta.lowest(low, 500)
priceRange  = priceHigh - priceLow
visibleHigh = priceHigh + priceRange * 1.0
visibleLow  = priceLow  - priceRange * 1.0

// ============================================================
// ===== ARRAYS – PSYCHOLOGISCHE LEVEL =====
// ============================================================
var line[] allLines = array.new<line>()
var box[]  allBoxes = array.new<box>()

if barstate.islast
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1
            box.delete(array.get(allBoxes, i))
        array.clear(allBoxes)

drawPsychLevel(level, zoneWidthPips, zoneCol, lineCol) =>
    zoneHalf = zoneWidthPips * pipValue / 2
    l = line.new(bar_index - 300, level, bar_index + 100, level,
                 color=lineCol, width=lineWidth, style=psychLineStyle, extend=extend.both)
    array.push(allLines, l)
    b = box.new(bar_index - 300, level + zoneHalf, bar_index + 100, level - zoneHalf,
                border_color=na, bgcolor=zoneCol, extend=extend.both)
    array.push(allBoxes, b)

// ============================================================
// ===== PDH / PDL – BERECHNUNG & ZEICHNUNG =====
// ============================================================
isNewDay = timeframe.change("D")

var float pdh    = na
var float pdl    = na
var int   pdhBar = na
var int   pdlBar = na

var float dayHigh    = na
var float dayLow     = na
var int   dayHighBar = na
var int   dayLowBar  = na

var line  linePDH  = na
var line  linePDL  = na
var label labelPDH = na
var label labelPDL = na

if isNewDay
    if not na(dayHigh)
        pdh    := dayHigh
        pdl    := dayLow
        pdhBar := dayHighBar
        pdlBar := dayLowBar
    dayHigh    := high
    dayLow     := low
    dayHighBar := bar_index
    dayLowBar  := bar_index
else
    if na(dayHigh) or high > dayHigh
        dayHigh    := high
        dayHighBar := bar_index
    if na(dayLow) or low < dayLow
        dayLow    := low
        dayLowBar := bar_index

if barstate.islast and not na(pdh)
    if not na(linePDH)
        line.delete(linePDH)
    if not na(linePDL)
        line.delete(linePDL)
    if not na(labelPDH)
        label.delete(labelPDH)
    if not na(labelPDL)
        label.delete(labelPDL)

    endBar = bar_index + 50

    if showPDH
        linePDH := line.new(pdhBar, pdh, endBar, pdh,
                            color=colorPDH, width=widthPDHL, style=pdhlStyle)
        if showLabelPDHL
            labelPDH := label.new(endBar, pdh + labelOffset, "PDH",
                                  color=color.new(color.white, 100),
                                  textcolor=colorPDH,
                                  style=label.style_none,
                                  size=size.tiny)
    if showPDL
        linePDL := line.new(pdlBar, pdl, endBar, pdl,
                            color=colorPDL, width=widthPDHL, style=pdhlStyle)
        if showLabelPDHL
            labelPDL := label.new(endBar, pdl + labelOffset, "PDL",
                                  color=color.new(color.white, 100),
                                  textcolor=colorPDL,
                                  style=label.style_none,
                                  size=size.tiny)

// ============================================================
// ===== PWH / PWL – BERECHNUNG & ZEICHNUNG =====
// ============================================================
isNewWeek = timeframe.change("W")

var float pwh    = na
var float pwl    = na
var int   pwhBar = na
var int   pwlBar = na

var float weekHigh    = na
var float weekLow     = na
var int   weekHighBar = na
var int   weekLowBar  = na

var line  linePWH  = na
var line  linePWL  = na
var label labelPWH = na
var label labelPWL = na

if isNewWeek
    if not na(weekHigh)
        pwh    := weekHigh
        pwl    := weekLow
        pwhBar := weekHighBar
        pwlBar := weekLowBar
    weekHigh    := high
    weekLow     := low
    weekHighBar := bar_index
    weekLowBar  := bar_index
else
    if na(weekHigh) or high > weekHigh
        weekHigh    := high
        weekHighBar := bar_index
    if na(weekLow) or low < weekLow
        weekLow    := low
        weekLowBar := bar_index

if barstate.islast and not na(pwh)
    if not na(linePWH)
        line.delete(linePWH)
    if not na(linePWL)
        line.delete(linePWL)
    if not na(labelPWH)
        label.delete(labelPWH)
    if not na(labelPWL)
        label.delete(labelPWL)

    endBarWeek = bar_index + 200

    if showPWH
        linePWH := line.new(pwhBar, pwh, endBarWeek, pwh,
                            color=colorPWH, width=widthPWHL, style=pwhlStyle)
        if showLabelPWHL
            labelPWH := label.new(endBarWeek, pwh + labelOffset, "PWH",
                                  color=color.new(color.white, 100),
                                  textcolor=colorPWH,
                                  style=label.style_none,
                                  size=size.tiny)
    if showPWL
        linePWL := line.new(pwlBar, pwl, endBarWeek, pwl,
                            color=colorPWL, width=widthPWHL, style=pwhlStyle)
        if showLabelPWHL
            labelPWL := label.new(endBarWeek, pwl + labelOffset, "PWL",
                                  color=color.new(color.white, 100),
                                  textcolor=colorPWL,
                                  style=label.style_none,
                                  size=size.tiny)

// ============================================================
// ===== PSYCHOLOGISCHE LEVEL ZEICHNEN =====
// ============================================================
if barstate.islast
    baseStep = isJPYPair ? 0.01 : 0.0001
    var float[] drawnLevels = array.new<float>()
    array.clear(drawnLevels)

    if show1000
        step       = baseStep * 1000
        startLevel = math.floor(visibleLow / step) * step
        level      = startLevel
        for i = 0 to 100
            if level > visibleHigh
                break
            if level >= visibleLow
                drawPsychLevel(level, zoneWidth1000, zoneColor1000, lineColor1000)
                array.push(drawnLevels, level)
            level := level + step

    if show100
        step       = baseStep * 100
        startLevel = math.floor(visibleLow / step) * step
        level      = startLevel
        for i = 0 to 500
            if level > visibleHigh
                break
            if level >= visibleLow
                drawPsychLevel(level, zoneWidth100, zoneColor100, lineColor100)
                array.push(drawnLevels, level)
            level := level + step

    if show50
        step       = baseStep * 50
        startLevel = math.floor(visibleLow / step) * step
        level      = startLevel
        for i = 0 to 1000
            if level > visibleHigh
                break
            if level >= visibleLow
                isDuplicate = false
                if array.size(drawnLevels) > 0
                    for j = 0 to array.size(drawnLevels) - 1
                        if math.abs(array.get(drawnLevels, j) - level) < baseStep
                            isDuplicate := true
                            break
                if not isDuplicate
                    drawPsychLevel(level, zoneWidth50, zoneColor50, lineColor50)
                    array.push(drawnLevels, level)
            level := level + step

    if show25
        step       = baseStep * 25
        startLevel = math.floor(visibleLow / step) * step
        level      = startLevel
        for i = 0 to 2000
            if level > visibleHigh
                break
            if level >= visibleLow
                isDuplicate = false
                if array.size(drawnLevels) > 0
                    for j = 0 to math.min(array.size(drawnLevels) - 1, 200)
                        if math.abs(array.get(drawnLevels, j) - level) < baseStep
                            isDuplicate := true
                            break
                if not isDuplicate
                    drawPsychLevel(level, zoneWidth25, zoneColor25, lineColor25)
                    array.push(drawnLevels, level)
            level := level + step

    if show10
        step       = baseStep * 10
        startLevel = math.floor(visibleLow / step) * step
        level      = startLevel
        for i = 0 to 5000
            if level > visibleHigh
                break
            if level >= visibleLow
                isDuplicate = false
                if array.size(drawnLevels) > 0
                    startIdx = math.max(0, array.size(drawnLevels) - 100)
                    for j = startIdx to array.size(drawnLevels) - 1
                        if math.abs(array.get(drawnLevels, j) - level) < baseStep
                            isDuplicate := true
                            break
                if not isDuplicate
                    drawPsychLevel(level, zoneWidth10, zoneColor10, lineColor10)
                    array.push(drawnLevels, level)
            level := level + step

// Dummy plot
plot(na, title="Psychological Levels + PDH/PDL + PWH/PWL")
````
