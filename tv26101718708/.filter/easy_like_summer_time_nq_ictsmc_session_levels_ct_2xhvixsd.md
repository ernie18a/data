# Easy like Summer Time (NQ ICT/SMC Session Levels) [CT]

- url: https://www.tradingview.com/script/2xhvIXsd-Easy-like-Summer-Time-NQ-ICT-SMC-Session-Levels-CT/
- type: indicator
- pine_id: PUB;e14511927a4740658a1e6f4b5730af2b
- version: 1.0

## Description

Summer Time ICT Indicator
The Summer Time ICT Indicator is designed to help traders spend less time glued to the screen while still keeping the market's most important reference levels in view.
Instead of manually plotting key ICT and Smart Money concepts each session, this indicator automatically tracks and displays institutional levels so you can focus on execution rather than chart maintenance.
Features
✅ Previous Day High (PDH) & Previous Day Low (PDL)
✅ Previous Week High (PWH) & Previous Week Low (PWL)
✅ Monday High & Monday Low
✅ Weekly Open
✅ Daily Open (5:00 PM Central Time futures session)
✅ Rolling 4-Hour Opens
✅ Asia Session Open, High & Low
✅ London Session Open, High & Low
✅ New York Session Open, High & Low
✅ Customizable colors, line styles, and labels
✅ Built-in alerts for key level interactions, allowing you to step away from the screen and be notified when price reaches areas that matter
Built for traders who value efficiency
The goal of this indicator is simple: reduce chart clutter, automate repetitive tasks, and help you stay aware of significant liquidity levels without having to watch every candle.
Whether you're looking for session liquidity sweeps, reactions at prior highs and lows, or interactions with important opens, the Summer Time ICT Indicator keeps those levels visible and can alert you when price reaches them.
Best used on
Nasdaq Futures (NQ)
Micro Nasdaq (MNQ)
S&P 500 Futures (ES/MES)
Other liquid futures, indices, forex pairs, and markets where session-based analysis is valuable
Note: This tool is intended as a charting aid and alert system. It does not generate buy or sell signals and should be used alongside your own trading plan and risk management.
One branding suggestion: the tagline “Trade more. Watch less.” fits this indicator especially well and reinforces the idea that timely alerts let you step away from the charts without losing awareness of key levels.

## Source Code

````pine
//@version=6
indicator("NQ ICT/SMC Session Levels [CT]", "NQ ICT Levels CT", overlay=true, max_lines_count=120, max_labels_count=120)

// Designed for NQ futures on intraday charts. All period logic is anchored to
// Central Time so futures session opens line up with the 5:00 PM CT rollover.

string GROUP_TIME = "Time / Sessions"
string tz = input.string("America/Chicago", "Timezone", group=GROUP_TIME)
string asiaSession = input.session("1800-0000", "Asia Session", group=GROUP_TIME)
string londonSession = input.session("0100-0400", "London Session", group=GROUP_TIME)
string nySession = input.session("0830-1100", "New York Session", group=GROUP_TIME)

string GROUP_DISPLAY = "Display"
bool showPrices = input.bool(true, "Show Prices In Labels", group=GROUP_DISPLAY)
int labelOffsetBars = input.int(6, "Right Label Offset (Bars)", minval=1, maxval=100, group=GROUP_DISPLAY)
int lineWidth = input.int(1, "Line Width", minval=1, maxval=4, group=GROUP_DISPLAY)
color labelTextColor = input.color(color.white, "Label Text", group=GROUP_DISPLAY)

string GROUP_PREV = "Previous Day / Week"
bool showPDH = input.bool(true, "Previous Day High", group=GROUP_PREV, inline="PDH")
color colorPDH = input.color(color.new(color.lime, 0), "", group=GROUP_PREV, inline="PDH")
string stylePDH = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_PREV, inline="PDH")
bool showPDL = input.bool(true, "Previous Day Low", group=GROUP_PREV, inline="PDL")
color colorPDL = input.color(color.new(color.red, 0), "", group=GROUP_PREV, inline="PDL")
string stylePDL = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_PREV, inline="PDL")
bool showPWH = input.bool(true, "Previous Week High", group=GROUP_PREV, inline="PWH")
color colorPWH = input.color(color.new(color.green, 0), "", group=GROUP_PREV, inline="PWH")
string stylePWH = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_PREV, inline="PWH")
bool showPWL = input.bool(true, "Previous Week Low", group=GROUP_PREV, inline="PWL")
color colorPWL = input.color(color.new(color.maroon, 0), "", group=GROUP_PREV, inline="PWL")
string stylePWL = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_PREV, inline="PWL")

