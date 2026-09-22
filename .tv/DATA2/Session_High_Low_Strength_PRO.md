<!-- tradingview-pine-id: PUB;9fae99361edf4d24819a0fbde44a2bec -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session High / Low Strength PRO

Source: https://www.tradingview.com/script/GEWgKYsh-Session-High-Low-Strength/

## Description

**Session High / Low Strength PRO** is a session-based market structure indicator designed to automatically track the High and Low of multiple trading sessions while also calculating how strong each level is.

The indicator can be fully customized for different markets, time zones, and trading styles. Each session can have its own name, trading hours, and color.

### Main Features

• Tracks the **Session High and Session Low** automatically
• Supports up to **4 fully customizable sessions**
• Custom **From / To session times**
• Adjustable **UTC / GMT timezone**
• Works with Asia, London, New York, custom sessions, or any other time window
• Automatically extends completed session levels
• Optional strength labels
• Live dashboard displaying session levels and strength
• Customizable line styles, colors, and widths

### High / Low Strength Score

Each Session High and Session Low receives a **Strength Score from 0 to 100**.

The score combines several different factors instead of relying on only one measurement.

**Level Touches**

The indicator tracks how often price interacts with the Session High or Low. Multiple reactions around the same price can indicate that the level is being respected by the market.

**Wick Rejection**

Long rejection wicks around the Session High or Low can indicate aggressive rejection of that price area.

**Relative Volume**

Volume around each level is compared with average market volume. Higher relative volume during a test can indicate stronger participation around the level.

**Close Away Strength**

The indicator measures how strongly price closes away from the Session High or Low after interacting with it. A stronger move away from the level can indicate stronger rejection.

### Strength Classification

The final score is classified as:

**0–24:** VERY WEAK
**25–39:** WEAK
**40–54:** MODERATE
**55–69:** STRONG
**70–84:** VERY STRONG
**85–100:** EXTREME

The weight of each strength component can be adjusted individually in the settings.

### Session Configuration

Every session can be configured independently.

Example:

**Asia Session**
00:00 – 08:00

**London Session**
07:00 – 16:00

**New York Session**
13:30 – 20:00

**Custom Session**
Any user-defined trading period

These are only example times. All session times can be changed directly in the indicator settings.

### Time Zone Support

The indicator supports customizable time zones, allowing the same session logic to be used regardless of the chart's exchange timezone.

Examples:

GMT+0
GMT+1
GMT+2
GMT-4
GMT-5

You can also use supported timezone names such as:

Europe/London
America/New_York

This makes the indicator useful for traders who work with specific session windows across different global markets.

### Extended Session Levels

When a session finishes, its High and Low can automatically extend to the right side of the chart.

This allows previous session levels to act as potential:

• Support
• Resistance
• Liquidity targets
• Breakout levels
• Reversal areas
• BOS / CHoCH confirmation zones

When the same session starts again, the previous session levels stop extending and the new session begins calculating its own High and Low.

### Dashboard

The built-in dashboard shows:

• Session name
• Session High
• High Strength Score
• Session Low
• Low Strength Score
• Strength classification

This makes it possible to quickly compare the most important session levels without manually checking every line on the chart.

### Trading Applications

The indicator can be used together with:

• BOS / CHoCH
• Market Structure Shift
• Liquidity Sweeps
• Breakout & Retest strategies
• Support and Resistance
• Volume Profile
• Session trading
• Reversal setups
• Trend continuation setups

For example, a Session High with a high strength score may represent a more significant liquidity or resistance area than a Session High that formed with very little volume and no meaningful rejection.

### Important

The Strength Score should not be interpreted as a prediction that a level will definitely hold.

A strong level can still break.

The score is designed to provide additional context about how the level was formed and how strongly the market previously reacted around that area.

