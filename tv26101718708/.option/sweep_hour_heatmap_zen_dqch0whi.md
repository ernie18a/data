# Sweep Hour Heatmap [Zen]

- url: https://www.tradingview.com/script/dQcH0whI-Sweep-Hour-Heatmap-Zen/
- type: indicator
- pine_id: PUB;25625fbb513b46a1aacab5a904268584
- version: 1.0

## Description

Sweep Hour Heatmap [Zen] counts liquidity sweeps by the hour of the week in which they happened and shows how often the sweeps of each hour were followed by a reversal. Every sweep of a basket of up to 20 crypto perpetuals (or of the chart coin alone) is placed in one of 168 cells, weekday x UTC hour, by the open time of the sweep candle. 6 candles later the script compares the close with the close of the sweep candle: lower after a high sweep, or higher after a low sweep, counts as a reversal. A 7 x 24 table shows the number of sweeps in every cell and fills in orange the cells whose reversal share is at least 5 points above the share of all sweeps together, so you can see in which hours, on this exchange and history, sweeps were most often followed by a reversal.

The script works on the 1H chart only. All numbers below are default settings and can be changed in Inputs.

WHAT IS DIFFERENT HERE
Pool and sweep detection and basket requests are the same building blocks as in my other open-source scripts; what this script does with the sweeps is its own:
- every sweep goes into a weekday x hour cell, and the cell keeps the number of sweeps and the number of reversals after them;
- the reversal is defined on the sweep candle's own close, a fixed number of candles later, the same way for every coin and every cell;
- the fill of a cell is relative: it shows how far the cell's reversal share is above the share of all counted sweeps, in four steps, and a cell with too few sweeps is never filled;
- the alert fires when the chart coin sweeps a pool in an hour whose cell is above the average by a set margin.
It is not a version of Session Sweep Map [Zen], which draws the highs and lows of the Asia, London and New York sessions on one coin and records which session swept whose level: there are no session levels and no lines here. Liquidity Sweep Breadth [Zen] measures how many basket coins swept on one candle, in a lower pane: this script has no lower pane and no per-candle count. Sweep Lead Lag [Zen] groups sweeps into waves and records the chart coin's role; Sweep Volume Shock [Zen] classifies sweeps by the volume of the sweep candle. None of them has a weekday x hour axis, and this script has no session levels, waves or volume classes. Unlike typical time-of-day statistics of returns per hour, the unit here is a sweep and the measure is what happened after it.

HOW IT WORKS
- Timeframe: 1H only. On any other timeframe the table shows "Use the 1H chart" and nothing is counted.
- Basket: BTC, ETH, SOL, XRP, BNB, DOGE, ADA, LINK, AVAX, LTC, SUI, NEAR, AAVE, ONDO, DOT, TRX, BCH, UNI, APT, ARB (comma separated, no trailing comma; only the first 20 are used). Each coin is requested as the chart's exchange + coin + USDT.P on 1H, for example BITGET:ETHUSDT.P. A coin that has no such symbol on the chart's exchange is left out; a coin that has no candle at the time of the chart candle is not counted on that candle. With "Count sweeps of" set to Chart coin, only the chart's own sweeps are counted; the basket is still requested, so loading takes the same time.
- Pool of a coin: the highest high and the lowest low of its previous 20 closed candles. A coin with fewer than 20 candles of history has no pool yet.
- Sweep: a closed candle whose wick goes beyond the pool and whose close comes back to or inside it (high above the high pool with a close at or below it; low below the low pool with a close at or above it). A candle that sweeps both pools counts as two sweeps, one per side.
- Cell: the weekday and the UTC hour of the open time of the sweep candle, 7 days x 24 hours = 168 cells. Monday 00:00 UTC is the first cell, Sunday 23:00 UTC the last.
- Reversal: 6 closed candles after the sweep candle, the close of the same coin is compared with the close of the sweep candle. After a high sweep the sweep is a reversal if the later close is lower; after a low sweep, if it is higher. An equal close is not a reversal. A sweep is added to its cell only when this check is done, so the sweeps of the last 6 candles are not in the table yet. If the coin has no candle at the moment of the check, the sweep is dropped and counted nowhere.
- History: only sweeps within the last 2000 candles of the chart are counted (see Realtime behaviour).
- Average share: the number of reversals divided by the number of counted sweeps, over all cells together. It is the share of all sweeps, not the mean of the 168 cells, so cells with many sweeps weigh more.
- Edge of a cell: the cell's reversal share minus the average share, in percentage points. A cell with fewer than 15 sweeps has no edge: it is shown in grey and is never filled or starred.

