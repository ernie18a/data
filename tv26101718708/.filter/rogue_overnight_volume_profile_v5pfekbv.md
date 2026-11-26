# Rogue Overnight Volume Profile

- url: https://www.tradingview.com/script/v5pFekBV-Rogue-Overnight-Volume-Profile/
- type: indicator
- pine_id: PUB;2d8a6108b8cd49138bb509e41cf748e4
- version: 3.0

## Description

[b]Rogue Overnight Volume Profile[/b]
The Rogue Overnight Volume Profile is an institutional-style overnight volume profile designed specifically for futures traders who use overnight auction structure to prepare for the Regular Trading Hours (RTH) session.

Unlike traditional session volume profiles that remain fixed throughout the day, Rogue Overnight Profile automatically builds the overnight distribution, identifies the most important price levels, and projects them into the current trading session for easy decision making.

Features:
[list]
[*]Overnight Volume Profile
[*]Automatically builds a complete volume profile during the overnight session.
[*]Adjustable profile resolution with up to 1,000 price rows.
[*]Value Area (default 70%)
[*]Point of Control (POC)
[*]Value Area High (OVAH)
[*]Value Area Low (OVAL)
[*]Customizable profile colors and placement.
[*]Dynamic Overnight Levels
[*]The indicator automatically calculates and plots:
[*]OVAH (Overnight Value Area High)
[*]OPOC (Overnight Point of Control)
[*]OVAL (Overnight Value Area Low)
[/list]
These levels begin at the start of the completed overnight profile and extend just beyond current price during the New York session, keeping the chart clean while maintaining important reference levels.

Historical overnight levels are retained for previous sessions to assist with market structure analysis.

[b]Developing Overnight Range:[/b]
Monitor the overnight auction as it forms with an optional shaded developing range, allowing traders to visualize overnight balance before the market opens.

[b]Weekly VWAP[/b]
Includes a built-in Weekly VWAP with customizable color and line width to provide higher-timeframe context and institutional bias.

[b]5-Period Moving Average[/b]
A configurable 5-period moving average (EMA or SMA) can be displayed to help identify short-term momentum and trend direction.

[b]First Touch Detection[/b]
Automatically identifies the first interaction with overnight profile levels during the New York session.

Supported first-touch signals include:
[list]
[*]OVAH First Touch
[*]OPOC First Touch
[*]OVAL First Touch
[/list]
These areas often act as important decision points where responsive buyers or sellers may enter the market.

[b]Break & Retest Detection[/b]
The indicator can also detect break-and-retest setups after price establishes acceptance above or below an overnight level.
Bullish and bearish retest opportunities are labeled automatically, making it easier to identify continuation setups around key profile references.

[b]Fully Customizable[/b]
Every major component can be enabled, disabled, or customized, including:
[list]
[*]Session times
[*]Profile resolution
[*]Value Area percentage
[*]Historical sessions displayed
[*]Colors
[*]Labels
[*]Weekly VWAP
[*]Moving Average
[*]Touch detection
[*]Retest detection
[/list]

[b]Designed For[/b]
[list]
[*]Nasdaq Futures (NQ)
[*]S&P Futures (ES)
[*]Dow Futures (YM)
[*]Russell Futures (RTY)
[*]Crude Oil (CL)
[/list]Any market where overnight auction structure influences the regular session.

[b]Best Used For[/b]
[list]
[*]Identifying overnight support and resistance.
[*]Planning opening scenarios.
[*]Fade and acceptance trades around OVAH, OPOC, and OVAL.
[*]Breakout confirmation.
[*]Break-and-retest continuation setups.
[/list]
Understanding overnight market positioning before the RTH open.

Disclaimer: This indicator is intended as a decision-support tool and does not provide financial advice. Always incorporate sound risk management and additional market context before entering any trade.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// Copyright RogueLLC33

//@version=6
indicator(
     "Rogue Overnight Profile",
     shorttitle = "Rogue ON Profile",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 5000
)

// ============================================================================
// 1. SESSION SETTINGS
// ============================================================================

groupSessions = "Sessions"

profileSession = input.session(
     "1800-0929",
     "Overnight Profile Session",
     group = groupSessions,
     tooltip = "Default covers 6:00 PM through 9:29 AM New York time."
)

newYorkSession = input.session(
     "0930-1600",
     "New York Session",
     group = groupSessions
)

sessionTimezone = input.string(
     "America/New_York",
     "Session Time Zone",
     group = groupSessions
)

// ============================================================================
// 2. PROFILE SETTINGS
// ============================================================================

groupProfile = "Volume Profile"

