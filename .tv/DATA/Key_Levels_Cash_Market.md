<!-- tradingview-pine-id: PUB;d178bc3a16174a2ea1c6f68c0dd42b38 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Key Levels - Cash Market

Source: https://www.tradingview.com/script/gB4SPKBZ-Key-Levels-Cash-Market/

## Description

This is a Pine v6 modernization of the original SpacemanBTC Key Levels indicator. The original was already a useful way to keep important higher-timeframe levels on chart, but parts of the session logic, timezone handling, and display system were showing their age—especially for equities and index futures traders.

This version keeps the same core idea while rebuilding the underlying logic for cleaner, more reliable behavior.

What changed

[*]Updated to Pine Script v6
Modernized the codebase and removed a large amount of repetitive legacy plotting logic.

[*]Cash-market sessions instead of FX-style sessions
London, New York, and Tokyo now use their actual local cash-market hours rather than generic FX session windows.

[*]Timezone-aware session handling
Sessions use Europe/London, America/New_York, and Asia/Tokyo, so daylight-saving changes are handled automatically.

[*]More reliable session High / Low / Open levels
Session tracking was rebuilt to reset from the actual first bar of each session, avoiding incorrect levels caused by gaps, stale values, or RTH-only charts.

[*]Improved Tokyo handling
The Tokyo range accounts for the exchange's midday lunch break while preserving the morning range into the afternoon session.

[*]Non-repainting Current Year levels
Current Year High, Low, and Mid were rewritten to avoid higher-timeframe lookahead behavior that could make historical levels differ from what was available in real time.

[*]Improved Monday Range for futures
Uses TradingView's trading-day logic so overnight futures sessions—such as NQ beginning Sunday evening—are correctly associated with Monday.

[*]Simplified display controls
The old Distance and Anchor Distance controls were replaced by a single Right Offset setting. Right Anchored mode now simply starts levels at the current bar.

[*]Cleaner session settings UI
Each cash session now has its enable toggle, session time, and color on the same row.

[*]Global Coloring is now truly global
London, New York, and Tokyo session levels now respect the Global Coloring setting as well.

Based on the original Key Levels SpacemanBTC IDWM source. The original source credited @sbtnc for the base code. This version remains open source with credit to the work it was built from.

---

## Source Code

````pine
//@version=6
// Key Levels - Cash Market
//
// Modernized Pine v6 implementation based on the original
// "Key Levels SpacemanBTC IDWM" source.
// Original source credited @sbtnc for the base code.
//
// Reworked with timezone-aware cash sessions, corrected session ranges,
// non-repainting YTD levels, improved Monday-range handling,
// simplified display controls, and a consolidated rendering engine.
//
indicator("Key Levels - Cash Market", shorttitle = "Key Levels-CM", overlay = true, max_lines_count = 100, max_labels_count = 100)

//------------------------------------------------------------------------------
// Groups
//------------------------------------------------------------------------------
string GROUP_DISPLAY  = "Display"
string GROUP_4H       = "4H"
string GROUP_DAILY    = "Daily"
string GROUP_MONDAY   = "Monday Range"
string GROUP_WEEKLY   = "Weekly"
string GROUP_MONTHLY  = "Monthly"
string GROUP_QUARTER  = "Quarterly"
string GROUP_YEARLY   = "Yearly"
string GROUP_SESSIONS = "Cash Market Sessions"

//------------------------------------------------------------------------------
// Display / global controls
//------------------------------------------------------------------------------
string displayStyle = input.string("Standard", "Display Style", options = ["Standard", "Right Anchored"], group = GROUP_DISPLAY,
     tooltip = "Standard: each level begins at its true origin. Right Anchored: each level begins at the current bar so the chart stays cleaner.")
bool mergeLevels = input.bool(true, "Merge Overlapping Labels", group = GROUP_DISPLAY)
int rightOffsetBars = input.int(15, "Right Offset (bars)", minval = 1, maxval = 500, group = GROUP_DISPLAY,
     tooltip = "Controls how far to the right the line endpoint and label are placed. This replaces the old Distance + Anchor Distance controls.")
bool staggerNearbyLabels = input.bool(true, "Stagger Nearby Labels", group = GROUP_DISPLAY,
     tooltip = "Horizontally spaces nearby levels to prevent them from overlapping, while keeping each line at its exact price.")

