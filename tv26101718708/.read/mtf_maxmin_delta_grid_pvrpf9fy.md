# MTF Max/Min Delta Grid

- url: https://www.tradingview.com/script/PVRPf9Fy-MTF-Max-Min-Delta-Grid/
- type: indicator
- pine_id: PUB;720c5634a0c540aa93c100ffe01dda9b
- version: 1.0

## Description

Description:
Overview
The Multi-Timeframe Max/Min Delta Grid is an advanced volume analysis tool designed to look inside the formation of a candle and extract the true buying and selling pressure. By utilizing a 1-second lower timeframe, this indicator calculates the raw intrabar volume delta and plots the absolute peak buying (Max Delta) and peak selling (Min Delta) pressure within a dynamic, multi-row heatmap table.

This tool is built for order flow and volume traders who want to identify hidden exhaustion, absorption, and aggressive participation without cluttering their main chart with traditional histograms.

How it Works (Underlying Logic)
Standard volume bars only tell you the total transacted volume at the end of a candle. This script goes deeper:

Micro-structure Tracking: It constantly queries the 1S (1-second) timeframe to calculate tick-by-tick Delta (Ask-traded volume vs. Bid-traded volume).

MTF Aggregation: It accumulates these 1-second delta values into a user-defined Higher Timeframe (e.g., a 5-minute block).

Extremes: Instead of just showing the closing delta, it isolates the highest positive delta (Max ▲) and lowest negative delta (Min ▼) achieved during the life of that candle.

The Heatmap Grid & Color Logic
To make data consumption intuitive, the indicator renders a clean, scrolling "Excel-like" grid anchored to the bottom right of the chart. The cells are dynamically color-coded based on the percentage of Max/Min Delta relative to the Total Volume of that specific timeframe:

White (<= 3%): Zero Threshold. When delta influence is negligible, the cell background turns white and forces a "0" reading to eliminate market noise.

Aqua / Pink (3% to 5%): Low Dominance. Highlights unusually weak buyer (Aqua) or seller (Pink) participation.

Green / Red Gradients (5% to 95%): Standard Scaling. The script uses a smooth color gradient. A 20% delta ratio will appear as a dark, muted green/red, while an 80% ratio will glow as a bright neon green/red, allowing your eyes to instantly gauge relative volume strength.

Dark Grid (>= 95%): Extreme Domination. If buyers or sellers completely overwhelm the bar, the cell turns distinctly dark, signaling an extreme imbalance.

Practical Application for Traders

Spotting Absorption: If price pushes into resistance and the grid prints a massive bright green Max Delta, but the candle ultimately closes as a bearish pin bar, it indicates aggressive buyers were absorbed by limit sellers.

Confirming Breakouts: A genuine breakout should be accompanied by a bright or dark-grid Max/Min Delta, confirming that aggressive market orders are supporting the move.

Exhaustion: Shrinking Max/Min Delta percentages (indicated by muted colors or White/Aqua/Pink thresholds) at swing highs/lows can signal a lack of interest and a potential reversal.

Features at a Glance

Smart Number Formatting: Converts large volume figures into readable formats (e.g., 15.4K, 1.2M) to keep the grid clean.

Auto Date Separators: Automatically inserts a dark blue date column whenever a new trading session/day begins, making historical review effortless.

Highly Customizable: Fully adjustable grid sizes (rows/columns), MTF selections, and adjustable percentage thresholds to fit varying asset classes and liquidities.

Disclaimer: This script is for educational and analytical purposes only. Volume delta is a leading context tool but should be combined with price action or other structural analysis methods. It does not guarantee profitable trading signals.

## Source Code

````pine
//@version=6
indicator("MTF Max/Min Delta Grid", overlay = false, max_bars_back = 5000)

// === INPUTS ===
// Grid Configuration
columns = input.int(46, "Columns", minval = 10, maxval = 60)
rows    = input.int(2, "Rows (Blocks)", minval = 1, maxval = 10)
domTf   = input.timeframe("5", "MTF Timeframe")

// Threshold Inputs
deltaThresh    = input.float(95, title="Dark Threshold (%) >=")
lowDomThresh   = input.float(5,  title="Aqua/Pink Threshold (%) <=")
maxMinThresh   = input.float(3,  title="Zero Value Threshold (%) <=")

// Colors
panelBg   = color.rgb(10, 11, 14)
headerBg  = color.rgb(24, 28, 34)
timeBg    = color.rgb(15, 30, 55)
textMain  = color.rgb(230, 230, 230)
textMuted = color.rgb(170, 170, 170)
borderCol = color.rgb(45, 50, 55)

