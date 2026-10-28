# FRF

- url: https://www.tradingview.com/script/6ow6h4fG/
- type: indicator
- pine_id: PUB;43a1fa1c714f45c3a425a450443a594f
- version: 1.0

## Description

Flat Range Finder (FRF) 

FRF is a high-performance analysis tool developed to detect consolidation (sideways movement) zones in the market.

About FRF Drawing

Purpose and Usage:
The primary purpose of the FRF drawing is to objectively identify zones where the price is compressed within a channel without forming a significant trend over a certain period. This channel allows you to visualize the "uncertain" or "rest" phase of the market.

Update Mechanism:
The FRF drawing periodically scans within the "Min FRF Search Length" and "MAX FRF Search Length" range defined by the system. At each new bar close, the most appropriate channel length is recalculated using the "Channel Fixed R" coefficient. If a stronger consolidation structure forms in the current data, the channel automatically updates itself to adapt to this new data.


Fibonacci & Risk/Reward Box

This feature helps you determine entry, target, and stop-loss levels by using the boundaries of the detected channel.

Why and How to Use It?

    Why: In moments of market uncertainty, it provides a disciplined Risk/Reward management based on the channel's own internal dynamics (statistical deviations) rather than arbitrary levels.

    How: Activate the box by selecting "Long" or "Short" from the "Position Mode" setting. The box uses the 0.236 Fibonacci ratio as the entry level. The badges on the box dynamically display the current Open P&L status and the Risk/Reward Ratio at the end of the channel.

⚠️ WARNING: THE FIBONACCI & RISK BOX IS AUTOMATICALLY RECALCULATED UPON EVERY NEW CHANNEL DETECTION OR CHANGE IN PRICE DATA. PREVIOUS BOXES AND LABELS ARE DELETED AND REDRAWN ACCORDING TO THE MOST CURRENT CHANNEL DATA. TO AVOID LOSING YOUR PREVIOUS TRADE ANALYSES, ENSURE YOU ARE TRACKING THE LATEST BOX DATA.
Technical Specifications of the Indicator

FRF is equipped with the following capabilities within the classic TradingView library:

    MTF (Multi-Timeframe) Support: The indicator can process data from a different timeframe regardless of the current timeframe. You can select your desired TF by activating the Enable MTF option.

    Dynamic Channel Fixed R Analysis: This is a statistical metric used to determine the strength of the consolidation. You can optimize how "flat" the channel should be using the Target Threshold <= this setting.

    Breakout Alerts: When the upper or lower boundaries of the channel are broken by the body of a candle, the indicator triggers the alert() function to send you a notification.

    Advanced Visualizations:

        Debug Table: You can view the statistical data of the channel in real-time in the corner of your screen.

        Channel Customization: You can fully adjust the channel line style, transparency, and fill colors according to your personal chart preferences.

        Midline: You can display the middle baseline within the channel, allowing you to distinguish more clearly which half of the channel the price is dominant in.

    Debugging: You can toggle the labels on the bars to understand the indicator's operational logic by using the Show Debug Label option.

This indicator is not a prediction tool, but a data-driven channel detection engine.

## Source Code

````pine
//@version=6
indicator("FRF", overlay=true, max_bars_back=1200)

sourceInput = close

// --- Inputs ---

// [ GRUP 0: MTF Settings ]
bool   useMTF       = input.bool(false, "Enable MTF (Use Another Timeframe's Bars)", group="MTF Settings", tooltip="When enabled, the FRF engine uses the selected timeframe's own bars, including how far back to look.")
string mtfTimeframe = input.timeframe("240", "MTF Timeframe", group="MTF Settings", tooltip="E.g.: 60 (1H), 240 (4H), D (Daily). This setting has no effect when useMTF is disabled.")

