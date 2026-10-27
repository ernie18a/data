# Cross-Exchange Sweep [Zen]

- url: https://www.tradingview.com/script/iPeVL1ep-Cross-Exchange-Sweep-Zen/
- type: indicator
- pine_id: PUB;3dfb511703ee4e19adb90d49d6f40cd9
- version: 2.0

## Description

Cross-Exchange Sweep [Zen] checks every liquidity sweep on your chart against three other crypto exchanges on the same closed candle. Each exchange is compared with its own pool, so you see whether the level was taken across the market or only on the exchange you are looking at.

WHAT IS ORIGINAL
Pools and sweeps are standard concepts. Here a sweep is not judged from one exchange only; the script adds a cross-exchange check:
- For every sweep on the chart exchange, the same candle is read from Binance, Bybit and OKX (if the chart is on one of them, that one is replaced by Bitget).
- Each reference exchange is checked against its own pool, built from its own previous candles, not against the chart's price. A small price difference between exchanges is therefore not counted as a missed level.
- Every sweep gets a class: MARKET-WIDE, SPLIT, LOCAL WICK, or n/a when fewer than two references have data. MARKET-WIDE and SPLIT plates show which exchanges took their level.
- The table counts each class over the loaded history, so you can see how often sweeps on this symbol and timeframe were local.
Instead of relying on one exchange's wick, you see whether the other exchanges took their own matching level on the same candle.
Relation to my Sweep OI Flush [Zen]: both use the same sweep rule. That script classifies a sweep by the open interest change on one exchange; this one uses no open interest and checks whether each reference exchange took its own level on the same candle.

WHAT IT SHOWS
- Pool: the highest high and the lowest low of the previous N closed candles (Pool length, 20 by default). Step lines show the chart exchange's pools.
- Sweep (chart exchange): a closed candle's wick goes beyond the pool and the candle closes back inside it. A wick or a close exactly at the pool is not a sweep.
- Reference exchanges: BINANCE, BYBIT and OKX with the same ticker as the chart (for example BINANCE:BTCUSDT.P). If the chart is on one of them, that one is replaced by BITGET.
- Result of each reference on the same candle:
  swept: its wick went beyond its own pool and the candle closed back inside,
  broke: its wick went beyond its own pool and the candle closed at or beyond it,
  no: its wick did not go beyond its own pool,
  n/a: no candle with the same open time, or not enough history for a full pool.
  An exchange took the level when its result is swept or broke.
- Class (only references with data are counted):
  MARKET-WIDE: every reference with data took its level.
  SPLIT: some took it, some did not.
  LOCAL WICK: none took it; the sweep happened only on the chart exchange.
  n/a: fewer than two references had data on that candle. No marker is drawn; the sweep is counted in the table.
- Markers: MARKET-WIDE is a solid plate "WIDE" in the side colour (orange above the candle for a high sweep, blue below it for a low sweep). SPLIT is a plate "SPLIT" in the table's panel colour with side-coloured text. Under the word, three squares show the references in table order: filled = took its level, empty = did not, dash = no data. LOCAL WICK is a small grey dot (can be hidden in Inputs).
- When two plates on the same side are closer than 8 candles, the older one turns into a small dot of the side colour. Hover any plate or dot for its tooltip: class, side, time (UTC), the chart exchange's pool and wick, and the result of each reference.

TABLE (bottom right by default)
- Last: open time (UTC), side and class of the latest sweep. The row is highlighted while that sweep is on the most recent closed candle.
- For the chart exchange and each reference: Pool, Wick and Result of that latest sweep. A reference without data shows dashes and n/a.
- History: the number of WIDE, SPLIT and LOCAL sweeps, n/a sweeps and the total, over all loaded candles.
- A legend for the squares.
- "no reference data" in the Last row means that none of the three references had a candle with the same open time as any closed chart candle in the loaded history.

ALERTS
All alerts fire at candle close. Sweeps with class n/a send no alert.
- "Any alert() function call": one plain-text message per candle with the class, the side and the result of each reference, for example: "BTCUSDT.P 4H BITGET: SPLIT high sweep. BINANCE took, BYBIT took, OKX did not take." If one candle sweeps both pools, both are in the same message.
- Three alert conditions: "MARKET-WIDE sweep", "SPLIT sweep" and "LOCAL WICK sweep". Their messages include the exchange, ticker and timeframe.