profileRows = input.int(
     450,
     "Profile Rows",
     minval = 20,
     maxval = 500,
     group = groupProfile,
     tooltip = "Higher values provide finer price resolution but require more calculations."
)

valueAreaPercent = input.float(
     70.0,
     "Value Area Volume %",
     minval = 50.0,
     maxval = 99.0,
     step = 1.0,
     group = groupProfile
)

showProfile = input.bool(
     true,
     "Show Completed Overnight Profile",
     group = groupProfile
)

profileWidthBars = input.int(
     500,
     "Maximum Profile Width",
     minval = 10,
     maxval = 1000,
     group = groupProfile
)

profilePlacement = input.string(
     "Left",
     "Profile Placement",
     options = ["Left", "Right"],
     group = groupProfile
)

showDevelopingRange = input.bool(
     true,
     "Shade Developing Overnight Range",
     group = groupProfile
)

// ============================================================================
// HIGH VOLUME NODE SETTINGS
// ============================================================================

groupNodes = "High Volume Nodes"

showHVNs = input.bool(
     true,
     "Show High Volume Nodes",
     group = groupNodes
)

hvnDetectionPercent = input.int(
     8,
     "HVN Detection Percent",
     minval = 1,
     maxval = 50,
     group = groupNodes,
     tooltip = "Controls how many surrounding profile rows must have less volume. Higher values produce fewer, stronger HVNs."
) / 100.0

hvnThresholdPercent = input.int(
     2,
     "HVN Minimum Volume %",
     minval = 0,
     maxval = 100,
     group = groupNodes,
     tooltip = "Minimum row volume relative to the profile's maximum row volume."
) / 100.0

hvnColor = input.color(
     color.new(color.green, 0),
     "HVN Color",
     group = groupNodes
)

// =========================
// Volume surge settings 
// =========================
groupVolSurge = "Volume Surge Highlights"
showVolSurgeHighlights = input.bool(true, "Show Volume Surge Highlights", group=groupVolSurge)
volSurgeLength = input.int(30, "Average Volume Length", minval=1, group=groupVolSurge)
volSurgeMult = input.float(2.0, "Surge Multiplier Threshold", step=0.1, group=groupVolSurge)
volSurgeUpColor = input.color(color.new(color.green, 85), "Up Surge Highlight", group=groupVolSurge)
volSurgeDownColor = input.color(color.new(color.red, 85), "Down Surge Highlight", group=groupVolSurge)

// ============================================================================
// 5-PERIOD MOVING AVERAGE SETTINGS
// ============================================================================

groupMA = "Moving Average"

showMA5 = input.bool(
     true,
     "Show 5-Period Moving Average",
     group = groupMA
)

ma5Source = input.source(
     close,
     "MA Source",
     group = groupMA
)

ma5Type = input.string(
     "EMA",
     "MA Type",
     options = ["SMA", "EMA"],
     group = groupMA
)

ma5Color = input.color(
     color.white,
     "MA Color",
     group = groupMA
)

ma5Width = input.int(
     2,
     "MA Width",
     minval = 1,
     maxval = 5,
     group = groupMA
)

// ============================================================================
// 3. WEEKLY VWAP SETTINGS
// ============================================================================

groupVWAP = "Weekly VWAP"

showWeeklyVWAP = input.bool(
     true,
     "Show Weekly VWAP",
     group = groupVWAP
)

weeklyVWAPSource = input.source(
     hlc3,
     "VWAP Source",
     group = groupVWAP
)

weeklyVWAPColor = input.color(
     color.rgb(195, 0, 0),
     "Weekly VWAP Color",
     group = groupVWAP
)

weeklyVWAPWidth = input.int(
     2,
     "Weekly VWAP Width",
     minval = 1,
     maxval = 5,
     group = groupVWAP
)

// ============================================================================
// 4. LEVEL SETTINGS
// ============================================================================

groupLevels = "Overnight Levels"

showOVAH = input.bool(true, "Show OVAH", group = groupLevels)
showOPOC = input.bool(true, "Show OPOC", group = groupLevels)
showOVAL = input.bool(true, "Show OVAL", group = groupLevels)

levelForwardBars = input.int(
     10,
     "Level Bars Ahead of Price",
     minval = 1,
     maxval = 100,
     group = groupLevels,
     tooltip = "After the overnight session ends, profile levels remain this many bars ahead of the current price bar during RTH."
)

keepSessions = input.int(
     5,
     "Historical Sessions to Keep",
     minval = 1,
     maxval = 20,
     group = groupLevels
)

levelWidth = input.int(
     2,
     "Level Line Width",
     minval = 1,
     maxval = 4,
     group = groupLevels
)

showLevelLabels = input.bool(
     true,
     "Show Level Labels",
     group = groupLevels
)