string GROUP_MON = "Monday Range"
bool showMonH = input.bool(true, "Monday High", group=GROUP_MON, inline="MONH")
color colorMonH = input.color(color.new(color.aqua, 0), "", group=GROUP_MON, inline="MONH")
string styleMonH = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_MON, inline="MONH")
bool showMonL = input.bool(true, "Monday Low", group=GROUP_MON, inline="MONL")
color colorMonL = input.color(color.new(color.orange, 0), "", group=GROUP_MON, inline="MONL")
string styleMonL = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_MON, inline="MONL")

string GROUP_OPENS = "Opens"
bool showWeeklyOpen = input.bool(true, "Weekly Open", group=GROUP_OPENS, inline="WO")
color colorWeeklyOpen = input.color(color.new(color.yellow, 0), "", group=GROUP_OPENS, inline="WO")
string styleWeeklyOpen = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_OPENS, inline="WO")
bool showDailyOpen = input.bool(true, "Daily Open (5:00 PM CT)", group=GROUP_OPENS, inline="DO")
color colorDailyOpen = input.color(color.new(color.white, 0), "", group=GROUP_OPENS, inline="DO")
string styleDailyOpen = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_OPENS, inline="DO")
bool showFourHourOpens = input.bool(true, "4-Hour Opens", group=GROUP_OPENS, inline="4H")
color colorFourHourOpen = input.color(color.new(color.fuchsia, 0), "", group=GROUP_OPENS, inline="4H")
string styleFourHourOpen = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=GROUP_OPENS, inline="4H")
int fourHourOpenCount = input.int(6, "Number Of 4-Hour Opens", minval=1, maxval=24, group=GROUP_OPENS)

