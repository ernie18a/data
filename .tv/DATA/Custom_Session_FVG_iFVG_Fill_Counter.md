<!-- tradingview-pine-id: PUB;a7eba79d299b444681ee8d7d72c67135 -->
<!-- tradingviewscripts-format: 1 -->
# Custom Session FVG & iFVG Fill Counter

Source: https://www.tradingview.com/script/rRsCEgjb-FVG-iFVG-Fill-Counter-Spectre-Trades/

## Description

The Custom Session FVG & iFVG Fill Counter is designed for intraday traders who use Fair Value Gaps to evaluate price delivery, market imbalance, and potential reversal areas. Unlike session-specific indicators, this tool can be fully customized for any trading session, including New York, London, Asia, premarket, regular trading hours, kill zones, or a user-defined time window.

The indicator automatically identifies bullish and bearish three-candle FVGs formed during the selected session, tracks whether those imbalances remain active or become filled, and monitors when an invalidated FVG converts into an inverse Fair Value Gap, or iFVG.

A customizable on-chart dashboard provides a clear breakdown of bullish and bearish FVGs created, FVGs filled, iFVGs created, iFVGs revisited, and zones that remain active. Users can customize the session name, dashboard title, session hours, time zone, minimum gap size, fill requirement, iFVG confirmation method, colors, text size, dashboard location, session shading, and chart markers.

The indicator can be configured for any market or trading window by selecting the preferred session hours and time zone. This allows traders to study imbalance behavior during sessions such as:

New York regular trading hours
New York AM or PM session
London session
London Kill Zone
Asian or Tokyo session
Futures premarket
Custom opening-range windows
Any personally defined trading session

This tool is intended for futures, forex, index, cryptocurrency, and intraday price-action traders who want a faster way to measure how efficiently the market is filling imbalances during a chosen session. It may be particularly useful for traders who incorporate ICT concepts, liquidity sweeps, market structure shifts, displacement, FVG retests, and inverse FVG reversals into their trading process.

The indicator is best used as a market-context and confirmation tool alongside higher-timeframe bias, liquidity levels, structure, volume, and disciplined risk management.

Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice. Fair Value Gaps and inverse Fair Value Gaps do not guarantee reversals, continuations, or profitable trades. Historical signals and past performance do not predict future results. Users are responsible for independently evaluating all trade setups and applying appropriate risk management before entering any position.

---

## Source Code

````pine
//@version=6
indicator(
     "Custom Session FVG & iFVG Fill Counter",
     shorttitle = "Session FVG/iFVG",
     overlay = true,
     max_labels_count = 500,
     max_boxes_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. CUSTOM SESSION SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupSession = "1. Custom Trading Session"

customSessionName = input.string(
     "New York Session",
     "Session Name",
     tooltip = "Enter the name displayed in the dashboard, such as New York, London, Asia, Premarket, or NY AM.",
     group = groupSession)

customDashboardTitle = input.string(
     "FVG / iFVG COUNTER",
     "Dashboard Title",
     tooltip = "Customize the main title displayed at the top of the dashboard.",
     group = groupSession)

customSession = input.session(
     "0930-1600",
     "Session Hours",
     tooltip = "Select the session hours used for FVG detection and counting.",
     group = groupSession)

customTimeZone = input.string(
     "America/New_York",
     "Session Time Zone",
     options = [
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "Europe/London",
         "Europe/Paris",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "Etc/UTC"
     ],
     tooltip = "The selected session hours are interpreted using this time zone.",
     group = groupSession)

resetAtNewSession = input.bool(
     true,
     "Reset Counts at New Session",
     tooltip = "When enabled, all counters and tracked gaps reset when a new selected session begins.",
     group = groupSession)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. FVG DETECTION SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupDetection = "2. FVG Detection"

minimumGapTicks = input.int(
     1,
     "Minimum Gap Size in Ticks",
     minval = 1,
     tooltip = "FVGs smaller than this number of minimum price ticks will be ignored.",
     group = groupDetection)

fillRequirement = input.string(
     "Full Fill",
     "FVG Fill Requirement",
     options = [
         "First Touch",
         "50% Fill",
         "Full Fill"
     ],
     tooltip = "Determines how deeply price must enter an FVG before it is counted as filled.",
     group = groupDetection)

inversionRequirement = input.string(
     "Candle Close",
     "iFVG Confirmation",
     options = [
         "Candle Close",
         "Wick Through"
     ],
     tooltip = "Determines whether an FVG becomes inverse after a candle close or wick crosses its far boundary.",
     group = groupDetection)

allowCreationBarFill = input.bool(
     false,
     "Allow Fill on Creation Candle",
     tooltip = "When disabled, a newly detected FVG cannot be counted as filled on its creation candle.",
     group = groupDetection)

maximumTrackedZones = input.int(
     100,
     "Maximum Tracked Zones",
     minval = 10,
     maxval = 500,
     tooltip = "Limits the number of active FVG and iFVG zones stored by the indicator.",
     group = groupDetection)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupDashboard = "3. Dashboard"

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = groupDashboard)

