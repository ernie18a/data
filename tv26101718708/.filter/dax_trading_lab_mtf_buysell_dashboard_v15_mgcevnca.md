# DAX Trading Lab MTF BUY/SELL Dashboard v1.5

- url: https://www.tradingview.com/script/mGCevNcA-DAX-Trading-Lab-MTF-BUY-SELL-Dashboard-v1-5/
- type: indicator
- pine_id: PUB;6e74bf3ee232485aa7750829064d51bf
- version: 1.0

## Description

Unlock the power of the DAX40 with this precision M5 indicator, engineered specifically for high-frequency scalpers. Designed around the powerful Market Cycles framework, it seamlessly identifies key phases of Accumulation, Manipulation, and Distribution. Spot precise institutional traps and ride explosive distribution moves with absolute confidence and sharp clarity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
// © tiongsean 

//@version=6 
indicator("DAX Trading Lab MTF BUY/SELL Dashboard v1.5", overlay=true, max_lines_count=500) 

// --- Settings Inputs --- 
tablePos = input.string( 
     defval=position.top_right,  
     title="Dashboard Position",  
     options=[position.top_right, position.bottom_right, position.top_left, position.bottom_left, position.middle_right, position.middle_left], 
     group="Dashboard Appearance" 
     ) 

fontSizeOpt = input.string( 
     defval="Small", 
     title="Table Font Size", 
     options=["Tiny", "Small", "Normal", "Large"], 
     group="Dashboard Appearance" 
     ) 

// Map user font size selection to Pine Script constants 
chosenFontSize = fontSizeOpt == "Tiny" ? size.tiny : fontSizeOpt == "Small" ? size.small : fontSizeOpt == "Normal" ? size.normal : size.large 
titleFontSize  = fontSizeOpt == "Tiny" ? size.small : fontSizeOpt == "Small" ? size.normal : fontSizeOpt == "Normal" ? size.large : size.huge 

// --- Chart Overlay Toggles --- 
showVolLabels = input.bool(true, title="Show Volume Labels on Chart", group="Chart Overlay Settings") 
volLabelPos   = input.string(defval="Bottom of Chart", title="Volume Label Position", options=["Bottom of Chart", "Below Signal Bar"], group="Chart Overlay Settings")
volLabelColorOpt = input.color(defval=color.blue, title="Custom Volume Label Color (If not Dynamic)", group="Chart Overlay Settings")
useDynamicColors = input.bool(true, title="Use Dynamic Colors (Blue=Buy, Red=Sell)", group="Chart Overlay Settings")

// --- Volume Delta Filter Settings ---
useDeltaFilter  = input.bool(true, title="Enable Volume Delta Surge Filter", group="Volume Delta Filter Settings")
deltaMultiplier = input.float(1.5, title="Delta Surge Multiplier (vs Avg)", minval=0.5, step=0.1, group="Volume Delta Filter Settings")

// Custom Cross Window (5 Bars on M5 chart = 25 Mins)
macdWindow = input.int(5, title="MACD Sync Window (Bars/Mins Filter)", minval=1, tooltip="5 bars on M5 chart = 25 minutes", group="MACD Cross Settings")

// MACD 1 Inputs 
fast1   = input.int(5,   title="MACD 1 Fast Length",   group="MACD 1 Settings") 
slow1   = input.int(20,  title="MACD 1 Slow Length",   group="MACD 1 Settings") 
signal1 = input.int(9,   title="MACD 1 Signal Length", group="MACD 1 Settings") 

// MACD 2 Inputs 
fast2   = input.int(5,   title="MACD 2 Fast Length",   group="MACD 2 Settings") 
slow2   = input.int(20,  title="MACD 2 Slow Length",   group="MACD 2 Settings") 
signal2 = input.int(50,  title="MACD 2 Signal Length", group="MACD 2 Settings") 

// --- Trend Filter & Confirmation Window Options --- 
useEma10      = input.bool(true, title="Use EMA 10 Filter", group="Trend Filter Options") 
ema10Len      = input.int(10, title="EMA 10 Length", minval=1, group="Trend Filter Options") 
useEma20      = input.bool(true, title="Use EMA 20 Filter", group="Trend Filter Options") 
ema20Len      = input.int(20, title="EMA 20 Length", minval=1, group="Trend Filter Options") 
confirmWindow = input.int(3, title="Max Confirmation Candle Delay", minval=1, maxval=5, tooltip="Allows signal if price closes above/below filter within this many candles after MACD alignment", group="Trend Filter Options")

