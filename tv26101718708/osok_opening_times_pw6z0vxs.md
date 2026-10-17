# OSOK Opening Times

- url: https://www.tradingview.com/script/pW6Z0vXS-OSOK-Opening-Times/
- type: indicator
- pine_id: PUB;64f463fb86df4b938dd27bc58eccb784
- version: 3.0

## Description

[b]OSOK Opening Times[/b] marks the opening times of active trading periods with vertical lines. It automatically adjusts the periods shown to match your chart timeframe, using solid lines for the larger period and dotted lines for the smaller active period.

Each boundary pair marks the [b]current period's opening and the next period's opening[/b]. This creates a clear time reference for the active day, week, month or quarter.

[b]Timeframe visibility[/b]

The breakdown below shows the default line styles when all visibility settings are enabled.

[list]
[*][b]Intraday below 1D, including 15m, 1H and 4H[/b]
Solid: current week opening to next week opening.
Dotted: active day opening to next day opening.
[*][b]Daily - 1D[/b]
Solid: current month opening to next month opening.
Dotted: active week opening to next week opening.
[*][b]Weekly - 1W[/b]
Solid: current quarter opening to next quarter opening.
Dotted: active month opening to next month opening.
[*][b]Monthly - 1M[/b]
Solid: none.
Dotted: current quarter opening to next quarter opening.
[*][b]Other intervals above 1D, such as 2D, 2W and 3M[/b]
No lines are displayed.
[/list]

A quarter is a three-month period. Quarterly boundaries appear on the 1W and 1M charts; the 3M chart itself displays no lines.

[b]Active periods and shared boundaries[/b]

Only the active periods are displayed. As new periods begin, their boundaries replace the previous markers. On intraday charts, daily dotted lines bracket only the active daily candle.

When two displayed boundaries coincide, the larger period's line takes precedence. The first daily candle of the week uses the weekly opening line as its starting boundary, avoiding a duplicate daily line.

[b]Appearance and customization[/b]

[list]
[*][b]Solid lines:[/b] black at 30% opacity by default.
[*][b]Dotted lines:[/b] black at 100% opacity by default.
[*][b]Line width:[/b] 1 by default.
[*]Visibility, color, opacity, style and width can be adjusted in the indicator's settings. Separate style settings are available for the different chart contexts.
[/list]

[b]Opening times and chart support[/b]

The indicator follows the symbol's TradingView candle sessions. Changing the chart's display timezone does not redefine those openings.

Upcoming boundaries use projected opening times. The active periods are determined by the latest chart bar, including when using Bar Replay.

The indicator supports standard time-based charts and Heikin Ashi. Tick, Renko, Range, Kagi, Line Break and Point & Figure charts are excluded.

## Source Code

````pine
//@version=6
indicator("OSOK Opening Times", overlay = true, max_lines_count = 20, max_labels_count = 20)

// OSOK v2 - complete source. The final line is "// END OF OSOK SCRIPT".
// Only the main and detail candles containing the latest chart bar are drawn.
// Bar Replay follows its latest bar. Period boundaries follow the symbol session.

const string GENERAL = "General"
const string STYLING = "Line Styling"
const string LABELS = "Labels"
const string P1 = "Profile 1 - default: 1D / quarter + month"
const string P2 = "Profile 2 - default: 4H / month + week"
const string P3 = "Profile 3 - default: 1H / week + day"
const string P4 = "Profile 4 - default: 30m and below / day + 4H"

