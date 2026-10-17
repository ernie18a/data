# VWAP Auto Anchored Trend

- url: https://www.tradingview.com/script/9YWtTaj9-VWAP-Auto-Anchored-Trend/
- type: indicator
- pine_id: PUB;6b9d1bec659f4594b4888494f4e40920
- version: 1.0

## Description

[b]VWAP Auto Anchored Trend[/b]

This indicator is a Pine Script v6 recreation of an auto-anchored VWAP tool with an added trend and flatness readout. It is designed to help you study how volume-weighted price develops from a selected anchor and how stable or directional that VWAP remains over time.

[b]What It Does[/b]

At its core, this script calculates a [b]Volume Weighted Average Price (VWAP)[/b]. Unlike a simple moving average, VWAP gives more influence to bars with higher volume. That allows it to reflect where trading activity has been concentrated during the active anchor period.

The line begins at the selected anchor and updates forward from there, giving you a focused view of how price and volume have behaved from that point.

[b]Anchor Periods[/b]

The script supports multiple anchor types, including:

[list]
[*]Auto
[*]Highest High
[*]Lowest Low
[*]Highest Volume
[*]Session
[*]Week
[*]Month
[*]Quarter
[*]Year
[*]Decade
[*]Century
[*]Earnings
[*]Dividends
[*]Splits
[/list]

For time-based anchors such as [b]Month[/b], [b]Quarter[/b], or [b]Year[/b], the indicator displays only the currently active anchor period. That keeps the chart focused on the most recent cycle rather than extending the VWAP through the entire chart history.

[b]Source and Calculation[/b]

The VWAP can be calculated from a selectable source, such as [b]hlc3[/b], which is commonly used as a balanced price basis. The script accumulates price multiplied by volume, then divides that running total by cumulative volume over the active anchor period.

This makes the line responsive not only to price movement, but to how much trading participation occurred at those prices.

[b]Bands and Visual Structure[/b]

The script includes optional upper and lower VWAP bands. These bands can be calculated using:

[list]
[*][b]Standard Deviation[/b]
[*][b]Percentage[/b]
[/list]

Up to three band levels can be enabled, each with its own multiplier. When active, they can help frame how tightly or loosely price is trading around the anchored VWAP.

A background fill can also be used between the outer visible bands to make the VWAP zone easier to read visually.

[b]Offset Support[/b]

An offset setting is included so the VWAP and its bands can be shifted visually on the chart. This affects display placement only and does not change the underlying VWAP calculation.

[b]VWAP Flatness and Trend Readout[/b]

One of the main additions in this version is the [b]VWAP Flatness[/b] section.

Instead of only judging the VWAP slope by eye, the script measures how much the VWAP has drifted from its anchor to the current bar. It then normalizes that drift using ATR to produce a more comparable trend/flatness reading.

The table compares two views:

[list]
[*][b]All Period[/b] - the entire active anchor period
[*][b]Last 50%[/b] - the most recent half of that same period
[/list]

This can help show whether the VWAP has remained balanced over the full anchor period, or whether the more recent portion has started to trend more clearly.

[b]Table Readout Includes[/b]

[list]
[*][b]VWAP State[/b] - VERY FLAT, FLAT, MODERATE, TRENDING, or STRONG TREND
[*][b]ATR Score[/b] - VWAP drift measured against ATR
[*][b]Drift %[/b] - total percentage drift in VWAP over the measured section
[*][b]Per Bar %[/b] - average drift per bar over that section
[/list]

This is intended as a structured way to describe VWAP behavior. It does not predict future price movement, but it can help organize how stable or directional the VWAP has been within the chosen anchor window.

[b]How It May Be Used[/b]

This indicator can be used as a reference for:

[list]
[*]Tracking where volume-weighted price has developed from an anchor
[*]Comparing current price to anchored average value
[*]Observing whether price is staying near VWAP or expanding away from it
[*]Viewing optional VWAP band structure
[*]Comparing overall VWAP behavior with the most recent half of the anchor period
[/list]

