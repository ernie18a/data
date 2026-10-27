# NSE Indices ReBalancing & ReConstruction Days Plot 

- url: https://www.tradingview.com/script/Qj4Msnj0-NSE-Indices-ReBalancing-ReConstruction-Days-Plot/
- type: indicator
- pine_id: PUB;0145aa87f3794fde8905c28ac10fbcd7
- version: 1.0

## Description

This indicator is a specialized macro-timing tool built specifically for traders and investors operating in the Indian Equity Markets (NSE). It automatically calculates and projects the highly anticipated NSE Index Reconstruction and Rebalancing dates directly onto your chart, giving you months of advanced notice before major institutional flows hit the market.

Passive index funds, ETFs, and institutional players are mandated to adjust their portfolios to mirror changes in NSE indices (like the NIFTY 50, Bank Nifty, Midcap 150, etc.). These adjustments trigger billions of dollars in forced buying and selling, primarily during the closing auction of the Execution Day (the trading day immediately preceding the Effective Day). This script ensures you are never caught off guard by this engineered volatility.

What It Tracks

🔴 Reconstruction Days (March & September): Major structural changes to the indices. Companies are added or removed based on free-float market cap criteria. These days historically see the most extreme volume and volatility spikes.

🔵 Rebalancing Days (June & December): Routine adjustments to the weightages of existing index constituents. While constituents don't change, the weight adjustments still drive significant and predictable institutional block trades.

Key Features

Forward-Looking Projections: Automatically plots the next 4 upcoming events. It draws a shaded "Action Zone" spanning exactly from the Execution Day to the Effective Day.

Smart Visibility Controls: Keep your charts clean. You can restrict the indicator to only show on a specific symbol (defaulted to NSE:NIFTY) so it doesn't clutter your individual stock charts. You can also toggle visibility on/off for specific timeframes (Intraday, Daily, Weekly, Monthly).

Replay-Mode Safe: The symbol-matching logic is custom-built to survive TradingView's Replay Mode quirks, ensuring your backtesting remains uninterrupted.

Advanced Holiday & Weekend Logic: Built-in logic skips weekends and recognizes NSE market holidays, ensuring the projected Execution Day strictly lands on a valid, active trading session.

Dynamic Auto-Cleanup: The zones automatically delete themselves from your chart exactly 24 hours after the Effective Day concludes, keeping your live workspace clutter-free.

Adaptive Labeling: Clear, dynamically sized text labels hover exactly 2% above the current closing price, preventing any interference with your price action candles or moving averages.

How to Use This in Your Trading

Option Sellers & Swing Traders: Identify these zones to avoid holding unhedged directional overnight positions or short straddles going into an Execution Day, protecting your capital against sudden gaps or IV crushes.

Momentum & Equity Traders: Look for front-running opportunities in the weeks leading up to Reconstruction days as the broader market anticipates specific stock inclusions or exclusions.

Intraday Traders: Prepare for potential liquidity drains in the morning session of Execution Days, followed by extreme, directionless volume spikes post-3:00 PM IST as passive funds execute their Market-On-Close (MOC) orders.

Settings & Customization

Visibility Settings: Enable/disable symbol filtering, set your target ticker, and toggle specific timeframes.

Label Settings: Adjust the label sizes (Tiny, Small, Normal, Large, Huge) to perfectly fit your specific screen resolution and chart layout.

Protect your portfolio from forced institutional flows and trade the volatility with precision.

## Source Code

````pine
//@version=6
indicator("Forward NSE Recon & Rebal Zones", shorttitle="Index Zones", overlay=true)

// ==========================================
// USER INPUTS FOR CUSTOMIZATION
// ==========================================
grpVis = "Symbol Visibility"
enableSymFilter = input.bool(true, title="Only Show On:", inline="sym", group=grpVis)
targetSymbol = input.symbol("NSE:NIFTY", title="", inline="sym", group=grpVis)

grpTF = "Timeframe Visibility"
showIntraday = input.bool(true, title="Intraday", inline="tf1", group=grpTF)
showDaily = input.bool(true, title="Daily", inline="tf1", group=grpTF)
showWeekly = input.bool(true, title="Weekly", inline="tf1", group=grpTF)
showMonthly = input.bool(true, title="Monthly", inline="tf1", group=grpTF)

