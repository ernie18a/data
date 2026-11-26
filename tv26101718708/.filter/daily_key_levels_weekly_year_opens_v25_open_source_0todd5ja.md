# Daily Key Levels + Weekly Year Opens v2.5 OPEN SOURCE

- url: https://www.tradingview.com/script/0tOdD5Ja-Daily-Key-Levels-Weekly-Year-Opens-v2-5-OPEN-SOURCE/
- type: indicator
- pine_id: PUB;b28dbc20995d408e8deb00b1e6d4f581
- version: 1.0

## Description

[b]DAILY KEY LEVELS + WEEKLY YEAR OPENS[/b]

[i]A clean higher-timeframe map that automatically changes with the chart.[/i]

[b]AUTOMATIC DAILY AND WEEKLY PROFILES[/b]

This indicator is built specifically for [b]1D and 1W charts[/b]. It detects the chart timeframe and switches profiles automatically.

On a [b]1D chart[/b], it displays the important weekly and monthly levels, the daily moving averages, and the Daily Trend + Level Map.

When the chart is changed to [b]1W[/b], the daily profile is removed and the indicator automatically switches to the yearly-open profile. No manual setting changes are required when moving between daily and weekly charts.

On other timeframes, a small notice appears instead of displaying the wrong profile.

[b]DAILY CHART PROFILE[/b]

The daily chart includes [b]Previous Month High and Low[/b], [b]Current Month High and Low[/b], and [b]Previous Week High and Low[/b]. It also plots the [b]20 EMA[/b] in white, [b]50 SMA[/b] in red, and [b]200 SMA[/b] in blue.

Previous week and previous month levels are confirmed after those periods close. Current month levels continue developing as the month trades.

The compact dashboard adds practical context without taking over the chart. It shows:

[b]Trend[/b], based on price location and the exact order of the 20 EMA, 50 SMA, and 200 SMA.

[b]Momentum / Stretch[/b], including the direction of the 20 EMA and 50 SMA and price's distance from the 20 EMA in ATR units.

[b]ATR / Stop Distance[/b], showing the current daily ATR plus 2x and 3x ATR reference distances. These are volatility measurements, not automatic stop recommendations.

[b]Previous Week and Previous Month[/b], showing whether price is above, below, or inside each completed range.

[b]Nearest Above, Nearest Below, and Nearest Confluence[/b], identifying the closest enabled levels and measuring their distance in daily ATR.

[b]WEEKLY CHART PROFILE[/b]

On a weekly chart, the indicator automatically displays the [b]current yearly open and the previous four yearly opens[/b].

By default, all yearly opens extend into the current chart area and include the calendar year and exact price. An optional [b]Year Segments[/b] mode is available for traders who prefer each open to remain within its original calendar year.

[b]PURPOSE[/b]

The daily profile provides a clear view of trend structure, volatility, nearby support and resistance, and level confluence. The weekly profile provides a simple long-term map of yearly opening prices.

Levels, colors, labels, moving averages, ATR settings, confluence distance, and dashboard placement can all be customized.

## Source Code