[b]Notes[/b]

[list]
[*]This script is intended as a charting and analysis tool.
[*]The flatness and trend labels describe measured VWAP behavior, not guarantees.
[*]Different symbols, timeframes, and anchor periods can produce very different readings.
[/list]

[b]Summary[/b]

This script combines anchored VWAP logic, optional bands, and a two-part flatness/trend readout into one tool. Its goal is to help you study where weighted price has developed, how price is behaving around that value, and whether the VWAP itself has remained relatively flat or become more directional over the active anchor period.

## Source Code

````pine
//@version=6
indicator("VWAP Auto Anchored Trend", shorttitle = "VWAP AA Trend", overlay = true, max_bars_back = 5000)

// TradingView documents that the built-in VWAP Auto Anchored indicator is not
// written in Pine and its source cannot be inspected. This script reproduces
// the documented behavior as closely as Pine allows, with the current-period
// display matching the built-in for time-based anchors like the Month setting
// shown in your screenshots.

string groupInputs = "Inputs"
string groupBands = "Bands Settings"
string groupFlatness = "VWAP Flatness"

string anchorPeriodInput = input.string("Month", "Anchor Period", options = ["Auto", "Highest High", "Lowest Low", "Highest Volume", "Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group = groupInputs)
int lengthInput = input.int(14, "Length", minval = 1, group = groupInputs)
srcInput = input.source(hlc3, "Source", group = groupInputs)
string bandsModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = groupBands)
bool band1Enabled = input.bool(false, "Bands Multiplier #1", inline = "band1", group = groupBands)
float bandMult1 = input.float(1.0, "", minval = 0.0, step = 0.25, inline = "band1", group = groupBands)
bool band2Enabled = input.bool(false, "Bands Multiplier #2", inline = "band2", group = groupBands)
float bandMult2 = input.float(2.0, "", minval = 0.0, step = 0.25, inline = "band2", group = groupBands)
bool band3Enabled = input.bool(false, "Bands Multiplier #3", inline = "band3", group = groupBands)
float bandMult3 = input.float(3.0, "", minval = 0.0, step = 0.25, inline = "band3", group = groupBands)
int offsetInput = input.int(0, "Offset", group = groupInputs)
bool showFlatnessTable = input.bool(true, "Show Flatness Table", group = groupFlatness)
int flatnessAtrLength = input.int(14, "ATR Length", minval = 1, group = groupFlatness)
float veryFlatThreshold = input.float(0.25, "Very Flat Threshold", minval = 0.0, step = 0.05, group = groupFlatness)
float flatThreshold = input.float(0.50, "Flat Threshold", minval = 0.0, step = 0.05, group = groupFlatness)
float moderateThreshold = input.float(1.00, "Moderate Threshold", minval = 0.0, step = 0.05, group = groupFlatness)
float trendingThreshold = input.float(1.50, "Trending Threshold", minval = 0.0, step = 0.05, group = groupFlatness)

int lastYear = year(last_bar_time)
int lastMonth = month(last_bar_time)
int lastDay = dayofmonth(last_bar_time)
int lastWeek = weekofyear(last_bar_time)
int lastQuarter = int(math.ceil(lastMonth / 3.0))
int lastDecade = int(math.floor(lastYear / 10.0))
int lastCentury = int(math.floor(lastYear / 100.0))

int currQuarter = int(math.ceil(month / 3.0))
int currDecade = int(math.floor(year / 10.0))
int currCentury = int(math.floor(year / 100.0))

resolveAutoAnchor() =>
    timeframe.isintraday ? "Session" :
     timeframe.isdaily and timeframe.multiplier == 1 ? "Month" :
     timeframe.isdaily and timeframe.multiplier >= 2 and timeframe.multiplier <= 10 ? "Quarter" :
     timeframe.isdaily and timeframe.multiplier >= 11 and timeframe.multiplier <= 60 ? "Year" :
     "Decade"

string resolvedAnchor = anchorPeriodInput == "Auto" ? resolveAutoAnchor() : anchorPeriodInput

bool newSession = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMonth = ta.change(time("M")) != 0
bool newQuarter = ta.change(time("3M")) != 0
bool newYear = ta.change(time("12M")) != 0
bool newDecade = currDecade != currDecade[1]
bool newCentury = currCentury != currCentury[1]

float earningsData = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol = true)
float dividendsData = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol = true)
float splitsData = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol = true)

