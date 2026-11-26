# CEMA

- url: https://www.tradingview.com/script/AYmyee4L-CEMA/
- type: indicator
- pine_id: PUB;aea13025238045b8a1a41baffc596a1e
- version: 1.0

## Description

Shows EMA 9,21,50,200, then Latest 3 Highs and Lows, EMA table from smaller to bigger time frame, Open low and Open high table to scanner as soon as possible

## Source Code

````pine
//@version=5
indicator("CEMA", shorttitle="Chartify", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Support and Resistance Calculation ---

// Define the timeframes for support and resistance
timeFrames = input.timeframe("5", title="Time Frames", inline="TF")
timeFrames2 = input.timeframe("15", title="Time Frames 2", inline="TF")
timeFrames3 = input.timeframe("30", title="Time Frames 3", inline="TF")
timeFrames4 = input.timeframe("60", title="Time Frames 4", inline="TF")
timeFrames5 = input.timeframe("D", title="Time Frames 5", inline="TF")
timeFrames6 = input.timeframe("W", title="Time Frames 6", inline="TF")
timeFrames7 = input.timeframe("M", title="Time Frames 7", inline="TF")


TotalLength = input.int(10, title="Total Length", minval=5)
// Input for percentage threshold
showOpenHL = input.bool(true, title="Show Open High/Low", group="Open High/Low")
percentThreshold = input.float(3.0, minval=0.1, title="Percentage Threshold (%)", tooltip="Draw lines only if the difference is within this percentage", group="Open High/Low")
openHLLookback = input.int(1000, title="Lookback Period", minval=10, group="Open High/Low", tooltip="Number of past bars to scan for Open=High/Low conditions")


// Function to get the highest high (Resistance) and lowest low (Support) for a given time frame
get_support_resistance(tf) =>
    float resistance = 0.0
    float support    = 0.0
    
    // Request Open, High, Low from the chosen timeframe (gaps off so we get continuous history)
    [o_htf, h_htf, l_htf] = request.security(syminfo.tickerid, tf, [open, high, low], gaps=barmerge.gaps_off)
    
    // ──────────────────────────────
    // Find latest valid Resistance (Open == High AND level > close)
    for i = 0 to math.min(openHLLookback, 1500)
        if na(o_htf[i]) or na(h_htf[i])
            continue
        
        float diff_pct_high = math.abs(close - h_htf[i]) / h_htf[i] * 100
        
        if o_htf[i] == h_htf[i] 
           and diff_pct_high < percentThreshold 
           and h_htf[i] > close
            resistance := h_htf[i]
            break   // most recent qualifying (exactly as you asked)
    
    // ──────────────────────────────
    // Find latest valid Support (Open == Low AND level < close)
    for i = 0 to math.min(openHLLookback, 1500)
        if na(o_htf[i]) or na(l_htf[i])
            continue
        
        float diff_pct_low = math.abs(close - l_htf[i]) / l_htf[i] * 100
        
        if o_htf[i] == l_htf[i] 
           and diff_pct_low < percentThreshold 
           and l_htf[i] < close
            support := l_htf[i]
            break   // most recent qualifying (exactly as you asked)
    
    [resistance, support]

// Get Support and Resistance for each time frame
// [resistance1, support1] = get_support_resistance(timeFrames)
// [resistance2, support2] = get_support_resistance(timeFrames2)
// [resistance3, support3] = get_support_resistance(timeFrames3)
// [resistance4, support4] = get_support_resistance(timeFrames4)
// [resistance5, support5] = get_support_resistance(timeFrames5)
// [resistance6, support6] = get_support_resistance(timeFrames6)
// [resistance7, support7] = get_support_resistance(timeFrames7)



// Round the EMA values for display
roundDecimal(value, decimals) =>
    math.round(value * math.pow(10, decimals)) / math.pow(10, decimals)

// --- EMA Calculation ---
getTextColor(emaValue, currentPrice) =>
    emaValue < currentPrice ? color.green : color.red

// User inputs for timeframes and EMA levels
tf1 = input.string("5", title="Timeframe 1", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf2 = input.string("15", title="Timeframe 2", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf3 = input.string("30", title="Timeframe 3", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf4 = input.string("60", title="Timeframe 4", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf5 = input.string("D", title="Timeframe 5", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf6 = input.string("W", title="Timeframe 6", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])
tf7 = input.string("M", title="Timeframe 7", options=["1S", "5S", "15S", "30S", "45S", "60S", "1", "5", "15", "30", "45", "60", "120", "180", "240", "D", "W", "M", "3M", "6M", "12M"])

emaLevel = input.int(9, title="EMA Level")
emaLevel2 = input.int(21, title="Additional EMA Level 1", minval=1)
emaLevel3 = input.int(200, title="Additional EMA Level 2", minval=1)
emaLevel4 = input.int(50, title="Additional EMA Level 3", minval=1)


// Plot Shape EMA
ema_current = ta.ema(close, emaLevel)
ema_current2 = ta.ema(close, emaLevel2)
ema_current3 = ta.ema(close, emaLevel3)
ema_current4 = ta.ema(close, emaLevel4)

plot(ema_current, color=color.yellow, title="EMA 9", linewidth=2)
plot(ema_current2, color=color.green, title="EMA 21", linewidth=2)
plot(ema_current3, color=color.white, title="EMA 200", linewidth=2)
plot(ema_current4, color=color.purple, title="EMA 50", linewidth=2)

// --- Table Creation for Support/Resistance and EMA ---

var table emaTable = table.new(position.top_right, 8, 7, border_width=1, frame_color=color.blue, bgcolor=color.black)
// === NEW: Separate Support & Resistance Table (only when checkbox is ON) ===

// Header
if bar_index == 0 
    
    table.cell(emaTable, 0, 0, "Support & Resistance", text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 1, "Resistance: "  , text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 2, "Support" , text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 3, "EMA 9", text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 4, "EMA 21", text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 5, "EMA 200", text_color=color.white, bgcolor=color.blue)
    table.cell(emaTable, 0, 6, "EMA 50", text_color=color.white, bgcolor=color.blue)

// Add Support/Resistance values
// table.cell(emaTable, 1, 1, str.tostring(resistance1, "#.##"), text_color=getTextColor(resistance1, close))
// table.cell(emaTable, 1, 2, str.tostring(support1, "#.##"), text_color=getTextColor(support1, close))

// table.cell(emaTable, 2, 1, str.tostring(resistance2, "#.##"), text_color=getTextColor(resistance2, close))
// table.cell(emaTable, 2, 2, str.tostring(support2, "#.##"), text_color=getTextColor(support2, close))

// table.cell(emaTable, 3, 1, str.tostring(resistance3, "#.##"), text_color=getTextColor(resistance3, close))
// table.cell(emaTable, 3, 2, str.tostring(support3, "#.##"), text_color=getTextColor(support3, close))

// table.cell(emaTable, 4, 1, str.tostring(resistance4, "#.##"), text_color=getTextColor(resistance4, close))
// table.cell(emaTable, 4, 2, str.tostring(support4, "#.##"), text_color=getTextColor(support4, close))

// table.cell(emaTable, 5, 1, str.tostring(resistance5, "#.##"), text_color=getTextColor(resistance5, close))
// table.cell(emaTable, 5, 2, str.tostring(support5, "#.##"), text_color=getTextColor(support5, close))

// table.cell(emaTable, 6, 1, str.tostring(resistance6, "#.##"), text_color=getTextColor(resistance6, close))
// table.cell(emaTable, 6, 2, str.tostring(support6, "#.##"), text_color=getTextColor(support6, close))

// table.cell(emaTable, 7, 1, str.tostring(resistance7, "#.##"), text_color=getTextColor(resistance7, close))
// table.cell(emaTable, 7, 2, str.tostring(support7, "#.##"), text_color=getTextColor(support7, close))

// table.cell(emaTable, 1, 0, text="Current TF", text_color=color.white, bgcolor=color.new(color.blue, 80))
// table.cell(emaTable, 1, 1, str.tostring(resistanceCurr, "#.##"), text_color=getTextColor(resistanceCurr, close))
// table.cell(emaTable, 1, 2, str.tostring(supportCurr, "#.##"), text_color=getTextColor(supportCurr, close))

// Calculate EMA for different timeframes
ema_tf1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLevel))
ema_tf2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLevel))
ema_tf3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaLevel))
ema_tf4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaLevel))
ema_tf5 = request.security(syminfo.tickerid, tf5, ta.ema(close, emaLevel))
ema_tf6 = request.security(syminfo.tickerid, tf6, ta.ema(close, emaLevel))
ema_tf7 = request.security(syminfo.tickerid, tf7, ta.ema(close, emaLevel))