WHAT YOU SEE
- Table (top right by default): 7 rows Mon to Sun, 24 columns 00 to 23 UTC. Header: the number of coins with data out of the basket (or the chart symbol in Chart coin mode), the time zone, the reversal horizon and the minimum sweeps per cell.
- Cell: the number of sweeps, or "-" when there are none. No fill when the edge is below +5 points or the cell has fewer than 15 sweeps. Four steps of orange for an edge of at least +5, +10, +20 and +30 points; the last step has inverted text. The cell with the highest edge among the cells with at least 15 sweeps has a star after its number. Tooltip: weekday and hour, sweeps and reversal share; the edge only for cells with at least 15 sweeps.
- Legend row: the average share and the four fill steps.
- Bottom line: counted sweeps, average reversal share, the top cell with its share and count, the history length, and a note that these are historical data, not a forecast.
- Nothing is drawn on the candles.

ALERTS
Evaluated on the close of every 1H candle. The alert() message already fires once per bar close; for the alert condition choose the frequency "Once per bar close".
- "Any alert() function call": one message when the chart coin sweeps a pool (high or low) in an hour whose cell has at least 15 sweeps and an edge of at least +10 points over the average, for example "Sweep in a hot hour: BTCUSDT.P 60 | 03:00 UTC | 14/15 reversals".
- One alert condition, "Sweep in a hot hour", with the message "Sweep in a hot hour on <ticker> <interval>".
- Use one of the two ways; if you create both, you get two messages for the same event.
- The alert reports the chart coin's sweep and the cell's statistics as they stand at that moment. It does not say that this sweep will reverse.

HOW TO READ IT
- A filled cell says that, on the loaded history of this exchange, sweeps in that hour were followed by a reversal more often than sweeps in general. The darker the fill, the larger the difference.
- With 168 cells, some look hot by chance alone: with a few dozen sweeps per cell the reversal share of one cell moves by about 20 percentage points from chance, and with no real hour effect the top cell typically sits about 25 points above the average while some 30 cells reach the first fill step. Sweeps of different coins on the same candle are not independent, so the real sample is smaller than the number shown. Treat a filled cell or the star as a place to look, to be checked on more history, other exchanges or other coins, not as a rule.
- Chart coin mode has about one sweep per cell over 2000 candles; with the default minimum expect nearly every cell to be grey.
- This is context for your own analysis, not an entry signal.

INPUTS (defaults; all inputs are hidden from the status line)
- Pool length (candles): 20
- Reversal check (candles): 6
- History (candles): 2000
- Count sweeps of: Basket
- Basket coins (max 20): the list above
- Min sweeps for a cell to count: 15
- Hot hour: edge over average (pp): 10
- Table position: Top right

REALTIME BEHAVIOUR AND LIMITS
- The history window is set when the chart loads: it is counted back from the last candle at that moment. While the chart stays open new sweeps are added and old ones are not removed, so the window grows until the next reload.
- On the closing tick of a chart candle the other coins' candles may not have their final values yet, or may not be matched in time, and such a coin is not counted on that candle. After a reload the window moves to the new last candle, so the counts, the average share, the fills, the starred cell and the hot status of a cell can change; an alert that fired live may not match the reloaded table. The chart coin's own sweep is final on a closed candle.
- The table counts the loaded history only, so its numbers depend on how many candles your plan loads; with fewer than 2000 candles loaded the window is shorter than the setting.
- The basket is requested from the chart's exchange. On an exchange without USDT perpetuals the header shows 0/20 coins and the table has no counts. On a spot chart the chart coin's sweeps are spot while the basket is read from the perpetuals.
- Up to 20 coins are read on every candle; the first load can take a few seconds.
- Built for standard candles. Heikin Ashi, Renko and other synthetic charts change the prices the script reads.
- Colours follow the chart background (light or dark).