showSessionStatus = input.bool(
     true,
     "Show Session Status",
     group = groupDashboard)

dashboardPositionInput = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group = groupDashboard)

dashboardTextSizeInput = input.string(
     "Small",
     "Dashboard Text Size",
     options = [
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     group = groupDashboard)

dashboardBackground = input.color(
     color.new(color.black, 10),
     "Dashboard Background",
     group = groupDashboard)

dashboardBorderColor = input.color(
     color.gray,
     "Dashboard Border",
     group = groupDashboard)

headerBackground = input.color(
     color.new(color.blue, 65),
     "Header Background",
     group = groupDashboard)

headerTextColor = input.color(
     color.white,
     "Header Text",
     group = groupDashboard)

bullishColor = input.color(
     color.lime,
     "Bullish Text",
     group = groupDashboard)

bearishColor = input.color(
     color.red,
     "Bearish Text",
     group = groupDashboard)

neutralColor = input.color(
     color.silver,
     "Neutral Text",
     group = groupDashboard)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. CHART DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupMarkers = "4. Chart Display"

showNewFVGMarkers = input.bool(
     false,
     "Mark New FVGs",
     group = groupMarkers)

showFVGFillMarkers = input.bool(
     true,
     "Mark Filled FVGs",
     group = groupMarkers)

showIFVGFillMarkers = input.bool(
     true,
     "Mark Filled iFVGs",
     group = groupMarkers)

shadeSelectedSession = input.bool(
     false,
     "Shade Selected Session",
     group = groupMarkers)

sessionShadeColor = input.color(
     color.new(color.blue, 92),
     "Session Shade Color",
     group = groupMarkers)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getTablePosition(string selectedPosition) =>
    switch selectedPosition
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

getTableTextSize(string selectedSize) =>
    switch selectedSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

getFVGFillLevel(
     int direction,
     float lowerBoundary,
     float upperBoundary) =>

    float midpoint = math.avg(
         lowerBoundary,
         upperBoundary)

    float fillLevel = switch fillRequirement
        "First Touch" =>
            direction == 1
                 ? upperBoundary
                 : lowerBoundary

        "50% Fill" =>
            midpoint

        "Full Fill" =>
            direction == 1
                 ? lowerBoundary
                 : upperBoundary

        =>
            midpoint

    fillLevel

removeZone(
     array<float> lowerArray,
     array<float> upperArray,
     array<int> directionArray,
     array<int> stateArray,
     array<int> creationArray,
     array<int> inversionArray,
     int zoneIndex) =>

    array.remove(
         lowerArray,
         zoneIndex)

    array.remove(
         upperArray,
         zoneIndex)

    array.remove(
         directionArray,
         zoneIndex)

    array.remove(
         stateArray,
         zoneIndex)

    array.remove(
         creationArray,
         zoneIndex)

    array.remove(
         inversionArray,
         zoneIndex)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. CUSTOM SESSION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sessionTime = time(
     timeframe.period,
     customSession,
     customTimeZone)

inSelectedSession = not na(
     sessionTime)

newSelectedSession =
     inSelectedSession and
     na(sessionTime[1])

bgcolor(
     shadeSelectedSession and inSelectedSession
         ? sessionShadeColor
         : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. ACTIVE ZONE ARRAYS
//
// Direction:
//  1  = Original bullish FVG
// -1  = Original bearish FVG
//
// State:
//  0 = Active standard FVG
//  1 = Active inverse FVG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> zoneLower =
     array.new<float>()

var array<float> zoneUpper =
     array.new<float>()

var array<int> zoneDirection =
     array.new<int>()

var array<int> zoneState =
     array.new<int>()

var array<int> zoneCreationBar =
     array.new<int>()

var array<int> zoneInversionBar =
     array.new<int>()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. SESSION COUNTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int bullishFVGCreated = 0
var int bearishFVGCreated = 0

var int bullishFVGFilled = 0
var int bearishFVGFilled = 0

var int bullishIFVGCreated = 0
var int bearishIFVGCreated = 0

var int bullishIFVGFilled = 0
var int bearishIFVGFilled = 0

if newSelectedSession and resetAtNewSession
    array.clear(zoneLower)
    array.clear(zoneUpper)
    array.clear(zoneDirection)
    array.clear(zoneState)
    array.clear(zoneCreationBar)
    array.clear(zoneInversionBar)

    bullishFVGCreated := 0
    bearishFVGCreated := 0

    bullishFVGFilled := 0
    bearishFVGFilled := 0

    bullishIFVGCreated := 0
    bearishIFVGCreated := 0

    bullishIFVGFilled := 0
    bearishIFVGFilled := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. THREE-CANDLE FVG DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

minimumGapSize =
     minimumGapTicks *
     syminfo.mintick

newBullishFVG =
     inSelectedSession and
     bar_index >= 2 and
     low > high[2] and
     low - high[2] >= minimumGapSize

newBearishFVG =
     inSelectedSession and
     bar_index >= 2 and
     high < low[2] and
     low[2] - high >= minimumGapSize

if newBullishFVG
    array.push(
         zoneLower,
         high[2])

    array.push(
         zoneUpper,
         low)

    array.push(
         zoneDirection,
         1)

    array.push(
         zoneState,
         0)

    array.push(
         zoneCreationBar,
         bar_index)

    array.push(
         zoneInversionBar,
         -1)

    bullishFVGCreated += 1

if newBearishFVG
    array.push(
         zoneLower,
         high)

    array.push(
         zoneUpper,
         low[2])

    array.push(
         zoneDirection,
         -1)

    array.push(
         zoneState,
         0)

    array.push(
         zoneCreationBar,
         bar_index)

    array.push(
         zoneInversionBar,
         -1)

    bearishFVGCreated += 1

// Remove the oldest zones when the user-defined limit is exceeded.

while array.size(zoneLower) > maximumTrackedZones
    array.shift(zoneLower)
    array.shift(zoneUpper)
    array.shift(zoneDirection)
    array.shift(zoneState)
    array.shift(zoneCreationBar)
    array.shift(zoneInversionBar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. PROCESS ACTIVE FVGs AND iFVGs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool bullishFVGFillEvent = false
bool bearishFVGFillEvent = false

bool bullishIFVGFillEvent = false
bool bearishIFVGFillEvent = false

if inSelectedSession and array.size(zoneLower) > 0
    int zoneIndex =
         array.size(zoneLower) - 1

    while zoneIndex >= 0
        float lowerBoundary =
             array.get(
                 zoneLower,
                 zoneIndex)

        float upperBoundary =
             array.get(
                 zoneUpper,
                 zoneIndex)

        int originalDirection =
             array.get(
                 zoneDirection,
                 zoneIndex)

        int currentState =
             array.get(
                 zoneState,
                 zoneIndex)

        int creationBar =
             array.get(
                 zoneCreationBar,
                 zoneIndex)

        int inversionBar =
             array.get(
                 zoneInversionBar,
                 zoneIndex)

        bool canProcessStandardFVG =
             allowCreationBarFill or
             bar_index > creationBar

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ACTIVE STANDARD FVG
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        if currentState == 0 and canProcessStandardFVG
            float fillLevel =
                 getFVGFillLevel(
                     originalDirection,
                     lowerBoundary,
                     upperBoundary)

            bool bullishFVGIsFilled =
                 originalDirection == 1 and
                 low <= fillLevel

            bool bearishFVGIsFilled =
                 originalDirection == -1 and
                 high >= fillLevel

            bool bullishFVGInverted =
                 originalDirection == 1 and
                 (
                     inversionRequirement == "Candle Close"
                         ? close < lowerBoundary
                         : low < lowerBoundary
                 )

            bool bearishFVGInverted =
                 originalDirection == -1 and
                 (
                     inversionRequirement == "Candle Close"
                         ? close > upperBoundary
                         : high > upperBoundary
                 )

            // Bullish FVG becomes bearish iFVG.

            if bullishFVGInverted
                bullishFVGFilled += 1
                bearishIFVGCreated += 1

                bullishFVGFillEvent := true

                array.set(
                     zoneState,
                     zoneIndex,
                     1)

                array.set(
                     zoneInversionBar,
                     zoneIndex,
                     bar_index)

            // Bearish FVG becomes bullish iFVG.

            else if bearishFVGInverted
                bearishFVGFilled += 1
                bullishIFVGCreated += 1

                bearishFVGFillEvent := true

                array.set(
                     zoneState,
                     zoneIndex,
                     1)

                array.set(
                     zoneInversionBar,
                     zoneIndex,
                     bar_index)

            // Standard FVG is filled without becoming inverse.

            else if bullishFVGIsFilled
                bullishFVGFilled += 1
                bullishFVGFillEvent := true

                removeZone(
                     zoneLower,
                     zoneUpper,
                     zoneDirection,
                     zoneState,
                     zoneCreationBar,
                     zoneInversionBar,
                     zoneIndex)

            else if bearishFVGIsFilled
                bearishFVGFilled += 1
                bearishFVGFillEvent := true

                removeZone(
                     zoneLower,
                     zoneUpper,
                     zoneDirection,
                     zoneState,
                     zoneCreationBar,
                     zoneInversionBar,
                     zoneIndex)

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ACTIVE INVERSE FVG
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        else if currentState == 1 and bar_index > inversionBar
            bool bullishIFVGRetest =
                 originalDirection == -1 and
                 low <= upperBoundary and
                 high >= lowerBoundary

            bool bearishIFVGRetest =
                 originalDirection == 1 and
                 low <= upperBoundary and
                 high >= lowerBoundary

            if bullishIFVGRetest
                bullishIFVGFilled += 1
                bullishIFVGFillEvent := true

                removeZone(
                     zoneLower,
                     zoneUpper,
                     zoneDirection,
                     zoneState,
                     zoneCreationBar,
                     zoneInversionBar,
                     zoneIndex)

            else if bearishIFVGRetest
                bearishIFVGFilled += 1
                bearishIFVGFillEvent := true

                removeZone(
                     zoneLower,
                     zoneUpper,
                     zoneDirection,
                     zoneState,
                     zoneCreationBar,
                     zoneInversionBar,
                     zoneIndex)

        zoneIndex -= 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. CHART MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showNewFVGMarkers and newBullishFVG,
     title = "New Bullish FVG",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullishColor,
     size = size.tiny,
     text = "FVG",
     textcolor = bullishColor)

plotshape(
     showNewFVGMarkers and newBearishFVG,
     title = "New Bearish FVG",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearishColor,
     size = size.tiny,
     text = "FVG",
     textcolor = bearishColor)

plotshape(
     showFVGFillMarkers and bullishFVGFillEvent,
     title = "Bullish FVG Filled",
     style = shape.circle,
     location = location.belowbar,
     color = bullishColor,
     size = size.tiny,
     text = "F",
     textcolor = bullishColor)

plotshape(
     showFVGFillMarkers and bearishFVGFillEvent,
     title = "Bearish FVG Filled",
     style = shape.circle,
     location = location.abovebar,
     color = bearishColor,
     size = size.tiny,
     text = "F",
     textcolor = bearishColor)

plotshape(
     showIFVGFillMarkers and bullishIFVGFillEvent,
     title = "Bullish iFVG Filled",
     style = shape.diamond,
     location = location.belowbar,
     color = bullishColor,
     size = size.tiny,
     text = "iF",
     textcolor = bullishColor)

plotshape(
     showIFVGFillMarkers and bearishIFVGFillEvent,
     title = "Bearish iFVG Filled",
     style = shape.diamond,
     location = location.abovebar,
     color = bearishColor,
     size = size.tiny,
     text = "iF",
     textcolor = bearishColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12. TOTALS AND ACTIVE ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

totalFVGCreated =
     bullishFVGCreated +
     bearishFVGCreated

totalFVGFilled =
     bullishFVGFilled +
     bearishFVGFilled

totalIFVGCreated =
     bullishIFVGCreated +
     bearishIFVGCreated

totalIFVGFilled =
     bullishIFVGFilled +
     bearishIFVGFilled

int activeFVGCount = 0
int activeIFVGCount = 0

if array.size(zoneState) > 0
    for currentIndex = 0 to array.size(zoneState) - 1
        int stateValue =
             array.get(
                 zoneState,
                 currentIndex)

        if stateValue == 0
            activeFVGCount += 1

        else if stateValue == 1
            activeIFVGCount += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13. CUSTOM DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dashboardPosition =
     getTablePosition(
         dashboardPositionInput)

dashboardTextSize =
     getTableTextSize(
         dashboardTextSizeInput)

var table dashboard = table.new(
     dashboardPosition,
     4,
     8,
     bgcolor = dashboardBackground,
     frame_color = dashboardBorderColor,
     frame_width = 1,
     border_color = dashboardBorderColor,
     border_width = 1)

if barstate.islast
    table.clear(
         dashboard,
         0,
         0,
         3,
         7)

    if showDashboard
        table.cell(
             dashboard,
             0,
             0,
             customDashboardTitle,
             bgcolor = headerBackground,
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.merge_cells(
             dashboard,
             0,
             0,
             3,
             0)

        table.cell(
             dashboard,
             0,
             1,
             customSessionName,
             bgcolor = dashboardBackground,
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.merge_cells(
             dashboard,
             0,
             1,
             3,
             1)

        table.cell(
             dashboard,
             0,
             2,
             "Category",
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             2,
             "Bull",
             text_color = bullishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             2,
             "Bear",
             text_color = bearishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             2,
             "Total",
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             0,
             3,
             "FVG Created",
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             3,
             str.tostring(bullishFVGCreated),
             text_color = bullishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             3,
             str.tostring(bearishFVGCreated),
             text_color = bearishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             3,
             str.tostring(totalFVGCreated),
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             0,
             4,
             "FVG Filled",
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             4,
             str.tostring(bullishFVGFilled),
             text_color = bullishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             4,
             str.tostring(bearishFVGFilled),
             text_color = bearishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             4,
             str.tostring(totalFVGFilled),
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             0,
             5,
             "iFVG Created",
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             5,
             str.tostring(bullishIFVGCreated),
             text_color = bullishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             5,
             str.tostring(bearishIFVGCreated),
             text_color = bearishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             5,
             str.tostring(totalIFVGCreated),
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             0,
             6,
             "iFVG Filled",
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             6,
             str.tostring(bullishIFVGFilled),
             text_color = bullishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             6,
             str.tostring(bearishIFVGFilled),
             text_color = bearishColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             6,
             str.tostring(totalIFVGFilled),
             text_color = headerTextColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             0,
             7,
             "Active Zones",
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             1,
             7,
             "FVG " + str.tostring(activeFVGCount),
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             2,
             7,
             "iFVG " + str.tostring(activeIFVGCount),
             text_color = neutralColor,
             text_size = dashboardTextSize)

        table.cell(
             dashboard,
             3,
             7,
             showSessionStatus
                 ? inSelectedSession
                     ? "ACTIVE"
                     : "CLOSED"
                 : "",
             text_color = inSelectedSession
                 ? bullishColor
                 : neutralColor,
             text_size = dashboardTextSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 14. ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     bullishFVGFillEvent,
     title = "Bullish FVG Filled",
     message = "A bullish FVG was filled during the selected trading session.")

alertcondition(
     bearishFVGFillEvent,
     title = "Bearish FVG Filled",
     message = "A bearish FVG was filled during the selected trading session.")

alertcondition(
     bullishIFVGFillEvent,
     title = "Bullish iFVG Filled",
     message = "A bullish iFVG was filled during the selected trading session.")

alertcondition(
     bearishIFVGFillEvent,
     title = "Bearish iFVG Filled",
     message = "A bearish iFVG was filled during the selected trading session.")
````
