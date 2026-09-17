<!-- tradingview-pine-id: PUB;d53c2e49c70e4944bcd302717db426a9 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# The Magnet Model - Opening Range Volume Profile

Source: https://www.tradingview.com/script/RMmQHRj2-The-Magnet-Model/

## Description

The Magnet Model — Opening Range Volume Profile

The Magnet Model ORVP is designed to turn the opening auction into a simple, repeatable map of where volume established value and where those levels may continue to matter throughout the trading session. It will automatically map the key volume-based levels established during New York opening range.

Instead of manually drawing a Fixed Range Volume Profile each morning, the indicator automatically builds the opening profile and identifies the Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL). Once the opening range is complete, these levels extend to the right, allowing traders to monitor how price interacts with them throughout the session.

Key Features
Automatic 9:30–9:46 AM New York Opening Range Volume Profile
Automatically calculates VAH, POC, and VAL
70% Value Area by default
VAH, POC, and VAL automatically extend to the right
Shaded Value Area between VAH and VAL for quick visual reference
Current ORVP is highlighted pink
Previous ORVP zones can use different colors to distinguish sessions
Adjustable number of historical ORVPs displayed
Clean date labels such as 8/31 ORVP
Adjustable profile rows and profile width
Customizable colors, line widths, and line styles
Optional Overlap Detection Deletion to automatically remove older ORVP zones that overlap the newest value area
Designed to maintain a clean chart while preserving important historical opening-range levels

How It Can Be Used

The ORVP provides a structured framework for evaluating the market after the opening range has formed.

VAH, VAL, and POC can serve as important areas to monitor for:

Acceptance and rejection
Support and resistance
Breakouts and failed breakouts
Retests
Potential price magnets
Continuation or reversal opportunities

Historical ORVP levels can also remain on the chart, allowing traders to identify when price returns to areas of value established during previous sessions.

Best Used With Confluence

While The Magnet Model ORVP is powerful on its own, it can become even more effective when combined with other high-quality market references and confirmation tools.

Consider looking for confluence with VWAP, Simple Moving Averages (SMAs), Initial Balance (IB), key session levels, and order flow.

Some of the strongest areas of interest can develop when multiple independent levels or signals align with an ORVP VAH, VAL, or POC, providing additional context for potential support, resistance, acceptance, rejection, and directional movement.

The goal is not to trade an ORVP level blindly, but to use it as part of a broader framework of confluence.

Overlap Detection

When Overlap Detection Deletion is enabled, the indicator compares each newly completed value area with older ORVP zones.

If an older VAH-to-VAL value area overlaps the newest value area, the older profile is automatically removed.

This optional feature helps reduce chart clutter and keeps the focus on distinct opening-range value areas.

Default Configuration

Opening Range: 9:30–9:46 AM New York
Value Area: 70%
Profile Rows: 100
VAH / VAL / POC: Black, 2-width lines
Current Value Area: Pink, 20% opacity
Historical Value Areas: Differentiated by color

Send me a message with any questions or requests.

For educational and informational purposes only. This indicator does not provide financial advice or guarantee future market behavior.

---

## Source Code

````pine
//@version=6
indicator(
     "The Magnet Model - Opening Range Volume Profile",
     shorttitle = "The Magnet Model - ORVP",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 500,
     max_bars_back = 5000
)

//=====================================================================
// INPUT GROUPS
//=====================================================================

var string GROUP_OR      = "Opening Range"
var string GROUP_VP      = "Volume Profile"
var string GROUP_LEVELS  = "VAH / VAL / POC"
var string GROUP_FILL    = "Value Area Fill"
var string GROUP_DATE    = "OR Date Label"
var string GROUP_OVERLAP = "ORVP Overlap Detection"

//=====================================================================
// OPENING RANGE SETTINGS
//=====================================================================

timezoneInput = input.string(
     "America/New_York",
     "Timezone",
     group = GROUP_OR
)

