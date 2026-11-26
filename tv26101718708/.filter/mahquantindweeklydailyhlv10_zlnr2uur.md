# MAHQuant_IND_WeeklyDailyHL_v1.0

- url: https://www.tradingview.com/script/zlNR2uuR-MAHQuant-IND-WeeklyDailyHL-v1-0/
- type: indicator
- pine_id: PUB;f62f967318614b94ba49b7fa147d9b4f
- version: 1.0

## Description

MAHQuant Weekly & Daily High-Low Levels

A professional price action indicator that automatically draws the previous week's and day's High/Low levels, as well as the current week's (Monday-Wednesday) range. It also includes a candle comparison feature to detect potential reversal signals.

🧠 HOW IT WORKS:

Weekly Levels (Previous Week):
• Retrieves the highest and lowest prices from the previous full trading week using request.security("W", ...)
• Draws horizontal lines at those levels
• Includes adjustable percentage offsets to create buffer zones
• Labels display the exact price value

Daily Levels (Previous Day):
• Retrieves the highest and lowest prices from the previous trading day using request.security("D", ...)
• Draws horizontal lines at those levels
• Includes adjustable percentage offsets
• Labels display the exact price value

Current Week Levels (Monday - Wednesday):
• Tracks the high and low from Monday, Tuesday, and Wednesday separately
• After Wednesday close, calculates the highest high and lowest low among these 3 days
• Draws a single range line for the entire current week
• Extends to the right for forward-looking reference

Candle Comparison Logic:
• Compares the current candle's wick size to the previous candle's wick size
• Identifies when the current candle is opposite in direction (e.g., red after green)
• Highlights when the current candle's wick is larger than the previous candle's wick
• This helps spot potential rejection or reversal patterns

Bar Coloring Logic:
• Green: Bullish candle with large body and high volume
• Light Green: Bullish candle with small body or low volume
• Red: Bearish candle with large body and high volume
• Orange: Bearish candle with small body or low volume

⚙️ HOW TO USE:

1. Set your broker's timezone in the "Timezone" input
2. Toggle Weekly/Daily/Current Week levels on/off
3. Adjust the offset percentages to create buffer zones
4. Enable "Candle Comparison" to spot rejection signals

⚠️ DISCLAIMER:
This script is for educational purposes only. Not financial advice. Past performance does not guarantee future results.

📌 VERSION: 1.0 | DEVELOPER: MAHQuant | UPDATED: August 2026

🙏 Special thanks to Mr. Amirreza Arya for his valuable educational insights that inspired this tool.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MAHQuant