string GROUP_ASIA = "Asia"
bool showAsiaOpen = input.bool(true, "Asia Open", group=GROUP_ASIA, inline="AO")
color colorAsiaOpen = input.color(color.new(color.teal, 0), "", group=GROUP_ASIA, inline="AO")
bool showAsiaHigh = input.bool(true, "Asia High", group=GROUP_ASIA, inline="AH")
color colorAsiaHigh = input.color(color.new(color.lime, 0), "", group=GROUP_ASIA, inline="AH")
bool showAsiaLow = input.bool(true, "Asia Low", group=GROUP_ASIA, inline="AL")
color colorAsiaLow = input.color(color.new(color.red, 0), "", group=GROUP_ASIA, inline="AL")
string styleAsia = input.string("Dashed", "Asia Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_ASIA)

string GROUP_LONDON = "London"
bool showLondonOpen = input.bool(true, "London Open", group=GROUP_LONDON, inline="LO")
color colorLondonOpen = input.color(color.new(color.blue, 0), "", group=GROUP_LONDON, inline="LO")
bool showLondonHigh = input.bool(true, "London High", group=GROUP_LONDON, inline="LH")
color colorLondonHigh = input.color(color.new(color.lime, 0), "", group=GROUP_LONDON, inline="LH")
bool showLondonLow = input.bool(true, "London Low", group=GROUP_LONDON, inline="LL")
color colorLondonLow = input.color(color.new(color.red, 0), "", group=GROUP_LONDON, inline="LL")
string styleLondon = input.string("Dashed", "London Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_LONDON)

string GROUP_NY = "New York"
bool showNYOpen = input.bool(true, "New York Open", group=GROUP_NY, inline="NO")
color colorNYOpen = input.color(color.new(color.purple, 0), "", group=GROUP_NY, inline="NO")
bool showNYHigh = input.bool(true, "New York High", group=GROUP_NY, inline="NH")
color colorNYHigh = input.color(color.new(color.lime, 0), "", group=GROUP_NY, inline="NH")
bool showNYLow = input.bool(true, "New York Low", group=GROUP_NY, inline="NL")
color colorNYLow = input.color(color.new(color.red, 0), "", group=GROUP_NY, inline="NL")
string styleNY = input.string("Dashed", "New York Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_NY)

string GROUP_ALERTS = "Alerts"
bool enableAlerts = input.bool(false, "Master Enable Alerts", group=GROUP_ALERTS)
bool alertsOnBarClose = input.bool(true, "Alert Once Per Bar Close", group=GROUP_ALERTS)
bool alertMessagesWithPrice = input.bool(true, "Enable Alert Messages With Price", group=GROUP_ALERTS)
bool alertPDH = input.bool(true, "Previous Day High", group=GROUP_ALERTS, inline="A1")
bool alertPDL = input.bool(true, "Previous Day Low", group=GROUP_ALERTS, inline="A1")
bool alertPWH = input.bool(true, "Previous Week High", group=GROUP_ALERTS, inline="A2")
bool alertPWL = input.bool(true, "Previous Week Low", group=GROUP_ALERTS, inline="A2")
bool alertMonH = input.bool(true, "Monday High", group=GROUP_ALERTS, inline="A3")
bool alertMonL = input.bool(true, "Monday Low", group=GROUP_ALERTS, inline="A3")
bool alertWeeklyOpen = input.bool(true, "Weekly Open", group=GROUP_ALERTS, inline="A4")
bool alertDailyOpen = input.bool(true, "Daily Open", group=GROUP_ALERTS, inline="A4")
bool alertAsiaHigh = input.bool(true, "Asia High", group=GROUP_ALERTS, inline="A5")
bool alertAsiaLow = input.bool(true, "Asia Low", group=GROUP_ALERTS, inline="A5")
bool alertLondonHigh = input.bool(true, "London High", group=GROUP_ALERTS, inline="A6")
bool alertLondonLow = input.bool(true, "London Low", group=GROUP_ALERTS, inline="A6")
bool alertNYHigh = input.bool(true, "New York High", group=GROUP_ALERTS, inline="A7")
bool alertNYLow = input.bool(true, "New York Low", group=GROUP_ALERTS, inline="A7")

int MS_HOUR = 60 * 60 * 1000
int MS_DAY = 24 * MS_HOUR
int chartMs = int(math.max(nz(timeframe.in_seconds(timeframe.period), 60), 60) * 1000)
int labelX = time + chartMs * labelOffsetBars

f_lineStyle(string styleName) =>
    switch styleName
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_text(string name, float price) =>
    showPrices ? str.format("{0}  {1}", name, str.tostring(price, format.mintick)) : name

f_levelColor(color baseColor) =>
    color.new(baseColor, 0)

f_labelColor(color baseColor) =>
    color.new(baseColor, 15)

f_alertMessage(string name, float price) =>
    alertMessagesWithPrice ? str.format("{0} touched: {1}", name, str.tostring(price, format.mintick)) : str.format("{0} touched", name)

f_alertReady(bool fired, bool enabled, float price, bool touched) =>
    enableAlerts and enabled and not fired and not na(price) and touched and (not alertsOnBarClose or barstate.isconfirmed)

f_fireAlert(string message) =>
    if alertsOnBarClose
        alert(message, alert.freq_once_per_bar_close)
    else
        alert(message, alert.freq_once_per_bar)

const int IDX_PDH = 0
const int IDX_PDL = 1
const int IDX_PWH = 2
const int IDX_PWL = 3
const int IDX_MONH = 4
const int IDX_MONL = 5
const int IDX_WO = 6
const int IDX_DO = 7
const int IDX_ASIAO = 8
const int IDX_ASIAH = 9
const int IDX_ASIAL = 10
const int IDX_LONO = 11
const int IDX_LONH = 12
const int IDX_LONL = 13
const int IDX_NYO = 14
const int IDX_NYH = 15
const int IDX_NYL = 16
const int LEVEL_COUNT = 17

var line[] levelLines = array.new_line(LEVEL_COUNT)
var label[] levelLabels = array.new_label(LEVEL_COUNT)

f_deleteLevel(int idx) =>
    line ln = array.get(levelLines, idx)
    label lb = array.get(levelLabels, idx)
    if not na(ln)
        line.delete(ln)
        array.set(levelLines, idx, na)
    if not na(lb)
        label.delete(lb)
        array.set(levelLabels, idx, na)

f_renderLevel(int idx, bool show, float price, int anchor, string name, color levelColor, string styleName, int width) =>
    if show and not na(price) and not na(anchor)
        line ln = array.get(levelLines, idx)
        label lb = array.get(levelLabels, idx)
        if na(ln)
            ln := line.new(anchor, price, time, price, xloc=xloc.bar_time, extend=extend.right, color=f_levelColor(levelColor), style=f_lineStyle(styleName), width=width)
            array.set(levelLines, idx, ln)
        else
            line.set_xy1(ln, anchor, price)
            line.set_xy2(ln, time, price)
            line.set_extend(ln, extend.right)
            line.set_color(ln, f_levelColor(levelColor))
            line.set_style(ln, f_lineStyle(styleName))
            line.set_width(ln, width)
        if na(lb)
            lb := label.new(labelX, price, f_text(name, price), xloc=xloc.bar_time, style=label.style_label_left, color=f_labelColor(levelColor), textcolor=labelTextColor, size=size.small)
            array.set(levelLabels, idx, lb)
        else
            label.set_x(lb, labelX)
            label.set_y(lb, price)
            label.set_text(lb, f_text(name, price))
            label.set_color(lb, f_labelColor(levelColor))
            label.set_textcolor(lb, labelTextColor)
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, size.small)
    else
        f_deleteLevel(idx)

f_dailyAnchor(int t) =>
    int todayOpen = timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), 17, 0)
    int priorT = t - MS_DAY
    int priorOpen = timestamp(tz, year(priorT, tz), month(priorT, tz), dayofmonth(priorT, tz), 17, 0)
    t >= todayOpen ? todayOpen : priorOpen