// ============================================================================
// 4. SETUP SETTINGS
// ============================================================================

groupSetups = "Trade Setups"

showFirstTouches = input.bool(
     true,
     "Mark First NY-Session Touches",
     group = groupSetups
)

showRetests = input.bool(
     false,
     "Mark Break-and-Retest Setups",
     group = groupSetups
)

touchToleranceTicks = input.int(
     0,
     "Touch Tolerance in Ticks",
     minval = 0,
     maxval = 100,
     group = groupSetups
)

requireRetestClose = input.bool(
     true,
     "Require Retest Candle to Close Back on Correct Side",
     group = groupSetups
)

// ============================================================================
// 5. VISUAL SETTINGS
// ============================================================================

groupVisuals = "Visuals"

valueAreaColor = input.color(
     color.new(color.green, 65),
     "Value Area Profile",
     group = groupVisuals
)

outsideValueColor = input.color(
     color.new(color.rgb(35, 85, 56), 70),
     "Outside Value Area",
     group = groupVisuals
)

pocProfileColor = input.color(
     color.new(color.red, 30),
     "POC Profile Row",
     group = groupVisuals
)

ovahColor = input.color(
     color.rgb(30, 105, 255),
     "OVAH Color",
     group = groupVisuals
)

opocColor = input.color(
     color.rgb(205, 50, 50),
     "OPOC Color",
     group = groupVisuals
)

ovalColor = input.color(
     color.rgb(30, 105, 255),
     "OVAL Color",
     group = groupVisuals
)

overnightRangeColor = input.color(
     color.new(color.rgb(25, 65, 105), 88),
     "Developing Overnight Range",
     group = groupVisuals
)

firstTouchBuyColor = input.color(
     color.rgb(0, 110, 255),
     "Bullish Touch Color",
     group = groupVisuals
)

firstTouchSellColor = input.color(
     color.rgb(150, 0, 0),
     "Bearish Touch Color",
     group = groupVisuals
)

// ============================================================================
// 6. SESSION DETECTION
// ============================================================================

inOvernight = not na(time(
     timeframe.period,
     profileSession,
     sessionTimezone
))

inNewYork = not na(time(
     timeframe.period,
     newYorkSession,
     sessionTimezone
))

overnightStart = inOvernight and not inOvernight[1]
overnightEnd   = not inOvernight and inOvernight[1]

newYorkStart = inNewYork and not inNewYork[1]
newYorkEnd   = not inNewYork and inNewYork[1]

// ============================================================================
// WEEKLY VWAP CALCULATION
// ============================================================================

newWeek = timeframe.change("1W")

var float weeklyPV = 0.0
var float weeklyVolume = 0.0

if newWeek
    weeklyPV := weeklyVWAPSource * volume
    weeklyVolume := volume
else
    weeklyPV += weeklyVWAPSource * volume
    weeklyVolume += volume

weeklyVWAP = weeklyVolume > 0 ? weeklyPV / weeklyVolume : na

// ============================================================================
// 7. DATA STORAGE
// ============================================================================

var array<float> overnightHighs   = array.new_float()
var array<float> overnightLows    = array.new_float()
var array<float> overnightVolumes = array.new_float()

var array<box> profileBoxes = array.new_box()

var array<line> historicalLines = array.new_line()
var array<label> historicalLabels = array.new_label()
var line currentOVAHLine = na
var line currentOPOCLine = na
var line currentOVALLine = na

var label currentOVAHLabel = na
var label currentOPOCLabel = na
var label currentOVALLabel = na

var int overnightStartBar = na
var int overnightEndBar   = na

var float developingHigh = na
var float developingLow  = na

var float overnightVAH = na
var float overnightPOC = na
var float overnightVAL = na

var int completedProfileBar = na

// ============================================================================
// 8. FIRST-TOUCH STATE
// ============================================================================

var bool ovahTouched = false
var bool opocTouched = false
var bool ovalTouched = false

// ============================================================================
// 9. BREAK-AND-RETEST STATE
// ============================================================================

// State values:
//  0 = no active break
//  1 = price broke above the level
// -1 = price broke below the level

var int ovahBreakState = 0
var int opocBreakState = 0
var int ovalBreakState = 0

var int ovahBreakBar = na
var int opocBreakBar = na
var int ovalBreakBar = na

var bool ovahRetestCompleted = false
var bool opocRetestCompleted = false
var bool ovalRetestCompleted = false

// ============================================================================
// 10. HELPER FUNCTIONS
// ============================================================================

f_deleteProfileBoxes() =>
    if array.size(profileBoxes) > 0
        for i = 0 to array.size(profileBoxes) - 1
            box.delete(array.get(profileBoxes, i))
        array.clear(profileBoxes)