orSession = input.session(
     "0930-0946",
     "Opening Range",
     group = GROUP_OR
)

sessionsToKeep = input.int(
     2,
     "Opening Ranges to Keep",
     minval = 1,
     maxval = 10,
     group = GROUP_OR
)

//=====================================================================
// VOLUME PROFILE SETTINGS
//=====================================================================

showProfile = input.bool(
     false,
     "Show Profile",
     group = GROUP_VP
)

rowCount = input.int(
     24,
     "Profile Rows",
     minval = 5,
     maxval = 100,
     group = GROUP_VP
)

valueAreaPct = input.float(
     70.0,
     "Value Area %",
     minval = 1,
     maxval = 100,
     step = 1,
     group = GROUP_VP
)

profileWidthPct = input.float(
     50.0,
     "Profile Width %",
     minval = 5,
     maxval = 100,
     step = 5,
     group = GROUP_VP
)

normalRowColor = input.color(
     color.black,
     "Normal Rows",
     group = GROUP_VP
)

valueAreaRowColor = input.color(
     color.black,
     "Value Area Rows",
     group = GROUP_VP
)

pocRowColor = input.color(
     color.black,
     "POC Row",
     group = GROUP_VP
)

//=====================================================================
// VAH / VAL / POC SETTINGS
//=====================================================================

showPOC = input.bool(
     true,
     "Show POC",
     group = GROUP_LEVELS
)

pocColor = input.color(
     color.black,
     "POC Color",
     group = GROUP_LEVELS
)

pocWidth = input.int(
     2,
     "POC Width",
     minval = 1,
     maxval = 5,
     group = GROUP_LEVELS
)

showVA = input.bool(
     true,
     "Show VAH / VAL",
     group = GROUP_LEVELS
)

vaColor = input.color(
     color.black,
     "VAH / VAL Color",
     group = GROUP_LEVELS
)

vaWidth = input.int(
     2,
     "VAH / VAL Width",
     minval = 1,
     maxval = 5,
     group = GROUP_LEVELS
)

lineStyleInput = input.string(
     "Solid",
     "Level Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_LEVELS
)

showLabels = input.bool(
     true,
     "Show VAH / VAL / POC Labels",
     group = GROUP_LEVELS
)

//=====================================================================
// VALUE AREA FILL SETTINGS
//=====================================================================

showValueAreaFill = input.bool(
     true,
     "Shade VAH to VAL",
     group = GROUP_FILL
)

currentORColor = input.color(
     color.new(color.rgb(233, 30, 99), 80),
     "Current OR",
     group = GROUP_FILL
)

previousORColor = input.color(
     color.new(color.rgb(72, 149, 239), 80),
     "Previous OR",
     group = GROUP_FILL
)

twoDaysAgoColor = input.color(
     color.new(color.rgb(194, 178, 128), 80),
     "2 ORs Ago",
     group = GROUP_FILL
)

threeDaysAgoColor = input.color(
     color.new(color.rgb(95, 168, 120), 80),
     "3 ORs Ago",
     group = GROUP_FILL
)

olderORColor = input.color(
     color.new(color.gray, 80),
     "Older ORs",
     group = GROUP_FILL
)

//=====================================================================
// OR DATE LABEL SETTINGS
//=====================================================================

showORDate = input.bool(
     true,
     "Show OR Date",
     group = GROUP_DATE
)

dateTextColor = input.color(
     color.black,
     "Date Text Color",
     group = GROUP_DATE
)

dateTextSizeInput = input.string(
     "Tiny",
     "Date Text Size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_DATE
)

dateLabelOffset = input.int(
     8,
     "Date Label Right Offset",
     minval = 0,
     maxval = 30,
     group = GROUP_DATE
)

//=====================================================================
// ORVP OVERLAP DETECTION
//=====================================================================

deleteOverlappingORs = input.bool(
     true,
     "Overlap Detection Deletion",
     group = GROUP_OVERLAP
)