Not financial advice.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
indicator("Sweep Hour Heatmap [Zen]", overlay = true)

// ---------- Inputs ----------
gP = "Pool & sweep"
poolLen = input.int(20, "Pool length (candles)", minval = 5, group = gP, display = display.none, tooltip = "Pool = highest high / lowest low of the previous N closed 1H candles of each coin. Sweep = wick beyond the pool and close back inside, on a closed candle.")
horizon = input.int(6, "Reversal check (candles)", minval = 1, maxval = 48, group = gP, display = display.none, tooltip = "A sweep is a reversal if, this many candles after the sweep candle, the close is on the far side of the sweep candle's close: below it after a high sweep, above it after a low sweep.")
histLen = input.int(2000, "History (candles)", minval = 168, maxval = 5000, group = gP, display = display.none, tooltip = "Only sweeps within this many candles from the last candle are counted.")

gB = "Source"
srcMode   = input.string("Basket", "Count sweeps of", options = ["Chart coin", "Basket"], group = gB, display = display.none)
basketStr = input.string("BTC,ETH,SOL,XRP,BNB,DOGE,ADA,LINK,AVAX,LTC,SUI,NEAR,AAVE,ONDO,DOT,TRX,BCH,UNI,APT,ARB", "Basket coins (max 20)", group = gB, display = display.none, tooltip = "Comma separated, no trailing comma. Each coin is requested as chart exchange + coin + USDT.P on 1H. A coin with no data on the exchange is left out.")

gA = "Hot hours"
minN    = input.int(15, "Min sweeps for a cell to count", minval = 1, group = gA, display = display.none, tooltip = "Cells with fewer sweeps are shown in grey and never filled.")
hotEdge = input.int(10, "Hot hour: edge over average (pp)", minval = 1, maxval = 50, group = gA, display = display.none, tooltip = "A cell is a hot hour when its reversal share is at least this many percentage points above the overall reversal share of all counted sweeps. Used for the alert.")