ema_tf1_2 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLevel2))
ema_tf2_2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLevel2))
ema_tf3_2 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaLevel2))
ema_tf4_2 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaLevel2))
ema_tf5_2 = request.security(syminfo.tickerid, tf5, ta.ema(close, emaLevel2))
ema_tf6_2 = request.security(syminfo.tickerid, tf6, ta.ema(close, emaLevel2))
ema_tf7_2 = request.security(syminfo.tickerid, tf7, ta.ema(close, emaLevel2))

ema_tf1_3 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLevel3))
ema_tf2_3 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLevel3))
ema_tf3_3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaLevel3))
ema_tf4_3 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaLevel3))
ema_tf5_3 = request.security(syminfo.tickerid, tf5, ta.ema(close, emaLevel3))
ema_tf6_3 = request.security(syminfo.tickerid, tf6, ta.ema(close, emaLevel3))
ema_tf7_3 = request.security(syminfo.tickerid, tf7, ta.ema(close, emaLevel3))


ema_tf1_4 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLevel4))
ema_tf2_4 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLevel4))
ema_tf3_4 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaLevel4))
ema_tf4_4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaLevel4))
ema_tf5_4 = request.security(syminfo.tickerid, tf5, ta.ema(close, emaLevel4))
ema_tf6_4 = request.security(syminfo.tickerid, tf6, ta.ema(close, emaLevel4))
ema_tf7_4 = request.security(syminfo.tickerid, tf7, ta.ema(close, emaLevel4))



// Round values for better display
ema_tf1_rounded = roundDecimal(ema_tf1, 2)
ema_tf2_rounded = roundDecimal(ema_tf2, 2)
ema_tf3_rounded = roundDecimal(ema_tf3, 2)
ema_tf4_rounded = roundDecimal(ema_tf4, 2)
ema_tf5_rounded = roundDecimal(ema_tf5, 2) // 30min EMA
ema_tf6_rounded = roundDecimal(ema_tf6, 2) // Weekly EMA
ema_tf7_rounded = roundDecimal(ema_tf7, 2) // Monthly EMA

ema_tf1_2_rounded = roundDecimal(ema_tf1_2, 2)
ema_tf2_2_rounded = roundDecimal(ema_tf2_2, 2)
ema_tf3_2_rounded = roundDecimal(ema_tf3_2, 2)
ema_tf4_2_rounded = roundDecimal(ema_tf4_2, 2)
ema_tf5_2_rounded = roundDecimal(ema_tf5_2, 2) // 30min EMA
ema_tf6_2_rounded = roundDecimal(ema_tf6_2, 2) // Weekly EMA
ema_tf7_2_rounded = roundDecimal(ema_tf7_2, 2) // Monthly EMA

ema_tf1_3_rounded = roundDecimal(ema_tf1_3, 2)
ema_tf2_3_rounded = roundDecimal(ema_tf2_3, 2)
ema_tf3_3_rounded = roundDecimal(ema_tf3_3, 2)
ema_tf4_3_rounded = roundDecimal(ema_tf4_3, 2)
ema_tf5_3_rounded = roundDecimal(ema_tf5_3, 2) // 30min EMA
ema_tf6_3_rounded = roundDecimal(ema_tf6_3, 2) // Weekly EMA
ema_tf7_3_rounded = roundDecimal(ema_tf7_3, 2) // Monthly EMA