f_addHistoricalLine(
     int x1,
     int x2,
     float price,
     color lineColor,
     string levelName,
     bool enabled
 ) =>
    if enabled and not na(price)
        newLine = line.new(
             x1 = x1,
             y1 = price,
             x2 = x2,
             y2 = price,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = lineColor,
             width = levelWidth
        )

        array.push(historicalLines, newLine)

        if showLevelLabels
            newLabel = label.new(
                 x = x2,
                 y = price,
                 text = levelName,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = color.new(lineColor, 75),
                 textcolor = color.white,
                 size = size.tiny
            )

            array.push(historicalLabels, newLabel)

f_trimHistoricalObjects() =>
    maximumLines = keepSessions * 3
    maximumLabels = keepSessions * 3

    while array.size(historicalLines) > maximumLines
        oldestLine = array.shift(historicalLines)
        line.delete(oldestLine)

    while array.size(historicalLabels) > maximumLabels
        oldestLabel = array.shift(historicalLabels)
        label.delete(oldestLabel)

f_levelTouched(float level, float tolerance) =>
    not na(level) and
     high >= level - tolerance and
     low <= level + tolerance

// ============================================================================
// 11. RESET AT THE BEGINNING OF THE OVERNIGHT SESSION
// ============================================================================

if overnightStart
    array.clear(overnightHighs)
    array.clear(overnightLows)
    array.clear(overnightVolumes)

    overnightStartBar := bar_index

    developingHigh := high
    developingLow  := low

// ============================================================================
// 12. COLLECT OVERNIGHT DATA
// ============================================================================

if inOvernight
    array.push(overnightHighs, high)
    array.push(overnightLows, low)
    array.push(overnightVolumes, volume)

    developingHigh := na(developingHigh) ? high : math.max(developingHigh, high)
    developingLow  := na(developingLow) ? low : math.min(developingLow, low)

// ============================================================================
// 13. BUILD THE COMPLETED PROFILE
// ============================================================================

if overnightEnd and array.size(overnightHighs) > 0
    overnightEndBar := bar_index - 1

    profileHigh = array.max(overnightHighs)
    profileLow  = array.min(overnightLows)

    totalRange = math.max(profileHigh - profileLow, syminfo.mintick)
    rowSize    = totalRange / profileRows

    rowVolumes = array.new_float(profileRows, 0.0)

    storedBars = array.size(overnightHighs)

    // ------------------------------------------------------------------------
    // Distribute each bar's volume through the price rows touched by that bar.
    // ------------------------------------------------------------------------

    for barIndex = 0 to storedBars - 1
        barHigh   = array.get(overnightHighs, barIndex)
        barLow    = array.get(overnightLows, barIndex)
        barVolume = array.get(overnightVolumes, barIndex)

        barRange = barHigh - barLow

        if barRange <= syminfo.mintick
            rowIndex = int(math.floor((barLow - profileLow) / rowSize))
            rowIndex := math.max(0, math.min(profileRows - 1, rowIndex))

            previousVolume = array.get(rowVolumes, rowIndex)
            array.set(
                 rowVolumes,
                 rowIndex,
                 previousVolume + barVolume
            )
        else
            firstRow = int(math.floor((barLow - profileLow) / rowSize))
            lastRow  = int(math.floor((barHigh - profileLow) / rowSize))

            firstRow := math.max(0, math.min(profileRows - 1, firstRow))
            lastRow  := math.max(0, math.min(profileRows - 1, lastRow))

            for rowIndex = firstRow to lastRow
                rowBottom = profileLow + rowIndex * rowSize
                rowTop    = rowBottom + rowSize

                overlap = math.max(
                     0.0,
                     math.min(barHigh, rowTop) -
                     math.max(barLow, rowBottom)
                )

                allocatedVolume = barVolume * overlap / barRange

                previousVolume = array.get(rowVolumes, rowIndex)

                array.set(
                     rowVolumes,
                     rowIndex,
                     previousVolume + allocatedVolume
                )

    // ------------------------------------------------------------------------
    // Find Point of Control.
    // ------------------------------------------------------------------------

    pocIndex = 0
    maximumRowVolume = array.get(rowVolumes, 0)

    for rowIndex = 1 to profileRows - 1
        currentRowVolume = array.get(rowVolumes, rowIndex)

        if currentRowVolume > maximumRowVolume
            maximumRowVolume := currentRowVolume
            pocIndex := rowIndex

    // ------------------------------------------------------------------------
    // Expand value area outward from the POC.
    // ------------------------------------------------------------------------

    totalProfileVolume = array.sum(rowVolumes)
    targetValueVolume  = totalProfileVolume * valueAreaPercent / 100.0

    lowerValueIndex = pocIndex
    upperValueIndex = pocIndex

    accumulatedVolume = array.get(rowVolumes, pocIndex)

    while accumulatedVolume < targetValueVolume and
         (lowerValueIndex > 0 or upperValueIndex < profileRows - 1)

        nextLowerVolume = lowerValueIndex > 0 ?
             array.get(rowVolumes, lowerValueIndex - 1) :
             -1.0

        nextUpperVolume = upperValueIndex < profileRows - 1 ?
             array.get(rowVolumes, upperValueIndex + 1) :
             -1.0

        if nextUpperVolume > nextLowerVolume
            upperValueIndex += 1
            accumulatedVolume += math.max(nextUpperVolume, 0.0)
        else
            lowerValueIndex -= 1
            accumulatedVolume += math.max(nextLowerVolume, 0.0)

    overnightPOC := profileLow + (pocIndex + 0.5) * rowSize
    overnightVAH := profileLow + (upperValueIndex + 1.0) * rowSize
    overnightVAL := profileLow + lowerValueIndex * rowSize

    completedProfileBar := bar_index

    // Reset setup tracking for the new RTH session.
    ovahTouched := false
    opocTouched := false
    ovalTouched := false

    ovahBreakState := 0
    opocBreakState := 0
    ovalBreakState := 0

    ovahBreakBar := na
    opocBreakBar := na
    ovalBreakBar := na

    ovahRetestCompleted := false
    opocRetestCompleted := false
    ovalRetestCompleted := false

