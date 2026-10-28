# Sweep Lead Lag [Zen]

- url: https://www.tradingview.com/script/MrPrTcn8-Sweep-Lead-Lag-Zen/
- type: indicator
- pine_id: PUB;c7c63d6e784c401ab22a5f48e6310d70
- version: 1.0

## Description

Sweep Lead Lag [Zen] watches a basket of up to 20 crypto perpetuals and groups their liquidity sweeps into waves: a wave starts on the first closed candle on which any basket coin sweeps its pool and collects every coin that sweeps within a window of 6 candles counted from that first candle. For each wave the script records the role of the chart's own coin (Led, Joined or Absent) and what the chart's close did 12 candles after the wave ended, so you can check on the loaded history of this chart how price behaved after such waves.

All numbers below are default settings and can be changed in Inputs.

WHAT IS ORIGINAL AND WHY A SEPARATE PUBLICATION
A per-candle breadth count, such as my open-source Liquidity Sweep Breadth [Zen], shows in a lower pane how many coins swept on one candle. This script does something else with the same raw event:
- it joins sweeps that happen on different candles into one wave, with a fixed window counted from the first sweep;
- it records the order inside the wave: which coins swept on the first candle and how many candles later the others followed (the tooltip of every mark lists them);
- it classifies each wave by the role of the chart coin (Led, Joined, Absent) and keeps, for each role, a record of what the chart's price did after the wave;
- it shows the wave while it is still forming, with the number of coins so far and the position inside the window.
Pools, sweeps and basket requests are standard building blocks; the wave, the role and the outcome record per role are what this publication adds. It draws on the price chart, has no per-candle breadth series and no lower pane. It is a separate script, not an update of the breadth count, because the two answer different questions and share no logic beyond sweep detection.

HOW IT WORKS
- Basket: BTC, ETH, SOL, XRP, BNB, DOGE, ADA, LINK, AVAX, LTC, SUI, NEAR, AAVE, ONDO, DOT, TRX, BCH, UNI, APT, ARB. Each coin is requested as the chart's exchange + coin + USDT.P on the chart's timeframe, for example BITGET:ETHUSDT.P. A coin that has no such symbol on the chart's exchange is left out; a coin that has no candle at the time of the chart candle is not counted on that candle.
- Pool of a coin: the highest high and the lowest low of its previous 20 closed candles. A coin with fewer than 20 candles of history has no pool yet.
- Sweep: a closed candle whose wick goes beyond the pool and whose close comes back to or inside it (high above the high pool with a close at or below it; low below the low pool with a close at or above it).
- Wave: starts on the first closed candle on which any basket coin sweeps; the window is 6 candles, the first one included, and it always runs its full length. A coin belongs to the wave if it sweeps inside the window; each coin is counted once, on its first sweep. The wave is kept only if at least 5 coins swept inside the window; otherwise it is dropped and leaves no mark, no table entry and no alert. High-sweep waves (BSL, buy-side liquidity) and low-sweep waves (SSL, sell-side liquidity) are tracked separately and can run at the same time.
- Windows do not overlap: the next wave on the same side can start only on the candle after the window ends. A cluster of sweeps that straddles the end of a window is therefore split: its first sweeps go to that window, the rest can only open a new wave after it ends.
- Role of the chart coin: Led = the chart coin swept on the first candle of the wave (other coins may have swept on that candle too, so Led is order in time, not cause); Joined = it swept later inside the window; Absent = it did not sweep inside the window. The chart coin's own sweep is read from the candles of the chart itself. On a perpetual chart of a basket coin the chart coin is also part of the basket, so its sweep can open a wave. If the chart coin is not in the basket, its sweep cannot open a wave: a sweep before the first basket sweep is not counted, and the role stays Absent unless the coin sweeps again inside the window.
- Outcome: 12 candles after the last candle of the window, the close is compared with the close of that last candle. For a BSL wave the outcome is Fell when the later close is lower; for an SSL wave it is Rose when the later close is higher. An equal close is neither. A wave enters the table only once its outcome is known, so waves from the last 12 candles are still pending.

