# Streak Forward Returns

- url: https://www.tradingview.com/script/5u1jCsDU-Streak-Forward-Returns/
- type: indicator
- pine_id: PUB;04306cebdae34bc594bed6eb833e4432
- version: 1.0

## Description

[b]Description
[/b]

What happens after a market falls, or rises, several days in a row? This indicator answers that question for any symbol on your chart.

It finds every past streak of N consecutive lower or higher closes. It then measures what the price did 1 week, 1 month, 3 months, 6 months and 12 months later. Finally, it compares those results with the symbol’s normal behavior, so you can see whether the streak actually changed the odds.

[b]How it works
[/b]

[b]Streak counter
[/b]
The lower pane plots a running count of consecutive closes. Positive bars are higher closes, negative bars are lower closes.
An unchanged close resets the count to zero.
Dashed lines mark the threshold you choose.

[b]Trigger
[/b]
An event is recorded on the bar where the streak reaches N.
Longer streaks are counted only once. A 9-day losing run with N = 7 produces one event, not three.
Each event is marked on the price chart with a triangle and a shaded background.

[b]Forward returns
[/b]
Returns are measured from the trigger bar’s close to the close of the first bar on or after the target date.
1W adds 7 calendar days. 1M, 3M, 6M and 12M add calendar months, with the day capped at month end. For example, Jan. 31 plus one month becomes Feb. 28 or 29.
If the target date falls on a weekend or holiday, the next trading session is used.

[b]Baseline
[/b]
The “All-days” columns calculate the same 1W to 12M returns starting from every bar in the loaded history.
This gives you the unconditional average and win rate.
If the post-streak numbers are not clearly better or worse than the baseline, the streak carries little information.

[b]The table
[/b]
Stats section, one row per horizon:

Events: the number of completed cases.
Avg %: the average return.
Median %: the median return, which is less distorted by outliers.
Win %: the share of positive outcomes.
Worst % and Best %: the extremes.
All-days avg % and All-days win %: the baseline.

Recent events section: the most recent triggers, each with its date, the total move during the streak, and the return at every horizon. Horizons not yet reached show “–”, so the current streak appears but is not counted in the statistics.

[b]Inputs
[/b]
Streak direction: Down or Up.
Streak length: 2 to 50 consecutive closes. Default 7.
Number of recent events to list.
Table position, text size and colors.

[b]Alerts
[/b]
An alert condition fires when the streak reaches the selected length.

[b]Notes and limitations
[/b]
Timeframe: designed for daily charts. It runs on any timeframe, but the horizons are calendar-based, so on intraday charts the streak counts intraday bars while returns still measure weeks and months.

History: results only use the history loaded on your chart. Long-history symbols may exceed your plan’s bar limit, and the table title shows the first date actually used.

Prices: close-to-close prices, dividends excluded. Enable adjustment for dividends in chart settings if you want total returns on symbols that support it.

Sample size: long streaks are rare, so samples are often small. Treat the results as historical case studies, not as statistical proof.

Not advice: past behavior does not guarantee future results. This tool is for research and education, not a trading signal or investment advice.[pine][/pine]

## Source Code

````pine
//@version=6
indicator("Streak Forward Returns", shorttitle = "Streak FwdRet", overlay = false, max_labels_count = 500)

// ───────────────────────── Inputs ─────────────────────────
string dirIn  = input.string("Down", "Streak direction", options = ["Down", "Up"])
int    nIn    = input.int(7, "Streak length (consecutive closes)", minval = 2, maxval = 50)

int    nShow  = input.int(12, "Recent events to list", minval = 0, maxval = 40, group = "Table")
string posIn  = input.string("Bottom right", "Table position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = "Table")
string sizeIn = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = "Table")