ema_tf1_4_rounded = roundDecimal(ema_tf1_4, 2)
ema_tf2_4_rounded = roundDecimal(ema_tf2_4, 2)
ema_tf3_4_rounded = roundDecimal(ema_tf3_4, 2)
ema_tf4_4_rounded = roundDecimal(ema_tf4_4, 2)
ema_tf5_4_rounded = roundDecimal(ema_tf5_4, 2) // 30min EMA
ema_tf6_4_rounded = roundDecimal(ema_tf6_4, 2) // Weekly EMA
ema_tf7_4_rounded = roundDecimal(ema_tf7_4, 2) // Monthly EMA

table.cell(emaTable, 1, 0, text=tf1 + " min", text_color=color.white)
// Add EMA values to the table
table.cell(emaTable, 1, 3, str.tostring(ema_tf1, "#.##"), text_color=getTextColor(ema_tf1_rounded, close))
table.cell(emaTable, 1, 4, str.tostring(ema_tf1_2, "#.##"), text_color=getTextColor(ema_tf1_2_rounded, close))
table.cell(emaTable, 1, 5, str.tostring(ema_tf1_3, "#.##"), text_color=getTextColor(ema_tf1_3_rounded, close))
table.cell(emaTable, 1, 6, str.tostring(ema_tf1_4, "#.##"), text_color=getTextColor(ema_tf1_4_rounded, close))


table.cell(emaTable, 2, 0, text=tf2 + " min", text_color=color.white)
table.cell(emaTable, 2, 3, str.tostring(ema_tf2, "#.##"), text_color=getTextColor(ema_tf2_rounded, close))
table.cell(emaTable, 2, 4, str.tostring(ema_tf2_2, "#.##"), text_color=getTextColor(ema_tf2_2_rounded, close))
table.cell(emaTable, 2, 5, str.tostring(ema_tf2_3, "#.##"), text_color=getTextColor(ema_tf2_3_rounded, close))
table.cell(emaTable, 2, 6, str.tostring(ema_tf2_4, "#.##"), text_color=getTextColor(ema_tf2_4_rounded, close))


table.cell(emaTable, 3, 0, text=tf3 + " min", text_color=color.white)
table.cell(emaTable, 3, 3, str.tostring(ema_tf3, "#.##"), text_color=getTextColor(ema_tf3_rounded, close))
table.cell(emaTable, 3, 4, str.tostring(ema_tf3_2, "#.##"), text_color=getTextColor(ema_tf3_2_rounded,  close))
table.cell(emaTable, 3, 5, str.tostring(ema_tf3_3, "#.##"), text_color=getTextColor(ema_tf3_2_rounded, close))
table.cell(emaTable, 3, 6, str.tostring(ema_tf3_4, "#.##"), text_color=getTextColor(ema_tf3_4_rounded, close))

table.cell(emaTable, 4, 0, text=tf4 + " min", text_color=color.white)
table.cell(emaTable, 4, 3, str.tostring(ema_tf4, "#.##"), text_color=getTextColor(ema_tf4_rounded, close))
table.cell(emaTable, 4, 4, str.tostring(ema_tf4_2, "#.##"), text_color=getTextColor(ema_tf4_2_rounded, close))
table.cell(emaTable, 4, 5, str.tostring(ema_tf4_3, "#.##"), text_color=getTextColor(ema_tf4_3_rounded, close))
table.cell(emaTable, 4, 6, str.tostring(ema_tf4_4, "#.##"), text_color=getTextColor(ema_tf4_4_rounded, close))

table.cell(emaTable, 5, 0, text=tf5 + " min", text_color=color.white)
table.cell(emaTable, 5, 3, str.tostring(ema_tf5, "#.##"), text_color=getTextColor(ema_tf5_rounded, close))
table.cell(emaTable, 5, 4, str.tostring(ema_tf5_2, "#.##"), text_color=getTextColor(ema_tf5_2_rounded, close))
table.cell(emaTable, 5, 5, str.tostring(ema_tf5_3, "#.##"), text_color=getTextColor(ema_tf5_3_rounded, close))
table.cell(emaTable, 5, 6, str.tostring(ema_tf5_4, "#.##"), text_color=getTextColor(ema_tf5_4_rounded, close))

table.cell(emaTable, 6, 0, text=tf6 + " week", text_color=color.white)
table.cell(emaTable, 6, 3, str.tostring(ema_tf6, "#.##"), text_color=getTextColor(ema_tf6_rounded, close))
table.cell(emaTable, 6, 4, str.tostring(ema_tf6_2, "#.##"), text_color=getTextColor(ema_tf6_2_rounded, close))
table.cell(emaTable, 6, 5, str.tostring(ema_tf6_3, "#.##"), text_color=getTextColor(ema_tf6_3_rounded, close))
table.cell(emaTable, 6, 6, str.tostring(ema_tf6_4, "#.##"), text_color=getTextColor(ema_tf6_4_rounded, close))

table.cell(emaTable, 7, 0, text=tf7 + " month", text_color=color.white)
table.cell(emaTable, 7, 3, str.tostring(ema_tf7, "#.##"), text_color=getTextColor(ema_tf7_rounded, close))
table.cell(emaTable, 7, 4, str.tostring(ema_tf7_2, "#.##"), text_color=getTextColor(ema_tf7_2_rounded, close))
table.cell(emaTable, 7, 5, str.tostring(ema_tf7_3, "#.##"), text_color=getTextColor(ema_tf7_3_rounded, close))
table.cell(emaTable, 7, 6, str.tostring(ema_tf7_4, "#.##"), text_color=getTextColor(ema_tf7_4_rounded, close))


// === Open High / Low Table ===
var table openHLTable = table.new(position.bottom_right, columns = 3, rows = 8, 
                                  border_width = 1, frame_color = color.white, 
                                  bgcolor = color.new(color.black, 80))

