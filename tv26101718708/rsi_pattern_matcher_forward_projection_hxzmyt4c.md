# RSI Pattern Matcher & Forward Projection

- url: https://www.tradingview.com/script/HxZmYT4c/
- type: indicator
- pine_id: PUB;6e863158a20c43179677545d5dd7e422
- version: 1.0

## Description

RSI Pattern Matcher & Forward Projection is an advanced RSI-based analysis tool 
that combines historical pattern matching, statistical forward projection, 
Bollinger Bands, and an EMA overlay — all applied directly on the RSI panel.

Instead of using RSI as a simple overbought/oversold indicator, this script 
treats the RSI as a pattern signal. It scans hundreds of historical bars to find 
past moments where RSI behavior and price direction closely matched the current 
market structure, then statistically projects what RSI is most likely to do next.


### How It Works

The indicator builds a fingerprint of the current market using the last N bars 
(Pattern Length), capturing:
- RSI value for each bar in the window
- Price direction per bar (rising, falling, or flat)

It then scans the full lookback window and marks a historical bar as a match when:
- Each RSI value falls within the defined tolerance (e.g. ±4 points per bar)
- At least 60% of the price direction steps align with the current pattern

Once matches are collected, the script averages what happened to RSI over the 
following bars after each match. This averaged path is rendered as a step-by-step 
dashed projection line extending to the right of the last bar.

Bollinger Bands (length 14, multiplier 2.0) and EMA 12 are computed on the RSI 
itself — not on price. Both indicators are also extended forward by the same 
projection length using linear slope extrapolation, giving a complete forward 
context for the RSI forecast.


### What It Displays

RSI Line — main aqua line (standard RSI)

RSI EMA 12 — orange line tracking the short-term RSI average; crossovers 
signal early momentum shifts

Bollinger Bands on RSI:
  • Yellow middle band (SMA 14)
  • Red upper band (overbought pressure zone)
  • Green lower band (oversold pressure zone)
  • Gray fill between bands

Forward Projection (dashed lines extending beyond last bar):
  • RSI forecast path — averaged from historical analogs, color-coded by zone
  • BB Upper extension — red dashed
  • BB Lower extension — green dashed
  • BB Basis extension — yellow dashed
  • EMA 12 extension — orange dashed

Live RSI Label — current RSI value displayed next to the last bar, 
color-coded in real time (red ≥ 70, green ≤ 30, aqua otherwise)

Forecast Label — projected RSI value shown at the end of the forward window

Info Table (top right):
  • Matches found vs maximum
  • Dominant directional bias (Up / Down / Flat)
  • Direction distribution percentages
  • Average, best-case, and worst-case price change across all matches
  • Estimated RSI value N bars ahead
  • Confidence score based on match count


### Confidence Score

≥ 10 matches → 90%
≥  7 matches → 75%
≥  5 matches → 60%
≥  3 matches → 40%
<  3 matches → 20%

A warning is displayed on the table when fewer than 3 matches are found. 
In this case, increase RSI Tolerance or Lookback to find more historical analogs.


### Inputs

RSI Period — RSI calculation length (default: 14)
RSI Source — price input for RSI (default: close)
Pattern Length — bars used to build the current pattern fingerprint (2–20, default: 3)
Projection Length — bars ahead to project all forward lines (1–20, default: 3)
RSI Tolerance — max RSI difference per bar allowed when matching (±0.5–10, default: ±4.0)
Lookback — historical bars to scan for matches (50–999, default: 500)
Max Matches — maximum historical matches to average (3–20, default: 10)


### How To Use

1. Add the indicator to any chart — it plots on a separate RSI panel
2. Check the info table for match count; if below 3, raise RSI Tolerance or Lookback
3. Read the dominant direction and confidence score for a quick bias assessment
4. Follow the dashed projection line to see where RSI is historically likely to go
5. Use the extended BB bands to anticipate whether RSI may reach overbought or 
   oversold territory within the projection window
6. Watch the EMA extension — if the projected RSI crosses above or below the 
   extended EMA, it can signal a momentum shift ahead
7. Compare the forecast RSI label against the 70 and 30 levels for reversal context
8. Use best-case and worst-case % change figures to frame risk/reward expectations
9. Higher timeframes (1H, 4H, Daily) generally produce cleaner RSI patterns 
   and more meaningful matches


### Best Used For

- Anticipating RSI direction before price confirms
- Identifying overbought/oversold exhaustion using historical analogs
- Spotting early momentum shifts via RSI EMA crossovers
- Using BB band position to contextualize RSI extremes
- Filtering trade entries with forward projection confluence
- Multi-layer RSI analysis combining pattern matching, bands, and trend