bool earningsAnchor = not na(earningsData)
bool dividendsAnchor = not na(dividendsData)
bool splitsAnchor = not na(splitsData)
bool highestHighAnchor = ta.highestbars(high, lengthInput) == 0 and ta.highestbars(high, lengthInput)[1] != 0
bool lowestLowAnchor = ta.lowestbars(low, lengthInput) == 0 and ta.lowestbars(low, lengthInput)[1] != 0
bool highestVolumeAnchor = ta.highestbars(volume, lengthInput) == 0 and ta.highestbars(volume, lengthInput)[1] != 0

bool inCurrentSession = year == lastYear and month == lastMonth and dayofmonth == lastDay
bool inCurrentWeek = year == lastYear and weekofyear == lastWeek
bool inCurrentMonth = year == lastYear and month == lastMonth
bool inCurrentQuarter = year == lastYear and currQuarter == lastQuarter
bool inCurrentYear = year == lastYear
bool inCurrentDecade = currDecade == lastDecade
bool inCurrentCentury = currCentury == lastCentury

bool fixedCurrentPeriodAnchor = resolvedAnchor == "Session" or resolvedAnchor == "Week" or resolvedAnchor == "Month" or resolvedAnchor == "Quarter" or resolvedAnchor == "Year" or resolvedAnchor == "Decade" or resolvedAnchor == "Century"
bool inActivePeriod = switch resolvedAnchor
    "Session" => inCurrentSession
    "Week" => inCurrentWeek
    "Month" => inCurrentMonth
    "Quarter" => inCurrentQuarter
    "Year" => inCurrentYear
    "Decade" => inCurrentDecade
    "Century" => inCurrentCentury
    => false

bool anchorPulse = switch resolvedAnchor
    "Session" => inCurrentSession and not inCurrentSession[1]
    "Week" => inCurrentWeek and not inCurrentWeek[1]
    "Month" => inCurrentMonth and not inCurrentMonth[1]
    "Quarter" => inCurrentQuarter and not inCurrentQuarter[1]
    "Year" => inCurrentYear and not inCurrentYear[1]
    "Decade" => inCurrentDecade and not inCurrentDecade[1]
    "Century" => inCurrentCentury and not inCurrentCentury[1]
    "Highest High" => highestHighAnchor
    "Lowest Low" => lowestLowAnchor
    "Highest Volume" => highestVolumeAnchor
    "Earnings" => earningsAnchor
    "Dividends" => dividendsAnchor
    "Splits" => splitsAnchor
    => false

bool activeNow = fixedCurrentPeriodAnchor ? inActivePeriod : ta.barssince(anchorPulse) >= 0

float weightedPrice = srcInput * volume
float weightedPriceSq = srcInput * srcInput * volume

var float sumPV = na
var float sumV = na
var float sumP2V = na
var float anchorVwapValue = na
var int barsInAnchorPeriod = na

if activeNow
    sumPV := anchorPulse or na(sumPV[1]) ? weightedPrice : nz(sumPV[1]) + weightedPrice
    sumV := anchorPulse or na(sumV[1]) ? volume : nz(sumV[1]) + volume
    sumP2V := anchorPulse or na(sumP2V[1]) ? weightedPriceSq : nz(sumP2V[1]) + weightedPriceSq
    anchorVwapValue := anchorPulse or na(anchorVwapValue[1]) ? srcInput : anchorVwapValue[1]
    barsInAnchorPeriod := anchorPulse or na(barsInAnchorPeriod[1]) ? 1 : barsInAnchorPeriod[1] + 1
