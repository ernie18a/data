# Custom Timeframe Volume Profile

- url: https://www.tradingview.com/script/HNNqewug-Custom-Timeframe-Volume-Profile/
- type: indicator
- pine_id: PUB;42bfacf71699490ebaee9af6a04c7225
- version: 1.0

## Description

VP+ builds a volume profile for any higher timeframe you choose (4H, Daily, Weekly or anything custom) and draws it on your current chart. A new profile starts at the beginning of each HTF bar, so you can see where volume accumulated during that period and which prices the market accepted or rejected.

[b]What it shows[/b]
Volume histogram: horizontal bars showing how much volume traded at each price level within the HTF period.
POC (Point of Control): the row with the most volume, highlighted in its own color.
Value Area: the rows containing your chosen percentage of total volume (default 70%), shaded separately from the rest of the profile.
VAH / VAL lines: the top and bottom edges of the Value Area, drawn as lines across the period.
Developing profile: the current period's profile updates live as new bars form.

[b]How to use it[/b]
Treat the POC, VAH and VAL as reference levels. Price accepted inside the Value Area often rotates toward the POC, while a move that holds outside it can signal a shift in balance.
Prior-period VAH, VAL and POC often act as support or resistance in the next period.
Combine it with your own session, liquidity or structure levels for confluence.

[b]Settings[/b]
HTF Period: the timeframe each profile covers.
Number of Rows: profile resolution (5–100).
Max Width (Bars): how far the longest bar extends to the right.
Value Area %: share of volume included in the Value Area.
Show Historical Profiles: keep or hide previous periods.
VAH / VAL Lines: individual toggles, colors and widths (1–10), plus a shared style (solid, dashed or dotted) and a length option (period only, or extend right).
Style: colors for the Value Area rows, outside-VA rows, POC and row borders, plus border width.
Alert: fires when a new HTF period (and so a new profile) begins.

[b]Notes[/b]
Volume is assigned to each chart bar's close price, so accuracy depends on your chart timeframe. Lower timeframes (1m–5m) give a much finer profile than something like a 1H chart.
TradingView allows up to 500 boxes per indicator. A high row count with many historical profiles will hit that limit, and the oldest profiles will drop off. Lowering the row count or turning off historical profiles helps.
Calculation is limited to the last N bars (default 3000) to stay within Pine's history buffer. Lower it if you see a "historical offset" error.
The indicator needs volume data, so it won't work on symbols that don't provide it.

[i]For educational purposes only. Not financial advice.[/i]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © zacromancer

//@version=6
indicator('Custom Timeframe Volume Profile', shorttitle='VP+', overlay = true, max_bars_back = 5000, calc_bars_count = 5000, max_boxes_count = 500, max_lines_count = 500)

// --- Groups ---
string G_MAIN  = "Volume Profile Settings"
string G_STYLE = "Style"
string G_VA    = "VAH / VAL Lines"

// --- Inputs ---
string htfInput       = input.timeframe("D", "HTF Period", group = G_MAIN, tooltip = "The timeframe used to group the volume profile. Profiles reset at the start of each HTF bar (e.g., 02:00, 06:00 for 4H).")
int    rowCount       = input.int(80, "Number of Rows", minval = 5, maxval = 100, group = G_MAIN, tooltip = "Number of horizontal bars in the profile histogram. Note: High values combined with historical profiles may hit the 500-box limit quickly.")
int    widthScale     = input.int(50, "Max Width (Bars)", minval = 5, group = G_MAIN, tooltip = "Maximum width of the profile in number of bars on the chart.")
float  vaPercent      = input.float(70.0, "Value Area Volume %", minval = 0, maxval = 100, group = G_MAIN, tooltip = "The percentage of total volume to include in the Value Area.")
bool   showPrevious   = input.bool(true, "Show Historical Profiles", group = G_MAIN, tooltip = "Whether to keep profiles from previous periods on the chart.")
int    vpLookbackBars = input.int(3000, "Limit VP Calculation To Last N Bars", minval = 100, maxval = 4900, group = G_MAIN, tooltip = "Keeps the profile object tracking inside Pine's historical buffer limit (max_bars_back is hard-capped at 5000). Lower this further if you still hit a 'historical offset' error.")