### Originality

This script combines four independent analytical layers into a single RSI panel:
a historical analog pattern matcher, a statistical forward projection engine, 
Bollinger Bands applied to RSI (not price), and a linear slope extrapolation 
system for all forward indicators. The specific combination — simultaneous RSI 
and price direction fingerprinting, 60% direction alignment threshold, per-bar 
averaged projection, and slope-based BB/EMA extension — represents the author's 
own approach to making RSI forecasting both visual and statistically grounded.


### Disclaimer

This indicator is for educational and analytical purposes only. Pattern matching 
based on historical RSI behavior does not guarantee future results. Past analogs 
may not repeat. Always apply proper risk management and combine this tool with 
additional analysis before making any trading decisions.

Short Description:

Scans historical RSI and price direction patterns to project the most likely RSI 
path forward. Includes Bollinger Bands and EMA on RSI, full forward extension of 
all indicators, directional bias stats, and a confidence score.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('RSI Pattern Matcher & Forward Projection', overlay = false, max_bars_back = 1000)

// ─── INPUTS ─────────────────────────────────────────────────────────────────
rsiLength = input.int(14, 'RSI Period', minval = 1)
rsiSrc = input.source(close, 'RSI Source')
patternBars = input.int(3, 'Pattern Length (bars)', minval = 2, maxval = 20)
forwardBars = input.int(3, 'Projection Length (bars)', minval = 1, maxval = 20)
rsiTol = input.float(4.0, 'RSI Similarity Tolerance', minval = 0.5, maxval = 10, step = 0.5)
lookback = input.int(500, 'Lookback (bars)', minval = 50, maxval = 999)
maxMatches = input.int(10, 'Max Matches', minval = 3, maxval = 20)

// ─── RSI ────────────────────────────────────────────────────────────────────
rsiVal = ta.rsi(rsiSrc, rsiLength)

// ─── RESULTS ────────────────────────────────────────────────────────────────
var int matchCount = 0
var float upCount = 0.0
var float downCount = 0.0
var float flatCount = 0.0
var float avgPctChange = 0.0
var float maxPct = 0.0
var float minPct = 0.0
var float avgRsiAfter = 0.0

var array<float> fwdAvgClose = array.new_float(0)
var array<float> fwdAvgRsi = array.new_float(0)

if barstate.islast
    matchCount := 0
    upCount := 0
    downCount := 0
    flatCount := 0
    avgPctChange := 0.0
    maxPct := -999.0
    minPct := 999.0
    avgRsiAfter := 0.0

    array.clear(fwdAvgClose)
    array.clear(fwdAvgRsi)

    array<float> fwdCloseSum = array.new_float(forwardBars, 0.0)
    array<float> fwdRsiSum = array.new_float(forwardBars, 0.0)
    array<float> fwdCount2 = array.new_float(forwardBars, 0.0)

    array<float> curRsi = array.new_float(patternBars, 0.0)
    array<float> curDir = array.new_float(patternBars - 1, 0.0)

    for k = 0 to patternBars - 1 by 1
        array.set(curRsi, k, rsiVal[k + 1])

    for k = 0 to patternBars - 2 by 1
        diff = close[k + 1] - close[k + 2]
        array.set(curDir, k, diff > 0 ? 1.0 : diff < 0 ? -1.0 : 0.0)

    int startBar = patternBars + forwardBars + 2

    for i = startBar to lookback by 1
        if i + patternBars >= bar_index
            continue
        if i + forwardBars >= bar_index
            continue

        bool rsiMatch = true
        float rsiScore = 0.0

        for k = 0 to patternBars - 1 by 1
            pastRsi = rsiVal[i + k]
            curR = array.get(curRsi, k)
            diff = math.abs(pastRsi - curR)
            rsiScore := rsiScore + diff
            if diff > rsiTol
                rsiMatch := false
                break

        if not rsiMatch
            continue

        bool dirMatch = true
        int dirMatchCount = 0

        for k = 0 to patternBars - 2 by 1
            pastDiff = close[i + k] - close[i + k + 1]
            pastDir = pastDiff > 0 ? 1.0 : pastDiff < 0 ? -1.0 : 0.0
            curD = array.get(curDir, k)
            if pastDir == curD
                dirMatchCount := dirMatchCount + 1
                dirMatchCount

        if dirMatchCount < int(math.round((patternBars - 1) * 0.6))
            dirMatch := false
            dirMatch

        if not dirMatch
            continue

        if matchCount >= maxMatches
            break

        matchCount := matchCount + 1

        float baseClose = close[i]
        float endClose = close[i - forwardBars]
        float pctChange = (endClose - baseClose) / baseClose * 100

        avgPctChange := avgPctChange + pctChange

        if pctChange > maxPct
            maxPct := pctChange
            maxPct
        if pctChange < minPct
            minPct := pctChange
            minPct

        if pctChange > 0.1
            upCount := upCount + 1
            upCount
        else if pctChange < -0.1
            downCount := downCount + 1
            downCount
        else
            flatCount := flatCount + 1
            flatCount

        for f = 0 to forwardBars - 1 by 1
            fClose = close[i - f]
            fRsi = rsiVal[i - f]
            normClose = (fClose - baseClose) / baseClose * 100
            array.set(fwdCloseSum, f, array.get(fwdCloseSum, f) + normClose)
            array.set(fwdRsiSum, f, array.get(fwdRsiSum, f) + fRsi)
            array.set(fwdCount2, f, array.get(fwdCount2, f) + 1)

    if matchCount > 0
        avgPctChange := avgPctChange / matchCount
        for f = 0 to forwardBars - 1 by 1
            cnt = array.get(fwdCount2, f)
            if cnt > 0
                array.push(fwdAvgClose, array.get(fwdCloseSum, f) / cnt)
                array.push(fwdAvgRsi, array.get(fwdRsiSum, f) / cnt)
            else
                array.push(fwdAvgClose, 0.0)
                array.push(fwdAvgRsi, 50.0)
    else
        maxPct := 0.0
        minPct := 0.0
        minPct