f_weeklyAnchor(int t) =>
    int dow = dayofweek(t, tz)
    int todayWeeklyOpen = timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), 17, 0)
    int daysSinceSunday = dow - dayofweek.sunday
    int sundayT = t - daysSinceSunday * MS_DAY
    int sundayOpen = timestamp(tz, year(sundayT, tz), month(sundayT, tz), dayofmonth(sundayT, tz), 17, 0)
    dow == dayofweek.sunday and t < todayWeeklyOpen ? timestamp(tz, year(t - 7 * MS_DAY, tz), month(t - 7 * MS_DAY, tz), dayofmonth(t - 7 * MS_DAY, tz), 17, 0) : sundayOpen

int dayAnchorNow = f_dailyAnchor(time)
int weekAnchorNow = f_weeklyAnchor(time)
bool newDay = ta.change(dayAnchorNow) != 0
bool newWeek = ta.change(weekAnchorNow) != 0
bool tradingDayIsMonday = dayofweek(dayAnchorNow + 7 * MS_HOUR, tz) == dayofweek.monday

var float currentDayHigh = na
var float currentDayLow = na
var float previousDayHigh = na
var float previousDayLow = na
var float dailyOpen = na
var int previousDayAnchor = na
var int dailyOpenAnchor = na

if na(currentDayHigh)
    currentDayHigh := high
    currentDayLow := low
    dailyOpen := open
    dailyOpenAnchor := dayAnchorNow
else if newDay
    previousDayHigh := currentDayHigh
    previousDayLow := currentDayLow
    previousDayAnchor := dayAnchorNow
    currentDayHigh := high
    currentDayLow := low
    dailyOpen := open
    dailyOpenAnchor := dayAnchorNow
else
    currentDayHigh := math.max(currentDayHigh, high)
    currentDayLow := math.min(currentDayLow, low)