````pine
//@version=6
indicator("Daily Key Levels + Weekly Year Opens v2.5 OPEN SOURCE", shorttitle = "HTF Levels", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ============================================================================
// DISPLAY
// ============================================================================
string GROUP_DISPLAY = "Display"
bool enableDailyProfile = input.bool(true, "Enable Daily Profile", group = GROUP_DISPLAY)
bool enableWeeklyProfile = input.bool(true, "Enable Weekly Profile", group = GROUP_DISPLAY)
bool showTimeframeNotice = input.bool(true, "Show 1D / 1W Timeframe Notice", group = GROUP_DISPLAY)

bool isOneDayChart = timeframe.isdaily and timeframe.multiplier == 1
bool isOneWeekChart = timeframe.isweekly and timeframe.multiplier == 1
bool showDailyProfile = enableDailyProfile and isOneDayChart
bool showWeeklyProfile = enableWeeklyProfile and isOneWeekChart

// ============================================================================
// DAILY CHART: IMPORTANT LEVELS
// ============================================================================
string GROUP_LEVELS = "Daily Chart: Important Levels"
bool showPreviousMonth = input.bool(true, "Previous Month High / Low", group = GROUP_LEVELS)
bool showCurrentMonth = input.bool(true, "Current Month High / Low", group = GROUP_LEVELS)
bool showPreviousWeek = input.bool(true, "Previous Week High / Low", group = GROUP_LEVELS)
bool showLevelLabels = input.bool(true, "Show Level Labels", group = GROUP_LEVELS)
bool includePriceInLabels = input.bool(true, "Include Price in Labels", group = GROUP_LEVELS)
color previousMonthColor = input.color(color.red, "Previous Month Color", group = GROUP_LEVELS)
color currentMonthColor = input.color(color.teal, "Current Month Color", group = GROUP_LEVELS)
color previousWeekColor = input.color(color.yellow, "Previous Week Color", group = GROUP_LEVELS)
string levelLineStyleInput = input.string("Solid", "Level Line Style", options = ["Solid", "Dashed", "Dotted"], group = GROUP_LEVELS)
int levelLineWidth = input.int(1, "Level Line Width", minval = 1, maxval = 5, group = GROUP_LEVELS)
int levelLabelOffset = input.int(8, "Level Label Offset", minval = 1, maxval = 100, group = GROUP_LEVELS)

levelLineStyle = levelLineStyleInput == "Dashed" ? line.style_dashed : levelLineStyleInput == "Dotted" ? line.style_dotted : line.style_solid

// ============================================================================
// DAILY CHART: MOVING AVERAGES
// ============================================================================
string GROUP_MAS = "Daily Chart: Moving Averages"
bool showEMA20 = input.bool(true, "Show 20 EMA", group = GROUP_MAS)
bool showSMA50 = input.bool(true, "Show 50 SMA", group = GROUP_MAS)
bool showSMA200 = input.bool(true, "Show 200 SMA", group = GROUP_MAS)
color ema20Color = input.color(color.white, "20 EMA Color", group = GROUP_MAS)
color sma50Color = input.color(color.red, "50 SMA Color", group = GROUP_MAS)
color sma200Color = input.color(color.blue, "200 SMA Color", group = GROUP_MAS)
int ema20Width = input.int(2, "20 EMA Width", minval = 1, maxval = 5, group = GROUP_MAS)
int sma50Width = input.int(2, "50 SMA Width", minval = 1, maxval = 5, group = GROUP_MAS)
int sma200Width = input.int(2, "200 SMA Width", minval = 1, maxval = 5, group = GROUP_MAS)

// ============================================================================
// DAILY CHART: COMPACT TREND + LEVEL MAP
// ============================================================================
string GROUP_DAILY_MAP = "Daily Chart: Trend + Level Map"
bool showDailyMap = input.bool(true, "Show Daily Trend and Level Map", group = GROUP_DAILY_MAP)
int dailyAtrLength = input.int(14, "ATR Length", minval = 1, group = GROUP_DAILY_MAP)
int slopeLookback = input.int(5, "MA Slope Lookback (Daily Bars)", minval = 1, maxval = 100, group = GROUP_DAILY_MAP)
float confluenceThresholdAtr = input.float(0.20, "Confluence Distance (ATR)", minval = 0.01, maxval = 2.00, step = 0.01, group = GROUP_DAILY_MAP)
string dashboardPositionInput = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GROUP_DAILY_MAP)
string dashboardTextSizeInput = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = GROUP_DAILY_MAP)

string mapPosition = dashboardPositionInput == "Bottom Right" ? position.bottom_right : dashboardPositionInput == "Top Left" ? position.top_left : dashboardPositionInput == "Bottom Left" ? position.bottom_left : position.top_right
string mapTextSize = dashboardTextSizeInput == "Tiny" ? size.tiny : dashboardTextSizeInput == "Normal" ? size.normal : size.small