// ------------------------------------------------------------------------
// Initially place the levels ahead of the first bar after overnight ends.
// Their right edges will continue updating during the New York session.
// ------------------------------------------------------------------------

    levelEndBar = bar_index + levelForwardBars

    // ------------------------------------------------------------------------
    // Draw VAH, POC and VAL after the overnight session ends.
    // ------------------------------------------------------------------------

    currentOVAHLine := na
    currentOPOCLine := na
    currentOVALLine := na

    currentOVAHLabel := na
    currentOPOCLabel := na
    currentOVALLabel := na

    if showOVAH and not na(overnightVAH)
        f_addHistoricalLine(overnightStartBar, levelEndBar, overnightVAH, ovahColor, "OVAH", true)

        if array.size(historicalLines) > 0
            currentOVAHLine := array.get(historicalLines, array.size(historicalLines) - 1)

        if showLevelLabels and array.size(historicalLabels) > 0
            currentOVAHLabel := array.get(historicalLabels, array.size(historicalLabels) - 1)

    if showOPOC and not na(overnightPOC)
        f_addHistoricalLine(overnightStartBar, levelEndBar, overnightPOC, opocColor, "OPOC", true)

        if array.size(historicalLines) > 0
            currentOPOCLine := array.get(historicalLines, array.size(historicalLines) - 1)

        if showLevelLabels and array.size(historicalLabels) > 0
            currentOPOCLabel := array.get(historicalLabels, array.size(historicalLabels) - 1)

    if showOVAL and not na(overnightVAL)
        f_addHistoricalLine(overnightStartBar, levelEndBar, overnightVAL, ovalColor, "OVAL", true)

        if array.size(historicalLines) > 0
            currentOVALLine := array.get(historicalLines, array.size(historicalLines) - 1)

        if showLevelLabels and array.size(historicalLabels) > 0
            currentOVALLabel := array.get(historicalLabels, array.size(historicalLabels) - 1)

    f_trimHistoricalObjects()

    // ------------------------------------------------------------------------
    // Draw the latest completed profile.
    // ------------------------------------------------------------------------

    f_deleteProfileBoxes()

    if showProfile and maximumRowVolume > 0
        for rowIndex = 0 to profileRows - 1
            rowVolume = array.get(rowVolumes, rowIndex)

            relativeWidth = rowVolume / maximumRowVolume

            widthBars = math.max(
                 1,
                 int(math.round(relativeWidth * profileWidthBars))
            )

            rowBottom = profileLow + rowIndex * rowSize
            rowTop = rowBottom + rowSize

            rowInsideValueArea =
                 rowIndex >= lowerValueIndex and
                 rowIndex <= upperValueIndex

            rowColor = rowIndex == pocIndex ?
                 pocProfileColor :
                 rowInsideValueArea ?
                 valueAreaColor :
                 outsideValueColor

            int boxLeft = na
            int boxRight = na

            if profilePlacement == "Right"
                boxRight := overnightEndBar
                boxLeft := overnightEndBar - widthBars + 1
            else
                boxLeft := overnightStartBar
                boxRight := overnightStartBar + widthBars - 1

            profileBox = box.new(
                 left = boxLeft,
                 top = rowTop,
                 right = boxRight,
                 bottom = rowBottom,
                 xloc = xloc.bar_index,
                 border_color = color.new(rowColor, 100),
                 bgcolor = rowColor
            )

            array.push(profileBoxes, profileBox)

    // ------------------------------------------------------------------------
    // Identify and highlight high-volume nodes.
    // ------------------------------------------------------------------------

    if showProfile and showHVNs and maximumRowVolume > 0
        hvnLookaround = math.max(
            1,
            int(profileRows * hvnDetectionPercent)
        )

        paddedVolumes = array.copy(rowVolumes)

        for paddingIndex = 1 to hvnLookaround
            array.unshift(paddedVolumes, 0.0)
            array.push(paddedVolumes, 0.0)

        paddedSize = array.size(paddedVolumes)

        for rowIndex = 0 to profileRows - 1
            centerIndex = rowIndex + hvnLookaround

            bool higherThanRowsBelow = true
            bool higherThanRowsAbove = true

            if centerIndex - hvnLookaround >= 0 and centerIndex + hvnLookaround < paddedSize

                for comparisonIndex = centerIndex - hvnLookaround to centerIndex - 1
                    if array.get(paddedVolumes, centerIndex) <= array.get(paddedVolumes, comparisonIndex)

                        higherThanRowsBelow := false
                        break

                for comparisonIndex = centerIndex + 1 to centerIndex + hvnLookaround
                    if array.get(paddedVolumes, centerIndex) <=
                         array.get(paddedVolumes, comparisonIndex)

                        higherThanRowsAbove := false
                        break

                rowVolume = array.get(rowVolumes, rowIndex)

                rowPassesThreshold =
                     rowVolume / maximumRowVolume >
                     hvnThresholdPercent

                isHighVolumeNode =
                     higherThanRowsBelow and
                     higherThanRowsAbove and
                     rowPassesThreshold

                if isHighVolumeNode
                    relativeWidth =
                         rowVolume /
                         maximumRowVolume

                    widthBars = math.max(
                        1,
                        int(
                            math.round(
                                relativeWidth *
                                profileWidthBars
                            )
                        )
                    )

                    rowBottom =
                         profileLow +
                         rowIndex *
                         rowSize

                    int hvnBoxLeft = na
                    int hvnBoxRight = na

                    if profilePlacement == "Right"
                        hvnBoxRight := overnightEndBar
                        hvnBoxLeft :=
                             overnightEndBar -
                             widthBars +
                             1
                    else
                        hvnBoxLeft := overnightStartBar
                        hvnBoxRight :=
                             overnightStartBar +
                             widthBars -
                             1

                    hvnBox = box.new(
                        left = hvnBoxLeft,
                        top = rowBottom + rowSize * 0.85,
                        right = hvnBoxRight,
                        bottom = rowBottom + rowSize * 0.15,
                        xloc = xloc.bar_index,
                        border_color = color.new(hvnColor, 100),
                        bgcolor = hvnColor
                    )

                    array.push(profileBoxes, hvnBox)