//@version=6
indicator("MAHQuant_IND_WeeklyDailyHL_v1.0", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. INPUT SETTINGS
// ==========================================
groupTime = "⏰ Time & Session"
i_tz = input.string('UTC+3:30', title="Your Timezone", options=['UTC-11', 'UTC-10', 'UTC-9', 'UTC-8', 'UTC-7', 'UTC-6', 'UTC-5', 'UTC-4', 'UTC-3', 'UTC-2', 'UTC-1', 'UTC+0', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+3:30', 'UTC+4', 'UTC+4:30', 'UTC+5', 'UTC+5:30', 'UTC+6', 'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12'], group=groupTime)

tz_offset = switch i_tz
    'UTC-11'   => -11 * 3600
    'UTC-10'   => -10 * 3600
    'UTC-9'    => -9 * 3600
    'UTC-8'    => -8 * 3600
    'UTC-7'    => -7 * 3600
    'UTC-6'    => -6 * 3600
    'UTC-5'    => -5 * 3600
    'UTC-4'    => -4 * 3600
    'UTC-3'    => -3 * 3600
    'UTC-2'    => -2 * 3600
    'UTC-1'    => -1 * 3600
    'UTC+0'    => 0
    'UTC+1'    => 1 * 3600
    'UTC+2'    => 2 * 3600
    'UTC+3'    => 3 * 3600
    'UTC+3:30' => 3 * 3600 + 1800
    'UTC+4'    => 4 * 3600
    'UTC+4:30' => 4 * 3600 + 1800
    'UTC+5'    => 5 * 3600
    'UTC+5:30' => 5 * 3600 + 1800
    'UTC+6'    => 6 * 3600
    'UTC+7'    => 7 * 3600
    'UTC+8'    => 8 * 3600
    'UTC+9'    => 9 * 3600
    'UTC+10'   => 10 * 3600
    'UTC+11'   => 11 * 3600
    'UTC+12'   => 12 * 3600

adjust_time(_time) =>
    _time + tz_offset * 1000

// --- Weekly Inputs ---
groupWeekly = "📅 Weekly Levels (Previous)"
showWeeklyHigh = input.bool(true, "Show High", inline="w1", group=groupWeekly)
showWeeklyLow = input.bool(true, "Show Low", inline="w1", group=groupWeekly)
showWeeklyOffset = input.bool(true, "Offset", inline="w1", group=groupWeekly)
showWeeklyLabels = input.bool(true, "Labels", inline="w1", group=groupWeekly)
weeklyLineColor = input.color(color.green, "Color", inline="w2", group=groupWeekly)
weeklyLineWidth = input.int(2, "Width", minval=1, maxval=5, inline="w2", group=groupWeekly)
weeklyLineStyle = input.string("solid", "Style", options=["solid", "dotted", "dashed"], inline="w2", group=groupWeekly)
adjWeeklyHighPct = input.float(0.07, "High Offset (%)", step=0.01, group=groupWeekly)
adjWeeklyLowPct = input.float(0.07, "Low Offset (%)", step=0.01, group=groupWeekly)

// --- Daily Inputs ---
groupDaily = "📆 Daily Levels (Previous)"
showDailyHigh = input.bool(true, "Show High", inline="d1", group=groupDaily)
showDailyLow = input.bool(true, "Show Low", inline="d1", group=groupDaily)
showDailyOffset = input.bool(true, "Offset", inline="d1", group=groupDaily)
showDailyLabels = input.bool(true, "Labels", inline="d1", group=groupDaily)
dailyLineColor = input.color(color.orange, "Color", inline="d2", group=groupDaily)
dailyLineWidth = input.int(2, "Width", minval=1, maxval=5, inline="d2", group=groupDaily)
dailyLineStyle = input.string("solid", "Style", options=["solid", "dotted", "dashed"], inline="d2", group=groupDaily)
adjDailyHighPct = input.float(0.04, "High Offset (%)", step=0.01, group=groupDaily)
adjDailyLowPct = input.float(0.04, "Low Offset (%)", step=0.01, group=groupDaily)

// --- Current Week Inputs ---
groupCurrentWeek = "🗓️ Current Week Levels (Mon-Wed)"
showCurrentWeeklyHigh = input.bool(true, "Show High", inline="cw1", group=groupCurrentWeek)
showCurrentWeeklyLow = input.bool(true, "Show Low", inline="cw1", group=groupCurrentWeek)
showCurrentWeeklyOffset = input.bool(true, "Offset", inline="cw1", group=groupCurrentWeek)
showCurrentWeeklyLabels = input.bool(true, "Labels", inline="cw1", group=groupCurrentWeek)
currentWeeklyLineColor = input.color(color.blue, "Color", inline="cw2", group=groupCurrentWeek)
currentWeeklyLineWidth = input.int(2, "Width", minval=1, maxval=5, inline="cw2", group=groupCurrentWeek)
currentWeeklyLineStyle = input.string("solid", "Style", options=["solid", "dotted", "dashed"], inline="cw2", group=groupCurrentWeek)
adjCurrentHighPct = input.float(0.05, "High Offset (%)", step=0.01, group=groupCurrentWeek)
adjCurrentLowPct = input.float(0.05, "Low Offset (%)", step=0.01, group=groupCurrentWeek)

// --- Other Inputs ---
groupComparison = "🕯️ Candle Comparison"
enableComparison = input.bool(true, "Enable Candle Comparison", group=groupComparison)
bearishColor = input.color(color.red, "Bearish Signal Color", group=groupComparison)
bullishColor = input.color(color.green, "Bullish Signal Color", group=groupComparison)
showLastBars = input.int(4, "Show Last N Bars", group=groupComparison)

groupVisuals = "🎨 Visuals & Branding"
showBarColor = input.bool(true, "Show MAHQuant Bar Color", group=groupVisuals)
showSignature = input.bool(true, "Show MAHQuant Signature", group=groupVisuals)

signatureGroup = '🖋️ MAHQuant Signature Controls'
vPos = input.string('top', 'Vertical Position', options = ['top', 'middle', 'bottom'], group = signatureGroup)
hPos = input.string('center', 'Horizontal Position', options = ['left', 'center', 'right'], group = signatureGroup)

// ==========================================
// 2. HELPER VARIABLES
// ==========================================
var line weeklyHighLine = na
var line weeklyLowLine = na
var line adjWeeklyHighLine = na
var line adjWeeklyLowLine = na
var label weeklyHighLabel = na
var label weeklyLowLabel = na

var line dailyHighLine = na
var line dailyLowLine = na
var line adjDailyHighLine = na
var line adjDailyLowLine = na
var label dailyHighLabel = na
var label dailyLowLabel = na

var line curHighLine = na
var line curLowLine = na
var line curAdjHighLine = na
var line curAdjLowLine = na
var label curHighLabel = na
var label curLowLabel = na

var float monHigh = na
var float monLow = na
var float tueHigh = na
var float tueLow = na
var float wedHigh = na
var float wedLow = na

// ==========================================
// 3. CORE LOGIC: WEEKLY & DAILY LEVELS
// ==========================================
prevWeeklyHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
prevWeeklyLow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
prevDailyHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDailyLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

startTimeWeekly = request.security(syminfo.tickerid, "W", time[1], lookahead=barmerge.lookahead_on)
startTimeDaily = request.security(syminfo.tickerid, "D", time[1], lookahead=barmerge.lookahead_on)

wHighOffset = prevWeeklyHigh * (adjWeeklyHighPct / 100)
wLowOffset = prevWeeklyLow * (adjWeeklyLowPct / 100)
dHighOffset = prevDailyHigh * (adjDailyHighPct / 100)
dLowOffset = prevDailyLow * (adjDailyLowPct / 100)

if not na(prevWeeklyHigh) and not na(prevWeeklyLow)
    if showWeeklyHigh
        line.delete(weeklyHighLine)
        weeklyHighLine := line.new(startTimeWeekly, prevWeeklyHigh, time, prevWeeklyHigh, xloc=xloc.bar_time, color=weeklyLineColor, width=weeklyLineWidth, style=weeklyLineStyle == "solid" ? line.style_solid : weeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        label.delete(weeklyHighLabel)
        if showWeeklyLabels
            weeklyHighLabel := label.new(bar_index + 10, prevWeeklyHigh, text="Last Week High\n" + str.tostring(prevWeeklyHigh, format.mintick), style=label.style_label_left, color=color.new(weeklyLineColor, 70), textcolor=weeklyLineColor, size=size.small)
        line.delete(adjWeeklyHighLine)
        if showWeeklyOffset
            adjWeeklyHighLine := line.new(startTimeWeekly, prevWeeklyHigh - wHighOffset, time, prevWeeklyHigh - wHighOffset, xloc=xloc.bar_time, color=color.new(weeklyLineColor, 50), width=weeklyLineWidth, style=weeklyLineStyle == "solid" ? line.style_solid : weeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
    
    if showWeeklyLow
        line.delete(weeklyLowLine)
        weeklyLowLine := line.new(startTimeWeekly, prevWeeklyLow, time, prevWeeklyLow, xloc=xloc.bar_time, color=weeklyLineColor, width=weeklyLineWidth, style=weeklyLineStyle == "solid" ? line.style_solid : weeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        label.delete(weeklyLowLabel)
        if showWeeklyLabels
            weeklyLowLabel := label.new(bar_index + 10, prevWeeklyLow, text="Last Week Low\n" + str.tostring(prevWeeklyLow, format.mintick), style=label.style_label_left, color=color.new(weeklyLineColor, 70), textcolor=weeklyLineColor, size=size.small)
        line.delete(adjWeeklyLowLine)
        if showWeeklyOffset
            adjWeeklyLowLine := line.new(startTimeWeekly, prevWeeklyLow + wLowOffset, time, prevWeeklyLow + wLowOffset, xloc=xloc.bar_time, color=color.new(weeklyLineColor, 50), width=weeklyLineWidth, style=weeklyLineStyle == "solid" ? line.style_solid : weeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)

if not na(prevDailyHigh) and not na(prevDailyLow)
    if showDailyHigh
        line.delete(dailyHighLine)
        dailyHighLine := line.new(startTimeDaily, prevDailyHigh, time, prevDailyHigh, xloc=xloc.bar_time, color=dailyLineColor, width=dailyLineWidth, style=dailyLineStyle == "solid" ? line.style_solid : dailyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        label.delete(dailyHighLabel)
        if showDailyLabels
            dailyHighLabel := label.new(bar_index + 10, prevDailyHigh, text="Last Day High\n" + str.tostring(prevDailyHigh, format.mintick), style=label.style_label_left, color=color.new(dailyLineColor, 70), textcolor=dailyLineColor, size=size.small)
        line.delete(adjDailyHighLine)
        if showDailyOffset
            adjDailyHighLine := line.new(startTimeDaily, prevDailyHigh - dHighOffset, time, prevDailyHigh - dHighOffset, xloc=xloc.bar_time, color=color.new(dailyLineColor, 50), width=dailyLineWidth, style=dailyLineStyle == "solid" ? line.style_solid : dailyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
    
    if showDailyLow
        line.delete(dailyLowLine)
        dailyLowLine := line.new(startTimeDaily, prevDailyLow, time, prevDailyLow, xloc=xloc.bar_time, color=dailyLineColor, width=dailyLineWidth, style=dailyLineStyle == "solid" ? line.style_solid : dailyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        label.delete(dailyLowLabel)
        if showDailyLabels
            dailyLowLabel := label.new(bar_index + 10, prevDailyLow, text="Last Day Low\n" + str.tostring(prevDailyLow, format.mintick), style=label.style_label_left, color=color.new(dailyLineColor, 70), textcolor=dailyLineColor, size=size.small)
        line.delete(adjDailyLowLine)
        if showDailyOffset
            adjDailyLowLine := line.new(startTimeDaily, prevDailyLow + dLowOffset, time, prevDailyLow + dLowOffset, xloc=xloc.bar_time, color=color.new(dailyLineColor, 50), width=dailyLineWidth, style=dailyLineStyle == "solid" ? line.style_solid : dailyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)

// ==========================================
// 4. CORE LOGIC: CURRENT WEEK (MON-WED)
// ==========================================
if dayofweek == dayofweek.sunday
    line.delete(curHighLine)
    line.delete(curLowLine)
    line.delete(curAdjHighLine)
    line.delete(curAdjLowLine)
    label.delete(curHighLabel)
    label.delete(curLowLabel)
    monHigh := na
    monLow := na
    tueHigh := na
    tueLow := na
    wedHigh := na
    wedLow := na

if dayofweek == dayofweek.monday
    monHigh := request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
    monLow := request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)

if dayofweek == dayofweek.tuesday
    tueHigh := request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
    tueLow := request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)

if dayofweek == dayofweek.wednesday
    wedHigh := request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
    wedLow := request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)

if dayofweek == dayofweek.thursday and not na(monHigh) and not na(tueHigh) and not na(wedHigh)
    highestHigh = math.max(monHigh, tueHigh, wedHigh)
    lowestLow = math.min(monLow, tueLow, wedLow)
    
    line.delete(curHighLine)
    line.delete(curLowLine)
    line.delete(curAdjHighLine)
    line.delete(curAdjLowLine)
    label.delete(curHighLabel)
    label.delete(curLowLabel)
    
    highOffsetVal = highestHigh * (1 - adjCurrentHighPct / 100)
    lowOffsetVal = lowestLow * (1 + adjCurrentLowPct / 100)
    threeDaysSec = 3 * 24 * 60 * 60 * 1000
    
    if showCurrentWeeklyHigh
        curHighLine := line.new(adjust_time(time) - threeDaysSec, highestHigh, adjust_time(time), highestHigh, xloc=xloc.bar_time, color=currentWeeklyLineColor, width=currentWeeklyLineWidth, style=currentWeeklyLineStyle == "solid" ? line.style_solid : currentWeeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        if showCurrentWeeklyLabels
            curHighLabel := label.new(bar_index + 10, highestHigh, text="Current Week High\n" + str.tostring(highestHigh, format.mintick), style=label.style_label_left, color=color.new(currentWeeklyLineColor, 70), textcolor=currentWeeklyLineColor, size=size.small)
        if showCurrentWeeklyOffset
            curAdjHighLine := line.new(adjust_time(time) - threeDaysSec, highOffsetVal, adjust_time(time), highOffsetVal, xloc=xloc.bar_time, color=color.new(currentWeeklyLineColor, 50), width=currentWeeklyLineWidth, style=currentWeeklyLineStyle == "solid" ? line.style_solid : currentWeeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        
    if showCurrentWeeklyLow
        curLowLine := line.new(adjust_time(time) - threeDaysSec, lowestLow, adjust_time(time), lowestLow, xloc=xloc.bar_time, color=currentWeeklyLineColor, width=currentWeeklyLineWidth, style=currentWeeklyLineStyle == "solid" ? line.style_solid : currentWeeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)
        if showCurrentWeeklyLabels
            curLowLabel := label.new(bar_index + 10, lowestLow, text="Current Week Low\n" + str.tostring(lowestLow, format.mintick), style=label.style_label_left, color=color.new(currentWeeklyLineColor, 70), textcolor=currentWeeklyLineColor, size=size.small)
        if showCurrentWeeklyOffset
            curAdjLowLine := line.new(adjust_time(time) - threeDaysSec, lowOffsetVal, adjust_time(time), lowOffsetVal, xloc=xloc.bar_time, color=color.new(currentWeeklyLineColor, 50), width=currentWeeklyLineWidth, style=currentWeeklyLineStyle == "solid" ? line.style_solid : currentWeeklyLineStyle == "dotted" ? line.style_dotted : line.style_dashed, extend=extend.right)

// ==========================================
// 5. CANDLE COMPARISON LOGIC
// ==========================================
float size1 = na
float size2 = na
bool isOpposite = false
bool isSize1Bigger = false

if enableComparison
    size1 := open > close ? math.abs(high - close) : math.abs(low - close)
    size2 := open[1] > close[1] ? math.abs(high[1] - close[1]) : math.abs(low[1] - close[1])
    
    isOpposite := (open < close and open[1] > close[1]) or (open > close and open[1] < close[1])
    isSize1Bigger := size1 > size2

plotshape(enableComparison and isOpposite and isSize1Bigger and open > close, location=location.abovebar, style=shape.triangledown, color=bearishColor, size=size.small, title="Bearish Rejection", show_last=showLastBars)
plotshape(enableComparison and isOpposite and isSize1Bigger and open < close, location=location.belowbar, style=shape.triangleup, color=bullishColor, size=size.small, title="Bullish Rejection", show_last=showLastBars)

// ==========================================
// 6. MAHQUANT BAR COLOR (Optimized)
// ==========================================
colorGreen      = color.new(#008000, 0)
colorLightGreen = color.new(#00ff0c, 80)
colorRed        = color.new(#ff0317, 0)
colorOrange     = color.new(color.orange, 0)

isGreen      = close > open
isRed        = close < open
isBigBody    = math.abs(close - open) / math.abs(high - low) > 0.15
isSmallBody  = math.abs(close - open) / math.abs(high - low) <= 0.15
isHighVolume = volume > ta.sma(volume, 40)
isLowVolume  = volume < ta.sma(volume, 40)

candleColor = isGreen and isBigBody and isHighVolume ? colorGreen :
              isGreen and isSmallBody and isLowVolume ? colorLightGreen :
              isRed and isBigBody and isHighVolume ? colorRed :
              isRed and isSmallBody and isLowVolume ? colorOrange :
              isGreen and isLowVolume ? colorLightGreen : colorOrange

barcolor(showBarColor ? candleColor : na)

// ==========================================
// 7. MAHQUANT SIGNATURE
// ==========================================
title = '⚡ MAHQuant'
subtitle = 'MINDSET  |  AWARENESS  |  HARMONY'
symbolInfo = syminfo.ticker + ' | ' + timeframe.period + (timeframe.isminutes ? 'M' : '')
dateInfo = str.tostring(dayofmonth(time_close)) + '/' + str.tostring(month(time_close)) + '/' + str.tostring(year(time_close))

width = 0
height = 0
bgColor = color.new(color.blue, 90)
titleColor = color.new(color.black, 0)
titleSize = 'large'
titleAlign = 'center'
subtitleColor = color.new(color.black, 30)
subtitleSize = 'normal'
subtitleAlign = 'center'
infoColor = color.new(color.black, 30)
infoSize = 'small'
infoAlign = 'center'

if showSignature
    mahTable = table.new(vPos + '_' + hPos, 1, 3)
    table.cell(mahTable, 0, 0, title, width, height, titleColor, titleAlign, text_size = titleSize, bgcolor = bgColor)
    table.cell(mahTable, 0, 1, subtitle, width, height, subtitleColor, subtitleAlign, text_size = subtitleSize, bgcolor = bgColor)
    table.cell(mahTable, 0, 2, symbolInfo + ' | ' + dateInfo, width, height, infoColor, infoAlign, text_size = infoSize, bgcolor = bgColor)

// ==========================================
````