if showOpenHL and barstate.islast
    table.clear(openHLTable, 0, 0)   // Safe clear with column and row
    
    int row = 0
    
    // Main Title
    table.cell(openHLTable, 0, row, "Open = High / Low Levels", 
               text_color = color.white, bgcolor = color.navy)
    row += 1
    
    // Column Headers
    table.cell(openHLTable, 0, row, "Date", text_color = color.white, bgcolor = color.blue)
    table.cell(openHLTable, 1, row, "Price",    text_color = color.white, bgcolor = color.blue)
    table.cell(openHLTable, 2, row, "Type",     text_color = color.white, bgcolor = color.blue)
    row += 1
    
    int highCount = 0
    int lowCount  = 0
    
    for i = 0 to openHLLookback
        if highCount >= 3 and lowCount >= 3
            break
        
        // Safe calculations (prevents division by zero runtime error)
        float openHighDiffPercent = high[i] > 0 ? math.abs((close - high[i]) / high[i]) * 100 : 100
        float openLowDiffPercent  = low[i]  > 0 ? math.abs((close - low[i])  / low[i])  * 100 : 100

        bool openIsHigh = not na(open[i]) and not na(high[i]) and open[i] == high[i] and openHighDiffPercent < percentThreshold
        bool openIsLow  = not na(open[i]) and not na(low[i])  and open[i] == low[i]  and openLowDiffPercent  < percentThreshold

        // Resistance - Open = High
        if openIsHigh and highCount < 3
            table.cell(openHLTable, 0, row, str.format_time(time[i], "dd-MMM HH:mm", syminfo.timezone), text_color = color.orange)
            table.cell(openHLTable, 1, row, str.tostring(high[i], "#.##"), text_color = color.red)
            table.cell(openHLTable, 2, row, "Resistance", text_color = color.red)
            highCount += 1
            row += 1

        // Support - Open = Low
        if openIsLow and lowCount < 3
            table.cell(openHLTable, 0, row, str.format_time(time[i], "dd-MMM HH:mm", syminfo.timezone), text_color = color.orange)
            table.cell(openHLTable, 1, row, str.tostring(low[i], "#.##"), text_color = color.lime)
            table.cell(openHLTable, 2, row, "Support", text_color = color.lime)
            lowCount += 1
            row += 1
else
    // Hide when checkbox is off
    table.clear(openHLTable, 0, 0)
// //@version=5
// indicator("Big Reversal Candle (Inverted Hammer)", overlay=true)


// Inputs
showInvertedHammer = input.bool(true, title="Show Inverted Hammer", group="Inverted Hammer")
bodyThreshold = input.float(0.5, title="Body-to-Candle Ratio Threshold", tooltip="Maximum ratio of the body to the full candle range (0-1)", group="Inverted Hammer")
wickRatio = input.float(2.0, title="Upper Wick-to-Body Ratio", tooltip="Minimum ratio of upper wick to body", group="Inverted Hammer")
minCandleSize = input.float(0.5, title="Minimum Candle Size (%)", tooltip="Minimum size of the candle (percentage of the closing price)", group="Inverted Hammer")

// Candle properties
candleRange = high - low
bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
candleSizePercent = (candleRange / close) * 100

// Conditions for Inverted Hammer
isInvertedHammer =  bodySize / candleRange <= bodyThreshold and     upperWick / bodySize >= wickRatio and       lowerWick / candleRange <= 0.1 and candleSizePercent >= minCandleSize            // Candle size is above the minimum threshold

// Draw horizontal line for Inverted Hammer
var line[] lines = na  // Store lines in an array for tracking

if isInvertedHammer and showInvertedHammer
    // Create a horizontal line at the high of the candle
    newLine = line.new(x1=bar_index - 1, y1=high, x2=bar_index + 1, y2=high, color=color.yellow, width=2, style=line.style_dotted, extend=extend.right)
    array.push(lines, newLine)

    
// === Hull Moving Average (HMA) Calculation ===
hma(source, length) =>
    ta.wma(2 * ta.wma(source, length / 2) - ta.wma(source, length), math.round(math.sqrt(length)))

// Define HMA lengths
showHMA = input.bool(false, title="Show HMA")
hmaLength1 = 9
hmaLength2 = 21

// Calculate HMAs
hmaFast = hma(close, hmaLength1)
hmaSlow = hma(close, hmaLength2)

// Plot HMA
// Plot HMA
plot(showHMA ? hmaFast : na, title="HMA Fast (9)", color=color.aqua, linewidth=2, display=display.pane)
plot(showHMA ? hmaSlow : na, title="HMA Slow (21)", color=color.red, linewidth=2, display=display.pane)

// HMA Cross Signals
longSignalHMA = ta.crossover(hmaFast, hmaSlow)
shortSignalHMA = ta.crossunder(hmaFast, hmaSlow)