// ============================================================================
// 13B. KEEP CURRENT PROFILE LEVELS AHEAD OF PRICE
// ============================================================================

// Lines are created only after the overnight session has completed.
// During RTH, their right edge stays the selected number of bars ahead.
// Once RTH ends, the objects stop updating and remain historical.

if inNewYork and not na(completedProfileBar)
    dynamicLevelEndBar = bar_index + levelForwardBars

    if not na(currentOVAHLine)
        line.set_x2(
             currentOVAHLine,
             dynamicLevelEndBar
        )

    if not na(currentOPOCLine)
        line.set_x2(
             currentOPOCLine,
             dynamicLevelEndBar
        )

    if not na(currentOVALLine)
        line.set_x2(
             currentOVALLine,
             dynamicLevelEndBar
        )

    if not na(currentOVAHLabel)
        label.set_x(
             currentOVAHLabel,
             dynamicLevelEndBar
        )

    if not na(currentOPOCLabel)
        label.set_x(
             currentOPOCLabel,
             dynamicLevelEndBar
        )

    if not na(currentOVALLabel)
        label.set_x(
             currentOVALLabel,
             dynamicLevelEndBar
        )

// ============================================================================
// 14. DEVELOPING OVERNIGHT RANGE
// ============================================================================

developingTopPlot = plot(
     showDevelopingRange and inOvernight ? developingHigh : na,
     "Developing Overnight High",
     color = color.new(overnightRangeColor, 100),
     display = display.none
)