var float currentWeekHigh = na
var float currentWeekLow = na
var float previousWeekHigh = na
var float previousWeekLow = na
var float weeklyOpen = na
var int previousWeekAnchor = na
var int weeklyOpenAnchor = na

if na(currentWeekHigh)
    currentWeekHigh := high
    currentWeekLow := low
    weeklyOpen := open
    weeklyOpenAnchor := weekAnchorNow
else if newWeek
    previousWeekHigh := currentWeekHigh
    previousWeekLow := currentWeekLow
    previousWeekAnchor := weekAnchorNow
    currentWeekHigh := high
    currentWeekLow := low
    weeklyOpen := open
    weeklyOpenAnchor := weekAnchorNow
else
    currentWeekHigh := math.max(currentWeekHigh, high)
    currentWeekLow := math.min(currentWeekLow, low)

var float mondayHigh = na
var float mondayLow = na
var int mondayAnchor = na

if newWeek
    mondayHigh := na
    mondayLow := na
    mondayAnchor := na

if tradingDayIsMonday
    mondayHigh := na(mondayHigh) ? high : math.max(mondayHigh, high)
    mondayLow := na(mondayLow) ? low : math.min(mondayLow, low)
    mondayAnchor := dayAnchorNow

int block4h = int(math.floor((time - dayAnchorNow) / (4 * MS_HOUR)))
int block4hId = dayAnchorNow + block4h * 4 * MS_HOUR
bool new4hBlock = ta.change(block4hId) != 0

var float[] fourHPrices = array.new_float()
var int[] fourHAnchors = array.new_int()
var line[] fourHLines = array.new_line()
var label[] fourHLabels = array.new_label()

f_trimFourHour() =>
    while array.size(fourHPrices) > fourHourOpenCount
        line ln = array.shift(fourHLines)
        label lb = array.shift(fourHLabels)
        array.shift(fourHPrices)
        array.shift(fourHAnchors)
        if not na(ln)
            line.delete(ln)
        if not na(lb)
            label.delete(lb)

f_clearFourHour() =>
    while array.size(fourHPrices) > 0
        line ln = array.shift(fourHLines)
        label lb = array.shift(fourHLabels)
        array.shift(fourHPrices)
        array.shift(fourHAnchors)
        if not na(ln)
            line.delete(ln)
        if not na(lb)
            label.delete(lb)

if array.size(fourHPrices) == 0
    array.push(fourHPrices, open)
    array.push(fourHAnchors, block4hId)
    array.push(fourHLines, na)
    array.push(fourHLabels, na)
else if new4hBlock
    array.push(fourHPrices, open)
    array.push(fourHAnchors, block4hId)
    array.push(fourHLines, na)
    array.push(fourHLabels, na)
    f_trimFourHour()

bool inAsia = not na(time(timeframe.period, asiaSession, tz))
bool asiaWasActive = bar_index > 0 ? inAsia[1] : false
bool asiaStart = inAsia and not asiaWasActive
var float asiaOpen = na
var float asiaHigh = na
var float asiaLow = na
var int asiaAnchor = na
if asiaStart
    asiaOpen := open
    asiaHigh := high
    asiaLow := low
    asiaAnchor := time
else if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)

bool inLondon = not na(time(timeframe.period, londonSession, tz))
bool londonWasActive = bar_index > 0 ? inLondon[1] : false
bool londonStart = inLondon and not londonWasActive
var float londonOpen = na
var float londonHigh = na
var float londonLow = na
var int londonAnchor = na
if londonStart
    londonOpen := open
    londonHigh := high
    londonLow := low
    londonAnchor := time
else if inLondon
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow := math.min(nz(londonLow, low), low)

bool inNY = not na(time(timeframe.period, nySession, tz))
bool nyWasActive = bar_index > 0 ? inNY[1] : false
bool nyStart = inNY and not nyWasActive
var float nyOpen = na
var float nyHigh = na
var float nyLow = na
var int nyAnchor = na
if nyStart
    nyOpen := open
    nyHigh := high
    nyLow := low
    nyAnchor := time
