# Green Pen Indi by Wachi

- url: https://www.tradingview.com/script/WlSAVZKx/
- type: indicator
- pine_id: PUB;228a405b7f4145bf8a0a2282685db460
- version: 2.0

## Description

This indicator automatically plots the "1,000-Point Daily Range" (กรอบวัน 1000 จุด), a core technique from the Green Pen (แม่ปลาปากกาเขียว) trading system
. It is designed specifically for the XAUUSD (Gold) chart to help traders identify the daily starting range, minor pivot points, and daily support/resistance levels
.
How the Calculations Work: The indicator sets the daily reference point based on the 07:00 AM (UTC+7 / Thai Time) candle, which marks the daily opening/closing transition for reference brokers like Exness and City Index
.
Minor Support/Resistance (Middle Line / รับต้านย่อย): The script captures the 07:00 AM price, removes decimals, and rounds it to the nearest whole number ending in exactly 0 or 5
.
Daily Resistance (Top Line / แนวต้านวัน): Calculated by adding exactly 500 points ($5 for Gold) to the Middle Line
.
Daily Support (Bottom Line / แนวรับวัน): Calculated by subtracting exactly 500 points ($5 for Gold) from the Middle Line
. The total distance from the bottom line to the top line is exactly 1,000 points
.
How to Use This Indicator: This tool acts as a GPS for the day's trading, helping you observe how price interacts with key daily levels
.
Observe Price Action (PA): Watch how the price behaves when it tests these three lines. Do not blindly place orders just because the price touches a line
.
Smaller Timeframes for Entry: When the price approaches the Top, Middle, or Bottom line, drop down to the M1 or M5 timeframes to look for entry signals
. Wait for clear Price Action (PA) or a breakout before entering a trade
.
"Standing on the Frame" (ยืนกรอบ): If a 5-minute candle successfully closes above and holds a line (e.g., green candle closing above the resistance), the price is considered to be "standing on the frame" and has a high probability of continuing in that direction
.
Retests: If you miss the initial 07:00 AM move, wait for the price to retest the Daily Range lines (often around 07:50 AM to 08:00 AM as volume enters) to find a safer entry point
.
Recommended Settings:
Symbol: XAUUSD
Broker Feed: City Index or Exness are highly recommended to ensure the 07:00 AM candle closes align perfectly with the Green Pen system
.
User Inputs: You can toggle the anchor price between the "Open" and "Close" of the 07:00 AM candle depending on your preferred variation of the system.

## Source Code

````pine
//@version=6
indicator("Green Pen Indi by Wachi", overlay=true)

// =============================================================================
// INPUT SETTINGS
// =============================================================================

priceSource = input.string("Open", title="Price Source at 07:00 AM UTC+7", options=["Open", "Close"])
topLineColor = input(color.red, title="Top Line Color (Resistance)")
midLineColor = input(color.purple, title="Middle Line Color (Baseline)")
botLineColor = input(color.green, title="Bottom Line Color (Support)")
lineWidth = input.int(1, title="Line Width", minval=1, maxval=5)
showLabels = input(true, title="Show Price Labels")
labelSizeTop = input.string("normal", title="Top Label Text Size", options=["tiny", "small", "normal", "large"])
labelSizeMiddle = input.string("small", title="Middle Label Text Size", options=["tiny", "small", "normal", "large"])
labelSizeBottom = input.string("small", title="Bottom Label Text Size", options=["tiny", "small", "normal", "large"])
timezoneOffset = input.int(7, title="Timezone Offset (hours)", minval=-12, maxval=12)
showDebug = input(false, title="Show Debug Table")

// =============================================================================
// CORE LOGIC
// =============================================================================

// Function: Round price to nearest whole number ending in 0 or 5
roundToNearestFiveOrZero(price) =>
    math.round(price / 5) * 5

// FR-1 & FR-2: Capture the baseline price at 07:00 AM UTC+7
var priceAt7AM = close

// Check for 07:00 AM with timezone offset
currentHour = (hour + timezoneOffset) % 24
is07AM = currentHour == 7 and minute == 0

// Capture price when 7am occurs
if is07AM
    priceAt7AM := priceSource == "Open" ? open : close

// FR-3: Round to nearest 0 or 5 (Middle Line)
middleLineValue = roundToNearestFiveOrZero(priceAt7AM)

// FR-4: Top Line = Middle Line + 5 points
topLineValue = middleLineValue + 5