developingBottomPlot = plot(
     showDevelopingRange and inOvernight ? developingLow : na,
     "Developing Overnight Low",
     color = color.new(overnightRangeColor, 100),
     display = display.none
)

fill(
     developingTopPlot,
     developingBottomPlot,
     color = showDevelopingRange ? overnightRangeColor : na,
     title = "Developing Overnight Range"
)

// ============================================================================
// 15. FIRST-TOUCH SETUPS
// ============================================================================

touchTolerance = touchToleranceTicks * syminfo.mintick

newProfileAvailable =
     not na(completedProfileBar) and
     bar_index >= completedProfileBar

ovahFirstTouch =
     showFirstTouches and
     inNewYork and
     newProfileAvailable and
     not ovahTouched and
     f_levelTouched(overnightVAH, touchTolerance)

opocFirstTouch =
     showFirstTouches and
     inNewYork and
     newProfileAvailable and
     not opocTouched and
     f_levelTouched(overnightPOC, touchTolerance)

ovalFirstTouch =
     showFirstTouches and
     inNewYork and
     newProfileAvailable and
     not ovalTouched and
     f_levelTouched(overnightVAL, touchTolerance)

if ovahFirstTouch
    ovahTouched := true

    label.new(
         bar_index,
         high,
         "OVAH\nFIRST TAP",
         style = label.style_label_down,
         color = firstTouchSellColor,
         textcolor = color.white,
         size = size.tiny
    )

if opocFirstTouch
    opocTouched := true

    opocBullishReaction = close >= overnightPOC

    label.new(
         bar_index,
         opocBullishReaction ? low : high,
         "OPOC\nFIRST TAP",
         style = opocBullishReaction ?
             label.style_label_up :
             label.style_label_down,
         color = opocBullishReaction ?
             firstTouchBuyColor :
             firstTouchSellColor,
         textcolor = color.white,
         size = size.tiny
    )

if ovalFirstTouch
    ovalTouched := true

    label.new(
         bar_index,
         low,
         "OVAL\nFIRST TAP",
         style = label.style_label_up,
         color = firstTouchBuyColor,
         textcolor = color.white,
         size = size.tiny
    )

// ============================================================================
// 16. BREAK DETECTION
// ============================================================================

if inNewYork and newProfileAvailable
    // OVAH breaks
    if ta.crossover(close, overnightVAH)
        ovahBreakState := 1
        ovahBreakBar := bar_index
        ovahRetestCompleted := false

    if ta.crossunder(close, overnightVAH)
        ovahBreakState := -1
        ovahBreakBar := bar_index
        ovahRetestCompleted := false

    // OPOC breaks
    if ta.crossover(close, overnightPOC)
        opocBreakState := 1
        opocBreakBar := bar_index
        opocRetestCompleted := false

    if ta.crossunder(close, overnightPOC)
        opocBreakState := -1
        opocBreakBar := bar_index
        opocRetestCompleted := false

    // OVAL breaks
    if ta.crossover(close, overnightVAL)
        ovalBreakState := 1
        ovalBreakBar := bar_index
        ovalRetestCompleted := false

    if ta.crossunder(close, overnightVAL)
        ovalBreakState := -1
        ovalBreakBar := bar_index
        ovalRetestCompleted := false

// ============================================================================
// 17. BREAK-AND-RETEST SETUPS
// ============================================================================

ovahBullRetest =
     showRetests and
     inNewYork and
     ovahBreakState == 1 and
     not ovahRetestCompleted and
     bar_index > ovahBreakBar and
     low <= overnightVAH + touchTolerance and
     (not requireRetestClose or close >= overnightVAH)

ovahBearRetest =
     showRetests and
     inNewYork and
     ovahBreakState == -1 and
     not ovahRetestCompleted and
     bar_index > ovahBreakBar and
     high >= overnightVAH - touchTolerance and
     (not requireRetestClose or close <= overnightVAH)

opocBullRetest =
     showRetests and
     inNewYork and
     opocBreakState == 1 and
     not opocRetestCompleted and
     bar_index > opocBreakBar and
     low <= overnightPOC + touchTolerance and
     (not requireRetestClose or close >= overnightPOC)

opocBearRetest =
     showRetests and
     inNewYork and
     opocBreakState == -1 and
     not opocRetestCompleted and
     bar_index > opocBreakBar and
     high >= overnightPOC - touchTolerance and
     (not requireRetestClose or close <= overnightPOC)

ovalBullRetest =
     showRetests and
     inNewYork and
     ovalBreakState == 1 and
     not ovalRetestCompleted and
     bar_index > ovalBreakBar and
     low <= overnightVAL + touchTolerance and
     (not requireRetestClose or close >= overnightVAL)