else if inNY
    nyHigh := math.max(nz(nyHigh, high), high)
    nyLow := math.min(nz(nyLow, low), low)

var bool pdhAlertFired = false
var bool pdlAlertFired = false
var bool pwhAlertFired = false
var bool pwlAlertFired = false
var bool monHAlertFired = false
var bool monLAlertFired = false
var bool weeklyOpenAlertFired = false
var bool dailyOpenAlertFired = false
var bool asiaHAlertFired = false
var bool asiaLAlertFired = false
var bool londonHAlertFired = false
var bool londonLAlertFired = false
var bool nyHAlertFired = false
var bool nyLAlertFired = false

// Daily-derived levels refresh at the CT futures session boundary.
if newDay
    pdhAlertFired := false
    pdlAlertFired := false
    dailyOpenAlertFired := false

// Weekly and Monday levels refresh at the Sunday 5:00 PM CT weekly boundary.
if newWeek
    pwhAlertFired := false
    pwlAlertFired := false
    monHAlertFired := false
    monLAlertFired := false
    weeklyOpenAlertFired := false

// Session high/low alerts reset when the next matching session begins.
if asiaStart
    asiaHAlertFired := false
    asiaLAlertFired := false

if londonStart
    londonHAlertFired := false
    londonLAlertFired := false

if nyStart
    nyHAlertFired := false
    nyLAlertFired := false

bool pdhTouched = not na(previousDayHigh) and low <= previousDayHigh and high >= previousDayHigh
bool pdlTouched = not na(previousDayLow) and low <= previousDayLow and high >= previousDayLow
bool pwhTouched = not na(previousWeekHigh) and low <= previousWeekHigh and high >= previousWeekHigh
bool pwlTouched = not na(previousWeekLow) and low <= previousWeekLow and high >= previousWeekLow
// Monday range alerts are later-retest alerts, so they stay inactive while Monday's range is still forming.
bool monHTouched = not tradingDayIsMonday and not na(mondayHigh) and low <= mondayHigh and high >= mondayHigh
bool monLTouched = not tradingDayIsMonday and not na(mondayLow) and low <= mondayLow and high >= mondayLow
bool weeklyOpenTouched = not na(weeklyOpen) and low <= weeklyOpen and high >= weeklyOpen
bool dailyOpenTouched = not na(dailyOpen) and low <= dailyOpen and high >= dailyOpen
bool asiaHTouched = not inAsia and not na(asiaHigh) and low <= asiaHigh and high >= asiaHigh
bool asiaLTouched = not inAsia and not na(asiaLow) and low <= asiaLow and high >= asiaLow
bool londonHTouched = not inLondon and not na(londonHigh) and low <= londonHigh and high >= londonHigh
bool londonLTouched = not inLondon and not na(londonLow) and low <= londonLow and high >= londonLow
bool nyHTouched = not inNY and not na(nyHigh) and low <= nyHigh and high >= nyHigh
bool nyLTouched = not inNY and not na(nyLow) and low <= nyLow and high >= nyLow

bool pdhAlertNow = f_alertReady(pdhAlertFired, alertPDH, previousDayHigh, pdhTouched)
bool pdlAlertNow = f_alertReady(pdlAlertFired, alertPDL, previousDayLow, pdlTouched)
bool pwhAlertNow = f_alertReady(pwhAlertFired, alertPWH, previousWeekHigh, pwhTouched)
bool pwlAlertNow = f_alertReady(pwlAlertFired, alertPWL, previousWeekLow, pwlTouched)
bool monHAlertNow = f_alertReady(monHAlertFired, alertMonH, mondayHigh, monHTouched)
bool monLAlertNow = f_alertReady(monLAlertFired, alertMonL, mondayLow, monLTouched)
bool weeklyOpenAlertNow = f_alertReady(weeklyOpenAlertFired, alertWeeklyOpen, weeklyOpen, weeklyOpenTouched)
bool dailyOpenAlertNow = f_alertReady(dailyOpenAlertFired, alertDailyOpen, dailyOpen, dailyOpenTouched)
bool asiaHAlertNow = f_alertReady(asiaHAlertFired, alertAsiaHigh, asiaHigh, asiaHTouched)
bool asiaLAlertNow = f_alertReady(asiaLAlertFired, alertAsiaLow, asiaLow, asiaLTouched)
bool londonHAlertNow = f_alertReady(londonHAlertFired, alertLondonHigh, londonHigh, londonHTouched)
bool londonLAlertNow = f_alertReady(londonLAlertFired, alertLondonLow, londonLow, londonLTouched)
bool nyHAlertNow = f_alertReady(nyHAlertFired, alertNYHigh, nyHigh, nyHTouched)
bool nyLAlertNow = f_alertReady(nyLAlertFired, alertNYLow, nyLow, nyLTouched)

