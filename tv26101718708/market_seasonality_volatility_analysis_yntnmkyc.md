# Market Seasonality & Volatility Analysis

- url: https://www.tradingview.com/script/YntNmKyC-Market-Seasonality-Volatility-Analysis/
- type: indicator
- pine_id: PUB;a64a663aedf842ebaa52f10504415df2
- version: 1.0

## Description

[url=https://www.tradingview.com/x/tk62oMr5/]https://www.tradingview.com/x/tk62oMr5/[/url]

📊 Market Seasonality & Volatility Dashboard [Modular]
💡 The Concept
In trading, "When" is just as important as "What." Every financial asset has a unique "Seasonal DNA"—historical patterns driven by institutional rebalancing, tax cycles, and human psychology.

This indicator is a high-performance statistical engine that maps the historical behavior of any asset across three time-dimensions: Monthly, Quarterly, and Daily. It transforms raw historical data into a clean, Excel-style dashboard that helps you align your trades with the "Path of Least Resistance."

🔍 Key Metrics
Avg Performance (Directional Bias): Calculates the average percentage return for every period.
Green/Red bars: Instantly identify which months or days have a strong historical bullish or bearish bias.
Volatility (Risk & Range): Calculates the average High-to-Low range as a percentage.
Blue bars: Identify "Explosive" periods vs. "Quiet" periods. Use this to adjust your stop-loss width and take-profit targets based on expected market movement.
🛠 Unique Features
Excel-Style Visual Bars: Uses normalized block characters (█) to create a visual "heatmap" of data. This allows you to spot statistical outliers instantly without reading every digit.
Fully Modular UI: Your chart, your rules. Use the settings menu to toggle specific sections (Monthly, Quarterly, Daily) or specific columns (Performance, Volatility) on and off. The table dynamically resizes to stay compact.
Regime-Based Lookback: Markets evolve. Choose between All Time data, or filter for the Last N Years to see if traditional seasonality still holds up in the current market regime.
High-Contrast Design: Features a solid, non-transparent background with customizable framing and sizing, ensuring the data is readable regardless of the price action happening behind it.
📈 How to Use the Data
Alignment: If you are looking for a Long swing trade, check if the current Month and Quarter are historically positive. Trading with the seasonal wind at your back increases your probability.
The "Volatile Wednesday": If the "Daily" section shows massive Volatility bars for a specific day, prepare for wider price swings. Use a wider stop-loss to avoid being "wicked out" by noise.
Quarterly Rotations: Use the Quarterly section to prepare for broader institutional shifts (e.g., the Q1 "January Effect" or the Q3 "Summer Lull").
Customization: Day traders can hide Monthly/Quarterly stats to focus purely on Daily Volatility, while Investors can hide Daily/Volatility stats for a clean view of long-term performance.
⚙️ Settings Overview
Visibility: Toggle Monthly, Quarterly, Daily, Performance, or Volatility metrics.
Lookback: Set custom Year or Bar limits to analyze specific market eras.
Scaling: Choose table sizes from "Tiny" to "Huge" and adjust the maximum width of visual data bars.
Style: Fully customizable colors for background, borders, text, and data bars.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Market Seasonality & Volatility Analysis", overlay = true)

// --- Groups ---
string G_TABLE  = "Table Visibility"
string G_STYLE  = "Table Style"
string G_LOOK   = "Lookback Settings"

// --- Inputs ---
bool showMonthly     = input.bool(true, "Show Monthly Stats", group = G_TABLE)
bool showQuarterly   = input.bool(true, "Show Quarterly Stats", group = G_TABLE)
bool showDaily       = input.bool(true, "Show Daily Stats", group = G_TABLE)
bool showPerfCol     = input.bool(true, "Show Performance Column", group = G_TABLE)
bool showVolCol      = input.bool(true, "Show Volatility Column", group = G_TABLE)

string lookbackType  = input.string("All Time", "Lookback Type", options = ["All Time", "Years", "Bars"], group = G_LOOK)
int    lookbackValue = input.int(2, "Lookback Value", minval = 1, group = G_LOOK)

string tablePosInput  = input.string(position.top_right, "Table Position", options = [position.top_right, position.bottom_right, position.top_left, position.bottom_left, position.middle_right, position.middle_left, position.bottom_center, position.top_center], group = G_STYLE)
string tableSizeInput = input.string("Small", "Overall Table Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_STYLE)
int    barWidthInput  = input.int(8, "Visual Bar Max Length", minval = 1, maxval = 30, group = G_STYLE)
color  posColorInput  = input.color(#089981, "Positive Color", group = G_STYLE)
color  negColorInput  = input.color(#f23645, "Negative Color", group = G_STYLE)
color  volColorInput  = input.color(#5b9cf6, "Volatility Color", group = G_STYLE)
color  txtColorInput  = input.color(color.black, "Text Color", group = G_STYLE)
color  tableBgInput   = input.color(color.white, "Table Background", group = G_STYLE)
color  frameColorInput = input.color(color.gray, "Frame/Border Color", group = G_STYLE)

// --- Arrays ---
var float[] monthlyReturns = array.new_float(12, 0.0)
var float[] monthlyVol     = array.new_float(12, 0.0)
var int[]   monthlyCounts  = array.new_int(12, 0)

var float[] quarterlyReturns = array.new_float(4, 0.0)
var float[] quarterlyVol     = array.new_float(4, 0.0)
var int[]   quarterlyCounts  = array.new_int(4, 0)

var float[] dailyReturns   = array.new_float(7, 0.0)
var float[] dailyVol       = array.new_float(7, 0.0)
var int[]   dailyCounts    = array.new_int(7, 0)

var string[] monthNames   = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
var string[] quarterNames = array.from("Q1", "Q2", "Q3", "Q4")
var string[] dayNames     = array.from("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

// --- State ---
var float monthOpenPrice   = na
var float quarterOpenPrice = na
var float dayOpenPrice     = na
var float monthHigh = 0.0
var float monthLow = 1e12
var float quarterHigh = 0.0
var float quarterLow = 1e12

// --- Logic ---
float startTimeThreshold = timenow - (lookbackValue * 31536000000)
bool isWithinLookback = switch lookbackType
    "All Time" => true
    "Years"    => time >= startTimeThreshold
    "Bars"     => (last_bar_index - bar_index) <= lookbackValue
    => true

int m = month(time)
int q = math.ceil(m / 3.0)
int d = dayofweek(time)

bool isNewMonth   = ta.change(m) != 0
bool isNewQuarter = ta.change(q) != 0
bool isNewDay     = ta.change(d) != 0

if isWithinLookback and not isWithinLookback[1]
    monthOpenPrice := open
    quarterOpenPrice := open
    dayOpenPrice := open
    monthHigh := high
    monthLow := low
    quarterHigh := high
    quarterLow := low

if isWithinLookback
    if isNewMonth
        if not na(monthOpenPrice)
            int prevIdx = month(time[1]) - 1
            array.set(monthlyReturns, prevIdx, array.get(monthlyReturns, prevIdx) + (close[1] - monthOpenPrice) / monthOpenPrice * 100)
            array.set(monthlyVol, prevIdx, array.get(monthlyVol, prevIdx) + (monthHigh - monthLow) / monthOpenPrice * 100)
            array.set(monthlyCounts, prevIdx, array.get(monthlyCounts, prevIdx) + 1)
        monthOpenPrice := open
        monthHigh := high
        monthLow := low
    else
        monthHigh := math.max(monthHigh, high)
        monthLow := math.min(monthLow, low)

    if isNewQuarter
        if not na(quarterOpenPrice)
            int prevIdx = int(math.ceil(month(time[1]) / 3.0) - 1)
            array.set(quarterlyReturns, prevIdx, array.get(quarterlyReturns, prevIdx) + (close[1] - quarterOpenPrice) / quarterOpenPrice * 100)
            array.set(quarterlyVol, prevIdx, array.get(quarterlyVol, prevIdx) + (quarterHigh - quarterLow) / quarterOpenPrice * 100)
            array.set(quarterlyCounts, prevIdx, array.get(quarterlyCounts, prevIdx) + 1)
        quarterOpenPrice := open
        quarterHigh := high
        quarterLow := low
    else
        quarterHigh := math.max(quarterHigh, high)
        quarterLow := math.min(quarterLow, low)

    if isNewDay
        if not na(dayOpenPrice)
            int prevIdx = dayofweek(time[1]) - 1
            array.set(dailyReturns, prevIdx, array.get(dailyReturns, prevIdx) + (close[1] - dayOpenPrice) / dayOpenPrice * 100)
            array.set(dailyVol, prevIdx, array.get(dailyVol, prevIdx) + (high[1] - low[1]) / dayOpenPrice * 100)
            array.set(dailyCounts, prevIdx, array.get(dailyCounts, prevIdx) + 1)
        dayOpenPrice := open

// --- Table Generation ---
if barstate.islast
    int numCols = 1 + (showPerfCol ? 1 : 0) + (showVolCol ? 1 : 0)
    int numRows = (showMonthly ? 13 : 0) + (showQuarterly ? 5 : 0) + (showDaily ? 8 : 0)
    
    if numRows > 0
        table statsTable = table.new(tablePosInput, numCols, numRows, frame_color = frameColorInput, frame_width = 1, border_color = frameColorInput, border_width = 1)
        
        string tsize = switch tableSizeInput
            "Tiny"   => size.tiny
            "Small"  => size.small
            "Normal" => size.normal
            "Large"  => size.large
            "Huge"   => size.huge
            => size.small
            
        color headerBg = color.new(frameColorInput, 85)
        int rowOffset = 0

        // Column indexing
        int perfColIdx = showPerfCol ? 1 : -1
        int volColIdx  = showVolCol ? (showPerfCol ? 2 : 1) : -1

        if showMonthly
            table.cell(statsTable, 0, rowOffset, "Month", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showPerfCol
                table.cell(statsTable, perfColIdx, rowOffset, "Avg Perf.", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showVolCol
                table.cell(statsTable, volColIdx, rowOffset, "Volatility", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            rowOffset += 1
            
            float maxMRet = 0.0, maxMVol = 0.0
            for i = 0 to 11
                if array.get(monthlyCounts, i) > 0
                    maxMRet := math.max(maxMRet, math.abs(array.get(monthlyReturns, i) / array.get(monthlyCounts, i)))
                    maxMVol := math.max(maxMVol, array.get(monthlyVol, i) / array.get(monthlyCounts, i))
            
            for i = 0 to 11
                float cnt = array.get(monthlyCounts, i)
                float avg = cnt > 0 ? array.get(monthlyReturns, i) / cnt : 0.0
                float vol = cnt > 0 ? array.get(monthlyVol, i) / cnt : 0.0
                
                float r = maxMRet != 0 ? math.abs(avg) / maxMRet : 0
                string bR = ""
                if r > 0
                    for k = 1 to math.min(barWidthInput, math.round(r * barWidthInput))
                        bR += "█"
                
                float vR = maxMVol != 0 ? math.abs(vol) / maxMVol : 0
                string bV = ""
                if vR > 0
                    for k = 1 to math.min(barWidthInput, math.round(vR * barWidthInput))
                        bV += "█"

                table.cell(statsTable, 0, rowOffset + i, array.get(monthNames, i), bgcolor = tableBgInput, text_color = txtColorInput, text_size = tsize, text_halign = text.align_left)
                if showPerfCol
                    table.cell(statsTable, perfColIdx, rowOffset + i, bR + " " + str.format("{0,number,#.##}%", avg), bgcolor = tableBgInput, text_color = avg >= 0 ? posColorInput : negColorInput, text_size = tsize, text_halign = text.align_left)
                if showVolCol
                    table.cell(statsTable, volColIdx, rowOffset + i, bV + " " + str.format("{0,number,#.##}%", vol), bgcolor = tableBgInput, text_color = volColorInput, text_size = tsize, text_halign = text.align_left)
            rowOffset += 12

        if showQuarterly
            table.cell(statsTable, 0, rowOffset, "Quarter", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showPerfCol
                table.cell(statsTable, perfColIdx, rowOffset, "Avg Perf.", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showVolCol
                table.cell(statsTable, volColIdx, rowOffset, "Volatility", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            rowOffset += 1
            
            float maxQRet = 0.0, maxQVol = 0.0
            for i = 0 to 3
                if array.get(quarterlyCounts, i) > 0
                    maxQRet := math.max(maxQRet, math.abs(array.get(quarterlyReturns, i) / array.get(quarterlyCounts, i)))
                    maxQVol := math.max(maxQVol, array.get(quarterlyVol, i) / array.get(quarterlyCounts, i))

            for i = 0 to 3
                float cnt = array.get(quarterlyCounts, i)
                float avg = cnt > 0 ? array.get(quarterlyReturns, i) / cnt : 0.0
                float vol = cnt > 0 ? array.get(quarterlyVol, i) / cnt : 0.0
                
                float r = maxQRet != 0 ? math.abs(avg) / maxQRet : 0
                string bR = ""
                if r > 0
                    for k = 1 to math.min(barWidthInput, math.round(r * barWidthInput))
                        bR += "█"
                
                float vR = maxQVol != 0 ? math.abs(vol) / maxQVol : 0
                string bV = ""
                if vR > 0
                    for k = 1 to math.min(barWidthInput, math.round(vR * barWidthInput))
                        bV += "█"

                table.cell(statsTable, 0, rowOffset + i, array.get(quarterNames, i), bgcolor = tableBgInput, text_color = txtColorInput, text_size = tsize, text_halign = text.align_left)
                if showPerfCol
                    table.cell(statsTable, perfColIdx, rowOffset + i, bR + " " + str.format("{0,number,#.##}%", avg), bgcolor = tableBgInput, text_color = avg >= 0 ? posColorInput : negColorInput, text_size = tsize, text_halign = text.align_left)
                if showVolCol
                    table.cell(statsTable, volColIdx, rowOffset + i, bV + " " + str.format("{0,number,#.##}%", vol), bgcolor = tableBgInput, text_color = volColorInput, text_size = tsize, text_halign = text.align_left)
            rowOffset += 4

        if showDaily
            table.cell(statsTable, 0, rowOffset, "Day", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showPerfCol
                table.cell(statsTable, perfColIdx, rowOffset, "Avg Perf.", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            if showVolCol
                table.cell(statsTable, volColIdx, rowOffset, "Volatility", bgcolor = headerBg, text_color = txtColorInput, text_size = tsize)
            rowOffset += 1
            
            float maxDRet = 0.0, maxDVol = 0.0
            for i = 0 to 6
                if array.get(dailyCounts, i) > 0
                    maxDRet := math.max(maxDRet, math.abs(array.get(dailyReturns, i) / array.get(dailyCounts, i)))
                    maxDVol := math.max(maxDVol, array.get(dailyVol, i) / array.get(dailyCounts, i))

            for i = 0 to 6
                float cnt = array.get(dailyCounts, i)
                float avg = cnt > 0 ? array.get(dailyReturns, i) / cnt : 0.0
                float vol = cnt > 0 ? array.get(dailyVol, i) / cnt : 0.0

                float r = maxDRet != 0 ? math.abs(avg) / maxDRet : 0
                string bR = ""
                if r > 0
                    for k = 1 to math.min(barWidthInput, math.round(r * barWidthInput))
                        bR += "█"
                
                float vR = maxDVol != 0 ? math.abs(vol) / maxDVol : 0
                string bV = ""
                if vR > 0
                    for k = 1 to math.min(barWidthInput, math.round(vR * barWidthInput))
                        bV += "█"

                table.cell(statsTable, 0, rowOffset + i, array.get(dayNames, i), bgcolor = tableBgInput, text_color = txtColorInput, text_size = tsize, text_halign = text.align_left)
                if showPerfCol
                    table.cell(statsTable, perfColIdx, rowOffset + i, bR + " " + str.format("{0,number,#.##}%", avg), bgcolor = tableBgInput, text_color = avg >= 0 ? posColorInput : negColorInput, text_size = tsize, text_halign = text.align_left)
                if showVolCol
                    table.cell(statsTable, volColIdx, rowOffset + i, bV + " " + str.format("{0,number,#.##}%", vol), bgcolor = tableBgInput, text_color = volColorInput, text_size = tsize, text_halign = text.align_left)
````