//=====================================================================
// HELPERS
//=====================================================================

getLineStyle(string styleInput) =>
    lineStyle = line.style_solid

    if styleInput == "Dashed"
        lineStyle := line.style_dashed
    else if styleInput == "Dotted"
        lineStyle := line.style_dotted

    lineStyle

getDateTextSize(string sizeInput) =>
    textSize = size.tiny

    if sizeInput == "Small"
        textSize := size.small
    else if sizeInput == "Normal"
        textSize := size.normal

    textSize

getAgeColor(int age) =>
    color result = olderORColor

    if age == 0
        result := currentORColor
    else if age == 1
        result := previousORColor
    else if age == 2
        result := twoDaysAgoColor
    else if age == 3
        result := threeDaysAgoColor

    result

//=====================================================================
// OR PROFILE TYPE
//=====================================================================

type ORProfile
    array<box> rows
    line pocLine
    line vahLine
    line valLine
    linefill valueFill
    label pocLabel
    label vahLabel
    label valLabel
    label dateLabel
    float vahPrice
    float valPrice
    float pocPrice
    int dateID
    int monthNumber
    int dayNumber

//=====================================================================
// ORVP STATE
//=====================================================================

var array<float> sessionHighs =
     array.new_float()

var array<float> sessionLows =
     array.new_float()

var array<float> sessionVolumes =
     array.new_float()

var int sessionStartBar = na

var int orDateID = na
var int orMonth = na
var int orDay = na

var bool orCollecting = false

var ORProfile liveProfile = na

var array<ORProfile> profileHistory =
     array.new<ORProfile>()

//=====================================================================
// DELETE PROFILE
//=====================================================================

deleteProfile(ORProfile profile) =>

    if not na(profile)

        if not na(profile.valueFill)
            linefill.delete(profile.valueFill)

        if profile.rows.size() > 0

            for i = 0 to profile.rows.size() - 1
                box.delete(profile.rows.get(i))

        if not na(profile.pocLine)
            line.delete(profile.pocLine)

        if not na(profile.vahLine)
            line.delete(profile.vahLine)

        if not na(profile.valLine)
            line.delete(profile.valLine)

        if not na(profile.pocLabel)
            label.delete(profile.pocLabel)

        if not na(profile.vahLabel)
            label.delete(profile.vahLabel)

        if not na(profile.valLabel)
            label.delete(profile.valLabel)

        if not na(profile.dateLabel)
            label.delete(profile.dateLabel)

//=====================================================================
// UPDATE HISTORICAL COLORS
//=====================================================================

updateHistoryColors() =>

    if profileHistory.size() > 0

        for i = 0 to profileHistory.size() - 1

            ORProfile p =
                 profileHistory.get(i)

            color desiredColor =
                 getAgeColor(i)

            if not na(p.valueFill)

                linefill.set_color(
                     p.valueFill,
                     desiredColor
                )

    true

//=====================================================================
// BUILD PROFILE FROM STORED SOURCE BARS
//=====================================================================

