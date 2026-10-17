# Supertrend Filter Lab: Triple, 200 EMA, Kumo [forexobroker]

- url: https://www.tradingview.com/script/a1pYAqDL-Supertrend-Filter-Lab-Triple-200-EMA-Kumo-forexobroker/
- type: indicator
- pine_id: PUB;3284371f7fef40699abb3baa90b082c3
- version: 1.0

## Description

Supertrend Filter Lab: Triple, 200 EMA, Kumo [forexobroker]

🔶 OVERVIEW

Supertrend Filter Lab answers one question on your own chart: does filtering the Supertrend actually help, and which filter helps most? The plain Supertrend is always either long or short, so it keeps flipping when the market goes sideways. This script trades the plain Supertrend and three popular ways to filter it at the same time, the triple Supertrend, the 200 EMA and the Kumo cloud, follows every trade of every version to its exit, and compares all four in one table over exactly the same days.

You choose which version is drawn on the chart. All four are traded and logged on every bar regardless, so the comparison table is always complete.

🔶 HOW IT WORKS

1. Plain Supertrend (ATR 10, factor 3, TradingView's defaults). A buy when the line turns green, a sell when it turns red; the previous trade closes on the flip. Always in a trade.

2. Triple Supertrend (12/3, 10/1, 11/2). A trade only when all three lines turn the same colour; it closes as soon as the colours no longer match.

3. Supertrend + 200 EMA. Supertrend buys only while the close is above the 200 EMA, sells only while it is below. The entry comes from the flip, or from price crossing the EMA while the line already has the right colour. The trade closes when the Supertrend changes colour.

4. Supertrend + Kumo cloud (Ichimoku 9/26/52/26, the two lead lines only, drawn 25 bars ahead as TradingView's Ichimoku does). Supertrend buys only above the cloud, sells only below it, nothing while price is inside it. The trade closes on the first candle that closes back inside the cloud.

🔶 RISK UNIT AND STOP

Each trade's risk, one R, is the distance from the entry close to the Supertrend line the version trades on: the 12/3 line for the triple version, the default line for the other three. That line is also a protective stop: on every closed bar the stop is checked before the version's own exit, and a gap through it exits at the open. Results are counted in R (the move divided by the risk), so the four versions are measured in the same unit. The protective stop can be switched off to test the exits alone.

🔶 THE COMPARISON TABLE

The window: the days in which the anchor version (by default the + 200 EMA version, the strictest) took its last N trades (100 by default). Every version is counted over those same days, so no version looks better just because its trades fell in easier months. The window's dates and its number of bars are printed under the table.

For each version: trades, wins, total R, average R per trade, the worst losing run, and the time in market (the share of the window's bars with a trade open). The version drawn on the chart is highlighted. The last row shows the live state: the Supertrend's colour, whether the triple lines agree, the side of the EMA and of the cloud.

NON-REPAINTING: every entry, exit and result is evaluated on barstate.isconfirmed; there is no request.security and no lookahead. The cloud drawn ahead of price is the standard Ichimoku projection of values that are already known.

🔶 SETTINGS

Show
- Draw the trades of: Plain Supertrend, Triple Supertrend (default), Supertrend + 200 EMA, Supertrend + Kumo cloud.

Supertrend settings
- Default Supertrend: ATR length (10), factor (3).
- Triple lines: 12 / 3, 10 / 1, 11 / 2.

Filters
- EMA length (200).
- Kumo: conversion (9), base (26), lead line 2 (52), displacement (26).
- Protective stop on the risk line (default on).

Comparison window and table
- Window: the last trades of (default + 200 EMA), number of trades N (100).
- Show the comparison table, table position, table text size.

Visual
- Up, down, EMA and cloud colours; BUY / SELL and result labels; trades kept on chart.

Alerts
- Send JSON alert() messages for the drawn version.

🔶 ALERTS

Eight alertcondition hooks, a buy and a sell for each version: STFL Plain buy / sell, STFL Triple buy / sell, STFL 200 EMA buy / sell, STFL Kumo buy / sell. With JSON alerts on, every entry of the drawn version also fires an alert() once per bar close with a JSON body (action, version, ticker, timeframe, close).

🔶 LIMITATIONS

- The edges a filter adds can be small per trade. The table shows the average R per trade: compare it with your own spread and commission before trusting a version, especially the busier ones.
- The triple version can trade more often than the plain Supertrend, because every flip of its fast line breaks the agreement. Check the Trades column.
- Long losing runs are normal for trend following. The worst run is in the table.
- Results are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the protective stop is counted before the version's exit.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Supertrend Filter Lab — the plain Supertrend and three ways to filter it, traded side by side on the same
// chart, each with its own trade log, and one table that compares them over the same days.
// (1) Plain: the default Supertrend (ATR 10, factor 3) traded flip to flip. Always long or short.
// (2) Triple: three Supertrends (12/3, 10/1, 11/2). Enter when all three turn the same colour, exit when they no
//     longer match.
// (3) + 200 EMA: Supertrend buys only with the close above the 200 EMA, sells only below it. The entry comes from the
//     flip, or from price crossing the EMA while the line already has the right colour. Exit on the Supertrend flip.
// (4) + Kumo cloud: the Ichimoku cloud's two lead lines (9/26/52, displaced 26). Supertrend buys only with the close
//     above the cloud, sells only below it, nothing inside it. Exit on the first close back inside the cloud.
// Risk unit: the distance from the entry close to the Supertrend line the version trades on (the 12/3 line for the
// triple, the default line for the others). That line is also a protective stop, checked on every closed bar before
// the version's own exit; a gap through it exits at the open. Results are counted in R = move / risk.
// The comparison window: the days in which the anchor version (default + 200 EMA, the strictest) took its last N
// trades. Every version is counted over those same days, so the table compares like with like.
// Non-repainting: every entry, exit and result is evaluated on barstate.isconfirmed; there is no request.security and
// no lookahead. The cloud drawn ahead of price is the standard Ichimoku projection of values already known.
indicator("Supertrend Filter Lab: Triple, 200 EMA, Kumo [forexobroker]", shorttitle="STFL [fob]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_show   = "Show"
string g_st     = "Supertrend settings"
string g_filter = "Filters"
string g_log    = "Comparison window and table"
string g_vis    = "Visual"
string g_alert  = "Alerts"

string V_PLAIN  = "Plain Supertrend"
string V_TRIPLE = "Triple Supertrend"
string V_EMA    = "Supertrend + 200 EMA"
string V_KUMO   = "Supertrend + Kumo cloud"

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string i_show = input.string(V_TRIPLE, "Draw the trades of", options=[V_PLAIN, V_TRIPLE, V_EMA, V_KUMO], group=g_show, tooltip="All four versions are traded and logged on every bar. This choice only decides which one is drawn on the chart (its lines, entries and exits) and which row of the table is highlighted.")

int   i_atr0 = input.int(10, "Default Supertrend: ATR length", minval=1, maxval=200, group=g_st, tooltip="10 and 3 are TradingView's default Supertrend settings. The plain, + 200 EMA and + Kumo versions use this line.")
float i_fac0 = input.float(3.0, "Default Supertrend: factor", minval=0.1, maxval=20, step=0.1, group=g_st)
int   i_atr1 = input.int(12, "Triple line 1: ATR length", minval=1, maxval=200, group=g_st, inline="t1")
float i_fac1 = input.float(3.0, "factor", minval=0.1, maxval=20, step=0.1, group=g_st, inline="t1")
int   i_atr2 = input.int(10, "Triple line 2: ATR length", minval=1, maxval=200, group=g_st, inline="t2")
float i_fac2 = input.float(1.0, "factor", minval=0.1, maxval=20, step=0.1, group=g_st, inline="t2")
int   i_atr3 = input.int(11, "Triple line 3: ATR length", minval=1, maxval=200, group=g_st, inline="t3", tooltip="12/3, 10/1 and 11/2: the classic triple Supertrend. The triple version's risk line is line 1 (the slowest).")
float i_fac3 = input.float(2.0, "factor", minval=0.1, maxval=20, step=0.1, group=g_st, inline="t3")

int i_emaLen = input.int(200, "EMA length", minval=2, maxval=1000, group=g_filter)
int i_tenkan = input.int(9, "Kumo: conversion length", minval=1, maxval=200, group=g_filter)
int i_kijun  = input.int(26, "Kumo: base length", minval=1, maxval=200, group=g_filter)
int i_spanB  = input.int(52, "Kumo: lead line 2 length", minval=1, maxval=400, group=g_filter)
int i_disp   = input.int(26, "Kumo: displacement", minval=1, maxval=100, group=g_filter, tooltip="9, 26, 52, 26 are TradingView's default Ichimoku settings. Only the two lead lines (the cloud) are used.")
bool i_stop  = input.bool(true, "Protective stop on the risk line", group=g_filter, tooltip="ON (default): each trade also closes if price touches the Supertrend line it was entered on (checked before the version's own exit, on closed bars). OFF: the versions exit only on their own rule.")

string i_anchor  = input.string(V_EMA, "Window: the last trades of", options=[V_PLAIN, V_TRIPLE, V_EMA, V_KUMO], group=g_log, tooltip="The comparison window starts at the entry of this version's Nth-last closed trade. Every version is counted over the same days. The default is the strictest version, so every row has at least N trades behind it.")
int    i_windowN = input.int(100, "Window: number of trades (N)", minval=10, maxval=1000, group=g_log)
bool   i_showTable = input.bool(true, "Show the comparison table", group=g_log)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_log)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_log)

color i_upCol    = input.color(#00E5A8, "Up colour", group=g_vis)
color i_dnCol    = input.color(#FF3B5C, "Down colour", group=g_vis)
color i_emaCol   = input.color(#4DA3FF, "EMA colour", group=g_vis)
color i_cloudUp  = input.color(#2BB673, "Cloud colour, lead 1 on top", group=g_vis)
color i_cloudDn  = input.color(#E0445A, "Cloud colour, lead 2 on top", group=g_vis)
bool  i_labels   = input.bool(true, "Show BUY / SELL and result labels", group=g_vis)
int   i_keep     = input.int(150, "Trades kept on chart", minval=10, maxval=240, group=g_vis)

bool i_alertJson = input.bool(true, "Send JSON alert() messages for the drawn version", group=g_alert)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── INDICATORS ────────────────────────────────────────────────────────────────
bool confirmed = barstate.isconfirmed
[st0, dir0] = ta.supertrend(i_fac0, i_atr0)
[st1, dir1] = ta.supertrend(i_fac1, i_atr1)
[st2, dir2] = ta.supertrend(i_fac2, i_atr2)
[st3, dir3] = ta.supertrend(i_fac3, i_atr3)
// ta.supertrend's direction is -1 in an uptrend (green line under price) and +1 in a downtrend
int u0 = na(dir0) ? 0 : dir0 < 0 ? 1 : -1
int u1 = na(dir1) ? 0 : dir1 < 0 ? 1 : -1
int u2 = na(dir2) ? 0 : dir2 < 0 ? 1 : -1
int u3 = na(dir3) ? 0 : dir3 < 0 ? 1 : -1
float emaV = ta.ema(close, i_emaLen)

f_donchian(int len) => math.avg(ta.lowest(low, len), ta.highest(high, len))
float convV = f_donchian(i_tenkan)
float baseV = f_donchian(i_kijun)
float leadA = math.avg(convV, baseV)        // drawn i_disp - 1 bars ahead, as TradingView's Ichimoku does
float leadB = f_donchian(i_spanB)
float cloudA = leadA[i_disp - 1]            // the cloud under the current candle
float cloudB = leadB[i_disp - 1]
float cloudTop = math.max(cloudA, cloudB)
float cloudBot = math.min(cloudA, cloudB)

// ─── ENTRY AND EXIT CONDITIONS PER VERSION ─────────────────────────────────────
bool ready0 = u0 != 0 and u0[1] != 0
bool flip0  = ready0 and u0 != u0[1]

bool agreeNow  = u1 != 0 and u1 == u2 and u2 == u3
bool agreePrev = u1[1] != 0 and u1[1] == u2[1] and u2[1] == u3[1]
int  agreeSide = agreeNow ? u1 : 0
int  agreePrevSide = agreePrev ? u1[1] : 0

bool emaL = u0 == 1 and not na(emaV) and close > emaV
bool emaS = u0 == -1 and not na(emaV) and close < emaV
bool kumoL = u0 == 1 and not na(cloudTop) and close > cloudTop
bool kumoS = u0 == -1 and not na(cloudBot) and close < cloudBot

// ─── THE BOOK OF ONE VERSION ───────────────────────────────────────────────────
type Book
    int   pos = 0
    float entry = na
    float stop = na
    float risk = na
    int   ebar = na
    int   etime = na
    array<float> r
    array<int>   te
    array<int>   held
    array<int>   tt
    float eq = 0.0

f_book() => Book.new(0, na, na, na, na, na, array.new<float>(), array.new<int>(), array.new<int>(), array.new<int>(), 0.0)

var Book bP = f_book()
var Book bT = f_book()
var Book bE = f_book()
var Book bK = f_book()

var array<label> drawn = array.new<label>()
var array<line>  drawnL = array.new<line>()

f_trim() =>
    if array.size(drawn) > 0
        while array.size(drawn) > i_keep * 2
            label.delete(array.shift(drawn))
    if array.size(drawnL) > 0
        while array.size(drawnL) > i_keep
            line.delete(array.shift(drawnL))

// Exit check of one version on a confirmed bar: protective stop first, then the version's own exit at the close.
// Returns [result R, exit price] or [na, na].
f_exit(Book b, bool ownExit, bool draw) =>
    float res = na
    float xpx = na
    if b.pos != 0 and bar_index > b.ebar
        bool hit = i_stop and (b.pos == 1 ? low <= b.stop : high >= b.stop)
        if hit
            xpx := b.pos == 1 ? math.min(open, b.stop) : math.max(open, b.stop)
        else if ownExit
            xpx := close
        if not na(xpx)
            res := (b.pos == 1 ? xpx - b.entry : b.entry - xpx) / b.risk
            array.push(b.r, res)
            array.push(b.te, b.ebar)
            array.push(b.held, bar_index - b.ebar)
            array.push(b.tt, b.etime)
            if array.size(b.r) > 4000
                array.shift(b.r)
                array.shift(b.te)
                array.shift(b.held)
                array.shift(b.tt)
            b.eq := b.eq + res
            if draw
                bool win = res > 0
                array.push(drawnL, line.new(b.ebar, b.entry, bar_index, xpx, color=color.new(win ? i_upCol : i_dnCol, 15), width=2, style=line.style_dotted))
                if i_labels
                    array.push(drawn, label.new(bar_index, xpx, (res > 0 ? "+" : "") + str.tostring(res, "#.#") + "R" + (hit ? " stop" : ""), color=color.new(win ? i_upCol : i_dnCol, 0), textcolor=win ? c_dark : c_white, style=b.pos == 1 ? label.style_label_down : label.style_label_up, size=size.small))
                f_trim()
            b.pos := 0
            b.entry := na
            b.stop := na
            b.risk := na
            b.ebar := na
            b.etime := na
    [res, xpx]

// Entry of one version at the close of a confirmed bar, risk measured to the given Supertrend line.
f_enter(Book b, int side, float riskLine, bool draw, string why) =>
    bool did = false
    if b.pos == 0 and side != 0 and not na(riskLine)
        float rk = math.max(math.abs(close - riskLine), syminfo.mintick * 5)
        b.pos := side
        b.entry := close
        b.risk := rk
        b.stop := side == 1 ? close - rk : close + rk
        b.ebar := bar_index
        b.etime := time
        did := true
        if draw and i_labels
            array.push(drawn, label.new(bar_index, side == 1 ? low : high, side == 1 ? "BUY" : "SELL", color=color.new(side == 1 ? i_upCol : i_dnCol, 0), textcolor=side == 1 ? c_dark : c_white, style=side == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=why + "\nEntry " + str.tostring(close, format.mintick) + "\nRisk line " + str.tostring(riskLine, format.mintick) + " (1R = " + str.tostring(rk, format.mintick) + ")"))
            f_trim()
    did

bool dP = i_show == V_PLAIN
bool dT = i_show == V_TRIPLE
bool dE = i_show == V_EMA
bool dK = i_show == V_KUMO

float resP = na
float xP = na
int   sigP = 0
float resT = na
float xT = na
int   sigT = 0
float resE = na
float xE = na
int   sigE = 0
float resK = na
float xK = na
int   sigK = 0

if confirmed
    // 1. plain: flip to flip
    [r1, x1] = f_exit(bP, flip0, dP)
    resP := r1
    xP := x1
    if flip0 and f_enter(bP, u0, st0, dP, "Plain Supertrend flip")
        sigP := u0
    // 2. triple: all three agree; out when they no longer match
    [r2, x2] = f_exit(bT, not (agreeNow and agreeSide == bT.pos), dT)
    resT := r2
    xT := x2
    if agreeNow and agreePrevSide != agreeSide and f_enter(bT, agreeSide, st1, dT, "All three Supertrends turned " + (agreeSide == 1 ? "green" : "red"))
        sigT := agreeSide
    // 3. + 200 EMA: out on the flip
    [r3, x3] = f_exit(bE, flip0, dE)
    resE := r3
    xE := x3
    int sideE = emaL and not emaL[1] ? 1 : emaS and not emaS[1] ? -1 : 0
    if f_enter(bE, sideE, st0, dE, sideE == 1 ? "Supertrend green with the close above the 200 EMA" : "Supertrend red with the close below the 200 EMA")
        sigE := sideE
    // 4. + Kumo: out on the first close back inside the cloud
    bool kumoOut = bK.pos == 1 ? close <= cloudTop : bK.pos == -1 ? close >= cloudBot : false
    [r4, x4] = f_exit(bK, kumoOut, dK)
    resK := r4
    xK := x4
    int sideK = kumoL and not kumoL[1] ? 1 : kumoS and not kumoS[1] ? -1 : 0
    if f_enter(bK, sideK, st0, dK, sideK == 1 ? "Supertrend green with the close above the cloud" : "Supertrend red with the close below the cloud")
        sigK := sideK

// ─── THE COMPARISON WINDOW ─────────────────────────────────────────────────────
Book anchorBook = i_anchor == V_PLAIN ? bP : i_anchor == V_TRIPLE ? bT : i_anchor == V_KUMO ? bK : bE
int nA = array.size(anchorBook.r)
int winStartBar = nA == 0 ? na : nA >= i_windowN ? array.get(anchorBook.te, nA - i_windowN) : array.get(anchorBook.te, 0)
int winStartTime = nA == 0 ? na : nA >= i_windowN ? array.get(anchorBook.tt, nA - i_windowN) : array.get(anchorBook.tt, 0)

// Stats of one version over the window: [trades, wins, total R, worst losing run, bars in a trade]
f_stats(Book b) =>
    int n = 0
    int w = 0
    float tot = 0.0
    int worst = 0
    int run = 0
    int bars = 0
    int sz = array.size(b.r)
    if sz > 0 and not na(winStartBar)
        for i = 0 to sz - 1
            if array.get(b.te, i) >= winStartBar
                float r = array.get(b.r, i)
                n += 1
                tot += r
                bars += array.get(b.held, i)
                if r > 0
                    w += 1
                    run := 0
                else
                    run += 1
                    worst := math.max(worst, run)
    [n, w, tot, worst, bars]

// ─── TABLE ─────────────────────────────────────────────────────────────────────
f_pos(string _p) =>
    switch _p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_r(float v) => (v > 0 ? "+" : "") + str.tostring(v, "#.#") + "R"
f_r2(float v) => (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

if i_showTable and barstate.islast
    var table tb = table.new(f_pos(i_tablePos), 7, 8, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    table.cell(tb, 0, 0, "SUPERTREND FILTER LAB", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.merge_cells(tb, 0, 0, 5, 0)
    table.cell(tb, 6, 0, "[fob]", text_color=color.new(c_white, 35), text_size=ts, text_halign=text.align_right, bgcolor=color.new(c_purple, 70))
    array<string> hdr = array.from("Version", "Trades", "Won", "Total R", "Avg R", "Worst run", "In market")
    for c = 0 to 6
        table.cell(tb, c, 1, array.get(hdr, c), text_color=c_grey, text_size=ts, text_halign=c == 0 ? text.align_left : text.align_right)
    int totalBars = na(winStartBar) ? 0 : bar_index - winStartBar + 1
    array<string> names = array.from(V_PLAIN, V_TRIPLE, V_EMA, V_KUMO)
    for k = 0 to 3
        Book b = k == 0 ? bP : k == 1 ? bT : k == 2 ? bE : bK
        [n, w, tot, worst, bars] = f_stats(b)
        string nm = array.get(names, k)
        bool sel = nm == i_show
        color bg = sel ? color.new(c_purple, 78) : na
        table.cell(tb, 0, k + 2, (sel ? "▸ " : "") + nm, text_color=c_white, text_size=ts, text_halign=text.align_left, bgcolor=bg)
        table.cell(tb, 1, k + 2, str.tostring(n), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 2, k + 2, str.tostring(w), text_color=i_upCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 3, k + 2, n > 0 ? f_r(tot) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 4, k + 2, n > 0 ? f_r2(tot / n) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 5, k + 2, str.tostring(worst), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 6, k + 2, totalBars > 0 ? str.tostring(100.0 * bars / totalBars, "#") + " %" : "-", text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
    string wtxt = na(winStartBar) ? "Window: not enough trades yet" : "Window: the last " + str.tostring(math.min(i_windowN, nA)) + " trades of " + i_anchor + " · " + str.format_time(winStartTime, "d MMM yyyy", syminfo.timezone) + " to " + str.format_time(time, "d MMM yyyy", syminfo.timezone) + " · " + str.tostring(totalBars) + " bars"
    table.cell(tb, 0, 6, wtxt, text_color=c_grey, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 6, 6, 6)
    string now = "Now: Supertrend " + (u0 == 1 ? "green" : "red") + " · triple " + (agreeNow ? (agreeSide == 1 ? "all green" : "all red") : "mixed") + " · " + (close > emaV ? "above" : "below") + " the EMA · " + (close > cloudTop ? "above" : close < cloudBot ? "below" : "inside") + " the cloud"
    table.cell(tb, 0, 7, now, text_color=c_grey, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 7, 6, 7)

// ─── CHART PLOTS (the drawn version only) ──────────────────────────────────────
bool showDefault = dP or dE or dK
plot(showDefault ? st0 : na, "Supertrend", color=u0 == 1 ? i_upCol : i_dnCol, linewidth=2, style=plot.style_linebr)
plot(dT ? st1 : na, "Triple 12/3", color=u1 == 1 ? i_upCol : i_dnCol, linewidth=2, style=plot.style_linebr)
plot(dT ? st2 : na, "Triple 10/1", color=color.new(u2 == 1 ? i_upCol : i_dnCol, 25), linewidth=1, style=plot.style_linebr)
plot(dT ? st3 : na, "Triple 11/2", color=color.new(u3 == 1 ? i_upCol : i_dnCol, 10), linewidth=1, style=plot.style_linebr)
plot(dE ? emaV : na, "EMA", color=color.new(i_emaCol, 10), linewidth=2)
pA = plot(dK ? leadA : na, "Lead 1", color=color.new(i_cloudUp, 40), offset=i_disp - 1)
pB = plot(dK ? leadB : na, "Lead 2", color=color.new(i_cloudDn, 40), offset=i_disp - 1)
fill(pA, pB, color=leadA > leadB ? color.new(i_cloudUp, 82) : color.new(i_cloudDn, 82))

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(st0, "st0", display=display.data_window)
plot(u0, "u0", display=display.data_window)
plot(st1, "st1", display=display.data_window)
plot(u1, "u1", display=display.data_window)
plot(st2, "st2", display=display.data_window)
plot(u2, "u2", display=display.data_window)
plot(st3, "st3", display=display.data_window)
plot(u3, "u3", display=display.data_window)
plot(emaV, "ema", display=display.data_window)
plot(leadA, "leadA", display=display.data_window)
plot(leadB, "leadB", display=display.data_window)
plot(sigP, "sigP", display=display.data_window)
plot(resP, "resP", display=display.data_window)
plot(xP, "xP", display=display.data_window)
plot(bP.pos, "posP", display=display.data_window)
plot(bP.eq, "eqP", display=display.data_window)
plot(sigT, "sigT", display=display.data_window)
plot(resT, "resT", display=display.data_window)
plot(xT, "xT", display=display.data_window)
plot(bT.pos, "posT", display=display.data_window)
plot(bT.eq, "eqT", display=display.data_window)
plot(sigE, "sigE", display=display.data_window)
plot(resE, "resE", display=display.data_window)
plot(xE, "xE", display=display.data_window)
plot(bE.pos, "posE", display=display.data_window)
plot(bE.eq, "eqE", display=display.data_window)
plot(sigK, "sigK", display=display.data_window)
plot(resK, "resK", display=display.data_window)
plot(xK, "xK", display=display.data_window)
plot(bK.pos, "posK", display=display.data_window)
plot(bK.eq, "eqK", display=display.data_window)
plot(bP.pos != 0 ? bP.stop : na, "stopP", display=display.data_window)
plot(bT.pos != 0 ? bT.stop : na, "stopT", display=display.data_window)
plot(bE.pos != 0 ? bE.stop : na, "stopE", display=display.data_window)
plot(bK.pos != 0 ? bK.stop : na, "stopK", display=display.data_window)
plot(winStartBar, "winStart", display=display.data_window)
plot(bar_index, "bi", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sigP == 1, "STFL Plain buy", "Supertrend Filter Lab, plain: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigP == -1, "STFL Plain sell", "Supertrend Filter Lab, plain: SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigT == 1, "STFL Triple buy", "Supertrend Filter Lab, triple: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigT == -1, "STFL Triple sell", "Supertrend Filter Lab, triple: SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigE == 1, "STFL 200 EMA buy", "Supertrend Filter Lab, + 200 EMA: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigE == -1, "STFL 200 EMA sell", "Supertrend Filter Lab, + 200 EMA: SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigK == 1, "STFL Kumo buy", "Supertrend Filter Lab, + Kumo: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigK == -1, "STFL Kumo sell", "Supertrend Filter Lab, + Kumo: SELL on {{ticker}} {{interval}} at {{close}}")

int sigShown = dP ? sigP : dT ? sigT : dE ? sigE : sigK
if i_alertJson and sigShown != 0
    alert('{"action":"' + (sigShown == 1 ? "BUY" : "SELL") + '","indicator":"STFL","version":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","close":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
````