int nearbyThresholdTicks = input.int(20, "Nearby Range (ticks)", minval = 1, maxval = 200, group = GROUP_DISPLAY,
     tooltip = "Different-price levels within this many ticks are staggered to prevent label overlap.")

int staggerStepBars = input.int(10, "Stagger Spacing (bars)", minval = 1, maxval = 100, group = GROUP_DISPLAY,
     tooltip = "Horizontal spacing between nearby labels.")
string lineSizeInput = input.string("Small", "Line Width", options = ["Small", "Medium", "Large"], inline = "LINE", group = GROUP_DISPLAY)
string lineStyleInput = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "LINE", group = GROUP_DISPLAY)
string labelSizeInput = input.string("Medium", "Text Size", options = ["Small", "Medium", "Large"], group = GROUP_DISPLAY)

bool globalShorthand = input.bool(false, "Global Shorthand", group = GROUP_DISPLAY,
     tooltip = "Use abbreviated labels for every level.")
bool globalColoring = input.bool(false, "Global Coloring", inline = "GC", group = GROUP_DISPLAY,
     tooltip = "Override every individual level color with one global color.")
color globalColor = input.color(#673ab7, "", inline = "GC", group = GROUP_DISPLAY)

int lineWidth = lineSizeInput == "Small" ? 1 : lineSizeInput == "Medium" ? 2 : 3
string lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid
string labelSize = labelSizeInput == "Small" ? size.small : labelSizeInput == "Large" ? size.large : size.normal

//------------------------------------------------------------------------------
// Level inputs
//------------------------------------------------------------------------------
bool show4HOpen  = input.bool(true, "Open", inline = "4H1", group = GROUP_4H)
bool show4HRange = input.bool(true, "Prev H/L", inline = "4H1", group = GROUP_4H)
bool show4HMid   = input.bool(false, "Prev Mid", inline = "4H1", group = GROUP_4H)
bool short4H = input.bool(false, "Shorthand", inline = "4H2", group = GROUP_4H, active = not globalShorthand)
color color4HInput = input.color(color.rgb(255, 0, 0), "", inline = "4H2", group = GROUP_4H, active = not globalColoring)

bool showDailyOpen  = input.bool(true, "Open", inline = "D1", group = GROUP_DAILY)
bool showDailyRange = input.bool(false, "Prev H/L", inline = "D1", group = GROUP_DAILY)
bool showDailyMid   = input.bool(false, "Prev Mid", inline = "D1", group = GROUP_DAILY)
bool shortDaily = input.bool(false, "Shorthand", inline = "D2", group = GROUP_DAILY, active = not globalShorthand)
color dailyColorInput = input.color(#ff9100, "", inline = "D2", group = GROUP_DAILY, active = not globalColoring)

bool showMondayRange = input.bool(true, "Range", inline = "MON1", group = GROUP_MONDAY)
bool showMondayMid   = input.bool(false, "Mid", inline = "MON1", group = GROUP_MONDAY)
bool shortMonday = input.bool(false, "Shorthand", inline = "MON2", group = GROUP_MONDAY, active = not globalShorthand)
color mondayColorInput = input.color(#f2ff00, "", inline = "MON2", group = GROUP_MONDAY, active = not globalColoring)

bool showWeeklyOpen  = input.bool(true, "Open", inline = "W1", group = GROUP_WEEKLY)
bool showWeeklyRange = input.bool(true, "Prev H/L", inline = "W1", group = GROUP_WEEKLY)
bool showWeeklyMid   = input.bool(false, "Prev Mid", inline = "W1", group = GROUP_WEEKLY)
bool shortWeekly = input.bool(false, "Shorthand", inline = "W2", group = GROUP_WEEKLY, active = not globalShorthand)
color weeklyColorInput = input.color(#1a9900, "", inline = "W2", group = GROUP_WEEKLY, active = not globalColoring)

bool showMonthlyOpen  = input.bool(true, "Open", inline = "M1", group = GROUP_MONTHLY)
bool showMonthlyRange = input.bool(true, "Prev H/L", inline = "M1", group = GROUP_MONTHLY)
bool showMonthlyMid   = input.bool(false, "Prev Mid", inline = "M1", group = GROUP_MONTHLY)
bool shortMonthly = input.bool(false, "Shorthand", inline = "M2", group = GROUP_MONTHLY, active = not globalShorthand)
color monthlyColorInput = input.color(#1608d4, "", inline = "M2", group = GROUP_MONTHLY, active = not globalColoring)

bool showQuarterlyOpen  = input.bool(true, "Open", inline = "Q1", group = GROUP_QUARTER)
bool showQuarterlyRange = input.bool(false, "Prev H/L", inline = "Q1", group = GROUP_QUARTER)
bool showQuarterlyMid   = input.bool(false, "Prev Mid", inline = "Q1", group = GROUP_QUARTER)
bool shortQuarterly = input.bool(false, "Shorthand", inline = "Q2", group = GROUP_QUARTER, active = not globalShorthand)
color quarterlyColorInput = input.color(color.rgb(135, 0, 253), "", inline = "Q2", group = GROUP_QUARTER, active = not globalColoring)

bool showYearlyOpen  = input.bool(true, "Open", inline = "Y1", group = GROUP_YEARLY)
bool showYearlyRange = input.bool(false, "Current H/L", inline = "Y1", group = GROUP_YEARLY)
bool showYearlyMid   = input.bool(false, "Current Mid", inline = "Y1", group = GROUP_YEARLY)
bool shortYearly = input.bool(false, "Shorthand", inline = "Y2", group = GROUP_YEARLY, active = not globalShorthand)
color yearlyColorInput = input.color(color.rgb(255, 0, 242), "", inline = "Y2", group = GROUP_YEARLY, active = not globalColoring)

// Each cash session gets its own row: show toggle | session hours | color.
bool showLondon = input.bool(false, "London", inline = "LON", group = GROUP_SESSIONS,
     tooltip = "London cash hours in Europe/London local time. DST is handled automatically.")
string londonSessionInput = input.session("0800-1630", "", inline = "LON", group = GROUP_SESSIONS, active = showLondon)
color londonColorInput = input.color(color.white, "", inline = "LON", group = GROUP_SESSIONS, active = showLondon and not globalColoring)

bool showNewYork = input.bool(false, "New York", inline = "NY", group = GROUP_SESSIONS,
     tooltip = "U.S. cash-equity hours in America/New_York local time. DST is handled automatically.")
string newYorkSessionInput = input.session("0930-1600", "", inline = "NY", group = GROUP_SESSIONS, active = showNewYork)
color newYorkColorInput = input.color(color.white, "", inline = "NY", group = GROUP_SESSIONS, active = showNewYork and not globalColoring)

bool showAsia = input.bool(false, "Tokyo / Asia", inline = "ASIA", group = GROUP_SESSIONS,
     tooltip = "Tokyo cash-market window in Asia/Tokyo local time. The 11:30-12:30 JST lunch break is excluded automatically. Japan does not observe DST.")
string asiaSessionInput = input.session("0900-1530", "", inline = "ASIA", group = GROUP_SESSIONS, active = showAsia)
color asiaColorInput = input.color(color.white, "", inline = "ASIA", group = GROUP_SESSIONS, active = showAsia and not globalColoring)

bool shortSessions = input.bool(false, "Session Shorthand", group = GROUP_SESSIONS, active = not globalShorthand)

//------------------------------------------------------------------------------
// Resolved colors and text
//------------------------------------------------------------------------------
color color4H        = globalColoring ? globalColor : color4HInput
color dailyColor     = globalColoring ? globalColor : dailyColorInput
color mondayColor    = globalColoring ? globalColor : mondayColorInput
color weeklyColor    = globalColoring ? globalColor : weeklyColorInput
color monthlyColor   = globalColoring ? globalColor : monthlyColorInput
color quarterlyColor = globalColoring ? globalColor : quarterlyColorInput
color yearlyColor    = globalColoring ? globalColor : yearlyColorInput
color londonColor    = globalColoring ? globalColor : londonColorInput
color newYorkColor   = globalColoring ? globalColor : newYorkColorInput
color asiaColor      = globalColoring ? globalColor : asiaColorInput

bool use4HShort      = globalShorthand or short4H
bool useDailyShort   = globalShorthand or shortDaily
bool useMondayShort  = globalShorthand or shortMonday
bool useWeeklyShort  = globalShorthand or shortWeekly
bool useMonthlyShort = globalShorthand or shortMonthly
bool useQuarterShort = globalShorthand or shortQuarterly
bool useYearlyShort  = globalShorthand or shortYearly
bool useSessionShort = globalShorthand or shortSessions

string txt4HOpen = use4HShort ? "4H-O" : "4H Open"
string txtP4HH   = use4HShort ? "P-4H-H" : "Prev 4H High"
string txtP4HL   = use4HShort ? "P-4H-L" : "Prev 4H Low"
string txtP4HM   = use4HShort ? "P-4H-M" : "Prev 4H Mid"

string txtDO  = useDailyShort ? "DO" : "Daily Open"
string txtPDH = useDailyShort ? "PDH" : "Prev Day High"
string txtPDL = useDailyShort ? "PDL" : "Prev Day Low"
string txtPDM = useDailyShort ? "PDM" : "Prev Day Mid"

string txtMonH = useMondayShort ? "MDAY-H" : "Monday High"
string txtMonL = useMondayShort ? "MDAY-L" : "Monday Low"
string txtMonM = useMondayShort ? "MDAY-M" : "Monday Mid"

string txtWO  = useWeeklyShort ? "WO" : "Weekly Open"
string txtPWH = useWeeklyShort ? "PWH" : "Prev Week High"
string txtPWL = useWeeklyShort ? "PWL" : "Prev Week Low"
string txtPWM = useWeeklyShort ? "PWM" : "Prev Week Mid"

string txtMO  = useMonthlyShort ? "MO" : "Monthly Open"
string txtPMH = useMonthlyShort ? "PMH" : "Prev Month High"
string txtPML = useMonthlyShort ? "PML" : "Prev Month Low"
string txtPMM = useMonthlyShort ? "PMM" : "Prev Month Mid"

string txtQO  = useQuarterShort ? "QO" : "Quarterly Open"
string txtPQH = useQuarterShort ? "PQH" : "Prev Quarter High"
string txtPQL = useQuarterShort ? "PQL" : "Prev Quarter Low"
string txtPQM = useQuarterShort ? "PQM" : "Prev Quarter Mid"

string txtYO  = useYearlyShort ? "YO" : "Yearly Open"
string txtCYH = useYearlyShort ? "CYH" : "Current Year High"
string txtCYL = useYearlyShort ? "CYL" : "Current Year Low"
string txtCYM = useYearlyShort ? "CYM" : "Current Year Mid"

string txtLonH = useSessionShort ? "Lon-H" : "London High"
string txtLonL = useSessionShort ? "Lon-L" : "London Low"
string txtLonO = useSessionShort ? "Lon-O" : "London Open"
string txtNYH  = useSessionShort ? "NY-H" : "New York High"
string txtNYL  = useSessionShort ? "NY-L" : "New York Low"
string txtNYO  = useSessionShort ? "NY-O" : "New York Open"
string txtAsiaH = useSessionShort ? "AS-H" : "Asia High"
string txtAsiaL = useSessionShort ? "AS-L" : "Asia Low"
string txtAsiaO = useSessionShort ? "AS-O" : "Asia Open"

//------------------------------------------------------------------------------
// Higher-timeframe levels
// Current-period time/open are known from the first bar of that period.
// Previous H/L values are explicitly offset by [1] with lookahead_on, which
// keeps historical and realtime behavior aligned without future leakage.
//------------------------------------------------------------------------------
[dTime, dOpen, pdTime, pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [time, open, time[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[h4Time, h4Open, ph4Time, ph4High, ph4Low] = request.security(syminfo.tickerid, "240", [time, open, time[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[wTime, wOpen, pwTime, pwHigh, pwLow] = request.security(syminfo.tickerid, "W", [time, open, time[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[mTime, mOpen, pmTime, pmHigh, pmLow] = request.security(syminfo.tickerid, "M", [time, open, time[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[qTime, qOpen, pqTime, pqHigh, pqLow] = request.security(syminfo.tickerid, "3M", [time, open, time[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[yTime, yOpen] = request.security(syminfo.tickerid, "12M", [time, open], lookahead = barmerge.lookahead_on)

float pdMid  = (pdHigh + pdLow) / 2.0
float ph4Mid = (ph4High + ph4Low) / 2.0
float pwMid  = (pwHigh + pwLow) / 2.0
float pmMid  = (pmHigh + pmLow) / 2.0
float pqMid  = (pqHigh + pqLow) / 2.0

//------------------------------------------------------------------------------
// Non-repainting current-year high/low
// Build the completed YTD range in DAILY context, return only the prior day's
// confirmed accumulator, then combine it with today's developing chart range.
// This avoids the original lookahead leak while remaining accurate even when
// the intraday chart does not have the whole year loaded.
//------------------------------------------------------------------------------
f_prevYtdRange() =>
    int tradingYear = year(time_tradingday, "UTC")
    bool newTradingYear = tradingYear != tradingYear[1]
    var float ytdHigh = na
    var float ytdLow = na
    ytdHigh := newTradingYear or na(ytdHigh) ? high : math.max(ytdHigh, high)
    ytdLow  := newTradingYear or na(ytdLow) ? low : math.min(ytdLow, low)
    [ytdHigh[1], ytdLow[1], newTradingYear]

[prevYtdHigh, prevYtdLow, firstTradingDayOfYear] = request.security(syminfo.tickerid, "D", f_prevYtdRange(), lookahead = barmerge.lookahead_on)

bool newTradingDay = barstate.isfirst or time_tradingday != time_tradingday[1]
var float currentDayHigh = na
var float currentDayLow = na

if newTradingDay or na(currentDayHigh)
    currentDayHigh := high
    currentDayLow := low
else
    currentDayHigh := math.max(currentDayHigh, high)
    currentDayLow := math.min(currentDayLow, low)

float currentYearHigh = firstTradingDayOfYear or na(prevYtdHigh) ? currentDayHigh : math.max(prevYtdHigh, currentDayHigh)
float currentYearLow  = firstTradingDayOfYear or na(prevYtdLow) ? currentDayLow : math.min(prevYtdLow, currentDayLow)
float currentYearMid  = (currentYearHigh + currentYearLow) / 2.0

//------------------------------------------------------------------------------
// Monday range
// Uses time_tradingday so overnight futures sessions are assigned to the day
// they belong to (e.g., Sunday evening NQ bars belong to Monday's trading day).
// The range develops live on Monday and then freezes for the rest of the week.
//------------------------------------------------------------------------------
int tradingYearNow = year(time_tradingday, "UTC")
int tradingWeekNow = weekofyear(time_tradingday, "UTC")
bool newTradingWeek = barstate.isfirst or tradingYearNow != tradingYearNow[1] or tradingWeekNow != tradingWeekNow[1]
bool isMondayTradingDay = dayofweek(time_tradingday, "UTC") == dayofweek.monday
bool mondayStart = isMondayTradingDay and not isMondayTradingDay[1]

var int mondayTime = na
var float mondayHigh = na
var float mondayLow = na

if newTradingWeek
    mondayTime := na
    mondayHigh := na
    mondayLow := na

if isMondayTradingDay
    if mondayStart or na(mondayHigh)
        mondayTime := time
        mondayHigh := high
        mondayLow := low
    else
        mondayHigh := math.max(mondayHigh, high)
        mondayLow := math.min(mondayLow, low)

float mondayMid = (mondayHigh + mondayLow) / 2.0

//------------------------------------------------------------------------------
// Cash-session ranges
// Sessions are fixed to weekdays and evaluated in each market's local IANA
// timezone, so DST transitions are handled automatically.
//
// Session starts are detected by BOTH session-state transition and local
// calendar date. The date check ensures ranges reset correctly even on
// RTH-only charts where no out-of-session bars exist between trading days.
//------------------------------------------------------------------------------

// Session membership
bool inLondon = not na(time(timeframe.period, londonSessionInput + ":23456", "Europe/London"))
bool inNewYork = not na(time(timeframe.period, newYorkSessionInput + ":23456", "America/New_York"))
bool inAsiaWindow = not na(time(timeframe.period, asiaSessionInput + ":23456", "Asia/Tokyo"))

// Tokyo Stock Exchange lunch break
bool inTokyoLunch = not na(time(timeframe.period, "1130-1230:23456", "Asia/Tokyo"))
bool inAsia = inAsiaWindow and not inTokyoLunch

// Local calendar-day keys.
// These guarantee a reset on a new local trading date even when the chart
// contains only regular-session bars.
int londonDayKey =
     year(time, "Europe/London") * 10000 +
     month(time, "Europe/London") * 100 +
     dayofmonth(time, "Europe/London")

int newYorkDayKey =
     year(time, "America/New_York") * 10000 +
     month(time, "America/New_York") * 100 +
     dayofmonth(time, "America/New_York")

int asiaDayKey =
     year(time, "Asia/Tokyo") * 10000 +
     month(time, "Asia/Tokyo") * 100 +
     dayofmonth(time, "Asia/Tokyo")

// True on the first chart bar belonging to each new cash session.
bool londonSessionStart =
     inLondon and (not inLondon[1] or londonDayKey != londonDayKey[1])

bool newYorkSessionStart =
     inNewYork and (not inNewYork[1] or newYorkDayKey != newYorkDayKey[1])

bool asiaSessionStart =
     inAsiaWindow and (not inAsiaWindow[1] or asiaDayKey != asiaDayKey[1])

//------------------------------------------------------------------------------
// London
//------------------------------------------------------------------------------
var int londonTime = na
var float londonHigh = na
var float londonLow = na
var float londonOpen = na

if londonSessionStart
    londonTime := time
    londonHigh := high
    londonLow := low
    londonOpen := open
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

//------------------------------------------------------------------------------
// New York
//------------------------------------------------------------------------------
var int newYorkTime = na
var float newYorkHigh = na
var float newYorkLow = na
var float newYorkOpen = na

if newYorkSessionStart
    newYorkTime := time
    newYorkHigh := high
    newYorkLow := low
    newYorkOpen := open
else if inNewYork
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow := math.min(newYorkLow, low)

//------------------------------------------------------------------------------
// Tokyo / Asia
//------------------------------------------------------------------------------
var int asiaTime = na
var float asiaHigh = na
var float asiaLow = na
var float asiaOpen = na

if asiaSessionStart
    asiaTime := time
    asiaHigh := high
    asiaLow := low
    asiaOpen := open
else if inAsia
    // Preserve the morning range through Tokyo's lunch break, then continue
    // updating when the afternoon cash session resumes.
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

//------------------------------------------------------------------------------
// Timeframe guards
// Do not display a lower-timeframe level on a higher-timeframe chart, where a
// normal request.security() call would only return a sampled intrabar value.
//------------------------------------------------------------------------------
float chartSeconds = timeframe.in_seconds()
bool canShow4H       = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("240")
bool canShowDaily    = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("1D")
bool canShowWeekly   = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("1W")
bool canShowMonthly  = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("1M")
bool canShowQuarter  = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("3M")
bool canShowYearly   = not na(chartSeconds) and chartSeconds <= timeframe.in_seconds("12M")
bool canShowSessions = timeframe.isintraday

//------------------------------------------------------------------------------
// Generic level renderer
//------------------------------------------------------------------------------
var array<int> levelStarts = array.new_int(0)
var array<float> levelPrices = array.new_float(0)
var array<string> levelTexts = array.new_string(0)
var array<color> levelColors = array.new_color(0)

var array<line> levelLines = array.new_line(0)
var array<label> levelLabels = array.new_label(0)

// Temporary stagger-slot assignments rebuilt on each last-bar update.
var array<int> levelSlots = array.new_int(0)

f_addLevel(bool enabled, int startTime, float price, string labelText, color levelColor) =>
    if enabled and not na(startTime) and not na(price)
        array.push(levelStarts, startTime)
        array.push(levelPrices, price)
        array.push(levelTexts, labelText)
        array.push(levelColors, levelColor)

if barstate.islast
    array.clear(levelStarts)
    array.clear(levelPrices)
    array.clear(levelTexts)
    array.clear(levelColors)
    array.clear(levelSlots)

    //--------------------------------------------------------------------------
    // Sessions
    //--------------------------------------------------------------------------
    f_addLevel(showLondon and canShowSessions, londonTime, londonHigh, txtLonH, londonColor)
    f_addLevel(showLondon and canShowSessions, londonTime, londonLow, txtLonL, londonColor)
    f_addLevel(showLondon and canShowSessions, londonTime, londonOpen, txtLonO, londonColor)

    f_addLevel(showNewYork and canShowSessions, newYorkTime, newYorkHigh, txtNYH, newYorkColor)
    f_addLevel(showNewYork and canShowSessions, newYorkTime, newYorkLow, txtNYL, newYorkColor)
    f_addLevel(showNewYork and canShowSessions, newYorkTime, newYorkOpen, txtNYO, newYorkColor)

    f_addLevel(showAsia and canShowSessions, asiaTime, asiaHigh, txtAsiaH, asiaColor)
    f_addLevel(showAsia and canShowSessions, asiaTime, asiaLow, txtAsiaL, asiaColor)
    f_addLevel(showAsia and canShowSessions, asiaTime, asiaOpen, txtAsiaO, asiaColor)

    //--------------------------------------------------------------------------
    // Intraday / calendar levels
    //
    // Added from lower timeframe to higher timeframe so merged labels naturally
    // inherit the color of the higher-timeframe level.
    //--------------------------------------------------------------------------
    f_addLevel(show4HOpen and canShow4H, h4Time, h4Open, txt4HOpen, color4H)
    f_addLevel(show4HRange and canShow4H, ph4Time, ph4High, txtP4HH, color4H)
    f_addLevel(show4HRange and canShow4H, ph4Time, ph4Low, txtP4HL, color4H)
    f_addLevel(show4HMid and canShow4H, ph4Time, ph4Mid, txtP4HM, color4H)

    f_addLevel(showMondayRange and canShowDaily, mondayTime, mondayHigh, txtMonH, mondayColor)
    f_addLevel(showMondayRange and canShowDaily, mondayTime, mondayLow, txtMonL, mondayColor)
    f_addLevel(showMondayMid and canShowDaily, mondayTime, mondayMid, txtMonM, mondayColor)

    f_addLevel(showDailyOpen and canShowDaily, dTime, dOpen, txtDO, dailyColor)
    f_addLevel(showDailyRange and canShowDaily, pdTime, pdHigh, txtPDH, dailyColor)
    f_addLevel(showDailyRange and canShowDaily, pdTime, pdLow, txtPDL, dailyColor)
    f_addLevel(showDailyMid and canShowDaily, pdTime, pdMid, txtPDM, dailyColor)

    f_addLevel(showWeeklyOpen and canShowWeekly, wTime, wOpen, txtWO, weeklyColor)
    f_addLevel(showWeeklyRange and canShowWeekly, pwTime, pwHigh, txtPWH, weeklyColor)
    f_addLevel(showWeeklyRange and canShowWeekly, pwTime, pwLow, txtPWL, weeklyColor)
    f_addLevel(showWeeklyMid and canShowWeekly, pwTime, pwMid, txtPWM, weeklyColor)

    f_addLevel(showMonthlyOpen and canShowMonthly, mTime, mOpen, txtMO, monthlyColor)
    f_addLevel(showMonthlyRange and canShowMonthly, pmTime, pmHigh, txtPMH, monthlyColor)
    f_addLevel(showMonthlyRange and canShowMonthly, pmTime, pmLow, txtPML, monthlyColor)
    f_addLevel(showMonthlyMid and canShowMonthly, pmTime, pmMid, txtPMM, monthlyColor)

    f_addLevel(showQuarterlyOpen and canShowQuarter, qTime, qOpen, txtQO, quarterlyColor)
    f_addLevel(showQuarterlyRange and canShowQuarter, pqTime, pqHigh, txtPQH, quarterlyColor)
    f_addLevel(showQuarterlyRange and canShowQuarter, pqTime, pqLow, txtPQL, quarterlyColor)
    f_addLevel(showQuarterlyMid and canShowQuarter, pqTime, pqMid, txtPQM, quarterlyColor)

    f_addLevel(showYearlyOpen and canShowYearly, yTime, yOpen, txtYO, yearlyColor)
    f_addLevel(showYearlyRange and canShowDaily, yTime, currentYearHigh, txtCYH, yearlyColor)
    f_addLevel(showYearlyRange and canShowDaily, yTime, currentYearLow, txtCYL, yearlyColor)
    f_addLevel(showYearlyMid and canShowDaily, yTime, currentYearMid, txtCYM, yearlyColor)

    int levelCount = array.size(levelPrices)

    //--------------------------------------------------------------------------
    // Remove unused drawing objects after settings change
    //--------------------------------------------------------------------------
    while array.size(levelLines) > levelCount
        line.delete(array.pop(levelLines))

    while array.size(levelLabels) > levelCount
        label.delete(array.pop(levelLabels))

    //--------------------------------------------------------------------------
    // Horizontal positioning
    //--------------------------------------------------------------------------
    int barMs = int(timeframe.in_seconds() * 1000.0)
    int baseRightTime = time + barMs * rightOffsetBars

    float nearbyPriceThreshold = nearbyThresholdTicks * syminfo.mintick

    //--------------------------------------------------------------------------
    // Draw / update levels
    //--------------------------------------------------------------------------
    if levelCount > 0
        for i = 0 to levelCount - 1
            int trueStart = array.get(levelStarts, i)
            int leftTime = displayStyle == "Right Anchored" ? time : trueStart

            float price = array.get(levelPrices, i)
            string labelText = array.get(levelTexts, i)
            color levelColor = array.get(levelColors, i)

            //------------------------------------------------------------------
            // Find a horizontal stagger slot.
            //
            // Exact-price matches deliberately use the SAME slot because they
            // will be merged into one label later.
            //
            // Nearby-but-different prices use the next available horizontal
            // slot so their labels fan out instead of overlapping.
            //------------------------------------------------------------------
            int staggerSlot = 0
            bool foundExactMatch = false

            if staggerNearbyLabels and i > 0
                // First check for an exact-price match.
                for j = 0 to i - 1
                    float otherPrice = array.get(levelPrices, j)

                    if price == otherPrice
                        staggerSlot := array.get(levelSlots, j)
                        foundExactMatch := true
                        break

                // If this is a unique price, stagger it relative to all nearby
                // previously processed prices.
                if not foundExactMatch
                    for j = 0 to i - 1
                        float otherPrice = array.get(levelPrices, j)
                        float priceDiff = math.abs(price - otherPrice)

                        if priceDiff > 0 and priceDiff <= nearbyPriceThreshold
                            int otherSlot = array.get(levelSlots, j)
                            staggerSlot := math.max(staggerSlot, otherSlot + 1)

            array.push(levelSlots, staggerSlot)

            int itemRightTime =
                 baseRightTime + barMs * staggerStepBars * staggerSlot

            line ln = na
            label lb = na

            //------------------------------------------------------------------
            // Create drawing objects if this level doesn't have them yet
            //------------------------------------------------------------------
            if i >= array.size(levelLines)
                ln := line.new(
                     x1 = leftTime,
                     y1 = price,
                     x2 = itemRightTime,
                     y2 = price,
                     xloc = xloc.bar_time,
                     color = levelColor,
                     width = lineWidth,
                     style = lineStyle)

                lb := label.new(
                     x = itemRightTime,
                     y = price,
                     text = labelText,
                     xloc = xloc.bar_time,
                     style = label.style_none,
                     textcolor = levelColor,
                     size = labelSize)

                array.push(levelLines, ln)
                array.push(levelLabels, lb)

            //------------------------------------------------------------------
            // Otherwise update the existing objects
            //------------------------------------------------------------------
            else
                ln := array.get(levelLines, i)
                lb := array.get(levelLabels, i)

                line.set_x1(ln, leftTime)
                line.set_x2(ln, itemRightTime)
                line.set_y1(ln, price)
                line.set_y2(ln, price)
                line.set_color(ln, levelColor)
                line.set_width(ln, lineWidth)
                line.set_style(ln, lineStyle)

                label.set_x(lb, itemRightTime)
                label.set_y(lb, price)
                label.set_text(lb, labelText)
                label.set_textcolor(lb, levelColor)
                label.set_size(lb, labelSize)

        //--------------------------------------------------------------------------
        // Merge labels that resolve to the EXACT same tradable price.
        //
        // Nearby but non-identical levels remain separate and are handled by
        // the horizontal staggering above.
        //--------------------------------------------------------------------------
        if mergeLevels and levelCount > 1
            for i = 1 to levelCount - 1
                float priceI = array.get(levelPrices, i)
                label labelI = array.get(levelLabels, i)

                for j = 0 to i - 1
                    float priceJ = array.get(levelPrices, j)
                    label labelJ = array.get(levelLabels, j)

                    if priceI == priceJ and label.get_text(labelJ) != ""
                        label.set_text(
                             labelJ,
                             label.get_text(labelI) + " / " + label.get_text(labelJ))

                        label.set_text(labelI, "")
                        label.set_textcolor(labelJ, array.get(levelColors, i))
                        break
````
