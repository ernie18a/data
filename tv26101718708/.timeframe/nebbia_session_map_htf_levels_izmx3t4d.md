# Nebbia Session Map & HTF Levels 

- url: https://www.tradingview.com/script/izmx3t4d/
- type: indicator
- pine_id: PUB;a761100087f04f1b88f9d50880aa48bc
- version: 3.0

## Description

Nebbia Market Sessions & Liquidity Levels is an open-source intraday market-mapping indicator designed to combine session structure, liquidity references, higher-timeframe levels and the US Initial Balance in a single charting tool.

The script is intended primarily for traders who work on lower intraday timeframes and want a clear view of where price is trading relative to important session ranges, historical highs and lows, confirmed swing levels, opening prices and Initial Balance projections.

Market Sessions
The indicator can display the main intraday trading sessions:

Asia

London

New York AM

New York Lunch

New York PM

Each session can be enabled or disabled independently and has customizable hours, colors and transparency.

The first hour of the Asia and London sessions can also be highlighted separately, making it easier to identify their initial range and early-session price development.

Session times use timezone-aware calculations, allowing daylight-saving changes to be handled correctly when IANA timezones such as America/New_York, America/Chicago, Europe/London, Europe/Rome and Asia/Tokyo are selected.

Killzone Pivots
For every enabled killzone, the script can track the session high and low and extend them forward as potential liquidity levels.

These pivots can remain active according to three different expiration rules:

until the end of the trading day;

until the next occurrence of the same session;

until the level is mitigated.

A pivot stops extending once price trades through it.

Alerts can also be enabled for killzone pivot breaks.

Higher-Timeframe Liquidity Levels
Nebbia can display historical liquidity references from several timeframes:

past daily highs and lows;

past weekly highs and lows;

past monthly highs and lows;

two optional confirmed swing-timeframe slots.

The two swing slots are fully configurable. They may be used, for example, for:

4-hour swings;

1-hour swings;

30-minute swings;

or any other supported timeframe.

Swing highs and lows are confirmed only after the selected number of right-side bars has closed, preventing an unconfirmed pivot from being displayed prematurely.

The timeframe name is generated automatically in the label, producing references such as:

4H H

4H L

1H H

30M L

When two swing levels occur at the same price, the higher timeframe takes priority.

Level Confluence
When multiple liquidity references share the same price, Nebbia merges them instead of drawing several overlapping lines.

The hierarchy is:

Monthly → Weekly → Daily → higher swing timeframe → lower swing timeframe

The highest-priority line remains visible, while the label can report the relevant confluence.

Examples:

W LOW 09.06 / 4H L

D HIGH 16.07 / 1H H

M LOW 01.07 / W LOW 07.07

This keeps the chart readable while preserving the information contained in lower-timeframe confirmations.

Active and Mitigated Levels
Active liquidity levels are displayed using the selected active line style.

Once price trades through a level, it can be converted into a mitigated level using a separate broken-line style and transparency.

A dedicated setting allows mitigated levels to be shown or hidden completely.

This means the chart can be configured either to retain historical interaction points or to display only liquidity levels that remain untouched.

Level labels can also be enabled or disabled independently.

High labels are positioned above their level, while low labels are positioned below it.

Current Trading-Day High and Low
An optional developing mode can display the high and low of the current Chicago trading day.

These levels update throughout the session and are treated as provisional rather than as already-confirmed historical levels.

At the beginning of the next trading day, the completed daily range is transferred into the normal historical daily-level logic.

ADR5 Distance Filter
Nebbia includes an optional ADR5 filter, based on the average daily range of the five most recently completed trading days.

The ADR5 value is calculated and frozen at the beginning of each new trading day.

Only levels located within the selected ADR5 distance multiplier are displayed.

This can reduce chart clutter by hiding historical liquidity references that are too far away from current price.

For example:

1.0 displays levels within one ADR5;

1.5 displays levels within one and a half ADR5;

2.0 displays levels within two ADR5.

Opening Prices
The indicator can display the latest opening price for:

Daily Open — 00:00 Rome

Tokyo Open — 09:00 Tokyo

London Open — 08:00 London

US Cash Open — 08:30 Chicago

Each opening price has an independent visibility option, color and editable label text.

Only the latest relevant opening line is retained, preventing older opening levels from unnecessarily accumulating on the chart.

Time Markers and Separators
Optional vertical timestamps can identify:

00:00 Rome;

08:30 Chicago.

Daily, weekly and monthly separators can also be displayed independently.

Optional day-of-week labels may be placed at the top or bottom of the chart, with the possibility of hiding weekend labels.

US Initial Balance
Nebbia includes a dedicated US Initial Balance module based on the first hour of the US cash session:

08:30–09:30 America/Chicago

The Initial Balance can display:

IB High;

IB Low;

50% midpoint;

optional ×2 and ×3 extensions;

optional 50% levels between the main extensions;

a highlighted IB time window;

a tinted area between IB High and IB Low;

optional price labels;

configurable extension direction and line styles.

When lines are extended to the right, they remain active until the beginning of the next trading day’s Initial Balance rather than extending indefinitely.

The script can also calculate statistics from the previous 20 completed Initial Balance sessions.

Customization
Most visual components can be configured independently, including:

session colors and transparency;

swing timeframes and pivot sensitivity;

level colors and widths;

active and mitigated line styles;

label visibility and distance;

opening-price labels;

timestamp styles;

Initial Balance colors, widths and extensions;

timeframe visibility limits;

session-history drawing limits.

Credits
This open-source project was inspired in part by:

ICT Killzones + Pivots [TFO]
by tradeforopp

Full recognition is given to the original author for the concepts and foundation that helped inspire the session and pivot components of this project.

Nebbia Market Sessions & Liquidity Levels is an independent expansion and redesign that adds higher-timeframe liquidity mapping, swing-timeframe slots, confluence management, ADR5 filtering, opening prices, timestamps and a complete US Initial Balance module.

Disclaimer
This indicator is provided for educational and analytical purposes only.

It does not constitute financial advice, investment advice or a recommendation to enter or exit any trade. Historical levels, session ranges, pivots and Initial Balance projections do not guarantee future market behavior.

## Source Code