grpLbl = "Label Settings"
lblSizeStr = input.string("Normal", options=["Tiny", "Small", "Normal", "Large", "Huge"], title="Text Size", group=grpLbl)

// ==========================================
// VISIBILITY LOGIC (Replay-Proof)
// ==========================================
// Split the input symbol (e.g. "NSE:NIFTY") to extract just the ticker ("NIFTY")
string[] symParts = str.split(targetSymbol, ":")
string cleanTarget = array.size(symParts) > 1 ? array.get(symParts, 1) : targetSymbol

// Check both the strict ID and the clean ticker to survive Replay Mode modifications
bool isCorrectSymbol = not enableSymFilter or (syminfo.tickerid == targetSymbol) or (syminfo.ticker == cleanTarget)

// Check if the current chart timeframe is enabled in settings
bool isCorrectTF = (showIntraday and timeframe.isintraday) or 
                   (showDaily and timeframe.isdaily) or 
                   (showWeekly and timeframe.isweekly) or 
                   (showMonthly and timeframe.ismonthly)

bool allowPlotting = isCorrectSymbol and isCorrectTF

// ==========================================
// TRACKING ARRAYS (Prevents overlap on live ticks)
// ==========================================
var line[] drawnLines = array.new_line()
var label[] drawnLabels = array.new_label()
var linefill[] drawnFills = array.new_linefill()

// ==========================================
// HELPER FUNCTIONS
// ==========================================
getLabelSize(string sizeStr) =>
    sizeStr == "Tiny" ? size.tiny : sizeStr == "Small" ? size.small : sizeStr == "Large" ? size.large : sizeStr == "Huge" ? size.huge : size.normal

getMonthString(int m) =>
    m == 1 ? "Jan" : m == 2 ? "Feb" : m == 3 ? "Mar" : m == 4 ? "Apr" : m == 5 ? "May" : m == 6 ? "Jun" : m == 7 ? "Jul" : m == 8 ? "Aug" : m == 9 ? "Sept" : m == 10 ? "Oct" : m == 11 ? "Nov" : "Dec"

// Calculates exactly how many days are in a given month (handles Leap Years)
getDaysInMonth(int y, int m) =>
    bool isLeap = (y % 4 == 0 and (y % 100 != 0 or y % 400 == 0))
    int days = m == 2 ? (isLeap ? 29 : 28) : (m == 4 or m == 6 or m == 9 or m == 11) ? 30 : 31
    days

isNSEHoliday(int y, int m, int d) =>
    bool holiday = false
    if y == 2026
        if (m == 1 and (d == 15 or d == 26)) or
           (m == 3 and (d == 3 or d == 26 or d == 31)) or // Explicitly skips holidays
           (m == 4 and (d == 3 or d == 14)) or
           (m == 5 and (d == 1 or d == 28)) or
           (m == 6 and (d == 26)) or
           (m == 9 and d == 14) or
           (m == 10 and (d == 2 or d == 20)) or
           (m == 11 and (d == 10 or d == 24)) or
           (m == 12 and d == 25)
            holiday := true
    holiday

// Rolls backward 1 day at a time until it finds a valid trading day
getPreviousTradingDay(int currentTime) =>
    int testTime = currentTime - 86400000 // Start exactly 1 day prior
    bool validDayFound = false
    
    for i = 1 to 15 // Safety limit loop
        if validDayFound
            break
            
        int cy = year(testTime, "Asia/Kolkata")
        int cm = month(testTime, "Asia/Kolkata")
        int cd = dayofmonth(testTime, "Asia/Kolkata")
        int dw = dayofweek(testTime, "Asia/Kolkata")
        
        // Skip Weekends and Holidays
        if dw == 1 or dw == 7 or isNSEHoliday(cy, cm, cd)
            testTime := testTime - 86400000
            continue
            
        validDayFound := true
    testTime