// [ GRUP 3: Flat Range Finder (FRF) ]
float targetPearsonR = input.float(0.5, "Target Threshold <= this", step=0.01, group="Flat Range Finder (FRF)", tooltip="Among all lengths in range, the length with the lowest/farthest negative r that still satisfies r <= this value is selected as the flat range.")
int adaptiveMinLen = input.int(10, "Min FRF Search Length", minval=5, group="Flat Range Finder (FRF)", tooltip="The shortest period to look back for consolidation detection.")
int adaptiveMaxLen = input.int(500, "MAX FRF Search Length", minval=5, group="Flat Range Finder (FRF)", tooltip="The longest period to look back for consolidation detection.")
int adaptiveStep = input.int(1, "Search Step", minval=1, group="Flat Range Finder (FRF)", tooltip="Scan step interval to optimize calculation load.")
color adaptiveChColor = input.color(color.rgb(200, 78, 34), "FRF (Auto) Channel Color", group="Flat Range Finder (FRF)", tooltip="Color of the automatically detected range zone.")

// [ GRUP 4: FRF Crossover Labels ]
bool showCrossLabelsFRF = input.bool(true, "Show FRF Crossover Labels", group="FRF Crossover Labels", tooltip="Displays the active length of the consolidation zone using labels above/below the bar.")
string threshModeFRF = input.string("Channel Fixed R", "Threshold Source", options=["Manual", "Channel Fixed R"], group="FRF Crossover Labels", tooltip="Manual: Uses the 'FRF Threshold' value below. Channel Fixed R: Automatically uses the 'Target Threshold <= this' (fixed channel R) value from the Flat Range Finder group.")
float threshFRFInput = input.float(0.05, "FRF Threshold (Manual)", step=0.01, group="FRF Crossover Labels", tooltip="Used when Threshold Source = Manual.")

// [ GRUP 1: FRF Channel Configuration ]
float devMultiplier = 2
string lineStyle1 = input.string("Solid", "Line Style", options=["Solid", "Dotted", "Dashed"], group="FRF Channel Configuration", tooltip="Style of channel border lines (Solid, Dotted, Dashed).")
string extendStyle = input.string("Extend Right", "Extend Direction", options=["Extend Right", "Extend Both", "Extend None", "Extend Left"], group="FRF Channel Configuration", tooltip="Direction to extend lines (Right, Left, Both, None).")
int channelTransparency = input.int(40, "Border Transparency", minval=0, maxval=100, group="FRF Channel Configuration", tooltip="Transparency level of the border lines.")
int fillTransparency = input.int(93, "Fill Transparency", minval=0, maxval=100, group="FRF Channel Configuration", tooltip="Transparency level of the channel background fill.")

// [ GRUP 2: Midline Settings ]
bool showMidline = input.bool(true, "Display FRF Midline", group="Midline Settings", tooltip="Displays the middle baseline on the chart.")
color midlineColor = input.color(color.gray, "Midline Color", group="Midline Settings", tooltip="Color of the midline.")
string midLineStyle = input.string("Dashed", "Midline Style", options=["Dotted", "Solid", "Dashed"], group="Midline Settings", tooltip="Style of the midline.")
int midTransp = input.int(50, "Midline Transparency", minval=0, maxval=100, step=10, group="Midline Settings", tooltip="Transparency level of the midline.")

// [ GRUP 6: Fibonacci & Risk/Reward Box ]
string posMode     = input.string("Long", "Position Mode", options=["Long", "Short"], group="Fibonacci & Risk Box", tooltip="Long: Entry from 0.236 at the bottom, Target at the upper line. Short: Entry from 0.236 at the top, Target at the lower line.")
bool showFib       = input.bool(true, "Show Fibonacci & Risk Box", group="Fibonacci & Risk Box", tooltip="Draws Fib levels, level values, and Target/Stop Loss zones over the channel.")
color fibColor     = input.color(color.rgb(76, 175, 80), "Fib Line Color", group="Fibonacci & Risk Box", tooltip="Color of the Fibonacci lines.")
string fibLineStyle = input.string("Dotted", "Fib Line Style", options=["Solid", "Dotted", "Dashed"], group="Fibonacci & Risk Box")
int fibTransp      = input.int(30, "Fib Line Transparency", minval=0, maxval=100, group="Fibonacci & Risk Box")
bool showFibLabels = input.bool(true, "Show Level Values", group="Fibonacci & Risk Box", tooltip="Displays Fib ratios and price level values next to the lines.")
bool showRRDetails = input.bool(true, "Show Risk/Reward Badges", group="Fibonacci & Risk Box", tooltip="Adds Target, Stop, Open P&L, and Risk/Reward Ratio text badges to the channel.")
color targetColor  = input.color(color.rgb(8, 153, 129), "Target Zone Color", group="Fibonacci & Risk Box", tooltip="Box fill and badge color for the target zone.")
color stopColor    = input.color(color.rgb(242, 54, 69), "Stop Loss Color", group="Fibonacci & Risk Box", tooltip="Box fill and badge color for the stop loss zone.")
int boxTransp      = input.int(80, "Box Transparency", minval=0, maxval=100, group="Fibonacci & Risk Box")

