# VWAP Strategy Lab: 4 Setups + Prop Test [forexobroker]

- url: https://www.tradingview.com/script/aDz4OEek-VWAP-Strategy-Lab-4-Setups-Prop-Test-forexobroker/
- type: indicator
- pine_id: PUB;c055d5bbc5f4478ab80fd6136c03f0a4
- version: 1.0

## Description

VWAP Strategy Lab: 4 Setups + Prop Test [forexobroker]

🔶 OVERVIEW

VWAP Strategy Lab trades the four VWAP setups traders use most, side by side on the same chart, and logs every trade of each one: the first-touch bounce, the break and retest, the band reversion and the anchored VWAP. One table compares them over the same days, splits every result into calm and choppy sessions, and runs a prop firm style challenge on the setup you draw, so you can see on your own chart which setup actually holds up.

🔶 HOW IT WORKS

1. The VWAP. The session VWAP of hlc3 (TradingView's default anchor: a new line every trading day) with bands at +/- 2 standard deviations. A new session starts a new line.

2. The anchored VWAPs. Two more lines anchored at the bar of the previous session's high (orange) and the previous session's low (blue).

3. A. First-touch bounce. Price has closed on one side of the VWAP for at least 12 candles of the session (one hour on a 5-minute chart). The first candle that touches the VWAP and closes back on that side is the entry. Stop beyond that candle (0.1 ATR past it, at least 0.25 ATR), target 2R. Only the first touch counts; a close through the line starts the count again.

4. B. Break and retest. After at least 12 closes on one side, price closes through the VWAP: the break. Within 12 candles a candle touches the VWAP from the new side and closes away from it: the retest and the entry. A close back through the line before the retest cancels the break. Stop beyond the retest candle, target 2R.

5. C. Band reversion. A close outside a band, then the first close back inside it: a trade against the stretch. Target = the VWAP at entry, stop beyond the furthest point of the stretch.

6. D. Anchored VWAP. Price has closed above the low-anchored line for 12 candles; the first touch that closes back above it is a buy. The mirror at the high-anchored line is a sell. Stop and target as in A.

Every trade is checked on closed candles: the stop counts first when one candle touches both the stop and the target, a gap through the stop exits at the open, and a trade still open when the session ends closes at the next session's first price. Results are in R (move / risk). One trade per setup at a time.

🔶 THE TABLE

For each setup: trades, wins, total R, average R, the worst losing run, and the total R split into calm and choppy sessions. Choppy sessions are the top 25 % of the chart's sessions by how many times the close crossed the VWAP (the threshold is measured on your chart and printed under the table). The comparison window is everything the chart has loaded by default, the same days for all four setups; it can also be set to the days of one setup's last N trades.

Note on the chop split: a session is known to be choppy only after it ends, so the split shows where a setup made or lost its R, not a filter you could apply in real time.

🔶 PROP CHALLENGE COUNTER

Every trade of the drawn setup inside the window is used once as a starting point. From there each trade is worth its result times the risk per trade (1 % of the starting balance by default). Passed = the profit target (+10 %) is reached first; failed = the daily loss limit (closed trades of one UTC day, -5 %) or the total loss limit (-10 %) is reached first; unfinished = neither yet. The table prints passed, failed and unfinished out of all starts. All four limits are inputs.

NON-REPAINTING: every entry, exit and result is evaluated on barstate.isconfirmed; there is no request.security and no lookahead.

🔶 SETTINGS

Show
- Which setup is drawn (all four are always logged).

VWAP
- Band width in standard deviations (2), show the bands, show the anchored VWAPs.

Setup rules
- Bars on one side before a setup counts (12), bars allowed for the retest (12).

Stop and target
- Target for A, B and D (2R), stop beyond the candle (0.1 ATR), minimum stop (0.25 ATR), ATR length (14), close open trades at the session end.

Comparison window, chop and table
- Window (everything loaded, or the last N trades of one setup), N (100), choppy sessions (top 25 %), table position and size.

Prop challenge
- Risk per trade (1 %), profit target (10 %), daily loss limit (5 %), total loss limit (10 %).

Visual
- Colours, labels, trades kept on the chart.

🔶 ALERTS

Four alertcondition hooks, one per setup. With JSON alerts on, every entry of the drawn setup also fires an alert() once per bar close with a JSON body (action, setup, ticker, timeframe, entry, stop, target).

🔶 LIMITATIONS

- The VWAP needs volume. On forex and CFD symbols TradingView provides tick volume (the number of price changes), which is what the script uses there; on a symbol without volume the table says so and no setup trades.
- Results depend on the market, the timeframe and the settings; the table shows them on your own chart, losses included.
- Results in the table are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- The prop challenge counter uses closed trades only; a real challenge also counts open losses.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: VWAP Strategy Lab — the four VWAP setups traders teach most, traded side by side on the same chart, each
// with its own trade log, one table that compares them over the same days, a choppy-session split and a prop-firm
// challenge counter.
// VWAP: the session VWAP (TradingView's default anchor: a new line every trading day) of hlc3, with +/- N standard
// deviation bands. Anchored VWAP: two extra lines anchored at the bar of the PREVIOUS session's high and low.
// A. First-touch bounce: price closed on one side of the VWAP for at least K bars of this session; the first candle
//    that touches the VWAP and closes back on that side is the entry. Stop beyond the touch candle, target 2R.
// B. Break and retest: after at least K closes on one side, price closes through the VWAP (the break); within W bars
//    a candle touches the VWAP from the new side and closes away from it (the retest): entry. Stop beyond the retest
//    candle, target 2R. A close back through the VWAP before the retest cancels the break.
// C. Band reversion: a close outside the +/- band, then the first close back inside it: fade toward the VWAP.
//    Stop beyond the extreme of the excursion, target = the VWAP at entry.
// D. Anchored VWAP: price closed above the line anchored at the previous session's low for at least K bars; the first
//    touch that closes back above it is a buy (the mirror at the previous session's high is a sell). Stop and target
//    as in A.
// Every trade is checked on closed bars: stop first when a candle touches both (the conservative count), a gap through
// the stop exits at the open, and a trade still open when the session ends is closed at the next session's first
// price. Results are in R = move / risk. Risk is at least the minimum stop in ATR.
// The comparison window: by default everything the chart has loaded (the same days for all four setups); optionally
// the days of one setup's last N trades. Choppy sessions: the top 25 % of the chart's sessions by VWAP crosses.
// Prop challenge: every trade of the drawn setup inside the window is used once as a start; from there each trade is
// worth result x the risk per trade (1 % of the starting balance by default). Passed = +target reached first; failed =
// the daily loss (closed trades of one UTC day) or the total loss limit reached first; unfinished = neither yet.
// Non-repainting: everything is evaluated on barstate.isconfirmed; no request.security and no lookahead.
indicator("VWAP Strategy Lab: 4 Setups + Prop Test [forexobroker]", shorttitle="VWAPLAB [fob]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_show  = "Show"
string g_vwap  = "VWAP"
string g_rules = "Setup rules"
string g_risk  = "Stop and target"
string g_log   = "Comparison window, chop and table"
string g_prop  = "Prop challenge"
string g_vis   = "Visual"
string g_alert = "Alerts"

string S_A = "A. First-touch bounce"
string S_B = "B. Break and retest"
string S_C = "C. Band reversion"
string S_D = "D. Anchored VWAP"
string S_ALL = "Everything loaded"

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string i_show = input.string(S_A, "Draw the trades of", options=[S_A, S_B, S_C, S_D], group=g_show, tooltip="All four setups are traded and logged on every bar. This choice decides which one is drawn (entries, stops, targets, results), which row of the table is highlighted and which setup the prop challenge counter uses.")

float i_bandMult = input.float(2.0, "Band: standard deviations", minval=0.5, maxval=5.0, step=0.5, group=g_vwap)
bool  i_showBands = input.bool(true, "Show the bands", group=g_vwap)
bool  i_showAnch  = input.bool(true, "Show the anchored VWAPs (always shown when D is drawn)", group=g_vwap)

int i_sideBars = input.int(12, "Bars on one side before a setup counts (K)", minval=2, maxval=200, group=g_rules, tooltip="A, B and D need price to have closed on one side of the line for at least this many bars of the current session (12 bars = 1 hour on a 5-minute chart). C needs the session to be this old before its band counts.")
int i_retest   = input.int(12, "Break and retest: bars allowed for the retest (W)", minval=1, maxval=200, group=g_rules)

float i_rr      = input.float(2.0, "Target (R) for A, B and D", minval=0.5, maxval=10.0, step=0.5, group=g_risk)
float i_buf     = input.float(0.1, "Stop beyond the candle (ATR)", minval=0.0, maxval=3.0, step=0.05, group=g_risk)
float i_minRisk = input.float(0.25, "Minimum stop (ATR)", minval=0.05, maxval=5.0, step=0.05, group=g_risk)
int   i_atrLen  = input.int(14, "ATR length", minval=1, maxval=200, group=g_risk)
bool  i_sessExit = input.bool(true, "Close open trades at the end of the session", group=g_risk, tooltip="ON (default): a trade still open when a new session starts is closed at that session's first price, as intraday VWAP traders do.")

string i_anchor  = input.string(S_ALL, "Window: the last trades of", options=[S_ALL, S_A, S_B, S_C, S_D], group=g_log, tooltip="Everything loaded (default): every trade on the chart's loaded history, the same days for all four setups. Or: the window starts at the entry of the chosen setup's Nth-last closed trade, and every setup is counted over those same days.")
int    i_windowN = input.int(100, "Window: number of trades (N)", minval=10, maxval=1000, group=g_log)
int    i_chopPct = input.int(25, "Choppy sessions: the top % by VWAP crosses", minval=5, maxval=50, group=g_log, tooltip="A session's crosses = how many times the close changed sides of the VWAP. The sessions with the most crosses (the top 25 % by default, measured on this chart) count as choppy.")
bool   i_showTable = input.bool(true, "Show the comparison table", group=g_log)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_log)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_log)