WHAT YOU SEE
- Marks: when a window ends and the wave is kept, a triangle is placed on the FIRST candle of the wave, 5 candles back from the candle that just closed (window length minus one). So the newest mark is always 5 candles behind the last closed candle, and a mark never appears on the open candle; once placed, it does not move. Orange triangle above the high for a BSL wave, blue triangle below the low for an SSL wave. Size: small for fewer than 10 coins, larger from 10 coins. The tooltip shows the count against the coins with data on that candle, for example "BSL 12/20", and every coin with its delay in candles from the first candle of the wave (+0 = swept on the first candle).
- Live label: while a window is open, a label on the last candle shows the side, the coins so far out of the coins with data, and the number of the current candle inside the window, the open candle included, for example "BSL 5/20" and "5/6". Coins are counted on closed candles only. If both sides are open, the label shows the side with more coins (BSL when equal); the table's bottom line lists both. The label is shown for every open window, including windows that will end with fewer than 5 coins and be dropped, and it disappears when the window ends.
- Table (top right by default), header: timeframe and the outcome horizon. One row per role of the chart coin: BSL n (number of BSL waves with that role), Fell (share of them after which the close was lower), SSL n and Rose (the same for SSL waves).
- Any candle: the baseline row, what price did after an arbitrary candle. Over all closed candles on which at least one basket coin had data, the share of candles whose close was lower (Fell column) and the share whose close was higher (Rose column) than the close 12 candles earlier. Compare each role's percentage with this row.
- Bottom line: open windows, if any ("BSL live 5" with the position inside the window), the number of waves in the loaded history (including waves whose outcome is still pending), the number of coins with data out of the basket on the last candle, and the note that these are historical statistics, not a forecast.

ALERTS
All alerts fire at candle close, at the END of the window, that is 5 candles after the first sweep, and only for waves with at least 10 coins. They use the live count (see Realtime behaviour).
- "Any alert() function call": one message per candle, for example "High-sweep wave: 12 of 20 coins | BTCUSDT.P 240"; if both sides end on the same candle the message has two lines.
- Two alert conditions, "High-sweep wave ended" and "Low-sweep wave ended", with the message "High-sweep wave ended on <ticker> <interval>" (same for low).
- Use one way or the other; if you create both, you get two messages for the same wave.

HOW TO READ IT
- A mark tells you that at least 5 coins took the same side of their pools within 6 candles; the tooltip tells you who went first.
- The table tells you how often, on this chart and timeframe, the close was lower 12 candles after a BSL wave or higher after an SSL wave, split by whether this coin led, joined or stayed out. Read it against the Any candle row.
- The counts are small and the outcome windows of neighbouring waves overlap, so the waves are not independent samples. With about 150 waves in a table row the 95% margin of a share near 50% is roughly 8 percentage points either way, so a difference of a few points from the baseline does not show anything by itself.
- This is context for your own analysis, not an entry signal.

INPUTS (defaults; all inputs are hidden from the status line)
- Pool length (candles): 20
- Wave window (candles): 6
- Min coins in a wave: 5
- Outcome horizon (candles): 12
- Alert: min coins in a wave: 10
- Basket coins (max 20): the list above, comma separated
- Show wave marks: on
- Table position: Top right

REALTIME BEHAVIOUR AND LIMITS
- Every decision is taken on closed candles. On the closing tick of a chart candle the other coins' candles may not have their final values yet, or may not be matched in time, and such a coin is not counted on that candle. The live count of a wave can therefore differ from the count the script gets when it recalculates the history, and after a chart reload the newest marks, their size, the alerts that would have fired and the table can change.
- Marks on the chart: up to 200 labels in total, the live label included, so only the most recent waves are marked. The table counts every wave in the loaded history, so its numbers depend on the timeframe and on how many candles your plan loads.
- The basket is requested from the chart's exchange. On an exchange without USDT perpetuals the bottom line shows 0/20 coins and no waves are found. On a spot chart the basket is still read from the perpetuals while the chart coin's own role comes from the spot candles.
- Up to 20 coins are read on every candle; loading can be slow on very small timeframes with long history.
- Built for standard candles. Heikin Ashi, Renko and other synthetic charts change the prices the script reads.
- Colours switch automatically with the chart background (light or dark).

Not financial advice.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
indicator("Sweep Lead Lag [Zen]", overlay = true, max_labels_count = 200)