// FR-5: Bottom Line = Middle Line - 5 points
bottomLineValue = middleLineValue - 5


// =============================================================================
// VISUALIZATION
// =============================================================================

// Track lines and labels, reset them each day
var array<line> dailyLines = array.new<line>()
var array<label> dailyLabels = array.new<label>()
var isPlotted = false
var lastPlottedDate = -1

// Reset isPlotted and delete old lines/labels at the start of each new day
if dayofmonth != lastPlottedDate
    isPlotted := false
    lastPlottedDate := dayofmonth
    // Delete all previous day lines
    if array.size(dailyLines) > 0
        for i = 0 to array.size(dailyLines) - 1
            line.delete(array.get(dailyLines, i))
        array.clear(dailyLines)
    // Delete all previous day labels
    if array.size(dailyLabels) > 0
        for i = 0 to array.size(dailyLabels) - 1
            label.delete(array.get(dailyLabels, i))
        array.clear(dailyLabels)

// Debug table to show priceSource value
var table debugTable2 = na

// Session table
var table sessionTable = na

// Determine current session
getCurrentSession() =>
    hr = (hour + timezoneOffset) % 24
    if hr >= 5 and hr < 14
        "Asia"
    else if hr >= 14 and hr < 19
        "London"
    else
        "US"

currentSession = getCurrentSession()

if showDebug
    // Add more debug values
    if na(debugTable2)
        debugTable2 := table.new(position.bottom_right, 2, 6, border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)
    table.cell(debugTable2, 0, 0, "Daily Data", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 0, "ราคา", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 0, 1, "ราคาเปิด 7 โมงเช้า", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 1, str.tostring(priceAt7AM, "#.00"), text_color=color.yellow, bgcolor=color.black)
    table.cell(debugTable2, 0, 2, "บน", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 2, str.tostring(topLineValue, "#.00"), text_color=color.yellow, bgcolor=color.black)
    table.cell(debugTable2, 0, 3, "กลาง", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 3, str.tostring(middleLineValue, "#.00"), text_color=color.yellow, bgcolor=color.black)
    table.cell(debugTable2, 0, 4, "ล่าง", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 4, str.tostring(bottomLineValue, "#.00"), text_color=color.yellow, bgcolor=color.black)
    table.cell(debugTable2, 0, 5, "Session", text_color=color.white, bgcolor=color.black)
    table.cell(debugTable2, 1, 5, currentSession, text_color=color.yellow, bgcolor=color.black)

// Plot horizontal lines on the main chart using line.new() - only once per 07:00 AM
if is07AM and isPlotted != true
    isPlotted := true
    array.push(dailyLines, line.new(bar_index, topLineValue, bar_index + 10, topLineValue, extend=extend.right, color=topLineColor, width=lineWidth))
    array.push(dailyLines, line.new(bar_index, middleLineValue, bar_index + 10, middleLineValue, extend=extend.right, color=midLineColor, width=lineWidth))
    array.push(dailyLines, line.new(bar_index, bottomLineValue, bar_index + 10, bottomLineValue, extend=extend.right, color=botLineColor, width=lineWidth))
    
// Add labels with price values only on the last 07:00 AM bar
    if showLabels
        topSize = labelSizeTop == "tiny" ? size.tiny : labelSizeTop == "small" ? size.small : labelSizeTop == "normal" ? size.normal : size.large
        midSize = labelSizeMiddle == "tiny" ? size.tiny : labelSizeMiddle == "small" ? size.small : labelSizeMiddle == "normal" ? size.normal : size.large
        botSize = labelSizeBottom == "tiny" ? size.tiny : labelSizeBottom == "small" ? size.small : labelSizeBottom == "normal" ? size.normal : size.large
        array.push(dailyLabels, label.new(bar_index + 10, topLineValue, "Top Day " + str.tostring(topLineValue, "#.00"), yloc=yloc.price, textcolor=color.white, style=label.style_none, size=topSize))
        array.push(dailyLabels, label.new(bar_index + 10, middleLineValue, "Mid Day " + str.tostring(middleLineValue, "#.00"), yloc=yloc.price, textcolor=color.white, style=label.style_none, size=midSize))
        array.push(dailyLabels, label.new(bar_index + 10, bottomLineValue, "Bot Day " + str.tostring(bottomLineValue, "#.00"), yloc=yloc.price, textcolor=color.white, style=label.style_none, size=botSize))
````