float i_riskPct  = input.float(1.0, "Risk per trade (% of the starting balance)", minval=0.1, maxval=10.0, step=0.1, group=g_prop)
float i_target   = input.float(10.0, "Profit target (%)", minval=1.0, maxval=100.0, step=0.5, group=g_prop)
float i_dayLoss  = input.float(5.0, "Daily loss limit (%)", minval=0.5, maxval=50.0, step=0.5, group=g_prop)
float i_maxLoss  = input.float(10.0, "Total loss limit (%)", minval=1.0, maxval=100.0, step=0.5, group=g_prop)

color i_vwapCol = input.color(#FFD400, "VWAP colour", group=g_vis)
color i_bandCol = input.color(#8C96A3, "Band colour", group=g_vis)
color i_ancHCol = input.color(#FF8A3D, "Anchored at the previous high", group=g_vis)
color i_ancLCol = input.color(#3DA5FF, "Anchored at the previous low", group=g_vis)
color i_upCol   = input.color(#00E5A8, "Buy / win colour", group=g_vis)
color i_dnCol   = input.color(#FF3B5C, "Sell / loss colour", group=g_vis)
bool  i_labels  = input.bool(true, "Show BUY / SELL and result labels", group=g_vis)
int   i_keep    = input.int(150, "Trades kept on chart", minval=10, maxval=240, group=g_vis)

bool i_alertJson = input.bool(true, "Send JSON alert() messages for the drawn setup", group=g_alert)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── VWAP, BANDS, ATR ──────────────────────────────────────────────────────────
bool confirmed = barstate.isconfirmed
bool newSess = timeframe.change("D")
[vw, upB, loB] = ta.vwap(hlc3, newSess, i_bandMult)
float atr = ta.atr(i_atrLen)
bool hasVol = not na(volume) and volume > 0

// ─── SESSION STATE ─────────────────────────────────────────────────────────────
var int   sessKey = na        // start time of the current session
var int   sessBars = 0
var int   crosses = 0
var map<int, int> sessCross = map.new<int, int>()
var float sHi = na
var int   sHiBar = na
var float sLo = na
var int   sLoBar = na
var int   anHiBar = na
var int   anLoBar = na
var float pvH = 0.0
var float vH = 0.0
var float pvL = 0.0
var float vL = 0.0

if newSess
    if not na(sessKey)
        sessCross.put(sessKey, crosses)
    anHiBar := sHiBar
    anLoBar := sLoBar
    sessKey := time
    sessBars := 0
    crosses := 0
    sHi := high
    sHiBar := bar_index
    sLo := low
    sLoBar := bar_index
    pvH := 0.0
    vH := 0.0
    pvL := 0.0
    vL := 0.0
    if not na(anHiBar)
        int dh = math.min(bar_index - anHiBar, 1900)
        for i = 0 to dh
            pvH += nz(hlc3[i] * volume[i])
            vH += nz(volume[i])
    if not na(anLoBar)
        int dl = math.min(bar_index - anLoBar, 1900)
        for i = 0 to dl
            pvL += nz(hlc3[i] * volume[i])
            vL += nz(volume[i])
else
    sessBars += 1
    if high > sHi
        sHi := high
        sHiBar := bar_index
    if low < sLo
        sLo := low
        sLoBar := bar_index
    if not na(anHiBar)
        pvH += nz(hlc3 * volume)
        vH += nz(volume)
    if not na(anLoBar)
        pvL += nz(hlc3 * volume)
        vL += nz(volume)
    if not na(vw) and not na(vw[1]) and math.sign(close - vw) != 0 and math.sign(close - vw) != math.sign(close[1] - vw[1])
        crosses += 1

float avH = vH > 0 ? pvH / vH : na
float avL = vL > 0 ? pvL / vL : na

// runs of closes on one side, counted inside the session
var int upRun = 0
var int dnRun = 0
var int upRunL = 0           // closes above the low-anchored VWAP
var int dnRunH = 0           // closes below the high-anchored VWAP
if newSess
    upRun := 0
    dnRun := 0
    upRunL := 0
    dnRunH := 0
int upPrev = upRun
int dnPrev = dnRun
int upLPrev = upRunL
int dnHPrev = dnRunH
upRun := not na(vw) and close > vw ? upRun + 1 : 0
dnRun := not na(vw) and close < vw ? dnRun + 1 : 0
upRunL := not na(avL) and close > avL ? upRunL + 1 : 0
dnRunH := not na(avH) and close < avH ? dnRunH + 1 : 0

// ─── THE BOOK OF ONE SETUP ─────────────────────────────────────────────────────
type Book
    int   pos = 0
    float entry = na
    float stop = na
    float target = na
    float risk = na
    int   ebar = na
    int   etime = na
    int   esess = na
    array<float> r
    array<int>   te
    array<int>   tt
    array<int>   xt
    array<int>   ts
    float eq = 0.0

f_book() => Book.new(0, na, na, na, na, na, na, na, array.new<float>(), array.new<int>(), array.new<int>(), array.new<int>(), array.new<int>(), 0.0)

var Book bA = f_book()
var Book bB = f_book()
var Book bC = f_book()
var Book bD = f_book()

var array<label> drawn = array.new<label>()
var array<line>  drawnL = array.new<line>()

f_trim() =>
    if array.size(drawn) > 0
        while array.size(drawn) > i_keep * 2
            label.delete(array.shift(drawn))
    if array.size(drawnL) > 0
        while array.size(drawnL) > i_keep * 3
            line.delete(array.shift(drawnL))

f_close(Book b, float px, bool draw, string why) =>
    float res = (b.pos == 1 ? px - b.entry : b.entry - px) / b.risk
    array.push(b.r, res)
    array.push(b.te, b.ebar)
    array.push(b.tt, b.etime)
    array.push(b.xt, time)
    array.push(b.ts, b.esess)
    if array.size(b.r) > 4000
        array.shift(b.r)
        array.shift(b.te)
        array.shift(b.tt)
        array.shift(b.xt)
        array.shift(b.ts)
    b.eq := b.eq + res
    if draw
        bool win = res > 0
        array.push(drawnL, line.new(b.ebar, b.stop, bar_index, b.stop, color=color.new(i_dnCol, 20), width=1))
        array.push(drawnL, line.new(b.ebar, b.target, bar_index, b.target, color=color.new(i_upCol, 20), width=1, style=line.style_dashed))
        array.push(drawnL, line.new(b.ebar, b.entry, bar_index, px, color=color.new(win ? i_upCol : i_dnCol, 15), width=2, style=line.style_dotted))
        if i_labels
            array.push(drawn, label.new(bar_index, px, (res > 0 ? "+" : "") + str.tostring(res, "#.#") + "R" + (why != "" ? " " + why : ""), color=color.new(win ? i_upCol : i_dnCol, 0), textcolor=win ? c_dark : c_white, style=b.pos == 1 ? label.style_label_down : label.style_label_up, size=size.small))
        f_trim()
    b.pos := 0
    b.entry := na
    b.stop := na
    b.target := na
    b.risk := na
    b.ebar := na
    b.etime := na
    b.esess := na
    res

// Stop and target on a confirmed bar after the entry bar. Returns [result, exit price] or [na, na].
f_check(Book b, bool draw) =>
    float res = na
    float xpx = na
    string why = ""
    if b.pos != 0 and bar_index > b.ebar
        bool gapStop = b.pos == 1 ? open <= b.stop : open >= b.stop
        bool hitStop = b.pos == 1 ? low <= b.stop : high >= b.stop
        bool hitTgt  = b.pos == 1 ? high >= b.target : low <= b.target
        if gapStop
            xpx := open
            why := "stop"
        else if hitStop
            xpx := b.stop
            why := "stop"
        else if hitTgt
            xpx := b.target
            why := "target"
        if not na(xpx)
            res := f_close(b, xpx, draw, why == "stop" ? "stop" : "")
    [res, xpx]

f_enter(Book b, int side, float stopPx, float tgtPx, bool draw, string why) =>
    bool did = false
    if b.pos == 0 and side != 0 and not na(stopPx) and not na(atr) and hasVol
        float minR = i_minRisk * atr
        float rk = math.max(side == 1 ? close - stopPx : stopPx - close, minR)
        float st = side == 1 ? close - rk : close + rk
        float tg = na(tgtPx) ? (side == 1 ? close + i_rr * rk : close - i_rr * rk) : tgtPx
        bool tgtOk = side == 1 ? tg > close : tg < close
        if tgtOk
            b.pos := side
            b.entry := close
            b.risk := rk
            b.stop := st
            b.target := tg
            b.ebar := bar_index
            b.etime := time
            b.esess := sessKey
            did := true
            if draw and i_labels
                array.push(drawn, label.new(bar_index, side == 1 ? low : high, side == 1 ? "BUY" : "SELL", color=color.new(side == 1 ? i_upCol : i_dnCol, 0), textcolor=side == 1 ? c_dark : c_white, style=side == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=why + "\nEntry " + str.tostring(close, format.mintick) + "\nStop " + str.tostring(st, format.mintick) + "\nTarget " + str.tostring(tg, format.mintick) + " (1R = " + str.tostring(rk, format.mintick) + ")"))
                f_trim()
    did

bool dA = i_show == S_A
bool dB = i_show == S_B
bool dC = i_show == S_C
bool dD = i_show == S_D

// ─── SETUP STATE ───────────────────────────────────────────────────────────────
var bool touchedUp = false
var bool touchedDn = false
var bool touchedL = false
var bool touchedH = false
var int  brkUpUntil = na
var int  brkDnUntil = na
var int  brkUpBar = na
var int  brkDnBar = na
var float excHi = na
var float excLo = na

if newSess
    touchedUp := false
    touchedDn := false
    touchedL := false
    touchedH := false
    brkUpUntil := na
    brkDnUntil := na
    excHi := na
    excLo := na
if upRun == 0
    touchedUp := false
if dnRun == 0
    touchedDn := false
if upRunL == 0
    touchedL := false
if dnRunH == 0
    touchedH := false

float resA = na
float xA = na
int   sigA = 0
float resB = na
float xB = na
int   sigB = 0
float resC = na
float xC = na
int   sigC = 0
float resD = na
float xD = na
int   sigD = 0

if confirmed
    // 0. session end: trades from the previous session close at this session's first price
    if newSess and i_sessExit
        if bA.pos != 0 and bA.esess != sessKey
            resA := f_close(bA, open, dA, "session")
            xA := open
        if bB.pos != 0 and bB.esess != sessKey
            resB := f_close(bB, open, dB, "session")
            xB := open
        if bC.pos != 0 and bC.esess != sessKey
            resC := f_close(bC, open, dC, "session")
            xC := open
        if bD.pos != 0 and bD.esess != sessKey
            resD := f_close(bD, open, dD, "session")
            xD := open
    // 1. stops and targets
    if na(resA)
        [r1, x1] = f_check(bA, dA)
        resA := r1
        xA := x1
    if na(resB)
        [r2, x2] = f_check(bB, dB)
        resB := r2
        xB := x2
    if na(resC)
        [r3, x3] = f_check(bC, dC)
        resC := r3
        xC := x3
    if na(resD)
        [r4, x4] = f_check(bD, dD)
        resD := r4
        xD := x4
    float buf = i_buf * nz(atr)
    // 2. A. first-touch bounce
    int sideA = 0
    if not na(vw) and not newSess
        if upPrev >= i_sideBars and not touchedUp and low <= vw and close > vw
            sideA := 1
            touchedUp := true
        else if dnPrev >= i_sideBars and not touchedDn and high >= vw and close < vw
            sideA := -1
            touchedDn := true
    if sideA != 0 and f_enter(bA, sideA, sideA == 1 ? low - buf : high + buf, na, dA, sideA == 1 ? "First touch of the VWAP from above, closed back above" : "First touch of the VWAP from below, closed back below")
        sigA := sideA
    // 3. B. break and retest
    int sideB = 0
    if not na(vw) and not newSess
        if not na(brkUpUntil)
            if bar_index > brkUpUntil or close < vw
                brkUpUntil := na
            else if bar_index > brkUpBar and low <= vw and close > vw
                sideB := 1
                brkUpUntil := na
        if not na(brkDnUntil)
            if bar_index > brkDnUntil or close > vw
                brkDnUntil := na
            else if bar_index > brkDnBar and high >= vw and close < vw and sideB == 0
                sideB := -1
                brkDnUntil := na
        if dnPrev >= i_sideBars and close > vw
            brkUpBar := bar_index
            brkUpUntil := bar_index + i_retest
        if upPrev >= i_sideBars and close < vw
            brkDnBar := bar_index
            brkDnUntil := bar_index + i_retest
    if sideB != 0 and f_enter(bB, sideB, sideB == 1 ? low - buf : high + buf, na, dB, sideB == 1 ? "VWAP broken upward, retested from above" : "VWAP broken downward, retested from below")
        sigB := sideB
    // 4. C. band reversion
    int sideC = 0
    if not na(upB) and not newSess and sessBars >= i_sideBars
        if close > upB
            excHi := na(excHi) ? high : math.max(excHi, high)
        else if not na(excHi)
            if close > vw
                sideC := -1
            excHi := na
        if close < loB
            excLo := na(excLo) ? low : math.min(excLo, low)
        else if not na(excLo)
            if close < vw and sideC == 0
                sideC := 1
            excLo := na
    float excStop = sideC == -1 ? math.max(high, nz(excHi[1], high)) + buf : sideC == 1 ? math.min(low, nz(excLo[1], low)) - buf : na
    if sideC != 0 and f_enter(bC, sideC, excStop, vw, dC, sideC == 1 ? "Closed back inside the lower band: fade to the VWAP" : "Closed back inside the upper band: fade to the VWAP")
        sigC := sideC
    // 5. D. anchored VWAP
    int sideD = 0
    if not newSess
        if not na(avL) and upLPrev >= i_sideBars and not touchedL and low <= avL and close > avL
            sideD := 1
            touchedL := true
        else if not na(avH) and dnHPrev >= i_sideBars and not touchedH and high >= avH and close < avH
            sideD := -1
            touchedH := true
    if sideD != 0 and f_enter(bD, sideD, sideD == 1 ? low - buf : high + buf, na, dD, sideD == 1 ? "First touch of the VWAP anchored at the previous low, closed back above" : "First touch of the VWAP anchored at the previous high, closed back below")
        sigD := sideD

// ─── THE COMPARISON WINDOW ─────────────────────────────────────────────────────
var int firstBar = bar_index
var int firstTime = time
Book anchorBook = i_anchor == S_A ? bA : i_anchor == S_C ? bC : i_anchor == S_D ? bD : bB
int nA = array.size(anchorBook.r)
int winStartBar = i_anchor == S_ALL ? firstBar : nA == 0 ? na : nA >= i_windowN ? array.get(anchorBook.te, nA - i_windowN) : array.get(anchorBook.te, 0)
int winStartTime = i_anchor == S_ALL ? firstTime : nA == 0 ? na : nA >= i_windowN ? array.get(anchorBook.tt, nA - i_windowN) : array.get(anchorBook.tt, 0)

f_crossesOf(int key) =>
    int c = na
    if not na(key)
        if key == sessKey
            c := crosses
        else if sessCross.contains(key)
            c := sessCross.get(key)
    c

// Stats over the window: [trades, wins, total R, worst losing run, calm R, choppy R, choppy trades]
f_stats(Book b, int chopX) =>
    int n = 0
    int w = 0
    float tot = 0.0
    int worst = 0
    int run = 0
    float calm = 0.0
    float chop = 0.0
    int nChop = 0
    int sz = array.size(b.r)
    if sz > 0 and not na(winStartBar)
        for i = 0 to sz - 1
            if array.get(b.te, i) >= winStartBar
                float r = array.get(b.r, i)
                n += 1
                tot += r
                if r > 0
                    w += 1
                    run := 0
                else
                    run += 1
                    worst := math.max(worst, run)
                int cr = f_crossesOf(array.get(b.ts, i))
                if not na(cr) and cr >= chopX
                    chop += r
                    nChop += 1
                else
                    calm += r
    [n, w, tot, worst, calm, chop, nChop]

// Prop challenge over the window: [passed, failed, unfinished]
f_prop(Book b) =>
    int passed = 0
    int failed = 0
    int open_ = 0
    int sz = array.size(b.r)
    if sz > 0 and not na(winStartBar)
        for s = 0 to sz - 1
            if array.get(b.te, s) >= winStartBar
                float bal = 0.0
                float day = 0.0
                int dayKey = -1
                int verdict = 0
                for j = s to sz - 1
                    int dk = int(math.floor(array.get(b.xt, j) / 86400000.0))
                    if dk != dayKey
                        dayKey := dk
                        day := 0.0
                    float pnl = array.get(b.r, j) * i_riskPct
                    bal := math.round(bal + pnl, 6)      // rounded so a run of exact 2R wins lands exactly on the target
                    day := math.round(day + pnl, 6)
                    if day <= -i_dayLoss or bal <= -i_maxLoss
                        verdict := -1
                        break
                    if bal >= i_target
                        verdict := 1
                        break
                if verdict == 1
                    passed += 1
                else if verdict == -1
                    failed += 1
                else
                    open_ += 1
    [passed, failed, open_]

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

Book drawnBook = dA ? bA : dB ? bB : dC ? bC : bD

if i_showTable and barstate.islast
    var table tb = table.new(f_pos(i_tablePos), 8, 9, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    table.cell(tb, 0, 0, "VWAP STRATEGY LAB", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.merge_cells(tb, 0, 0, 6, 0)
    table.cell(tb, 7, 0, "[fob]", text_color=color.new(c_white, 35), text_size=ts, text_halign=text.align_right, bgcolor=color.new(c_purple, 70))
    array<string> hdr = array.from("Setup", "Trades", "Won", "Total R", "Avg R", "Worst run", "Calm R", "Choppy R")
    for c = 0 to 7
        table.cell(tb, c, 1, array.get(hdr, c), text_color=c_grey, text_size=ts, text_halign=c == 0 ? text.align_left : text.align_right)
    array<int> cv = sessCross.values()
    int chopX = array.size(cv) > 0 ? int(math.ceil(array.percentile_nearest_rank(cv, 100 - i_chopPct))) : 999999
    array<string> names = array.from(S_A, S_B, S_C, S_D)
    for k = 0 to 3
        Book b = k == 0 ? bA : k == 1 ? bB : k == 2 ? bC : bD
        [n, w, tot, worst, calm, chop, nChop] = f_stats(b, chopX)
        string nm = array.get(names, k)
        bool sel = nm == i_show
        color bg = sel ? color.new(c_purple, 78) : na
        table.cell(tb, 0, k + 2, (sel ? "▸ " : "") + nm, text_color=c_white, text_size=ts, text_halign=text.align_left, bgcolor=bg)
        table.cell(tb, 1, k + 2, str.tostring(n), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 2, k + 2, str.tostring(w), text_color=i_upCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 3, k + 2, n > 0 ? f_r(tot) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 4, k + 2, n > 0 ? f_r2(tot / n) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 5, k + 2, str.tostring(worst), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 6, k + 2, n > 0 ? f_r(calm) : "-", text_color=calm >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 7, k + 2, nChop > 0 ? f_r(chop) + " (" + str.tostring(nChop) + ")" : "-", text_color=chop >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
    [pPass, pFail, pOpen] = f_prop(drawnBook)
    string ptxt = "Prop challenge on " + i_show + " (" + str.tostring(i_riskPct) + " % a trade, +" + str.tostring(i_target) + " % / -" + str.tostring(i_dayLoss) + " % a day / -" + str.tostring(i_maxLoss) + " %): " + str.tostring(pPass) + " passed · " + str.tostring(pFail) + " failed · " + str.tostring(pOpen) + " unfinished, of " + str.tostring(pPass + pFail + pOpen) + " starts"
    table.cell(tb, 0, 6, ptxt, text_color=c_white, text_size=ts, text_halign=text.align_left, bgcolor=color.new(c_purple, 85))
    table.merge_cells(tb, 0, 6, 7, 6)
    int totalBars = na(winStartBar) ? 0 : bar_index - winStartBar + 1
    string wtxt = na(winStartBar) ? "Window: not enough trades yet" : (i_anchor == S_ALL ? "Window: everything loaded" : "Window: the last " + str.tostring(math.min(i_windowN, nA)) + " trades of " + i_anchor) + " · " + str.format_time(winStartTime, "d MMM yyyy", syminfo.timezone) + " to " + str.format_time(time, "d MMM yyyy", syminfo.timezone) + " · choppy = the top " + str.tostring(i_chopPct) + " % of sessions (" + str.tostring(chopX) + "+ VWAP crosses)"
    table.cell(tb, 0, 7, wtxt, text_color=c_grey, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 7, 7, 7)
    string now = hasVol ? "Now: price " + (close > vw ? "above" : "below") + " the VWAP · " + str.tostring(crosses) + " crosses this session · " + (close > upB ? "outside the upper band" : close < loB ? "outside the lower band" : "inside the bands") : "This symbol has no volume data: the VWAP needs volume"
    table.cell(tb, 0, 8, now, text_color=hasVol ? c_grey : i_dnCol, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 8, 7, 8)

// ─── CHART PLOTS ───────────────────────────────────────────────────────────────
// a new session starts a new line: na on its first bar breaks the drawn line (the values themselves are unchanged)
plot(newSess ? na : vw, "VWAP", color=i_vwapCol, linewidth=3, style=plot.style_linebr)
plot(i_showBands and not newSess ? upB : na, "Upper band", color=color.new(i_bandCol, 30), linewidth=1, style=plot.style_linebr)
plot(i_showBands and not newSess ? loB : na, "Lower band", color=color.new(i_bandCol, 30), linewidth=1, style=plot.style_linebr)
plot((i_showAnch or dD) and not newSess ? avH : na, "Anchored at previous high", color=color.new(i_ancHCol, 10), linewidth=2, style=plot.style_linebr)
plot((i_showAnch or dD) and not newSess ? avL : na, "Anchored at previous low", color=color.new(i_ancLCol, 10), linewidth=2, style=plot.style_linebr)
plot(drawnBook.pos != 0 ? drawnBook.stop : na, "Stop", color=color.new(i_dnCol, 10), linewidth=1, style=plot.style_linebr)
plot(drawnBook.pos != 0 ? drawnBook.target : na, "Target", color=color.new(i_upCol, 10), linewidth=1, style=plot.style_linebr)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(vw, "vw", display=display.data_window)
plot(upB, "upB", display=display.data_window)
plot(loB, "loB", display=display.data_window)
plot(avH, "avH", display=display.data_window)
plot(avL, "avL", display=display.data_window)
plot(atr, "atr", display=display.data_window)
plot(sessKey, "sess", display=display.data_window)
plot(crosses, "crosses", display=display.data_window)
plot(sigA, "sigA", display=display.data_window)
plot(resA, "resA", display=display.data_window)
plot(xA, "xA", display=display.data_window)
plot(bA.pos != 0 ? bA.stop : na, "stopA", display=display.data_window)
plot(bA.pos != 0 ? bA.target : na, "tgtA", display=display.data_window)
plot(sigB, "sigB", display=display.data_window)
plot(resB, "resB", display=display.data_window)
plot(xB, "xB", display=display.data_window)
plot(bB.pos != 0 ? bB.stop : na, "stopB", display=display.data_window)
plot(bB.pos != 0 ? bB.target : na, "tgtB", display=display.data_window)
plot(sigC, "sigC", display=display.data_window)
plot(resC, "resC", display=display.data_window)
plot(xC, "xC", display=display.data_window)
plot(bC.pos != 0 ? bC.stop : na, "stopC", display=display.data_window)
plot(bC.pos != 0 ? bC.target : na, "tgtC", display=display.data_window)
plot(sigD, "sigD", display=display.data_window)
plot(resD, "resD", display=display.data_window)
plot(xD, "xD", display=display.data_window)
plot(bD.pos != 0 ? bD.stop : na, "stopD", display=display.data_window)
plot(bD.pos != 0 ? bD.target : na, "tgtD", display=display.data_window)
plot(winStartBar, "winStart", display=display.data_window)
plot(bar_index, "bi", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sigA != 0, "VWAP Lab A: first-touch bounce", "VWAP Strategy Lab A (first-touch bounce) on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigB != 0, "VWAP Lab B: break and retest", "VWAP Strategy Lab B (break and retest) on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigC != 0, "VWAP Lab C: band reversion", "VWAP Strategy Lab C (band reversion) on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigD != 0, "VWAP Lab D: anchored VWAP", "VWAP Strategy Lab D (anchored VWAP) on {{ticker}} {{interval}} at {{close}}")

int sigShown = dA ? sigA : dB ? sigB : dC ? sigC : sigD
if i_alertJson and sigShown != 0
    alert('{"action":"' + (sigShown == 1 ? "BUY" : "SELL") + '","indicator":"VWAPLAB","setup":"' + i_show + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(drawnBook.entry) + ',"stop":' + str.tostring(drawnBook.stop) + ',"target":' + str.tostring(drawnBook.target) + '}', alert.freq_once_per_bar_close)
````