// [ GRUP 5: Debug Info ]
bool   showDebugLabel = input.bool(false, "Show Debug Label", group="Debug Info", tooltip="Displays FRF debug info as a label on the bar.")
bool   showDebugTable = input.bool(true, "Show Debug Table", group="Debug Info", tooltip="Displays FRF debug info as a table in the corner of the screen.")
string debugTablePos  = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Debug Info")
string debugTableSize = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group="Debug Info")


// --- MTF: Collect actual bar array from the selected timeframe ---
f_getMTFArray(int length) =>
    var float[] a = array.new_float(0)
    array.push(a, close)
    if array.size(a) > length
        array.shift(a)
    a

mtfArr = useMTF ? request.security(syminfo.tickerid, mtfTimeframe, f_getMTFArray(adaptiveMaxLen), lookahead=barmerge.lookahead_off) : na
int  mtfArrSize = useMTF and not na(mtfArr) ? array.size(mtfArr) : 0
bool mtfReady   = not useMTF or mtfArrSize >= adaptiveMaxLen


// --- Line Extension Setup ---
var EXTEND_STYLE = extend.right
EXTEND_STYLE := switch extendStyle
    "Extend Right" => extend.right
    "Extend Both"  => extend.both
    "Extend None"  => extend.none
    => extend.left

// --- Debug Table Position/Size Setup ---
var DEBUG_TABLE_POS = position.top_right
DEBUG_TABLE_POS := switch debugTablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    => position.bottom_left

var DEBUG_TABLE_SIZE = size.normal
DEBUG_TABLE_SIZE := switch debugTableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    => size.normal

// --- Flat Range Finder (FRF): Drawing State Variables ---
var line adp_baseLine     = na
var line adp_upperLine    = na
var line adp_lowerLine    = na
var linefill adp_upperFill = na
var linefill adp_lowerFill = na
var label adp_pearsonLabel = na
var label adp_debugLabel  = na
var table adp_debugTable  = na
var line adp_midLine      = na
var label frf_crossLabel   = na
var float prevPrFRF       = na

// Memory Variables for Fib Lines, Labels, and Target/SL Fills
var line[] fibLines = array.new_line(0)
var label[] fibLabels = array.new_label(0)
var linefill targetFill = na
var linefill stopFill = na

// Risk / Reward Badge Labels
var label targetInfoLabel = na
var label stopInfoLabel   = na
var label middleInfoLabel = na

// Last channel line coordinates to be kept in memory
var float active_upperEndPrice = na
var float active_lowerEndPrice = na

// --- Flat Range Finder (FRF): Search + Draw ---
float bestR = na
int   bestLen = na
float bestStdDev = na
float bestSlope = na
float bestInt = na
float rawMinR = na
int   rawMinLen = na

