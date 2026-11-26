# The Beast ICT SMC Master Engine

- url: https://www.tradingview.com/script/1nhJ8buW-The-Beast-ICT-SMC-Master-Engine/
- type: indicator
- pine_id: PUB;3e2c43b32b92425382836b5b655f1eac
- version: 2.0

## Description

The Beast — ICT SMC Master Engine
The Beast is a consolidated, all-in-one TradingView indicator that merges eleven separate ICT (Inner Circle Trader) and Smart Money Concepts tools into a single script. Every module can be switched on or off independently, so you can run the full suite or isolate just the pieces you need.
Core Modules
1. Real-Time Multi-Timeframe Standard Deviations
Tracks swing highs and lows across four independently configurable timeframes (default 2m, 15m, 1h, 4h) and projects standard deviation levels above and below each swing, using a customizable list of deviation multiples (e.g. 1.0, -1.0, -2.0, -3.0, etc.). Projections auto-invalidate when price breaks back through the origin swing.
2. Market Structure & Fibonacci OTE
Identifies major swing highs/lows and tags them as HH, HL, LH, or LL. Flags Break of Structure (BOS) and Change of Character (CHoCH) events, detects liquidity sweeps of prior swing highs/lows, and automatically draws an Optimal Trade Entry (OTE) box with individual Fibonacci retracement lines (.50, .62, .705, .786, .85) whenever structure breaks.
3. Benchmark Key Levels & Specific Entries
Plots Previous Day High/Low/Close, Previous Week High/Low, Previous Month High/Low, and Daily/Weekly/Monthly Opens. Also marks the Midnight Open (00:00) and 4:00 AM Open, two levels commonly used as intraday entry references in ICT-style trading.
4. Sessions: Asia, London, NY ORB & RTH
Shades and tracks the high, low, and midpoint of the Asia session, London session, and New York Opening Range (default first 15 minutes, 9:30–9:45). Also highlights Regular Trading Hours (9:30–16:00). All session windows and colors are configurable.
5. Supply & Demand Zones
Detects sharp expansion candles (large range relative to ATR, breaking the prior candle's high/low) and draws supply or demand zones from the candle before the expansion, with an optional open-price reaction line.
6. Order Blocks (Standalone)
Marks the last opposing candle before a structural break as an order block, extending only the closest N blocks (configurable) to live price to avoid clutter.
7. Breaker Blocks (Standalone)
Converts order blocks into breaker blocks once price closes back through them, changing their color scheme to reflect the shift in role, and again only extends the closest N to current price.
8. Master Fair Value Gap & Stacked Imbalance Engine
Detects 3-candle Fair Value Gaps (FVGs) on the execution timeframe, plots a Consequent Encroachment (50% CE) line through each gap, and removes gaps once they're mitigated to a configurable threshold (wick or close-based). Only the closest N active FVGs are extended live.
9. Quad Ehlers SuperSmoother Trend Suite
Four independently configurable SuperSmoother moving averages (fast/medium/slow/trend), each with its own length, timeframe, color, and width — a low-lag alternative to standard moving averages for gauging trend direction.
10. TDA Ladder Dashboard & Confluence
A multi-timeframe bias ladder (default Daily, 4H, 1H, 15m) showing bullish/bearish bias, premium/discount/equilibrium location, and a letter grade (A/B/C) per timeframe. Combines these into a weighted confluence score, and fires an "A+" triangle signal (with alert) when bias, price location, structure, and the lowest timeframe grade all align.
Right-Side Level Labels
All Key Levels and Session levels (module 3 and 4) are rendered together on the right edge of the chart. Each level — PDH, PDL, PDC, session highs/lows/midpoints, periodic opens, etc. — gets its own distinct label. If another level sits close by in price, the label automatically shifts above or below its line so the text stays readable instead of being obscured by thick lines. The vertical offset is adjustable via the "Right-Side Label Positioning" input group.
Alerts
Built-in alert conditions fire on:
Confluence Long A+ / Short A+ signals
Bullish and Bearish structure breaks (BOS/CHoCH)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2026 jonathanbell1018 - Beast Sweep Tracker (written from scratch)
// Marks the candle where price sweeps a key level (wicks through it) and reclaims it (closes back on the
// original side) within a few candles. Grades each sweep by confluence and shows the stop (the sweep wick).
//@version=6
indicator("Beast Sweep Tracker", shorttitle = "Beast Sweeps", overlay = true, max_lines_count = 200, max_labels_count = 200)

// ═════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════
string g_LV = "Levels to Watch"
string g_SW = "Sweep Rules"
string g_GR = "Grading"
string g_SS = "Session Times"
string g_DS = "Display & Alerts"

onAsia  = input.bool(true, "Asia High / Low",     group = g_LV, tooltip = "Tick the levels whose sweeps you want marked.")
onLdn   = input.bool(true, "London High / Low",   group = g_LV)
onPD    = input.bool(true, "PDH / PDL",           group = g_LV)
onNY    = input.bool(true, "Last NY High / Low",  group = g_LV, tooltip = "High and low of the most recent completed New York session. Useful during Asia and London, and for the next day's NY open.")
onOrb   = input.bool(true, "ORB High / Low",      group = g_LV)
onSwing = input.bool(true, "Recent Swing Highs / Lows", group = g_LV, tooltip = "Adds the most recent swing highs and lows (internal liquidity) to the watch list.")
swLen   = input.int(10, "Swing Strength (bars each side)", minval = 3, maxval = 50, group = g_LV, tooltip = "A swing high needs this many lower highs on each side. Higher = fewer, more important swings. A swing only becomes a level after this many bars have passed.")
swMax   = input.int(3, "Swings Kept (each side)", minval = 1, maxval = 10, group = g_LV)

pierce   = input.float(1.0,  "Min Sweep Depth (points)", minval = 0.25, step = 0.25, group = g_SW, tooltip = "How far the wick must poke past the level to count as a sweep. Filters out wicks that only kiss the level.")
maxDepth = input.float(40.0, "Max Sweep Depth (points)", minval = 1.0, step = 1.0, group = g_SW, tooltip = "If price runs further than this past the level, it is treated as a real break, not a sweep, and no signal fires.")
reclaimN = input.int(3, "Candles Allowed to Reclaim", minval = 1, maxval = 20, group = g_SW, tooltip = "After the wick goes through, price must CLOSE back on the original side within this many candles. 1 = the reclaim must happen on the very next candle (or the sweep candle itself).")

stackBand = input.float(5.0, "Stacked Level Band (points)", minval = 0.25, step = 0.25, group = g_GR, tooltip = "Other key levels within this distance of the swept level count as stacked liquidity (e.g. Power Hour low sitting on London Low). +1 grade point.")
dispMult  = input.float(0.8, "Displacement (x ATR)", minval = 0.1, step = 0.1, group = g_GR, tooltip = "The reclaim candle's body must be at least this many ATRs, in the direction of the reversal, to count as displacement. +1 grade point.")
atrLen    = input.int(14, "ATR Length", minval = 1, group = g_GR)
kzLdnOn   = input.bool(true, "London",  inline = "k1", group = g_GR, tooltip = "Sweeps inside an active window (killzone) get +1 grade point. Times use the timezone in Session Times.")
kzLdn     = input.session("0200-0500", "", inline = "k1", group = g_GR)
kzAmOn    = input.bool(true, "NY AM",   inline = "k2", group = g_GR)
kzAm      = input.session("0930-1130", "", inline = "k2", group = g_GR)
kzPmOn    = input.bool(true, "NY PM",   inline = "k3", group = g_GR)
kzPm      = input.session("1330-1600", "", inline = "k3", group = g_GR)
minGrade  = input.string("C", "Minimum Grade to Show", options = ["A", "B", "C", "D"], group = g_GR, tooltip = "A = stacked + displacement + killzone. B = two of the three. C = one. D = plain sweep. Signals below this grade are hidden and do not alert.")

tz       = input.string("America/New_York", "Timezone", group = g_SS)
asiaSess = input.session("2200-0000", "Asia Range",   group = g_SS)
ldnSess  = input.session("0200-0400", "London Range", group = g_SS)
nySess   = input.session("0930-1600", "NY Session",   group = g_SS)
orbSess  = input.session("0930-0945", "Opening Range (ORB)", group = g_SS)

maxSig    = input.int(30, "Max Signals Kept on Chart", minval = 1, maxval = 100, group = g_DS)
sigSizeIn = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal"], group = g_DS)
bullCol   = input.color(color.new(#089981, 0), "Bullish Sweep Color", group = g_DS)
bearCol   = input.color(color.new(#f23645, 0), "Bearish Sweep Color", group = g_DS)
showLvls  = input.bool(false, "Draw watched levels", group = g_DS, tooltip = "Off by default, since Beast Tap Counter already draws the key levels. Turn on to use this script alone.")
showTbl   = input.bool(true, "Show Sweep Table", group = g_DS)
tblPosIn  = input.string("Top Left", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group = g_DS)
alertsOn  = input.bool(true, "Fire alert on a new sweep", group = g_DS, tooltip = "Create an alert on the indicator and choose 'Any alert() function call'.")

// ═════════════════════════════════════════
// TYPES & STATE
// ═════════════════════════════════════════
type Lvl
    string name
    bool   on
    float  px       = na
    int    setBar   = na
    int    setTime  = na
    bool   usedBull = false
    bool   usedBear = false
    int    pBull    = na      // bar where a sweep below started
    int    pBullT   = na
    float  xBull    = na      // lowest wick during that sweep
    int    pBear    = na      // bar where a sweep above started
    int    pBearT   = na
    float  xBear    = na      // highest wick during that sweep

type Rng
    float hi  = na
    float lo  = na
    bool  inS = false

var array<Lvl> keys = array.from(
     Lvl.new("Asia High", onAsia), Lvl.new("Asia Low", onAsia),
     Lvl.new("London High", onLdn), Lvl.new("London Low", onLdn),
     Lvl.new("PDH", onPD), Lvl.new("PDL", onPD),
     Lvl.new("NY High", onNY), Lvl.new("NY Low", onNY),
     Lvl.new("ORB High", onOrb), Lvl.new("ORB Low", onOrb))
int I_AH = 0, int I_AL = 1, int I_LH = 2, int I_LL = 3, int I_PDH = 4
int I_PDL = 5, int I_NH = 6, int I_NL = 7, int I_OH = 8, int I_OL = 9

var array<Lvl> swH = array.new<Lvl>()
var array<Lvl> swL = array.new<Lvl>()

var Rng asiaR = Rng.new()
var Rng ldnR  = Rng.new()
var Rng nyR   = Rng.new()
var Rng orbR  = Rng.new()

var array<label>  sigLbls = array.new_label()
var array<line>   sigLns  = array.new_line()
var array<string> logTime = array.new_string()
var array<string> logLvl  = array.new_string()
var array<int>    logDir  = array.new_int()
var array<string> logGrd  = array.new_string()
var array<float>  logStop = array.new_float()
var array<float>  logRisk = array.new_float()

float atr       = ta.atr(atrLen)
float prevClose = close[1]
bool  inKZ      = (kzLdnOn and not na(time(timeframe.period, kzLdn, tz))) or (kzAmOn and not na(time(timeframe.period, kzAm, tz))) or (kzPmOn and not na(time(timeframe.period, kzPm, tz)))

// ═════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════
f_set(Lvl l, float px, int t) =>
    l.px       := px
    l.setBar   := bar_index
    l.setTime  := t
    l.usedBull := false
    l.usedBear := false
    l.pBull    := na
    l.pBear    := na
    l.xBull    := na
    l.xBear    := na

f_clear(Lvl l) =>
    l.px    := na
    l.pBull := na
    l.pBear := na

f_range(Rng r, string sess) =>
    bool inS     = not na(time(timeframe.period, sess, tz))
    bool started = inS and not r.inS
    bool done    = not inS and r.inS
    if started
        r.hi := high
        r.lo := low
    else if inS
        r.hi := math.max(r.hi, high)
        r.lo := math.min(r.lo, low)
    r.inS := inS
    [started, done]

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_gradeTxt(int sc) =>
    sc >= 3 ? "A" : sc == 2 ? "B" : sc == 1 ? "C" : "D"

f_minScore(string g) =>
    g == "A" ? 3 : g == "B" ? 2 : g == "C" ? 1 : 0

// Counts other active levels stacked within the band of price p and lists their names
f_stackIn(array<Lvl> arr, float p, string selfName, int n0, string s0) =>
    int    n = n0
    string s = s0
    for o in arr
        if o.on and not na(o.px) and math.abs(o.px - p) <= stackBand and not (o.name == selfName and o.px == p)
            n += 1
            s := s + " + " + o.name
    [n, s]

f_stack(float p, string selfName) =>
    [n1, s1] = f_stackIn(keys, p, selfName, 0, "")
    [n2, s2] = f_stackIn(swH, p, selfName, n1, s1)
    [n3, s3] = f_stackIn(swL, p, selfName, n2, s2)
    [n3, s3]

f_fmt(float v) =>
    str.tostring(v, format.mintick)

// Draws and logs one sweep signal
f_signal(Lvl l, int dir, float ext, int t0) =>
    bool   disp  = dir == 1 ? (close > open and close - open >= atr * dispMult) : (close < open and open - close >= atr * dispMult)
    [nStk, stkNames] = f_stack(l.px, l.name)
    int    score = (nStk > 0 ? 1 : 0) + (disp ? 1 : 0) + (inKZ ? 1 : 0)
    string grade = f_gradeTxt(score)
    if score >= f_minScore(minGrade)
        float  stop = dir == 1 ? ext - syminfo.mintick : ext + syminfo.mintick
        float  risk = math.abs(close - stop)
        color  c    = dir == 1 ? bullCol : bearCol
        string tags = (nStk > 0 ? " stacked" : "") + (disp ? " disp" : "") + (inKZ ? " kz" : "")
        string txt  = (dir == 1 ? "▲ SWEEP " : "▼ SWEEP ") + l.name + stkNames + "\nGrade " + grade + (tags != "" ? " (" + str.trim(tags) + ")" : "") + "\nStop " + f_fmt(stop) + " · Risk " + str.tostring(risk, "#.##")
        sigLbls.push(label.new(time, dir == 1 ? ext : ext, txt, xloc.bar_time, yloc.price, color = color.new(c, 15), style = dir == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, size = f_size(sigSizeIn)))
        sigLns.push(line.new(t0, l.px, time, l.px, xloc.bar_time, color = c, width = 2, style = line.style_dotted))
        while sigLbls.size() > maxSig
            label.delete(sigLbls.shift())
        while sigLns.size() > maxSig
            line.delete(sigLns.shift())
        logTime.unshift(str.format_time(time, "EEE HH:mm", tz))
        logLvl.unshift(l.name)
        logDir.unshift(dir)
        logGrd.unshift(grade)
        logStop.unshift(stop)
        logRisk.unshift(risk)
        while logTime.size() > 6
            logTime.pop()
            logLvl.pop()
            logDir.pop()
            logGrd.pop()
            logStop.pop()
            logRisk.pop()
    score >= f_minScore(minGrade) ? l.name + (dir == 1 ? " swept & reclaimed (bullish)" : " swept & reclaimed (bearish)") + ", grade " + grade + ". " : ""

// Sweep engine for one level, run on each closed candle. Returns alert text if a signal fired.
f_proc(Lvl l) =>
    string msg = ""
    if l.on and not na(l.px) and not na(l.setBar) and bar_index > l.setBar and barstate.isconfirmed
        float p = l.px
        // Bullish: wick goes BELOW a level price was above, then closes back above it
        if not l.usedBull
            if na(l.pBull)
                if low <= p - pierce and prevClose >= p
                    l.pBull  := bar_index
                    l.pBullT := time
                    l.xBull  := low
            else
                l.xBull := math.min(l.xBull, low)
            if not na(l.pBull)
                if p - l.xBull > maxDepth
                    l.usedBull := true
                    l.pBull    := na
                else if close > p
                    msg += f_signal(l, 1, l.xBull, l.pBullT)
                    l.usedBull := true
                    l.pBull    := na
                else if bar_index - l.pBull >= reclaimN
                    l.usedBull := true
                    l.pBull    := na
        // Bearish: wick goes ABOVE a level price was below, then closes back below it
        if not l.usedBear
            if na(l.pBear)
                if high >= p + pierce and prevClose <= p
                    l.pBear  := bar_index
                    l.pBearT := time
                    l.xBear  := high
            else
                l.xBear := math.max(l.xBear, high)
            if not na(l.pBear)
                if l.xBear - p > maxDepth
                    l.usedBear := true
                    l.pBear    := na
                else if close < p
                    msg += f_signal(l, -1, l.xBear, l.pBearT)
                    l.usedBear := true
                    l.pBear    := na
                else if bar_index - l.pBear >= reclaimN
                    l.usedBear := true
                    l.pBear    := na
    msg

// ═════════════════════════════════════════
// BUILD THE LEVELS
// ═════════════════════════════════════════
[aS, aD] = f_range(asiaR, asiaSess)
[lS, lD] = f_range(ldnR,  ldnSess)
[nS, nD] = f_range(nyR,   nySess)
[oS, oD] = f_range(orbR,  orbSess)

if aS
    f_clear(keys.get(I_AH))
    f_clear(keys.get(I_AL))
if aD
    f_set(keys.get(I_AH), asiaR.hi, time)
    f_set(keys.get(I_AL), asiaR.lo, time)
if lS
    f_clear(keys.get(I_LH))
    f_clear(keys.get(I_LL))
if lD
    f_set(keys.get(I_LH), ldnR.hi, time)
    f_set(keys.get(I_LL), ldnR.lo, time)
// the last NY high/low stay live through the next NY session and get replaced when it closes
if nD
    f_set(keys.get(I_NH), nyR.hi, time)
    f_set(keys.get(I_NL), nyR.lo, time)
if oS
    f_clear(keys.get(I_OH))
    f_clear(keys.get(I_OL))
if oD
    f_set(keys.get(I_OH), orbR.hi, time)
    f_set(keys.get(I_OL), orbR.lo, time)

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
if timeframe.change("D") and not na(pdh)
    f_set(keys.get(I_PDH), pdh, time)
    f_set(keys.get(I_PDL), pdl, time)

// swing highs / lows (confirmed swLen bars after they print)
float ph  = ta.pivothigh(high, swLen, swLen)
float pl  = ta.pivotlow(low, swLen, swLen)
int   pvT = time[swLen]
if onSwing and not na(ph)
    Lvl s = Lvl.new("Swing High", true)
    f_set(s, ph, pvT)
    swH.push(s)
    while swH.size() > swMax
        swH.shift()
if onSwing and not na(pl)
    Lvl s = Lvl.new("Swing Low", true)
    f_set(s, pl, pvT)
    swL.push(s)
    while swL.size() > swMax
        swL.shift()

// ═════════════════════════════════════════
// RUN THE SWEEP ENGINE
// ═════════════════════════════════════════
string alertMsg = ""
for l in keys
    alertMsg += f_proc(l)
for l in swH
    alertMsg += f_proc(l)
for l in swL
    alertMsg += f_proc(l)

if alertsOn and alertMsg != ""
    alert(syminfo.ticker + ": " + alertMsg, alert.freq_once_per_bar_close)

// ═════════════════════════════════════════
// DISPLAY (last bar only)
// ═════════════════════════════════════════
f_pos(string p) =>
    switch p
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        => position.top_left

var table tbl = table.new(f_pos(tblPosIn), 5, 16, border_width = 1, border_color = color.new(color.gray, 60))
var array<line>  lvLns  = array.new_line()
var array<label> lvLbls = array.new_label()

f_drawLvl(Lvl l) =>
    if l.on and not na(l.px) and not na(l.setTime)
        color c = color.new(chart.fg_color, 50)
        lvLns.push(line.new(l.setTime, l.px, time, l.px, xloc.bar_time, extend.right, color = c, style = line.style_dotted))
        lvLbls.push(label.new(bar_index + 5, l.px, l.name, xloc.bar_index, yloc.price, color = color.new(color.black, 100), style = label.style_label_left, textcolor = c, size = size.tiny))

f_pendRow(Lvl l, int r) =>
    int rr = r
    if l.on and not na(l.px)
        if not na(l.pBull)
            table.cell(tbl, 0, rr, "Pending", text_color = color.black, bgcolor = color.new(color.yellow, 20), text_size = size.small)
            table.cell(tbl, 1, rr, l.name, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
            table.cell(tbl, 2, rr, "▲ swept below", text_color = bullCol, text_size = size.small)
            table.cell(tbl, 3, rr, "reclaim > " + f_fmt(l.px), text_color = chart.fg_color, text_size = size.small)
            table.cell(tbl, 4, rr, str.tostring(reclaimN - (bar_index - l.pBull)) + " left", text_color = chart.fg_color, text_size = size.small)
            rr += 1
        if not na(l.pBear) and rr < 16
            table.cell(tbl, 0, rr, "Pending", text_color = color.black, bgcolor = color.new(color.yellow, 20), text_size = size.small)
            table.cell(tbl, 1, rr, l.name, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
            table.cell(tbl, 2, rr, "▼ swept above", text_color = bearCol, text_size = size.small)
            table.cell(tbl, 3, rr, "reclaim < " + f_fmt(l.px), text_color = chart.fg_color, text_size = size.small)
            table.cell(tbl, 4, rr, str.tostring(reclaimN - (bar_index - l.pBear)) + " left", text_color = chart.fg_color, text_size = size.small)
            rr += 1
    rr

if barstate.islast
    while lvLns.size() > 0
        line.delete(lvLns.pop())
    while lvLbls.size() > 0
        label.delete(lvLbls.pop())
    if showLvls
        for l in keys
            f_drawLvl(l)
        for l in swH
            f_drawLvl(l)
        for l in swL
            f_drawLvl(l)

    if showTbl
        table.clear(tbl, 0, 0, 4, 15)
        table.cell(tbl, 0, 0, "Time",  text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 0, "Level", text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 2, 0, "Sweep", text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 3, 0, "Stop",  text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 4, 0, "Grade / Risk", text_color = chart.fg_color, text_size = size.small)
        int r = 1
        // live sweeps still waiting for a reclaim
        for l in keys
            r := f_pendRow(l, r)
        for l in swH
            r := f_pendRow(l, r)
        for l in swL
            r := f_pendRow(l, r)
        // the last 6 confirmed sweeps, newest first
        if logTime.size() == 0 and r == 1
            table.cell(tbl, 0, 1, "No sweeps yet", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
        else
            for i = 0 to logTime.size() - 1
                if r < 16
                    int   d  = logDir.get(i)
                    color c  = d == 1 ? bullCol : bearCol
                    string g = logGrd.get(i)
                    table.cell(tbl, 0, r, logTime.get(i), text_color = chart.fg_color, text_size = size.small)
                    table.cell(tbl, 1, r, logLvl.get(i), text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
                    table.cell(tbl, 2, r, d == 1 ? "▲ Bullish" : "▼ Bearish", text_color = color.white, bgcolor = color.new(c, 15), text_size = size.small)
                    table.cell(tbl, 3, r, f_fmt(logStop.get(i)), text_color = chart.fg_color, text_size = size.small)
                    table.cell(tbl, 4, r, g + " · " + str.tostring(logRisk.get(i), "#.##") + " pts", text_color = g == "A" ? color.white : chart.fg_color, bgcolor = g == "A" ? color.new(c, 15) : color.new(color.gray, 85), text_size = size.small)
                    r += 1
````
