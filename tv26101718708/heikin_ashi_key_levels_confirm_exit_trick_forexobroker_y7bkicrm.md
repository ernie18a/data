# Heikin Ashi Key Levels: Confirm + Exit Trick [forexobroker]

- url: https://www.tradingview.com/script/Y7BKiCrM-Heikin-Ashi-Key-Levels-Confirm-Exit-Trick-forexobroker/
- type: indicator
- pine_id: PUB;d06418191cce4dd9b8474c7ec136945c
- version: 1.0

## Description

Heikin Ashi Key Levels: Confirm + Exit Trick [forexobroker]

🔶 OVERVIEW

Heikin Ashi Key Levels trades a popular Heikin Ashi strategy the way it should be tested: the key levels are found on the real price, Heikin Ashi only confirms the turn, and every entry, stop, target and exit uses real prices. Three different exits are logged on the very same trades, so you can see on your own chart which one actually works, next to two reference ledgers over the same days.

The script draws Heikin Ashi candles in its own pane under the price chart, so you get the real price and Heikin Ashi side by side on any TradingView plan.

🔶 HOW IT WORKS

1. Heikin Ashi (standard formula). Close = (open + high + low + close) / 4, open = the middle of the previous Heikin Ashi body, high and low = the extremes. Drawn in the script's pane.

2. Key levels. A swing low (5 candles on each side) that price left by at least 2 ATR within the next 20 candles is a support; the mirror is a resistance. Each level is drawn as a band and lives for 300 candles; a close more than 0.5 ATR through it removes it.

3. The revisit. A real low within 0.3 ATR of a support (a high, for a resistance).

4. The confirmation, within 15 candles of the touch: the previous Heikin Ashi candle against the trade, then a candle in the trade's colour with no wick on the far side and a body that is still small (at most 1.2 times the average of the last 10 bodies). Entry at that candle's real close.

5. Stop just beyond the level (0.2 ATR past it, at least 0.25 ATR from the entry). Target at 2R. One trade at a time.

🔶 THREE EXITS ON THE SAME TRADES

A: fixed target at 2R.
B: half closed at 2R, the stop moved to break-even, the rest closed on the first Heikin Ashi candle of the opposite colour.
C: no target; the whole trade closes on the first opposite Heikin Ashi candle (the stop still applies).
All three are logged on every trade. The "Draw the trades of" setting only decides which one is drawn on the chart.

🔶 THE TABLE

For each exit: trades, wins, total R, average R and the worst losing run. Then two reference ledgers counted over the same days: the doji reversal (at least 5 Heikin Ashi candles of one colour, a doji, then two strong opposite candles with no wick on the far side; stop at the extreme of the three, 2R) and every Heikin Ashi colour flip (risk 1 ATR, out on the next flip). The last row books exit A at Heikin Ashi prices instead of real prices: entry at the Heikin Ashi close, stop and target checked against the Heikin Ashi candles. It shows how far a backtest on Heikin Ashi candles drifts from what real prices give.

The window: the last N key-level trades (100 by default); the other ledgers are counted over the same days. Its dates are printed under the table.

NON-REPAINTING: every level, touch, signal and result is evaluated on barstate.isconfirmed; pivots are confirmed candles later; there is no request.security and no lookahead.

🔶 SETTINGS

Key levels
- Swing strength (5), rejection in ATR (2.0) and within how many candles (20), level life (300 candles), revisit distance (0.3 ATR), broken by a close beyond (0.5 ATR).

Heikin Ashi confirmation
- Confirmation window (15 candles), small body (1.2 × the average), average body length (10).

Trade and exits
- Stop beyond the level (0.2 ATR), minimum stop (0.25 ATR), target (2R), exit B part closed at the target (0.5), which exit is drawn, ATR length (14).

Doji reversal
- Trend before the doji (5 candles), doji body (0.25 × its range), colour-flip risk (1 ATR).

Comparison window and table
- Window size (100), show the table, position, text size.

Visual
- Colours, draw key levels, labels, trades kept on the chart.

🔶 ALERTS

Four alertcondition hooks: buy at support, sell at resistance, doji reversal buy, doji reversal sell. With JSON alerts on, every key-level entry also fires an alert() once per bar close with a JSON body (action, ticker, timeframe, entry, stop, target).

🔶 LIMITATIONS