````pine
//@version=6
// +=============================================================================+
// | SCRIPT: Nebbia Session Map & HTF Levels                |
// | AUTHOR: Stefano Masiero for Alpha4All Italia                                |
// |                                                                             |
// | DEDICATION: Dedicated to my best friend, Nebbia.                            |
// |             Even from up there, you are a source of inspiration and grit!   |
// +=============================================================================+
// Revision: 2.10.15 — Current Day labels dominate calendar levels and combine with confluent Swing names.
indicator("Nebbia Session Map & HTF Levels ", "Nebbia Sessions", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// =================================================================================================
// CONSTANTS & HELPERS
// =================================================================================================
string TZ_CHICAGO = "America/Chicago"
string TZ_ROME    = "Europe/Rome"
string TZ_TOKYO   = "Asia/Tokyo"
string TZ_LONDON  = "Europe/London"
color TRANSPARENT = #FFFFFF00

get_line_type(string styleName) =>
    switch styleName
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

get_size(string sizeName) =>
    switch sizeName
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

session_active(string sessionName, string timezoneName) =>
    not na(time(timeframe.period, sessionName, timezoneName))

session_start(bool active) =>
    active and not active[1]

// True on the first chart bar whose opening time reaches the requested local clock time.
// This avoids the alignment ambiguities that short one-minute session strings can create
// on 15- and 30-minute charts.
crosses_local_time(int localHour, int localMinute, string timezoneName) =>
    int localTarget = timestamp(timezoneName, year(time, timezoneName), month(time, timezoneName), dayofmonth(time, timezoneName), localHour, localMinute)
    time >= localTarget and (na(time[1]) or time[1] < localTarget)

first_hour_of_session(string sessionName) =>
    int startValue = int(str.tonumber(str.substring(sessionName, 0, 4)))
    int startHour = int(math.floor(startValue / 100))
    int startMinute = startValue - startHour * 100
    int endHour = (startHour + 1) % 24
    str.tostring(startHour * 100 + startMinute, "0000") + "-" + str.tostring(endHour * 100 + startMinute, "0000")

calendar_day_key(int barTime, string timezoneName) =>
    timestamp(timezoneName, year(barTime, timezoneName), month(barTime, timezoneName), dayofmonth(barTime, timezoneName), 0, 0)

// The Nasdaq futures trading day starts at 17:00 Chicago and is named for
// the calendar day on which that trading session ends. Example: the session
// beginning Sunday at 17:00 is Monday's trading day.
trading_day_key(int barTime) =>
    int y = year(barTime, TZ_CHICAGO)
    int m = month(barTime, TZ_CHICAGO)
    int d = dayofmonth(barTime, TZ_CHICAGO)
    int dayAdjustment = hour(barTime, TZ_CHICAGO) >= 17 ? 1 : 0
    timestamp(TZ_CHICAGO, y, m, d + dayAdjustment, 0, 0)

week_start_key(int dayKey) =>
    int localDow = dayofweek(dayKey, TZ_CHICAGO)
    int daysFromMonday = localDow == dayofweek.sunday ? 6 : localDow - dayofweek.monday
    timestamp(TZ_CHICAGO, year(dayKey, TZ_CHICAGO), month(dayKey, TZ_CHICAGO), dayofmonth(dayKey, TZ_CHICAGO) - daysFromMonday, 0, 0)

week_key(int dayKey) =>
    year(dayKey, TZ_CHICAGO) * 100 + weekofyear(dayKey, TZ_CHICAGO)

month_key(int dayKey) =>
    year(dayKey, TZ_CHICAGO) * 100 + month(dayKey, TZ_CHICAGO)

format_day_month(int dateTime, string timezoneName) =>
    string dayText = str.tostring(dayofmonth(dateTime, timezoneName), "00")
    string monthText = str.tostring(month(dateTime, timezoneName), "00")
    dayText + "." + monthText

level_text_with_date(string baseText, int dateTime) =>
    baseText + " " + format_day_month(dateTime, TZ_CHICAGO)

mid_time(int x1, int x2) =>
    int(math.round((x1 + x2) / 2.0))

// Opening-price labels remain near the right side, as in revision 2.2.1.
right_label_time(int x1, int x2) =>
    int span = math.max(x2 - x1, 0)
    int percentageTarget = x1 + int(span * 0.78)
    int oneDayBackTarget = x2 - 24 * 60 * 60 * 1000
    float localTfSeconds = timeframe.in_seconds()
    int barMilliseconds = int(math.max(nz(localTfSeconds, 60.0), 60.0) * 1000.0)
    int latestTarget = x2 - barMilliseconds * 2
    int rawTarget = math.max(percentageTarget, oneDayBackTarget)
    math.max(x1, math.min(rawTarget, latestTarget))

chart_bar_milliseconds() =>
    float localTfSeconds = timeframe.in_seconds()
    int(math.max(nz(localTfSeconds, 60.0), 60.0) * 1000.0)

label_gap_half_width(string textValue, int minimumBars) =>
    // Pine cannot measure text in screen pixels. This estimate is tuned for
    // compact labels on a 15-minute chart and remains adjustable from Inputs.
    int estimatedFromText = int(math.ceil(str.length(textValue) * 0.32)) + 1
    int barsForGap = math.max(minimumBars, estimatedFromText)
    chart_bar_milliseconds() * barsForGap

level_label_right_time(int lineEnd) =>
    // The label anchor sits one chart bar after the visible line end.
    lineEnd + chart_bar_milliseconds()

level_label_price(float price, bool isHighLevel, int offsetTicks) =>
    // The label remains on the exact same price level as its line.
    price

level_label_style(bool isHighLevel) =>
    // label_left keeps the anchor on the left, so the text develops to the right.
    // With a transparent background, the text starts after the line endpoint.
    label.style_label_left

level_label_display_text(string rawText, bool isHighLevel) =>
    rawText

level_label_raw_text(string displayText) =>
    displayText

level_label_text_with_price(string baseText, float levelPrice, bool includePrice) =>
    includePrice and str.length(baseText) > 0 ? baseText + " | " + str.tostring(levelPrice, format.mintick) : baseText

timeframe_display_name(string tf) =>
    int seconds = int(timeframe.in_seconds(tf))
    string result = tf
    if seconds > 0
        if seconds % 604800 == 0
            result := str.tostring(int(seconds / 604800)) + "W"
        else if seconds % 86400 == 0
            result := str.tostring(int(seconds / 86400)) + "D"
        else if seconds % 3600 == 0
            result := str.tostring(int(seconds / 3600)) + "H"
        else if seconds % 60 == 0
            result := str.tostring(int(seconds / 60)) + "M"
    result

append_level_name(string baseText, string extraText) =>
    str.contains(baseText, extraText) ? baseText : baseText + " / " + extraText

set_split_line(line leftLine, line rightLine, int startTime, int endTime, int anchorTime, float price, int halfGapMs) =>
    int safeEnd = math.max(startTime, endTime)
    int safeAnchor = math.max(startTime, math.min(anchorTime, safeEnd))
    int leftEnd = math.max(startTime, math.min(safeAnchor - halfGapMs, safeEnd))
    int rightStart = math.max(startTime, math.min(safeAnchor + halfGapMs, safeEnd))
    line.set_xy1(leftLine, startTime, price)
    line.set_xy2(leftLine, leftEnd, price)
    line.set_xy1(rightLine, rightStart, price)
    line.set_xy2(rightLine, safeEnd, price)

// =================================================================================================
// INPUTS — GENERAL
// =================================================================================================
string G_SETTINGS = "Settings"
int max_days = input.int(20, "Session Drawing Limit", minval = 1, maxval = 30, tooltip = "Maximum history retained for session boxes, opening lines and separators.", group = G_SETTINGS)
string tf_limit = input.timeframe("30", "Timeframe Limit", tooltip = "Killzones, opening prices and timestamps are hidden above this chart timeframe. Higher-timeframe levels remain available.", group = G_SETTINGS)
string gmt_tz = input.string("America/New_York", "Killzone Timezone", options = ["America/New_York", "America/Chicago", "Europe/Rome", "Europe/London", "Asia/Tokyo", "GMT-12", "GMT-11", "GMT-10", "GMT-9", "GMT-8", "GMT-7", "GMT-6", "GMT-5", "GMT-4", "GMT-3", "GMT-2", "GMT-1", "GMT+0", "GMT+1", "GMT+2", "GMT+3", "GMT+4", "GMT+5", "GMT+6", "GMT+7", "GMT+8", "GMT+9", "GMT+10", "GMT+11", "GMT+12", "GMT+13", "GMT+14"], group = G_SETTINGS)
string labelSizeInput = input.string("Normal", "Label Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = G_SETTINGS)
color txt_color = input.color(#D5D9E2, "Text Color", tooltip = "Default text colour, chosen for dark charts.", group = G_SETTINGS)

label_size = get_size(labelSizeInput)
float chartTfSeconds = timeframe.in_seconds()
float limitTfSeconds = timeframe.in_seconds(tf_limit)
bool drawingTfOk = timeframe.isintraday and not na(chartTfSeconds) and not na(limitTfSeconds) and chartTfSeconds <= limitTfSeconds

// =================================================================================================
// INPUTS — KILLZONES
// =================================================================================================
string G_KZ = "Killzones"
bool show_kz = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = G_KZ)
bool show_kz_text = input.bool(true, "Display Text", inline = "KZ", group = G_KZ)

bool use_asia = input.bool(true, "", inline = "ASIA", group = G_KZ)
string as_txt = input.string("Asia", "", inline = "ASIA", group = G_KZ)
string asia = input.session("2000-0000", "", inline = "ASIA", group = G_KZ)
color as_color = input.color(#2962FF, "", inline = "ASIA", group = G_KZ)

bool use_london = input.bool(true, "", inline = "LONDON", group = G_KZ)
string lo_txt = input.string("London", "", inline = "LONDON", group = G_KZ)
string london = input.session("0200-0500", "", inline = "LONDON", group = G_KZ)
color lo_color = input.color(#FFEB3B, "", inline = "LONDON", group = G_KZ)

bool use_nyam = input.bool(true, "", inline = "NYAM", group = G_KZ)
string na_txt = input.string("NY AM", "", inline = "NYAM", group = G_KZ)
string nyam = input.session("0830-1100", "", inline = "NYAM", group = G_KZ)
color na_color = input.color(#00A884, "", inline = "NYAM", group = G_KZ)

bool use_nylu = input.bool(false, "", inline = "NYLU", group = G_KZ)
string nl_txt = input.string("NY Lunch", "", inline = "NYLU", group = G_KZ)
string nylu = input.session("1200-1300", "", inline = "NYLU", group = G_KZ)
color nl_color = input.color(#F57C00, "", inline = "NYLU", group = G_KZ)

bool use_nypm = input.bool(true, "", inline = "NYPM", group = G_KZ)
string np_txt = input.string("NY PM", "", inline = "NYPM", group = G_KZ)
string nypm = input.session("1330-1600", "", inline = "NYPM", group = G_KZ)
color np_color = input.color(#AB47BC, "", inline = "NYPM", group = G_KZ)

int box_transparency = input.int(85, "Box Transparency", minval = 0, maxval = 100, group = G_KZ)
int first_hour_transparency = input.int(78, "First Hour Transparency", minval = 0, maxval = 100, tooltip = "Lower values make the first hour of Tokyo and London more visible than the remaining Killzone.", group = G_KZ)
int text_transparency = input.int(55, "Text Transparency", minval = 0, maxval = 100, group = G_KZ)
bool show_tokyo_first_hour = input.bool(false, "Highlight Tokyo First Hour", group = G_KZ)
bool show_london_first_hour = input.bool(false, "Highlight London First Hour", group = G_KZ)

// =================================================================================================
// INPUTS — KILLZONE PIVOTS
// =================================================================================================
string G_KZ_PIVOTS = "Killzone Pivots"
bool show_pivots = input.bool(true, "Show Pivots", inline = "KZPV", group = G_KZ_PIVOTS)
bool alert_kz_pivots = input.bool(true, "Alert Broken Pivots", inline = "KZPV", group = G_KZ_PIVOTS)
string kz_extension_mode = input.string("End of Trading Day", "Extend Unmitigated Pivots", options = ["End of Trading Day", "Next Same Session", "Until Mitigated"], tooltip = "All Killzone pivots stop immediately at the first strict break. This setting defines only the maximum lifetime of a level that has not yet been mitigated.", group = G_KZ_PIVOTS)
kz_pivot_style = get_line_type(input.string("Solid", "Pivot Style", options = ["Solid", "Dotted", "Dashed"], inline = "KZST", group = G_KZ_PIVOTS))
int kz_pivot_width = input.int(1, "", minval = 1, maxval = 4, inline = "KZST", group = G_KZ_PIVOTS)

// =================================================================================================
// INPUTS — HIGHER-TIMEFRAME LEVELS
// =================================================================================================
string G_LEVELS = "Day - Week - Month - Swing Slots"
bool alert_level_breaks = input.bool(false, "Alert Level Breaks", group = G_LEVELS)
bool show_level_labels = input.bool(true, "Show Level Labels", tooltip = "Master switch for swing, daily, weekly, monthly and developing current-day labels. Lines remain visible.", group = G_LEVELS)
bool show_level_prices_in_labels = input.bool(true, "Show Prices in Unmitigated Level Labels", tooltip = "Appends the exact price to each visible, unmitigated Swing, Daily, Weekly, Monthly and Current Day label. Confluent levels keep one combined label and one price. Mitigated labels never display the price.", group = G_LEVELS)
int htf_label_offset_ticks = 0

bool show_swing1 = input.bool(true, "Swing Slot 1", inline = "SW1", group = G_LEVELS)
string swing1_tf = input.timeframe("240", "Timeframe", inline = "SW1", group = G_LEVELS)
int swing1_left = input.int(1, "Left", minval = 1, maxval = 20, inline = "SW1P", group = G_LEVELS)
int swing1_right = input.int(1, "Right", minval = 1, maxval = 20, inline = "SW1P", group = G_LEVELS)
color swing1_color = input.color(#1848CC, "Color", inline = "SW1C", group = G_LEVELS)
int swing1_width = input.int(2, "Width", minval = 1, maxval = 4, inline = "SW1C", group = G_LEVELS)

bool show_swing2 = input.bool(false, "Swing Slot 2", inline = "SW2", group = G_LEVELS)
string swing2_tf = input.timeframe("60", "Timeframe", inline = "SW2", group = G_LEVELS)
int swing2_left = input.int(1, "Left", minval = 1, maxval = 20, inline = "SW2P", group = G_LEVELS)
int swing2_right = input.int(1, "Right", minval = 1, maxval = 20, inline = "SW2P", group = G_LEVELS)
color swing2_color = input.color(#0C3299, "Color", inline = "SW2C", group = G_LEVELS)
int swing2_width = input.int(1, "Width", minval = 1, maxval = 4, inline = "SW2C", group = G_LEVELS)

bool show_past_day_hl = input.bool(true, "Past Daily Highs / Lows", inline = "DHL", group = G_LEVELS)
color daily_level_color = input.color(#3179F5, "", inline = "DHL", group = G_LEVELS)
int daily_level_width = input.int(2, "Width", minval = 1, maxval = 4, inline = "DHL", group = G_LEVELS)
bool show_current_day_hl = input.bool(false, "Current Day High / Low (Developing)", tooltip = "Plots the current Chicago trading-day high and low. These levels update during the session and are never treated as mitigated. At the next trading day, the completed levels are handled by Past Daily Highs / Lows.", group = G_LEVELS)
string past_day_high_label_text = input.string("D HIGH", "Daily High Label", inline = "DLBL", group = G_LEVELS)
string past_day_low_label_text = input.string("D LOW", "Daily Low Label", inline = "DLBL", group = G_LEVELS)
bool show_day_separator = input.bool(false, "Day Separator", inline = "DSEP", group = G_LEVELS)
color day_separator_color = input.color(#607D8B, "", inline = "DSEP", group = G_LEVELS)

bool show_past_week_hl = input.bool(true, "Past Weekly Highs / Lows", inline = "WHL", group = G_LEVELS)
color weekly_level_color = input.color(#5B9CF6, "", inline = "WHL", group = G_LEVELS)
int weekly_level_width = input.int(3, "Width", minval = 1, maxval = 4, inline = "WHL", group = G_LEVELS)
string past_week_high_label_text = input.string("W HIGH", "Weekly High Label", inline = "WLBL", group = G_LEVELS)
string past_week_low_label_text = input.string("W LOW", "Weekly Low Label", inline = "WLBL", group = G_LEVELS)
bool show_week_separator = input.bool(false, "Week Separator", inline = "WSEP", group = G_LEVELS)
color week_separator_color = input.color(#8D6E63, "", inline = "WSEP", group = G_LEVELS)

bool show_past_month_hl = input.bool(false, "Past Monthly Highs / Lows", inline = "MHL", group = G_LEVELS)
color monthly_level_color = input.color(#90BFF9, "", inline = "MHL", group = G_LEVELS)
int monthly_level_width = input.int(2, "Width", minval = 1, maxval = 4, inline = "MHL", group = G_LEVELS)
string past_month_high_label_text = input.string("M HIGH", "Monthly High Label", inline = "MLBL", group = G_LEVELS)
string past_month_low_label_text = input.string("M LOW", "Monthly Low Label", inline = "MLBL", group = G_LEVELS)
bool show_month_separator = input.bool(false, "Month Separator", inline = "MSEP", group = G_LEVELS)
color month_separator_color = input.color(#B71C1C, "", inline = "MSEP", group = G_LEVELS)

bool filter_levels_with_dr5 = input.bool(true, "Filter Levels With ADR5", tooltip = "ADR5 means Average Daily Range over the last five completed Chicago trading days. The value is frozen when a new trading day begins.", group = G_LEVELS)
float dr5_multiplier = input.float(1.0, "ADR5 Distance Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, tooltip = "Maximum display distance from current price = frozen ADR5 multiplied by this value.", group = G_LEVELS)

bool show_broken_levels = input.bool(true, "Show Mitigated Levels", tooltip = "When disabled, mitigated levels and their labels are hidden. Their state is preserved, so they reappear if this option is enabled again before daily cleanup.", group = G_LEVELS)
string mitigated_level_extension = input.string("End of Trading Day", "Mitigated Level Extension", options = ["End of Trading Day", "Until Mitigation"], tooltip = "End of Trading Day keeps a mitigated level extending until the current Chicago trading day finishes. Until Mitigation stops the line exactly on the candle that first traded through it.", group = G_LEVELS)
int broken_level_transparency = input.int(35, "Mitigated Level Transparency", minval = 0, maxval = 100, tooltip = "Lower values keep mitigated levels more visible.", group = G_LEVELS)
active_level_style = get_line_type(input.string("Solid", "Active Style", options = ["Solid", "Dotted", "Dashed"], inline = "LVST", group = G_LEVELS))
broken_level_style = get_line_type(input.string("Dotted", "Mitigated Style", options = ["Solid", "Dotted", "Dashed"], inline = "LVST", group = G_LEVELS))

bool dow_labels = input.bool(false, "Day of Week Labels", inline = "DOW", group = G_LEVELS)
string dow_yloc = input.string("Bottom", "", options = ["Top", "Bottom"], inline = "DOW", group = G_LEVELS)
string dow_xloc = input.string("Midnight", "", options = ["Midnight", "Midday"], inline = "DOW", group = G_LEVELS)
bool dow_hide_wknd = input.bool(false, "Hide Weekend Labels", group = G_LEVELS)

// =================================================================================================
// INPUTS — OPENING PRICES
// =================================================================================================
string G_OPEN = "Opening Prices"
bool show_daily_open = input.bool(true, "Daily Open", inline = "OP1", group = G_OPEN)
string daily_open_label_text = input.string("OpenD", "", inline = "OP1", group = G_OPEN)
color daily_open_color = input.color(#80DEEA, "", inline = "OP1", group = G_OPEN)

bool show_tokyo_open = input.bool(false, "Tokyo Open — 09:00 Tokyo", inline = "OP2", group = G_OPEN)
string tokyo_open_label_text = input.string("OpenT", "", inline = "OP2", group = G_OPEN)
color tokyo_open_color = input.color(#5C6BC0, "", inline = "OP2", group = G_OPEN)

bool show_london_open = input.bool(true, "London Open — 08:00 London", inline = "OP3", group = G_OPEN)
string london_open_label_text = input.string("OpenL", "", inline = "OP3", group = G_OPEN)
color london_open_color = input.color(#FDD835, "", inline = "OP3", group = G_OPEN)

bool show_us_open = input.bool(true, "US Cash Open — 08:30 Chicago", inline = "OP4", group = G_OPEN)
string us_open_label_text = input.string("OpenUS", "", inline = "OP4", group = G_OPEN)
color us_open_color = input.color(#ECEFF1, "", inline = "OP4", group = G_OPEN)

bool show_past_daily_opens = input.bool(false, "Past Daily Opens", inline = "OPH1", tooltip = "Keeps prior Daily Open lines. Each historical line stops when the next Daily Open begins. History is limited by Session Drawing Limit.", group = G_OPEN)
bool show_past_tokyo_opens = input.bool(false, "Past Tokyo Opens", inline = "OPH1", tooltip = "Keeps prior Tokyo Open lines. Each historical line stops when the next Tokyo Open begins. History is limited by Session Drawing Limit.", group = G_OPEN)
bool show_past_london_opens = input.bool(false, "Past London Opens", inline = "OPH2", tooltip = "Keeps prior London Open lines. Each historical line stops when the next London Open begins. History is limited by Session Drawing Limit.", group = G_OPEN)
bool show_past_us_opens = input.bool(false, "Past US Cash Opens", inline = "OPH2", tooltip = "Keeps prior US Cash Open lines. Each historical line stops when the next US Cash Open begins. History is limited by Session Drawing Limit.", group = G_OPEN)

int label_gap_bars = input.int(2, "Opening Label Gap", minval = 1, maxval = 30, tooltip = "Minimum half-gap around opening labels after they become visible.", group = G_OPEN)
opening_style = get_line_type(input.string("Dotted", "Opening Style", options = ["Solid", "Dotted", "Dashed"], inline = "OPST", group = G_OPEN))
int opening_width = input.int(1, "", minval = 1, maxval = 4, inline = "OPST", group = G_OPEN)

// =================================================================================================
// INPUTS — TIMESTAMPS
// =================================================================================================
string G_TS = "Timestamps"
bool show_midnight_timestamp = input.bool(true, "Daily Open", inline = "TS1", group = G_TS)
color midnight_timestamp_color = input.color(#546E7A, "", inline = "TS1", group = G_TS)
bool show_us_timestamp = input.bool(true, "Cash Open", inline = "TS2", group = G_TS)
color us_timestamp_color = input.color(#B0BEC5, "", inline = "TS2", group = G_TS)
timestamp_style = get_line_type(input.string("Dotted", "Timestamp Style", options = ["Solid", "Dotted", "Dashed"], inline = "TSST", group = G_TS))
int timestamp_width = input.int(1, "", minval = 1, maxval = 4, inline = "TSST", group = G_TS)

// =================================================================================================
// INPUTS — INITIAL BALANCE USA
// =================================================================================================
string G_IB_SETTINGS = "IB Settings"
bool show_ib = input.bool(true, "Show US Initial Balance", group = G_IB_SETTINGS)
bool ib_tf_filter = input.bool(true, "Hide IB on incompatible timeframes", tooltip = "The US IB uses 08:30–09:30 America/Chicago. Timeframes that do not divide 30 minutes cleanly are hidden when this option is enabled.", group = G_IB_SETTINGS)
string ib_tf_limit = input.timeframe("30", "IB Timeframe Limit", group = G_IB_SETTINGS)

string G_IB_DISPLAY = "IB Display"
bool drawExtras = input.bool(false, "Plot x2 / x3 extensions", group = G_IB_DISPLAY)
bool drawMidPoints = input.bool(true, "Plot 50% mid-levels", group = G_IB_DISPLAY)
bool shadeWindow = input.bool(false, "Highlight IB window on chart", group = G_IB_DISPLAY)
bool renderLabels = input.bool(false, "Show price labels", group = G_IB_DISPLAY)
bool shadeZones = input.bool(true, "Tint IB high-low area", group = G_IB_DISPLAY)
bool thisDayOnly = input.bool(false, "Keep only today's levels", group = G_IB_DISPLAY)
bool thisZoneOnly = input.bool(false, "Keep only today's tinted zone", group = G_IB_DISPLAY)
bool showDeltaInfo = input.bool(false, "Show 20-session IB-Δ stats", group = G_IB_DISPLAY)

string G_IB_STYLE = "IB Styling"
string ibLabelSizeInput = input.string("Small", "Label Size", options = ["Auto", "Huge", "Large", "Normal", "Small", "Tiny"], group = G_IB_STYLE)
int ibLineWidth = input.int(1, "Line Width", minval = 1, maxval = 4, group = G_IB_STYLE)
color clrHigh = input.color(#4CAF50, "High-side Color", group = G_IB_STYLE)
color clrLow = input.color(#F23645, "Low-side Color", group = G_IB_STYLE)
color clrMid = input.color(#FFFFFF, "Mid-level Color", group = G_IB_STYLE)
string extendOpt = input.string("Right", "Extend Lines", options = ["Right", "Left", "Both", "None"], tooltip = "None/Left: levels stop at 15:00 Chicago, the end of the US cash session. Right/Both: levels continue overnight but stop at 08:30 Chicago, when the next Initial Balance begins.", group = G_IB_STYLE)
mainIbStyle = get_line_type(input.string("Solid", "Main Level Style", options = ["Solid", "Dashed", "Dotted"], group = G_IB_STYLE))
extIbStyle = get_line_type(input.string("Dashed", "x2/x3 Level Style", options = ["Solid", "Dashed", "Dotted"], group = G_IB_STYLE))
midIbStyle = get_line_type(input.string("Dotted", "Mid-level Style", options = ["Solid", "Dashed", "Dotted"], group = G_IB_STYLE))
color zoneTint = input.color(color.new(#FFF9C4, 85), "Zone Fill Color", group = G_IB_STYLE)

ibLabelSize = get_size(ibLabelSizeInput)
ibLeftExtend = extendOpt == "Left" or extendOpt == "Both" ? extend.left : extend.none
bool ibContinueUntilNext = extendOpt == "Right" or extendOpt == "Both"

// =================================================================================================
// DATA TYPES
// =================================================================================================
type level_store
    array<line> lines
    array<line> rightLines
    array<label> labels
    array<float> prices
    array<bool> isHigh
    array<bool> broken
    array<int> brokenDay
    array<int> brokenTimes
    array<bool> visibleNow
    array<color> baseColors
    array<string> names
    array<int> widths

new_level_store() =>
    level_store.new(array.new_line(), array.new_line(), array.new_label(), array.new_float(), array.new_bool(), array.new_bool(), array.new_int(), array.new_int(), array.new_bool(), array.new_color(), array.new_string(), array.new_int())

type opening_store
    array<line> lines
    array<line> rightLines
    array<label> labels
    array<bool> labelShown
    array<int> revealTimes
    array<color> colors
    array<string> names

new_opening_store() =>
    opening_store.new(array.new_line(), array.new_line(), array.new_label(), array.new_bool(), array.new_int(), array.new_color(), array.new_string())

type ib_set
    array<line> lines
    array<label> labels
    box zone
    int startTime
    bool extendToNextIb
    bool rightClosed

// =================================================================================================
// KILLZONE STATE
// =================================================================================================
var array<box> asiaBoxes = array.new_box()
var array<line> asiaHighLines = array.new_line()
var array<line> asiaLowLines = array.new_line()
var array<bool> asiaHighValid = array.new_bool()
var array<bool> asiaLowValid = array.new_bool()

var array<box> londonBoxes = array.new_box()
var array<line> londonHighLines = array.new_line()
var array<line> londonLowLines = array.new_line()
var array<bool> londonHighValid = array.new_bool()
var array<bool> londonLowValid = array.new_bool()

var array<box> nyamBoxes = array.new_box()
var array<line> nyamHighLines = array.new_line()
var array<line> nyamLowLines = array.new_line()
var array<bool> nyamHighValid = array.new_bool()
var array<bool> nyamLowValid = array.new_bool()

var array<box> nyluBoxes = array.new_box()
var array<line> nyluHighLines = array.new_line()
var array<line> nyluLowLines = array.new_line()
var array<bool> nyluHighValid = array.new_bool()
var array<bool> nyluLowValid = array.new_bool()

var array<box> nypmBoxes = array.new_box()
var array<line> nypmHighLines = array.new_line()
var array<line> nypmLowLines = array.new_line()
var array<bool> nypmHighValid = array.new_bool()
var array<bool> nypmLowValid = array.new_bool()

var array<box> tokyoFirstHourBoxes = array.new_box()
var array<box> londonFirstHourBoxes = array.new_box()

trim_box_history(array<box> boxes) =>
    while array.size(boxes) > max_days
        box.delete(array.pop(boxes))

trim_kz_pivot_history(array<line> hiLines, array<line> loLines, array<bool> hiValid, array<bool> loValid) =>
    while array.size(hiLines) > max_days
        line.delete(array.pop(hiLines))
        line.delete(array.pop(loLines))
        array.pop(hiValid)
        array.pop(loValid)

manage_first_hour(bool enabled, string sessionName, string timezoneName, color baseColor, array<box> boxes) =>
    bool active = enabled and drawingTfOk and session_active(sessionName, timezoneName)
    bool starts = session_start(active)
    if starts
        box b = box.new(time, high, time, low, xloc = xloc.bar_time, border_color = color.new(baseColor, first_hour_transparency), bgcolor = color.new(baseColor, first_hour_transparency))
        array.unshift(boxes, b)
        trim_box_history(boxes)
    if active and array.size(boxes) > 0
        box b = array.get(boxes, 0)
        box.set_right(b, time)
        box.set_top(b, math.max(box.get_top(b), high))
        box.set_bottom(b, math.min(box.get_bottom(b), low))

expire_unmitigated_kz_pivots(array<line> hiLines, array<line> loLines, array<bool> hiValid, array<bool> loValid, int stopTime) =>
    int count = array.size(hiLines)
    if count > 0
        for i = 0 to count - 1
            if array.get(hiValid, i)
                line.set_x2(array.get(hiLines, i), stopTime)
                array.set(hiValid, i, false)
            if array.get(loValid, i)
                line.set_x2(array.get(loLines, i), stopTime)
                array.set(loValid, i, false)

manage_killzone(bool enabled, string sessionName, string titleText, color baseColor, array<box> boxes, array<line> hiLines, array<line> loLines, array<bool> hiValid, array<bool> loValid) =>
    bool active = enabled and drawingTfOk and session_active(sessionName, gmt_tz)
    bool starts = session_start(active)

    // In this mode the previous unmitigated levels expire exactly when the
    // same Killzone begins again. This happens before the new pivots are added.
    if starts and show_pivots and kz_extension_mode == "Next Same Session"
        expire_unmitigated_kz_pivots(hiLines, loLines, hiValid, loValid, time)

    if starts
        color boxColor = color.new(baseColor, box_transparency)
        color textColor = color.new(baseColor, text_transparency)
        box b = box.new(time, high, time, low, xloc = xloc.bar_time, border_color = show_kz ? boxColor : na, bgcolor = show_kz ? boxColor : na, text = show_kz and show_kz_text ? titleText : "", text_color = textColor)
        array.unshift(boxes, b)
        trim_box_history(boxes)

        if show_pivots
            line hiLine = line.new(time, high, time, high, xloc = xloc.bar_time, color = baseColor, style = kz_pivot_style, width = kz_pivot_width)
            line loLine = line.new(time, low, time, low, xloc = xloc.bar_time, color = baseColor, style = kz_pivot_style, width = kz_pivot_width)
            array.unshift(hiLines, hiLine)
            array.unshift(loLines, loLine)
            array.unshift(hiValid, true)
            array.unshift(loValid, true)
            trim_kz_pivot_history(hiLines, loLines, hiValid, loValid)

    if active and array.size(boxes) > 0
        box currentBox = array.get(boxes, 0)
        float newTop = math.max(box.get_top(currentBox), high)
        float newBottom = math.min(box.get_bottom(currentBox), low)
        box.set_right(currentBox, time)
        box.set_top(currentBox, newTop)
        box.set_bottom(currentBox, newBottom)

        if show_pivots and array.size(hiLines) > 0
            line currentHigh = array.get(hiLines, 0)
            line currentLow = array.get(loLines, 0)
            line.set_x2(currentHigh, time)
            line.set_x2(currentLow, time)
            if high > line.get_y1(currentHigh)
                line.set_xy1(currentHigh, time, high)
                line.set_xy2(currentHigh, time, high)
            if low < line.get_y1(currentLow)
                line.set_xy1(currentLow, time, low)
                line.set_xy2(currentLow, time, low)

    // The developing pivot at index zero is not eligible for mitigation while
    // its own Killzone is active. Older pivots remain eligible on every bar.
    if show_pivots and array.size(hiLines) > 0
        int count = array.size(hiLines)
        int firstEligibleIndex = active ? 1 : 0
        int currentTradingDay = trading_day_key(time)

        if firstEligibleIndex < count
            for i = firstEligibleIndex to count - 1
                line hiLine = array.get(hiLines, i)
                line loLine = array.get(loLines, i)
                bool highIsValid = array.get(hiValid, i)
                bool lowIsValid = array.get(loValid, i)

                bool expiresAtTradingDay = kz_extension_mode == "End of Trading Day"
                bool highExpired = expiresAtTradingDay and trading_day_key(line.get_x1(hiLine)) != currentTradingDay
                bool lowExpired = expiresAtTradingDay and trading_day_key(line.get_x1(loLine)) != currentTradingDay

                if highIsValid
                    line.set_x2(hiLine, time)
                    if highExpired
                        array.set(hiValid, i, false)
                    else if high > line.get_y1(hiLine)
                        array.set(hiValid, i, false)
                        if alert_kz_pivots
                            alert("Broke " + titleText + " High", alert.freq_once_per_bar)

                if lowIsValid
                    line.set_x2(loLine, time)
                    if lowExpired
                        array.set(loValid, i, false)
                    else if low < line.get_y1(loLine)
                        array.set(loValid, i, false)
                        if alert_kz_pivots
                            alert("Broke " + titleText + " Low", alert.freq_once_per_bar)

// =================================================================================================
// HIGHER-TIMEFRAME LEVEL ENGINE
// =================================================================================================
var level_store swing1Levels = new_level_store()
var level_store swing2Levels = new_level_store()
var level_store dailyLevels = new_level_store()
var level_store weeklyLevels = new_level_store()
var level_store monthlyLevels = new_level_store()

// Developing current trading-day levels are deliberately kept outside the break engine.
var line currentDayHighLine = na
var line currentDayLowLine = na
var label currentDayHighLabel = na
var label currentDayLowLabel = na
var int currentDayLevelStart = na

remove_level(level_store store, int index) =>
    line.delete(array.get(store.lines, index))
    line.delete(array.get(store.rightLines, index))
    label levelLabel = array.get(store.labels, index)
    if not na(levelLabel)
        label.delete(levelLabel)
    array.remove(store.lines, index)
    array.remove(store.rightLines, index)
    array.remove(store.labels, index)
    array.remove(store.prices, index)
    array.remove(store.isHigh, index)
    array.remove(store.broken, index)
    array.remove(store.brokenDay, index)
    array.remove(store.brokenTimes, index)
    array.remove(store.visibleNow, index)
    array.remove(store.baseColors, index)
    array.remove(store.names, index)
    array.remove(store.widths, index)

trim_level_store(level_store store, int maximumLevels) =>
    while array.size(store.lines) > maximumLevels
        remove_level(store, array.size(store.lines) - 1)

add_level(level_store store, int startTime, float price, bool isHighLevel, string levelName, color baseColor, int lineWidth, int maximumLevels, int currentDayKey) =>
    if not na(price) and not na(startTime)
        int anchor = level_label_right_time(time)
        line mainLine = line.new(startTime, price, time, price, xloc = xloc.bar_time, color = baseColor, style = active_level_style, width = lineWidth)
        // Kept for backward-compatible storage. The visible HTF level is a single uninterrupted line.
        line spareLine = line.new(time, price, time, price, xloc = xloc.bar_time, color = na, style = active_level_style, width = lineWidth)
        label levelLabel = label.new(anchor, level_label_price(price, isHighLevel, htf_label_offset_ticks), level_label_display_text(levelName, isHighLevel), xloc = xloc.bar_time, yloc = yloc.price, style = level_label_style(isHighLevel), color = TRANSPARENT, textcolor = show_level_labels ? baseColor : na, size = label_size, textalign = text.align_left, text_font_family = font.family_monospace)
        array.unshift(store.lines, mainLine)
        array.unshift(store.rightLines, spareLine)
        array.unshift(store.labels, levelLabel)
        array.unshift(store.prices, price)
        array.unshift(store.isHigh, isHighLevel)
        array.unshift(store.broken, false)
        array.unshift(store.brokenDay, na)
        array.unshift(store.brokenTimes, na)
        array.unshift(store.visibleNow, true)
        array.unshift(store.baseColors, baseColor)
        array.unshift(store.names, levelName)
        array.unshift(store.widths, lineWidth)
        trim_level_store(store, maximumLevels)

remove_broken_from_previous_days(level_store store, int currentTradingDay) =>
    int count = array.size(store.lines)
    if count > 0
        for i = count - 1 to 0
            bool isBroken = array.get(store.broken, i)
            int breakDay = array.get(store.brokenDay, i)
            if isBroken and not na(breakDay) and breakDay != currentTradingDay
                remove_level(store, i)

update_level_store(level_store store, int currentTradingDay, float visibilityDistance) =>
    int count = array.size(store.lines)
    if count > 0
        for i = 0 to count - 1
            line mainLine = array.get(store.lines, i)
            line spareLine = array.get(store.rightLines, i)
            label levelLabel = array.get(store.labels, i)
            float levelPrice = array.get(store.prices, i)
            bool highLevel = array.get(store.isHigh, i)
            bool isBroken = array.get(store.broken, i)
            int breakTime = array.get(store.brokenTimes, i)
            color baseColor = array.get(store.baseColors, i)
            string levelName = array.get(store.names, i)
            int lineWidth = array.get(store.widths, i)
            int x1 = line.get_x1(mainLine)

            if not isBroken
                bool brokenNow = highLevel ? high > levelPrice : low < levelPrice
                if brokenNow
                    isBroken := true
                    breakTime := time
                    array.set(store.broken, i, true)
                    array.set(store.brokenDay, i, currentTradingDay)
                    array.set(store.brokenTimes, i, breakTime)
                    if alert_level_breaks
                        alert("Broke " + levelName + " @ " + str.tostring(levelPrice, format.mintick), alert.freq_once_per_bar)

            bool visible = (not isBroken or show_broken_levels) and (not filter_levels_with_dr5 or na(visibilityDistance) or math.abs(close - levelPrice) <= visibilityDistance)
            array.set(store.visibleNow, i, visible)
            color displayColor = isBroken ? color.new(baseColor, broken_level_transparency) : baseColor
            lineStyle = isBroken ? broken_level_style : active_level_style
            bool stopAtMitigation = isBroken and mitigated_level_extension == "Until Mitigation" and not na(breakTime)
            int visibleLineEnd = stopAtMitigation ? breakTime : time
            int anchor = level_label_right_time(visibleLineEnd)

            line.set_xy1(mainLine, x1, levelPrice)
            line.set_xy2(mainLine, visibleLineEnd, levelPrice)
            line.set_width(mainLine, lineWidth)
            line.set_style(mainLine, lineStyle)
            line.set_color(mainLine, visible ? displayColor : na)

            line.set_xy1(spareLine, time, levelPrice)
            line.set_xy2(spareLine, time, levelPrice)
            line.set_color(spareLine, na)

            if not na(levelLabel)
                label.set_x(levelLabel, anchor)
                label.set_y(levelLabel, level_label_price(levelPrice, highLevel, htf_label_offset_ticks))
                label.set_text(levelLabel, level_label_display_text(levelName, highLevel))
                label.set_textcolor(levelLabel, show_level_labels and visible ? displayColor : na)
                label.set_style(levelLabel, level_label_style(highLevel))
                label.set_textalign(levelLabel, text.align_left)
                label.set_color(levelLabel, TRANSPARENT)

// Confirmed pivots for both optional swing slots.
htf_pivots(int leftBars, int rightBars) =>
    // Pine requires ta.pivothigh/ta.pivotlow to be evaluated on every calculation.
    // Confirmation is applied only after the raw pivot series has been computed.
    float rawPHigh = ta.pivothigh(high, leftBars, rightBars)
    float rawPLow = ta.pivotlow(low, leftBars, rightBars)
    bool confirmationBarClosed = barstate.isconfirmed
    float pHigh = confirmationBarClosed ? rawPHigh : na
    float pLow = confirmationBarClosed ? rawPLow : na
    int pHighTime = not na(pHigh) ? time[rightBars] : na
    int pLowTime = not na(pLow) ? time[rightBars] : na
    [pHigh, pHighTime, pLow, pLowTime]

[phSwing1, phSwing1Time, plSwing1, plSwing1Time] = request.security(syminfo.tickerid, swing1_tf, htf_pivots(swing1_left, swing1_right), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[phSwing2, phSwing2Time, plSwing2, plSwing2Time] = request.security(syminfo.tickerid, swing2_tf, htf_pivots(swing2_left, swing2_right), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

bool newSwing1High = show_swing1 and not na(phSwing1Time) and (na(phSwing1Time[1]) or phSwing1Time != phSwing1Time[1])
bool newSwing1Low = show_swing1 and not na(plSwing1Time) and (na(plSwing1Time[1]) or plSwing1Time != plSwing1Time[1])
bool newSwing2High = show_swing2 and not na(phSwing2Time) and (na(phSwing2Time[1]) or phSwing2Time != phSwing2Time[1])
bool newSwing2Low = show_swing2 and not na(plSwing2Time) and (na(plSwing2Time[1]) or plSwing2Time != plSwing2Time[1])

string swing1Prefix = timeframe_display_name(swing1_tf)
string swing2Prefix = timeframe_display_name(swing2_tf)
string swing1HighText = swing1Prefix + " H"
string swing1LowText = swing1Prefix + " L"
string swing2HighText = swing2Prefix + " H"
string swing2LowText = swing2Prefix + " L"

// =================================================================================================
// CUSTOM TRADING DAY, ADR5, DAILY/WEEKLY/MONTHLY RANGES
// =================================================================================================
var int currentTradingDay = na
var int currentWeekKey = na
var int currentMonthKey = na
var int currentWeekStart = na
var int currentMonthStart = na
var float dayHigh = na
var float dayLow = na
var int dayHighTime = na
var int dayLowTime = na
var float weekHigh = na
var float weekLow = na
var int weekHighTime = na
var int weekLowTime = na
var float monthHigh = na
var float monthLow = na
var int monthHighTime = na
var int monthLowTime = na
var array<float> drBuffer = array.new_float()
var float dr5 = na

int barTradingDay = trading_day_key(time)
int barWeekKey = week_key(barTradingDay)
int barMonthKey = month_key(barTradingDay)
bool newTradingDay = not na(currentTradingDay) and barTradingDay != currentTradingDay
bool newTradingWeek = not na(currentWeekKey) and barWeekKey != currentWeekKey
bool newTradingMonth = not na(currentMonthKey) and barMonthKey != currentMonthKey

if na(currentTradingDay)
    currentTradingDay := barTradingDay
    currentWeekKey := barWeekKey
    currentMonthKey := barMonthKey
    currentWeekStart := week_start_key(barTradingDay)
    currentMonthStart := barTradingDay
    dayHigh := high
    dayLow := low
    dayHighTime := time
    dayLowTime := time
    currentDayLevelStart := time
    weekHigh := high
    weekLow := low
    weekHighTime := time
    weekLowTime := time
    monthHigh := high
    monthLow := low
    monthHighTime := time
    monthLowTime := time
else
    if newTradingDay
        // Pine functions cannot reassign global object IDs, so developing
        // current-day drawings are cleared directly in global scope.
        if not na(currentDayHighLine)
            line.delete(currentDayHighLine)
        if not na(currentDayLowLine)
            line.delete(currentDayLowLine)
        if not na(currentDayHighLabel)
            label.delete(currentDayHighLabel)
        if not na(currentDayLowLabel)
            label.delete(currentDayLowLabel)
        currentDayHighLine := na
        currentDayLowLine := na
        currentDayHighLabel := na
        currentDayLowLabel := na

        float completedDayRange = dayHigh - dayLow
        array.push(drBuffer, completedDayRange)
        if array.size(drBuffer) > 5
            array.shift(drBuffer)
        dr5 := array.avg(drBuffer)

        if show_past_day_hl
            string completedDayDate = format_day_month(currentTradingDay, TZ_CHICAGO)
            add_level(dailyLevels, dayHighTime, dayHigh, true, past_day_high_label_text + " " + completedDayDate, daily_level_color, daily_level_width, 20, barTradingDay)
            add_level(dailyLevels, dayLowTime, dayLow, false, past_day_low_label_text + " " + completedDayDate, daily_level_color, daily_level_width, 20, barTradingDay)

        if newTradingWeek
            if show_past_week_hl
                string completedWeekDate = format_day_month(currentWeekStart, TZ_CHICAGO)
                add_level(weeklyLevels, weekHighTime, weekHigh, true, past_week_high_label_text + " " + completedWeekDate, weekly_level_color, weekly_level_width, 12, barTradingDay)
                add_level(weeklyLevels, weekLowTime, weekLow, false, past_week_low_label_text + " " + completedWeekDate, weekly_level_color, weekly_level_width, 12, barTradingDay)
            currentWeekKey := barWeekKey
            currentWeekStart := week_start_key(barTradingDay)
            weekHigh := high
            weekLow := low
            weekHighTime := time
            weekLowTime := time
        else
            if high > weekHigh
                weekHigh := high
                weekHighTime := time
            if low < weekLow
                weekLow := low
                weekLowTime := time

        if newTradingMonth
            if show_past_month_hl
                add_level(monthlyLevels, monthHighTime, monthHigh, true, past_month_high_label_text, monthly_level_color, monthly_level_width, 8, barTradingDay)
                add_level(monthlyLevels, monthLowTime, monthLow, false, past_month_low_label_text, monthly_level_color, monthly_level_width, 8, barTradingDay)
            currentMonthKey := barMonthKey
            currentMonthStart := barTradingDay
            monthHigh := high
            monthLow := low
            monthHighTime := time
            monthLowTime := time
        else
            if high > monthHigh
                monthHigh := high
                monthHighTime := time
            if low < monthLow
                monthLow := low
                monthLowTime := time

        currentTradingDay := barTradingDay
        dayHigh := high
        dayLow := low
        dayHighTime := time
        dayLowTime := time
        currentDayLevelStart := time

        remove_broken_from_previous_days(swing1Levels, currentTradingDay)
        remove_broken_from_previous_days(swing2Levels, currentTradingDay)
        remove_broken_from_previous_days(dailyLevels, currentTradingDay)
        remove_broken_from_previous_days(weeklyLevels, currentTradingDay)
        remove_broken_from_previous_days(monthlyLevels, currentTradingDay)
    else
        if high > dayHigh
            dayHigh := high
            dayHighTime := time
        if low < dayLow
            dayLow := low
            dayLowTime := time

        if high > weekHigh
            weekHigh := high
            weekHighTime := time
        if low < weekLow
            weekLow := low
            weekLowTime := time

        if high > monthHigh
            monthHigh := high
            monthHighTime := time
        if low < monthLow
            monthLow := low
            monthLowTime := time

// Developing current trading-day high/low.
// All assignments stay in global scope because Pine does not allow a function
// to reassign global line/label variables.
if show_current_day_hl
    if na(currentDayLevelStart)
        currentDayLevelStart := time

    string currentDayDate = format_day_month(barTradingDay, TZ_CHICAGO)

    if na(currentDayHighLine)
        currentDayHighLine := line.new(currentDayLevelStart, dayHigh, time, dayHigh, xloc = xloc.bar_time, color = daily_level_color, style = line.style_dashed, width = daily_level_width)
    if na(currentDayLowLine)
        currentDayLowLine := line.new(currentDayLevelStart, dayLow, time, dayLow, xloc = xloc.bar_time, color = daily_level_color, style = line.style_dashed, width = daily_level_width)

    int currentDayAnchor = level_label_right_time(time)

    if na(currentDayHighLabel)
        currentDayHighLabel := label.new(currentDayAnchor, level_label_price(dayHigh, true, htf_label_offset_ticks), "Current Day High", xloc = xloc.bar_time, yloc = yloc.price, style = level_label_style(true), color = TRANSPARENT, textcolor = show_level_labels ? daily_level_color : na, size = label_size, textalign = text.align_left, text_font_family = font.family_monospace)
    if na(currentDayLowLabel)
        currentDayLowLabel := label.new(currentDayAnchor, level_label_price(dayLow, false, htf_label_offset_ticks), "Current Day Low", xloc = xloc.bar_time, yloc = yloc.price, style = level_label_style(false), color = TRANSPARENT, textcolor = show_level_labels ? daily_level_color : na, size = label_size, textalign = text.align_left, text_font_family = font.family_monospace)

    line.set_xy1(currentDayHighLine, dayHighTime, dayHigh)
    line.set_xy2(currentDayHighLine, time, dayHigh)
    line.set_color(currentDayHighLine, daily_level_color)
    line.set_width(currentDayHighLine, daily_level_width)
    line.set_style(currentDayHighLine, line.style_dashed)

    line.set_xy1(currentDayLowLine, dayLowTime, dayLow)
    line.set_xy2(currentDayLowLine, time, dayLow)
    line.set_color(currentDayLowLine, daily_level_color)
    line.set_width(currentDayLowLine, daily_level_width)
    line.set_style(currentDayLowLine, line.style_dashed)

    label.set_x(currentDayHighLabel, currentDayAnchor)
    label.set_y(currentDayHighLabel, level_label_price(dayHigh, true, htf_label_offset_ticks))
    label.set_text(currentDayHighLabel, "Current Day High")
    label.set_style(currentDayHighLabel, level_label_style(true))
    label.set_textcolor(currentDayHighLabel, show_level_labels ? daily_level_color : na)
    label.set_color(currentDayHighLabel, TRANSPARENT)

    label.set_x(currentDayLowLabel, currentDayAnchor)
    label.set_y(currentDayLowLabel, level_label_price(dayLow, false, htf_label_offset_ticks))
    label.set_text(currentDayLowLabel, "Current Day Low")
    label.set_style(currentDayLowLabel, level_label_style(false))
    label.set_textcolor(currentDayLowLabel, show_level_labels ? daily_level_color : na)
    label.set_color(currentDayLowLabel, TRANSPARENT)
else
    if not na(currentDayHighLine)
        line.delete(currentDayHighLine)
    if not na(currentDayLowLine)
        line.delete(currentDayLowLine)
    if not na(currentDayHighLabel)
        label.delete(currentDayHighLabel)
    if not na(currentDayLowLabel)
        label.delete(currentDayLowLabel)
    currentDayHighLine := na
    currentDayLowLine := na
    currentDayHighLabel := na
    currentDayLowLabel := na

if newSwing1High
    add_level(swing1Levels, phSwing1Time, phSwing1, true, swing1HighText, swing1_color, swing1_width, 60, barTradingDay)
if newSwing1Low
    add_level(swing1Levels, plSwing1Time, plSwing1, false, swing1LowText, swing1_color, swing1_width, 60, barTradingDay)
if newSwing2High
    add_level(swing2Levels, phSwing2Time, phSwing2, true, swing2HighText, swing2_color, swing2_width, 60, barTradingDay)
if newSwing2Low
    add_level(swing2Levels, plSwing2Time, plSwing2, false, swing2LowText, swing2_color, swing2_width, 60, barTradingDay)

float levelVisibilityDistance = not na(dr5) ? dr5 * dr5_multiplier : na
update_level_store(swing1Levels, barTradingDay, levelVisibilityDistance)
update_level_store(swing2Levels, barTradingDay, levelVisibilityDistance)
update_level_store(dailyLevels, barTradingDay, levelVisibilityDistance)
update_level_store(weeklyLevels, barTradingDay, levelVisibilityDistance)
update_level_store(monthlyLevels, barTradingDay, levelVisibilityDistance)

// Confluent levels follow a strict hierarchy: monthly > weekly > daily > swing slot 1 > swing slot 2.
// Daily text is suppressed when a Weekly level exists at the same price. Swing information
// is appended to the dominant label, and the dominant line adopts the earliest swing origin.
suppress_confluent_lower(level_store primaryStore, level_store secondaryStore, bool adoptEarlierOrigin, bool keepSecondaryName) =>
    float tolerance = syminfo.mintick * 2.0
    int primaryCount = array.size(primaryStore.lines)
    int secondaryCount = array.size(secondaryStore.lines)
    if primaryCount > 0 and secondaryCount > 0
        for p = 0 to primaryCount - 1
            label primaryLabel = array.get(primaryStore.labels, p)
            bool primaryIsBroken = array.get(primaryStore.broken, p)
            bool primaryEligible = show_broken_levels or not primaryIsBroken
            if primaryEligible and not na(primaryLabel) and str.length(level_label_raw_text(label.get_text(primaryLabel))) > 0
                float primaryPrice = array.get(primaryStore.prices, p)
                bool primaryIsHigh = array.get(primaryStore.isHigh, p)
                string primaryName = array.get(primaryStore.names, p)
                for q = 0 to secondaryCount - 1
                    label secondaryLabel = array.get(secondaryStore.labels, q)
                    bool secondaryIsBroken = array.get(secondaryStore.broken, q)
                    bool secondaryEligible = show_broken_levels or not secondaryIsBroken
                    if secondaryEligible and not na(secondaryLabel) and str.length(level_label_raw_text(label.get_text(secondaryLabel))) > 0
                        float secondaryPrice = array.get(secondaryStore.prices, q)
                        bool secondaryIsHigh = array.get(secondaryStore.isHigh, q)
                        bool sameSide = primaryIsHigh == secondaryIsHigh
                        bool samePrice = math.abs(primaryPrice - secondaryPrice) <= tolerance
                        if sameSide and samePrice
                            line primaryLine = array.get(primaryStore.lines, p)
                            line secondaryLine = array.get(secondaryStore.lines, q)
                            line secondarySpare = array.get(secondaryStore.rightLines, q)

                            if adoptEarlierOrigin
                                int earliestOrigin = math.min(line.get_x1(primaryLine), line.get_x1(secondaryLine))
                                line.set_x1(primaryLine, earliestOrigin)
                                int primaryLineEnd = line.get_x2(primaryLine)
                                int anchor = level_label_right_time(primaryLineEnd)
                                label.set_x(primaryLabel, anchor)

                            if keepSecondaryName
                                string secondaryName = array.get(secondaryStore.names, q)
                                string currentPrimaryText = level_label_raw_text(label.get_text(primaryLabel))
                                string combinedName = append_level_name(currentPrimaryText, secondaryName)
                                label.set_text(primaryLabel, level_label_display_text(combinedName, primaryIsHigh))

                            // Explicitly preserve the semantic vertical rule in every state:
                            // highs above the line, lows below it, including broken levels.
                            label.set_y(primaryLabel, level_label_price(primaryPrice, primaryIsHigh, htf_label_offset_ticks))
                            label.set_style(primaryLabel, level_label_style(primaryIsHigh))

                            label.set_text(secondaryLabel, "")
                            label.set_textcolor(secondaryLabel, na)
                            line.set_color(secondaryLine, na)
                            line.set_color(secondarySpare, na)

collect_level_label_candidates(level_store store, float visibilityDistance, array<label> candidateLabels, array<float> candidatePrices, array<int> candidateLineEnds, array<string> candidateTexts) =>
    int count = array.size(store.lines)
    if count > 0 and show_level_labels
        for i = 0 to count - 1
            label levelLabel = array.get(store.labels, i)
            float levelPrice = array.get(store.prices, i)
            bool isBroken = array.get(store.broken, i)
            bool visible = array.get(store.visibleNow, i)
            string baseLabelText = not na(levelLabel) ? label.get_text(levelLabel) : ""

            if visible and not na(levelLabel) and str.length(baseLabelText) > 0
                line mainLine = array.get(store.lines, i)
                string finalLabelText = level_label_text_with_price(baseLabelText, levelPrice, show_level_prices_in_labels and not isBroken)
                label.set_text(levelLabel, finalLabelText)

                array.push(candidateLabels, levelLabel)
                array.push(candidatePrices, levelPrice)
                array.push(candidateLineEnds, line.get_x2(mainLine))
                array.push(candidateTexts, finalLabelText)

confluent_active_level_name(level_store store, float candidatePrice, bool candidateIsHigh) =>
    string matchingName = ""
    int count = array.size(store.lines)
    if count > 0 and not na(candidatePrice)
        float tolerance = syminfo.mintick * 2.0
        for i = 0 to count - 1
            float storedPrice = array.get(store.prices, i)
            bool storedIsHigh = array.get(store.isHigh, i)
            bool storedIsBroken = array.get(store.broken, i)
            bool storedVisible = array.get(store.visibleNow, i)
            bool sameSide = storedIsHigh == candidateIsHigh
            bool samePrice = math.abs(storedPrice - candidatePrice) <= tolerance

            if str.length(matchingName) == 0 and sameSide and samePrice and not storedIsBroken and storedVisible
                matchingName := array.get(store.names, i)
    matchingName

preferred_confluent_swing_name(level_store priorityStore, level_store secondaryStore, float candidatePrice, bool candidateIsHigh) =>
    string matchingName = confluent_active_level_name(priorityStore, candidatePrice, candidateIsHigh)
    if str.length(matchingName) == 0
        matchingName := confluent_active_level_name(secondaryStore, candidatePrice, candidateIsHigh)
    matchingName

suppress_confluent_store_labels(level_store store, float candidatePrice, bool candidateIsHigh) =>
    int count = array.size(store.lines)
    if count > 0 and not na(candidatePrice)
        float tolerance = syminfo.mintick * 2.0
        for i = 0 to count - 1
            float storedPrice = array.get(store.prices, i)
            bool storedIsHigh = array.get(store.isHigh, i)
            bool storedVisible = array.get(store.visibleNow, i)
            bool sameSide = storedIsHigh == candidateIsHigh
            bool samePrice = math.abs(storedPrice - candidatePrice) <= tolerance

            if storedVisible and sameSide and samePrice
                label storedLabel = array.get(store.labels, i)
                if not na(storedLabel)
                    label.set_text(storedLabel, "")
                    label.set_textcolor(storedLabel, na)

arrange_level_labels(array<label> candidateLabels, array<float> candidatePrices, array<int> candidateLineEnds, array<string> candidateTexts) =>
    int count = array.size(candidateLabels)
    if count > 0
        for i = 0 to count - 1
            label currentLabel = array.get(candidateLabels, i)
            float currentPrice = array.get(candidatePrices, i)
            int currentLineEnd = array.get(candidateLineEnds, i)
            int fixedX = level_label_right_time(currentLineEnd)

            // Every label uses exactly the same rule:
            // one chart bar to the right of its own visible line end.
            label.set_x(currentLabel, fixedX)
            label.set_y(currentLabel, currentPrice)
            label.set_style(currentLabel, label.style_label_left)
            label.set_textalign(currentLabel, text.align_left)

// Swing-slot priority is based on the selected timeframe, not on slot number.
// When both swings coincide, only the higher-timeframe swing survives; its label
// does not append the lower-timeframe name.
float swing1PrioritySeconds = timeframe.in_seconds(swing1_tf)
float swing2PrioritySeconds = timeframe.in_seconds(swing2_tf)
bool swing1HasPriority = na(swing2PrioritySeconds) or (not na(swing1PrioritySeconds) and swing1PrioritySeconds >= swing2PrioritySeconds)

if swing1HasPriority
    suppress_confluent_lower(swing1Levels, swing2Levels, true, false)
else
    suppress_confluent_lower(swing2Levels, swing1Levels, true, false)

// Higher-timeframe calendar levels then absorb only the swing labels that remain visible.
suppress_confluent_lower(monthlyLevels, weeklyLevels, false, false)
suppress_confluent_lower(monthlyLevels, dailyLevels, false, false)
suppress_confluent_lower(monthlyLevels, swing1Levels, true, true)
suppress_confluent_lower(monthlyLevels, swing2Levels, true, true)
suppress_confluent_lower(weeklyLevels, dailyLevels, false, false)
suppress_confluent_lower(weeklyLevels, swing1Levels, true, true)
suppress_confluent_lower(weeklyLevels, swing2Levels, true, true)
suppress_confluent_lower(dailyLevels, swing1Levels, true, true)
suppress_confluent_lower(dailyLevels, swing2Levels, true, true)

// Final label layout: preserve exact Y price and distribute only along X.
array<label> levelLayoutLabels = array.new_label()
array<float> levelLayoutPrices = array.new_float()
array<int> levelLayoutEnds = array.new_int()
array<string> levelLayoutTexts = array.new_string()

// Current Day labels have priority over Monthly, Weekly and Daily labels.
// When they coincide with a Swing, the preferred Swing name is appended to the
// Current Day label. All prices remain included through the shared label formatter.
string currentDayHighSwingName = ""
string currentDayLowSwingName = ""

if show_current_day_hl and show_level_labels
    if swing1HasPriority
        currentDayHighSwingName := preferred_confluent_swing_name(swing1Levels, swing2Levels, dayHigh, true)
        currentDayLowSwingName := preferred_confluent_swing_name(swing1Levels, swing2Levels, dayLow, false)
    else
        currentDayHighSwingName := preferred_confluent_swing_name(swing2Levels, swing1Levels, dayHigh, true)
        currentDayLowSwingName := preferred_confluent_swing_name(swing2Levels, swing1Levels, dayLow, false)

    // Current Day dominates all calendar labels at the same price.
    suppress_confluent_store_labels(monthlyLevels, dayHigh, true)
    suppress_confluent_store_labels(weeklyLevels, dayHigh, true)
    suppress_confluent_store_labels(dailyLevels, dayHigh, true)
    suppress_confluent_store_labels(monthlyLevels, dayLow, false)
    suppress_confluent_store_labels(weeklyLevels, dayLow, false)
    suppress_confluent_store_labels(dailyLevels, dayLow, false)

    // Swing names are absorbed into the Current Day label, preventing overlap.
    suppress_confluent_store_labels(swing1Levels, dayHigh, true)
    suppress_confluent_store_labels(swing2Levels, dayHigh, true)
    suppress_confluent_store_labels(swing1Levels, dayLow, false)
    suppress_confluent_store_labels(swing2Levels, dayLow, false)

// Collect all surviving historical labels after Current Day priority is applied.
collect_level_label_candidates(monthlyLevels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)
collect_level_label_candidates(weeklyLevels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)
collect_level_label_candidates(dailyLevels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)

if swing1HasPriority
    collect_level_label_candidates(swing1Levels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)
    collect_level_label_candidates(swing2Levels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)
else
    collect_level_label_candidates(swing2Levels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)
    collect_level_label_candidates(swing1Levels, levelVisibilityDistance, levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)

// Add Current Day labels last. Their text always prevails, while an active
// confluent Swing name is appended after it.
if show_current_day_hl and show_level_labels
    if not na(currentDayHighLabel) and not na(currentDayHighLine)
        string currentDayHighBaseText = "Current Day High"
        if str.length(currentDayHighSwingName) > 0
            currentDayHighBaseText := append_level_name(currentDayHighBaseText, currentDayHighSwingName)
        string currentDayHighText = level_label_text_with_price(currentDayHighBaseText, dayHigh, show_level_prices_in_labels)
        label.set_text(currentDayHighLabel, currentDayHighText)
        label.set_textcolor(currentDayHighLabel, daily_level_color)

        array.push(levelLayoutLabels, currentDayHighLabel)
        array.push(levelLayoutPrices, dayHigh)
        array.push(levelLayoutEnds, line.get_x2(currentDayHighLine))
        array.push(levelLayoutTexts, currentDayHighText)

    if not na(currentDayLowLabel) and not na(currentDayLowLine)
        string currentDayLowBaseText = "Current Day Low"
        if str.length(currentDayLowSwingName) > 0
            currentDayLowBaseText := append_level_name(currentDayLowBaseText, currentDayLowSwingName)
        string currentDayLowText = level_label_text_with_price(currentDayLowBaseText, dayLow, show_level_prices_in_labels)
        label.set_text(currentDayLowLabel, currentDayLowText)
        label.set_textcolor(currentDayLowLabel, daily_level_color)

        array.push(levelLayoutLabels, currentDayLowLabel)
        array.push(levelLayoutPrices, dayLow)
        array.push(levelLayoutEnds, line.get_x2(currentDayLowLine))
        array.push(levelLayoutTexts, currentDayLowText)

arrange_level_labels(levelLayoutLabels, levelLayoutPrices, levelLayoutEnds, levelLayoutTexts)


// =================================================================================================
// SEPARATORS
// =================================================================================================
var array<line> daySeparators = array.new_line()
var array<line> weekSeparators = array.new_line()
var array<line> monthSeparators = array.new_line()

add_separator(bool condition, bool enabled, color separatorColor, array<line> separators) =>
    if condition and enabled
        line sep = line.new(time, high, time, low, xloc = xloc.bar_time, extend = extend.both, color = separatorColor, style = line.style_dotted, width = 1)
        array.unshift(separators, sep)
        while array.size(separators) > max_days
            line.delete(array.pop(separators))

add_separator(newTradingDay, show_day_separator, day_separator_color, daySeparators)
add_separator(newTradingWeek, show_week_separator, week_separator_color, weekSeparators)
add_separator(newTradingMonth, show_month_separator, month_separator_color, monthSeparators)

// =================================================================================================
// OPENING PRICE ENGINE
// =================================================================================================
var opening_store dailyOpenStore = new_opening_store()
var opening_store tokyoOpenStore = new_opening_store()
var opening_store londonOpenStore = new_opening_store()
var opening_store usOpenStore = new_opening_store()

clear_opening_store(opening_store store) =>
    while array.size(store.lines) > 0
        line.delete(array.pop(store.lines))
    while array.size(store.rightLines) > 0
        line.delete(array.pop(store.rightLines))
    while array.size(store.labels) > 0
        label.delete(array.pop(store.labels))
    while array.size(store.labelShown) > 0
        array.pop(store.labelShown)
    while array.size(store.revealTimes) > 0
        array.pop(store.revealTimes)
    while array.size(store.colors) > 0
        array.pop(store.colors)
    while array.size(store.names) > 0
        array.pop(store.names)

trim_opening_store(opening_store store, int maximumOpenings) =>
    while array.size(store.lines) > maximumOpenings
        line.delete(array.pop(store.lines))
        line.delete(array.pop(store.rightLines))
        label.delete(array.pop(store.labels))
        array.pop(store.labelShown)
        array.pop(store.revealTimes)
        array.pop(store.colors)
        array.pop(store.names)

update_opening_store(opening_store store, bool revealNow) =>
    if array.size(store.lines) > 0
        line leftLine = array.get(store.lines, 0)
        line rightLine = array.get(store.rightLines, 0)
        label currentLabel = array.get(store.labels, 0)
        bool shown = array.get(store.labelShown, 0)
        int revealTime = array.get(store.revealTimes, 0)
        color openingColor = array.get(store.colors, 0)
        string openingText = array.get(store.names, 0)
        int x1 = line.get_x1(leftLine)
        float price = line.get_y1(leftLine)

        if revealNow and not shown
            shown := true
            revealTime := time
            array.set(store.labelShown, 0, true)
            array.set(store.revealTimes, 0, revealTime)

        if shown
            int anchor = mid_time(x1, revealTime)
            set_split_line(leftLine, rightLine, x1, time, anchor, price, label_gap_half_width(openingText, label_gap_bars))
            line.set_color(leftLine, openingColor)
            line.set_color(rightLine, openingColor)
            label.set_x(currentLabel, anchor)
            label.set_y(currentLabel, price)
            label.set_text(currentLabel, openingText)
            label.set_textcolor(currentLabel, openingColor)
            label.set_style(currentLabel, label.style_label_center)
            label.set_textalign(currentLabel, text.align_center)
            label.set_color(currentLabel, TRANSPARENT)
        else
            // Before the next reference session begins, show one uninterrupted dotted/opening line only.
            line.set_xy1(leftLine, x1, price)
            line.set_xy2(leftLine, time, price)
            line.set_color(leftLine, openingColor)
            line.set_xy1(rightLine, time, price)
            line.set_xy2(rightLine, time, price)
            line.set_color(rightLine, na)
            label.set_text(currentLabel, "")
            label.set_textcolor(currentLabel, na)

add_opening(opening_store store, string openingName, color openingColor, bool keepHistory) =>
    // When history is enabled, the previous opening has already been updated
    // to this bar and is therefore frozen at the new same-session opening.
    // Otherwise the original latest-only behavior is preserved.
    if not keepHistory
        clear_opening_store(store)

    line leftLine = line.new(time, open, time, open, xloc = xloc.bar_time, color = openingColor, style = opening_style, width = opening_width)
    line rightLine = line.new(time, open, time, open, xloc = xloc.bar_time, color = na, style = opening_style, width = opening_width)
    label openingLabel = label.new(time, open, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_center, color = TRANSPARENT, textcolor = na, size = label_size, textalign = text.align_center, text_font_family = font.family_monospace)
    array.unshift(store.lines, leftLine)
    array.unshift(store.rightLines, rightLine)
    array.unshift(store.labels, openingLabel)
    array.unshift(store.labelShown, false)
    array.unshift(store.revealTimes, na)
    array.unshift(store.colors, openingColor)
    array.unshift(store.names, openingName)

    trim_opening_store(store, keepHistory ? max_days : 1)

int romeDayKey = calendar_day_key(time, TZ_ROME)
bool newRomeDay = not na(romeDayKey[1]) and romeDayKey != romeDayKey[1]
bool newTokyoOpen = crosses_local_time(9, 0, TZ_TOKYO)
bool newLondonOpen = crosses_local_time(8, 0, TZ_LONDON)
bool newUsOpen = crosses_local_time(8, 30, TZ_CHICAGO)

// Label-reveal triggers are intentionally independent from every Killzone toggle.
bool asiaSessionRaw = session_active(asia, gmt_tz)
bool nyAmSessionRaw = session_active(nyam, gmt_tz)
bool nyLunchSessionRaw = session_active(nylu, gmt_tz)
bool newAsiaSessionRaw = session_start(asiaSessionRaw)
bool newNyAmSessionRaw = session_start(nyAmSessionRaw)
bool newNyLunchSessionRaw = session_start(nyLunchSessionRaw)

if drawingTfOk
    // Reveal the current opening label only when its following reference session starts.
    update_opening_store(dailyOpenStore, newAsiaSessionRaw)
    update_opening_store(tokyoOpenStore, newLondonOpen)
    update_opening_store(londonOpenStore, newNyAmSessionRaw)
    update_opening_store(usOpenStore, newNyLunchSessionRaw)

    // Each opening can retain its own historical series independently.
    if show_daily_open and newRomeDay
        add_opening(dailyOpenStore, daily_open_label_text, daily_open_color, show_past_daily_opens)
    if show_tokyo_open and newTokyoOpen
        add_opening(tokyoOpenStore, tokyo_open_label_text, tokyo_open_color, show_past_tokyo_opens)
    if show_london_open and newLondonOpen
        add_opening(londonOpenStore, london_open_label_text, london_open_color, show_past_london_opens)
    if show_us_open and newUsOpen
        add_opening(usOpenStore, us_open_label_text, us_open_color, show_past_us_opens)

// =================================================================================================
// TIMESTAMPS
// =================================================================================================
var array<line> midnightTimestampLines = array.new_line()
var array<line> usTimestampLines = array.new_line()

add_timestamp(bool condition, bool enabled, color timestampColor, array<line> timestampLines) =>
    if drawingTfOk and condition and enabled
        line timestampLine = line.new(time, high, time, low, xloc = xloc.bar_time, extend = extend.both, color = timestampColor, style = timestamp_style, width = timestamp_width)
        array.unshift(timestampLines, timestampLine)
        while array.size(timestampLines) > max_days
            line.delete(array.pop(timestampLines))

add_timestamp(newRomeDay, show_midnight_timestamp, midnight_timestamp_color, midnightTimestampLines)
add_timestamp(newUsOpen, show_us_timestamp, us_timestamp_color, usTimestampLines)

// =================================================================================================
// KILLZONES & FIRST-HOUR HIGHLIGHTS
// =================================================================================================
manage_killzone(use_asia, asia, as_txt, as_color, asiaBoxes, asiaHighLines, asiaLowLines, asiaHighValid, asiaLowValid)
manage_killzone(use_london, london, lo_txt, lo_color, londonBoxes, londonHighLines, londonLowLines, londonHighValid, londonLowValid)
manage_killzone(use_nyam, nyam, na_txt, na_color, nyamBoxes, nyamHighLines, nyamLowLines, nyamHighValid, nyamLowValid)
manage_killzone(use_nylu, nylu, nl_txt, nl_color, nyluBoxes, nyluHighLines, nyluLowLines, nyluHighValid, nyluLowValid)
manage_killzone(use_nypm, nypm, np_txt, np_color, nypmBoxes, nypmHighLines, nypmLowLines, nypmHighValid, nypmLowValid)

// First-hour highlights now inherit the configured Killzone start and timezone.
// With the defaults, London is 02:00–03:00 New York, i.e. 08:00–09:00 Rome in summer.
manage_first_hour(show_tokyo_first_hour, first_hour_of_session(asia), gmt_tz, as_color, tokyoFirstHourBoxes)
manage_first_hour(show_london_first_hour, first_hour_of_session(london), gmt_tz, lo_color, londonFirstHourBoxes)

// =================================================================================================
// DAY-OF-WEEK LABELS
// =================================================================================================
int adjustedDowTime = dow_xloc == "Midday" ? time - int(timeframe.in_seconds("D") / 2.0 * 1000.0) : time
bool isNewDow = dayofweek(adjustedDowTime, gmt_tz) != dayofweek(adjustedDowTime, gmt_tz)[1]
bool dowAtTop = dow_yloc == "Top"

plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.sunday and isNewDow and not dow_hide_wknd, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "SUNDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.monday and isNewDow, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "MONDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.tuesday and isNewDow, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "TUESDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.wednesday and isNewDow, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "WEDNESDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.thursday and isNewDow, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "THURSDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.friday and isNewDow, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "FRIDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(adjustedDowTime, gmt_tz) == dayofweek.saturday and isNewDow and not dow_hide_wknd, location = dowAtTop ? location.top : location.bottom, char = "", textcolor = txt_color, text = "SATURDAY")

// =================================================================================================
// INITIAL BALANCE USA — 08:30–09:30 AMERICA/CHICAGO
// Adapted from Initial Balance Wave Map.
// Released under the Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
// © 2025 Drysdale Trading Group
// =================================================================================================
float ibTfLimitSeconds = timeframe.in_seconds(ib_tf_limit)
bool ibTfAligns = not na(chartTfSeconds) and chartTfSeconds > 0 and 1800 % chartTfSeconds == 0
bool ibTfOk = not ib_tf_filter or (timeframe.isintraday and not na(ibTfLimitSeconds) and chartTfSeconds <= ibTfLimitSeconds and ibTfAligns)
bool ibActive = show_ib and ibTfOk and session_active("0830-0930", TZ_CHICAGO)
bool ibStarts = session_start(ibActive)
bool ibEnds = not ibActive and ibActive[1]

bgcolor(shadeWindow and ibActive ? color.new(#673AB7, 80) : na)

var float ibHigh = na
var float ibLow = na
var int ibStartTime = na
var array<float> ibDeltaBuffer = array.new_float()
var float ibDelta = na
var array<ib_set> ibHistory = array.new<ib_set>()

clear_ib_set(ib_set setToDelete, bool deleteZone) =>
    int lineCount = array.size(setToDelete.lines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            line.delete(array.get(setToDelete.lines, i))
    int labelCount = array.size(setToDelete.labels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            label.delete(array.get(setToDelete.labels, i))
    if deleteZone and not na(setToDelete.zone)
        box.delete(setToDelete.zone)

clear_all_ib_history() =>
    int historyCount = array.size(ibHistory)
    if historyCount > 0
        for i = historyCount - 1 to 0
            ib_set oldSet = array.get(ibHistory, i)
            clear_ib_set(oldSet, true)
            array.remove(ibHistory, i)

clear_old_ib_zones() =>
    int historyCount = array.size(ibHistory)
    if historyCount > 0
        for i = 0 to historyCount - 1
            ib_set existingSet = array.get(ibHistory, i)
            if not na(existingSet.zone)
                box.delete(existingSet.zone)
                existingSet.zone := na

trim_ib_history() =>
    while array.size(ibHistory) > max_days
        ib_set oldestSet = array.pop(ibHistory)
        clear_ib_set(oldestSet, true)

set_ib_right_edge(ib_set targetSet, int stopTime) =>
    int lineCount = array.size(targetSet.lines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            line.set_x2(array.get(targetSet.lines, i), stopTime)

ib_cash_close_time(int startTime) =>
    timestamp(TZ_CHICAGO, year(startTime, TZ_CHICAGO), month(startTime, TZ_CHICAGO), dayofmonth(startTime, TZ_CHICAGO), 15, 0)

close_previous_ib_at_next_start(int stopTime) =>
    if array.size(ibHistory) > 0
        ib_set latestSet = array.get(ibHistory, 0)
        if latestSet.extendToNextIb and not latestSet.rightClosed
            set_ib_right_edge(latestSet, stopTime)
            latestSet.rightClosed := true

update_latest_ib_right_edge() =>
    bool changed = false
    if array.size(ibHistory) > 0
        ib_set latestSet = array.get(ibHistory, 0)
        if not latestSet.rightClosed
            if latestSet.extendToNextIb
                // The line remains live overnight, but is explicitly capped by
                // close_previous_ib_at_next_start() at the next 08:30 Chicago.
                set_ib_right_edge(latestSet, time_close)
                changed := true
            else
                // Without right extension, all IB levels remain visible through
                // the full US cash session and stop exactly at 15:00 Chicago.
                int cashClose = ib_cash_close_time(latestSet.startTime)
                set_ib_right_edge(latestSet, math.min(time_close, cashClose))
                changed := true
                if time >= cashClose
                    latestSet.rightClosed := true
    changed

if ibStarts
    // Right-extended levels from yesterday stop at the exact beginning of the
    // new Initial Balance, never beyond it.
    close_previous_ib_at_next_start(time)
    ibHigh := high
    ibLow := low
    ibStartTime := time
else if ibActive
    ibHigh := math.max(ibHigh, high)
    ibLow := math.min(ibLow, low)

if ibEnds and not na(ibHigh) and not na(ibLow) and not na(ibStartTime)
    int ibEndTime = time
    float ibMid = math.avg(ibHigh, ibLow)
    ibDelta := ibHigh - ibLow

    array.push(ibDeltaBuffer, ibDelta)
    if array.size(ibDeltaBuffer) > 20
        array.shift(ibDeltaBuffer)

    if thisDayOnly
        clear_all_ib_history()
    else if shadeZones and thisZoneOnly
        clear_old_ib_zones()

    array<line> newLines = array.new_line()
    array<label> newLabels = array.new_label()
    box newZone = na

    line ibHighLine = line.new(ibStartTime, ibHigh, ibEndTime, ibHigh, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrHigh, style = mainIbStyle)
    line ibLowLine = line.new(ibStartTime, ibLow, ibEndTime, ibLow, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrLow, style = mainIbStyle)
    array.push(newLines, ibHighLine)
    array.push(newLines, ibLowLine)

    if drawMidPoints
        line ibMidLine = line.new(ibStartTime, ibMid, ibEndTime, ibMid, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrMid, style = midIbStyle)
        array.push(newLines, ibMidLine)

    if drawExtras
        line ibHigh2Line = line.new(ibStartTime, ibHigh + ibDelta, ibEndTime, ibHigh + ibDelta, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrHigh, style = extIbStyle)
        line ibLow2Line = line.new(ibStartTime, ibLow - ibDelta, ibEndTime, ibLow - ibDelta, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrLow, style = extIbStyle)
        line ibHigh3Line = line.new(ibStartTime, ibHigh + ibDelta * 2.0, ibEndTime, ibHigh + ibDelta * 2.0, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrHigh, style = extIbStyle)
        line ibLow3Line = line.new(ibStartTime, ibLow - ibDelta * 2.0, ibEndTime, ibLow - ibDelta * 2.0, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrLow, style = extIbStyle)
        array.push(newLines, ibHigh2Line)
        array.push(newLines, ibLow2Line)
        array.push(newLines, ibHigh3Line)
        array.push(newLines, ibLow3Line)

        if drawMidPoints
            line ibHighMidLine = line.new(ibStartTime, ibHigh + ibDelta / 2.0, ibEndTime, ibHigh + ibDelta / 2.0, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrMid, style = midIbStyle)
            line ibLowMidLine = line.new(ibStartTime, ibLow - ibDelta / 2.0, ibEndTime, ibLow - ibDelta / 2.0, xloc = xloc.bar_time, width = ibLineWidth, extend = ibLeftExtend, color = clrMid, style = midIbStyle)
            array.push(newLines, ibHighMidLine)
            array.push(newLines, ibLowMidLine)

    if renderLabels
        label highLabel = label.new(ibStartTime, ibHigh, "IB High\n" + str.tostring(ibHigh, format.mintick), xloc = xloc.bar_time, textcolor = clrHigh, style = label.style_none, size = ibLabelSize)
        label lowLabel = label.new(ibStartTime, ibLow, "IB Low\n" + str.tostring(ibLow, format.mintick), xloc = xloc.bar_time, textcolor = clrLow, style = label.style_none, size = ibLabelSize)
        array.push(newLabels, highLabel)
        array.push(newLabels, lowLabel)

        if drawMidPoints
            label midLabel = label.new(ibStartTime, ibMid, "Mid 50%\n" + str.tostring(ibMid, format.mintick) + "\nΔ=" + str.tostring(ibDelta, format.mintick), xloc = xloc.bar_time, textcolor = clrMid, style = label.style_none, size = ibLabelSize)
            array.push(newLabels, midLabel)

        if drawExtras
            label high2Label = label.new(ibStartTime, ibHigh + ibDelta, "High x2\n" + str.tostring(ibHigh + ibDelta, format.mintick), xloc = xloc.bar_time, textcolor = clrHigh, style = label.style_none, size = ibLabelSize)
            label low2Label = label.new(ibStartTime, ibLow - ibDelta, "Low x2\n" + str.tostring(ibLow - ibDelta, format.mintick), xloc = xloc.bar_time, textcolor = clrLow, style = label.style_none, size = ibLabelSize)
            label high3Label = label.new(ibStartTime, ibHigh + ibDelta * 2.0, "High x3\n" + str.tostring(ibHigh + ibDelta * 2.0, format.mintick), xloc = xloc.bar_time, textcolor = clrHigh, style = label.style_none, size = ibLabelSize)
            label low3Label = label.new(ibStartTime, ibLow - ibDelta * 2.0, "Low x3\n" + str.tostring(ibLow - ibDelta * 2.0, format.mintick), xloc = xloc.bar_time, textcolor = clrLow, style = label.style_none, size = ibLabelSize)
            array.push(newLabels, high2Label)
            array.push(newLabels, low2Label)
            array.push(newLabels, high3Label)
            array.push(newLabels, low3Label)

            if drawMidPoints
                label highMidLabel = label.new(ibStartTime, ibHigh + ibDelta / 2.0, "High +½Δ", xloc = xloc.bar_time, textcolor = clrMid, style = label.style_none, size = ibLabelSize)
                label lowMidLabel = label.new(ibStartTime, ibLow - ibDelta / 2.0, "Low −½Δ", xloc = xloc.bar_time, textcolor = clrMid, style = label.style_none, size = ibLabelSize)
                array.push(newLabels, highMidLabel)
                array.push(newLabels, lowMidLabel)

    if shadeZones
        newZone := box.new(ibStartTime, ibHigh, ibEndTime, ibLow, xloc = xloc.bar_time, bgcolor = zoneTint, border_color = TRANSPARENT)

    array.unshift(ibHistory, ib_set.new(newLines, newLabels, newZone, ibStartTime, ibContinueUntilNext, false))
    trim_ib_history()

    ibHigh := na
    ibLow := na
    ibStartTime := na

// Extend the newest completed IB according to the selected policy. These
// levels never stop because of mitigation or a price break.
update_latest_ib_right_edge()

// When NY AM and the current US IB share the same high or low, suppress the
// underlying NY AM pivot so the green/red IB levels remain visually dominant.
apply_ib_priority_over_nyam() =>
    int nyCount = array.size(nyamHighLines)
    int historyCount = array.size(ibHistory)
    float tolerance = syminfo.mintick * 1.0
    line latestIbHigh = na
    line latestIbLow = na
    if historyCount > 0
        ib_set latestSet = array.get(ibHistory, 0)
        if array.size(latestSet.lines) >= 2
            latestIbHigh := array.get(latestSet.lines, 0)
            latestIbLow := array.get(latestSet.lines, 1)
    if nyCount > 0
        for i = 0 to nyCount - 1
            line nyHigh = array.get(nyamHighLines, i)
            line nyLow = array.get(nyamLowLines, i)
            bool overlapHigh = not na(latestIbHigh) and math.abs(line.get_y1(nyHigh) - line.get_y1(latestIbHigh)) <= tolerance
            bool overlapLow = not na(latestIbLow) and math.abs(line.get_y1(nyLow) - line.get_y1(latestIbLow)) <= tolerance
            line.set_color(nyHigh, overlapHigh ? na : na_color)
            line.set_color(nyLow, overlapLow ? na : na_color)

apply_ib_priority_over_nyam()

ib_sentiment() =>
    if array.size(ibDeltaBuffer) == 0 or na(ibDelta)
        "N/A"
    else
        float maxDelta = array.max(ibDeltaBuffer)
        float minDelta = array.min(ibDeltaBuffer)
        float avgDelta = array.avg(ibDeltaBuffer)
        float distanceMax = math.abs(ibDelta - maxDelta)
        float distanceMin = math.abs(ibDelta - minDelta)
        float distanceAvg = math.abs(ibDelta - avgDelta)
        distanceMax < distanceMin and distanceMax < distanceAvg ? "Wide" : distanceMin < distanceMax and distanceMin < distanceAvg ? "Narrow" : "Average"

var table statTbl = table.new(position.bottom_left, 2, 6)
if barstate.islast and showDeltaInfo and ibTfOk
    string sampleText = str.tostring(array.size(ibDeltaBuffer))
    table.cell(statTbl, 0, 0, "IB-Δ Stats (" + sampleText + ")", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 0, "", bgcolor = color.black)
    table.cell(statTbl, 0, 1, "20-session Max", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 1, array.size(ibDeltaBuffer) > 0 ? str.tostring(array.max(ibDeltaBuffer), format.mintick) : "N/A", bgcolor = color.black, text_color = clrHigh)
    table.cell(statTbl, 0, 2, "20-session Mean", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 2, array.size(ibDeltaBuffer) > 0 ? str.tostring(array.avg(ibDeltaBuffer), format.mintick) : "N/A", bgcolor = color.black, text_color = clrMid)
    table.cell(statTbl, 0, 3, "20-session Min", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 3, array.size(ibDeltaBuffer) > 0 ? str.tostring(array.min(ibDeltaBuffer), format.mintick) : "N/A", bgcolor = color.black, text_color = clrLow)
    table.cell(statTbl, 0, 4, "Current Δ", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 4, not na(ibDelta) ? str.tostring(ibDelta, format.mintick) : "N/A", bgcolor = color.black, text_color = #42A5F5)
    table.cell(statTbl, 0, 5, "Status", bgcolor = color.black, text_color = color.white)
    table.cell(statTbl, 1, 5, ib_sentiment(), bgcolor = color.black, text_color = color.white)
````