buildProfile() =>

    ORProfile result = na

    int barCount =
         sessionHighs.size()

    if barCount > 0

        float profileHigh =
             sessionHighs.max()

        float profileLow =
             sessionLows.min()

        float profileRange =
             profileHigh -
             profileLow

        if profileRange > 0

            float rowHeight =
                 profileRange /
                 rowCount

            array<float> volumeRows =
                 array.new_float(
                      rowCount,
                      0.0
                 )

            //---------------------------------------------------------
            // DISTRIBUTE SOURCE-BAR VOLUME ACROSS PROFILE ROWS
            //---------------------------------------------------------

            for i = 0 to barCount - 1

                float barHigh =
                     sessionHighs.get(i)

                float barLow =
                     sessionLows.get(i)

                float barVolume =
                     sessionVolumes.get(i)

                float barRange =
                     barHigh -
                     barLow

                if barRange <= 0

                    float rawIndex =
                         (
                              barHigh -
                              profileLow
                         ) /
                         rowHeight

                    int idx =
                         int(
                              math.min(
                                   rowCount - 1,
                                   math.max(
                                        0.0,
                                        rawIndex
                                   )
                              )
                         )

                    volumeRows.set(
                         idx,
                         volumeRows.get(idx) +
                         barVolume
                    )

                else

                    for r = 0 to rowCount - 1

                        float rowBottom =
                             profileLow +
                             r *
                             rowHeight

                        float rowTop =
                             rowBottom +
                             rowHeight

                        float overlapTop =
                             math.min(
                                  barHigh,
                                  rowTop
                             )

                        float overlapBottom =
                             math.max(
                                  barLow,
                                  rowBottom
                             )

                        float overlap =
                             overlapTop -
                             overlapBottom

                        if overlap > 0

                            float distributedVolume =
                                 barVolume *
                                 overlap /
                                 barRange

                            volumeRows.set(
                                 r,
                                 volumeRows.get(r) +
                                 distributedVolume
                            )

            //---------------------------------------------------------
            // POINT OF CONTROL
            //---------------------------------------------------------

            float maximumVolume =
                 volumeRows.max()

            int pocIndex =
                 volumeRows.indexof(
                      maximumVolume
                 )

            float totalVolume =
                 volumeRows.sum()

            //---------------------------------------------------------
            // VALUE AREA
            //---------------------------------------------------------

            float targetVolume =
                 totalVolume *
                 valueAreaPct /
                 100.0

            float accumulatedVolume =
                 volumeRows.get(
                      pocIndex
                 )

            int lowerIndex =
                 pocIndex

            int upperIndex =
                 pocIndex

            while accumulatedVolume < targetVolume and
                 (
                      lowerIndex > 0 or
                      upperIndex < rowCount - 1
                 )

                float volumeBelow =
                     -1.0

                float volumeAbove =
                     -1.0

                if lowerIndex > 0

                    volumeBelow :=
                         volumeRows.get(
                              lowerIndex - 1
                         )

                if upperIndex < rowCount - 1

                    volumeAbove :=
                         volumeRows.get(
                              upperIndex + 1
                         )

                if volumeAbove >= volumeBelow

                    upperIndex += 1

                    accumulatedVolume +=
                         volumeAbove

                else

                    lowerIndex -= 1

                    accumulatedVolume +=
                         volumeBelow

            //---------------------------------------------------------
            // FINAL VAH / VAL / POC PRICES
            //---------------------------------------------------------

            float pocPrice =
                 profileLow +
                 (
                      pocIndex + 0.5
                 ) *
                 rowHeight

            float vahPrice =
                 profileLow +
                 (
                      upperIndex + 1
                 ) *
                 rowHeight

            float valPrice =
                 profileLow +
                 lowerIndex *
                 rowHeight

            //---------------------------------------------------------
            // PROFILE ROWS
            //---------------------------------------------------------

            array<box> rowBoxes =
                 array.new<box>()

            int currentBar =
                 bar_index

            int sessionWidth =
                 math.max(
                      1,
                      currentBar -
                      sessionStartBar
                 )

            int maxProfileWidth =
                 math.max(
                      1,
                      int(
                           sessionWidth *
                           profileWidthPct /
                           100.0
                      )
                 )

            maxProfileWidth :=
                 math.min(
                      maxProfileWidth,
                      sessionWidth
                 )

            if showProfile

                for r = 0 to rowCount - 1

                    float rowBottom =
                         profileLow +
                         r *
                         rowHeight

                    float rowTop =
                         rowBottom +
                         rowHeight

                    float rowVolume =
                         volumeRows.get(r)

                    int profileRowWidth =
                         1

                    if maximumVolume > 0

                        profileRowWidth :=
                             int(
                                  maxProfileWidth *
                                  rowVolume /
                                  maximumVolume
                             )

                    profileRowWidth :=
                         math.max(
                              profileRowWidth,
                              1
                         )

                    color profileColor =
                         normalRowColor

                    if r == pocIndex

                        profileColor :=
                             pocRowColor

                    else if
                         r >= lowerIndex and
                         r <= upperIndex

                        profileColor :=
                             valueAreaRowColor

                    box profileBox =
                         box.new(
                              sessionStartBar,
                              rowTop,
                              sessionStartBar +
                              profileRowWidth,
                              rowBottom,
                              border_color = na,
                              bgcolor = profileColor
                         )

                    rowBoxes.push(
                         profileBox
                    )

            //---------------------------------------------------------
            // VAH / VAL / POC RAYS
            //---------------------------------------------------------

            line pocLine = na
            line vahLine = na
            line valLine = na

            if showPOC

                pocLine :=
                     line.new(
                          sessionStartBar,
                          pocPrice,
                          currentBar,
                          pocPrice,
                          color = pocColor,
                          width = pocWidth,
                          style = getLineStyle(lineStyleInput),
                          extend = extend.right
                     )

            if showVA

                vahLine :=
                     line.new(
                          sessionStartBar,
                          vahPrice,
                          currentBar,
                          vahPrice,
                          color = vaColor,
                          width = vaWidth,
                          style = getLineStyle(lineStyleInput),
                          extend = extend.right
                     )

                valLine :=
                     line.new(
                          sessionStartBar,
                          valPrice,
                          currentBar,
                          valPrice,
                          color = vaColor,
                          width = vaWidth,
                          style = getLineStyle(lineStyleInput),
                          extend = extend.right
                     )

            //---------------------------------------------------------
            // VALUE AREA FILL
            //---------------------------------------------------------

            linefill valueFill = na

            if showValueAreaFill and
                 not na(vahLine) and
                 not na(valLine)

                valueFill :=
                     linefill.new(
                          vahLine,
                          valLine,
                          currentORColor
                     )

            //---------------------------------------------------------
            // VAH / VAL / POC LABELS
            //---------------------------------------------------------

            label pocLabel = na
            label vahLabel = na
            label valLabel = na

            if showLabels

                if showPOC

                    pocLabel :=
                         label.new(
                              sessionStartBar,
                              pocPrice,
                              "POC",
                              style = label.style_label_right,
                              color = color.new(color.white, 100),
                              textcolor = pocColor,
                              size = size.small
                         )

                if showVA

                    vahLabel :=
                         label.new(
                              sessionStartBar,
                              vahPrice,
                              "VAH",
                              style = label.style_label_right,
                              color = color.new(color.white, 100),
                              textcolor = vaColor,
                              size = size.small
                         )

                    valLabel :=
                         label.new(
                              sessionStartBar,
                              valPrice,
                              "VAL",
                              style = label.style_label_right,
                              color = color.new(color.white, 100),
                              textcolor = vaColor,
                              size = size.small
                         )

            //---------------------------------------------------------
            // DATE LABEL
            //---------------------------------------------------------

            label dateLabel = na

            if showORDate

                string dateText =
                     str.tostring(orMonth) +
                     "/" +
                     str.tostring(orDay) +
                     " ORVP"

                float dateY =
                     valPrice +
                     syminfo.mintick *
                     2

                int dateX =
                     currentBar +
                     dateLabelOffset

                dateLabel :=
                     label.new(
                          dateX,
                          dateY,
                          dateText,
                          style = label.style_none,
                          textcolor = dateTextColor,
                          size = getDateTextSize(dateTextSizeInput),
                          textalign = text.align_left
                     )

            result :=
                 ORProfile.new(
                      rowBoxes,
                      pocLine,
                      vahLine,
                      valLine,
                      valueFill,
                      pocLabel,
                      vahLabel,
                      valLabel,
                      dateLabel,
                      vahPrice,
                      valPrice,
                      pocPrice,
                      orDateID,
                      orMonth,
                      orDay
                 )

    result