- Heikin Ashi candles are averages and react late by design. They are used here only to confirm and to exit; never measure price on them.
- Results depend on the market, the timeframe and the settings; the table shows them on your own chart, losses included.
- Results in the table are the script's own rules applied to closed candles: no spread, no commission, no slippage, and the stop is counted before the target on a candle that touches both.
- This is an analysis tool, not financial advice, and past performance does not guarantee future results. Test on your own market and timeframe before relying on any signal.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Heikin Ashi Key Levels — key levels on the real price, Heikin Ashi as the confirmation, three ways to exit
// the same trades, and two reference ledgers, all on the chart.
// (1) Heikin Ashi candles (standard formula) are drawn in this script's own pane, so the real price stays on the chart
//     above: a free side-by-side view. Every entry, stop, target and exit uses REAL prices; Heikin Ashi only decides.
// (2) Key level: a swing low (N candles each side) that price left by at least X ATR within the next M candles is a
//     support; the mirror is a resistance. A level lives for a set number of candles and is removed when a close
//     breaks through it.
// (3) The revisit: a real low within a fraction of an ATR of a support (high, for a resistance) without closing through it.
// (4) The confirmation, within a window after the touch: the previous Heikin Ashi candle against the trade, then a
//     candle in the trade's colour with no wick on the far side and a body that is still small (at most a multiple of
//     the average of the last bodies). Entry at that candle's real close.
// (5) Stop slightly beyond the level (at least a quarter ATR from the entry). Exits, all measured on the same entries:
//     A fixed target at 2R; B half off at 2R, stop to break-even, the rest out on the first opposite Heikin Ashi candle;
//     C no target, everything out on the first opposite Heikin Ashi candle. One trade at a time: a new entry waits until
//     every exit of the previous trade is closed.
// Reference ledgers over the same days: the doji reversal (a trend, a Heikin Ashi doji, two strong opposite candles with
// one shadow; stop at the extreme of the three, 2R) and every Heikin Ashi colour flip (risk 1 ATR, out on the next
// flip). And exit A booked at Heikin Ashi prices instead of real prices, to show how far such a backtest drifts.
// Non-repainting: every level, touch, signal and result is evaluated on barstate.isconfirmed; pivots are confirmed
// candles later; there is no request.security and no lookahead.
indicator("Heikin Ashi Key Levels: Confirm + Exit Trick [forexobroker]", shorttitle="HAKL [fob]", overlay=false, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=2000)

// ─── INPUT GROUPS ──────────────────────────────────────────────────────────────
string g_lv   = "Key levels"
string g_cf   = "Heikin Ashi confirmation"
string g_tr   = "Trade and exits"
string g_dj   = "Doji reversal"
string g_log  = "Comparison window and table"
string g_vis  = "Visual"
string g_al   = "Alerts"

string X_A = "A: fixed target at 2R"
string X_B = "B: half at 2R, ride the rest"
string X_C = "C: ride with Heikin Ashi"

// ─── INPUTS ────────────────────────────────────────────────────────────────────
int   i_pivStr   = input.int(5, "Swing strength (candles each side)", minval=1, maxval=20, group=g_lv)
float i_rejAtr   = input.float(2.0, "Rejection: price left by at least (ATR)", minval=0.5, maxval=10, step=0.5, group=g_lv)
int   i_rejBars  = input.int(20, "Rejection: within (candles)", minval=5, maxval=100, group=g_lv)
int   i_life     = input.int(300, "A level lives for (candles)", minval=20, maxval=2000, group=g_lv)
float i_touchAtr = input.float(0.3, "Revisit: within (ATR) of the level", minval=0.0, maxval=2, step=0.1, group=g_lv)
float i_breakAtr = input.float(0.5, "Broken by a close beyond (ATR)", minval=0.1, maxval=3, step=0.1, group=g_lv)

int   i_confWin  = input.int(15, "Confirmation within (candles of the touch)", minval=1, maxval=60, group=g_cf)
float i_small    = input.float(1.2, "Small body: at most (× average body)", minval=0.2, maxval=5, step=0.1, group=g_cf)
int   i_bodyLen  = input.int(10, "Average body over (candles)", minval=3, maxval=50, group=g_cf)