color  vaColor        = input.color(color.new(#5b9cf6, 60), "Value Area Color", group = G_STYLE, tooltip = "Color for the rows inside the Value Area.")
color  outVaColor     = input.color(color.new(#056656, 90), "Outside VA Color", group = G_STYLE, tooltip = "Color for the rows outside the Value Area.")
color  pocColor       = input.color(color.new(#f23645, 20), "POC Color", group = G_STYLE, tooltip = "Color used to highlight the Point of Control (the row with the highest volume).")
color  borderCol      = input.color(color.new(#ffffff, 100), "Border Color", group = G_STYLE, tooltip = "Color of the row borders.")
int    borderWidth    = input.int(1, "Border Width", minval = 0, group = G_STYLE)

bool   showVAH        = input.bool(true, "Show VAH", inline = "vah", group = G_VA)
color  vahColor       = input.color(#860303, "", inline = "vah", group = G_VA)
int    vahWidth       = input.int(1, "Width", minval = 1, maxval = 10, inline = "vah", group = G_VA)
bool   showVAL        = input.bool(true, "Show VAL", inline = "val", group = G_VA)
color  valColor       = input.color(#860303, "", inline = "val", group = G_VA)
int    valWidth       = input.int(1, "Width", minval = 1, maxval = 10, inline = "val", group = G_VA)
string lineStyleInput = input.string("dotted", "Line Style", options = ["solid", "dashed", "dotted"], group = G_VA)
string lineExtInput   = input.string("Period", "Line Length", options = ["Period", "Extend Right"], group = G_VA, tooltip = "Period: each line spans only the bars of its own HTF period. Extend Right: lines continue to the right edge of the chart.")

// --- Helpers ---
getLineStyle(style) =>
    switch style
        'dotted' => line.style_dotted
        'dashed' => line.style_dashed
        => line.style_solid

string lnStyle  = getLineStyle(lineStyleInput)
string lnExtend = lineExtInput == "Extend Right" ? extend.right : extend.none

// --- Constants and Variables ---
var map<int, float> volMap = map.new<int, float>()
var int   startBar   = bar_index
var float htfHigh    = high
var float htfLow     = low
var box[] currentBoxes = array.new<box>()
var line[] vahLines    = array.new<line>()
var line[] valLines    = array.new<line>()

// Detect New HTF Period
bool isNewPeriod = ta.change(time(htfInput)) != 0

// Only build/refresh volume-profile state within the last N bars. This keeps the
// box-array tracking used by drawProfile() from needing a historical buffer that
// spans the whole dataset (which is what was tripping the "historical offset
// beyond the buffer's limit" error, since max_bars_back can't exceed 5000).
bool inVPWindow = bar_index >= last_bar_index - vpLookbackBars

// --- Function to Draw / Update a VAH or VAL line ---
// Each holder array keeps at most one line per profile period.
drawLevel(line[] holder, float price, int x1, int x2, color c, int w) =>
    if holder.size() == 0
        holder.push(line.new(x1, price, x2, price, color = c, width = w, style = lnStyle, extend = lnExtend))
    else
        line l = holder.get(0)
        line.set_xy1(l, x1, price)
        line.set_xy2(l, x2, price)
        line.set_color(l, c)
        line.set_width(l, w)

// --- Function to Draw Profile ---
// This function will draw or update the boxes based on the current volMap.
// endBar is the last bar of the profile's period (used for the VAH/VAL lines).
drawProfile(int endBar) =>
    float rangeHeight = htfHigh - htfLow
    float step = rangeHeight / rowCount

    if step > 0
        array<float> bucketVols = array.new<float>(rowCount, 0.0)
        float totalVol = 0.0
        float maxVol   = 0.0
        int   pocIdx   = 0

        int[] keysArray = volMap.keys()
        for k in keysArray
            float price = k * syminfo.mintick
            float vol   = volMap.get(k)
            int bucketIdx = math.min(rowCount - 1, math.max(0, int((price - htfLow) / step)))

            float newV = bucketVols.get(bucketIdx) + vol
            bucketVols.set(bucketIdx, newV)
            totalVol += vol

            if newV > maxVol
                maxVol := newV
                pocIdx := bucketIdx

        int vaLowIdx  = pocIdx
        int vaHighIdx = pocIdx
        float vaVol   = bucketVols.get(pocIdx)
        float targetVol = totalVol * (vaPercent / 100.0)

        if totalVol > 0
            while vaVol < targetVol and (vaLowIdx > 0 or vaHighIdx < rowCount - 1)
                float upVol   = vaHighIdx < rowCount - 1 ? bucketVols.get(vaHighIdx + 1) : 0.0
                float downVol = vaLowIdx > 0 ? bucketVols.get(vaLowIdx - 1) : 0.0

                if upVol >= downVol and vaHighIdx < rowCount - 1
                    vaHighIdx += 1
                    vaVol += upVol
                else if vaLowIdx > 0
                    vaLowIdx -= 1
                    vaVol += downVol
                else
                    break

        // VAH = top edge of the highest Value Area row, VAL = bottom edge of the lowest
        float vahPrice = htfLow + (vaHighIdx + 1) * step
        float valPrice = htfLow + vaLowIdx * step
        if showVAH
            drawLevel(vahLines, vahPrice, startBar, endBar, vahColor, vahWidth)
        if showVAL
            drawLevel(valLines, valPrice, startBar, endBar, valColor, valWidth)

        for i = 0 to rowCount - 1
            float bLow  = htfLow + i * step
            float bHigh = bLow + step
            float bVol  = bucketVols.get(i)

            if bVol > 0
                int x2 = startBar + int((bVol / math.max(1, maxVol)) * widthScale)
                bool isInVA = i >= vaLowIdx and i <= vaHighIdx
                color bCol = (i == pocIdx) ? pocColor : (isInVA ? vaColor : outVaColor)

                if array.size(currentBoxes) <= i
                    currentBoxes.push(box.new(startBar, bHigh, x2, bLow, border_color = borderCol, bgcolor = bCol, border_width = borderWidth))
                else
                    box b = currentBoxes.get(i)
                    box.set_lefttop(b, startBar, bHigh)
                    box.set_rightbottom(b, x2, bLow)
                    box.set_bgcolor(b, bCol)
                    box.set_border_color(b, borderCol)
                    box.set_border_width(b, borderWidth)
            else
                // If bucket is empty and we are reusing boxes, hide the box
                if array.size(currentBoxes) > i
                    box b = currentBoxes.get(i)
                    box.set_lefttop(b, startBar, 0)
                    box.set_rightbottom(b, startBar, 0)

// --- Logic: Data Collection & Reset ---
if inVPWindow
    if isNewPeriod
        // 1. Finalize the PREVIOUS period's profile before resetting
        // Only if there is data in the map. The previous period ended on the prior bar.
        if volMap.size() > 0
            drawProfile(bar_index - 1)

        // 2. Prepare for the NEW period
        if not showPrevious
            for b in currentBoxes
                box.delete(b)
            for l in vahLines
                line.delete(l)
            for l in valLines
                line.delete(l)
        currentBoxes.clear() // Always start a new set of box references so the
                              // previous period's boxes (if kept) stay untouched
        vahLines.clear()
        valLines.clear()
        volMap.clear()

        startBar := bar_index
        htfHigh  := high
        htfLow   := low

    // Update data for the current period
    htfHigh := math.max(htfHigh, high)
    htfLow  := math.min(htfLow, low)
    int tickKey = math.round(close / syminfo.mintick)
    volMap.put(tickKey, nz(volMap.get(tickKey)) + volume)

    // 3. Update the DEVELOPING profile on the last bar
    if barstate.islast
        drawProfile(bar_index)

// --- Alerts ---
alertcondition(isNewPeriod, "New HTF Period", "A new Volume Profile period has started.")
````