//=====================================================================
// AUTOMATIC ORVP DATA QUALITY LADDER
//
// Priority:
// 1. 1-minute
// 2. 2-minute
// 3. 5-minute
// 4. 10-minute
// 5. Current chart data
//
// The script therefore preserves the 1-minute ORVP whenever TradingView
// makes 1-minute intrabars available. Older Bar Replay history can fall
// back to progressively coarser data rather than showing no ORVP.
//=====================================================================

[or1mTimes, or1mHighs, or1mLows, or1mVolumes] = request.security_lower_tf(
     syminfo.tickerid,
     "1",
     [time, high, low, volume],
     ignore_invalid_timeframe = true,
     calc_bars_count = 100000
)

[or2mTimes, or2mHighs, or2mLows, or2mVolumes] = request.security_lower_tf(
     syminfo.tickerid,
     "2",
     [time, high, low, volume],
     ignore_invalid_timeframe = true,
     calc_bars_count = 100000
)

[or5mTimes, or5mHighs, or5mLows, or5mVolumes] = request.security_lower_tf(
     syminfo.tickerid,
     "5",
     [time, high, low, volume],
     ignore_invalid_timeframe = true,
     calc_bars_count = 100000
)

[or10mTimes, or10mHighs, or10mLows, or10mVolumes] = request.security_lower_tf(
     syminfo.tickerid,
     "10",
     [time, high, low, volume],
     ignore_invalid_timeframe = true,
     calc_bars_count = 100000
)