float i_stopBuf  = input.float(0.2, "Stop beyond the level by (ATR)", minval=0.0, maxval=2, step=0.1, group=g_tr)
float i_minRisk  = input.float(0.25, "Stop at least (ATR) from the entry", minval=0.05, maxval=2, step=0.05, group=g_tr)
float i_rr       = input.float(2.0, "Target (R)", minval=0.5, maxval=10, step=0.5, group=g_tr)
float i_part     = input.float(0.5, "Exit B: part closed at the target", minval=0.1, maxval=0.9, step=0.1, group=g_tr)
string i_draw    = input.string(X_B, "Draw the trades of", options=[X_A, X_B, X_C], group=g_tr, tooltip="All three exits are logged on every trade; this only decides which one is drawn on the chart.")
int   i_atrLen   = input.int(14, "ATR length", minval=1, maxval=200, group=g_tr)

int   i_trendLen = input.int(5, "Trend before the doji (candles of one colour)", minval=2, maxval=30, group=g_dj)
float i_dojiBody = input.float(0.25, "Doji: body at most (× its range)", minval=0.05, maxval=0.6, step=0.05, group=g_dj)
float i_flipRisk = input.float(1.0, "Colour flips: risk (ATR)", minval=0.2, maxval=5, step=0.1, group=g_dj)

int    i_windowN   = input.int(100, "Window: the last N trades of the key-level strategy", minval=10, maxval=1000, group=g_log)
bool   i_showTable = input.bool(true, "Show the comparison table", group=g_log)
string i_tablePos  = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=g_log)
string i_tableSize = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=g_log)