// Table init (3 rows per block for Time, Max, Min)
var table dom = table.new(position.bottom_right, columns + 1, rows * 3, bgcolor = panelBg, frame_color = borderCol, border_width = 1)

// === 1-SECOND DELTA LOGIC ===
float vol1s = volume
float delta1s = 0.0

if close > close[1]
    delta1s := vol1s
else if close < close[1]
    delta1s := -vol1s

// Pull 1S data array for the current chart bar
deltaArray1s = request.security_lower_tf(syminfo.tickerid, "1S", delta1s)

// === MTF ACCUMULATION ===
// Check if a new higher timeframe bar has started
bool newDomBar = ta.change(time(domTf)) != 0

// We use 'var' to persist values across the bars until the next MTF bar starts
var float domCumDelta = 0.0
var float domMaxD     = 0.0
var float domMinD     = 0.0
var float domTotalVol = 0.0

if newDomBar
    domCumDelta := 0.0
    domMaxD     := 0.0
    domMinD     := 0.0
    domTotalVol := 0.0

// Accumulate the 1-second ticks strictly chronologically
if array.size(deltaArray1s) > 0
    for d in deltaArray1s
        domCumDelta += d
        domTotalVol += math.abs(d)
        domMaxD     := math.max(domMaxD, domCumDelta)
        domMinD     := math.min(domMinD, domCumDelta)

// === DATA STORAGE ARRAYS ===
int domTime = time(domTf)

var timesArr = array.new_int()
var maxArr   = array.new_float()
var minArr   = array.new_float()
var volArr   = array.new_float()

capacity = columns * rows

var renderTypes = array.new_int(capacity, -1)
var renderIdxs  = array.new_int(capacity, -1)

// Store data based on whether it is a new MTF bar or an updating real-time bar
if newDomBar
    array.push(timesArr, domTime)
    array.push(maxArr, domMaxD)
    array.push(minArr, domMinD)
    array.push(volArr, domTotalVol)
else
    int lastIdx = array.size(timesArr) - 1
    if lastIdx >= 0
        array.set(timesArr, lastIdx, domTime)
        array.set(maxArr, lastIdx, domMaxD)
        array.set(minArr, lastIdx, domMinD)
        array.set(volArr, lastIdx, domTotalVol)

// Maintain Array Sizes to avoid memory overflow
while array.size(timesArr) > capacity
    array.shift(timesArr)
    array.shift(maxArr)
    array.shift(minArr)
    array.shift(volArr)

// === FORMATTERS ===
formatNSEDate(int t) =>
    str.tostring(dayofmonth(t, "Asia/Kolkata"), "00") + "/" + str.tostring(month(t, "Asia/Kolkata"), "00")

formatNSETime(int t) =>
    str.tostring(hour(t, "Asia/Kolkata"), "00") + ":" + str.tostring(minute(t, "Asia/Kolkata"), "00")

formatVol(v) =>
    if v == 0
        "0"
    else if math.abs(v) >= 1000000
        str.tostring(v / 1000000, "#.##") + "M"
    else if math.abs(v) >= 1000
        str.tostring(v / 1000, "#.##") + "K"
    else
        str.tostring(v, "#")