else
    sumPV := na
    sumV := na
    sumP2V := na
    anchorVwapValue := na
    barsInAnchorPeriod := na

float vwapValue = sumV > 0 ? sumPV / sumV : na
float variance = sumV > 0 ? math.max(sumP2V / sumV - vwapValue * vwapValue, 0.0) : na
float stdevValue = not na(variance) ? math.sqrt(variance) : na
float flatnessAtr = ta.atr(flatnessAtrLength)
float flatnessDrift = not na(vwapValue) and not na(anchorVwapValue) ? math.abs(vwapValue - anchorVwapValue) : na
float flatnessPercent = not na(flatnessDrift) and anchorVwapValue != 0 ? flatnessDrift / math.abs(anchorVwapValue) * 100.0 : na
float flatnessAtrScore = not na(flatnessDrift) and flatnessAtr > 0 ? flatnessDrift / flatnessAtr : na
float flatnessPerBarPercent = not na(flatnessPercent) and barsInAnchorPeriod > 0 ? flatnessPercent / barsInAnchorPeriod : na
int halfPeriodBars = not na(barsInAnchorPeriod) ? math.max(1, int(math.ceil(barsInAnchorPeriod / 2.0))) : na
float halfPeriodStartVwap = not na(halfPeriodBars) and halfPeriodBars > 1 ? vwapValue[halfPeriodBars - 1] : vwapValue
float halfPeriodDrift = not na(vwapValue) and not na(halfPeriodStartVwap) ? math.abs(vwapValue - halfPeriodStartVwap) : na
float halfPeriodPercent = not na(halfPeriodDrift) and halfPeriodStartVwap != 0 ? halfPeriodDrift / math.abs(halfPeriodStartVwap) * 100.0 : na
float halfPeriodAtrScore = not na(halfPeriodDrift) and flatnessAtr > 0 ? halfPeriodDrift / flatnessAtr : na
float halfPeriodPerBarPercent = not na(halfPeriodPercent) and halfPeriodBars > 0 ? halfPeriodPercent / halfPeriodBars : na

flatnessLabel(float score) =>
    na(score) ? "N/A" :
     score < veryFlatThreshold ? "VERY FLAT" :
     score < flatThreshold ? "FLAT" :
     score < moderateThreshold ? "MODERATE" :
     score < trendingThreshold ? "TRENDING" :
     "STRONG TREND"

flatnessColor(float score) =>
    na(score) ? color.gray :
     score < veryFlatThreshold ? color.rgb(72, 187, 120) :
     score < flatThreshold ? color.rgb(126, 211, 33) :
     score < moderateThreshold ? color.rgb(245, 166, 35) :
     score < trendingThreshold ? color.rgb(255, 107, 107) :
     color.rgb(208, 2, 27)

string flatnessText = flatnessLabel(flatnessAtrScore)
color flatnessBg = flatnessColor(flatnessAtrScore)
string halfPeriodText = flatnessLabel(halfPeriodAtrScore)
color halfPeriodBg = flatnessColor(halfPeriodAtrScore)

bandDistance(float multiplier) =>
    bandsModeInput == "Percentage" ? vwapValue * multiplier / 100.0 : stdevValue * multiplier

float upperBand1 = band1Enabled and not na(vwapValue) ? vwapValue + bandDistance(bandMult1) : na
float lowerBand1 = band1Enabled and not na(vwapValue) ? vwapValue - bandDistance(bandMult1) : na
float upperBand2 = band2Enabled and not na(vwapValue) ? vwapValue + bandDistance(bandMult2) : na
float lowerBand2 = band2Enabled and not na(vwapValue) ? vwapValue - bandDistance(bandMult2) : na
float upperBand3 = band3Enabled and not na(vwapValue) ? vwapValue + bandDistance(bandMult3) : na
float lowerBand3 = band3Enabled and not na(vwapValue) ? vwapValue - bandDistance(bandMult3) : na