HOW TO USE
- Built for USDT perpetuals on Bitget, Binance, Bybit and OKX. The ticker must have the same name on the reference exchanges. A spot chart is compared with spot markets of the same name.
- When a sweep prints on your chart, check its class: MARKET-WIDE means every reference with data took its own level on the same candle; SPLIT means only some did; LOCAL WICK means none did.
- The History row shows how often sweeps on this symbol and timeframe were local.
- It is context for your own analysis, not an entry signal.

INPUTS (defaults)
- Pool length (bars): 20 (5 to 500)
- Show pools: on
- Show LOCAL WICK dots: on
- Show table: on
- Table position: bottom right
Fixed in the code: the reference exchanges, the 8-candle merge distance and the marker limit of about 60.

REALTIME BEHAVIOUR AND LIMITS
- Sweeps and classes are calculated on closed candles only; no marker is drawn on the open candle. The pool lines on the open candle come from closed candles and do not move during it.
- On a live candle, reference values are the latest received at the chart candle's close. If a reference has already opened its next candle, its just-closed candle is used. If a reference has not yet delivered its final prices for that candle, a marker or alert produced live can differ from what the chart shows after a reload, because the history then uses final reference data.
- Only about 60 of the latest markers stay on the chart; the History counts cover all loaded candles, so they depend on how much history the chart loads.
- If one candle sweeps both pools, both sweeps are counted and drawn; the Last row shows the low side.
- A ticker with a different name on a reference exchange (for example with a 1000 prefix) gives n/a for that exchange.
- Use standard candles. On Heikin Ashi, Renko and other synthetic chart types the chart's prices are not the exchange's traded prices, so the comparison does not hold.
- Colours follow the chart theme (light or dark) automatically.

Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
//@version=6
indicator("Cross-Exchange Sweep [Zen]", overlay = true, max_labels_count = 60, behind_chart = false)

// Cross-Exchange Sweep [Zen]
// A sweep on the chart exchange (wick beyond the pool of the previous N closed bars, close back inside, closed bar)
// is compared with three reference exchanges on the same candle. Each exchange is checked against ITS OWN pool.
// Every classified sweep is then followed for N bars: Reversal (a move of k x ATR away from the level first),
// Stop (price trades beyond the sweep wick first) or None, and the table shows the outcome of each class.