// === RENDERING GRID ===
if barstate.islastconfirmedhistory or barstate.isrealtime
    table.clear(dom, 0, 0, columns, rows * 3 - 1)
    int sz = array.size(timesArr)

    for c = 0 to columns
        for r = 0 to rows * 3 - 1
            table.cell_set_width(dom, c, r, 100.0 / (columns + 1))

    // Pre-calculate visual layout to inject date columns seamlessly
    array.fill(renderTypes, -1)
    array.fill(renderIdxs, -1)
    
    int fillPos = capacity - 1
    int dataIdx = sz - 1

    while dataIdx >= 0 and fillPos >= 0
        array.set(renderTypes, fillPos, 0)
        array.set(renderIdxs, fillPos, dataIdx)
        fillPos -= 1

        if dataIdx > 0 and fillPos >= 0
            int t_curr = array.get(timesArr, dataIdx)
            int t_prev = array.get(timesArr, dataIdx - 1)
            
            if dayofmonth(t_curr, "Asia/Kolkata") != dayofmonth(t_prev, "Asia/Kolkata")
                array.set(renderTypes, fillPos, 1) 
                array.set(renderIdxs, fillPos, t_curr) 
                fillPos -= 1

        dataIdx -= 1

    // Render the Grid
    for block = 0 to rows - 1
        int rowBase = block * 3

        table.cell(dom, 0, rowBase,     "TIME",  bgcolor = headerBg, text_color = textMuted, text_size = size.small)
        table.cell(dom, 0, rowBase + 1, "Max ▲", bgcolor = headerBg, text_color = color.white, text_size = size.small)
        table.cell(dom, 0, rowBase + 2, "Min ▼", bgcolor = headerBg, text_color = color.white, text_size = size.small)

        for col = 0 to columns - 1
            
            int flatIdx = (rows - 1 - block) * columns + col
            int rType = array.get(renderTypes, flatIdx)
            int rVal  = array.get(renderIdxs, flatIdx)

            if rType == 0 
                int t       = array.get(timesArr, rVal)
                float mxD   = array.get(maxArr, rVal)
                float mnD   = array.get(minArr, rVal)
                float tVol  = array.get(volArr, rVal)

                // Percentages based on ratio (Delta Volume / Total Volume)
                float maxPct = tVol > 0 ? (mxD / tVol) * 100 : 0.0
                float minPct = tVol > 0 ? (math.abs(mnD) / tVol) * 100 : 0.0

                // Zero Check Booleans
                bool isMaxZero = maxPct <= maxMinThresh
                bool isMinZero = minPct <= maxMinThresh

                // Zero Threshold Force Logic (<= 3% prints 0)
                float finalMaxD = isMaxZero ? 0.0 : mxD
                float finalMinD = isMinZero ? 0.0 : mnD

                // Gradient Base Colors
                color baseGreen   = color.rgb(30, 90, 40)    // Deep green
                color brightGreen = color.rgb(0, 255, 100)   // Neon green
                color baseRed     = color.rgb(130, 25, 25)   // Deep red
                color brightRed   = color.rgb(255, 30, 60)   // Neon red
                color darkBg      = color.rgb(15, 15, 15)    // Dark for >= 95%

                // MAX Color Evaluation
                color bgMax = na
                color txtColMax = color.white
                
                if isMaxZero
                    bgMax := color.white
                    txtColMax := color.black
                else if maxPct >= deltaThresh
                    bgMax := darkBg
                    txtColMax := color.white
                else if maxPct <= lowDomThresh
                    bgMax := color.aqua
                    txtColMax := color.black
                else
                    // Gradation as per ratio exactly between 5% and 95%
                    bgMax := color.from_gradient(maxPct, lowDomThresh, deltaThresh, baseGreen, brightGreen)
                    txtColMax := color.white

                // MIN Color Evaluation
                color bgMin = na
                color txtColMin = color.white
                
                if isMinZero
                    bgMin := color.white
                    txtColMin := color.black
                else if minPct >= deltaThresh
                    bgMin := darkBg
                    txtColMin := color.white
                else if minPct <= lowDomThresh
                    bgMin := color.rgb(255, 105, 180) // Pink
                    txtColMin := color.black
                else
                    // Gradation as per ratio exactly between 5% and 95%
                    bgMin := color.from_gradient(minPct, lowDomThresh, deltaThresh, baseRed, brightRed)
                    txtColMin := color.white

                // Time Execution
                bool latest = (rVal == sz - 1)
                color timeColor = latest ? color.rgb(35,60,110) : timeBg

                // Draw Cells
                table.cell(dom, col + 1, rowBase, formatNSETime(t), bgcolor = timeColor, text_color = textMain, text_size = size.tiny)
                table.cell(dom, col + 1, rowBase + 1, formatVol(finalMaxD), bgcolor = bgMax, text_color = txtColMax, text_size = size.tiny)
                table.cell(dom, col + 1, rowBase + 2, formatVol(finalMinD), bgcolor = bgMin, text_color = txtColMin, text_size = size.tiny)
                
            else if rType == 1 
                int t = rVal
                color sepBg = color.rgb(25, 40, 60)
                
                table.cell(dom, col + 1, rowBase,     formatNSEDate(t), bgcolor = sepBg, text_color = color.white, text_size = size.normal)
                table.cell(dom, col + 1, rowBase + 1, "",               bgcolor = sepBg)
                table.cell(dom, col + 1, rowBase + 2, "",               bgcolor = sepBg)
                
                table.merge_cells(dom, col + 1, rowBase, col + 1, rowBase + 2)
                
            else 
                for rr = 0 to 2
                    table.cell(dom, col + 1, rowBase + rr, "", bgcolor = panelBg)
````