color i_upCol    = input.color(#00E5A8, "Up colour", group=g_vis)
color i_dnCol    = input.color(#FF3B5C, "Down colour", group=g_vis)
color i_lvCol    = input.color(#F5C542, "Key level colour", group=g_vis)
bool  i_showLv   = input.bool(true, "Draw key levels", group=g_vis)
bool  i_labels   = input.bool(true, "Show BUY / SELL and result labels", group=g_vis)
int   i_keep     = input.int(120, "Trades kept on chart", minval=10, maxval=200, group=g_vis)

bool i_alertJson = input.bool(true, "Send JSON alert() messages", group=g_al)

color c_white  = #FFFFFF
color c_dark   = #0B0F14
color c_purple = #A259FF
color c_grey   = #9AA4AE

// ─── HEIKIN ASHI ───────────────────────────────────────────────────────────────
bool  confirmed = barstate.isconfirmed
float haC = (open + high + low + close) / 4
var float haO = na
haO := na(haO) ? (open + close) / 2 : (haO + haC[1]) / 2
float haH = math.max(high, haO, haC)
float haL = math.min(low, haO, haC)
bool  haG = haC >= haO
float haBody = math.abs(haC - haO)
bool  noLowW = low >= math.min(haO, haC)          // no lower wick: the real low never went below the body
bool  noHighW = high <= math.max(haO, haC)
bool  isDoji = haBody <= i_dojiBody * (haH - haL) and not noLowW and not noHighW
float smaBody = ta.sma(haBody, i_bodyLen)
float bodyAvg = smaBody[1]                         // the last bodies, not counting this one
float bodyAvgD = smaBody[3]                        // the bodies before the doji (doji reversal)
float atrV = ta.atr(i_atrLen)

plotcandle(haO, haH, haL, haC, "Heikin Ashi", color=haG ? i_upCol : i_dnCol, wickcolor=haG ? i_upCol : i_dnCol, bordercolor=haG ? i_upCol : i_dnCol)

// ─── KEY LEVELS ────────────────────────────────────────────────────────────────
float pl = ta.pivotlow(low, i_pivStr, i_pivStr)
float ph = ta.pivothigh(high, i_pivStr, i_pivStr)
float hhR = ta.highest(high, i_rejBars)            // the candles after a pivot that is i_rejBars old
float llR = ta.lowest(low, i_rejBars)
float atrPiv = atrV[i_rejBars]

var array<int>   cBar  = array.new<int>()
var array<float> cPx   = array.new<float>()
var array<int>   cSide = array.new<int>()
var array<int>   lvSide  = array.new<int>()
var array<float> lvPx    = array.new<float>()
var array<int>   lvPiv   = array.new<int>()
var array<int>   lvTouch = array.new<int>()
var array<box>   lvBox   = array.new<box>()
var array<box>   oldBox  = array.new<box>()

int   lvNewSide = 0
float lvNewPx = na
int   lvNewPiv = na

if confirmed
    if not na(pl)
        array.push(cBar, bar_index - i_pivStr)
        array.push(cPx, pl)
        array.push(cSide, 1)
    if not na(ph)
        array.push(cBar, bar_index - i_pivStr)
        array.push(cPx, ph)
        array.push(cSide, -1)
    // candidates whose rejection window has just completed
    while array.size(cBar) > 0 and array.get(cBar, 0) <= bar_index - i_rejBars
        int   b = array.shift(cBar)
        float p = array.shift(cPx)
        int   s = array.shift(cSide)
        if b == bar_index - i_rejBars and not na(atrPiv)
            bool rej = s == 1 ? hhR - p >= i_rejAtr * atrPiv : p - llR >= i_rejAtr * atrPiv
            if rej
                array.push(lvSide, s)
                array.push(lvPx, p)
                array.push(lvPiv, b)
                array.push(lvTouch, na)
                array.push(lvBox, i_showLv ? box.new(b, p + (s == 1 ? 0.0 : 0.15) * atrPiv, bar_index, p - (s == 1 ? 0.15 : 0.0) * atrPiv, border_color=color.new(i_lvCol, 40), bgcolor=color.new(i_lvCol, 85), force_overlay=true) : na)
                lvNewSide := s
                lvNewPx := p
                lvNewPiv := b

// A level that expires or breaks is removed from the chart; a level that produced a trade stays, faded, as its record.
f_retire(int k, bool traded) =>
    box bx = array.get(lvBox, k)
    if not na(bx)
        if traded
            box.set_bgcolor(bx, color.new(i_lvCol, 88))
            box.set_border_color(bx, color.new(i_lvCol, 55))
            array.push(oldBox, bx)
            if array.size(oldBox) > 150
                box.delete(array.shift(oldBox))
        else
            box.delete(bx)
    array.remove(lvSide, k)
    array.remove(lvPx, k)
    array.remove(lvPiv, k)
    array.remove(lvTouch, k)
    array.remove(lvBox, k)

// ─── LEDGERS ───────────────────────────────────────────────────────────────────
type Ledger
    array<float> r
    array<int>   te
    array<int>   tt
    array<int>   held

f_ledger() => Ledger.new(array.new<float>(), array.new<int>(), array.new<int>(), array.new<int>())

var Ledger LA = f_ledger()
var Ledger LB = f_ledger()
var Ledger LC = f_ledger()
var Ledger LH = f_ledger()
var Ledger LD = f_ledger()
var Ledger LF = f_ledger()

f_book(Ledger L, float res, int eb, int et) =>
    array.push(L.r, res)
    array.push(L.te, eb)
    array.push(L.tt, et)
    array.push(L.held, bar_index - eb)
    if array.size(L.r) > 5000
        array.shift(L.r)
        array.shift(L.te)
        array.shift(L.tt)
        array.shift(L.held)

// gap-aware stop fill: a candle that opens beyond the stop fills at its open
f_stopFill(int side, float stp) => side == 1 ? math.min(open, stp) : math.max(open, stp)

// ─── STRATEGY 1 STATE ──────────────────────────────────────────────────────────
var int   tSide = 0
var int   tBar = na
var int   tTime = na
var float tE = na
var float tS = na
var float tRisk = na
var float tT = na
var float tEH = na
var float tTH = na
var float tRiskH = na
var bool  aOpen = false
var bool  bOpen = false
var bool  cOpen = false
var bool  hOpen = false
var bool  bHalf = false
var float bBank = 0.0
var array<label> drawn = array.new<label>()
var array<line>  drawnL = array.new<line>()

f_trim() =>
    if array.size(drawn) > 0
        while array.size(drawn) > i_keep * 3
            label.delete(array.shift(drawn))
    if array.size(drawnL) > 0
        while array.size(drawnL) > i_keep * 3
            line.delete(array.shift(drawnL))

f_rlabel(float res, float px, int side) =>
    if i_labels
        bool win = res > 0
        array.push(drawn, label.new(bar_index, px, (res > 0 ? "+" : "") + str.tostring(res, "#.#") + "R", color=color.new(win ? i_upCol : i_dnCol, 0), textcolor=win ? c_dark : c_white, style=side == 1 ? label.style_label_down : label.style_label_up, size=size.small, force_overlay=true))
        f_trim()

bool dA = i_draw == X_A
bool dB = i_draw == X_B
bool dC = i_draw == X_C

float resA = na
float xA = na
float resB = na
float xB = na
int   halfB = 0
float resC = na
float xC = na
float resH = na
float xH = na

if confirmed and tSide != 0 and bar_index > tBar
    bool against = tSide == 1 ? not haG : haG
    // A: stop first, then the 2R target
    if aOpen
        bool sH = tSide == 1 ? low <= tS : high >= tS
        bool tH_ = tSide == 1 ? high >= tT : low <= tT
        if sH
            xA := f_stopFill(tSide, tS)
            resA := (xA - tE) * tSide / tRisk
        else if tH_
            xA := tT
            resA := i_rr
        if not na(resA)
            aOpen := false
            f_book(LA, resA, tBar, tTime)
            if dA
                f_rlabel(resA, xA, tSide)
    // B: before the target like A; after it, half is banked, the stop sits at the entry, the rest rides Heikin Ashi
    if bOpen
        if not bHalf
            bool sH = tSide == 1 ? low <= tS : high >= tS
            bool tH_ = tSide == 1 ? high >= tT : low <= tT
            if sH
                xB := f_stopFill(tSide, tS)
                resB := (xB - tE) * tSide / tRisk
            else if tH_
                bHalf := true
                bBank := i_part * i_rr
                halfB := 1
                if against
                    xB := close
                    resB := bBank + (1 - i_part) * (close - tE) * tSide / tRisk
        else
            bool beH = tSide == 1 ? low <= tE : high >= tE
            if beH
                xB := f_stopFill(tSide, tE)
                resB := bBank + (1 - i_part) * (xB - tE) * tSide / tRisk
            else if against
                xB := close
                resB := bBank + (1 - i_part) * (close - tE) * tSide / tRisk
        if not na(resB)
            bOpen := false
            f_book(LB, resB, tBar, tTime)
            if dB
                f_rlabel(resB, xB, tSide)
    // C: no target; the stop, or the first Heikin Ashi candle against the trade
    if cOpen
        bool sH = tSide == 1 ? low <= tS : high >= tS
        if sH
            xC := f_stopFill(tSide, tS)
            resC := (xC - tE) * tSide / tRisk
        else if against
            xC := close
            resC := (close - tE) * tSide / tRisk
        if not na(resC)
            cOpen := false
            f_book(LC, resC, tBar, tTime)
            if dC
                f_rlabel(resC, xC, tSide)
    // H: exit A booked at Heikin Ashi prices (the backtest that uses the wrong candles)
    if hOpen
        bool sH = tSide == 1 ? haL <= tS : haH >= tS
        bool tH_ = tSide == 1 ? haH >= tTH : haL <= tTH
        if sH
            xH := tS
            resH := -1.0
        else if tH_
            xH := tTH
            resH := i_rr
        if not na(resH)
            hOpen := false
            f_book(LH, resH, tBar, tTime)
    if not aOpen and not bOpen and not cOpen and not hOpen
        tSide := 0

// ─── STRATEGY 1: TOUCHES AND THE CONFIRMATION ──────────────────────────────────
int   sig1 = 0
float sLvl = na
int   sPiv = na
int   sTouch = na
float sE = na
float sS = na
float sT = na
int   lvTouchNew = 0

if confirmed and not na(atrV) and not na(bodyAvg)
    int n = array.size(lvSide)
    if n > 0
        for k = n - 1 to 0
            if k >= array.size(lvSide)
                continue
            int   s  = array.get(lvSide, k)
            float p  = array.get(lvPx, k)
            int   pv = array.get(lvPiv, k)
            int   tc = array.get(lvTouch, k)
            box   bx = array.get(lvBox, k)
            if not na(bx)
                box.set_right(bx, bar_index)
            bool broken = s == 1 ? close < p - i_breakAtr * atrV : close > p + i_breakAtr * atrV
            if bar_index - pv > i_life or broken
                f_retire(k, false)
                continue
            if na(tc)
                bool touch = s == 1 ? low <= p + i_touchAtr * atrV : high >= p - i_touchAtr * atrV
                if touch
                    array.set(lvTouch, k, bar_index)
                    lvTouchNew := s
                    if not na(bx)
                        box.set_bgcolor(bx, color.new(i_lvCol, 70))
                continue
            if bar_index - tc > i_confWin
                array.set(lvTouch, k, na)
                if not na(bx)
                    box.set_bgcolor(bx, color.new(i_lvCol, 85))
                continue
            bool want = s == 1
            bool conf = (haG == want) and (want ? noLowW : noHighW) and (haG[1] != want) and haBody <= i_small * bodyAvg
            if conf and sig1 == 0 and tSide == 0
                float stp = s == 1 ? math.min(p - i_stopBuf * atrV, close - i_minRisk * atrV) : math.max(p + i_stopBuf * atrV, close + i_minRisk * atrV)
                sig1 := s
                sLvl := p
                sPiv := pv
                sTouch := tc
                sE := close
                sS := stp
                sT := close + s * i_rr * math.abs(close - stp)
                f_retire(k, true)

if sig1 != 0
    tSide := sig1
    tBar := bar_index
    tTime := time
    tE := sE
    tS := sS
    tRisk := math.abs(sE - sS)
    tT := sT
    tEH := haC
    tRiskH := math.max(math.abs(haC - sS), i_minRisk * atrV)
    tTH := haC + sig1 * i_rr * tRiskH
    aOpen := true
    bOpen := true
    cOpen := true
    hOpen := true
    bHalf := false
    bBank := 0.0
    if i_labels
        string tip = (sig1 == 1 ? "BUY at support " : "SELL at resistance ") + str.tostring(sLvl, format.mintick) + "\nHeikin Ashi turned " + (sig1 == 1 ? "green with no lower wick" : "red with no upper wick") + ", body still small\nEntry " + str.tostring(sE, format.mintick) + " · stop " + str.tostring(sS, format.mintick) + " · 2R " + str.tostring(sT, format.mintick)
        array.push(drawn, label.new(bar_index, sig1 == 1 ? low : high, sig1 == 1 ? "BUY" : "SELL", color=color.new(sig1 == 1 ? i_upCol : i_dnCol, 0), textcolor=sig1 == 1 ? c_dark : c_white, style=sig1 == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tip, force_overlay=true))
        array.push(drawnL, line.new(bar_index, sS, bar_index + 12, sS, color=color.new(i_dnCol, 20), width=2, force_overlay=true))
        array.push(drawnL, line.new(bar_index, sT, bar_index + 12, sT, color=color.new(i_upCol, 20), width=2, style=line.style_dashed, force_overlay=true))
        f_trim()

// ─── STRATEGY 2: THE DOJI REVERSAL ─────────────────────────────────────────────
var int   dSide = 0
var int   dBar = na
var int   dTime = na
var float dE = na
var float dS = na
var float dT = na
float resD = na
float xD = na
int   sigD = 0
float dEnt = na
float dStp = na

if confirmed and dSide != 0 and bar_index > dBar
    bool sH = dSide == 1 ? low <= dS : high >= dS
    bool tH_ = dSide == 1 ? high >= dT : low <= dT
    if sH
        xD := f_stopFill(dSide, dS)
        resD := (xD - dE) * dSide / math.abs(dE - dS)
    else if tH_
        xD := dT
        resD := i_rr
    if not na(resD)
        f_book(LD, resD, dBar, dTime)
        dSide := 0

if confirmed and dSide == 0 and not na(atrV) and bar_index > i_trendLen + i_bodyLen + 3
    float avgB = bodyAvgD
    for side in array.from(1, -1)
        bool want = side == 1
        bool twoStrong = haG == want and haG[1] == want and (want ? noLowW and noLowW[1] : noHighW and noHighW[1]) and haBody >= avgB and haBody[1] >= avgB
        bool dojiPrev = isDoji[2]
        bool trendBefore = true
        for j = 3 to i_trendLen + 2
            if haG[j] == want
                trendBefore := false
        if twoStrong and dojiPrev and trendBefore and sigD == 0
            float ext = side == 1 ? math.min(low, low[1], low[2]) : math.max(high, high[1], high[2])
            float stp = side == 1 ? math.min(ext, close - i_minRisk * atrV) : math.max(ext, close + i_minRisk * atrV)
            sigD := side
            dEnt := close
            dStp := stp
    if sigD != 0
        dSide := sigD
        dBar := bar_index
        dTime := time
        dE := dEnt
        dS := dStp
        dT := dEnt + sigD * i_rr * math.abs(dEnt - dStp)

// ─── THE 99 % WAY: EVERY COLOUR FLIP ───────────────────────────────────────────
var int   fSide = 0
var int   fBar = na
var int   fTime = na
var float fE = na
var float fS = na
var float fRisk = na
float resF = na
float xF = na
int   sigF = 0

if confirmed and not na(atrV) and bar_index > 1
    bool flip = haG != haG[1]
    if fSide != 0 and bar_index > fBar
        bool sH = fSide == 1 ? low <= fS : high >= fS
        if sH
            xF := f_stopFill(fSide, fS)
            resF := (xF - fE) * fSide / fRisk
        else if flip
            xF := close
            resF := (close - fE) * fSide / fRisk
        if not na(resF)
            f_book(LF, resF, fBar, fTime)
            fSide := 0
    if flip
        sigF := haG ? 1 : -1
        fSide := sigF
        fBar := bar_index
        fTime := time
        fE := close
        fRisk := i_flipRisk * atrV
        fS := close - sigF * fRisk

// ─── THE COMPARISON WINDOW ─────────────────────────────────────────────────────
int nA = array.size(LA.r)
int winStartBar = nA == 0 ? na : nA >= i_windowN ? array.get(LA.te, nA - i_windowN) : array.get(LA.te, 0)
int winStartTime = nA == 0 ? na : nA >= i_windowN ? array.get(LA.tt, nA - i_windowN) : array.get(LA.tt, 0)

f_stats(Ledger L) =>
    int n = 0
    int w = 0
    float tot = 0.0
    int worst = 0
    int run = 0
    int sz = array.size(L.r)
    if sz > 0 and not na(winStartBar)
        for i = 0 to sz - 1
            if array.get(L.te, i) >= winStartBar
                float r = array.get(L.r, i)
                n += 1
                tot += r
                if r > 0
                    w += 1
                    run := 0
                else
                    run += 1
                    worst := math.max(worst, run)
    [n, w, tot, worst]

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
    var table tb = table.new(f_pos(i_tablePos), 6, 10, bgcolor=color.new(c_dark, 8), border_color=color.new(c_purple, 45), border_width=1, frame_color=color.new(c_purple, 15), frame_width=2, force_overlay=true)
    string ts  = i_tableSize == "Large" ? size.normal : i_tableSize == "Small" ? size.tiny : size.small
    string tsH = i_tableSize == "Large" ? size.large : i_tableSize == "Small" ? size.small : size.normal
    table.cell(tb, 0, 0, "HEIKIN ASHI KEY LEVELS", text_color=c_white, text_size=tsH, text_halign=text.align_left, bgcolor=color.new(c_purple, 70))
    table.merge_cells(tb, 0, 0, 4, 0)
    table.cell(tb, 5, 0, "[fob]", text_color=color.new(c_white, 35), text_size=ts, text_halign=text.align_right, bgcolor=color.new(c_purple, 70))
    array<string> hdr = array.from("Ledger", "Trades", "Won", "Total R", "Avg R", "Worst run")
    for c = 0 to 5
        table.cell(tb, c, 1, array.get(hdr, c), text_color=c_grey, text_size=ts, text_halign=c == 0 ? text.align_left : text.align_right)
    array<string> names = array.from("Key levels · " + X_A, "Key levels · " + X_B, "Key levels · " + X_C, "Doji reversal", "Every colour flip", "Exit A booked at Heikin Ashi prices")
    for k = 0 to 5
        Ledger L = k == 0 ? LA : k == 1 ? LB : k == 2 ? LC : k == 3 ? LD : k == 4 ? LF : LH
        [n, w, tot, worst] = f_stats(L)
        string nm = array.get(names, k)
        bool sel = (k == 0 and dA) or (k == 1 and dB) or (k == 2 and dC)
        color bg = sel ? color.new(c_purple, 78) : k == 5 ? color.new(c_grey, 85) : na
        table.cell(tb, 0, k + 2, (sel ? "▸ " : "") + nm, text_color=c_white, text_size=ts, text_halign=text.align_left, bgcolor=bg)
        table.cell(tb, 1, k + 2, str.tostring(n), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 2, k + 2, str.tostring(w), text_color=i_upCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 3, k + 2, n > 0 ? f_r(tot) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 4, k + 2, n > 0 ? f_r2(tot / n) : "-", text_color=tot >= 0 ? i_upCol : i_dnCol, text_size=ts, text_halign=text.align_right, bgcolor=bg)
        table.cell(tb, 5, k + 2, str.tostring(worst), text_color=c_white, text_size=ts, text_halign=text.align_right, bgcolor=bg)
    string wtxt = na(winStartBar) ? "Window: not enough trades yet" : "Window: the last " + str.tostring(math.min(i_windowN, nA)) + " key-level trades · " + str.format_time(winStartTime, "d MMM yyyy", syminfo.timezone) + " to " + str.format_time(time, "d MMM yyyy", syminfo.timezone)
    table.cell(tb, 0, 8, wtxt, text_color=c_grey, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 8, 5, 8)
    string now = "Now: Heikin Ashi " + (haG ? "green" : "red") + (haG ? (noLowW ? ", no lower wick" : "") : (noHighW ? ", no upper wick" : "")) + (isDoji ? ", doji" : "") + " · " + str.tostring(array.size(lvSide)) + " key levels watched"
    table.cell(tb, 0, 9, now, text_color=c_grey, text_size=ts, text_halign=text.align_left)
    table.merge_cells(tb, 0, 9, 5, 9)

// ─── DATA-WINDOW PLOTS (read by tools, hidden on the chart) ────────────────────
plot(bar_index, "bi", display=display.data_window)
plot(haO, "haO", display=display.data_window)
plot(haH, "haH", display=display.data_window)
plot(haL, "haL", display=display.data_window)
plot(haC, "haC", display=display.data_window)
plot(atrV, "atr", display=display.data_window)
plot(lvNewSide, "lvNewSide", display=display.data_window)
plot(lvNewPx, "lvNewPx", display=display.data_window)
plot(lvNewPiv, "lvNewPiv", display=display.data_window)
plot(lvTouchNew, "lvTouch", display=display.data_window)
plot(sig1, "sig1", display=display.data_window)
plot(sLvl, "sLvl", display=display.data_window)
plot(sPiv, "sPiv", display=display.data_window)
plot(sTouch, "sTouch", display=display.data_window)
plot(sE, "sE", display=display.data_window)
plot(sS, "sS", display=display.data_window)
plot(sT, "sT", display=display.data_window)
plot(sig1 != 0 ? tEH : na, "sEH", display=display.data_window)
plot(sig1 != 0 ? tTH : na, "sTH", display=display.data_window)
plot(resA, "resA", display=display.data_window)
plot(xA, "xA", display=display.data_window)
plot(resB, "resB", display=display.data_window)
plot(xB, "xB", display=display.data_window)
plot(halfB, "halfB", display=display.data_window)
plot(resC, "resC", display=display.data_window)
plot(xC, "xC", display=display.data_window)
plot(resH, "resH", display=display.data_window)
plot(xH, "xH", display=display.data_window)
plot(sigD, "sigD", display=display.data_window)
plot(dEnt, "dE", display=display.data_window)
plot(dStp, "dS", display=display.data_window)
plot(resD, "resD", display=display.data_window)
plot(xD, "xD", display=display.data_window)
plot(sigF, "sigF", display=display.data_window)
plot(resF, "resF", display=display.data_window)
plot(xF, "xF", display=display.data_window)
plot(winStartBar, "winStart", display=display.data_window)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(sig1 == 1, "HAKL Buy at support", "Heikin Ashi Key Levels: BUY at support on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig1 == -1, "HAKL Sell at resistance", "Heikin Ashi Key Levels: SELL at resistance on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigD == 1, "HAKL Doji reversal buy", "Heikin Ashi Key Levels, doji reversal: BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigD == -1, "HAKL Doji reversal sell", "Heikin Ashi Key Levels, doji reversal: SELL on {{ticker}} {{interval}} at {{close}}")
if i_alertJson and sig1 != 0
    alert('{"action":"' + (sig1 == 1 ? "BUY" : "SELL") + '","indicator":"HAKL","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","entry":' + str.tostring(sE) + ',"stop":' + str.tostring(sS) + ',"target":' + str.tostring(sT) + '}', alert.freq_once_per_bar_close)
````