ovalBearRetest =
     showRetests and
     inNewYork and
     ovalBreakState == -1 and
     not ovalRetestCompleted and
     bar_index > ovalBreakBar and
     high >= overnightVAL - touchTolerance and
     (not requireRetestClose or close <= overnightVAL)

if ovahBullRetest
    ovahRetestCompleted := true

    label.new(
         bar_index,
         low,
         "OVAH\nSUPPORT RETEST",
         style = label.style_label_up,
         color = firstTouchBuyColor,
         textcolor = color.white,
         size = size.tiny
    )

if ovahBearRetest
    ovahRetestCompleted := true

    label.new(
         bar_index,
         high,
         "OVAH\nRESISTANCE RETEST",
         style = label.style_label_down,
         color = firstTouchSellColor,
         textcolor = color.white,
         size = size.tiny
    )

if opocBullRetest
    opocRetestCompleted := true

    label.new(
         bar_index,
         low,
         "OPOC\nSUPPORT RETEST",
         style = label.style_label_up,
         color = firstTouchBuyColor,
         textcolor = color.white,
         size = size.tiny
    )

if opocBearRetest
    opocRetestCompleted := true

    label.new(
         bar_index,
         high,
         "OPOC\nRESISTANCE RETEST",
         style = label.style_label_down,
         color = firstTouchSellColor,
         textcolor = color.white,
         size = size.tiny
    )

if ovalBullRetest
    ovalRetestCompleted := true

    label.new(
         bar_index,
         low,
         "OVAL\nSUPPORT RETEST",
         style = label.style_label_up,
         color = firstTouchBuyColor,
         textcolor = color.white,
         size = size.tiny
    )

if ovalBearRetest
    ovalRetestCompleted := true

    label.new(
         bar_index,
         high,
         "OVAL\nRESISTANCE RETEST",
         style = label.style_label_down,
         color = firstTouchSellColor,
         textcolor = color.white,
         size = size.tiny
    )

// ============================================================================
// 5-PERIOD MOVING AVERAGE
// ============================================================================

ma5 = ma5Type == "EMA" ?
     ta.ema(ma5Source, 5) :
     ta.sma(ma5Source, 5)

plot(
     showMA5 ? ma5 : na,
     title = "5-Period Moving Average",
     color = ma5Color,
     linewidth = ma5Width
)

// ============================================================================
// WEEKLY VWAP PLOT
// ============================================================================

plot(
     showWeeklyVWAP ? weeklyVWAP : na,
     title = "Weekly VWAP",
     color = weeklyVWAPColor,
     linewidth = weeklyVWAPWidth
)

//--------------------------------------------------------------------------------------------------
// Volume Surge Highlights
//--------------------------------------------------------------------------------------------------
avgVolumeSurge = ta.sma(volume, volSurgeLength)
volMultipleSurge = avgVolumeSurge > 0 ? volume / avgVolumeSurge : na

isVolumeSurge = showVolSurgeHighlights and inNewYork and not na(volMultipleSurge) and volMultipleSurge > volSurgeMult
isUpVolumeBar = close >= close[1]

volumeSurgeColor = isVolumeSurge ? isUpVolumeBar ? volSurgeUpColor : volSurgeDownColor : na

bgcolor(volumeSurgeColor, title="Volume Surge Highlight")

// ============================================================================
// 18. ALERTS
// ============================================================================

alertcondition(
     ovahFirstTouch,
     "OVAH First Touch",
     "Price has made its first New York-session touch of OVAH."
)

alertcondition(
     opocFirstTouch,
     "OPOC First Touch",
     "Price has made its first New York-session touch of OPOC."
)

alertcondition(
     ovalFirstTouch,
     "OVAL First Touch",
     "Price has made its first New York-session touch of OVAL."
)

anyFirstTouch =
     ovahFirstTouch or
     opocFirstTouch or
     ovalFirstTouch

alertcondition(
     anyFirstTouch,
     "Any Overnight Level First Touch",
     "Price has made its first New York-session touch of an overnight profile level."
)

anyBullishRetest =
     ovahBullRetest or
     opocBullRetest or
     ovalBullRetest

anyBearishRetest =
     ovahBearRetest or
     opocBearRetest or
     ovalBearRetest

alertcondition(
     anyBullishRetest,
     "Bullish Overnight Level Retest",
     "A broken overnight profile level is being retested as support."
)

alertcondition(
     anyBearishRetest,
     "Bearish Overnight Level Retest",
     "A broken overnight profile level is being retested as resistance."
)

alertcondition(
     anyBullishRetest or anyBearishRetest,
     "Any Overnight Level Retest",
     "An overnight profile break-and-retest setup has occurred."
)
````