enabled = input.bool(true, "Show opening times", group = GENERAL)
profileMode = input.string("Automatic", "Profile", options = ["Automatic", "Profile 1", "Profile 2", "Profile 3", "Profile 4"], group = GENERAL, tooltip = "Automatic selects the first enabled matching profile, from 1 to 4. A manual selection bypasses chart matching; the candle timeframes must still be higher than the chart.")
endMode = input.string("Next candle open", "End boundary", options = ["Next candle open", "Candle close"], group = GENERAL, tooltip = "Next candle open preserves the original opening-time brackets. Candle close ends at the current candle's closing timestamp. These may differ across overnight, weekend, and session gaps.")
overlapMode = input.string("Main wins", "Coincident boundaries", options = ["Main wins", "Detail wins", "Show both"], group = GENERAL, tooltip = "Applies only when visible main and detail lines have exactly the same timestamp.")
statusFontSize = input.string("Small", "Summary font size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GENERAL, tooltip = "Controls the font size of the OSOK Openings summary and configuration messages.")
showStatus = input.bool(false, "Show active profile summary", group = GENERAL, tooltip = "Shows the main and detail timeframes at the selected summary position. Configuration errors appear there even when this is off.")

colorMode = input.string("Custom colors", "Colors", options = ["Custom colors", "Match chart theme"], group = STYLING, tooltip = "Custom colors use the HTF and LTF color pickers, including opacity. Match chart theme uses the chart foreground color and the transparency controls below.")
autoMainTransparency = input.int(20, "Theme HTF transparency", minval = 0, maxval = 100, group = STYLING, active = colorMode == "Match chart theme", tooltip = "0 = opaque. 100 = invisible.")
autoDetailTransparency = input.int(75, "Theme LTF transparency", minval = 0, maxval = 100, group = STYLING, active = colorMode == "Match chart theme", tooltip = "Higher transparency makes the LTF candle's lines fainter.")
htfColor = input.color(color.new(#808080, 0), "HTF color / opacity", inline = "htf_style", group = STYLING, active = colorMode == "Custom colors")
htfStyle = input.string("Solid", "HTF style", options = ["Solid", "Dashed", "Dotted"], inline = "htf_style", group = STYLING)
ltfColor = input.color(color.new(#808080, 65), "LTF color / opacity", inline = "ltf_style", group = STYLING, active = colorMode == "Custom colors")
ltfStyle = input.string("Dotted", "LTF style", options = ["Solid", "Dashed", "Dotted"], inline = "ltf_style", group = STYLING)

showLabels = input.bool(false, "Show boundary labels", group = LABELS)
labelContent = input.string("Timeframe", "Text", options = ["Timeframe", "Timeframe + date/time"], group = LABELS, active = showLabels)
labelPlacement = input.string("Above price", "Position", options = ["Above price", "Below price"], group = LABELS, active = showLabels)
labelSizeInput = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = LABELS, active = showLabels)
labelPadding = input.float(1.0, "Distance from price (ATR)", minval = 0.0, maxval = 10.0, step = 0.25, group = LABELS, active = showLabels)
labelTimezone = input.string("Exchange", "Date/time zone", options = ["Exchange", "UTC", "America/New_York", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney"], group = LABELS, active = showLabels and labelContent == "Timeframe + date/time", tooltip = "Changes label text only. Candle boundaries always follow the symbol's session.")

// Profiles control timeframes, visibility, widths, and boundaries.
// HTF/LTF colors and line styles are shared in the Line Styling section.

p1Enabled = input.bool(true, "Enable profile 1", group = P1)
p1Chart = input.timeframe("1D", "Chart timeframe", inline = "p1_chart", group = P1, active = p1Enabled)
p1Match = input.string("Exact", "Match", options = ["Exact", "At or below"], inline = "p1_chart", group = P1, active = p1Enabled, tooltip = "Exact matches the selected chart interval. At or below includes time-based charts up to that interval. Earlier enabled profiles take priority if ranges overlap.")
p1Main = input.bool(true, "Main candle", inline = "p1_main", group = P1, active = p1Enabled)
p1MainTF = input.timeframe("3M", "", inline = "p1_main", group = P1, active = p1Enabled, tooltip = "Defines the main candle and the upper limit for the smaller candle. Must be higher than the chart timeframe. Only the current candle is marked.")
p1MainWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p1_ms", group = P1, active = p1Enabled and p1Main)
p1MainEdges = input.string("Both", "Main boundaries", options = ["Both", "Opening only", "Ending only"], group = P1, active = p1Enabled and p1Main)
p1Detail = input.bool(true, "Smaller candle", inline = "p1_detail", group = P1, active = p1Enabled)
p1DetailTF = input.timeframe("1M", "", inline = "p1_detail", group = P1, active = p1Enabled and p1Detail, tooltip = "Must be above the chart timeframe and below the main candle timeframe. Only the smaller candle containing the latest chart bar is marked.")
p1DetailWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p1_ds", group = P1, active = p1Enabled and p1Detail)
p1DetailEdges = input.string("Both", "Detail boundaries", options = ["Both", "Opening only", "Ending only"], group = P1, active = p1Enabled and p1Detail)

p2Enabled = input.bool(true, "Enable profile 2", group = P2)
p2Chart = input.timeframe("240", "Chart timeframe", inline = "p2_chart", group = P2, active = p2Enabled)
p2Match = input.string("Exact", "Match", options = ["Exact", "At or below"], inline = "p2_chart", group = P2, active = p2Enabled, tooltip = "Exact matches the selected chart interval. At or below includes time-based charts up to that interval. Earlier enabled profiles take priority if ranges overlap.")
p2Main = input.bool(true, "Main candle", inline = "p2_main", group = P2, active = p2Enabled)
p2MainTF = input.timeframe("1M", "", inline = "p2_main", group = P2, active = p2Enabled, tooltip = "Defines the main candle and the upper limit for the smaller candle. Must be higher than the chart timeframe. Only the current candle is marked.")
p2MainWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p2_ms", group = P2, active = p2Enabled and p2Main)
p2MainEdges = input.string("Both", "Main boundaries", options = ["Both", "Opening only", "Ending only"], group = P2, active = p2Enabled and p2Main)
p2Detail = input.bool(true, "Smaller candle", inline = "p2_detail", group = P2, active = p2Enabled)
p2DetailTF = input.timeframe("1W", "", inline = "p2_detail", group = P2, active = p2Enabled and p2Detail, tooltip = "Must be above the chart timeframe and below the main candle timeframe. Only the smaller candle containing the latest chart bar is marked.")
p2DetailWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p2_ds", group = P2, active = p2Enabled and p2Detail)
p2DetailEdges = input.string("Both", "Detail boundaries", options = ["Both", "Opening only", "Ending only"], group = P2, active = p2Enabled and p2Detail)

p3Enabled = input.bool(true, "Enable profile 3", group = P3)
p3Chart = input.timeframe("60", "Chart timeframe", inline = "p3_chart", group = P3, active = p3Enabled)
p3Match = input.string("Exact", "Match", options = ["Exact", "At or below"], inline = "p3_chart", group = P3, active = p3Enabled, tooltip = "Exact matches the selected chart interval. At or below includes time-based charts up to that interval. Earlier enabled profiles take priority if ranges overlap.")
p3Main = input.bool(true, "Main candle", inline = "p3_main", group = P3, active = p3Enabled)
p3MainTF = input.timeframe("1W", "", inline = "p3_main", group = P3, active = p3Enabled, tooltip = "Defines the main candle and the upper limit for the smaller candle. Must be higher than the chart timeframe. Only the current candle is marked.")
p3MainWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p3_ms", group = P3, active = p3Enabled and p3Main)
p3MainEdges = input.string("Both", "Main boundaries", options = ["Both", "Opening only", "Ending only"], group = P3, active = p3Enabled and p3Main)
p3Detail = input.bool(true, "Smaller candle", inline = "p3_detail", group = P3, active = p3Enabled)
p3DetailTF = input.timeframe("1D", "", inline = "p3_detail", group = P3, active = p3Enabled and p3Detail, tooltip = "Must be above the chart timeframe and below the main candle timeframe. Only the smaller candle containing the latest chart bar is marked.")
p3DetailWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p3_ds", group = P3, active = p3Enabled and p3Detail)
p3DetailEdges = input.string("Both", "Detail boundaries", options = ["Both", "Opening only", "Ending only"], group = P3, active = p3Enabled and p3Detail)

p4Enabled = input.bool(true, "Enable profile 4", group = P4)
p4Chart = input.timeframe("30", "Chart timeframe", inline = "p4_chart", group = P4, active = p4Enabled)
p4Match = input.string("At or below", "Match", options = ["Exact", "At or below"], inline = "p4_chart", group = P4, active = p4Enabled, tooltip = "Exact matches the selected chart interval. At or below includes time-based charts up to that interval. Earlier enabled profiles take priority if ranges overlap.")
p4Main = input.bool(true, "Main candle", inline = "p4_main", group = P4, active = p4Enabled)
p4MainTF = input.timeframe("1D", "", inline = "p4_main", group = P4, active = p4Enabled, tooltip = "Defines the main candle and the upper limit for the smaller candle. Must be higher than the chart timeframe. Only the current candle is marked.")
p4MainWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p4_ms", group = P4, active = p4Enabled and p4Main)
p4MainEdges = input.string("Both", "Main boundaries", options = ["Both", "Opening only", "Ending only"], group = P4, active = p4Enabled and p4Main)
p4Detail = input.bool(true, "Smaller candle", inline = "p4_detail", group = P4, active = p4Enabled)
p4DetailTF = input.timeframe("240", "", inline = "p4_detail", group = P4, active = p4Enabled and p4Detail, tooltip = "Must be above the chart timeframe and below the main candle timeframe. Only the smaller candle containing the latest chart bar is marked.")
p4DetailWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "p4_ds", group = P4, active = p4Enabled and p4Detail)
p4DetailEdges = input.string("Both", "Detail boundaries", options = ["Both", "Opening only", "Ending only"], group = P4, active = p4Enabled and p4Detail)

getStyle(string choice) =>
    switch choice
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

getLabelSize(string choice) =>
    switch choice
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

tfTitle(string tf) =>
    float minutes = str.tonumber(tf)
    na(minutes) ? tf : minutes >= 60 and minutes % 60 == 0 ? str.tostring(minutes / 60, "#") + "H" : tf + "m"

// Preserve the distinction between daily, weekly, monthly and minute charts.
matchesChart(bool profileEnabled, string target, string matchRule, float chartSeconds) =>
    bool sameFamily = timeframe.isdaily == str.endswith(target, "D") and timeframe.isweekly == str.endswith(target, "W") and timeframe.ismonthly == str.endswith(target, "M")
    float targetSeconds = timeframe.in_seconds(target)
    profileEnabled and not na(chartSeconds) and (matchRule == "Exact" ? sameFamily and chartSeconds == targetSeconds : chartSeconds <= targetSeconds)

addBoundary(array<line> lines, array<label> labels, bool visible, int stamp, color ink, string style, int width, string caption, float labelY) =>
    if visible and not na(stamp)
        array.push(lines, line.new(stamp, low, stamp, math.max(high, low + syminfo.mintick), xloc = xloc.bar_time, extend = extend.both, color = ink, style = getStyle(style), width = width))
        if showLabels
            string zone = labelTimezone == "Exchange" ? syminfo.timezone : labelTimezone
            string labelText = caption
            if labelContent == "Timeframe + date/time"
                labelText += "\n" + str.format_time(stamp, "MMM d, HH:mm", zone)
            string labelStyle = labelPlacement == "Above price" ? label.style_label_down : label.style_label_up
            array.push(labels, label.new(stamp, labelY, labelText, xloc = xloc.bar_time, yloc = yloc.price, color = color.new(chart.bg_color, 10), style = labelStyle, textcolor = color.new(ink, 0), size = getLabelSize(labelSizeInput)))
    0

bool timeBased = timeframe.isseconds or timeframe.isminutes or timeframe.isdwm
bool supportedChart = timeBased and chart.is_standard
float chartSeconds = timeBased ? timeframe.in_seconds() : na

bool match1 = matchesChart(p1Enabled, p1Chart, p1Match, chartSeconds)
bool match2 = matchesChart(p2Enabled, p2Chart, p2Match, chartSeconds)
bool match3 = matchesChart(p3Enabled, p3Chart, p3Match, chartSeconds)
bool match4 = matchesChart(p4Enabled, p4Chart, p4Match, chartSeconds)
int automaticProfile = match1 ? 1 : match2 ? 2 : match3 ? 3 : match4 ? 4 : 0
int profile = switch profileMode
    "Profile 1" => 1
    "Profile 2" => 2
    "Profile 3" => 3
    "Profile 4" => 4
    => automaticProfile
bool profileEnabled = profile == 1 ? p1Enabled : profile == 2 ? p2Enabled : profile == 3 ? p3Enabled : p4Enabled
string mainTF = profile == 1 ? p1MainTF : profile == 2 ? p2MainTF : profile == 3 ? p3MainTF : p4MainTF
string detailTF = profile == 1 ? p1DetailTF : profile == 2 ? p2DetailTF : profile == 3 ? p3DetailTF : p4DetailTF
bool showMain = profile == 1 ? p1Main : profile == 2 ? p2Main : profile == 3 ? p3Main : p4Main
bool showDetail = profile == 1 ? p1Detail : profile == 2 ? p2Detail : profile == 3 ? p3Detail : p4Detail
int mainWidth = profile == 1 ? p1MainWidth : profile == 2 ? p2MainWidth : profile == 3 ? p3MainWidth : p4MainWidth
int detailWidth = profile == 1 ? p1DetailWidth : profile == 2 ? p2DetailWidth : profile == 3 ? p3DetailWidth : p4DetailWidth
string mainEdges = profile == 1 ? p1MainEdges : profile == 2 ? p2MainEdges : profile == 3 ? p3MainEdges : p4MainEdges
string detailEdges = profile == 1 ? p1DetailEdges : profile == 2 ? p2DetailEdges : profile == 3 ? p3DetailEdges : p4DetailEdges

color mainColor = colorMode == "Match chart theme" ? color.new(chart.fg_color, autoMainTransparency) : htfColor
color detailColor = colorMode == "Match chart theme" ? color.new(chart.fg_color, autoDetailTransparency) : ltfColor

float mainSeconds = timeframe.in_seconds(mainTF)
float detailSeconds = timeframe.in_seconds(detailTF)
bool invalidMain = showMain and mainSeconds <= chartSeconds
bool invalidDetail = showDetail and (detailSeconds <= chartSeconds or detailSeconds >= mainSeconds)
bool invalidProfile = profile > 0 and profileEnabled and (invalidMain or invalidDetail)
bool canDraw = enabled and supportedChart and profile > 0 and profileEnabled and not invalidProfile

// Evaluate timestamps on every bar; render only the latest candle brackets.
int mainOpen = time(mainTF)
int mainNextOpen = time(mainTF, timeframe_bars_back = -1)
int mainClose = time_close(mainTF)
int detailOpen = time(detailTF)
int detailNextOpen = time(detailTF, timeframe_bars_back = -1)
int detailClose = time_close(detailTF)
int mainEnd = endMode == "Candle close" ? mainClose : mainNextOpen
int detailEnd = endMode == "Candle close" ? detailClose : detailNextOpen
string endCaption = endMode == "Candle close" ? " close" : " next open"

float atr = ta.atr(14)
float spacing = math.max(nz(atr, high - low), syminfo.mintick)
float direction = labelPlacement == "Above price" ? 1.0 : -1.0
float mainLabelY = (labelPlacement == "Above price" ? high : low) + direction * spacing * labelPadding
float detailLabelY = mainLabelY + direction * spacing * 0.75

var array<line> markers = array.new<line>()
var array<label> captions = array.new<label>()
// Appended after existing inputs to preserve their saved order.
statusVertical = input.string("top", "Summary position", options = ["top", "middle", "bottom"], inline = "status_position", group = GENERAL)
statusHorizontal = input.string("right", "", options = ["left", "center", "right"], inline = "status_position", group = GENERAL, tooltip = "Anchors the OSOK Openings summary and configuration messages to one of nine chart positions.")
statusThemeText = input.bool(true, "Match chart text color", inline = "status_color", group = GENERAL)
statusTextColor = input.color(color.black, "Text color", inline = "status_color", group = GENERAL, active = not statusThemeText, tooltip = "Turn off Match chart text color to use this color and opacity for the summary and configuration messages.")
string statusPosition = switch statusVertical
    "top" => statusHorizontal == "left" ? position.top_left : statusHorizontal == "center" ? position.top_center : position.top_right
    "middle" => statusHorizontal == "left" ? position.middle_left : statusHorizontal == "center" ? position.middle_center : position.middle_right
    => statusHorizontal == "left" ? position.bottom_left : statusHorizontal == "center" ? position.bottom_center : position.bottom_right
var table status = table.new(statusPosition, 1, 1)

if barstate.islast
    while array.size(markers) > 0
        line.delete(array.pop(markers))
    while array.size(captions) > 0
        label.delete(array.pop(captions))

    if canDraw
        bool mainStartShown = showMain and mainEdges != "Ending only" and not na(mainOpen)
        bool mainEndShown = showMain and mainEdges != "Opening only" and not na(mainEnd)
        bool detailStartShown = showDetail and detailEdges != "Ending only" and not na(detailOpen)
        bool detailEndShown = showDetail and detailEdges != "Opening only" and not na(detailEnd)

        // Suppress a duplicate only if the winning boundary is actually visible.
        if overlapMode == "Main wins"
            detailStartShown := detailStartShown and not ((mainStartShown and detailOpen == mainOpen) or (mainEndShown and detailOpen == mainEnd))
            detailEndShown := detailEndShown and not ((mainStartShown and detailEnd == mainOpen) or (mainEndShown and detailEnd == mainEnd))
        else if overlapMode == "Detail wins"
            mainStartShown := mainStartShown and not ((detailStartShown and mainOpen == detailOpen) or (detailEndShown and mainOpen == detailEnd))
            mainEndShown := mainEndShown and not ((detailStartShown and mainEnd == detailOpen) or (detailEndShown and mainEnd == detailEnd))

        addBoundary(markers, captions, detailStartShown, detailOpen, detailColor, ltfStyle, detailWidth, tfTitle(detailTF) + " open", detailLabelY)
        addBoundary(markers, captions, detailEndShown, detailEnd, detailColor, ltfStyle, detailWidth, tfTitle(detailTF) + endCaption, detailLabelY)
        addBoundary(markers, captions, mainStartShown, mainOpen, mainColor, htfStyle, mainWidth, tfTitle(mainTF) + " open", mainLabelY)
        addBoundary(markers, captions, mainEndShown, mainEnd, mainColor, htfStyle, mainWidth, tfTitle(mainTF) + endCaption, mainLabelY)

    string summary = "OSOK Openings\nMain: " + tfTitle(mainTF) + (showMain ? "" : " (hidden)") + " | Detail: " + tfTitle(detailTF) + (showDetail ? "" : " (hidden)")
    if not enabled
        summary := "OSOK | Hidden"
    else if not supportedChart
        summary := "OSOK | Use a supported time-based chart."
    else if profile == 0
        summary := "OSOK | No matching profile."
    else if not profileEnabled
        summary := "OSOK | Selected profile is disabled."
    else if invalidMain
        summary := "OSOK | Main candle must be higher than the chart.\nCheck Profile " + str.tostring(profile) + "."
    else if invalidDetail
        summary := "OSOK | Smaller candle must be above the chart\nand below the main candle. Check Profile " + str.tostring(profile) + "."
    else if not showMain and not showDetail
        summary := "OSOK | Both layers are hidden."

    table.clear(status, 0, 0)
    if showStatus or (enabled and supportedChart and invalidProfile)
        table.cell(status, 0, 0, summary, text_color = statusThemeText ? chart.fg_color : statusTextColor, bgcolor = color.new(chart.bg_color, 10), text_size = getLabelSize(statusFontSize))

// END OF OSOK SCRIPT
````