// ─── TABLE ──────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 4, 12, bgcolor = color.new(color.black, 5), border_color = color.new(color.gray, 50), border_width = 1, frame_color = color.new(color.white, 20), frame_width = 2)

hdrBg = color.new(#1a237e, 10)
upBg = color.new(#1b5e20, 25)
downBg = color.new(#b71c1c, 25)
flatBg = color.new(#37474f, 30)
infoBg = color.new(#263238, 30)
warnBg = color.new(#e65100, 25)

if barstate.islast
    float total = upCount + downCount + flatCount
    float upPct = total > 0 ? upCount / total * 100 : 0
    float downPct = total > 0 ? downCount / total * 100 : 0
    float flatPct = total > 0 ? flatCount / total * 100 : 0

    string dominant = upPct >= downPct and upPct >= flatPct ? '⬆ UP' : downPct > upPct and downPct >= flatPct ? '⬇ DOWN' : '➡ FLAT'
    color domColor = upPct >= downPct and upPct >= flatPct ? color.lime : downPct > upPct ? color.red : color.yellow
    color domBg = upPct >= downPct and upPct >= flatPct ? upBg : downPct > upPct ? downBg : flatBg

    table.cell(t, 0, 0, 'RSI PATTERN MATCHER & PROJECTION', text_color = color.yellow, text_size = size.small, bgcolor = hdrBg)
    table.merge_cells(t, 0, 0, 3, 0)

    table.cell(t, 0, 1, 'Pattern: ' + str.tostring(patternBars) + ' bars', text_color = color.silver, text_size = size.tiny, bgcolor = infoBg)
    table.cell(t, 1, 1, 'Forward: ' + str.tostring(forwardBars) + ' bars', text_color = color.silver, text_size = size.tiny, bgcolor = infoBg)
    table.cell(t, 2, 1, 'RSI Tol: ±' + str.tostring(rsiTol, '#.#'), text_color = color.silver, text_size = size.tiny, bgcolor = infoBg)
    table.cell(t, 3, 1, 'Lookback: ' + str.tostring(lookback), text_color = color.silver, text_size = size.tiny, bgcolor = infoBg)

    matchBg = matchCount >= 5 ? infoBg : warnBg
    table.cell(t, 0, 2, 'Matches Found', text_color = color.white, text_size = size.tiny, bgcolor = matchBg)
    table.merge_cells(t, 0, 2, 1, 2)
    table.cell(t, 2, 2, str.tostring(matchCount) + ' / ' + str.tostring(maxMatches), text_color = matchCount >= 5 ? color.lime : color.orange, text_size = size.small, bgcolor = matchBg)
    table.merge_cells(t, 2, 2, 3, 2)

    table.cell(t, 0, 3, 'PROJECTED DIRECTION', text_color = color.white, text_size = size.tiny, bgcolor = domBg)
    table.merge_cells(t, 0, 3, 1, 3)
    table.cell(t, 2, 3, dominant, text_color = domColor, text_size = size.small, bgcolor = domBg)
    table.merge_cells(t, 2, 3, 3, 3)

    table.cell(t, 0, 4, '⬆ Up', text_color = color.lime, text_size = size.tiny, bgcolor = upBg)
    table.cell(t, 1, 4, str.tostring(upPct, '#.0') + '%', text_color = color.lime, text_size = size.small, bgcolor = upBg)
    table.cell(t, 2, 4, '⬇ Down', text_color = color.red, text_size = size.tiny, bgcolor = downBg)
    table.cell(t, 3, 4, str.tostring(downPct, '#.0') + '%', text_color = color.red, text_size = size.small, bgcolor = downBg)

    table.cell(t, 0, 5, '➡ Flat', text_color = color.yellow, text_size = size.tiny, bgcolor = flatBg)
    table.cell(t, 1, 5, str.tostring(flatPct, '#.0') + '%', text_color = color.yellow, text_size = size.tiny, bgcolor = flatBg)
    table.cell(t, 2, 5, 'Avg Change', text_color = color.white, text_size = size.tiny, bgcolor = infoBg)
    table.cell(t, 3, 5, (avgPctChange >= 0 ? '+' : '') + str.tostring(avgPctChange, '#.##') + '%', text_color = avgPctChange >= 0 ? color.lime : color.red, text_size = size.tiny, bgcolor = infoBg)

    table.cell(t, 0, 6, 'Best Case', text_color = color.white, text_size = size.tiny, bgcolor = upBg)
    table.merge_cells(t, 0, 6, 1, 6)
    table.cell(t, 2, 6, '+' + str.tostring(maxPct, '#.##') + '%', text_color = color.lime, text_size = size.tiny, bgcolor = upBg)
    table.merge_cells(t, 2, 6, 3, 6)

    table.cell(t, 0, 7, 'Worst Case', text_color = color.white, text_size = size.tiny, bgcolor = downBg)
    table.merge_cells(t, 0, 7, 1, 7)
    table.cell(t, 2, 7, str.tostring(minPct, '#.##') + '%', text_color = color.red, text_size = size.tiny, bgcolor = downBg)
    table.merge_cells(t, 2, 7, 3, 7)

    if array.size(fwdAvgRsi) > 0
        lastFwdRsi = array.get(fwdAvgRsi, array.size(fwdAvgRsi) - 1)
        table.cell(t, 0, 8, 'Avg RSI in ' + str.tostring(forwardBars) + ' Bars', text_color = color.white, text_size = size.tiny, bgcolor = infoBg)
        table.merge_cells(t, 0, 8, 1, 8)
        table.cell(t, 2, 8, str.tostring(lastFwdRsi, '#.0'), text_color = color.aqua, text_size = size.tiny, bgcolor = infoBg)
        table.merge_cells(t, 2, 8, 3, 8)

    float confidence = matchCount >= 10 ? 90.0 : matchCount >= 7 ? 75.0 : matchCount >= 5 ? 60.0 : matchCount >= 3 ? 40.0 : 20.0
    color confColor = confidence >= 70 ? color.lime : confidence >= 50 ? color.yellow : color.red
    table.cell(t, 0, 9, 'Confidence Score', text_color = color.white, text_size = size.small, bgcolor = infoBg)
    table.merge_cells(t, 0, 9, 1, 9)
    table.cell(t, 2, 9, str.tostring(confidence, '#') + '%', text_color = confColor, text_size = size.small, bgcolor = infoBg)
    table.merge_cells(t, 2, 9, 3, 9)

    if matchCount < 3
        table.cell(t, 0, 10, '⚠ Low matches: increase RSI tolerance or lookback', text_color = color.orange, text_size = size.tiny, bgcolor = warnBg)
        table.merge_cells(t, 0, 10, 3, 10)

// ─── CHART ──────────────────────────────────────────────────────────────────
plot(rsiVal, 'RSI', color.aqua, linewidth = 2)
hline(70, 'Overbought', color.new(color.red, 10), linestyle = hline.style_dotted)
hline(30, 'Oversold', color.new(color.green, 10), linestyle = hline.style_dotted)
hline(50, 'Middle', color.new(color.gray, 10), linestyle = hline.style_dotted)

patternActive = bar_index >= bar_index[patternBars]
bgcolor(barstate.islast ? color.new(color.yellow, 85) : na, title = 'Current Bar')

// ─── RSI EMA 12 ─────────────────────────────────────────────────────────────
rsiEma12 = ta.ema(rsiVal, 12)
plot(rsiEma12, 'RSI EMA 12', color.new(color.orange, 0), linewidth = 1, style = plot.style_line)

// ─── BOLLINGER BANDS ON RSI ──────────────────────────────────────────────────
bbLength = 14
bbMult = 2.0
bbBasis = ta.sma(rsiVal, bbLength)
bbDev = bbMult * ta.stdev(rsiVal, bbLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

plot(bbBasis, 'BB Basis', color.new(color.yellow, 50), linewidth = 1, style = plot.style_line)
plot(bbUpper, 'BB Upper', color.new(color.red, 40), linewidth = 1, style = plot.style_line)
plot(bbLower, 'BB Lower', color.new(color.green, 40), linewidth = 1, style = plot.style_line)

// ─── LIVE RSI LABEL ─────────────────────────────────────────────────────────
var label rsiLabel = na

if barstate.islast
    label.delete(rsiLabel)
    rsiColor = rsiVal >= 70 ? color.red : rsiVal <= 30 ? color.lime : color.aqua
    rsiLabel := label.new(x = bar_index + 2, y = rsiVal, text = 'RSI: ' + str.tostring(rsiVal, '#.00'), color = color.new(color.black, 100), textcolor = rsiColor, style = label.style_label_left, size = size.small)
    rsiLabel

// ─── PROJECTED RSI: Step-by-step line + final label ─────────────────────────
var array<line> forecastLines = array.new_line()
var label forecastLabel = na

if barstate.islast
    for ln in forecastLines
        line.delete(ln)
    array.clear(forecastLines)
    label.delete(forecastLabel)

    if array.size(fwdAvgRsi) > 0
        float prevY = rsiVal
        int prevX = bar_index

        for f = 0 to array.size(fwdAvgRsi) - 1 by 1
            curY = array.get(fwdAvgRsi, f)
            curX = bar_index + f + 1

            fcastColor = curY >= 70 ? color.red : curY <= 30 ? color.lime : color.orange

            ln = line.new(x1 = prevX, y1 = prevY, x2 = curX, y2 = curY, color = color.new(fcastColor, 30), style = line.style_dashed, width = 2)
            array.push(forecastLines, ln)

            prevX := curX
            prevY := curY
            prevY

        lastRsi = array.get(fwdAvgRsi, array.size(fwdAvgRsi) - 1)
        lastColor = lastRsi >= 70 ? color.red : lastRsi <= 30 ? color.lime : color.orange
        forecastLabel := label.new(x = bar_index + forwardBars + 7, y = lastRsi, text = 'FORECAST\nRSI: ' + str.tostring(lastRsi, '#.0'), color = color.new(color.black, 10), textcolor = lastColor, style = label.style_label_left, size = size.small)
        forecastLabel

// ─── EXTEND BB & EMA INTO PROJECTION ────────────────────────────────────────
var line bbUpperExt = na
var line bbLowerExt = na
var line bbBasisExt = na
var line emaExt = na

if barstate.islast
    line.delete(bbUpperExt)
    line.delete(bbLowerExt)
    line.delete(bbBasisExt)
    line.delete(emaExt)

    // BB ve EMA'nın son iki barındaki eğimi hesapla
    bbUpperSlope = bbUpper - bbUpper[1]
    bbLowerSlope = bbLower - bbLower[1]
    bbBasisSlope = bbBasis - bbBasis[1]
    emaSlope = rsiEma12 - rsiEma12[1]

    // Projeksiyon bitiş noktaları (eğim * forwardBars uzatılıyor)
    bbUpperEnd = bbUpper + bbUpperSlope * forwardBars
    bbLowerEnd = bbLower + bbLowerSlope * forwardBars
    bbBasisEnd = bbBasis + bbBasisSlope * forwardBars
    emaEnd = rsiEma12 + emaSlope * forwardBars

    bbUpperExt := line.new(x1 = bar_index, y1 = bbUpper, x2 = bar_index + forwardBars, y2 = bbUpperEnd, color = color.new(color.red, 55), style = line.style_dashed, width = 1)

    bbLowerExt := line.new(x1 = bar_index, y1 = bbLower, x2 = bar_index + forwardBars, y2 = bbLowerEnd, color = color.new(color.green, 55), style = line.style_dashed, width = 1)

    bbBasisExt := line.new(x1 = bar_index, y1 = bbBasis, x2 = bar_index + forwardBars, y2 = bbBasisEnd, color = color.new(color.yellow, 60), style = line.style_dashed, width = 1)

    emaExt := line.new(x1 = bar_index, y1 = rsiEma12, x2 = bar_index + forwardBars, y2 = emaEnd, color = color.new(color.orange, 40), style = line.style_dashed, width = 1)
    emaExt
````
