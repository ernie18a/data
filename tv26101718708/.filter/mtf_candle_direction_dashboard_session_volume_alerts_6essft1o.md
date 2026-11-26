# MTF Candle Direction Dashboard + Session Volume Alerts

- url: https://www.tradingview.com/script/6esSft1O-MTF-Candle-Direction-Dashboard-Session-Volume-Alerts/
- type: indicator
- pine_id: PUB;6c1153e1e554423fa87828f623f13174
- version: 3.0

## Description

OVERVIEW
This indicator shows the direction of the current and previous candle across five higher timeframes (15M, 1H, 4H, Daily, Weekly) in a compact dashboard. It also sends real-time alerts for candle direction flips on 1H, 4H and Daily, and for unusual volume in the pre-market and regular trading hours (RTH) sessions compared with their own 7-day and 30-day averages.

It is built for intraday traders who want to see higher-timeframe bias and session volume strength at a glance, without switching charts.

────────────────────────
1. MTF CANDLE DIRECTION DASHBOARD
────────────────────────
A table on the right side of the chart shows, for each timeframe:
- Current: direction of the candle that is still forming
- Previous: direction of the last closed candle

Symbols:
▲ Bullish (close > open)
▼ Bearish (close < open)
■ Neutral / Doji (close = open)

Timeframes: 15M, 1H, 4H, D, W

This gives a quick read on whether the higher timeframes agree or conflict, e.g. the 1H and 4H are both bullish while the Daily is still bearish.

────────────────────────
2. CANDLE FLIP ALERTS (1H / 4H / DAILY)
────────────────────────
When a new 1H, 4H or Daily candle opens, the script compares the last two CLOSED candles on that timeframe:
- BEAR→BULL: the prior candle was bearish and the last closed candle is bullish
- BULL→BEAR: the prior candle was bullish and the last closed candle is bearish

Notes:
- Only confirmed (closed) candles are used, so flip alerts do not repaint.
- The alert fires on the first tick of the new candle, which is the earliest a flip can be confirmed.
- Doji candles (close = open) are neutral and never trigger a flip.
- Candle open times follow the chart's session. With extended hours ON, Daily/4H candles start at 04:00 ET. With extended hours OFF, they start at 09:30 ET.

────────────────────────
3. SESSION VOLUME ALERTS (PRE-MARKET & RTH)
────────────────────────
The script tracks cumulative volume separately for two New York sessions:
- Pre-market: 04:00 – 09:30 ET
- RTH (Regular Trading Hours): 09:30 – 16:00 ET

Times use the America/New_York time zone and adjust automatically for EST/EDT.

For each session, today's running volume is compared with:
- the 7-day average of that same session's total volume
- the 30-day average of that same session's total volume

Pre-market is compared only against past pre-market sessions, and RTH only against past RTH sessions. The two are never mixed.

Four volume alerts:
- PM VOL > 7D AVG
- PM VOL > 30D AVG
- RTH VOL > 7D AVG
- RTH VOL > 30D AVG

Each alert fires in real time, on the tick when the running volume crosses the average, and only once per session.

Volume is always calculated from 5-minute extended-hours data, whatever the chart's timeframe, so session boundaries are exact.

────────────────────────
ALERT MESSAGE FORMAT
────────────────────────
All triggers are combined into a single message:
TICKER | EVENT(S) | Price

Example:
NVDA | 1H BEAR→BULL | PM VOL > 7D AVG (2.1M vs 1.8M) | Price 182.45

────────────────────────
HOW TO SET UP ALERTS
────────────────────────
1. Add the indicator to an intraday chart.
2. For pre-market alerts, turn ON extended trading hours on the chart. The script only updates when the chart receives data, so pre-market alerts cannot fire on an RTH-only chart. RTH alerts work either way.
3. Create an alert and set the condition to: MTF Candle Dir → "Any alert() function call".
4. Choose your notifications (app, email, webhook, etc.).

Alert frequency is handled inside the script (flips once per new candle, volume once per session), so no extra frequency setting is needed.