//=====================================================================
// SELECT BEST AVAILABLE SOURCE FOR EACH CHART BAR
//=====================================================================

array<int> selectedORTimes =
     array.new_int()

array<float> selectedORHighs =
     array.new_float()

array<float> selectedORLows =
     array.new_float()

array<float> selectedORVolumes =
     array.new_float()

if array.size(or1mTimes) > 0

    selectedORTimes := or1mTimes
    selectedORHighs := or1mHighs
    selectedORLows := or1mLows
    selectedORVolumes := or1mVolumes

else if array.size(or2mTimes) > 0

    selectedORTimes := or2mTimes
    selectedORHighs := or2mHighs
    selectedORLows := or2mLows
    selectedORVolumes := or2mVolumes

else if array.size(or5mTimes) > 0

    selectedORTimes := or5mTimes
    selectedORHighs := or5mHighs
    selectedORLows := or5mLows
    selectedORVolumes := or5mVolumes

else if array.size(or10mTimes) > 0

    selectedORTimes := or10mTimes
    selectedORHighs := or10mHighs
    selectedORLows := or10mLows
    selectedORVolumes := or10mVolumes

else if timeframe.isintraday

    selectedORTimes.push(time)
    selectedORHighs.push(high)
    selectedORLows.push(low)
    selectedORVolumes.push(volume)

int selectedORCount =
     array.size(selectedORTimes)

//=====================================================================
// PROCESS BEST AVAILABLE ORVP SOURCE
//=====================================================================