gV = "Display"
tblPosIn = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = gV, display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI    = isLight ? #AD4A12 : #D9703A
color cMUTED = isLight ? #647482 : #8391A4
color cTXT   = isLight ? #131722 : #D1D4DC
color cINK   = isLight ? #FFFFFF : #131722
color cBG    = isLight ? color.new(#FFFFFF, 8) : color.new(#131722, 8)
color cHEAD  = isLight ? color.new(#647482, 80) : color.new(#8391A4, 75)

tblPos = tblPosIn == "Top right" ? position.top_right : tblPosIn == "Bottom right" ? position.bottom_right : tblPosIn == "Bottom left" ? position.bottom_left : position.top_left

bool is1H = timeframe.in_seconds() == 3600

// ---------- Per-coin sweep (runs in each coin's own context) ----------
f_sweep(int len) =>
    float hh = ta.highest(high, len)[1]
    float ll = ta.lowest(low, len)[1]
    bool ok = bar_index >= len
    int sh = (ok and high > hh and close <= hh) ? 1 : 0
    int sl = (ok and low < ll and close >= ll) ? 1 : 0
    [sh, sl, close, time]

// ---------- State: 168 cells (day 0..6 x hour 0..23) ----------
var int[] cnt = array.new_int(168, 0)
var int[] rev = array.new_int(168, 0)
var int[] pBar  = array.new_int()
var int[] pCell = array.new_int()
var int[] pSide = array.new_int()
var float[] pPx = array.new_float()
var int[] pCoin = array.new_int()
var int okCntC = 0
var table tbl = na

string[] coinsRaw = str.split(basketStr, ",")
int n = math.min(coinsRaw.size(), 20)
f_name(int idx) => str.upper(str.trim(coinsRaw.get(idx)))

// ---------- Requests: every bar, unconditional ----------
int[]   swH = array.new_int(20, 0)
int[]   swL = array.new_int(20, 0)
float[] cl  = array.new_float(20, na)
int okCnt = 0
for i = 0 to n - 1
    string sym = syminfo.prefix + ":" + f_name(i) + "USDT.P"
    [a, b, c, t] = request.security(sym, timeframe.period, f_sweep(poolLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    bool valid = not na(t) and t == time
    swH.set(i, (valid and a == 1) ? 1 : 0)
    swL.set(i, (valid and b == 1) ? 1 : 0)
    cl.set(i, valid ? c : na)
    okCnt += valid ? 1 : 0
if barstate.isconfirmed
    okCntC := okCnt

[oSH, oSL, oC, oT] = f_sweep(poolLen)

// ---------- Cell of this candle (UTC) ----------
int dow  = dayofweek(time, "UTC")
int hr   = hour(time, "UTC")
int dIdx = dow == 1 ? 6 : dow - 2
int cell = dIdx * 24 + hr

bool useBasket = srcMode == "Basket"
bool chartSweepNow = false

if barstate.isconfirmed and is1H
    int k = pBar.size() - 1
    while k >= 0
        int age = bar_index - pBar.get(k)
        if age >= horizon
            int ci = pCoin.get(k)
            float nowC = ci < 0 ? close : cl.get(ci)
            if not na(nowC)
                bool r = pSide.get(k) == 1 ? nowC < pPx.get(k) : nowC > pPx.get(k)
                int cc = pCell.get(k)
                cnt.set(cc, cnt.get(cc) + 1)
                if r
                    rev.set(cc, rev.get(cc) + 1)
            pBar.remove(k)
            pCell.remove(k)
            pSide.remove(k)
            pPx.remove(k)
            pCoin.remove(k)
        k -= 1
    bool inHist = bar_index >= last_bar_index - histLen
    if inHist
        if useBasket
            for i = 0 to n - 1
                if swH.get(i) == 1
                    pBar.push(bar_index), pCell.push(cell), pSide.push(1), pPx.push(cl.get(i)), pCoin.push(i)
                if swL.get(i) == 1
                    pBar.push(bar_index), pCell.push(cell), pSide.push(2), pPx.push(cl.get(i)), pCoin.push(i)
        else
            if oSH == 1
                pBar.push(bar_index), pCell.push(cell), pSide.push(1), pPx.push(close), pCoin.push(-1)
            if oSL == 1
                pBar.push(bar_index), pCell.push(cell), pSide.push(2), pPx.push(close), pCoin.push(-1)
    chartSweepNow := oSH == 1 or oSL == 1

// ---------- Average share and edge of a cell ----------
f_avg() =>
    int t = 0
    int r = 0
    for c = 0 to 167
        t += cnt.get(c)
        r += rev.get(c)
    t == 0 ? 50.0 : 100.0 * r / t

f_edge(int c, float avg) =>
    int k = cnt.get(c)
    k < minN ? -999.0 : 100.0 * rev.get(c) / k - avg

float avgShare = f_avg()
bool cellHot = is1H and f_edge(cell, avgShare) >= hotEdge

// ---------- Alert: chart coin sweeps in a hot hour ----------
bool hotNow = barstate.isconfirmed and chartSweepNow and cellHot
if hotNow
    alert("Sweep in a hot hour: " + syminfo.ticker + " 60 | " + str.tostring(hr, "00") + ":00 UTC | " + str.tostring(rev.get(cell)) + "/" + str.tostring(cnt.get(cell)) + " reversals", alert.freq_once_per_bar_close)
alertcondition(hotNow, "Sweep in a hot hour", "Sweep in a hot hour on {{ticker}} {{interval}}")

// ---------- Table ----------
f_fill(float e) =>
    e >= 30 ? 20 : e >= 20 ? 45 : e >= 10 ? 65 : e >= 5 ? 82 : -1

if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    string[] days = array.from("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
    tbl := table.new(tblPos, 25, 12, bgcolor = na, border_width = 1, border_color = na, frame_width = 0)
    table.cell(tbl, 0, 0, "", text_size = size.small)
    table.merge_cells(tbl, 0, 0, 24, 0)
    string head = "SWEEP HOUR HEATMAP · " + (useBasket ? str.tostring(okCntC) + "/" + str.tostring(n) + " coins" : syminfo.ticker) + " · UTC · reversal after " + str.tostring(horizon) + "h · n<" + str.tostring(minN) + " not filled"
    table.cell(tbl, 0, 1, head, text_color = cTXT, text_size = size.small, text_halign = text.align_left, bgcolor = cHEAD)
    table.merge_cells(tbl, 0, 1, 24, 1)
    if not is1H
        table.cell(tbl, 0, 2, "Use the 1H chart", text_color = cHI, text_size = size.small, text_halign = text.align_left, bgcolor = cBG)
        table.merge_cells(tbl, 0, 2, 24, 2)
    else
        table.cell(tbl, 0, 2, "", text_size = size.tiny, bgcolor = cBG)
        for h = 0 to 23
            table.cell(tbl, h + 1, 2, str.tostring(h, "00"), text_color = cMUTED, text_size = size.tiny, text_halign = text.align_center, bgcolor = cBG)
        int total = 0
        int bestCell = -1
        float bestEdge = -999.0
        for c = 0 to 167
            float e0 = f_edge(c, avgShare)
            if e0 > bestEdge
                bestEdge := e0
                bestCell := c
        for d = 0 to 6
            table.cell(tbl, 0, d + 3, days.get(d), text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left, bgcolor = cBG)
            for h = 0 to 23
                int c = d * 24 + h
                int k = cnt.get(c)
                int r = rev.get(c)
                total += k
                float e = f_edge(c, avgShare)
                int tr = f_fill(e)
                bool isBest = c == bestCell and bestEdge > -999.0
                color bg = tr < 0 ? cBG : color.new(cHI, tr)
                color tc = k == 0 or k < minN ? cMUTED : tr == 20 ? cINK : cTXT
                string txt = k == 0 ? "-" : str.tostring(k) + (isBest ? "*" : "")
                string tip = days.get(d) + " " + str.tostring(h, "00") + ":00 UTC\n" + str.tostring(k) + " sweeps" + (k == 0 ? "" : " · " + str.tostring(100.0 * r / k, "0") + "% reversed" + (k < minN ? " (n<" + str.tostring(minN) + ")" : " · " + (e >= 0 ? "+" : "") + str.tostring(e, "0") + " pp vs average"))
                table.cell(tbl, h + 1, d + 3, txt, text_color = tc, text_size = size.small, text_halign = text.align_center, bgcolor = bg, tooltip = tip)
        table.cell(tbl, 0, 10, "fill = reversal share vs average (" + str.tostring(avgShare, "0") + "%)", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left, bgcolor = cBG)
        table.merge_cells(tbl, 0, 10, 16, 10)
        table.cell(tbl, 17, 10, "+5", text_color = cTXT, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(cHI, 82))
        table.merge_cells(tbl, 17, 10, 18, 10)
        table.cell(tbl, 19, 10, "+10", text_color = cTXT, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(cHI, 65))
        table.merge_cells(tbl, 19, 10, 20, 10)
        table.cell(tbl, 21, 10, "+20", text_color = cTXT, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(cHI, 45))
        table.merge_cells(tbl, 21, 10, 22, 10)
        table.cell(tbl, 23, 10, "+30 pp", text_color = cINK, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(cHI, 20))
        table.merge_cells(tbl, 23, 10, 24, 10)
        string best = bestCell < 0 ? "no cell with " + str.tostring(minN) + "+ sweeps" : "top cell (*) " + days.get(bestCell / 24) + " " + str.tostring(bestCell % 24, "00") + ":00 UTC (" + str.tostring(100.0 * rev.get(bestCell) / cnt.get(bestCell), "0") + "% of " + str.tostring(cnt.get(bestCell)) + ")"
        table.cell(tbl, 0, 11, str.tostring(total) + " sweeps · " + (total == 0 ? "-" : str.tostring(avgShare, "0") + "%") + " reversed on average · " + best + " · last " + str.tostring(histLen) + " candles · historical data, not a forecast", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left, bgcolor = cBG)
        table.merge_cells(tbl, 0, 11, 24, 11)
````
