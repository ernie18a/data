<!-- tradingview-pine-id: PUB;92a41589ac53447aa778f84ef4baba85 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Monday High & Low - Pro

Source: https://www.tradingview.com/script/r7iy6vmD-Monday-High-Low-Pro/

## Description

Welcome to the Monday Range & Liquidity Sweeps indicator, a powerful and clean tool designed specifically for Range Traders and Smart Money Concepts (SMC) enthusiasts.

📊 The Core Concept:
According to market data and price action algorithms, the first day of the trading week sets the tone.

Monday High acts as a major Resistance and a pool of Buy-Side Liquidity (BSL).

Monday Low acts as a strong Support and a pool of Sell-Side Liquidity (SSL).

💡 How to Trade with this Indicator:
This indicator automatically plots the Monday High and Low from the exact candles they were formed, extending cleanly to the right. You can use these levels to trade high-probability liquidity sweeps:

🐻 Bearish Setup (Short): Wait for the market to sweep the Monday High (grabbing liquidity). If the price fails to hold above and closes back inside the Monday range, it indicates a false breakout. You can enter a short position targeting the opposite liquidity pool: the Monday Low.

🐂 Bullish Setup (Long): Wait for the market to sweep the Monday Low. If the price rejects and closes back inside the Monday range, the bearish momentum is likely trapped. You can enter a long position targeting the opposite liquidity pool: the Monday High.

⚙️ Key Features (Pro Customization):

Custom Timezone (UTC Offset): Manually input your UTC offset in the settings to align the Monday range perfectly with your trading session (e.g., New York, London, or Local Time).

Clean Visuals: Adjust line thickness, color, transparency, and style (Solid, Dotted, Dashed) so it blends perfectly with your chart theme.

Minimalist Design: Only draws what you need. Labels and lines automatically extend without cluttering your historical price action.

Drop a like and leave a comment if this helps your trading week. Trade safe and always manage your risk!

---

## Source Code

````pine
//@version=6
indicator("Monday High & Low - Pro", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. TIMEZONE & HISTORY SETTINGS
// ==========================================
utcOffset = input.float(0.0, title="UTC Offset (e.g., -4, 5, 5.5)", step=0.5, minval=-12.0, maxval=14.0, group="Timezone & History")

// NAYA FEATURE: "Current Week" sab se pehle add kiya gaya hai
historyLimitInp = input.string("Current Week", title="Show History Data", options=["Current Week", "2 Weeks", "1 Month", "3 Months", "6 Months", "All Time", "Custom Range"], group="Timezone & History")

// ==========================================
// 2. CUSTOM DATE RANGE (CALENDAR)
// ==========================================
startDate = input.time(timestamp("01 Jan 2023 00:00 +0000"), title="Custom Start Date", group="Custom Date Range")
endDate = input.time(timestamp("31 Dec 2026 23:59 +0000"), title="Custom End Date", group="Custom Date Range")

// ==========================================
// 3. DESIGN & STYLE SETTINGS
// ==========================================
lineColor = input.color(color.black, title="Line & Text Color", group="Style Settings")
lineOpacity = input.int(30, title="Transparency (0=Dark, 100=Invisible)", minval=0, maxval=100, group="Style Settings")
lineWidth = input.int(1, title="Line Thickness (1 to 5)", minval=1, maxval=5, group="Style Settings")
lineStyleInp = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Style Settings")
labelPos = input.string("Right", title="Label Position", options=["Left", "Center", "Right"], group="Style Settings")

// Styling
finalColor = color.new(lineColor, lineOpacity)
finalStyle = lineStyleInp == "Solid" ? line.style_solid : lineStyleInp == "Dashed" ? line.style_dashed : line.style_dotted

// ==========================================
// 4. HISTORY LIMIT LOGIC (Updated with Current Week)
// ==========================================
bool inHistoryZone = true

if historyLimitInp == "Custom Range"
    inHistoryZone := (time >= startDate and time <= endDate)
else if historyLimitInp == "All Time"
    inHistoryZone := true
else
    // Current week ke liye pichle 7 din ka data limit lagaya hai
    limitInDays = historyLimitInp == "Current Week" ? 7 : historyLimitInp == "2 Weeks" ? 14 : historyLimitInp == "1 Month" ? 30 : historyLimitInp == "3 Months" ? 90 : 180
    inHistoryZone := ((timenow - time) / 86400000.0) <= limitInDays

// ==========================================
// 5. LOGIC & CALCULATION (Monday)
// ==========================================
var float monHigh = na
var float monLow = na
var int monHighBar = na
var int monLowBar = na

var line highLine = na
var line lowLine = na
var label highLabel = na
var label lowLabel = na

offsetMillis = int(utcOffset * 60 * 60 * 1000)
localTime = time + offsetMillis
prevLocalTime = na(time[1]) ? na : (time[1] + offsetMillis)

currentDay = dayofweek(localTime, "UTC")
prevDay = dayofweek(prevLocalTime, "UTC")

isNewMonday = currentDay == dayofweek.monday and prevDay != dayofweek.monday

if isNewMonday
    monHigh := high
    monLow := low
    monHighBar := bar_index
    monLowBar := bar_index
    
    if inHistoryZone
        highLine := line.new(x1=monHighBar, y1=monHigh, x2=bar_index, y2=monHigh, color=finalColor, width=lineWidth, style=finalStyle)
        lowLine := line.new(x1=monLowBar, y1=monLow, x2=bar_index, y2=monLow, color=finalColor, width=lineWidth, style=finalStyle)
        
        highLabel := label.new(x=bar_index, y=monHigh, text=" Monday High", style=label.style_none, textcolor=finalColor)
        lowLabel := label.new(x=bar_index, y=monLow, text=" Monday Low", style=label.style_none, textcolor=finalColor)

if currentDay == dayofweek.monday and not isNewMonday
    if high > monHigh
        monHigh := high
        monHighBar := bar_index
    if low < monLow
        monLow := low
        monLowBar := bar_index

// ==========================================
// 6. SATURDAY STOP & LABEL POSITION LOGIC
// ==========================================
bool extendLine = (currentDay == dayofweek.monday or currentDay == dayofweek.tuesday or currentDay == dayofweek.wednesday or currentDay == dayofweek.thursday or currentDay == dayofweek.friday)

endBar = bar_index + 3

if not na(highLine) and extendLine and inHistoryZone
    line.set_x1(highLine, monHighBar)
    line.set_y1(highLine, monHigh)
    line.set_x2(highLine, endBar)
    line.set_y2(highLine, monHigh)
    
    highX = labelPos == "Left" ? monHighBar : labelPos == "Center" ? int((monHighBar + endBar) / 2) : endBar
    label.set_x(highLabel, highX)
    label.set_y(highLabel, monHigh)
    
if not na(lowLine) and extendLine and inHistoryZone
    line.set_x1(lowLine, monLowBar)
    line.set_y1(lowLine, monLow)
    line.set_x2(lowLine, endBar)
    line.set_y2(lowLine, monLow)
    
    lowX = labelPos == "Left" ? monLowBar : labelPos == "Center" ? int((monLowBar + endBar) / 2) : endBar
    label.set_x(lowLabel, lowX)
    label.set_y(lowLabel, monLow)
````