color vwapColor = color.rgb(33, 150, 243)
color band1Color = color.rgb(76, 175, 80)
color band2Color = color.rgb(255, 127, 14)
color band3Color = color.rgb(192, 0, 0)

vwapPlot = plot(vwapValue, "VWAP", color = vwapColor, linewidth = 2, offset = offsetInput)
upper1Plot = plot(upperBand1, "Upper Band #1", color = band1Color, offset = offsetInput)
lower1Plot = plot(lowerBand1, "Lower Band #1", color = band1Color, offset = offsetInput)
upper2Plot = plot(upperBand2, "Upper Band #2", color = band2Color, offset = offsetInput)
lower2Plot = plot(lowerBand2, "Lower Band #2", color = band2Color, offset = offsetInput)
upper3Plot = plot(upperBand3, "Upper Band #3", color = band3Color, offset = offsetInput)
lower3Plot = plot(lowerBand3, "Lower Band #3", color = band3Color, offset = offsetInput)

float bgUpper = band3Enabled ? upperBand3 : band2Enabled ? upperBand2 : band1Enabled ? upperBand1 : na
float bgLower = band3Enabled ? lowerBand3 : band2Enabled ? lowerBand2 : band1Enabled ? lowerBand1 : na
bgUpperPlot = plot(bgUpper, "Background Upper", display = display.none, offset = offsetInput)
bgLowerPlot = plot(bgLower, "Background Lower", display = display.none, offset = offsetInput)
fill(bgUpperPlot, bgLowerPlot, title = "Background", color = color.new(color.silver, 92))

var table flatnessTable = table.new(position.bottom_right, 3, 5, border_width = 1)
if barstate.islast
    if showFlatnessTable
        table.cell(flatnessTable, 0, 0, "", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 1, 0, "All Period", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 2, 0, "1/2 Period", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 0, 1, "VWAP", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 1, 1, flatnessText, text_color = color.white, bgcolor = flatnessBg)
        table.cell(flatnessTable, 2, 1, halfPeriodText, text_color = color.white, bgcolor = halfPeriodBg)
        table.cell(flatnessTable, 0, 2, "ATR Score", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 1, 2, na(flatnessAtrScore) ? "N/A" : str.tostring(flatnessAtrScore, "#.##"), text_color = color.white, bgcolor = color.new(flatnessBg, 10))
        table.cell(flatnessTable, 2, 2, na(halfPeriodAtrScore) ? "N/A" : str.tostring(halfPeriodAtrScore, "#.##"), text_color = color.white, bgcolor = color.new(halfPeriodBg, 10))
        table.cell(flatnessTable, 0, 3, "Drift %", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 1, 3, na(flatnessPercent) ? "N/A" : str.tostring(flatnessPercent, "#.##") + "%", text_color = color.white, bgcolor = color.new(flatnessBg, 10))
        table.cell(flatnessTable, 2, 3, na(halfPeriodPercent) ? "N/A" : str.tostring(halfPeriodPercent, "#.##") + "%", text_color = color.white, bgcolor = color.new(halfPeriodBg, 10))
        table.cell(flatnessTable, 0, 4, "Per Bar %", text_color = color.white, bgcolor = color.rgb(58, 63, 74))
        table.cell(flatnessTable, 1, 4, na(flatnessPerBarPercent) ? "N/A" : str.tostring(flatnessPerBarPercent, "#.####") + "%", text_color = color.white, bgcolor = color.new(flatnessBg, 10))
        table.cell(flatnessTable, 2, 4, na(halfPeriodPerBarPercent) ? "N/A" : str.tostring(halfPeriodPerBarPercent, "#.####") + "%", text_color = color.white, bgcolor = color.new(halfPeriodBg, 10))
    else
        table.clear(flatnessTable, 0, 0, 2, 4)
````