// --- Time Filter Inputs --- 
useTimeFilter = input.bool(true, title="Enable Signal Blackout Window", group="Signal Time Filter") 
startTime     = input.string("0200", title="Blackout Window Start (HHMM)", group="Signal Time Filter") 
endTime       = input.string("1445", title="Blackout Window End (HHMM)", group="Signal Time Filter") 
filterTZ      = input.string("GMT+8", title="Timezone for Filter", group="Signal Time Filter") 

// --- Signal Line Style Customization Inputs --- 
lineStyleOpt = input.string(defval="Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Signal Line Style Customization") 
lineWidth    = input.int(defval=2, title="Line Width", minval=1, maxval=5, group="Signal Line Style Customization") 
buyLineColor = input.color(defval=color.green, title="Buy Line Color", group="Signal Line Style Customization") 
sellLineColor= input.color(defval=color.red, title="Sell Line Color", group="Signal Line Style Customization") 

// Map the style string selection to actual Pine Script line style constants 
chosenStyle = lineStyleOpt == "Solid" ? line.style_solid : lineStyleOpt == "Dotted" ? line.style_dotted : line.style_dashed 

// --- Global Indicator Calculations --- 
[macdLine1, signalLine1, _] = ta.macd(close, fast1, slow1, signal1) 
[macdLine2, signalLine2, _] = ta.macd(close, fast2, slow2, signal2) 

// Trend filter: Local EMAs 
ema10 = ta.ema(close, ema10Len) 
ema20 = ta.ema(close, ema20Len) 

plot(useEma10 ? ema10 : na, color=color.orange, title="Filter EMA 10", linewidth=1) 
plot(useEma20 ? ema20 : na, color=color.blue, title="Filter EMA 20", linewidth=1) 

// --- Core Logic Functions --- 
checkDualMACD() => 
    int state1 = macdLine1 > signalLine1 ? 1 : macdLine1 < signalLine1 ? -1 : 0 
    int state2 = macdLine2 > signalLine2 ? 1 : macdLine2 < signalLine2 ? -1 : 0 
    [state1, state2] 

checkMACD1Change() => 
    macdLine1 > signalLine1 != macdLine1[1] > signalLine1[1] 

checkMACD2Change() => 
    macdLine2 > signalLine2 != macdLine2[1] > signalLine2[1] 

// Function to calculate volume metric tracking for any given timeframe 
calcVolumeMetrics() => 
    int state1 = macdLine1 > signalLine1 ? 1 : macdLine1 < signalLine1 ? -1 : 0 
    int state2 = macdLine2 > signalLine2 ? 1 : macdLine2 < signalLine2 ? -1 : 0 
    bool bothBuy  = (state1 == 1) and (state2 == 1) 
    bool bothSell = (state1 == -1) and (state2 == -1) 
     
    bool bTrigger = bothBuy and not(bothBuy[1]) 
    bool sTrigger = bothSell and not(bothSell[1]) 
     
    float cRange = high - low 
    float bVol = cRange == 0 ? 0.0 : volume * (close - low) / cRange 
    float sVol = cRange == 0 ? 0.0 : volume * (high - close) / cRange 
    float delta = bVol - sVol 
    [bTrigger, sTrigger, volume, bVol, sVol, delta] 

// --- Fetch Higher Timeframe Data --- 
[m30_S1, m30_S2] = request.security(syminfo.tickerid, "30",   checkDualMACD(), lookahead=barmerge.lookahead_off) 
[h1_S1,  h1_S2]  = request.security(syminfo.tickerid, "60",   checkDualMACD(), lookahead=barmerge.lookahead_off) 
[h2_S1,  h2_S2]  = request.security(syminfo.tickerid, "120", checkDualMACD(), lookahead=barmerge.lookahead_off) 
[h4_S1,  h4_S2]  = request.security(syminfo.tickerid, "240", checkDualMACD(), lookahead=barmerge.lookahead_off) 
[m5_S1,  m5_S2]  = checkDualMACD() 

// Fetch Volume Profiles per timeframe dynamically 
[m5BTrig, m5STrig, m5TotV, m5BuyV, m5SellV, m5DelV] = calcVolumeMetrics() 

// --- Volume Delta Logic & Confirmation Engine ---
avgDelta = ta.sma(math.abs(m5DelV), macdWindow)
strongDeltaSurge = math.abs(m5DelV) > (avgDelta * deltaMultiplier)
deltaBuyConfirm  = not useDeltaFilter or (m5DelV > 0 and strongDeltaSurge)
deltaSellConfirm = not useDeltaFilter or (m5DelV < 0 and strongDeltaSurge)