// ---------- inputs ----------
poolLen  = input.int(20, "Pool length (bars)", minval = 5, maxval = 500, tooltip = "Pool = highest high / lowest low of the previous N closed bars, computed separately on every exchange.", display = display.none)
showPool = input.bool(true, "Show pools", tooltip = "Step lines of the chart exchange pools.", display = display.none)
showDots = input.bool(true, "Show LOCAL WICK dots", tooltip = "LOCAL WICK: the sweep happened only on the chart exchange, no reference exchange reached its own pool.", display = display.none)
gO = "Outcome statistics"
outN     = input.int(12, "Outcome window (bars)", minval = 2, group = gO, tooltip = "How many bars after the sweep are checked.", display = display.none)
tgtAtr   = input.float(1.0, "Reversal target (x ATR)", minval = 0.1, step = 0.1, group = gO, tooltip = "Reversal = price moves this many ATR from the sweep close, away from the swept level, before it trades beyond the sweep wick.", display = display.none)
atrLen   = input.int(14, "ATR length", minval = 1, group = gO, display = display.none)
showTbl  = input.bool(true, "Show table", group = "Display", display = display.none)
tblPosIn = input.string("Bottom right", "Table position", options = ["Bottom right", "Top right", "Bottom left", "Top left"], group = "Display", display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI     = isLight ? #AD4A12 : #D9703A
color cHItxt  = isLight ? #994110 : #D9703A
color cLO     = isLight ? #1B46B4 : #6F88EE
color cNEU    = isLight ? #647482 : #8C9098
color cMUTED  = isLight ? #505C69 : #9AA3B2
color cINK    = isLight ? #1F2937 : #D1D4DC
color cSOLID  = isLight ? #FFFFFF : #131722
color cPANEL  = isLight ? #F4F5F7 : #1E222D
color cHEAD   = #2A2E39
color cHEADTX = isLight ? #FFFFFF : #D1D4DC
color cBORDER = isLight ? #C4C8CE : #363A45
color cFRESH  = color.new(#C98B78, 60)

// ---------- reference exchanges (the chart exchange is replaced by Bitget) ----------
string pref = syminfo.prefix
string tk   = syminfo.ticker
string ex1  = pref == "BINANCE" ? "BITGET" : "BINANCE"
string ex2  = pref == "BYBIT" ? "BITGET" : "BYBIT"
string ex3  = pref == "OKX" ? "BITGET" : "OKX"

// reference bar with the chart bar's time: on a live bar the reference may already have opened its next bar,
// so its current and previous bars are both requested and the one whose time equals the chart bar's time is used
f_ref() =>
    float ph = ta.highest(high, poolLen)[1] + (bar_index >= poolLen ? 0.0 : na)
    float pl = ta.lowest(low, poolLen)[1] + (bar_index >= poolLen ? 0.0 : na)
    [high, low, close, time, ph, pl, high[1], low[1], close[1], time[1], ph[1], pl[1]]

f_pick(int tA, int tB, float vA, float vB) => tA == time ? vA : tB == time ? vB : na

[h1a, l1a, c1a, t1a, ph1a, pl1a, h1b, l1b, c1b, t1b, ph1b, pl1b] = request.security(ex1 + ":" + tk, timeframe.period, f_ref(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[h2a, l2a, c2a, t2a, ph2a, pl2a, h2b, l2b, c2b, t2b, ph2b, pl2b] = request.security(ex2 + ":" + tk, timeframe.period, f_ref(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[h3a, l3a, c3a, t3a, ph3a, pl3a, h3b, l3b, c3b, t3b, ph3b, pl3b] = request.security(ex3 + ":" + tk, timeframe.period, f_ref(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

int   t1  = t1a == time or t1b == time ? time : na
float h1  = f_pick(t1a, t1b, h1a, h1b)
float l1  = f_pick(t1a, t1b, l1a, l1b)
float c1  = f_pick(t1a, t1b, c1a, c1b)
float ph1 = f_pick(t1a, t1b, ph1a, ph1b)
float pl1 = f_pick(t1a, t1b, pl1a, pl1b)
int   t2  = t2a == time or t2b == time ? time : na
float h2  = f_pick(t2a, t2b, h2a, h2b)
float l2  = f_pick(t2a, t2b, l2a, l2b)
float c2  = f_pick(t2a, t2b, c2a, c2b)
float ph2 = f_pick(t2a, t2b, ph2a, ph2b)
float pl2 = f_pick(t2a, t2b, pl2a, pl2b)
int   t3  = t3a == time or t3b == time ? time : na
float h3  = f_pick(t3a, t3b, h3a, h3b)
float l3  = f_pick(t3a, t3b, l3a, l3b)
float c3  = f_pick(t3a, t3b, c3a, c3b)
float ph3 = f_pick(t3a, t3b, ph3a, ph3b)
float pl3 = f_pick(t3a, t3b, pl3a, pl3b)

// ---------- sweep on the chart exchange ----------
float rawHi  = ta.highest(high, poolLen)[1]
float rawLo  = ta.lowest(low, poolLen)[1]
float poolHi = bar_index >= poolLen ? rawHi : na
float poolLo = bar_index >= poolLen ? rawLo : na
bool swHi = not na(poolHi) and high > poolHi and close < poolHi
bool swLo = not na(poolLo) and low < poolLo and close > poolLo

plot(showPool ? poolHi : na, "Pool high", cHI, 1, plot.style_stepline)
plot(showPool ? poolLo : na, "Pool low", cLO, 1, plot.style_stepline)

// ---------- helpers ----------
// state of one exchange on this candle: -1 n/a, 0 did not reach its pool, 1 wick beyond + close back (swept), 2 wick beyond + close beyond (broke)
f_st(int t, float x, float c, float p, bool up) =>
    int st = -1
    if t == time and not na(p) and not na(x) and not na(c)
        bool reached = up ? x > p : x < p
        bool back = up ? c < p : c > p
        st := reached ? (back ? 1 : 2) : 0
    st

f_nm(int st) => st == -1 ? "n/a" : st == 0 ? "no" : st == 1 ? "swept" : "broke"
f_sq(int st) => st == -1 ? "–" : st >= 1 ? "■" : "□"
f_tk(int st) => st == -1 ? "n/a" : st >= 1 ? "took" : "did not take"

// class: an exchange "took" the level when its wick went beyond its own pool (closed back or not)
f_cls(int a, int b, int c) =>
    int avail = (a >= 0 ? 1 : 0) + (b >= 0 ? 1 : 0) + (c >= 0 ? 1 : 0)
    int hit = (a >= 1 ? 1 : 0) + (b >= 1 ? 1 : 0) + (c >= 1 ? 1 : 0)
    avail < 2 ? 3 : hit == avail ? 0 : hit == 0 ? 2 : 1

f_cname(int k) => k == 0 ? "MARKET-WIDE" : k == 1 ? "SPLIT" : k == 2 ? "LOCAL WICK" : "n/a"
f_tf() => timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period
f_px(float x) => na(x) ? "—" : str.tostring(x, format.mintick)

// small dot marker (a label body, so the tooltip always shows)
f_dot(int x, float y, color col, string tip) =>
    label.new(x, y, "", style = label.style_circle, color = col, size = size.tiny, tooltip = tip)

// turn an existing label into a small dot (two plates of the same side closer than MERGE_BARS bars: the older one becomes a dot)
f_toDot(label l, color col) =>
    label.set_style(l, label.style_circle)
    label.set_text(l, "")
    label.set_color(l, col)
    label.set_size(l, size.tiny)

// ---------- outcome tracking (same rule as Sweep OI Flush [Zen]) ----------
// dir -1 = high sweep (reversal is down), 1 = low sweep (reversal is up); stopX = the sweep wick
type Trk
    int   dir
    int   cls
    float target
    float stopX
    int   barsLeft

float atrV = ta.atr(atrLen)
f_rate(int a, int tot) => tot > 0 ? str.tostring(100.0 * a / tot, "0") + "%" : "—"

// ---------- state ----------
int MERGE_BARS = 8
var array<int> cnt = array.from(0, 0, 0, 0)
var label lastLblHi = na
var int lastBarHi = na
var label lastLblLo = na
var int lastBarLo = na
var int lastT = na
var int lastBar = na
var string lastSide = "—"
var int lastCls = -1
var array<int>   lastSt = array.from(-1, -1, -1, -1)
var array<float> lastPool = array.new<float>(4, na)
var array<float> lastWick = array.new<float>(4, na)
var array<int>   alig = array.from(0, 0, 0)
var array<Trk>   trk   = array.new<Trk>()
var array<int>   wins  = array.from(0, 0, 0)
var array<int>   stops = array.from(0, 0, 0)
var array<int>   exps  = array.from(0, 0, 0)
bool evW = false
bool evS = false
bool evL = false
string evMsg = ""

if barstate.isconfirmed
    // 1) resolve earlier sweeps with this closed bar (a bar that hits both counts as Stop)
    if array.size(trk) > 0
        for i = array.size(trk) - 1 to 0
            Trk tq = array.get(trk, i)
            bool hitS = tq.dir == -1 ? high > tq.stopX : low < tq.stopX
            bool hitT = tq.dir == -1 ? low <= tq.target : high >= tq.target
            if hitS
                array.set(stops, tq.cls, array.get(stops, tq.cls) + 1)
                array.remove(trk, i)
            else if hitT
                array.set(wins, tq.cls, array.get(wins, tq.cls) + 1)
                array.remove(trk, i)
            else
                tq.barsLeft := tq.barsLeft - 1
                if tq.barsLeft <= 0
                    array.set(exps, tq.cls, array.get(exps, tq.cls) + 1)
                    array.remove(trk, i)
    // 2) this bar's sweeps
    array.set(alig, 0, array.get(alig, 0) + (t1 == time ? 1 : 0))
    array.set(alig, 1, array.get(alig, 1) + (t2 == time ? 1 : 0))
    array.set(alig, 2, array.get(alig, 2) + (t3 == time ? 1 : 0))
    for side = 0 to 1
        bool up = side == 0
        if up ? swHi : swLo
            int a = up ? f_st(t1, h1, c1, ph1, true) : f_st(t1, l1, c1, pl1, false)
            int b = up ? f_st(t2, h2, c2, ph2, true) : f_st(t2, l2, c2, pl2, false)
            int c = up ? f_st(t3, h3, c3, ph3, true) : f_st(t3, l3, c3, pl3, false)
            int k = f_cls(a, b, c)
            array.set(cnt, k, array.get(cnt, k) + 1)
            // follow every classified sweep from the next bar (n/a sweeps are not followed)
            if k <= 2 and not na(atrV)
                array.push(trk, Trk.new(up ? -1 : 1, k, up ? close - tgtAtr * atrV : close + tgtAtr * atrV, up ? high : low, outN))
            float pool = up ? poolHi : poolLo
            float wick = up ? high : low
            string sq = f_sq(a) + " " + f_sq(b) + " " + f_sq(c)
            string tip = f_cname(k) + " · " + (up ? "high" : "low") + " sweep · " + str.format_time(time, "yyyy-MM-dd HH:mm", "UTC") + " UTC"
            tip += "\n" + pref + " (chart): pool " + f_px(pool) + ", wick " + f_px(wick) + ", swept"
            tip += "\n" + ex1 + ": " + f_nm(a) + "\n" + ex2 + ": " + f_nm(b) + "\n" + ex3 + ": " + f_nm(c)
            color cS = up ? cHI : cLO
            if k == 2
                if showDots
                    f_dot(bar_index, wick, cNEU, tip)
            else if k <= 1
                label prevL = up ? lastLblHi : lastLblLo
                int prevB = up ? lastBarHi : lastBarLo
                if not na(prevL) and bar_index - prevB < MERGE_BARS
                    f_toDot(prevL, cS)
                color bg = k == 0 ? cS : cPANEL
                color tx = k == 0 ? cSOLID : (up ? cHItxt : cLO)
                string txt = (k == 0 ? "WIDE" : "SPLIT") + "\n" + sq
                label nl = label.new(bar_index, wick, txt, style = up ? label.style_label_down : label.style_label_up, color = bg, textcolor = tx, size = size.small, tooltip = tip)
                if up
                    lastLblHi := nl
                    lastBarHi := bar_index
                else
                    lastLblLo := nl
                    lastBarLo := bar_index
            // remember the latest sweep for the table
            lastT := time
            lastBar := bar_index
            lastSide := up ? "high" : "low"
            lastCls := k
            array.set(lastSt, 0, 1)
            array.set(lastSt, 1, a)
            array.set(lastSt, 2, b)
            array.set(lastSt, 3, c)
            array.set(lastPool, 0, pool)
            array.set(lastPool, 1, a >= 0 ? (up ? ph1 : pl1) : na)
            array.set(lastPool, 2, b >= 0 ? (up ? ph2 : pl2) : na)
            array.set(lastPool, 3, c >= 0 ? (up ? ph3 : pl3) : na)
            array.set(lastWick, 0, wick)
            array.set(lastWick, 1, a >= 0 ? (up ? h1 : l1) : na)
            array.set(lastWick, 2, b >= 0 ? (up ? h2 : l2) : na)
            array.set(lastWick, 3, c >= 0 ? (up ? h3 : l3) : na)
            if k <= 2
                evW := evW or k == 0
                evS := evS or k == 1
                evL := evL or k == 2
                evMsg += syminfo.ticker + " " + f_tf() + " " + pref + ": " + f_cname(k) + " " + (up ? "high" : "low") + " sweep. " + ex1 + " " + f_tk(a) + ", " + ex2 + " " + f_tk(b) + ", " + ex3 + " " + f_tk(c) + ". "

if evMsg != ""
    alert(evMsg, alert.freq_once_per_bar_close)
alertcondition(evW, "MARKET-WIDE sweep", "{{exchange}}:{{ticker}} {{interval}} Cross-Exchange Sweep: MARKET-WIDE sweep")
alertcondition(evS, "SPLIT sweep", "{{exchange}}:{{ticker}} {{interval}} Cross-Exchange Sweep: SPLIT sweep")
alertcondition(evL, "LOCAL WICK sweep", "{{exchange}}:{{ticker}} {{interval}} Cross-Exchange Sweep: LOCAL WICK sweep")

// ---------- table ----------
tblPos = switch tblPosIn
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

var table tb = table.new(tblPos, 5, 13, bgcolor = cPANEL, frame_color = cBORDER, frame_width = 1, border_width = 0)
if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 0, 4, 0)
    for r = 1 to 6
        table.merge_cells(tb, 3, r, 4, r)
    table.merge_cells(tb, 0, 11, 4, 11)
    table.merge_cells(tb, 0, 12, 4, 12)

f_cell(int col, int row, string t, color tc, bool num, color bg) =>
    table.cell(tb, col, row, t, text_color = tc, bgcolor = bg, text_size = size.small, text_halign = num ? text.align_right : text.align_left, text_font_family = num ? font.family_monospace : font.family_default)

if barstate.islast and showTbl
    bool fresh = not na(lastBar) and bar_index - lastBar <= 1
    color rowBg = fresh ? cFRESH : cPANEL
    int total = array.sum(cnt)
    table.cell(tb, 0, 0, "Cross-Exchange Sweep [Zen] · " + f_tf(), text_color = cHEADTX, bgcolor = cHEAD, text_size = size.small)
    bool noRef = array.sum(alig) == 0
    f_cell(0, 1, "Last", fresh ? cINK : cMUTED, false, rowBg)
    f_cell(1, 1, na(lastT) ? "—" : str.format_time(lastT, "MM-dd HH:mm", "UTC"), cINK, false, rowBg)
    f_cell(2, 1, lastSide, cINK, false, rowBg)
    f_cell(3, 1, noRef ? "no reference data" : lastCls < 0 ? "—" : f_cname(lastCls), noRef ? cMUTED : cINK, false, rowBg)
    f_cell(0, 2, "Exchange", cMUTED, false, cPANEL)
    f_cell(1, 2, "Pool", cMUTED, true, cPANEL)
    f_cell(2, 2, "Wick", cMUTED, true, cPANEL)
    f_cell(3, 2, "Result", cMUTED, false, cPANEL)
    for i = 0 to 3
        string nm = i == 0 ? pref + " (chart)" : i == 1 ? ex1 : i == 2 ? ex2 : ex3
        int st = array.get(lastSt, i)
        f_cell(0, 3 + i, nm, cINK, false, cPANEL)
        f_cell(1, 3 + i, lastCls < 0 ? "—" : f_px(array.get(lastPool, i)), cINK, true, cPANEL)
        f_cell(2, 3 + i, lastCls < 0 ? "—" : f_px(array.get(lastWick, i)), cINK, true, cPANEL)
        f_cell(3, 3 + i, lastCls < 0 ? "—" : f_sq(st) + " " + f_nm(st), st >= 1 ? cINK : cMUTED, false, cPANEL)
    // outcome of each class after the sweep
    string rule = "Reversal = price reached " + str.tostring(tgtAtr) + " ATR from the sweep close, away from the swept level, before trading beyond the sweep wick, within " + str.tostring(outN) + " bars. Stop = beyond the wick first (a bar that does both counts as Stop). None = neither within the window."
    rule += " Percentages use resolved sweeps only; pending and n/a sweeps are excluded. High and low sweeps on the same bar count separately."
    array<string> hd = array.from("Outcome", "Resolved", "Reversal", "Stop", "None")
    for c = 0 to 4
        table.cell(tb, c, 7, array.get(hd, c), text_color = cMUTED, bgcolor = cPANEL, text_size = size.small, text_halign = c == 0 ? text.align_left : text.align_right, tooltip = rule)
    for k = 0 to 2
        int w = array.get(wins, k)
        int sp = array.get(stops, k)
        int e = array.get(exps, k)
        int tot = w + sp + e
        f_cell(0, 8 + k, f_cname(k), cINK, false, cPANEL)
        f_cell(1, 8 + k, str.tostring(tot), cINK, true, cPANEL)
        f_cell(2, 8 + k, f_rate(w, tot), cINK, true, cPANEL)
        f_cell(3, 8 + k, f_rate(sp, tot), cINK, true, cPANEL)
        f_cell(4, 8 + k, f_rate(e, tot), cINK, true, cPANEL)
    string hist = "History: WIDE " + str.tostring(array.get(cnt, 0)) + " · SPLIT " + str.tostring(array.get(cnt, 1)) + " · LOCAL " + str.tostring(array.get(cnt, 2)) + " · n/a " + str.tostring(array.get(cnt, 3)) + " · of " + str.tostring(total)
    table.cell(tb, 0, 11, hist, text_color = cMUTED, bgcolor = cPANEL, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 0, 12, "■ took  □ did not  – no data", text_color = cMUTED, bgcolor = cPANEL, text_size = size.tiny, text_halign = text.align_left)
````