if selectedORCount > 0

    for i = 0 to selectedORCount - 1

        int sourceBarTime =
             array.get(
                  selectedORTimes,
                  i
             )

        float sourceBarHigh =
             array.get(
                  selectedORHighs,
                  i
             )

        float sourceBarLow =
             array.get(
                  selectedORLows,
                  i
             )

        float sourceBarVolume =
             array.get(
                  selectedORVolumes,
                  i
             )

        int sourceHour =
             hour(
                  sourceBarTime,
                  timezoneInput
             )

        int sourceMinute =
             minute(
                  sourceBarTime,
                  timezoneInput
             )

        int sourceMonth =
             month(
                  sourceBarTime,
                  timezoneInput
             )

        int sourceDay =
             dayofmonth(
                  sourceBarTime,
                  timezoneInput
             )

        int sourceYear =
             year(
                  sourceBarTime,
                  timezoneInput
             )

        int sourceDateID =
             sourceYear *
             10000 +
             sourceMonth *
             100 +
             sourceDay

        int sourceMinuteOfDay =
             sourceHour *
             60 +
             sourceMinute

        bool sourceBarInOR =
             sourceMinuteOfDay >= 570 and
             sourceMinuteOfDay < 586

        //-------------------------------------------------------------
        // START NEW OR
        //-------------------------------------------------------------

        if sourceBarInOR and
             (
                  not orCollecting or
                  sourceDateID != orDateID
             )

            sessionHighs.clear()
            sessionLows.clear()
            sessionVolumes.clear()

            if not na(liveProfile)
                deleteProfile(liveProfile)

            liveProfile := na

            sessionStartBar :=
                 bar_index

            orDateID :=
                 sourceDateID

            orMonth :=
                 sourceMonth

            orDay :=
                 sourceDay

            orCollecting :=
                 true

        //-------------------------------------------------------------
        // COLLECT OR SOURCE DATA
        //-------------------------------------------------------------

        if sourceBarInOR and
             orCollecting and
             sourceDateID == orDateID

            sessionHighs.push(
                 sourceBarHigh
            )

            sessionLows.push(
                 sourceBarLow
            )

            sessionVolumes.push(
                 sourceBarVolume
            )

            if not na(liveProfile)
                deleteProfile(
                     liveProfile
                )

            liveProfile :=
                 buildProfile()

        //-------------------------------------------------------------
        // FINALIZE AT / AFTER 09:46
        //-------------------------------------------------------------

        if not sourceBarInOR and
             orCollecting and
             (
                  sourceDateID != orDateID or
                  sourceMinuteOfDay >= 586
             )

            if not na(liveProfile)
                deleteProfile(
                     liveProfile
                )

            liveProfile :=
                 buildProfile()

            if not na(liveProfile)

                profileHistory.unshift(
                     liveProfile
                )

                liveProfile := na

                //-----------------------------------------------------
                // DELETE OLDER OVERLAPPING ORVPS
                //-----------------------------------------------------

                if deleteOverlappingORs and
                     profileHistory.size() > 1

                    ORProfile newestProfile =
                         profileHistory.get(0)

                    float newestVAH =
                         newestProfile.vahPrice

                    float newestVAL =
                         newestProfile.valPrice

                    int overlapIndex =
                         profileHistory.size() - 1

                    while overlapIndex >= 1

                        ORProfile olderProfile =
                             profileHistory.get(
                                  overlapIndex
                             )

                        bool zonesOverlap =
                             olderProfile.valPrice <=
                             newestVAH and
                             olderProfile.vahPrice >=
                             newestVAL

                        if zonesOverlap

                            deleteProfile(
                                 olderProfile
                            )

                            profileHistory.remove(
                                 overlapIndex
                            )

                        overlapIndex -= 1

                //-----------------------------------------------------
                // ENFORCE HISTORY LIMIT
                //-----------------------------------------------------

                while profileHistory.size() >
                     sessionsToKeep

                    ORProfile oldProfile =
                         profileHistory.pop()

                    deleteProfile(
                         oldProfile
                    )

                bool colorsUpdated =
                     updateHistoryColors()

            orCollecting :=
                 false

//=====================================================================
// KEEP DATE LABELS / HISTORICAL COLORS CURRENT
//=====================================================================

if barstate.islast

    bool colorsUpdated =
         updateHistoryColors()

    if profileHistory.size() > 0

        for i = 0 to profileHistory.size() - 1

            ORProfile p =
                 profileHistory.get(i)

            if not na(p.dateLabel)

                label.set_x(
                     p.dateLabel,
                     bar_index +
                     dateLabelOffset
                )

                label.set_y(
                     p.dateLabel,
                     p.valPrice +
                     syminfo.mintick *
                     2
                )
````