alertcondition(pdhAlertNow, "PDH Touched", "PDH touched")
alertcondition(pdlAlertNow, "PDL Touched", "PDL touched")
alertcondition(pwhAlertNow, "PWH Touched", "PWH touched")
alertcondition(pwlAlertNow, "PWL Touched", "PWL touched")
alertcondition(monHAlertNow, "Monday High Touched", "Monday High touched")
alertcondition(monLAlertNow, "Monday Low Touched", "Monday Low touched")
alertcondition(weeklyOpenAlertNow, "Weekly Open Touched", "Weekly Open touched")
alertcondition(dailyOpenAlertNow, "Daily Open Touched", "Daily Open touched")
alertcondition(asiaHAlertNow, "Asia High Touched", "Asia High touched")
alertcondition(asiaLAlertNow, "Asia Low Touched", "Asia Low touched")
alertcondition(londonHAlertNow, "London High Touched", "London High touched")
alertcondition(londonLAlertNow, "London Low Touched", "London Low touched")
alertcondition(nyHAlertNow, "New York High Touched", "New York High touched")
alertcondition(nyLAlertNow, "New York Low Touched", "New York Low touched")

if pdhAlertNow
    f_fireAlert(f_alertMessage("PDH", previousDayHigh))
    pdhAlertFired := true

if pdlAlertNow
    f_fireAlert(f_alertMessage("PDL", previousDayLow))
    pdlAlertFired := true

if pwhAlertNow
    f_fireAlert(f_alertMessage("PWH", previousWeekHigh))
    pwhAlertFired := true

if pwlAlertNow
    f_fireAlert(f_alertMessage("PWL", previousWeekLow))
    pwlAlertFired := true

if monHAlertNow
    f_fireAlert(f_alertMessage("Monday High", mondayHigh))
    monHAlertFired := true

if monLAlertNow
    f_fireAlert(f_alertMessage("Monday Low", mondayLow))
    monLAlertFired := true

if weeklyOpenAlertNow
    f_fireAlert(f_alertMessage("Weekly Open", weeklyOpen))
    weeklyOpenAlertFired := true

if dailyOpenAlertNow
    f_fireAlert(f_alertMessage("Daily Open", dailyOpen))
    dailyOpenAlertFired := true

if asiaHAlertNow
    f_fireAlert(f_alertMessage("Asia High", asiaHigh))
    asiaHAlertFired := true

if asiaLAlertNow
    f_fireAlert(f_alertMessage("Asia Low", asiaLow))
    asiaLAlertFired := true

if londonHAlertNow
    f_fireAlert(f_alertMessage("London High", londonHigh))
    londonHAlertFired := true

if londonLAlertNow
    f_fireAlert(f_alertMessage("London Low", londonLow))
    londonLAlertFired := true

if nyHAlertNow
    f_fireAlert(f_alertMessage("New York High", nyHigh))
    nyHAlertFired := true

if nyLAlertNow
    f_fireAlert(f_alertMessage("New York Low", nyLow))
    nyLAlertFired := true