// --- Local M5 Signal Triggers & Chart Marking --- 
m5BothBuy  = (m5_S1 == 1) and (m5_S2 == 1) 
m5BothSell = (m5_S1 == -1) and (m5_S2 == -1) 

// Track the specific candle where the dual MACDs initially align
macdRawBuySetup  = m5BothBuy and not(m5BothBuy[1])
macdRawSellSetup = m5BothSell and not(m5BothSell[1])

// Measure structural lookback windows based on raw crossovers
barsSinceRawBuy  = ta.barssince(macdRawBuySetup)
barsSinceRawSell = ta.barssince(macdRawSellSetup)

// Global window boundary trackers to ensure alignment synchronization
barsSinceNotBuy  = ta.barssince(not m5BothBuy)
barsSinceNotSell = ta.barssince(not m5BothSell)

// Time tracking condition 
sessionString = startTime + "-" + endTime 
inBlackoutWindow = not na(time(timeframe.period, sessionString, filterTZ)) 
signalsAllowed = not (useTimeFilter and inBlackoutWindow) 

// Dynamic EMA Confirmation Rules based on inputs (Evaluated on current close)
priceConditionBuy  = (not useEma10 or close > ema10) and (not useEma20 or close > ema20) and (close > close[1]) 
priceConditionSell = (not useEma10 or close < ema10) and (not useEma20 or close < ema20) and (close < close[1]) 

// Anti-duplicate protection logic boundaries
var int lastBuyBar = 0
var int lastSellBar = 0

// Evaluates triggers if structural cross occurred within valid synchronization windows AND price breakout conditions print
buyTrigger  = m5BothBuy and (barsSinceNotBuy <= macdWindow) and (barsSinceRawBuy <= confirmWindow) and priceConditionBuy and signalsAllowed and deltaBuyConfirm and (bar_index > lastBuyBar + confirmWindow)
sellTrigger = m5BothSell and (barsSinceNotSell <= macdWindow) and (barsSinceRawSell <= confirmWindow) and priceConditionSell and signalsAllowed and deltaSellConfirm and (bar_index > lastSellBar + confirmWindow)

if buyTrigger
    lastBuyBar := bar_index
if sellTrigger
    lastSellBar := bar_index

// Color the background of the trigger candle yellow 
bgcolor(buyTrigger or sellTrigger ? color.new(color.yellow, 80) : na, title="Trend Change Candle") 