// ============================================================================
// WEEKLY CHART: YEARLY OPENS
// ============================================================================
string GROUP_YEARLY = "Weekly Chart: Yearly Opens"
bool showCurrentYearOpen = input.bool(true, "Current Year Open", group = GROUP_YEARLY)
bool showOneYearBackOpen = input.bool(true, "1 Year Back Open", group = GROUP_YEARLY)
bool showTwoYearsBackOpen = input.bool(true, "2 Years Back Open", group = GROUP_YEARLY)
bool showThreeYearsBackOpen = input.bool(true, "3 Years Back Open", group = GROUP_YEARLY)
bool showFourYearsBackOpen = input.bool(true, "4 Years Back Open", group = GROUP_YEARLY)
bool showYearOpenLabels = input.bool(true, "Show Year Open Labels", group = GROUP_YEARLY)
string yearlyOpenMode = input.string("Extend all to current", "Year Open Display", options = ["Extend all to current", "Year segments"], group = GROUP_YEARLY)
int yearlyOpenWidth = input.int(2, "Year Open Width", minval = 1, maxval = 5, group = GROUP_YEARLY)
int yearlyLabelOffset = input.int(8, "Right Label Offset", minval = 1, maxval = 100, group = GROUP_YEARLY)
color currentYearOpenColor = input.color(color.blue, "Current Year Color", group = GROUP_YEARLY)
color oneYearBackOpenColor = input.color(#c402c4, "1 Year Back Color", group = GROUP_YEARLY)
color twoYearsBackOpenColor = input.color(color.green, "2 Years Back Color", group = GROUP_YEARLY)
color threeYearsBackOpenColor = input.color(color.orange, "3 Years Back Color", group = GROUP_YEARLY)
color fourYearsBackOpenColor = input.color(color.purple, "4 Years Back Color", group = GROUP_YEARLY)

// ============================================================================
// HELPERS
// ============================================================================
f_level_is_valid(float value) =>
    not na(value) and math.abs(value) >= syminfo.mintick

f_level_text(string name, float value) =>
    includePriceInLabels ? name + "  " + str.tostring(value, format.mintick) : name

f_update_ray(line id, bool showIt, int x1, float y, color lineColor, string lineStyle, int width) =>
    line out = id
    if showIt and not na(x1) and f_level_is_valid(y)
        int x2 = math.max(time, x1 + 86400000)
        if na(out)
            out := line.new(x1, y, x2, y, xloc = xloc.bar_time, extend = extend.right, color = lineColor, style = lineStyle, width = width)
        else
            line.set_xy1(out, x1, y)
            line.set_xy2(out, x2, y)
            line.set_extend(out, extend.right)
            line.set_color(out, lineColor)
            line.set_style(out, lineStyle)
            line.set_width(out, width)
    else if not na(out)
        line.delete(out)
        out := na
    out

f_update_segment(line id, bool showIt, int x1, int x2, float y, color lineColor, int width, bool extendRight) =>
    line out = id
    if showIt and not na(x1) and not na(x2) and f_level_is_valid(y)
        int safeX2 = math.max(x2, x1 + 604800000)
        if na(out)
            out := line.new(x1, y, safeX2, y, xloc = xloc.bar_time, extend = extendRight ? extend.right : extend.none, color = lineColor, style = line.style_solid, width = width)
        else
            line.set_xy1(out, x1, y)
            line.set_xy2(out, safeX2, y)
            line.set_extend(out, extendRight ? extend.right : extend.none)
            line.set_color(out, lineColor)
            line.set_style(out, line.style_solid)
            line.set_width(out, width)
    else if not na(out)
        line.delete(out)
        out := na
    out

f_update_right_label(label id, bool showIt, float y, string labelText, color textColor, int offset) =>
    label out = id
    if showIt and f_level_is_valid(y)
        if na(out)
            out := label.new(bar_index + offset, y, labelText, xloc = xloc.bar_index, style = label.style_none, textcolor = textColor)
        else
            label.set_x(out, bar_index + offset)
            label.set_y(out, y)
            label.set_text(out, labelText)
            label.set_style(out, label.style_none)
            label.set_textcolor(out, textColor)
    else if not na(out)
        label.delete(out)
        out := na
    out

f_update_time_label(label id, bool showIt, int x, float y, string labelText, color textColor) =>
    label out = id
    if showIt and not na(x) and f_level_is_valid(y)
        if na(out)
            out := label.new(x, y, labelText, xloc = xloc.bar_time, style = label.style_none, textcolor = textColor)
        else
            label.set_x(out, x)
            label.set_y(out, y)
            label.set_text(out, labelText)
            label.set_style(out, label.style_none)
            label.set_textcolor(out, textColor)
    else if not na(out)
        label.delete(out)
        out := na
    out

// Trend codes are ordered by structure quality, not merely by price vs the 200 SMA.
// The 50 SMA vs 200 SMA defines the long-term structure.
// The 20 EMA vs 50 SMA defines the short-term structure.
// Current price then determines whether that structure is trending, pulling back, weakening,
// under pressure, or fully lost.
//
// This prevents a damaged bullish structure from appearing stronger than an intact bull pullback.
//  10 = bull trend, 9 = bull pullback, 8 = bull trend repairing,
//   7 = deep bull pullback, 6 = bull trend weakening,
//   5 = bull trend under pressure, 4 = bull structure lost.
// Negative codes mirror the same logic for bearish structures.
f_trend_code(float price, float ema20, float sma50, float sma200) =>
    int result = 0
    if not na(price) and not na(ema20) and not na(sma50) and not na(sma200)
        bool longTermBull = sma50 > sma200
        bool longTermBear = sma50 < sma200
        bool shortTermBull = ema20 > sma50
        bool shortTermBear = ema20 < sma50

        if longTermBull
            if shortTermBull
                // Fully aligned bullish structure: 20 EMA > 50 SMA > 200 SMA.
                if price > ema20
                    result := 10
                else if price >= sma50
                    result := 9
                else if price >= sma200
                    result := 7
                else
                    result := 4
            else
                // The 20 EMA has crossed below the 50 SMA while the 50 remains above the 200.
                if price > sma50
                    result := 8
                else if price >= ema20 and price >= sma200
                    result := 6
                else if price >= sma200
                    result := 5
                else
                    result := 4
        else if longTermBear
            if shortTermBear
                // Fully aligned bearish structure: 20 EMA < 50 SMA < 200 SMA.
                if price < ema20
                    result := -10
                else if price <= sma50
                    result := -9
                else if price <= sma200
                    result := -7
                else
                    result := -4
            else
                // The 20 EMA has crossed above the 50 SMA while the 50 remains below the 200.
                if price < sma50
                    result := -8
                else if price <= ema20 and price <= sma200
                    result := -6
                else if price <= sma200
                    result := -5
                else
                    result := -4
        else
            result := price >= sma200 ? 1 : -1
    result

f_trend_name(int code) =>
    code == 10 ? "Bull Trend" :
     code == 9 ? "Bull Pullback" :
     code == 8 ? "Bull Trend Repairing" :
     code == 7 ? "Deep Bull Pullback" :
     code == 6 ? "Bull Trend Weakening" :
     code == 5 ? "Bull Trend Under Pressure" :
     code == 4 ? "Bull Structure Lost" :
     (code == 1 or code == -1) ? "Neutral Transition" :
     code == -4 ? "Bear Structure Lost" :
     code == -5 ? "Bear Trend Under Pressure" :
     code == -6 ? "Bear Trend Weakening" :
     code == -7 ? "Deep Bear Rally" :
     code == -8 ? "Bear Trend Reasserting" :
     code == -9 ? "Bear Rally" :
     code == -10 ? "Bear Trend" : "Unavailable"

f_trend_color(int code) =>
    code == 10 ? color.lime :
     code == 9 ? color.green :
     code == 8 ? color.olive :
     code == 7 ? color.orange :
     code == 6 ? color.rgb(190, 105, 0) :
     code == 5 ? color.maroon :
     code == 4 ? color.red :
     code == -4 ? color.green :
     code == -5 ? color.teal :
     code == -6 ? color.olive :
     code == -7 ? color.orange :
     code == -8 ? color.rgb(150, 55, 55) :
     code == -9 ? color.maroon :
     code == -10 ? color.red : color.gray

// Show the actual moving-average order instead of the vague word "Mixed".
f_stack_text(float ema20, float sma50, float sma200) =>
    string result = "Unavailable"
    if not na(ema20) and not na(sma50) and not na(sma200)
        if ema20 >= sma50 and sma50 >= sma200
            result := "20 > 50 > 200"
        else if sma50 >= ema20 and ema20 >= sma200
            result := "50 > 20 > 200"
        else if sma50 >= sma200 and sma200 >= ema20
            result := "50 > 200 > 20"
        else if ema20 >= sma200 and sma200 >= sma50
            result := "20 > 200 > 50"
        else if sma200 >= ema20 and ema20 >= sma50
            result := "200 > 20 > 50"
        else
            result := "200 > 50 > 20"
    result

f_slope_text(float currentValue, float pastValue) =>
    na(currentValue) or na(pastValue) ? "n/a" : currentValue > pastValue ? "Up" : currentValue < pastValue ? "Down" : "Flat"

f_range_state(float price, float rangeHigh, float rangeLow, float atrValue) =>
    string result = "Unavailable"
    if not na(price) and f_level_is_valid(rangeHigh) and f_level_is_valid(rangeLow) and rangeHigh > rangeLow
        if price > rangeHigh
            float aboveDistance = not na(atrValue) and atrValue > 0 ? (price - rangeHigh) / atrValue : na
            result := "Above High" + (na(aboveDistance) ? "" : " | +" + str.tostring(aboveDistance, "#.00") + " ATR")
        else if price < rangeLow
            float belowDistance = not na(atrValue) and atrValue > 0 ? (rangeLow - price) / atrValue : na
            result := "Below Low" + (na(belowDistance) ? "" : " | -" + str.tostring(belowDistance, "#.00") + " ATR")
        else
            float rangePosition = (price - rangeLow) / (rangeHigh - rangeLow) * 100.0
            result := "Inside | " + str.tostring(rangePosition, "#.0") + "% from low"
    result

f_range_color(float price, float rangeHigh, float rangeLow) =>
    not na(price) and f_level_is_valid(rangeHigh) and price > rangeHigh ? color.green : not na(price) and f_level_is_valid(rangeLow) and price < rangeLow ? color.red : color.gray

f_distance_text(string name, float level, float price, float atrValue) =>
    if not f_level_is_valid(level) or na(price)
        "None"
    else
        float atrDistance = not na(atrValue) and atrValue > 0 ? math.abs(level - price) / atrValue : na
        name + " @ " + str.tostring(level, format.mintick) + (na(atrDistance) ? "" : " | " + str.tostring(atrDistance, "#.00") + " ATR")

// ============================================================================
// DAILY PROFILE CALCULATIONS
// ============================================================================
[previousMonthHigh, previousMonthLow, previousMonthStart] = request.security(
     syminfo.tickerid,
     "M",
     [high[1], low[1], time[1]],
     lookahead = barmerge.lookahead_on)

[previousWeekHigh, previousWeekLow, previousWeekStart] = request.security(
     syminfo.tickerid,
     "W",
     [high[1], low[1], time[1]],
     lookahead = barmerge.lookahead_on)

bool newMonth = timeframe.change("M")
var float currentMonthHigh = na
var float currentMonthLow = na
var int currentMonthStart = na

if isOneDayChart
    if newMonth or na(currentMonthHigh) or na(currentMonthLow)
        currentMonthHigh := high
        currentMonthLow := low
        currentMonthStart := time("M")
    else
        currentMonthHigh := math.max(currentMonthHigh, high)
        currentMonthLow := math.min(currentMonthLow, low)

float dailyEMA20 = ta.ema(close, 20)
float dailySMA50 = ta.sma(close, 50)
float dailySMA200 = ta.sma(close, 200)
float dailyATR = ta.atr(dailyAtrLength)

plot(showDailyProfile and showEMA20 ? dailyEMA20 : na, "Daily 20 EMA", color = ema20Color, linewidth = ema20Width, display = display.all - display.status_line)
plot(showDailyProfile and showSMA50 ? dailySMA50 : na, "Daily 50 SMA", color = sma50Color, linewidth = sma50Width, display = display.all - display.status_line)
plot(showDailyProfile and showSMA200 ? dailySMA200 : na, "Daily 200 SMA", color = sma200Color, linewidth = sma200Width, display = display.all - display.status_line)

var line previousMonthHighLine = na
var line previousMonthLowLine = na
var line currentMonthHighLine = na
var line currentMonthLowLine = na
var line previousWeekHighLine = na
var line previousWeekLowLine = na

var label previousMonthHighLabel = na
var label previousMonthLowLabel = na
var label currentMonthHighLabel = na
var label currentMonthLowLabel = na
var label previousWeekHighLabel = na
var label previousWeekLowLabel = na

if barstate.islast
    bool drawPreviousMonth = showDailyProfile and showPreviousMonth
    bool drawCurrentMonth = showDailyProfile and showCurrentMonth
    bool drawPreviousWeek = showDailyProfile and showPreviousWeek

    previousMonthHighLine := f_update_ray(previousMonthHighLine, drawPreviousMonth, previousMonthStart, previousMonthHigh, previousMonthColor, levelLineStyle, levelLineWidth)
    previousMonthLowLine := f_update_ray(previousMonthLowLine, drawPreviousMonth, previousMonthStart, previousMonthLow, previousMonthColor, levelLineStyle, levelLineWidth)
    currentMonthHighLine := f_update_ray(currentMonthHighLine, drawCurrentMonth, currentMonthStart, currentMonthHigh, currentMonthColor, levelLineStyle, levelLineWidth)
    currentMonthLowLine := f_update_ray(currentMonthLowLine, drawCurrentMonth, currentMonthStart, currentMonthLow, currentMonthColor, levelLineStyle, levelLineWidth)
    previousWeekHighLine := f_update_ray(previousWeekHighLine, drawPreviousWeek, previousWeekStart, previousWeekHigh, previousWeekColor, levelLineStyle, levelLineWidth)
    previousWeekLowLine := f_update_ray(previousWeekLowLine, drawPreviousWeek, previousWeekStart, previousWeekLow, previousWeekColor, levelLineStyle, levelLineWidth)

    previousMonthHighLabel := f_update_right_label(previousMonthHighLabel, drawPreviousMonth and showLevelLabels, previousMonthHigh, f_level_text("Prev Month High", previousMonthHigh), previousMonthColor, levelLabelOffset)
    previousMonthLowLabel := f_update_right_label(previousMonthLowLabel, drawPreviousMonth and showLevelLabels, previousMonthLow, f_level_text("Prev Month Low", previousMonthLow), previousMonthColor, levelLabelOffset)
    currentMonthHighLabel := f_update_right_label(currentMonthHighLabel, drawCurrentMonth and showLevelLabels, currentMonthHigh, f_level_text("Curr Month High", currentMonthHigh), currentMonthColor, levelLabelOffset)
    currentMonthLowLabel := f_update_right_label(currentMonthLowLabel, drawCurrentMonth and showLevelLabels, currentMonthLow, f_level_text("Curr Month Low", currentMonthLow), currentMonthColor, levelLabelOffset)
    previousWeekHighLabel := f_update_right_label(previousWeekHighLabel, drawPreviousWeek and showLevelLabels, previousWeekHigh, f_level_text("Prev Week High", previousWeekHigh), previousWeekColor, levelLabelOffset)
    previousWeekLowLabel := f_update_right_label(previousWeekLowLabel, drawPreviousWeek and showLevelLabels, previousWeekLow, f_level_text("Prev Week Low", previousWeekLow), previousWeekColor, levelLabelOffset)

// ============================================================================
// WEEKLY PROFILE CALCULATIONS
// ============================================================================
[yearOpen0, yearStart0, yearOpen1, yearStart1, yearOpen2, yearStart2, yearOpen3, yearStart3, yearOpen4, yearStart4] = request.security(
     syminfo.tickerid,
     "12M",
     [open, time, open[1], time[1], open[2], time[2], open[3], time[3], open[4], time[4]],
     lookahead = barmerge.lookahead_on)

int currentYearNumber = not na(yearStart0) ? year(yearStart0) : year(time)
int yearOneNumber = not na(yearStart1) ? year(yearStart1) : currentYearNumber - 1
int yearTwoNumber = not na(yearStart2) ? year(yearStart2) : currentYearNumber - 2
int yearThreeNumber = not na(yearStart3) ? year(yearStart3) : currentYearNumber - 3
int yearFourNumber = not na(yearStart4) ? year(yearStart4) : currentYearNumber - 4

bool extendAllYearOpens = yearlyOpenMode == "Extend all to current"
int currentWeeklyX2 = time + 604800000

var line yearOpenLine0 = na
var line yearOpenLine1 = na
var line yearOpenLine2 = na
var line yearOpenLine3 = na
var line yearOpenLine4 = na

var label yearOpenLabel0 = na
var label yearOpenLabel1 = na
var label yearOpenLabel2 = na
var label yearOpenLabel3 = na
var label yearOpenLabel4 = na

if barstate.islast
    bool drawYear0 = showWeeklyProfile and showCurrentYearOpen
    bool drawYear1 = showWeeklyProfile and showOneYearBackOpen
    bool drawYear2 = showWeeklyProfile and showTwoYearsBackOpen
    bool drawYear3 = showWeeklyProfile and showThreeYearsBackOpen
    bool drawYear4 = showWeeklyProfile and showFourYearsBackOpen

    int year0X2 = currentWeeklyX2
    int year1X2 = extendAllYearOpens ? currentWeeklyX2 : yearStart0
    int year2X2 = extendAllYearOpens ? currentWeeklyX2 : yearStart1
    int year3X2 = extendAllYearOpens ? currentWeeklyX2 : yearStart2
    int year4X2 = extendAllYearOpens ? currentWeeklyX2 : yearStart3

    yearOpenLine0 := f_update_segment(yearOpenLine0, drawYear0, yearStart0, year0X2, yearOpen0, currentYearOpenColor, yearlyOpenWidth, true)
    yearOpenLine1 := f_update_segment(yearOpenLine1, drawYear1, yearStart1, year1X2, yearOpen1, oneYearBackOpenColor, yearlyOpenWidth, extendAllYearOpens)
    yearOpenLine2 := f_update_segment(yearOpenLine2, drawYear2, yearStart2, year2X2, yearOpen2, twoYearsBackOpenColor, yearlyOpenWidth, extendAllYearOpens)
    yearOpenLine3 := f_update_segment(yearOpenLine3, drawYear3, yearStart3, year3X2, yearOpen3, threeYearsBackOpenColor, yearlyOpenWidth, extendAllYearOpens)
    yearOpenLine4 := f_update_segment(yearOpenLine4, drawYear4, yearStart4, year4X2, yearOpen4, fourYearsBackOpenColor, yearlyOpenWidth, extendAllYearOpens)

    string year0Text = str.tostring(currentYearNumber) + " Open  " + str.tostring(yearOpen0, format.mintick)
    string year1Text = str.tostring(yearOneNumber) + " Open  " + str.tostring(yearOpen1, format.mintick)
    string year2Text = str.tostring(yearTwoNumber) + " Open  " + str.tostring(yearOpen2, format.mintick)
    string year3Text = str.tostring(yearThreeNumber) + " Open  " + str.tostring(yearOpen3, format.mintick)
    string year4Text = str.tostring(yearFourNumber) + " Open  " + str.tostring(yearOpen4, format.mintick)

    int yearlyRightLabelTime = time + yearlyLabelOffset * 604800000
    if extendAllYearOpens
        yearOpenLabel0 := f_update_time_label(yearOpenLabel0, drawYear0 and showYearOpenLabels, yearlyRightLabelTime, yearOpen0, year0Text, currentYearOpenColor)
        yearOpenLabel1 := f_update_time_label(yearOpenLabel1, drawYear1 and showYearOpenLabels, yearlyRightLabelTime, yearOpen1, year1Text, oneYearBackOpenColor)
        yearOpenLabel2 := f_update_time_label(yearOpenLabel2, drawYear2 and showYearOpenLabels, yearlyRightLabelTime, yearOpen2, year2Text, twoYearsBackOpenColor)
        yearOpenLabel3 := f_update_time_label(yearOpenLabel3, drawYear3 and showYearOpenLabels, yearlyRightLabelTime, yearOpen3, year3Text, threeYearsBackOpenColor)
        yearOpenLabel4 := f_update_time_label(yearOpenLabel4, drawYear4 and showYearOpenLabels, yearlyRightLabelTime, yearOpen4, year4Text, fourYearsBackOpenColor)
    else
        yearOpenLabel0 := f_update_time_label(yearOpenLabel0, drawYear0 and showYearOpenLabels, yearStart0, yearOpen0, year0Text, currentYearOpenColor)
        yearOpenLabel1 := f_update_time_label(yearOpenLabel1, drawYear1 and showYearOpenLabels, yearStart1, yearOpen1, year1Text, oneYearBackOpenColor)
        yearOpenLabel2 := f_update_time_label(yearOpenLabel2, drawYear2 and showYearOpenLabels, yearStart2, yearOpen2, year2Text, twoYearsBackOpenColor)
        yearOpenLabel3 := f_update_time_label(yearOpenLabel3, drawYear3 and showYearOpenLabels, yearStart3, yearOpen3, year3Text, threeYearsBackOpenColor)
        yearOpenLabel4 := f_update_time_label(yearOpenLabel4, drawYear4 and showYearOpenLabels, yearStart4, yearOpen4, year4Text, fourYearsBackOpenColor)

// ============================================================================
// COMPACT DAILY TREND + LEVEL MAP
// ============================================================================
var table dailyMapTable = table.new(mapPosition, 2, 9, border_width = 1)

if barstate.islast
    for row = 0 to 8
        for column = 0 to 1
            table.cell(dailyMapTable, column, row, "", bgcolor = color.new(color.black, 100), text_color = color.new(color.white, 100), text_size = mapTextSize)

    if showDailyProfile and showDailyMap
        int trendCode = f_trend_code(close, dailyEMA20, dailySMA50, dailySMA200)
        string trendText = f_trend_name(trendCode) + " | " + f_stack_text(dailyEMA20, dailySMA50, dailySMA200)
        string slope20 = f_slope_text(dailyEMA20, dailyEMA20[slopeLookback])
        string slope50 = f_slope_text(dailySMA50, dailySMA50[slopeLookback])
        float stretchAtr = not na(dailyATR) and dailyATR > 0 and not na(dailyEMA20) ? (close - dailyEMA20) / dailyATR : na
        string momentumText = "20 " + slope20 + " | 50 " + slope50 + (na(stretchAtr) ? "" : " | " + (stretchAtr >= 0 ? "+" : "") + str.tostring(stretchAtr, "#.00") + " ATR vs 20")
        string atrStopText = na(dailyATR) ? "Unavailable" : "ATR(" + str.tostring(dailyAtrLength) + ") " + str.tostring(dailyATR, format.mintick) + " | 2x " + str.tostring(dailyATR * 2.0, format.mintick) + " | 3x " + str.tostring(dailyATR * 3.0, format.mintick)

        string previousWeekState = f_range_state(close, previousWeekHigh, previousWeekLow, dailyATR)
        string previousMonthState = f_range_state(close, previousMonthHigh, previousMonthLow, dailyATR)

        array<float> candidateLevels = array.new<float>()
        array<string> candidateNames = array.new<string>()
        array<int> candidateGroups = array.new<int>()

        if showPreviousMonth and f_level_is_valid(previousMonthHigh)
            array.push(candidateLevels, previousMonthHigh)
            array.push(candidateNames, "Prev Month High")
            array.push(candidateGroups, 1)
        if showPreviousMonth and f_level_is_valid(previousMonthLow)
            array.push(candidateLevels, previousMonthLow)
            array.push(candidateNames, "Prev Month Low")
            array.push(candidateGroups, 1)
        if showCurrentMonth and f_level_is_valid(currentMonthHigh)
            array.push(candidateLevels, currentMonthHigh)
            array.push(candidateNames, "Curr Month High")
            array.push(candidateGroups, 2)
        if showCurrentMonth and f_level_is_valid(currentMonthLow)
            array.push(candidateLevels, currentMonthLow)
            array.push(candidateNames, "Curr Month Low")
            array.push(candidateGroups, 2)
        if showPreviousWeek and f_level_is_valid(previousWeekHigh)
            array.push(candidateLevels, previousWeekHigh)
            array.push(candidateNames, "Prev Week High")
            array.push(candidateGroups, 3)
        if showPreviousWeek and f_level_is_valid(previousWeekLow)
            array.push(candidateLevels, previousWeekLow)
            array.push(candidateNames, "Prev Week Low")
            array.push(candidateGroups, 3)
        if showEMA20 and f_level_is_valid(dailyEMA20)
            array.push(candidateLevels, dailyEMA20)
            array.push(candidateNames, "20 EMA")
            array.push(candidateGroups, 4)
        if showSMA50 and f_level_is_valid(dailySMA50)
            array.push(candidateLevels, dailySMA50)
            array.push(candidateNames, "50 SMA")
            array.push(candidateGroups, 5)
        if showSMA200 and f_level_is_valid(dailySMA200)
            array.push(candidateLevels, dailySMA200)
            array.push(candidateNames, "200 SMA")
            array.push(candidateGroups, 6)

        float nearestAboveValue = na
        float nearestBelowValue = na
        float nearestAboveDistance = na
        float nearestBelowDistance = na
        string nearestAboveName = "None"
        string nearestBelowName = "None"

        int candidateCount = array.size(candidateLevels)
        if candidateCount > 0
            for i = 0 to candidateCount - 1
                float candidate = array.get(candidateLevels, i)
                string candidateName = array.get(candidateNames, i)
                float distance = math.abs(candidate - close)
                if candidate > close and (na(nearestAboveDistance) or distance < nearestAboveDistance)
                    nearestAboveDistance := distance
                    nearestAboveValue := candidate
                    nearestAboveName := candidateName
                if candidate < close and (na(nearestBelowDistance) or distance < nearestBelowDistance)
                    nearestBelowDistance := distance
                    nearestBelowValue := candidate
                    nearestBelowName := candidateName

        string nearestAboveText = f_distance_text(nearestAboveName, nearestAboveValue, close, dailyATR)
        string nearestBelowText = f_distance_text(nearestBelowName, nearestBelowValue, close, dailyATR)

        float bestClusterDistance = na
        float bestClusterSpread = na
        string bestClusterNameA = ""
        string bestClusterNameB = ""

        if candidateCount > 1 and not na(dailyATR) and dailyATR > 0
            float maxClusterSpread = dailyATR * confluenceThresholdAtr
            for i = 0 to candidateCount - 2
                float levelA = array.get(candidateLevels, i)
                string nameA = array.get(candidateNames, i)
                int groupA = array.get(candidateGroups, i)
                for j = i + 1 to candidateCount - 1
                    float levelB = array.get(candidateLevels, j)
                    string nameB = array.get(candidateNames, j)
                    int groupB = array.get(candidateGroups, j)
                    float spread = math.abs(levelA - levelB)
                    if groupA != groupB and spread <= maxClusterSpread
                        float clusterCenter = (levelA + levelB) / 2.0
                        float clusterDistance = math.abs(clusterCenter - close)
                        if na(bestClusterDistance) or clusterDistance < bestClusterDistance or (clusterDistance == bestClusterDistance and spread < bestClusterSpread)
                            bestClusterDistance := clusterDistance
                            bestClusterSpread := spread
                            bestClusterNameA := nameA
                            bestClusterNameB := nameB

        string confluenceText = na(bestClusterDistance) ? "None within " + str.tostring(confluenceThresholdAtr, "#.00") + " ATR" : bestClusterNameA + " + " + bestClusterNameB + " | " + str.tostring(bestClusterDistance / dailyATR, "#.00") + " ATR away"

        color headerBackground = color.new(color.blue, 70)
        color labelBackground = color.new(color.black, 20)
        color valueBackground = color.new(color.black, 5)
        color weekStateColor = f_range_color(close, previousWeekHigh, previousWeekLow)
        color monthStateColor = f_range_color(close, previousMonthHigh, previousMonthLow)
        bool slope20Up = not na(dailyEMA20[slopeLookback]) and dailyEMA20 > dailyEMA20[slopeLookback]
        bool slope20Down = not na(dailyEMA20[slopeLookback]) and dailyEMA20 < dailyEMA20[slopeLookback]
        bool slope50Up = not na(dailySMA50[slopeLookback]) and dailySMA50 > dailySMA50[slopeLookback]
        bool slope50Down = not na(dailySMA50[slopeLookback]) and dailySMA50 < dailySMA50[slopeLookback]
        color momentumBackground = valueBackground
        if slope20Up and slope50Up
            momentumBackground := color.new(color.green, 84)
        else if slope20Down and slope50Down
            momentumBackground := color.new(color.red, 80)
        else if (slope20Up and slope50Down) or (slope20Down and slope50Up)
            momentumBackground := color.new(color.orange, 78)
        if not na(stretchAtr) and stretchAtr <= -1.25
            momentumBackground := color.new(color.red, 68)
        else if not na(stretchAtr) and stretchAtr >= 1.25
            momentumBackground := color.new(color.orange, 65)

        table.cell(dailyMapTable, 0, 0, "DAILY TREND + LEVEL MAP", bgcolor = headerBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 0, syminfo.ticker, bgcolor = headerBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 1, "Trend", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 1, trendText, bgcolor = color.new(f_trend_color(trendCode), 58), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 2, "Momentum / Stretch", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 2, momentumText, bgcolor = momentumBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 3, "ATR / Stop Range", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 3, atrStopText, bgcolor = color.new(color.blue, 85), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 4, "Previous Week", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 4, previousWeekState, bgcolor = color.new(weekStateColor, 75), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 5, "Previous Month", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 5, previousMonthState, bgcolor = color.new(monthStateColor, 75), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 6, "Nearest Above", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 6, nearestAboveText, bgcolor = color.new(color.red, 85), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 7, "Nearest Below", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 7, nearestBelowText, bgcolor = color.new(color.green, 85), text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 0, 8, "Nearest Confluence", bgcolor = labelBackground, text_color = color.white, text_size = mapTextSize)
        table.cell(dailyMapTable, 1, 8, confluenceText, bgcolor = color.new(color.orange, 82), text_color = color.white, text_size = mapTextSize)

// ============================================================================
// TIMEFRAME NOTICE
// ============================================================================
var table timeframeNotice = table.new(position.top_center, 1, 1)

if barstate.islast
    bool wrongTimeframe = not isOneDayChart and not isOneWeekChart
    string noticeText = showTimeframeNotice and wrongTimeframe ? "Use this indicator on a 1D or 1W chart" : ""
    color noticeBackground = showTimeframeNotice and wrongTimeframe ? color.new(color.orange, 15) : color.new(color.black, 100)
    color noticeTextColor = showTimeframeNotice and wrongTimeframe ? color.white : color.new(color.white, 100)
    table.cell(timeframeNotice, 0, 0, noticeText, bgcolor = noticeBackground, text_color = noticeTextColor)
````