if barstate.islast
    f_renderLevel(IDX_PDH, showPDH, previousDayHigh, previousDayAnchor, "PDH", colorPDH, stylePDH, lineWidth)
    f_renderLevel(IDX_PDL, showPDL, previousDayLow, previousDayAnchor, "PDL", colorPDL, stylePDL, lineWidth)
    f_renderLevel(IDX_PWH, showPWH, previousWeekHigh, previousWeekAnchor, "PWH", colorPWH, stylePWH, lineWidth)
    f_renderLevel(IDX_PWL, showPWL, previousWeekLow, previousWeekAnchor, "PWL", colorPWL, stylePWL, lineWidth)
    f_renderLevel(IDX_MONH, showMonH, mondayHigh, mondayAnchor, "Mon H", colorMonH, styleMonH, lineWidth)
    f_renderLevel(IDX_MONL, showMonL, mondayLow, mondayAnchor, "Mon L", colorMonL, styleMonL, lineWidth)
    f_renderLevel(IDX_WO, showWeeklyOpen, weeklyOpen, weeklyOpenAnchor, "W Open", colorWeeklyOpen, styleWeeklyOpen, lineWidth)
    f_renderLevel(IDX_DO, showDailyOpen, dailyOpen, dailyOpenAnchor, "D Open", colorDailyOpen, styleDailyOpen, lineWidth)
    f_renderLevel(IDX_ASIAO, showAsiaOpen, asiaOpen, asiaAnchor, "Asia O", colorAsiaOpen, styleAsia, lineWidth)
    f_renderLevel(IDX_ASIAH, showAsiaHigh, asiaHigh, asiaAnchor, "Asia H", colorAsiaHigh, styleAsia, lineWidth)
    f_renderLevel(IDX_ASIAL, showAsiaLow, asiaLow, asiaAnchor, "Asia L", colorAsiaLow, styleAsia, lineWidth)
    f_renderLevel(IDX_LONO, showLondonOpen, londonOpen, londonAnchor, "London O", colorLondonOpen, styleLondon, lineWidth)
    f_renderLevel(IDX_LONH, showLondonHigh, londonHigh, londonAnchor, "London H", colorLondonHigh, styleLondon, lineWidth)
    f_renderLevel(IDX_LONL, showLondonLow, londonLow, londonAnchor, "London L", colorLondonLow, styleLondon, lineWidth)
    f_renderLevel(IDX_NYO, showNYOpen, nyOpen, nyAnchor, "NY O", colorNYOpen, styleNY, lineWidth)
    f_renderLevel(IDX_NYH, showNYHigh, nyHigh, nyAnchor, "NY H", colorNYHigh, styleNY, lineWidth)
    f_renderLevel(IDX_NYL, showNYLow, nyLow, nyAnchor, "NY L", colorNYLow, styleNY, lineWidth)

    if showFourHourOpens
        f_trimFourHour()
        for i = 0 to array.size(fourHPrices) - 1
            float price = array.get(fourHPrices, i)
            int anchor = array.get(fourHAnchors, i)
            line ln = array.get(fourHLines, i)
            label lb = array.get(fourHLabels, i)
            if na(ln)
                ln := line.new(anchor, price, time, price, xloc=xloc.bar_time, extend=extend.right, color=f_levelColor(colorFourHourOpen), style=f_lineStyle(styleFourHourOpen), width=lineWidth)
                array.set(fourHLines, i, ln)
            else
                line.set_xy1(ln, anchor, price)
                line.set_xy2(ln, time, price)
                line.set_extend(ln, extend.right)
                line.set_color(ln, f_levelColor(colorFourHourOpen))
                line.set_style(ln, f_lineStyle(styleFourHourOpen))
                line.set_width(ln, lineWidth)
            if na(lb)
                lb := label.new(labelX, price, f_text("4H O", price), xloc=xloc.bar_time, style=label.style_label_left, color=f_labelColor(colorFourHourOpen), textcolor=labelTextColor, size=size.small)
                array.set(fourHLabels, i, lb)
            else
                label.set_x(lb, labelX)
                label.set_y(lb, price)
                label.set_text(lb, f_text("4H O", price))
                label.set_color(lb, f_labelColor(colorFourHourOpen))
                label.set_textcolor(lb, labelTextColor)
                label.set_style(lb, label.style_label_left)
                label.set_size(lb, size.small)
    else
        f_clearFourHour()
````