// Plot shapes on the chart with black structural lettering 
plotshape(buyTrigger,  title="Dual MACD Buy Signal",  style=shape.triangleup,   location=location.belowbar, color=color.yellow, size=size.small, text="B", textcolor=color.black) 
plotshape(sellTrigger, title="Dual MACD Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.yellow, size=size.small, text="S", textcolor=color.black) 

// --- Dynamic Chart Overlay Label Engine --- 
getChartLabelText(float tot, float b, float s, float d) => 
    dp = d > 0 ? "+" : "" 
    "Vol: " + str.tostring(tot, "#") +  
     "\nB: " + str.tostring(b, "#") +  
     "\nS: " + str.tostring(s, "#") +  
     "\nΔ: " + dp + str.tostring(d, "#") 

// Fixed positioning using yloc.price logic to map to the lowest visible point safely
chartLowestPrice = ta.lowest(low, 20)
chosenYloc       = volLabelPos == "Bottom of Chart" ? yloc.price : yloc.belowbar
targetYCoordinate= volLabelPos == "Bottom of Chart" ? chartLowestPrice : low
chosenStyleLabel = volLabelPos == "Bottom of Chart" ? label.style_label_upper_left : label.style_label_up

if buyTrigger and showVolLabels 
    labelText = getChartLabelText(m5TotV, m5BuyV, m5SellV, m5DelV) 
    finalColor = useDynamicColors ? color.new(color.blue, 20) : volLabelColorOpt
    label.new(x=bar_index, y=targetYCoordinate, text=labelText, xloc=xloc.bar_index, yloc=chosenYloc,  
              color=finalColor, textcolor=color.white, style=chosenStyleLabel, size=size.small) 

if sellTrigger and showVolLabels 
    labelText = getChartLabelText(m5TotV, m5BuyV, m5SellV, m5DelV) 
    finalColor = useDynamicColors ? color.new(color.red, 20) : volLabelColorOpt
    label.new(x=bar_index, y=targetYCoordinate, text=labelText, xloc=xloc.bar_index, yloc=chosenYloc,  
              color=finalColor, textcolor=color.white, style=chosenStyleLabel, size=size.small) 

// --- Dynamic Line Drawing Engine --- 
var line[] activeLines = array.new<line>() 
var int[]  lineTypes   = array.new<int>()  

// Create lines on new triggers using user customized styles 
if buyTrigger 
    newLine = line.new(x1=bar_index, y1=low, x2=bar_index, y2=low, color=buyLineColor, style=chosenStyle, width=lineWidth) 
    array.push(activeLines, newLine) 
    array.push(lineTypes, 1) 

if sellTrigger 
    newLine = line.new(x1=bar_index, y1=high, x2=bar_index, y2=high, color=sellLineColor, style=chosenStyle, width=lineWidth) 
    array.push(activeLines, newLine) 
    array.push(lineTypes, -1) 

// Manage and update/extend active lines historically bar-by-bar 
if array.size(activeLines) > 0 
    for i = array.size(activeLines) - 1 to 0 
        line  l        = array.get(activeLines, i) 
        int   lType    = array.get(lineTypes, i) 
        float targetY  = line.get_y1(l) 
        bool  isRetested = false 
         
        // Ensure we only look for a retest on bars AFTER the line was created 
        if bar_index > line.get_x1(l) 
            if lType == 1  
                if low <= targetY 
                    isRetested := true 
            else if lType == -1  
                if high >= targetY 
                    isRetested := true 
                 
        if isRetested 
            line.set_x2(l, bar_index) 
            array.remove(activeLines, i) 
            array.remove(lineTypes, i) 
        else 
            line.set_x2(l, bar_index) 

// --- Fetch MTF Time Captures (Malaysia UTC+8) --- 
getDateTimeString() => 
    str.format_time(time, "MM-dd HH:mm", "GMT+8") 

// --- Independent Time Tracking Matrix --- 
// MACD 1 Tracking 
m30Time1 = request.security(syminfo.tickerid, "30",   checkMACD1Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h1Time1  = request.security(syminfo.tickerid, "60",   checkMACD1Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h2Time1  = request.security(syminfo.tickerid, "120", checkMACD1Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h4Time1  = request.security(syminfo.tickerid, "240", checkMACD1Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 

var string m5TimeStr1 = "" 
if m5_S1 != m5_S1[1] 
    m5TimeStr1 := getDateTimeString() 

var string m30TimeStr1 = "" 
var string h1TimeStr1  = "" 
var string h2TimeStr1  = "" 
var string h4TimeStr1  = "" 

if m30Time1 != "" and not na(m30Time1)      
    m30TimeStr1 := m30Time1 
if h1Time1 != "" and not na(h1Time1)        
    h1TimeStr1  := h1Time1 
if h2Time1 != "" and not na(h2Time1)        
    h2TimeStr1  := h2Time1 
if h4Time1 != "" and not na(h4Time1)        
    h4TimeStr1  := h4Time1 

// MACD 2 Tracking 
m30Time2 = request.security(syminfo.tickerid, "30",   checkMACD2Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h1Time2  = request.security(syminfo.tickerid, "60",   checkMACD2Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h2Time2  = request.security(syminfo.tickerid, "120", checkMACD2Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 
h4Time2  = request.security(syminfo.tickerid, "240", checkMACD2Change() ? getDateTimeString() : "", lookahead=barmerge.lookahead_off) 

var string m5TimeStr2 = "" 
if m5_S2 != m5_S2[1] 
    m5TimeStr2 := getDateTimeString() 

var string m30TimeStr2 = "" 
var string h1TimeStr2  = "" 
var string h2TimeStr2  = "" 
var string h4TimeStr2  = "" 

if m30Time2 != "" and not na(m30Time2)      
    m30TimeStr2 := m30Time2 
if h1Time2 != "" and not na(h1Time2)        
    h1TimeStr2  := h1Time2 
if h2Time2 != "" and not na(h2Time2)        
    h2TimeStr2  := h2Time2 
if h4Time2 != "" and not na(h4Time2)        
    h4TimeStr2  := h4Time2 

// --- Helper function for cell formatting --- 
getSignalDetails(int state) => 
    string txt = "Neutral" 
    color bg   = color.gray 
    if state == 1 
        txt := "BUY" 
        bg  := color.green 
    else if state == -1 
        txt := "SELL" 
        bg  := color.red 
    [txt, bg] 

// --- Draw the Restructured Dashboard Table --- 
var table mtfTable = table.new(tablePos, 6, 7, bgcolor=color.black, border_width=1, border_color=color.gray) 

if barstate.islast 
    // ROW 0: Main Title Header Row 
    table.cell(mtfTable, 0, 0, "DAX Trading Lab MTF BUY/SELL Dashboard", text_color=color.yellow, text_size=titleFontSize, text_font_family=font.family_monospace) 
    table.merge_cells(mtfTable, 0, 0, 5, 0) 

    // ROW 1: Classification Headers 
    table.cell(mtfTable, 0, 1, "", text_color=color.gray, text_size=chosenFontSize) 
     
    table.cell(mtfTable, 1, 1, "Micro TF", text_color=color.white, text_size=chosenFontSize) 
    table.merge_cells(mtfTable, 1, 1, 2, 1)  
     
    table.cell(mtfTable, 3, 1, "Macro TF", text_color=color.white, text_size=chosenFontSize) 
    table.merge_cells(mtfTable, 3, 1, 5, 1)  

    // ROW 2: Clear Timeframe Labels 
    table.cell(mtfTable, 0, 2, "Timeframe", text_color=color.gray, text_size=chosenFontSize) 
    table.cell(mtfTable, 1, 2, "M5",         text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 2, 2, "M30",        text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 3, 2, "H1",         text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 4, 2, "H2",         text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 5, 2, "H4",         text_color=color.white, text_size=chosenFontSize) 

    // ROW 3: MACD Configuration 1 Signal State 
    string label1 = "MACD 1 (" + str.tostring(fast1) + "," + str.tostring(slow1) + "," + str.tostring(signal1) + ")" 
    table.cell(mtfTable, 0, 3, label1, text_color=color.white, text_size=chosenFontSize) 
    [m5T1, m5B1]   = getSignalDetails(m5_S1) 
    [m30T1, m30B1] = getSignalDetails(m30_S1) 
    [h1T1, h1B1]   = getSignalDetails(h1_S1) 
    [h2T1, h2B1]   = getSignalDetails(h2_S1) 
    [h4T1, h4B1]   = getSignalDetails(h4_S1) 
     
    table.cell(mtfTable, 1, 3, m5T1,   bgcolor=m5B1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 2, 3, m30T1,  bgcolor=m30B1,  text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 3, 3, h1T1,   bgcolor=h1B1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 4, 3, h2T1,   bgcolor=h2B1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 5, 3, h4T1,   bgcolor=h4B1,   text_color=color.white, text_size=chosenFontSize) 

    // ROW 4: MACD 1 Dynamic Timestamp Tracking 
    table.cell(mtfTable, 0, 4, "Last Change", text_color=color.gray, text_size=chosenFontSize) 
    table.cell(mtfTable, 1, 4, m5TimeStr1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 2, 4, m30TimeStr1,  text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 3, 4, h1TimeStr1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 4, 4, h2TimeStr1,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 5, 4, h4TimeStr1,   text_color=color.white, text_size=chosenFontSize) 

    // ROW 5: MACD Configuration 2 Signal State 
    string label2 = "MACD 2 (" + str.tostring(fast2) + "," + str.tostring(slow2) + "," + str.tostring(signal2) + ")" 
    table.cell(mtfTable, 0, 5, label2, text_color=color.white, text_size=chosenFontSize) 
    [m5T2, m5B2]   = getSignalDetails(m5_S2) 
    [m30T2, m30B2] = getSignalDetails(m30_S2) 
    [h1T2, h1B2]   = getSignalDetails(h1_S2) 
    [h2T2, h2B2]   = getSignalDetails(h2_S2) 
    [h4T2, h4B2]   = getSignalDetails(h4_S2) 
     
    table.cell(mtfTable, 1, 5, m5T2,   bgcolor=m5B2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 2, 5, m30T2,  bgcolor=m30B2,  text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 3, 5, h1T2,   bgcolor=h1B2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 4, 5, h2T2,   bgcolor=h2B2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 5, 5, h4T2,   bgcolor=h4B2,   text_color=color.white, text_size=chosenFontSize) 

    // ROW 6: MACD 2 Dynamic Timestamp Tracking 
    table.cell(mtfTable, 0, 6, "Last Change", text_color=color.gray, text_size=chosenFontSize) 
    table.cell(mtfTable, 1, 6, m5TimeStr2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 2, 6, m30TimeStr2,  text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 3, 6, h1TimeStr2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 4, 6, h2TimeStr2,   text_color=color.white, text_size=chosenFontSize) 
    table.cell(mtfTable, 5, 6, h4TimeStr2,   text_color=color.white, text_size=chosenFontSize) 

// --- Super Simple Alert Triggers --- 
if buyTrigger 
    alert("DAX BUY Signal (Volume Confirmed)", alert.freq_once_per_bar) 

if sellTrigger 
    alert("DAX SELL Signal (Volume Confirmed)", alert.freq_once_per_bar)
````
