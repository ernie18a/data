<!-- tradingview-pine-id: PUB;717005fcb8984398bee315d9c2940fa9 -->
<!-- tradingviewscripts-format: 1 -->
#  Market Clock

Source: https://www.tradingview.com/script/A3kkupo1-Market-Clock-Candle-Session-Timer/

## Description

[https://www.tradingview.com/x/EdZk3AR8/](https://www.tradingview.com/x/EdZk3AR8/)

Market Clock — Candle & Session Timer

Market Clock is a multi-timeframe trading clock designed to make market timing easier to see at a glance.

Most candle countdown tools answer a single question: How much time is left in the current candle?

Market Clock expands that idea into a compact timing dashboard. It simultaneously tracks the active chart candle, higher-timeframe candle development, and important market-session events so traders can understand not only how much time remains, but where they currently are within the market's timing structure.

MULTI-TIMEFRAME CANDLE CLOCKS

Market Clock monitors three timing layers simultaneously:

Chart Timeframe — automatically follows the active chart
Higher Timeframe 1 — configurable by the user
Higher Timeframe 2 — configurable by the user

Each active candle displays its remaining time alongside its percentage of completion.

This can be particularly useful for traders who use lower timeframes for execution while relying on higher timeframes for confirmation. Instead of switching charts simply to check when a higher-timeframe candle closes, Market Clock keeps those clocks visible from the current chart.

CANDLE PROGRESS

Time remaining tells only part of the story.

Market Clock also visualizes how far each candle has progressed through its lifespan using a segmented progress meter and percentage reading.

This provides immediate context for questions such as:

Is this higher-timeframe candle just beginning, or is it approaching confirmation?

A setup appearing during the first portion of a candle may carry very different implications from the same setup appearing moments before that candle closes.

As candles approach completion, the progress display changes state to make late-stage candles easier to recognize.

CLOSING WARNING

The final seconds of a candle can be particularly important when waiting for candle-close confirmation.

Market Clock includes a configurable Closing Warning Threshold. When an active candle enters this window, its timer changes state and the dashboard status changes to CLOSING.

This makes approaching closes visible without requiring the trader to continually watch the countdown.

MARKET EVENT COUNTDOWNS

Trading does not occur only according to candle boundaries. Important market-session transitions have their own clocks.

Market Clock currently tracks:

NY Cash Open
Countdown to the 9:30 AM New York equity-market open.

London Close
Countdown to the London session close.

These events appear in a dedicated Next Events section and automatically roll forward to the next trading day.

When an event enters the configurable Event Soon Threshold, Market Clock highlights the approaching event and changes its overall status to EVENT SOON.

DESIGNED FOR MULTI-TIMEFRAME TRADERS

Market Clock can complement many trading styles, but it was designed especially with multi-timeframe analysis in mind.

A trader might, for example, execute from a 5-minute chart while simultaneously monitoring the completion of the 1-hour and 4-hour candles. The lower timeframe provides execution detail while Market Clock keeps the larger timing structure visible.

This can be useful for:

[*]Candle-close confirmation
[*]Breakout and rejection setups
[*]Multi-timeframe confluence
[*]Session-open preparation
[*]Intraday and swing-trading workflows
[*]Traders waiting for higher-timeframe confirmation before execution
[*]

CUSTOMIZATION

The dashboard can be adapted to different workflows. Traders can independently control the chart-timeframe clock, two higher-timeframe clocks, progress meters, market-event countdowns, status display, dashboard position, text size, warning thresholds, and other display elements.

This allows Market Clock to function as either a compact candle timer or a more complete multi-timeframe timing dashboard.

DESIGN PHILOSOPHY

Price receives most of a trader's attention, but time is the other axis of every chart.

A candle's meaning develops not only from where price trades, but from how much time remains before that information becomes finalized.

Market Clock was built around that idea.

Instead of asking only:

“Where is price?”

Market Clock adds another question:

“Where are we in time?”

For traders who wait for closes, monitor several timeframes, or structure trades around major session transitions, that context can be just as valuable.

---

## Source Code

````pine
//@version=6
indicator(" Market Clock", overlay = true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UNIVERSAL UX PALETTE
// Matches CVD X-RAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BULL_COLOR    = #00c89b
BEAR_COLOR    = #f23645
NEUTRAL_COLOR = #636b79
CAUTION_COLOR = #ffbf00
HEADER_COLOR  = #38bdf8

PANEL_BG      = #131722
ROW_BG        = #1e222d
HEADER_BG     = #2a2e39
BORDER_COLOR  = color.new(#363a45, 50)
MUTED_TEXT    = #b2b5be

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string POS_TOP_LEFT      = "Top Left"
var string POS_TOP_CENTER    = "Top Center"
var string POS_TOP_RIGHT     = "Top Right"
var string POS_MIDDLE_LEFT   = "Middle Left"
var string POS_MIDDLE_CENTER = "Middle Center"
var string POS_MIDDLE_RIGHT  = "Middle Right"
var string POS_BOTTOM_LEFT   = "Bottom Left"
var string POS_BOTTOM_CENTER = "Bottom Center"
var string POS_BOTTOM_RIGHT  = "Bottom Right"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

posInput = input.string(
     POS_TOP_RIGHT,
     "Dashboard Position",
     options = [
         POS_TOP_LEFT,
         POS_TOP_CENTER,
         POS_TOP_RIGHT,
         POS_MIDDLE_LEFT,
         POS_MIDDLE_CENTER,
         POS_MIDDLE_RIGHT,
         POS_BOTTOM_LEFT,
         POS_BOTTOM_CENTER,
         POS_BOTTOM_RIGHT
     ],
     group = "Display"
)

showStatusInput       = input.bool(true, "Show Status", group = "Display")
showChartTFInput      = input.bool(true, "Show Chart Timeframe", group = "Display")
showTF1Input          = input.bool(true, "Show Higher Timeframe 1", group = "Display")
showTF2Input          = input.bool(true, "Show Higher Timeframe 2", group = "Display")
showProgressBarsInput = input.bool(true, "Show Progress Bars", group = "Display")
showNYOpenInput       = input.bool(true, "Show NY Cash Open", group = "Display")
showLondonCloseInput  = input.bool(true, "Show London Close", group = "Display")
showTimezoneInput     = input.bool(true, "Show Timezone Footer", group = "Display")

tf1Input = input.timeframe("60", "Higher Timeframe 1", group = "Timeframes")
tf2Input = input.timeframe("240", "Higher Timeframe 2", group = "Timeframes")

marketTimezoneInput = input.string(
     "America/New_York",
     "Market Event Timezone",
     group = "Market Events"
)

nyOpenHourInput = input.int(
     9,
     "NY Open Hour",
     minval = 0,
     maxval = 23,
     group = "Market Events"
)

nyOpenMinuteInput = input.int(
     30,
     "NY Open Minute",
     minval = 0,
     maxval = 59,
     group = "Market Events"
)

londonCloseHourInput = input.int(
     11,
     "London Close Hour",
     minval = 0,
     maxval = 23,
     group = "Market Events"
)

londonCloseMinuteInput = input.int(
     0,
     "London Close Minute",
     minval = 0,
     maxval = 59,
     group = "Market Events"
)

warningSecondsInput = input.int(
     10,
     "Closing Warning Threshold",
     minval = 1,
     maxval = 60,
     group = "Alerts"
)

eventSoonMinutesInput = input.int(
     15,
     "Event Soon Threshold",
     minval = 1,
     maxval = 120,
     group = "Alerts"
)

sizeInput = input.string(
     size.normal,
     "Text Size",
     options = [
         size.tiny,
         size.small,
         size.normal,
         size.large
     ],
     group = "Style"
)

progressSegmentsInput = input.int(
     12,
     "Progress Segments",
     minval = 8,
     maxval = 20,
     group = "Style"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

formatCountdown(int milliseconds) =>
    int ms = math.max(milliseconds, 0)

    int totalSeconds = int(math.floor(ms / 1000))
    int days         = int(math.floor(totalSeconds / 86400))
    int hours        = int(math.floor((totalSeconds % 86400) / 3600))
    int minutes      = int(math.floor((totalSeconds % 3600) / 60))
    int seconds      = totalSeconds % 60

    string result = ""

    if days > 0
        result := str.format(
             "{0}d {1,number,00}:{2,number,00}:{3,number,00}",
             days,
             hours,
             minutes,
             seconds
         )
    else if hours > 0
        result := str.format(
             "{0,number,00}:{1,number,00}:{2,number,00}",
             hours,
             minutes,
             seconds
         )
    else
        result := str.format(
             "{0}:{1,number,00}",
             minutes,
             seconds
         )

    result

tfLabel(string tf) =>
    int secondsTF = timeframe.in_seconds(tf)

    string result = tf

    if secondsTF < 60
        result := str.tostring(secondsTF) + "S"
    else if secondsTF < 3600
        result := str.tostring(int(secondsTF / 60)) + "M"
    else if secondsTF < 86400
        float hoursTF = secondsTF / 3600.0
        result := hoursTF == math.floor(hoursTF) ? str.tostring(int(hoursTF)) + "H" : str.tostring(hoursTF) + "H"
    else if secondsTF == 86400
        result := "1D"
    else if secondsTF < 604800
        result := str.tostring(int(secondsTF / 86400)) + "D"

    result

progressBar(float progress, int segments) =>
    float bounded = math.max(0.0, math.min(progress, 1.0))
    int filled = int(math.round(bounded * segments))
    int empty  = segments - filled

    string output = ""

    if filled > 0
        for i = 0 to filled - 1
            output += "━"

    if empty > 0
        for i = 0 to empty - 1
            output += "─"

    output

nextDailyEvent(
string timezone,
int eventHour,
int eventMinute
) =>
    int currentYear  = year(timenow, timezone)
    int currentMonth = month(timenow, timezone)
    int currentDay   = dayofmonth(timenow, timezone)

    int eventToday = timestamp(
         timezone,
         currentYear,
         currentMonth,
         currentDay,
         eventHour,
         eventMinute
     )

    int nextEvent = eventToday

    if timenow >= eventToday
        int tomorrowReference = timenow + 24 * 60 * 60 * 1000

        nextEvent := timestamp(
             timezone,
             year(tomorrowReference, timezone),
             month(tomorrowReference, timezone),
             dayofmonth(tomorrowReference, timezone),
             eventHour,
             eventMinute
         )

    nextEvent

nextWeekdayEvent(
string timezone,
int eventHour,
int eventMinute
) =>
    int candidate = nextDailyEvent(
         timezone,
         eventHour,
         eventMinute
     )

    int candidateDay = dayofweek(candidate, timezone)

    if candidateDay == dayofweek.saturday
        int mondayReference = candidate + 2 * 24 * 60 * 60 * 1000

        candidate := timestamp(
             timezone,
             year(mondayReference, timezone),
             month(mondayReference, timezone),
             dayofmonth(mondayReference, timezone),
             eventHour,
             eventMinute
         )

    else if candidateDay == dayofweek.sunday
        int mondayReference = candidate + 24 * 60 * 60 * 1000

        candidate := timestamp(
             timezone,
             year(mondayReference, timezone),
             month(mondayReference, timezone),
             dayofmonth(mondayReference, timezone),
             eventHour,
             eventMinute
         )

    candidate

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR TIMER ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

chartOpen  = time
chartClose = time_close

chartDuration = math.max(chartClose - chartOpen, 1)
chartElapsed  = math.max(timenow - chartOpen, 0)
chartTimeLeft = math.max(chartClose - timenow, 0)

chartProgress = math.min(chartElapsed / chartDuration, 1.0)

chartActive =
     timenow >= chartOpen and
     timenow < chartClose

chartWarning =
     chartActive and
     chartTimeLeft <= warningSecondsInput * 1000

tf1Open = request.security(
     syminfo.tickerid,
     tf1Input,
     time
)

tf1Close = request.security(
     syminfo.tickerid,
     tf1Input,
     time_close
)

tf1Duration = math.max(tf1Close - tf1Open, 1)
tf1Elapsed  = math.max(timenow - tf1Open, 0)
tf1TimeLeft = math.max(tf1Close - timenow, 0)

tf1Progress = math.min(tf1Elapsed / tf1Duration, 1.0)

tf1Active =
     timenow >= tf1Open and
     timenow < tf1Close

tf1Warning =
     tf1Active and
     tf1TimeLeft <= warningSecondsInput * 1000

tf2Open = request.security(
     syminfo.tickerid,
     tf2Input,
     time
)

tf2Close = request.security(
     syminfo.tickerid,
     tf2Input,
     time_close
)

tf2Duration = math.max(tf2Close - tf2Open, 1)
tf2Elapsed  = math.max(timenow - tf2Open, 0)
tf2TimeLeft = math.max(tf2Close - timenow, 0)

tf2Progress = math.min(tf2Elapsed / tf2Duration, 1.0)

tf2Active =
     timenow >= tf2Open and
     timenow < tf2Close

tf2Warning =
     tf2Active and
     tf2TimeLeft <= warningSecondsInput * 1000

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET EVENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nextNYOpen = nextWeekdayEvent(
     marketTimezoneInput,
     nyOpenHourInput,
     nyOpenMinuteInput
)

nextLondonClose = nextWeekdayEvent(
     marketTimezoneInput,
     londonCloseHourInput,
     londonCloseMinuteInput
)

nyOpenLeft = math.max(nextNYOpen - timenow, 0)
londonCloseLeft = math.max(nextLondonClose - timenow, 0)

eventSoonMs = eventSoonMinutesInput * 60 * 1000

nyOpenSoon = nyOpenLeft <= eventSoonMs
londonCloseSoon = londonCloseLeft <= eventSoonMs

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

anyClosing =
     (showChartTFInput and chartWarning) or
     (showTF1Input and tf1Warning) or
     (showTF2Input and tf2Warning)

anyEventSoon =
     (showNYOpenInput and nyOpenSoon) or
     (showLondonCloseInput and londonCloseSoon)

statusText =
     anyClosing ? "● CLOSING" :
     anyEventSoon ? "● EVENT SOON" :
     "● LIVE"

statusColor =
     anyClosing ? BEAR_COLOR :
     anyEventSoon ? CAUTION_COLOR :
     BULL_COLOR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tablePosition = switch posInput
    POS_TOP_LEFT      => position.top_left
    POS_TOP_CENTER    => position.top_center
    POS_TOP_RIGHT     => position.top_right
    POS_MIDDLE_LEFT   => position.middle_left
    POS_MIDDLE_CENTER => position.middle_center
    POS_MIDDLE_RIGHT  => position.middle_right
    POS_BOTTOM_LEFT   => position.bottom_left
    POS_BOTTOM_CENTER => position.bottom_center
    POS_BOTTOM_RIGHT  => position.bottom_right
    => position.top_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table clockPanel = table.new(
     position.top_right,
     2,
     13,
     border_width = 1,
     frame_color = BORDER_COLOR,
     border_color = BORDER_COLOR
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RENDER HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

renderSection(int row, string title) =>
    table.cell(
         clockPanel,
         0,
         row,
         "  " + title,
         text_color = MUTED_TEXT,
         bgcolor = HEADER_BG,
         text_size = size.tiny,
         text_halign = text.align_left
     )

    table.cell(
         clockPanel,
         1,
         row,
         "  ",
         bgcolor = HEADER_BG
     )

renderClockRow(
int row,
string label,
int timeLeft,
float progress,
bool active,
bool warning,
bool alternate,
bool highlight
) =>
    color bg = alternate ? ROW_BG : PANEL_BG

    color labelColor =
         highlight ? HEADER_COLOR : MUTED_TEXT

    color valueColor =
         not active ? NEUTRAL_COLOR :
         warning ? BEAR_COLOR :
         color.white

    color pctColor =
         not active ? NEUTRAL_COLOR :
         warning ? BEAR_COLOR :
         progress >= 0.90 ? CAUTION_COLOR :
         MUTED_TEXT

    string timerText =
         active ? formatCountdown(timeLeft) : "CLOSED"

    string pctText =
         active ? str.tostring(math.round(progress * 100.0), "#") + "%" : "—"

    table.cell(
         clockPanel,
         0,
         row,
         "  " + label + "  ",
         text_color = labelColor,
         bgcolor = bg,
         text_size = sizeInput,
         text_halign = text.align_left
     )

    table.cell(
         clockPanel,
         1,
         row,
         timerText + "     " + pctText + "  ",
         text_color = valueColor,
         bgcolor = bg,
         text_size = sizeInput,
         text_halign = text.align_right
     )

renderProgressRow(
int row,
float progress,
bool active,
bool warning,
bool alternate
) =>
    color bg = alternate ? ROW_BG : PANEL_BG

    color barColor =
         not active ? NEUTRAL_COLOR :
         warning ? BEAR_COLOR :
         progress >= 0.90 ? CAUTION_COLOR :
         HEADER_COLOR

    table.cell(
         clockPanel,
         0,
         row,
         "  ",
         bgcolor = bg
     )

    table.cell(
         clockPanel,
         1,
         row,
         active ? progressBar(progress, progressSegmentsInput) + "  " : "  ",
         text_color = barColor,
         bgcolor = bg,
         text_size = size.tiny,
         text_halign = text.align_right
     )

renderEventRow(
int row,
string eventName,
int timeLeft,
bool soon,
bool alternate
) =>
    color bg = alternate ? ROW_BG : PANEL_BG

    color timerColor =
         soon ? CAUTION_COLOR : BULL_COLOR

    table.cell(
         clockPanel,
         0,
         row,
         "  " + eventName + "  ",
         text_color = color.white,
         bgcolor = bg,
         text_size = sizeInput,
         text_halign = text.align_left
     )

    table.cell(
         clockPanel,
         1,
         row,
         formatCountdown(timeLeft) + "  ",
         text_color = timerColor,
         bgcolor = bg,
         text_size = sizeInput,
         text_halign = text.align_right
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RENDER DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast

    table.clear(
         clockPanel,
         0,
         0,
         1,
         12
     )

    table.set_position(
         clockPanel,
         tablePosition
     )

    int row = 0

    // Header
    table.cell(
         clockPanel,
         0,
         row,
         "  MARKET CLOCK  ",
         text_color = color.white,
         bgcolor = HEADER_BG,
         text_size = sizeInput,
         text_halign = text.align_left
     )

    table.cell(
         clockPanel,
         1,
         row,
         "  " + syminfo.ticker + "  ",
         text_color = HEADER_COLOR,
         bgcolor = HEADER_BG,
         text_size = sizeInput,
         text_halign = text.align_right
     )

    row += 1

    // Status
    if showStatusInput
        table.cell(
             clockPanel,
             0,
             row,
             "  " + statusText + "  ",
             text_color = statusColor,
             bgcolor = PANEL_BG,
             text_size = size.tiny,
             text_halign = text.align_left
         )

        table.cell(
             clockPanel,
             1,
             row,
             "  ",
             bgcolor = PANEL_BG
         )

        row += 1

    // Candle clocks
    renderSection(
         row,
         "CANDLE CLOCKS"
     )

    row += 1

    bool alternate = false

    if showChartTFInput
        renderClockRow(
             row,
             tfLabel(timeframe.period),
             chartTimeLeft,
             chartProgress,
             chartActive,
             chartWarning,
             alternate,
             true
         )

        row += 1

        if showProgressBarsInput
            renderProgressRow(
                 row,
                 chartProgress,
                 chartActive,
                 chartWarning,
                 alternate
             )
            row += 1

        alternate := not alternate

    if showTF1Input
        renderClockRow(
             row,
             tfLabel(tf1Input),
             tf1TimeLeft,
             tf1Progress,
             tf1Active,
             tf1Warning,
             alternate,
             false
         )

        row += 1

        if showProgressBarsInput
            renderProgressRow(
                 row,
                 tf1Progress,
                 tf1Active,
                 tf1Warning,
                 alternate
             )
            row += 1

        alternate := not alternate

    if showTF2Input
        renderClockRow(
             row,
             tfLabel(tf2Input),
             tf2TimeLeft,
             tf2Progress,
             tf2Active,
             tf2Warning,
             alternate,
             false
         )

        row += 1

        if showProgressBarsInput
            renderProgressRow(
                 row,
                 tf2Progress,
                 tf2Active,
                 tf2Warning,
                 alternate
             )
            row += 1

        alternate := not alternate

    // Events
    if showNYOpenInput or showLondonCloseInput
        renderSection(
             row,
             "NEXT EVENTS"
         )

        row += 1
        alternate := false

        if showNYOpenInput
            renderEventRow(
                 row,
                 "NY CASH OPEN",
                 nyOpenLeft,
                 nyOpenSoon,
                 alternate
             )

            row += 1
            alternate := not alternate

        if showLondonCloseInput
            renderEventRow(
                 row,
                 "LONDON CLOSE",
                 londonCloseLeft,
                 londonCloseSoon,
                 alternate
             )

            row += 1

    // Footer
    if showTimezoneInput
        table.cell(
             clockPanel,
             0,
             row,
             "",
             bgcolor = PANEL_BG
         )

        table.cell(
             clockPanel,
             1,
             row,
             "TIMEZONE: " + str.upper(marketTimezoneInput) + "  ",
             text_color = color.new(MUTED_TEXT, 35),
             bgcolor = PANEL_BG,
             text_size = size.tiny,
             text_halign = text.align_right
         )
````