It is best used together with price action, market structure, volume, and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("Session High / Low Strength PRO", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
// GLOBAL SETTINGS
// ============================================================================

groupGeneral = "General Settings"

timeZone = input.string(
     "GMT+0",
     "Time Zone",
     tooltip = "Enter any valid TradingView timezone. Examples: GMT+0, GMT+1, GMT+2, GMT-5, Europe/London, America/New_York.",
     group = groupGeneral)

extendCompleted = input.bool(
     true,
     "Extend Levels Until Next Same Session",
     group = groupGeneral)

showStrengthLabels = input.bool(
     true,
     "Show Strength Labels",
     group = groupGeneral)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = groupGeneral)

lineWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = groupGeneral)

highStyleInput = input.string(
     "Solid",
     "High Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupGeneral)

lowStyleInput = input.string(
     "Dashed",
     "Low Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupGeneral)


// ============================================================================
// STRENGTH SETTINGS
// ============================================================================

groupStrength = "Strength Calculation"

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = groupStrength)

volumeLength = input.int(
     20,
     "Volume Average Length",
     minval = 1,
     group = groupStrength)

touchToleranceATR = input.float(
     0.08,
     "Touch Tolerance - ATR",
     minval = 0.0,
     step = 0.01,
     tooltip = "Distance from the High/Low that still counts as a level touch.",
     group = groupStrength)

touchWeight = input.float(
     25.0,
     "Touch Weight",
     minval = 0,
     maxval = 100,
     group = groupStrength)

wickWeight = input.float(
     30.0,
     "Rejection Wick Weight",
     minval = 0,
     maxval = 100,
     group = groupStrength)

volumeWeight = input.float(
     25.0,
     "Relative Volume Weight",
     minval = 0,
     maxval = 100,
     group = groupStrength)

closeAwayWeight = input.float(
     20.0,
     "Close Away Weight",
     minval = 0,
     maxval = 100,
     tooltip = "Measures how strongly price closes away from the Session High or Low.",
     group = groupStrength)


// ============================================================================
// SESSION 1
// ============================================================================

groupS1 = "Session 1"

s1Enabled = input.bool(true, "Enable Session", group = groupS1)
s1Name = input.string("Asia", "Session Name", group = groupS1)
s1Time = input.session("0000-0800", "From - To", group = groupS1)
s1Color = input.color(color.rgb(33, 150, 243), "Color", group = groupS1)


// ============================================================================
// SESSION 2
// ============================================================================

groupS2 = "Session 2"

s2Enabled = input.bool(true, "Enable Session", group = groupS2)
s2Name = input.string("London", "Session Name", group = groupS2)
s2Time = input.session("0700-1600", "From - To", group = groupS2)
s2Color = input.color(color.rgb(255, 152, 0), "Color", group = groupS2)


// ============================================================================
// SESSION 3
// ============================================================================

groupS3 = "Session 3"

s3Enabled = input.bool(true, "Enable Session", group = groupS3)
s3Name = input.string("New York", "Session Name", group = groupS3)
s3Time = input.session("1330-2000", "From - To", group = groupS3)
s3Color = input.color(color.rgb(156, 39, 176), "Color", group = groupS3)


// ============================================================================
// SESSION 4
// ============================================================================

groupS4 = "Session 4"

s4Enabled = input.bool(false, "Enable Session", group = groupS4)
s4Name = input.string("Custom", "Session Name", group = groupS4)
s4Time = input.session("2000-2359", "From - To", group = groupS4)
s4Color = input.color(color.rgb(0, 188, 212), "Color", group = groupS4)


// ============================================================================
// BASE CALCULATIONS
// ============================================================================

atrValue = ta.atr(atrLength)
avgVolume = ta.sma(volume, volumeLength)


// ============================================================================
// HELPERS
// ============================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))


f_lineStyle(string styleInput) =>
    switch styleInput
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid


highLineStyle = f_lineStyle(highStyleInput)
lowLineStyle = f_lineStyle(lowStyleInput)


f_grade(float strength) =>
    if na(strength)
        "N/A"
    else if strength >= 85
        "EXTREME"
    else if strength >= 70
        "VERY STRONG"
    else if strength >= 55
        "STRONG"
    else if strength >= 40
        "MODERATE"
    else if strength >= 25
        "WEAK"
    else
        "VERY WEAK"


f_strengthText(float strength) =>
    if na(strength)
        "N/A"
    else
        str.tostring(int(math.round(strength))) + "/100 • " + f_grade(strength)


// ============================================================================
// STRENGTH CALCULATION
// ============================================================================

f_strength(
     int touches,
     float wickSum,
     float volumeRatioSum,
     float closeAway) =>

    float touchScore =
         f_clamp(
             touches / 4.0,
             0.0,
             1.0) * touchWeight

    float averageWick =
         touches > 0 ?
         wickSum / touches :
         0.0

    float wickScore =
         f_clamp(
             averageWick / 0.50,
             0.0,
             1.0) * wickWeight

    float averageVolumeRatio =
         touches > 0 ?
         volumeRatioSum / touches :
         1.0

    float volumeScore =
         f_clamp(
             averageVolumeRatio / 2.0,
             0.0,
             1.0) * volumeWeight

    float closeScore =
         f_clamp(
             closeAway,
             0.0,
             1.0) * closeAwayWeight

    float totalWeight =
         touchWeight +
         wickWeight +
         volumeWeight +
         closeAwayWeight

    float rawScore =
         touchScore +
         wickScore +
         volumeScore +
         closeScore

    totalWeight > 0 ?
         f_clamp(rawScore / totalWeight * 100.0, 0.0, 100.0) :
         0.0


// ============================================================================
// SESSION STATE OBJECT
// ============================================================================

type SessionState
    float sessionHigh = na
    float sessionLow = na

    int startBar = na

    int highTouches = 0
    int lowTouches = 0

    float highWickSum = 0.0
    float lowWickSum = 0.0

    float highVolumeRatioSum = 0.0
    float lowVolumeRatioSum = 0.0

    float highStrength = na
    float lowStrength = na

    float lastClose = na

    line highLine = na
    line lowLine = na


// ============================================================================
// SESSION PROCESSOR
// ============================================================================

f_processSession(
     SessionState state,
     bool enabled,
     string sessionTime,
     string sessionName,
     color sessionColor) =>

    bool inSession =
         enabled and
         not na(time(timeframe.period, sessionTime, timeZone))

    bool newSession =
         inSession and
         not inSession[1]

    bool sessionEnded =
         not inSession and
         inSession[1]

    float candleRange =
         math.max(
             high - low,
             syminfo.mintick)

    float upperWick =
         high -
         math.max(open, close)

    float lowerWick =
         math.min(open, close) -
         low

    float upperWickRatio =
         upperWick / candleRange

    float lowerWickRatio =
         lowerWick / candleRange

    float volumeRatio =
         not na(avgVolume) and
         avgVolume > 0 ?
         nz(volume, avgVolume) / avgVolume :
         1.0

    float tolerance =
         nz(atrValue, candleRange) *
         touchToleranceATR


    // ========================================================================
    // NEW SESSION
    // ========================================================================

    if newSession

        // Stop the previous extended session level
        if extendCompleted

            if not na(state.highLine)
                line.set_extend(
                     state.highLine,
                     extend.none)

                line.set_x2(
                     state.highLine,
                     bar_index)

            if not na(state.lowLine)
                line.set_extend(
                     state.lowLine,
                     extend.none)

                line.set_x2(
                     state.lowLine,
                     bar_index)


        state.sessionHigh := high
        state.sessionLow := low

        state.startBar := bar_index

        state.highTouches := 1
        state.lowTouches := 1

        state.highWickSum := upperWickRatio
        state.lowWickSum := lowerWickRatio

        state.highVolumeRatioSum := volumeRatio
        state.lowVolumeRatioSum := volumeRatio

        state.lastClose := close


        state.highLine := line.new(
             state.startBar,
             state.sessionHigh,
             bar_index,
             state.sessionHigh,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = sessionColor,
             width = lineWidth,
             style = highLineStyle)


        state.lowLine := line.new(
             state.startBar,
             state.sessionLow,
             bar_index,
             state.sessionLow,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = sessionColor,
             width = lineWidth,
             style = lowLineStyle)


    // ========================================================================
    // ACTIVE SESSION
    // ========================================================================

    else if inSession

        state.lastClose := close


        // --------------------------------------------------------------------
        // SESSION HIGH
        // --------------------------------------------------------------------

        if high > state.sessionHigh

            state.sessionHigh := high

            state.highTouches := 1

            state.highWickSum :=
                 upperWickRatio

            state.highVolumeRatioSum :=
                 volumeRatio

        else if high >= state.sessionHigh - tolerance

            state.highTouches += 1

            state.highWickSum +=
                 upperWickRatio

            state.highVolumeRatioSum +=
                 volumeRatio


        // --------------------------------------------------------------------
        // SESSION LOW
        // --------------------------------------------------------------------

        if low < state.sessionLow

            state.sessionLow := low

            state.lowTouches := 1

            state.lowWickSum :=
                 lowerWickRatio

            state.lowVolumeRatioSum :=
                 volumeRatio

        else if low <= state.sessionLow + tolerance

            state.lowTouches += 1

            state.lowWickSum +=
                 lowerWickRatio

            state.lowVolumeRatioSum +=
                 volumeRatio


        // --------------------------------------------------------------------
        // UPDATE LINES
        // --------------------------------------------------------------------

        if not na(state.highLine)

            line.set_xy1(
                 state.highLine,
                 state.startBar,
                 state.sessionHigh)

            line.set_xy2(
                 state.highLine,
                 bar_index,
                 state.sessionHigh)


        if not na(state.lowLine)

            line.set_xy1(
                 state.lowLine,
                 state.startBar,
                 state.sessionLow)

            line.set_xy2(
                 state.lowLine,
                 bar_index,
                 state.sessionLow)


    // ========================================================================
    // LIVE STRENGTH
    // ========================================================================

    if inSession

        float sessionRange =
             math.max(
                 state.sessionHigh -
                 state.sessionLow,
                 syminfo.mintick)

        float highCloseAway =
             f_clamp(
                 (state.sessionHigh - close) /
                 sessionRange,
                 0.0,
                 1.0)

        float lowCloseAway =
             f_clamp(
                 (close - state.sessionLow) /
                 sessionRange,
                 0.0,
                 1.0)


        state.highStrength :=
             f_strength(
                 state.highTouches,
                 state.highWickSum,
                 state.highVolumeRatioSum,
                 highCloseAway)


        state.lowStrength :=
             f_strength(
                 state.lowTouches,
                 state.lowWickSum,
                 state.lowVolumeRatioSum,
                 lowCloseAway)


    // ========================================================================
    // SESSION FINISHED
    // ========================================================================

    if sessionEnded

        if extendCompleted

            if not na(state.highLine)
                line.set_extend(
                     state.highLine,
                     extend.right)

            if not na(state.lowLine)
                line.set_extend(
                     state.lowLine,
                     extend.right)


        // --------------------------------------------------------------------
        // STRENGTH LABELS
        // --------------------------------------------------------------------

        if showStrengthLabels

            if not na(state.highLine)

                label.new(
                     line.get_x2(state.highLine),
                     state.sessionHigh,
                     sessionName +
                     " HIGH\n" +
                     f_strengthText(state.highStrength) +
                     "\nTouches: " +
                     str.tostring(state.highTouches),
                     xloc = xloc.bar_index,
                     style = label.style_label_down,
                     color = sessionColor,
                     textcolor = color.white,
                     size = size.tiny)


            if not na(state.lowLine)

                label.new(
                     line.get_x2(state.lowLine),
                     state.sessionLow,
                     sessionName +
                     " LOW\n" +
                     f_strengthText(state.lowStrength) +
                     "\nTouches: " +
                     str.tostring(state.lowTouches),
                     xloc = xloc.bar_index,
                     style = label.style_label_up,
                     color = sessionColor,
                     textcolor = color.white,
                     size = size.tiny)


// ============================================================================
// CREATE SESSION STATES
// ============================================================================

var SessionState session1 =
     SessionState.new()

var SessionState session2 =
     SessionState.new()

var SessionState session3 =
     SessionState.new()

var SessionState session4 =
     SessionState.new()


// ============================================================================
// RUN SESSIONS
// ============================================================================

f_processSession(
     session1,
     s1Enabled,
     s1Time,
     s1Name,
     s1Color)

f_processSession(
     session2,
     s2Enabled,
     s2Time,
     s2Name,
     s2Color)

f_processSession(
     session3,
     s3Enabled,
     s3Time,
     s3Name,
     s3Color)

f_processSession(
     session4,
     s4Enabled,
     s4Time,
     s4Name,
     s4Color)


// ============================================================================
// DASHBOARD
// ============================================================================

var table dashboard =
     table.new(
         position.top_right,
         5,
         5,
         border_width = 1)


f_price(float value) =>
    na(value) ?
         "N/A" :
         str.tostring(value, format.mintick)


f_score(float value) =>
    na(value) ?
         "N/A" :
         str.tostring(int(math.round(value))) +
         " | " +
         f_grade(value)


if barstate.islast and showDashboard

    // HEADER

    table.cell(
         dashboard,
         0,
         0,
         "SESSION",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         0,
         "HIGH",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(
         dashboard,
         2,
         0,
         "HIGH STRENGTH",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(
         dashboard,
         3,
         0,
         "LOW",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(
         dashboard,
         4,
         0,
         "LOW STRENGTH",
         bgcolor = color.black,
         text_color = color.white)


    // SESSION 1

    table.cell(
         dashboard,
         0,
         1,
         s1Name,
         bgcolor = color.new(s1Color, 70),
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         1,
         f_price(session1.sessionHigh))

    table.cell(
         dashboard,
         2,
         1,
         f_score(session1.highStrength))

    table.cell(
         dashboard,
         3,
         1,
         f_price(session1.sessionLow))

    table.cell(
         dashboard,
         4,
         1,
         f_score(session1.lowStrength))


    // SESSION 2

    table.cell(
         dashboard,
         0,
         2,
         s2Name,
         bgcolor = color.new(s2Color, 70),
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         2,
         f_price(session2.sessionHigh))

    table.cell(
         dashboard,
         2,
         2,
         f_score(session2.highStrength))

    table.cell(
         dashboard,
         3,
         2,
         f_price(session2.sessionLow))

    table.cell(
         dashboard,
         4,
         2,
         f_score(session2.lowStrength))


    // SESSION 3

    table.cell(
         dashboard,
         0,
         3,
         s3Name,
         bgcolor = color.new(s3Color, 70),
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         3,
         f_price(session3.sessionHigh))

    table.cell(
         dashboard,
         2,
         3,
         f_score(session3.highStrength))

    table.cell(
         dashboard,
         3,
         3,
         f_price(session3.sessionLow))

    table.cell(
         dashboard,
         4,
         3,
         f_score(session3.lowStrength))


    // SESSION 4

    table.cell(
         dashboard,
         0,
         4,
         s4Name,
         bgcolor = color.new(s4Color, 70),
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         4,
         f_price(session4.sessionHigh))

    table.cell(
         dashboard,
         2,
         4,
         f_score(session4.highStrength))

    table.cell(
         dashboard,
         3,
         4,
         f_price(session4.sessionLow))

    table.cell(
         dashboard,
         4,
         4,
         f_score(session4.lowStrength))
````