// Plot HMA Buy/Sell Signals
plotshape(series=showHMA ? longSignalHMA : na, title="Buy Signal (HMA)", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(series=showHMA ? shortSignalHMA : na, title="Sell Signal (HMA)", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === Halftrend Indicator ===
showHalfTrend = input.bool(false, title="Show Halftrend")
halftrendLength = input(2, title="Halftrend Length")
amplitude = input(1, title="Amplitude")

var float buyLevel = na
var float sellLevel = na

direction = 0
if high - low > amplitude * ta.atr(halftrendLength)
    direction := close > close[1] ? 1 : -1

if direction == 1
    buyLevel := low - amplitude * ta.atr(halftrendLength)
    sellLevel := na
else
    sellLevel := high + amplitude * ta.atr(halftrendLength)
    buyLevel := na

plot(showHalfTrend ? buyLevel : na, title="Halftrend Buy", color=color.green, linewidth=2, display=display.pane)
plot(showHalfTrend ? sellLevel : na, title="Halftrend Sell", color=color.red, linewidth=2, display=display.pane)

// Halftrend Buy/Sell Signals
buySignalHalftrend = na(close) and na(close[1]) and not na(buyLevel) and close > buyLevel
sellSignalHalftrend = na(close) and na(close[1]) and not na(sellLevel) and close < sellLevel

plotshape(series=showHalfTrend ? buySignalHalftrend : na, title="Halftrend Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(series=showHalfTrend ? sellSignalHalftrend : na, title="Halftrend Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === Bollinger Bands ===
showBB = input.bool(false, title="Show Bollinger Bands", group="Bollinger Bands")
bbLength = input.int(20, minval=1, title="Length", group="Bollinger Bands")
bbMaType = input.string("SMA", "Basis MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="Bollinger Bands")
bbSrc = input(close, title="Source", group="Bollinger Bands")
bbMult = input.float(2.0, minval=0.001, maxval=50, title="StdDev", group="Bollinger Bands")
bbOffset = input.int(0, "Offset", minval = -500, maxval = 500, display = display.data_window, group="Bollinger Bands")

bbMa(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

bbBasis = bbMa(bbSrc, bbLength, bbMaType)
bbDev = bbMult * ta.stdev(bbSrc, bbLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

plot(showBB ? bbBasis : na, "BB Basis", color=#2962FF, offset = bbOffset)
p1 = plot(showBB ? bbUpper : na, "BB Upper", color=#F23645, offset = bbOffset, display=display.pane)
p2 = plot(showBB ? bbLower : na, "BB Lower", color=#089981, offset = bbOffset, display=display.pane)
fill(p1, p2, title = "BB Background", color=showBB ? color.rgb(33, 150, 243, 95) : na)

// === Trend Buy Strategy ===
showTrendStrategy = input.bool(true, title="Show Trend Buy Strategy", group="Trend Strategy")
swingSupportTolerance = input.float(0.01, title="Buy Support Tolerance %", step=0.001, group="Trend Strategy", tooltip="Price must come within this % of a valid Swing Low to count as 'Taking Support'")
t_pivotLookback = input.int(2, title="Strategy Pivot Lookback", minval=1, group="Trend Strategy", tooltip="Bars required to confirm a Swing High/Low. Lower = Faster detection but more noise.")
emaValidationThreshold = input.float(0.5, title="EMA Validation Tolerance %", minval=0.0, step=0.1, group="Trend Strategy", tooltip="Allows the Open to be slightly above/below the EMAs and still count as a valid setup. E.g. 0.5% tolerance.")
debugMode = input.bool(false, title="Enable Debug Mode", group="Trend Strategy", tooltip="Shows state information on the chart.")

// === Trend Sell Strategy Inputs ===
showTrendStrategySell = input.bool(true, title="Show Trend Sell Strategy", group="Trend Strategy")
swingResistanceTolerance = input.float(0.01, title="Sell Resistance Tolerance %", step=0.001, group="Trend Strategy", tooltip="Price must come within this % of a valid Swing High to count as 'Taking Resistance'")

// Fetch Data (Current Timeframe)
t_open = open
t_high = high
t_low = low
t_close = close
t_ema9 = ta.ema(close, 9)
t_ema21 = ta.ema(close, 21)
t_ema200 = ta.ema(close, 200)

// Pivots Identification
t_leftBars = t_pivotLookback
t_rightBars = t_pivotLookback
t_phc = ta.pivothigh(high, t_leftBars, t_rightBars)
t_plc = ta.pivotlow(low, t_leftBars, t_rightBars)

// === Timeframe Mapping for Confirmation ===
var string confirmTf = ""
if timeframe.isintraday
    if timeframe.multiplier <= 30
        confirmTf := "5"
    else 
        confirmTf := "15"
else if timeframe.isdaily
    confirmTf := "15"
else if timeframe.isweekly
    confirmTf := "D"
else
    confirmTf := "15" // Default fallback

// Fetch LTF Data (Intrabar)
// Returns array of closes of the lower timeframe candles inside the current bar
[ltfCloses, ltfHighs, ltfLows] = request.security_lower_tf(syminfo.tickerid, confirmTf, [close, high, low])



// --- Confirmed EMA Crossover Strategy ---

// BUY Logic
var int b_state = 0 // 0=Search, 1=Confirm
var float b_setupHigh = 0.0
var float b_setupLow = 0.0
var int b_setupTime = 0
var float lc = 0.0

// 1. Search for Setup
bool setupBuy = open < t_ema9 and open < t_ema21 and close > t_ema9 and close > t_ema21

if b_state == 0 and setupBuy
    b_state := 1
    b_setupHigh := high
    b_setupLow := low
    b_setupTime := time

// 2. Confirm with LTF
bool buyConfirmed = false
if b_state == 1
    // If setup just happened on this bar, we wait for NEXT bar to check LTF? 
    // Or check LTF of *this* bar provided they closed higher than *this* bar's final high? (Impossible)
    // The previous logic relied on state persistence. 
    // Use `barstate.isconfirmed`? No, simpler to check if we are NOT on the setup bar anymore?
    // Actually, `request.security_lower_tf` returns intrabar data.
    // If the setup bar is closed (history), we can check its LTF data? No, we need to check subsequent price action.
    // The Standard Logic: Setup is Bar A. Confirmation is Bar B (or intrabar inside B) breaking Bar A's high.
    // So we need to reset state if we are on a new bar and haven't confirmed?
    // Let's stick to the previous code's flow:
    // It checked LTF closes *of the current bar*.
    // If `b_state` was set on Bar A, and we are now on Bar B, `ltfCloses` are for Bar B.
    // If any Bar B LTF Close > Bar A High -> Trigger.
    
    // We need to ensure we don't confirm on the *same* bar if the setup high *is* the bar high.
    // But `setupBuy` is based on `close`. `close` is final.
    // So `b_state` becomes 1 at the close of the bar (effectively).
    // On the *next* bar execution, `b_state` is 1.
    // So we check `ltfCloses`.
    
    if array.size(ltfCloses) > 0
        for i = 0 to array.size(ltfCloses) - 1
            lc := array.get(ltfCloses, i)
            if lc > b_setupHigh
                buyConfirmed := true
                b_state := 0
                break
            if lc < b_setupLow
                b_state := 0 // Invalidated
                break

if buyConfirmed and showTrendStrategy
    string ttip = "Signal: CONFIRMED BUY\n" + 
                  "---------------------\n" +
                  "Logic: EMA Cross + LTF Confirmation\n" +
                  "Setup Time: " + str.format_time(b_setupTime, "yyyy-MM-dd HH:mm") + "\n" +
                  "Setup High: " + str.tostring(lc, "#.##") + "\n" +
                  "Current Open: " + str.tostring(open, "#.##") + "\n" +
                  "Current Close: " + str.tostring(close, "#.##")
    label.new(bar_index, low, text="▲", color=color.lime, style=label.style_none, textcolor=color.lime, tooltip=ttip, yloc=yloc.belowbar, size=size.huge)


// SELL Logic
var int s_state = 0
var float s_setupHigh = 0.0
var float s_setupLow = 0.0
var int s_setupTime = 0

bool setupSell = open > t_ema9 and open > t_ema21 and close < t_ema9 and close < t_ema21

if s_state == 0 and setupSell
    s_state := 1
    s_setupHigh := high
    s_setupLow := low
    s_setupTime := time

bool sellConfirmed = false
if s_state == 1
    if array.size(ltfCloses) > 0
        for i = 0 to array.size(ltfCloses) - 1
            lc = array.get(ltfCloses, i)
            if lc < s_setupLow
                sellConfirmed := true
                s_state := 0
                break
            if lc > s_setupHigh
                s_state := 0 // Invalidated
                break

if sellConfirmed and showTrendStrategySell
    string ttip = "Signal: CONFIRMED SELL\n" + 
                  "----------------------\n" +
                  "Logic: EMA Cross + LTF Confirmation\n" +
                  "Setup Time: " + str.format_time(s_setupTime, "yyyy-MM-dd HH:mm") + "\n" +
                  "Setup Low: " + str.tostring(s_setupLow, "#.##") + "\n" +
                  "Current Open: " + str.tostring(open, "#.##") + "\n" +
                  "Current Close: " + str.tostring(close, "#.##")
    label.new(bar_index, high, text="▼", color=color.red, style=label.style_none, textcolor=color.red, tooltip=ttip, yloc=yloc.abovebar, size=size.huge)

// User Input
showSwingHL = input.bool(false, title="Show 3 Swing HL", group="Swing Settings")

// Parameters for Pivot Calculation
swingLookback = 1500
pivotLeft = 10
pivotRight = 10

// Calculate Pivot High and Low
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

// Explicitly set the history buffer size
max_bars_back(ph, 501)
max_bars_back(pl, 501)

// Array to store line objects so we can delete old ones
var line[] swingLines = array.new_line()

if barstate.islast and showSwingHL
    // Clear previous lines to avoid duplication/clutter
    if array.size(swingLines) > 0
        for i = 0 to array.size(swingLines) - 1
            line.delete(array.get(swingLines, i))
        array.clear(swingLines)

    // Arrays to collect VALID pivot values
    // We store the bar_index of the pivot to sort by recency
    int[] validHighIdx = array.new_int()
    float[] validHighVal = array.new_float()
    
    int[] validLowIdx = array.new_int()
    float[] validLowVal = array.new_float()

    // Scan backwards to find pivots and validate them
    for i = 0 to swingLookback
        // Check for Pivot High
        // ph[i] is the pivot value confirmed i bars ago. 
        // Peak location was i + pivotRight bars ago.
        if not na(ph[i])
            float pVal = ph[i]
            int pDist = i + pivotRight
            bool broken = false
            // Validation: Check bars from pDist-1 down to 0 (current)
            // If any High > pVal, it's broken
            // Optimization: We can just check the highest high in that range
            if pDist > 0
                // ta.highest(high, pDist) checks the last pDist bars (0 to pDist-1)
                // Note: ta.highest is robust in loops in Pine v5? 
                // Using array logic might be safer if ta.highest behaves weirdly in local scope loops.
                // But simplified manual check is safe:
                for k = 0 to pDist - 1
                    if high[k] > pVal
                        broken := true
                        break
            
            if not broken
                array.push(validHighIdx, bar_index - pDist)
                array.push(validHighVal, pVal)

        // Check for Pivot Low
        if not na(pl[i])
            float pVal = pl[i]
            int pDist = i + pivotRight
            bool broken = false
            // Validation: Check bars from pDist-1 down to 0
            // If any Low < pVal, it's broken
            if pDist > 0
                for k = 0 to pDist - 1
                    if low[k] < pVal
                        broken := true
                        break
            
            if not broken
                array.push(validLowIdx, bar_index - pDist)
                array.push(validLowVal, pVal)

    // --- Process Swing Highs ---
    if array.size(validHighIdx) > 0
        // We want the most recent ones. The loop scanned 0..500, finding most recent first?
        // Loop i=0 is most recent confirmation.
        // So arrays are naturally ordered by recency (confirmed most recently).
        // Check: i=0 is 'now'. i=500 is 'past'.
        // So array[0] is most recent pivot found.
        // We just take top 3.
        int countH = math.min(array.size(validHighIdx), 3)
        for j = 0 to countH - 1
            idx = array.get(validHighIdx, j) // Actual bar index of pivot
            val = array.get(validHighVal, j)
            // Draw Line from pivot to current
            l = line.new(x1=idx, y1=val, x2=bar_index, y2=val, color=color.red, width=3, style=line.style_solid)
            array.push(swingLines, l)

    // --- Process Swing Lows ---
    if array.size(validLowIdx) > 0
        int countL = math.min(array.size(validLowIdx), 3)
        for j = 0 to countL - 1
            idx = array.get(validLowIdx, j)
            val = array.get(validLowVal, j)
            l = line.new(x1=idx, y1=val, x2=bar_index, y2=val, color=color.green, width=1, style=line.style_solid)
            array.push(swingLines, l)

showBDStrategy      = input.bool(true,  title="Show BD Candle Sell Strategy", group="BD Candle Strategy")
bd_ema9TouchPct     = input.float(0.1,  title="EMA 9 Touch Tolerance (%)",    group="BD Candle Strategy", minval=0.1, step=0.1, tooltip="High of candle must come within this % of EMA 9 to count as a touch.")
bd_maxWatchBars     = input.int(20,     title="Max Bars to Wait (each phase)", group="BD Candle Strategy", minval=1,  tooltip="Setup cancels if EMA 9 not touched within this many bars (Phase 1), or if sell not triggered within this many bars after touch (Phase 2).")
bd_ltfConfirmTf     = input.string("15", title="LTF Confirmation Timeframe",  group="BD Candle Strategy", options=["1","3","5","10","15","30","45","60"], tooltip="A candle on this timeframe closing below BD Low fires the sell signal.")

// --- Re-use BB values already calculated above (bbLower, bbUpper, bbBasis) ---
// bbLower is already defined from the Bollinger Bands section.
// t_ema9  is already defined from the Trend Strategy section.

// --- BD Candle Detection ---
// Open > Lower BB  AND  Close < Lower BB
bool isBDCandle = open > bbLower and close < bbLower

// --- State Machine ---
// bd_phase: 0 = idle, 1 = watching for EMA9 touch, 2 = armed (watching for sell trigger)
var int   bd_phase      = 0
var float bd_low        = na   // BD candle's low (the key level)
var int   bd_phaseBar   = 0    // bar_index when the current phase started
var int   bd_cancelPhase   = 0    // 0=idle, 1=waiting for 15min confirm above cancel candle high
var float bd_cancelHigh    = na   // High of the candle that closed above EMA 9
var float bd_retestLow = na
var int bd_retestTime = 0
var bool  bd_justDetected = false
var int bd_signalTime = 0


// 15-min closes (reuse same approach as existing LTF logic)
ltfCloses15 = request.security_lower_tf(syminfo.tickerid, bd_ltfConfirmTf, close[0])
ltfTimes15 = request.security_lower_tf(syminfo.tickerid, bd_ltfConfirmTf, time)

bd_ltfBrokeHigh(lvl) =>
    bool broke = false
    if array.size(ltfCloses15) > 0
        for _i = 0 to array.size(ltfCloses15) - 1
            if array.get(ltfCloses15, _i) > lvl
                broke := true
                break
    broke

// Helper: did any 15-min close go below a level this bar?
bd_ltfBrokeLowIdx(lvl) =>
    int trigIdx = -1
    if array.size(ltfCloses15) > 0
        for _i = 0 to array.size(ltfCloses15) - 1
            if array.get(ltfCloses15, _i) < lvl
                trigIdx := _i
                break
    trigIdx

// --- Phase transitions ---

var float bd_high = na
var int bd_time = 0

bd_justDetected := false
if bd_phase == 0 and isBDCandle
    bd_phase        := 1
    bd_low          := low
    bd_high         := high
    bd_phaseBar     := bar_index
    bd_time         := time
    bd_justDetected := true



// --- Cancel state: detect candle closing above EMA 9 while setup is active ---
bool bd_cancelNow = false

if (bd_phase == 1 or bd_phase == 2)
    // Step 1: a candle closes above EMA 9 → arm the cancel
    if bd_cancelPhase == 0 and close > t_ema9
        bd_cancelPhase := 1
        bd_cancelHigh  := high

    // Step 2: 15-min close above that candle's high → confirmed cancel
    if bd_cancelPhase == 1
        if bd_ltfBrokeHigh(bd_cancelHigh)
            bd_cancelNow       := true
            bd_cancelPhase     := 0
            bd_cancelHigh      := na

// Reset cancel state if setup is no longer active
if bd_phase == 0
    bd_cancelPhase := 0
    bd_cancelHigh  := na

// Phase 1 : Watch for EMA 9 touch OR cancel conditions
if bd_phase == 1
    int barsSinceBD = bar_index - bd_phaseBar

    if bd_cancelNow
        bd_phase := 0
    else if close < bd_low
        bd_phase := 0
    else if barsSinceBD >= bd_maxWatchBars
        bd_phase := 0
    else
        float ema9Val   = t_ema9
        float touchDiff = math.abs(high - ema9Val) / ema9Val * 100
        if touchDiff <= bd_ema9TouchPct
            bd_phase    := 2
            bd_phaseBar := bar_index
            bd_retestLow    := low
            bd_retestTime   := time

// Phase 2 : Armed — watch for 15-min close below BD Low
bool bd_sellSignal = false
if bd_phase == 2
    int barsSinceTouch = bar_index - bd_phaseBar

    if bd_cancelNow
        bd_phase := 0
    else if barsSinceTouch >= bd_maxWatchBars
        bd_phase := 0
    else 
        int bd_trigIdx = bd_ltfBrokeLowIdx(bd_retestLow)
        if bd_trigIdx != -1
            bd_sellSignal := true
            bd_phase      := 0
            bd_signalTime := array.get(ltfTimes15, bd_trigIdx)

        

bool bd_showMarker = isBDCandle and bd_phase == 1 and (bar_index == bd_phaseBar)

// --- NEW BD Candle Marker ---
// Mark the BD candle itself with a small label so the user can see it was detected
plotshape(series = showBDStrategy ? bd_justDetected  : na,
          title       = "BD Candle",
          location    = location.abovebar,
          color       = color.new(color.orange, 0),
          style       = shape.diamond,
          size        = size.tiny,
          text        = "BD",
          textcolor   = color.orange)

// --- Sell Signal Label ---
if bd_sellSignal and showBDStrategy
    string bd_tip = "Signal: BD CANDLE SELL\n----------------------\nBD Candle Date: " + str.format_time(bd_time, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nBD Low: " + str.tostring(bd_low, "#.##") + "\nLogic: Open > Lower BB → Close < Lower BB\n→ High touched EMA 9 (±" + str.tostring(bd_ema9TouchPct) + "%)\nEMA9 Retest Date: " + str.format_time(bd_retestTime, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nEMA9 Retest Low: " + str.tostring(bd_retestLow, "#.##") + "\n→ " + bd_ltfConfirmTf + "-min close broke Retest Low\nSignal Date: " + str.format_time(bd_signalTime, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nSignal Close: " + str.tostring(close, "#.##")

    label.new(bar_index, high,
              text      = "▼",
              color     = color.new(color.orange, 100),
              style     = label.style_none,
              textcolor = color.orange,
              tooltip   = bd_tip,
              yloc      = yloc.abovebar,
              size      = size.huge)


// ============================================================
// === Bullish BD Candle Buy Strategy (Mirror of Bearish) =====
// ============================================================

// --- Inputs ---
showBullBDStrategy   = input.bool(true,  title="Show Bullish BD Candle Buy Strategy", group="Bullish BD Candle Strategy")
bull_ema9TouchPct    = input.float(1.5,  title="EMA 9 Touch Tolerance (%)",           group="Bullish BD Candle Strategy", minval=0.1, step=0.1, tooltip="Low of candle must come within this % of EMA 9 to count as a touch.")
bull_maxWatchBars    = input.int(20,     title="Max Bars to Wait (each phase)",        group="Bullish BD Candle Strategy", minval=1)
bull_ltfConfirmTf    = input.string("15","LTF Confirmation Timeframe",                group="Bullish BD Candle Strategy", options=["1","3","5","10","15","30","45","60"])

// --- Bullish BD Candle Detection ---
bool isBullBDCandle = open < bbUpper and close > bbUpper

// --- LTF Data ---
ltfCloses15Bull = request.security_lower_tf(syminfo.tickerid, bull_ltfConfirmTf, close)
ltfTimes15Bull  = request.security_lower_tf(syminfo.tickerid, bull_ltfConfirmTf, time)

// --- Helper: 15-min close ABOVE a level ---
bull_ltfBrokeHigh(lvl) =>
    bool broke = false
    int  brokeIdx = -1
    if array.size(ltfCloses15Bull) > 0
        for _i = 0 to array.size(ltfCloses15Bull) - 1
            if array.get(ltfCloses15Bull, _i) > lvl
                broke    := true
                brokeIdx := _i
                break
    [broke, brokeIdx]

// --- Helper: 15-min close BELOW a level (for cancel confirmation) ---
bull_ltfBrokeLow(lvl) =>
    bool broke = false
    if array.size(ltfCloses15Bull) > 0
        for _i = 0 to array.size(ltfCloses15Bull) - 1
            if array.get(ltfCloses15Bull, _i) < lvl
                broke := true
                break
    broke

// --- State Variables ---
var int   bull_phase        = 0
var float bull_high         = na
var float bull_low          = na
var int   bull_phaseBar     = 0
var int   bull_time         = 0
var float bull_retestHigh   = na
var int   bull_retestTime   = 0
var int   bull_signalTime   = 0
var bool  bull_justDetected = false
var int   bull_cancelPhase  = 0
var float bull_cancelLow    = na

// --- Phase 0 → 1 : Bullish BD Candle detected ---
bull_justDetected := false
if bull_phase == 0 and isBullBDCandle
    bull_phase        := 1
    bull_high         := high
    bull_low          := low
    bull_phaseBar     := bar_index
    bull_time         := time
    bull_justDetected := true

// --- Cancel logic: candle closes below EMA 9 → 15-min confirms below that candle's low ---
bool bull_cancelNow = false

if (bull_phase == 1 or bull_phase == 2)
    if bull_cancelPhase == 0 and close < t_ema9
        bull_cancelPhase := 1
        bull_cancelLow   := low

    if bull_cancelPhase == 1
        if bull_ltfBrokeLow(bull_cancelLow)
            bull_cancelNow      := true
            bull_cancelPhase    := 0
            bull_cancelLow      := na

if bull_phase == 0
    bull_cancelPhase := 0
    bull_cancelLow   := na
bool bull_buySignal = false
// --- Phase 1 : Watch for EMA 9 retest (Low within 1.5% of EMA 9) ---
if bull_phase == 1
    int barsSinceBull = bar_index - bull_phaseBar

    if bull_cancelNow
        bull_phase := 0
    else if close < t_ema9
        bull_phase := 0
    else if barsSinceBull >= bull_maxWatchBars
        bull_phase := 0
    else
        float ema9Val   = t_ema9
        float touchDiff = math.abs(low - ema9Val) / ema9Val * 100
        if touchDiff <= bull_ema9TouchPct and bar_index != bull_phaseBar
            bull_phase      := 2
            bull_phaseBar   := bar_index
            bull_retestHigh := high
            bull_retestTime := time

            // If retest candle itself closes above BO candle High → check 15-min immediately
            if close > bull_high
                [broke, brokeIdx] = bull_ltfBrokeHigh(bull_retestHigh)
                if broke
                    bull_buySignal  := true
                    bull_phase      := 0
                    bull_signalTime := array.get(ltfTimes15Bull, brokeIdx)
                else
                    // 15-min hasn't confirmed yet — stay in phase 2 but with retest high already set
                    bull_phase := 2

// --- Phase 2 : Armed — watch for 15-min close above retest candle High ---

if bull_phase == 2
    int barsSinceTouch = bar_index - bull_phaseBar

    if bull_cancelNow
        bull_phase := 0
    else if barsSinceTouch >= bull_maxWatchBars
        bull_phase := 0
    else
        [broke, brokeIdx] = bull_ltfBrokeHigh(bull_retestHigh)
        if broke
            bull_buySignal  := true
            bull_phase      := 0
            bull_signalTime := array.get(ltfTimes15Bull, brokeIdx)

// --- Bullish BD Candle Marker ---
plotshape(series = showBullBDStrategy ? bull_justDetected : na,
          title     = "Bullish BO Candle",
          location  = location.belowbar,
          color     = color.new(color.aqua, 0),
          style     = shape.diamond,
          size      = size.tiny,
          text      = "BO+",
          textcolor = color.aqua)

// --- Buy Signal Label ---
if bull_buySignal and showBullBDStrategy
    string bull_tip = "Signal: BO CANDLE BUY\n---------------------\nBO Candle Date: " + str.format_time(bull_time, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nBO High: " + str.tostring(bull_high, "#.##") + "\nLogic: Open < Upper BB → Close > Upper BB\n→ Low touched EMA 9 (±" + str.tostring(bull_ema9TouchPct) + "%)\nEMA9 Retest Date: " + str.format_time(bull_retestTime, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nEMA9 Retest High: " + str.tostring(bull_retestHigh, "#.##") + "\n→ " + bull_ltfConfirmTf + "-min close broke Retest High\nSignal Date: " + str.format_time(bull_signalTime, "dd-MMM-yyyy HH:mm", syminfo.timezone) + "\nSignal Close: " + str.tostring(close, "#.##")
    label.new(bar_index, low,
              text      = "▲",
              color     = color.new(color.aqua, 100),
              style     = label.style_none,
              textcolor = color.aqua,
              tooltip   = bull_tip,
              yloc      = yloc.belowbar,
              size      = size.huge)
````