────────────────────────
SETTINGS
────────────────────────
- Show Dashboard: show or hide the table
- Triangle/Text Size: Tiny / Small / Normal / Large / Huge
- Colors: Bullish, Bearish, Neutral, Background, Label Text
- HTF Session:
   - Chart: follow the chart's session setting (default)
   - Regular: always use RTH candles for the dashboard and flip alerts
   - Extended: always use extended-hours candles for the dashboard and flip alerts

────────────────────────
LIMITATIONS
────────────────────────
- The 7-day averages need at least 7 completed sessions of history, and the 30-day averages need 30. Until then, those alerts stay silent.
- Volume session windows are set for US equities on NY time. Other markets may not fit these hours.
- The dashboard's "Current" column shows the candle that is still forming, and can change until that candle closes.
- Volume accuracy depends on the extended-hours data your data feed provides for the symbol.

────────────────────────
DISCLAIMER
────────────────────────
This script is for informational and educational purposes only and is not financial advice. Past behavior of price or volume does not guarantee future results. Always use your own judgment and risk management.

## Source Code

````pine
//@version=6
indicator("MTF Candle Direction Dashboard", "MTF Candle Dir", overlay = true, max_labels_count = 500)

showDashboardInput = input.bool(true, "Show Dashboard", group = "Dashboard")
dashboardSizeInput = input.string("Normal", "Triangle/Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Dashboard")
bullColorInput    = input.color(#089981,     "Bullish",        inline = "dbcolor", group = "Dashboard")
bearColorInput    = input.color(#f23645,     "Bearish",        inline = "dbcolor", group = "Dashboard")
neutralColorInput = input.color(color.gray,  "Neutral (Doji)", inline = "dbcolor", group = "Dashboard")
bgColorInput      = input.color(color.white, "Background", group = "Dashboard")
labelColorInput   = input.color(color.black, "Label Text", group = "Dashboard")
sessionModeInput  = input.string("Chart", "HTF Session", options = ["Chart", "Regular", "Extended"], group = "Dashboard", tooltip = "Chart = follow the chart's own session setting")
showVolRowsInput  = input.bool(true, "Show PM/RTH Volume Rows", group = "Dashboard")

// ── Alert toggles ──
enableAlertsInput = input.bool(true, "Enable All Alerts", group = "Alerts", tooltip = "Master switch for every alert below.")
a1hBullInput  = input.bool(true, "1H Bear→Bull",     inline = "a1h",  group = "Alerts")
a1hBearInput  = input.bool(true, "1H Bull→Bear",     inline = "a1h",  group = "Alerts")
a4hBullInput  = input.bool(true, "4H Bear→Bull",     inline = "a4h",  group = "Alerts")
a4hBearInput  = input.bool(true, "4H Bull→Bear",     inline = "a4h",  group = "Alerts")
aDBullInput   = input.bool(true, "D Bear→Bull",      inline = "ad",   group = "Alerts")
aDBearInput   = input.bool(true, "D Bull→Bear",      inline = "ad",   group = "Alerts")
aPm7Input     = input.bool(true, "PM Vol > 7D Avg",  inline = "apm",  group = "Alerts")
aPm30Input    = input.bool(true, "PM Vol > 30D Avg", inline = "apm",  group = "Alerts")
aRth7Input    = input.bool(true, "RTH Vol > 7D Avg",  inline = "arth", group = "Alerts")
aRth30Input   = input.bool(true, "RTH Vol > 30D Avg", inline = "arth", group = "Alerts")

// ── ROC ──
showRocRowInput = input.bool(true, "Show ROC Row", group = "ROC")
rocLenInput     = input.int(9, "ROC Length", minval = 1, group = "ROC")
rocTfInput      = input.timeframe("D", "ROC Timeframe", group = "ROC")
aRocUpInput     = input.bool(true, "Alert: ROC crosses above", inline = "rocup", group = "ROC")
rocUpThrInput   = input.float(10.0, "%", step = 0.5, inline = "rocup", group = "ROC")
aRocDnInput     = input.bool(true, "Alert: ROC crosses below", inline = "rocdn", group = "ROC")
rocDnThrInput   = input.float(-10.0, "%", step = 0.5, inline = "rocdn", group = "ROC", tooltip = "Each ROC alert fires at most once per ROC-timeframe candle (e.g. once per day for D), when the live ROC crosses the threshold from the other side of the previous candle's ROC.")
rocStretchInput = input.float(8.0, "Stretched level %", minval = 0.1, step = 0.5, group = "ROC", tooltip = "Signal column shows STRETCHED when ROC is beyond ± this %.")
warnColorInput  = input.color(color.orange, "Warning color", group = "ROC")

// ── Flip filter ──
bodyFilterInput = input.bool(true, "Min Body Filter", group = "Flip Filter", tooltip = "Ignore tiny candles: a 1H/4H/D candle counts as bull/bear only if its body ≥ ATR × multiplier of that timeframe.")
bodyMinAtrInput = input.float(0.1, "Min Body (x ATR)", minval = 0.0, step = 0.05, group = "Flip Filter")
bodyAtrLenInput = input.int(14, "ATR Length", minval = 1, group = "Flip Filter")

// ── Volume comparison ──
volModeInput = input.string("Same Time", "Compare Against", options = ["Same Time", "Full Day"], group = "Volume", tooltip = "Same Time = avg volume by this time of day (early alerts). Full Day = avg total session volume (late confirmation).")
volMultInput = input.float(1.5, "Multiplier (x avg)", minval = 0.1, step = 0.1, group = "Volume", tooltip = "Alert when session volume so far > avg × this.")

// ── Volume labels ──
showVolLblInput = input.bool(true, "Show Volume Labels", group = "Volume Labels")
volLblSizeInput = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Volume Labels")
pm7ColInput     = input.color(color.orange, "PM7",  inline = "pmc", group = "Volume Labels")
pm30ColInput    = input.color(#e65100,      "PM30", inline = "pmc", group = "Volume Labels")
rth7ColInput    = input.color(#2962ff,      "R7",   inline = "rc",  group = "Volume Labels")
rth30ColInput   = input.color(#1a237e,      "R30",  inline = "rc",  group = "Volume Labels")

string dashboardTextSize = dashboardSizeInput == "Tiny" ? size.tiny : dashboardSizeInput == "Small" ? size.small : dashboardSizeInput == "Large" ? size.large : dashboardSizeInput == "Huge" ? size.huge : size.normal
string volLblSize = volLblSizeInput == "Small" ? size.small : volLblSizeInput == "Normal" ? size.normal : size.tiny
bool   todMode    = volModeInput == "Same Time"

// Session: default follows the chart so HTF bars match what you see
string htfTicker = sessionModeInput == "Chart" ? syminfo.tickerid : ticker.modify(syminfo.tickerid, session = sessionModeInput == "Extended" ? session.extended : session.regular)

f_candleDirs() =>
    int dirCur  = close    > open    ? 1 : close    < open    ? -1 : 0
    int dirPrev = close[1] > open[1] ? 1 : close[1] < open[1] ? -1 : 0
    [dirCur, dirPrev]

// lookahead_on: table only draws on the last bar, so this returns the true current HTF bar (no future leak)
[dir1mCur,  dir1mPrev]  = request.security(htfTicker, "1",   f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dir5mCur,  dir5mPrev]  = request.security(htfTicker, "5",   f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dir15mCur, dir15mPrev] = request.security(htfTicker, "15",  f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dir1hCur,  dir1hPrev]  = request.security(htfTicker, "60",  f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dir4hCur,  dir4hPrev]  = request.security(htfTicker, "240", f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dirDCur,   dirDPrev]   = request.security(htfTicker, "D",   f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[dirWCur,   dirWPrev]   = request.security(htfTicker, "W",   f_candleDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// ROC on the ROC timeframe: live value of the current candle, previous candle's value, candle time
f_roc() =>
    float r = ta.roc(close, rocLenInput)
    [r, r[1], time]

[rocCur, rocPrev, rocTime] = request.security(htfTicker, rocTfInput, f_roc(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

f_dirText(int d)  => d == 1 ? "▲" : d == -1 ? "▼" : "■"
f_dirColor(int d) => d == 1 ? bullColorInput : d == -1 ? bearColorInput : neutralColorInput

f_pct(float v) => na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "0.0") + "%"
f_pctColor(float v) => na(v) or v == 0 ? neutralColorInput : v > 0 ? bullColorInput : bearColorInput

// ROC signal: checked in order — flips, stretched, buyers/sellers losing, strong
f_rocSignal(float cur, float prev) =>
    string s = "—"
    color  c = neutralColorInput
    if not na(cur) and not na(prev)
        if cur > 0 and prev <= 0
            s := "FLIP UP"
            c := bullColorInput
        else if cur < 0 and prev >= 0
            s := "FLIP DOWN"
            c := bearColorInput
        else if math.abs(cur) >= rocStretchInput
            s := "STRETCHED"
            c := warnColorInput
        else if cur > 0 and cur < prev
            s := "BUYERS LOSING"
            c := warnColorInput
        else if cur < 0 and cur > prev
            s := "SELLERS LOSING"
            c := warnColorInput
        else if cur > 0
            s := "STRONG ↑"
            c := bullColorInput
        else if cur < 0
            s := "STRONG ↓"
            c := bearColorInput
    [s, c]

var table dashTable = table.new(position.middle_right, 4, 12, bgcolor = bgColorInput, border_width = 1, border_color = color.new(color.gray, 50))

f_row(int row, string tf, int cur, int prev) =>
    table.cell(dashTable, 0, row, tf,             text_color = labelColorInput,  text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 1, row, f_dirText(cur),  text_color = f_dirColor(cur),  text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 2, row, f_dirText(prev), text_color = f_dirColor(prev), text_size = dashboardTextSize, bgcolor = bgColorInput)

string rocLabel = "ROC " + str.tostring(rocLenInput) + rocTfInput

if showDashboardInput and barstate.islast
    table.cell(dashTable, 0, 0, "TF",       text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 1, 0, "Current",  text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 2, 0, "Previous", text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 3, 0, "Signal",   text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    f_row(1, "1M",  dir1mCur,  dir1mPrev)
    f_row(2, "5M",  dir5mCur,  dir5mPrev)
    f_row(3, "15M", dir15mCur, dir15mPrev)
    f_row(4, "1H",  dir1hCur,  dir1hPrev)
    f_row(5, "4H",  dir4hCur,  dir4hPrev)
    f_row(6, "D",   dirDCur,   dirDPrev)
    f_row(7, "W",   dirWCur,   dirWPrev)
    if showRocRowInput
        [sigTxt, sigCol] = f_rocSignal(rocCur, rocPrev)
        table.cell(dashTable, 0, 8, rocLabel,          text_color = labelColorInput,       text_size = dashboardTextSize, bgcolor = bgColorInput)
        table.cell(dashTable, 1, 8, f_pct(rocCur),     text_color = f_pctColor(rocCur),    text_size = dashboardTextSize, bgcolor = bgColorInput)
        table.cell(dashTable, 2, 8, f_pct(rocPrev),    text_color = f_pctColor(rocPrev),   text_size = dashboardTextSize, bgcolor = bgColorInput)
        table.cell(dashTable, 3, 8, sigTxt,            text_color = sigCol,                text_size = dashboardTextSize, bgcolor = bgColorInput)

// ── Flip alerts: at each new 1H / 4H / Daily candle open, last closed vs one before ──
// With the body filter on, a candle whose body < ATR × multiplier counts as neutral (0) → no flip
f_closedDirs() =>
    float atrH = ta.atr(bodyAtrLenInput)
    float thr  = bodyFilterInput ? bodyMinAtrInput * atrH : 0.0
    float body = math.abs(close - open)
    bool  big  = not na(thr) and body >= thr
    int d = big and close > open ? 1 : big and close < open ? -1 : 0
    [d[1], d[2], time]

[c1hLast, c1hPrior, t1h] = request.security(htfTicker, "60",  f_closedDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[c4hLast, c4hPrior, t4h] = request.security(htfTicker, "240", f_closedDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[cDLast,  cDPrior,  tD]  = request.security(htfTicker, "D",   f_closedDirs(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool new1h = ta.change(t1h) != 0
bool new4h = ta.change(t4h) != 0
bool newD  = ta.change(tD)  != 0

string flipMsg = ""
if a1hBullInput and new1h and c1hPrior == -1 and c1hLast == 1
    flipMsg += "1H BEAR→BULL | "
if a1hBearInput and new1h and c1hPrior == 1 and c1hLast == -1
    flipMsg += "1H BULL→BEAR | "
if a4hBullInput and new4h and c4hPrior == -1 and c4hLast == 1
    flipMsg += "4H BEAR→BULL | "
if a4hBearInput and new4h and c4hPrior == 1 and c4hLast == -1
    flipMsg += "4H BULL→BEAR | "
if aDBullInput and newD and cDPrior == -1 and cDLast == 1
    flipMsg += "D BEAR→BULL | "
if aDBearInput and newD and cDPrior == 1 and cDLast == -1
    flipMsg += "D BULL→BEAR | "

// ── ROC alerts: live ROC crosses a threshold from the other side of the previous candle's ROC; once per ROC candle ──
varip int  rocCandle = na
varip bool rocUpDone = false
varip bool rocDnDone = false
string rocMsg = ""
if barstate.isrealtime and not na(rocCur) and not na(rocPrev) and not na(rocTime)
    if na(rocCandle) or rocTime != rocCandle
        rocCandle := rocTime
        rocUpDone := false
        rocDnDone := false
    if aRocUpInput and not rocUpDone and rocPrev <= rocUpThrInput and rocCur > rocUpThrInput
        rocUpDone := true
        rocMsg += rocLabel + " ABOVE " + f_pct(rocUpThrInput) + " (" + f_pct(rocCur) + ") | "
    if aRocDnInput and not rocDnDone and rocPrev >= rocDnThrInput and rocCur < rocDnThrInput
        rocDnDone := true
        rocMsg += rocLabel + " BELOW " + f_pct(rocDnThrInput) + " (" + f_pct(rocCur) + ") | "

// ── Volume: Pre-market 04:00–09:30 and RTH 09:30–16:00 NY time (EST/EDT auto), always extended data ──
string volTicker = ticker.modify(syminfo.tickerid, session = session.extended)
int PM_SLOTS  = 66   // 04:00–09:30 in 5-min slots
int RTH_SLOTS = 78   // 09:30–16:00 in 5-min slots
int MAX_DAYS  = 30

f_avgLast(array<float> a, int n) =>
    int sz = a.size()
    float result = na
    if sz >= n
        float s = 0.0
        for i = sz - n to sz - 1
            s += a.get(i)
        result := s / n
    result

// Avg cumulative volume at a given 5-min slot over the last n stored days (circular buffer)
f_todAvg(matrix<float> m, int ptr, int days, int slot, int n) =>
    float result = na
    if days >= n
        float s = 0.0
        for k = 1 to n
            s += m.get((ptr - k + MAX_DAYS) % MAX_DAYS, slot)
        result := s / n
    result

f_sessVol() =>
    string tz = "America/New_York"
    bool inPM  = not na(time(timeframe.period, "0400-0930:23456", tz))
    bool inRTH = not na(time(timeframe.period, "0930-1600:23456", tz))
    bool pmStart  = inPM  and not inPM[1]
    bool rthStart = inRTH and not inRTH[1]
    int  mins     = hour(time, tz) * 60 + minute(time, tz)
    int  pmSlot   = math.max(0, math.min(PM_SLOTS - 1,  int((mins - 240) / 5)))
    int  rthSlot  = math.max(0, math.min(RTH_SLOTS - 1, int((mins - 570) / 5)))
    var float pmVol   = 0.0
    var float rthVol  = 0.0
    var int   pmId    = 0
    var int   rthId   = 0
    var bool  pmSeen  = false
    var bool  rthSeen = false
    var array<float> pmHist  = array.new<float>()
    var array<float> rthHist = array.new<float>()
    var matrix<float> pmMat  = matrix.new<float>(MAX_DAYS, PM_SLOTS, na)
    var matrix<float> rthMat = matrix.new<float>(MAX_DAYS, RTH_SLOTS, na)
    var array<float> pmToday  = array.new<float>(PM_SLOTS, na)
    var array<float> rthToday = array.new<float>(RTH_SLOTS, na)
    var int pmPtr   = 0
    var int rthPtr  = 0
    var int pmDays  = 0
    var int rthDays = 0
    // Archive the previous session (full total + forward-filled time-of-day curve), then reset
    if pmStart
        if pmSeen
            pmHist.push(pmVol)
            if pmHist.size() > MAX_DAYS
                pmHist.shift()
            float lastP = 0.0
            for c = 0 to PM_SLOTS - 1
                float v = pmToday.get(c)
                lastP := na(v) ? lastP : v
                pmMat.set(pmPtr, c, lastP)
            pmPtr  := (pmPtr + 1) % MAX_DAYS
            pmDays := math.min(pmDays + 1, MAX_DAYS)
        pmToday.fill(float(na))
        pmSeen := true
        pmVol  := 0.0
        pmId   += 1
    if rthStart
        if rthSeen
            rthHist.push(rthVol)
            if rthHist.size() > MAX_DAYS
                rthHist.shift()
            float lastR = 0.0
            for c = 0 to RTH_SLOTS - 1
                float v = rthToday.get(c)
                lastR := na(v) ? lastR : v
                rthMat.set(rthPtr, c, lastR)
            rthPtr  := (rthPtr + 1) % MAX_DAYS
            rthDays := math.min(rthDays + 1, MAX_DAYS)
        rthToday.fill(float(na))
        rthSeen := true
        rthVol  := 0.0
        rthId   += 1
    if inPM
        pmVol += nz(volume)
        pmToday.set(pmSlot, pmVol)
    if inRTH
        rthVol += nz(volume)
        rthToday.set(rthSlot, rthVol)
    // Outside its session, compare against the full-session slot (last slot)
    int pmS  = inPM  ? pmSlot  : PM_SLOTS - 1
    int rthS = inRTH ? rthSlot : RTH_SLOTS - 1
    float pm7   = todMode ? f_todAvg(pmMat,  pmPtr,  pmDays,  pmS,  7)  : f_avgLast(pmHist, 7)
    float pm30  = todMode ? f_todAvg(pmMat,  pmPtr,  pmDays,  pmS,  30) : f_avgLast(pmHist, 30)
    float rth7  = todMode ? f_todAvg(rthMat, rthPtr, rthDays, rthS, 7)  : f_avgLast(rthHist, 7)
    float rth30 = todMode ? f_todAvg(rthMat, rthPtr, rthDays, rthS, 30) : f_avgLast(rthHist, 30)
    [pmVol, pm7, pm30, pmId, rthVol, rth7, rth30, rthId]

[pmVol, pmAvg7, pmAvg30, pmId, rthVol, rthAvg7, rthAvg30, rthId] = request.security(volTicker, "5", f_sessVol(), gaps = barmerge.gaps_off)

// varip = survives realtime ticks, so each volume alert fires once per session
varip int  lastPmId   = -1
varip int  lastRthId  = -1
varip bool pm7Done    = false
varip bool pm30Done   = false
varip bool rth7Done   = false
varip bool rth30Done  = false
varip int  lastFlipBar = -1

// varip label state: keeps the label on its bar through realtime tick rollbacks
varip int    pmLblBar  = -1
varip string pmLblTxt  = ""
varip color  pmLblCol  = color.orange
varip int    rthLblBar = -1
varip string rthLblTxt = ""
varip color  rthLblCol = color.blue

if pmId != lastPmId
    lastPmId := pmId
    pm7Done  := false
    pm30Done := false
if rthId != lastRthId
    lastRthId := rthId
    rth7Done  := false
    rth30Done := false

f_v(float v) => str.tostring(v, format.volume)
f_x(float v, float a) => not na(a) and a > 0 ? str.tostring(v / a, "0.0") + "x" : "—"
string modeTag = todMode ? " (same time)" : " (full day)"

// Latches always update; toggles only control whether the message/label is produced
string volMsg = ""
if not pm7Done and not na(pmAvg7) and pmAvg7 > 0 and pmVol > pmAvg7 * volMultInput
    pm7Done := true
    if aPm7Input
        volMsg += "PM VOL " + f_x(pmVol, pmAvg7) + " 7D AVG" + modeTag + " (" + f_v(pmVol) + " vs " + f_v(pmAvg7) + ") | "
        string t = "PM7 " + f_x(pmVol, pmAvg7)
        pmLblTxt := pmLblBar == bar_index ? pmLblTxt + "\n" + t : t
        pmLblBar := bar_index
        pmLblCol := pm7ColInput
if not pm30Done and not na(pmAvg30) and pmAvg30 > 0 and pmVol > pmAvg30 * volMultInput
    pm30Done := true
    if aPm30Input
        volMsg += "PM VOL " + f_x(pmVol, pmAvg30) + " 30D AVG" + modeTag + " (" + f_v(pmVol) + " vs " + f_v(pmAvg30) + ") | "
        string t = "PM30 " + f_x(pmVol, pmAvg30)
        pmLblTxt := pmLblBar == bar_index ? pmLblTxt + "\n" + t : t
        pmLblBar := bar_index
        pmLblCol := pm30ColInput
if not rth7Done and not na(rthAvg7) and rthAvg7 > 0 and rthVol > rthAvg7 * volMultInput
    rth7Done := true
    if aRth7Input
        volMsg += "RTH VOL " + f_x(rthVol, rthAvg7) + " 7D AVG" + modeTag + " (" + f_v(rthVol) + " vs " + f_v(rthAvg7) + ") | "
        string t = "R7 " + f_x(rthVol, rthAvg7)
        rthLblTxt := rthLblBar == bar_index ? rthLblTxt + "\n" + t : t
        rthLblBar := bar_index
        rthLblCol := rth7ColInput
if not rth30Done and not na(rthAvg30) and rthAvg30 > 0 and rthVol > rthAvg30 * volMultInput
    rth30Done := true
    if aRth30Input
        volMsg += "RTH VOL " + f_x(rthVol, rthAvg30) + " 30D AVG" + modeTag + " (" + f_v(rthVol) + " vs " + f_v(rthAvg30) + ") | "
        string t = "R30 " + f_x(rthVol, rthAvg30)
        rthLblTxt := rthLblBar == bar_index ? rthLblTxt + "\n" + t : t
        rthLblBar := bar_index
        rthLblCol := rth30ColInput

// ── Tiny volume labels (redrawn each tick on the fire bar, so they never vanish intrabar) ──
if showVolLblInput and pmLblBar == bar_index
    label.new(bar_index, high, pmLblTxt, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.white, 100), textcolor = pmLblCol, size = volLblSize)
if showVolLblInput and rthLblBar == bar_index
    label.new(bar_index, low, rthLblTxt, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.white, 100), textcolor = rthLblCol, size = volLblSize)

// ── Dashboard volume rows ──
f_xColor(float v, float a) => not na(a) and a > 0 and v > a * volMultInput ? bullColorInput : labelColorInput

if showDashboardInput and showVolRowsInput and barstate.islast
    table.cell(dashTable, 0, 9, todMode ? "Vol@Time" : "Vol Day", text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 1, 9, "vs 7D",  text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 2, 9, "vs 30D", text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 0, 10, "PM",  text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 1, 10, f_x(pmVol, pmAvg7),   text_color = f_xColor(pmVol, pmAvg7),   text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 2, 10, f_x(pmVol, pmAvg30),  text_color = f_xColor(pmVol, pmAvg30),  text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 0, 11, "RTH", text_color = labelColorInput, text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 1, 11, f_x(rthVol, rthAvg7),  text_color = f_xColor(rthVol, rthAvg7),  text_size = dashboardTextSize, bgcolor = bgColorInput)
    table.cell(dashTable, 2, 11, f_x(rthVol, rthAvg30), text_color = f_xColor(rthVol, rthAvg30), text_size = dashboardTextSize, bgcolor = bgColorInput)

string msg = ""
if flipMsg != "" and lastFlipBar != bar_index
    lastFlipBar := bar_index
    msg += flipMsg
msg += rocMsg
msg += volMsg

if enableAlertsInput and msg != ""
    alert(syminfo.ticker + " | " + msg + "Price " + str.tostring(close, format.mintick), alert.freq_all)
````