// Finds the absolute last active trading day of a specific month
getLastTradingDayOfMonth(int y, int m) =>
    int daysInM = getDaysInMonth(y, m)
    
    // Anchored to 09:15 AM to match NSE daily bar open times. 
    int testTime = timestamp("Asia/Kolkata", y, m, daysInM, 9, 15)
    
    bool validDayFound = false
    for i = 0 to 15 // Start checking at i=0 (the current day)
        if validDayFound
            break
            
        int cy = year(testTime, "Asia/Kolkata")
        int cm = month(testTime, "Asia/Kolkata")
        int cd = dayofmonth(testTime, "Asia/Kolkata")
        int dw = dayofweek(testTime, "Asia/Kolkata")
        
        if dw == 1 or dw == 7 or isNSEHoliday(cy, cm, cd)
            testTime := testTime - 86400000 // Roll back 1 day
            continue
            
        validDayFound := true
    testTime

// ==========================================
// DRAWING LOGIC (ZONES & LABELS)
// ==========================================
if barstate.islast
    // 1. CLEANUP: Delete all previously drawn objects from the last tick
    if array.size(drawnLines) > 0
        for i = 0 to array.size(drawnLines) - 1
            line.delete(array.get(drawnLines, i))
        array.clear(drawnLines)
        
    if array.size(drawnFills) > 0
        for i = 0 to array.size(drawnFills) - 1
            linefill.delete(array.get(drawnFills, i))
        array.clear(drawnFills)
        
    if array.size(drawnLabels) > 0
        for i = 0 to array.size(drawnLabels) - 1
            label.delete(array.get(drawnLabels, i))
        array.clear(drawnLabels)

    // 2. PLOTTING: Calculate and plot the next 4 events ONLY if filters pass
    if allowPlotting
        int currentY = year(time)
        int currentM = month(time)
        int plottedCount = 0
        float latestClose = close

        for i = 0 to 24
            int checkM = currentM + i
            int targetY = currentY + int((checkM - 1) / 12)
            int targetM = (checkM - 1) % 12 + 1

            if targetM == 3 or targetM == 6 or targetM == 9 or targetM == 12
                
                // Effective Date
                int effectiveTime = getLastTradingDayOfMonth(targetY, targetM)
                
                // Execution Date
                int executionTime = getPreviousTradingDay(effectiveTime)

                // Only plot if we haven't passed the Effective Date yet
                if time < effectiveTime + 86400000
                    bool isRecon = (targetM == 3 or targetM == 9)
                    
                    // Hardcoded Line Rules applied here
                    color baseColor = isRecon ? color.red : color.blue
                    color lineColor = color.new(baseColor, 80) // 80 Transparency
                    color fillColor = color.new(baseColor, 85) // Fill slightly more transparent
                    
                    // Draw lines and push to tracking arrays (Solid line, width 2)
                    line1 = line.new(x1=executionTime, y1=low, x2=executionTime, y2=high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=line.style_solid, width=2)
                    array.push(drawnLines, line1)
                    
                    line2 = line.new(x1=effectiveTime, y1=low, x2=effectiveTime, y2=high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=line.style_solid, width=2)
                    array.push(drawnLines, line2)
                    
                    linefill fill = linefill.new(line1, line2, color=fillColor)
                    array.push(drawnFills, fill)

                    // Format Label
                    string formatDay = str.tostring(dayofmonth(effectiveTime, "Asia/Kolkata"))
                    string formatMonth = getMonthString(targetM)
                    string formatYear = str.tostring(targetY)
                    
                    string lblDate = formatDay + " " + formatMonth + " " + formatYear
                    
                    // Formatted with INDICES on top and text strictly centered
                    string lblText = isRecon ? "INDEX\nReconstruction Day\n" + lblDate : "INDEX\nRebalancing Day\n" + lblDate
                    
                    // Fetch dynamic label size from user inputs
                    string lblSize = getLabelSize(lblSizeStr)
                    
                    // Dynamic label color (Solid for readability)
                    color lblBgCol = baseColor
                    
                    // Set Label Position 2% above the closing price
                    float lblPos = latestClose * 1.02
                    
                    // Label style set to center, textalign set to align_center
                    lbl = label.new(x=effectiveTime, y=lblPos, text=lblText, xloc=xloc.bar_time, color=lblBgCol, textcolor=color.white, style=label.style_label_center, textalign=text.align_center, size=lblSize)
                    array.push(drawnLabels, lbl)

                    plottedCount += 1
                    if plottedCount >= 4
                        break
````