color upCol = input.color(#089981, "Up color",   group = "Style")
color dnCol = input.color(#F23645, "Down color", group = "Style")

// ───────────────────────── Streak counter ─────────────────────────
var int cnt = 0
if close > close[1]
    cnt := cnt > 0 ? cnt + 1 : 1
else if close < close[1]
    cnt := cnt < 0 ? cnt - 1 : -1
else
    cnt := 0

bool isDown = dirIn == "Down"
// Fires once per streak, on the bar the streak reaches N
bool trig = isDown ? cnt == -nIn : cnt == nIn

// ───────────────────────── History storage ─────────────────────────
var array<float> cl   = array.new<float>()
var array<int>   tm   = array.new<int>()
var array<int>   evI  = array.new<int>()
var array<float> evMv = array.new<float>()

cl.push(close)
tm.push(time)
if trig
    evI.push(cl.size() - 1)
    evMv.push((close / close[nIn] - 1) * 100)

// ───────────────────────── Plots ─────────────────────────
plot(cnt, "Consecutive closes", color = cnt >= 0 ? upCol : dnCol, style = plot.style_columns)
hline(0, "Zero", color = color.gray)
hline(nIn,  "Up threshold",   color = color.new(upCol, 40), linestyle = hline.style_dashed)
hline(-nIn, "Down threshold", color = color.new(dnCol, 40), linestyle = hline.style_dashed)
bgcolor(trig ? color.new(isDown ? dnCol : upCol, 80) : na)
plotshape(trig and isDown,     "Down-streak trigger", shape.triangleup,   location.belowbar, dnCol, size = size.small, force_overlay = true)
plotshape(trig and not isDown, "Up-streak trigger",   shape.triangledown, location.abovebar, upCol, size = size.small, force_overlay = true)
alertcondition(trig, "Streak reached N", "{{ticker}} reached the selected consecutive-close streak")

// ───────────────────────── Calendar helpers ─────────────────────────
daysIn(int y, int m) =>
    bool leap = (y % 4 == 0 and y % 100 != 0) or y % 400 == 0
    m == 2 ? (leap ? 29 : 28) : (m == 4 or m == 6 or m == 9 or m == 11) ? 30 : 31

addMonths(int t, int k) =>
    int y = year(t, syminfo.timezone)
    int m = month(t, syminfo.timezone) + k
    int d = dayofmonth(t, syminfo.timezone)
    while m > 12
        y += 1
        m -= 12
    timestamp(syminfo.timezone, y, m, math.min(d, daysIn(y, m)), hour(t, syminfo.timezone), minute(t, syminfo.timezone))

// r: 0 = 1W, 1 = 1M, 2 = 3M, 3 = 6M, 4 = 12M
targetTime(int t, int r) =>
    r == 0 ? t + 7 * 86400000 : addMonths(t, r == 1 ? 1 : r == 2 ? 3 : r == 3 ? 6 : 12)

// First bar index (>= lo0) whose time is >= tgt; -1 if the date has not been reached yet
findIdx(int tgt, int lo0) =>
    int lo = lo0
    int hi = tm.size() - 1
    int res = -1
    if tm.get(hi) >= tgt
        while lo < hi
            int mid = math.floor((lo + hi) / 2)
            if tm.get(mid) >= tgt
                hi := mid
            else
                lo := mid + 1
        res := lo
    res

fwdRet(int i0, int r) =>
    int j = findIdx(targetTime(tm.get(i0), r), i0)
    j < 0 ? na : (cl.get(j) / cl.get(i0) - 1) * 100

// ───────────────────────── Table ─────────────────────────
pos = switch posIn
    "Top right"    => position.top_right
    "Middle right" => position.middle_right
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    => position.bottom_right
txt = switch sizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

color BG   = #131722
color HDR  = #2a2e39
color TXT  = color.white
color MUTE = #b2b5be

var table tb = table.new(pos, 9, 9 + nShow, bgcolor = BG, border_color = #363a45, border_width = 1, frame_color = #363a45, frame_width = 1)

f(float x)  => na(x) ? "–" : str.tostring(x, "0.00")
cc(float x) => na(x) ? MUTE : x >= 0 ? upCol : dnCol
put(int c, int r, string s, color tc, color bg) =>
    table.cell(tb, c, r, s, text_color = tc, bgcolor = bg, text_size = txt)

if barstate.islast
    table.clear(tb, 0, 0, 8, 8 + nShow)
    lbl = array.from("1W", "1M", "3M", "6M", "12M")
    int n  = cl.size()
    int ne = evI.size()

    // Title
    string ttl = syminfo.ticker + " · " + str.tostring(ne) + " streaks of " + str.tostring(nIn) + " consecutive " + (isDown ? "lower" : "higher") + " closes · current streak: " + str.tostring(cnt) + " · history from " + str.format_time(tm.get(0), "yyyy-MM-dd", syminfo.timezone)
    put(0, 0, ttl, TXT, HDR)
    table.merge_cells(tb, 0, 0, 8, 0)

    hdr = array.from("Horizon", "Events", "Avg %", "Median %", "Win %", "Worst %", "Best %", "All-days avg %", "All-days win %")
    for c = 0 to 8
        put(c, 1, hdr.get(c), MUTE, HDR)

    for r = 0 to 4
        rets = array.new<float>()
        if ne > 0
            for k = 0 to ne - 1
                float v = fwdRet(evI.get(k), r)
                if not na(v)
                    rets.push(v)
        // Baseline: same calendar horizon from every day in the loaded history
        float bs = 0.0
        float bc = 0.0
        float bw = 0.0
        for i = 0 to n - 1
            float v = fwdRet(i, r)
            if na(v)
                break
            bs += v
            bc += 1
            if v > 0
                bw += 1
        int   m    = rets.size()
        float wins = 0.0
        for x in rets
            if x > 0
                wins += 1
        float avg  = m > 0 ? rets.avg()    : na
        float med  = m > 0 ? rets.median() : na
        float win  = m > 0 ? wins / m * 100 : na
        float mn   = m > 0 ? rets.min()    : na
        float mx   = m > 0 ? rets.max()    : na
        float bAvg = bc > 0 ? bs / bc : na
        float bWin = bc > 0 ? bw / bc * 100 : na
        int row = r + 2
        put(0, row, lbl.get(r), TXT, BG)
        put(1, row, str.tostring(m), TXT, BG)
        put(2, row, f(avg), cc(avg), BG)
        put(3, row, f(med), cc(med), BG)
        put(4, row, f(win), win >= 50 ? upCol : dnCol, BG)
        put(5, row, f(mn),  cc(mn),  BG)
        put(6, row, f(mx),  cc(mx),  BG)
        put(7, row, f(bAvg), cc(bAvg), BG)
        put(8, row, f(bWin), MUTE, BG)

    // Recent events
    put(0, 7, "Most recent events — % change after the trigger close (– = horizon not reached yet)", TXT, HDR)
    table.merge_cells(tb, 0, 7, 8, 7)
    put(0, 8, "Date", MUTE, HDR)
    put(1, 8, "Streak %", MUTE, HDR)
    for c = 0 to 4
        put(c + 2, 8, lbl.get(c), MUTE, HDR)

    if nShow > 0
        for q = 0 to nShow - 1
            int k = ne - 1 - q
            if k >= 0
                int i0  = evI.get(k)
                int row = 9 + q
                put(0, row, str.format_time(tm.get(i0), "yyyy-MM-dd", syminfo.timezone), TXT, BG)
                put(1, row, f(evMv.get(k)), cc(evMv.get(k)), BG)
                for c = 0 to 4
                    float v = fwdRet(i0, c)
                    put(c + 2, row, f(v), cc(v), BG)
````
