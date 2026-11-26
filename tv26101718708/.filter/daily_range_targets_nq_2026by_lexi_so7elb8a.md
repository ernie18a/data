# Daily Range Targets NQ 2026_by Lexi

- url: https://www.tradingview.com/script/SO7eLb8A/
- type: indicator
- pine_id: PUB;882bca9e015f40519af1da692f3320ad
- version: 1.0

## Description

I created this to calculate the Average Range but from 2026 cause this year is different as u all know. Also to be used in New York Session ! So here is what chatgpt wrote: 

Nasdaq 2026 ADR Targets is a volatility projection tool designed for Nasdaq traders who want to know how much of the market's typical daily movement has already been completed and where the average daily range would be fully achieved.

The indicator calculates the average daily range (ADR) using all completed trading days from 2026 and compares it to the current day's range. Based on this comparison, it projects price levels above and below the market where the average 2026 daily range would be reached.

Two dynamic target levels are displayed directly on the chart:

• ADR High Target – The price level where an upward extension would complete the average 2026 daily range.

• ADR Low Target – The price level where a downward extension would complete the average 2026 daily range.

Each target displays:

• Remaining points required to reach the average daily range.

• Remaining percentage of the average daily range available.

• Real-time updates throughout the trading day as market range expands.

The indicator is not designed to predict market direction. Instead, it serves as a volatility framework, helping traders understand whether Nasdaq has already consumed most of its typical daily movement or whether significant range expansion remains available.

Key Uses:

• Measure how much of the average daily range has been used.

• Identify potential exhaustion or expansion conditions.

• Estimate how much volatility remains available during the session.

• Provide objective ADR completion targets above and below current market structure.

• Support trade management, profit targeting, and expectation setting.

The indicator is particularly useful for Nasdaq traders who focus on intraday volatility and New York session price action, providing clean, chart-based ADR targets without cluttering the trading workspace.

## Source Code

````pine
//@version=6
indicator("Daily Range Targets NQ 2026_by Lexi", overlay=true, max_lines_count=2, max_labels_count=2)

// ===== SETTINGS =====
highLineColor = input.color(color.green, "ADR High Line Color")
lowLineColor  = input.color(color.red, "ADR Low Line Color")
textColor     = input.color(color.white, "Text Color")
lineWidth     = input.int(2, "Line Width", minval=1, maxval=5)

// ===== DAILY DATA =====
dayHigh = request.security(syminfo.tickerid, "D", high)
dayLow  = request.security(syminfo.tickerid, "D", low)

todayRange = dayHigh - dayLow

// ===== PREVIOUS DAY RANGE =====
prevRange = request.security(syminfo.tickerid, "D", high[1] - low[1])

// ===== 2026 AVERAGE RANGE CALCULATION =====
var float rangeSum = 0.0
var int rangeCount = 0

newDay = ta.change(time("D")) != 0

if newDay
    if year(time[1]) == 2026
        rangeSum += prevRange[1]
        rangeCount += 1

avgRange2026 = rangeCount > 0 ? rangeSum / rangeCount : na

// ===== RANGE UTILIZATION =====
remainingPts = math.max(0, avgRange2026 - todayRange)

usedPct = avgRange2026 > 0 ? (todayRange / avgRange2026) * 100 : na
remainingPct = math.max(0, 100 - usedPct)

// ===== TARGET LEVELS =====
adrHighTarget = dayHigh + remainingPts
adrLowTarget  = dayLow - remainingPts

// ===== LINES =====
var line highLine = na
var line lowLine = na

if barstate.islast

    if not na(highLine)
        line.delete(highLine)

    if not na(lowLine)
        line.delete(lowLine)

    highLine := line.new(
         bar_index - 100,
         adrHighTarget,
         bar_index + 100,
         adrHighTarget,
         color = highLineColor,
         width = lineWidth)

    lowLine := line.new(
         bar_index - 100,
         adrLowTarget,
         bar_index + 100,
         adrLowTarget,
         color = lowLineColor,
         width = lineWidth)

// ===== LABELS =====
var label highLabel = na
var label lowLabel = na

if barstate.islast

    if not na(highLabel)
        label.delete(highLabel)

    if not na(lowLabel)
        label.delete(lowLabel)

    highText =
         "ADR HIGH | " +
         str.tostring(remainingPts, "#") + " pts left | " +
         str.tostring(remainingPct, "#.0") + "%"

    lowText =
         "ADR LOW | " +
         str.tostring(remainingPts, "#") + " pts left | " +
         str.tostring(remainingPct, "#.0") + "%"

    highLabel := label.new(
         bar_index + 3,
         adrHighTarget,
         highText,
         style = label.style_label_left,
         color = color.new(highLineColor, 80),
         textcolor = textColor,
         size = size.small)

    lowLabel := label.new(
         bar_index + 3,
         adrLowTarget,
         lowText,
         style = label.style_label_left,
         color = color.new(lowLineColor, 80),
         textcolor = textColor,
         size = size.small)
````