// ---------- Inputs ----------
gP = "Pool & wave"
poolLen  = input.int(20, "Pool length (candles)", minval = 5, group = gP, display = display.none, tooltip = "Pool = highest high / lowest low of the previous N closed candles of each coin. Sweep = wick beyond the pool and close back inside, on a closed candle.")
winBars  = input.int(6, "Wave window (candles)", minval = 2, maxval = 20, group = gP, display = display.none, tooltip = "A wave starts on the first closed candle on which any basket coin sweeps a pool. Coins that sweep within this many candles (the first candle included) belong to the wave.")
minCoins = input.int(5, "Min coins in a wave", minval = 2, maxval = 20, group = gP, display = display.none, tooltip = "A wave is counted only if at least this many coins swept inside the window.")
horizon  = input.int(12, "Outcome horizon (candles)", minval = 3, maxval = 100, group = gP, display = display.none, tooltip = "The table compares the close at the end of a wave with the close this many candles later.")

alertMin = input.int(10, "Alert: min coins in a wave", minval = 2, maxval = 20, group = gP, display = display.none, tooltip = "Alerts fire only for waves with at least this many coins.")

gB = "Basket"
basketStr = input.string("BTC,ETH,SOL,XRP,BNB,DOGE,ADA,LINK,AVAX,LTC,SUI,NEAR,AAVE,ONDO,DOT,TRX,BCH,UNI,APT,ARB", "Basket coins (max 20)", group = gB, display = display.none, tooltip = "Comma separated. Each coin is requested as chart exchange + coin + USDT.P, for example BITGET:ETHUSDT.P, on the chart timeframe. A coin with no data on the exchange is left out.")