if barstate.islast and mtfReady
    for L = adaptiveMinLen to adaptiveMaxLen by adaptiveStep
        int n1L = L - 1
        float sumX = 0.0, sumXX = 0.0, sumYX = 0.0, sumY = 0.0
        for i = 1 to L by 1
            float val = na
            if useMTF
                val := array.get(mtfArr, mtfArrSize - i)
            else
                val := sourceInput[i - 1]
            sumX  += i
            sumXX += i * i
            sumYX += i * val
            sumY  += val
        float slopeL     = nz((L * sumYX - sumX * sumY) / (L * sumXX - sumX * sumX))
        float avgL       = sumY / L
        float interceptL = avgL - slopeL * sumX / L + slopeL
        float sumDev = 0.0, sumDxx = 0.0, sumDyy = 0.0, sumDyx = 0.0
        float regL   = interceptL + slopeL * n1L * 0.5
        float lineV  = interceptL
        for i = 0 to n1L by 1
            float v = na
            if useMTF
                v := array.get(mtfArr, mtfArrSize - (i + 1))
            else
                v := sourceInput[i]
            float dxt = v - avgL
            float dyt = lineV - regL
            v := v - lineV
            lineV += slopeL
            sumDxx += dxt * dxt
            sumDyy += dyt * dyt
            sumDyx += dxt * dyt
            sumDev += v * v
        int dfL = math.max(1, L - 2)
        float unStdDevL = math.sqrt(sumDev / dfL)
        float divisorL  = sumDxx * sumDyy
        float rL        = divisorL > 0 ? (sumDyx / math.sqrt(divisorL)) : na

        if not na(rL)
            if na(rawMinR) or rL < rawMinR
                rawMinR := rL
                rawMinLen := L
                bestR := rL
                bestLen := L
                bestStdDev := unStdDevL
                bestSlope := slopeL
                bestInt := interceptL

    // Target R threshold check
    if not na(bestR) and bestR > targetPearsonR
        bestR := na
        bestLen := na

    string dbgTxt = na(bestLen) ? ("FRF: NO MATCH. Lowest Threshold=" + str.tostring(rawMinR, "#.###") + " @ len=" + str.tostring(rawMinLen) + " (target=" + str.tostring(targetPearsonR, "#.###") + ")") : ("FRF Range: len=" + str.tostring(bestLen) + " Threshold=" + str.tostring(bestR, "#.###"))
    color dbgBgColor = na(bestLen) ? color.red : color.orange

    if showDebugTable
        if na(adp_debugTable)
            adp_debugTable := table.new(DEBUG_TABLE_POS, 1, 1)
        table.cell(adp_debugTable, 0, 0, dbgTxt, bgcolor=color.new(dbgBgColor, 0), text_color=color.white, text_size=DEBUG_TABLE_SIZE)
    else
        if not na(adp_debugTable)
            table.delete(adp_debugTable)
            adp_debugTable := na

    float dbgLabelPrice = high
    bool  dbgLabelAbove = true

    // UPDATE IF NEW CHANNEL FOUND
    if not na(bestLen)
        float adp_startPrice = bestInt + bestSlope * (bestLen - 1)
        float adp_endPrice   = bestInt
        int   adp_startBar   = bar_index - bestLen + 1
        float adp_upperStartPrice = adp_startPrice + devMultiplier * bestStdDev
        float adp_upperEndPrice   = adp_endPrice   + devMultiplier * bestStdDev
        float adp_lowerStartPrice = adp_startPrice - devMultiplier * bestStdDev
        float adp_lowerEndPrice   = adp_endPrice   - devMultiplier * bestStdDev

        // Store active channel boundaries in memory
        active_upperEndPrice := adp_upperEndPrice
        active_lowerEndPrice := adp_lowerEndPrice

        if high > adp_upperEndPrice
            dbgLabelAbove := true
        else
            dbgLabelAbove := false
            dbgLabelPrice := adp_upperEndPrice

        styleAdp = lineStyle1 == "Dotted" ? line.style_dotted : lineStyle1 == "Dashed" ? line.style_dashed : line.style_solid
        color effAdpColor = na(bestR) ? adaptiveChColor : (math.abs(bestR) <= 0.05 ? color.green : color.black)
        color effAdpFillColor = na(bestR) ? adaptiveChColor : (math.abs(bestR) <= 0.05 ? color.orange : color.black)

        if na(adp_upperLine)
            adp_baseLine := line.new(adp_startBar, adp_startPrice, bar_index, adp_endPrice, width=0, color=color.new(effAdpFillColor, 100), extend=EXTEND_STYLE)
            adp_upperLine := line.new(adp_startBar, adp_upperStartPrice, bar_index, adp_upperEndPrice, width=1, extend=EXTEND_STYLE, color=color.new(effAdpColor, channelTransparency), style=styleAdp)
            adp_lowerLine := line.new(adp_startBar, adp_lowerStartPrice, bar_index, adp_lowerEndPrice, width=1, extend=EXTEND_STYLE, color=color.new(effAdpColor, channelTransparency), style=styleAdp)
            adp_upperFill := linefill.new(adp_upperLine, adp_baseLine, color=color.new(effAdpFillColor, fillTransparency))
            adp_lowerFill := linefill.new(adp_baseLine, adp_lowerLine, color=color.new(effAdpFillColor, fillTransparency))
        else
            line.set_xy1(adp_baseLine, adp_startBar, adp_startPrice)
            line.set_xy2(adp_baseLine, bar_index, adp_endPrice)
            line.set_extend(adp_baseLine, EXTEND_STYLE)

            line.set_xy1(adp_upperLine, adp_startBar, adp_upperStartPrice)
            line.set_xy2(adp_upperLine, bar_index, adp_upperEndPrice)
            line.set_color(adp_upperLine, color.new(effAdpColor, channelTransparency))
            line.set_extend(adp_upperLine, EXTEND_STYLE)
            line.set_style(adp_upperLine, styleAdp)

            line.set_xy1(adp_lowerLine, adp_startBar, adp_lowerStartPrice)
            line.set_xy2(adp_lowerLine, bar_index, adp_lowerEndPrice)
            line.set_color(adp_lowerLine, color.new(effAdpColor, channelTransparency))
            line.set_extend(adp_lowerLine, EXTEND_STYLE)
            line.set_style(adp_lowerLine, styleAdp)

            linefill.set_color(adp_upperFill, color.new(effAdpFillColor, fillTransparency))
            linefill.set_color(adp_lowerFill, color.new(effAdpFillColor, fillTransparency))

        styleMid2 = midLineStyle == "Dotted" ? line.style_dotted : midLineStyle == "Dashed" ? line.style_dashed : line.style_solid
        if showMidline
            if na(adp_midLine)
                adp_midLine := line.new(adp_startBar, adp_startPrice, bar_index, adp_endPrice, width=1, extend=EXTEND_STYLE, color=color.new(midlineColor, midTransp), style=styleMid2)
            else
                line.set_xy1(adp_midLine, adp_startBar, adp_startPrice)
                line.set_xy2(adp_midLine, bar_index, adp_endPrice)
                line.set_color(adp_midLine, color.new(midlineColor, midTransp))
                line.set_extend(adp_midLine, EXTEND_STYLE)
                line.set_style(adp_midLine, styleMid2)
        else
            if not na(adp_midLine)
                line.delete(adp_midLine)
                adp_midLine := na

        // --- FIBONACCI & RISK/REWARD BOX DRAWING ---
        // Clear old lines, labels, fills, and badges
        for l in fibLines
            line.delete(l)
        array.clear(fibLines)

        for lbl in fibLabels
            label.delete(lbl)
        array.clear(fibLabels)

        if not na(targetFill)
            linefill.delete(targetFill)
            targetFill := na

        if not na(stopFill)
            linefill.delete(stopFill)
            stopFill := na

        if not na(targetInfoLabel)
            label.delete(targetInfoLabel)
            targetInfoLabel := na

        if not na(stopInfoLabel)
            label.delete(stopInfoLabel)
            stopInfoLabel := na

        if not na(middleInfoLabel)
            label.delete(middleInfoLabel)
            middleInfoLabel := na

        if showFib
            bool isLong = posMode == "Long"
            
            // Standard Fibonacci Ratios Array
            float[] fibRatios = array.from(0.000, 0.236, 0.382, 0.500, 0.618, 0.786, 1.000)

            styleFib = fibLineStyle == "Dotted" ? line.style_dotted : fibLineStyle == "Dashed" ? line.style_dashed : line.style_solid
            line fibEntryLine = na
            float fibEntryStartPrice = na
            float fibEntryEndPrice   = na

            // Entry level is relatively 0.236 for both Long and Short
            float targetEntryRatio = 0.236

            for r in fibRatios
                // Long: Bottom to top (0 -> 1) | Short: Top to bottom (0 -> 1)
                float effectiveRatio = isLong ? r : (1.0 - r)

                float fibStart = adp_lowerStartPrice + (adp_upperStartPrice - adp_lowerStartPrice) * effectiveRatio
                float fibEnd   = adp_lowerEndPrice   + (adp_upperEndPrice   - adp_lowerEndPrice)   * effectiveRatio

                line fLine = line.new(adp_startBar, fibStart, bar_index, fibEnd, width=1, extend=EXTEND_STYLE, color=color.new(fibColor, fibTransp), style=styleFib)
                array.push(fibLines, fLine)

                if math.abs(r - targetEntryRatio) < 0.005
                    fibEntryLine       := fLine
                    fibEntryStartPrice := fibStart
                    fibEntryEndPrice   := fibEnd

                if showFibLabels
                    string rText = str.tostring(r, "#.###")
                    label fLabel = label.new(bar_index, fibEnd, rText + " (" + str.tostring(fibEnd, "#.##") + ")", style=label.style_label_left, yloc=yloc.price, color=color.new(color.black, 100), textcolor=fibColor, size=size.small)
                    array.push(fibLabels, fLabel)

            // Long / Short Based Target & Stop Loss Fills
            if not na(fibEntryLine)
                if isLong
                    targetFill := linefill.new(adp_upperLine, fibEntryLine, color.new(targetColor, boxTransp))
                    stopFill   := linefill.new(fibEntryLine, adp_lowerLine, color.new(stopColor, boxTransp))
                else
                    targetFill := linefill.new(fibEntryLine, adp_lowerLine, color.new(targetColor, boxTransp))
                    stopFill   := linefill.new(adp_upperLine, fibEntryLine, color.new(stopColor, boxTransp))

                // --- RISK / REWARD METRIC AND BADGE CALCULATIONS ---
                if showRRDetails
                    // Horizontal position of badges remains at the tip of the channel (bar_index)
                    int endBarIdx = bar_index

                    float targetDiff = 0.0
                    float stopDiff   = 0.0
                    float pnlDiff    = 0.0

                    if isLong
                        targetDiff := adp_upperEndPrice - fibEntryEndPrice
                        stopDiff   := fibEntryEndPrice - adp_lowerEndPrice
                        pnlDiff    := close - fibEntryEndPrice
                    else
                        targetDiff := fibEntryEndPrice - adp_lowerEndPrice
                        stopDiff   := adp_upperEndPrice - fibEntryEndPrice
                        pnlDiff    := fibEntryEndPrice - close

                    float targetPct  = (targetDiff / fibEntryEndPrice) * 100
                    string targetTxt = "Target: " + str.tostring(targetDiff, "#.##") + " (" + str.tostring(targetPct, "#.###") + "%)"

                    float stopPct    = (stopDiff / fibEntryEndPrice) * 100
                    string stopTxt   = "Stop: " + str.tostring(stopDiff, "#.##") + " (" + str.tostring(stopPct, "#.###") + "%)"

                    float rrRatio    = stopDiff != 0 ? (targetDiff / stopDiff) : 0.0
                    float pnlPct     = (pnlDiff / fibEntryEndPrice) * 100
                    string middleTxt = "Open P&L: " + str.tostring(pnlDiff, "#.##") + " (" + str.tostring(pnlPct, "#.###") + "%)\nRisk/Reward Ratio: " + str.tostring(rrRatio, "#.##")

                    if isLong
                        float midUpperPrice = adp_upperEndPrice
                        targetInfoLabel := label.new(endBarIdx, midUpperPrice, targetTxt, style=label.style_label_down, yloc=yloc.price, color=targetColor, textcolor=color.white, size=size.small)

                        float midLowerPrice = adp_lowerEndPrice
                        stopInfoLabel := label.new(endBarIdx, midLowerPrice, stopTxt, style=label.style_label_up, yloc=yloc.price, color=stopColor, textcolor=color.white, size=size.small)
                    else
                        float topPrice = adp_upperEndPrice
                        stopInfoLabel := label.new(endBarIdx, topPrice, stopTxt, style=label.style_label_down, yloc=yloc.price, color=stopColor, textcolor=color.white, size=size.small)

                        float bottomPrice = adp_lowerEndPrice
                        targetInfoLabel := label.new(endBarIdx, bottomPrice, targetTxt, style=label.style_label_up, yloc=yloc.price, color=targetColor, textcolor=color.white, size=size.small)

                    float midEntryPrice = fibEntryEndPrice
                    middleInfoLabel := label.new(endBarIdx, midEntryPrice, middleTxt, style=label.style_label_center, yloc=yloc.price, color=stopColor, textcolor=color.white, size=size.small)

        // Orange label (FRF badge) moved back to the channel start (bottom-left)
        string adpPearsonTxt = "FRF: " + str.tostring(bestLen) + " | Threshold: " + str.tostring(bestR, "#.###")
        if na(adp_pearsonLabel)
            adp_pearsonLabel := label.new(adp_startBar, adp_lowerStartPrice, adpPearsonTxt, style=label.style_label_up, yloc=yloc.price, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
        else
            label.set_xy(adp_pearsonLabel, adp_startBar, adp_lowerStartPrice)
            label.set_text(adp_pearsonLabel, adpPearsonTxt)
            label.set_color(adp_pearsonLabel, color.new(color.orange, 0))

    // --- FRF Channel Breakout Combined Alert (Candle Body Completely Outside Condition) ---
    if not na(active_upperEndPrice) and not na(active_lowerEndPrice)
        float bodyLow  = math.min(open, close)
        float bodyHigh = math.max(open, close)

        bool isUpperBodyBreak = bodyLow > active_upperEndPrice
        bool isLowerBodyBreak = bodyHigh < active_lowerEndPrice

        if isUpperBodyBreak or isLowerBodyBreak
            string bandType   = isUpperBodyBreak ? "Upper Band Body Breakout 🟢" : "Lower Band Body Breakout 🔴"
            string tfInfo     = useMTF ? mtfTimeframe : timeframe.period
            string timeStr    = str.format_time(time, "yyyy-MM-dd HH:mm", "UTC+3")
            
            string alertMessage = "🚨 FRF CHANNEL BODY BREAKOUT 🚨\n" +
                                  "------------------------------\n" +
                                  "Broken Zone   : " + bandType + "\n" +
                                  "Symbol        : " + syminfo.ticker + "\n" +
                                  "Timeframe     : " + tfInfo + "\n" +
                                  "Close Price   : " + str.tostring(close) + "\n" +
                                  "Date/Time     : " + timeStr + "\n" +
                                  "FRF Channel Len: " + str.tostring(nz(bestLen))

            alert(alertMessage, alert.freq_once_per_bar_close)

    if showDebugLabel
        ylocVal = dbgLabelAbove ? yloc.abovebar : yloc.price
        if na(adp_debugLabel)
            adp_debugLabel := label.new(bar_index, dbgLabelPrice, dbgTxt, style=label.style_label_down, yloc=ylocVal, color=color.new(dbgBgColor, 0), textcolor=color.white, size=size.normal)
        else
            label.set_xy(adp_debugLabel, bar_index, dbgLabelPrice)
            label.set_yloc(adp_debugLabel, ylocVal)
            label.set_text(adp_debugLabel, dbgTxt)
            label.set_color(adp_debugLabel, color.new(dbgBgColor, 0))
    else
        if not na(adp_debugLabel)
            label.delete(adp_debugLabel)
            adp_debugLabel := na

// --- FRF Crossover Labels ---
float effThreshFRF = threshModeFRF == "Channel Fixed R" ? targetPearsonR : threshFRFInput

if showCrossLabelsFRF and not na(bestR)
    bool crossUpFRF = not na(prevPrFRF) and prevPrFRF <= effThreshFRF and bestR > effThreshFRF
    bool crossDnFRF = not na(prevPrFRF) and prevPrFRF >= effThreshFRF and bestR < effThreshFRF
    color effFRFColor = math.abs(bestR) <= 0.05 ? color.green : adaptiveChColor

    if crossUpFRF
        label.delete(frf_crossLabel)
        frf_crossLabel := label.new(bar_index, high, "FRF " + str.tostring(bestLen), style=label.style_label_down, yloc=yloc.abovebar, color=color.new(effFRFColor, 0), textcolor=color.white, size=size.small)
    if crossDnFRF
        label.delete(frf_crossLabel)
        frf_crossLabel := label.new(bar_index, low, "FRF " + str.tostring(bestLen), style=label.style_label_up, yloc=yloc.belowbar, color=color.new(effFRFColor, 0), textcolor=color.white, size=size.small)
    prevPrFRF := bestR
````