gV = "Display"
showDots   = input.bool(true, "Show wave marks", group = gV, display = display.none)
tblPosIn   = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = gV, display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI    = isLight ? #AD4A12 : #D9703A
color cLO    = isLight ? #1B46B4 : #6F88EE
color cMUTED = isLight ? #505C69 : #9AA3B2
color cTXT   = isLight ? #131722 : #D1D4DC
color cBG    = isLight ? color.new(#FFFFFF, 8) : color.new(#131722, 8)
color cHEAD  = isLight ? color.new(#647482, 80) : color.new(#8391A4, 75)

tblPos = tblPosIn == "Top right" ? position.top_right : tblPosIn == "Bottom right" ? position.bottom_right : tblPosIn == "Bottom left" ? position.bottom_left : position.top_left
max_bars_back(high, 20)
max_bars_back(low, 20)

// ---------- Per-coin sweep detection (runs in each coin's own context) ----------
f_sweep(int len) =>
    float hh = ta.highest(high, len)[1]
    float ll = ta.lowest(low, len)[1]
    bool ok = bar_index >= len
    int sh = (ok and high > hh and close <= hh) ? 1 : 0
    int sl = (ok and low < ll and close >= ll) ? 1 : 0
    [sh, sl, time]

// ---------- Wave state machine (one per side) ----------
f_wave(int[] sw, int[] lag, int[] st, int win, int minC) =>
    bool ended = false
    bool qual = false
    int cnt = 0
    int sb = -1
    int start = st.get(0)
    if start == -1 and sw.sum() > 0
        start := bar_index
        st.set(0, start)
        lag.fill(-1)
    if start != -1
        for i = 0 to 19
            if sw.get(i) == 1 and lag.get(i) == -1
                lag.set(i, bar_index - start)
        if bar_index - start >= win - 1
            ended := true
            sb := start
            for i = 0 to 19
                if lag.get(i) >= 0
                    cnt += 1
            qual := cnt >= minC
            st.set(0, -1)
    [ended, qual, cnt, sb]

f_count(int[] lag) =>
    int c = 0
    for i = 0 to 19
        if lag.get(i) >= 0
            c += 1
    c

f_pct(int a, int b) =>
    b == 0 ? "-" : str.tostring(100.0 * a / b, "#") + "%"

// ---------- State ----------
var int[] lagH = array.new_int(20, -1)
var int[] lagL = array.new_int(20, -1)
var int[] stH  = array.from(-1)
var int[] stL  = array.from(-1)
var int waves = 0
var int baseN = 0
var int baseDn = 0
var int baseUp = 0
var int[] pBar = array.new_int()
var int[] pSide = array.new_int()
var int[] pBkt = array.new_int()
var float[] pPx = array.new_float()
var int[] totN = array.new_int(6, 0)
var int[] revN = array.new_int(6, 0)
var table tbl = na
var label liveLbl = na
var int ownH = -1
var int ownL = -1

string[] coinsRaw = str.split(basketStr, ",")
int n = math.min(coinsRaw.size(), 20)

f_name(int idx) => str.upper(str.trim(coinsRaw.get(idx)))

f_tip(int[] lag) =>
    string s = ""
    for i = 0 to n - 1
        int l = lag.get(i)
        if l >= 0
            s += f_name(i) + " +" + str.tostring(l) + "\n"
    s

// ---------- Requests: every bar, unconditional ----------
int[] swH = array.new_int(20, 0)
int[] swL = array.new_int(20, 0)
int okCnt = 0
for i = 0 to n - 1
    string sym = syminfo.prefix + ":" + f_name(i) + "USDT.P"
    [a, b, t] = request.security(sym, timeframe.period, f_sweep(poolLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    bool valid = not na(t) and t == time
    swH.set(i, (valid and a == 1) ? 1 : 0)
    swL.set(i, (valid and b == 1) ? 1 : 0)
    okCnt += valid ? 1 : 0

// ---------- Waves and outcomes: closed candles only ----------
float closeAgo = close[horizon]
[oSH, oSL, oT] = f_sweep(poolLen)
bool bigH = false
bool bigL = false
string msgH = ""
string msgL = ""

if barstate.isconfirmed
    // outcomes of earlier waves
    if bar_index >= horizon and okCnt > 0
        baseN += 1
        baseDn += close < closeAgo ? 1 : 0
        baseUp += close > closeAgo ? 1 : 0
    int k = pBar.size() - 1
    while k >= 0
        if bar_index - pBar.get(k) >= horizon
            int ix = pSide.get(k) * 3 + pBkt.get(k)
            totN.set(ix, totN.get(ix) + 1)
            bool rev = pSide.get(k) == 0 ? close < pPx.get(k) : close > pPx.get(k)
            if rev
                revN.set(ix, revN.get(ix) + 1)
            pBar.remove(k)
            pSide.remove(k)
            pBkt.remove(k)
            pPx.remove(k)
        k -= 1

    bool startH = stH.get(0) == -1 and swH.sum() > 0
    bool startL = stL.get(0) == -1 and swL.sum() > 0
    if startH
        ownH := -1
    if startL
        ownL := -1
    int sIdxH = startH ? bar_index : stH.get(0)
    int sIdxL = startL ? bar_index : stL.get(0)
    if sIdxH != -1 and oSH == 1 and ownH == -1
        ownH := bar_index - sIdxH
    if sIdxL != -1 and oSL == 1 and ownL == -1
        ownL := bar_index - sIdxL
    [eH, qH, cH, sH] = f_wave(swH, lagH, stH, winBars, minCoins)
    if eH and qH
        waves += 1
        bigH := cH >= alertMin
        pBar.push(bar_index)
        pSide.push(0)
        pBkt.push(ownH == -1 ? 2 : ownH == 0 ? 0 : 1)
        pPx.push(close)
        msgH := "High-sweep wave: " + str.tostring(cH) + " of " + str.tostring(okCnt) + " coins | " + syminfo.ticker + " " + timeframe.period
        if showDots
            int offH = bar_index - sH
            label.new(sH, high[offH], "", style = label.style_triangledown, color = cHI, size = cH < 10 ? size.tiny : size.small, tooltip = "BSL " + str.tostring(cH) + "/" + str.tostring(okCnt) + "\n" + f_tip(lagH))
    [eL, qL, cL, sL] = f_wave(swL, lagL, stL, winBars, minCoins)
    if eL and qL
        waves += 1
        bigL := cL >= alertMin
        pBar.push(bar_index)
        pSide.push(1)
        pBkt.push(ownL == -1 ? 2 : ownL == 0 ? 0 : 1)
        pPx.push(close)
        msgL := "Low-sweep wave: " + str.tostring(cL) + " of " + str.tostring(okCnt) + " coins | " + syminfo.ticker + " " + timeframe.period
        if showDots
            int offL = bar_index - sL
            label.new(sL, low[offL], "", style = label.style_triangleup, color = cLO, size = cL < 10 ? size.tiny : size.small, tooltip = "SSL " + str.tostring(cL) + "/" + str.tostring(okCnt) + "\n" + f_tip(lagL))

// ---------- Alerts ----------
if barstate.isconfirmed and (bigH or bigL)
    alert((bigH ? msgH : "") + (bigH and bigL ? "\n" : "") + (bigL ? msgL : ""), alert.freq_once_per_bar_close)
alertcondition(bigH, "High-sweep wave ended", "High-sweep wave ended on {{ticker}} {{interval}}")
alertcondition(bigL, "Low-sweep wave ended", "Low-sweep wave ended on {{ticker}} {{interval}}")

// ---------- Live label at the last candle ----------
if barstate.islast
    if not na(liveLbl)
        label.delete(liveLbl)
        liveLbl := na
    int cLiveH = stH.get(0) != -1 ? f_count(lagH) : 0
    int cLiveL = stL.get(0) != -1 ? f_count(lagL) : 0
    if cLiveH > 0 or cLiveL > 0
        bool useH = cLiveH >= cLiveL
        int cc = useH ? cLiveH : cLiveL
        int stt = useH ? stH.get(0) : stL.get(0)
        liveLbl := label.new(bar_index, useH ? high : low, (useH ? "BSL " : "SSL ") + str.tostring(cc) + "/" + str.tostring(okCnt) + " · " + str.tostring(bar_index - stt + 1) + "/" + str.tostring(winBars), style = useH ? label.style_label_down : label.style_label_up, color = useH ? cHI : cLO, textcolor = isLight ? #FFFFFF : #131722, size = size.small)

// ---------- Table: what price did after a wave ----------
if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(tblPos, 5, 7, bgcolor = cBG, border_width = 0, frame_width = 0)
    table.cell(tbl, 0, 0, "SWEEP LEAD LAG · " + timeframe.period + " · " + str.tostring(horizon) + " candles after wave end", text_color = cTXT, text_size = size.small, text_halign = text.align_left, bgcolor = cHEAD)
    table.merge_cells(tbl, 0, 0, 4, 0)
    table.cell(tbl, 0, 1, "Chart coin", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 1, "BSL n", text_color = cHI, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 2, 1, "Fell", text_color = cHI, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 3, 1, "SSL n", text_color = cLO, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 4, 1, "Rose", text_color = cLO, text_size = size.tiny, text_halign = text.align_right)
    string[] names = array.from("Led", "Joined", "Absent")
    for r = 0 to 2
        table.cell(tbl, 0, r + 2, names.get(r), text_color = cTXT, text_size = size.small, text_halign = text.align_left)
        table.cell(tbl, 1, r + 2, str.tostring(totN.get(r)), text_color = cMUTED, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 2, r + 2, f_pct(revN.get(r), totN.get(r)), text_color = cHI, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 3, r + 2, str.tostring(totN.get(3 + r)), text_color = cMUTED, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 4, r + 2, f_pct(revN.get(3 + r), totN.get(3 + r)), text_color = cLO, text_size = size.small, text_halign = text.align_right)
    table.cell(tbl, 0, 5, "Any candle", text_color = cMUTED, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 5, str.tostring(baseN), text_color = cMUTED, text_size = size.small, text_halign = text.align_right)
    table.cell(tbl, 2, 5, f_pct(baseDn, baseN), text_color = cMUTED, text_size = size.small, text_halign = text.align_right)
    table.cell(tbl, 3, 5, "", text_color = cMUTED, text_size = size.small)
    table.cell(tbl, 4, 5, f_pct(baseUp, baseN), text_color = cMUTED, text_size = size.small, text_halign = text.align_right)
    string live = ""
    if stH.get(0) != -1
        live += "BSL live " + str.tostring(f_count(lagH)) + " · " + str.tostring(bar_index - stH.get(0) + 1) + "/" + str.tostring(winBars) + "\n"
    if stL.get(0) != -1
        live += "SSL live " + str.tostring(f_count(lagL)) + " · " + str.tostring(bar_index - stL.get(0) + 1) + "/" + str.tostring(winBars) + "\n"
    table.cell(tbl, 0, 6, live + str.tostring(waves) + " waves · " + str.tostring(okCnt) + "/" + str.tostring(n) + " coins · historical stats, not a forecast", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 6, 4, 6)
````
