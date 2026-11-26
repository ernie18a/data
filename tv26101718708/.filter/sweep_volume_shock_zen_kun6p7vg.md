# Sweep Volume Shock [Zen]

- url: https://www.tradingview.com/script/KuN6p7VG-Sweep-Volume-Shock-Zen/
- type: indicator
- pine_id: PUB;3e744cea00244544a6a475e8e5dc956f
- version: 1.0

## Description

Sweep Volume Shock [Zen] marks liquidity sweeps and shows how much volume each sweep carried: the volume of the sweep candle is divided by the coin's own average volume over the previous 20 closed candles. A sweep on at least 2.0 x the average is SHOCK, a sweep on at most 0.7 x is QUIET, anything in between is NORMAL. The same check runs on a basket of up to 20 crypto perpetuals, and a table shows the most recent sweeps in the basket with their volume multiples, so you can see at once which coins just took a pool on heavy volume and which did it on nothing.

All numbers below are default settings and can be changed in Inputs.

WHAT IS DIFFERENT HERE
Sweep detection, relative volume and basket requests are common building blocks. This script links them coin by coin:
- every sweep is classified by the volume of the sweep candle itself, measured against that coin's own recent volume, not against a fixed number and not against other coins;
- the classification runs on all coins of the basket on every closed candle, and the table lists the most recent sweeps with their side, age, volume multiple and class;
- on the chart coin a SHOCK sweep gets a label whose text is the volume multiple; NORMAL and QUIET sweeps get a small mark, and the tooltip of every mark shows the multiple.
It is not a version of my open-source Liquidity Sweep Breadth [Zen], which measures how many basket coins swept on one candle and draws that share in a lower pane. This script has no lower pane and does not measure breadth; the only basket count here is the number of SHOCK sweeps on the last closed candle, shown in the bottom line of the table and used for the basket alert. It is not a version of Sweep OI Flush [Zen] either: that one works from open interest and keeps outcome statistics; nothing here reads open interest and no outcomes are tracked.

HOW IT WORKS
- Basket: BTC, ETH, SOL, XRP, BNB, DOGE, ADA, LINK, AVAX, LTC, SUI, NEAR, AAVE, ONDO, DOT, TRX, BCH, UNI, APT, ARB (comma separated, no trailing comma; only the first 20 entries are used). Each coin is requested as the chart's exchange + coin + USDT.P on the chart's timeframe, for example BITGET:ETHUSDT.P. A coin that has no such symbol on the chart's exchange is left out; a coin that has no candle at the time of the chart candle is not counted on that candle.
- Pool of a coin: the highest high and the lowest low of its previous 20 closed candles. A coin with fewer than 20 candles of history has no pool and no average yet.
- Sweep: a closed candle whose wick goes beyond the pool and whose close comes back to or inside it (high above the high pool with a close at or below it; low below the low pool with a close at or above it). A candle that sweeps both pools is one sweep with side BSL+SSL; its mark is placed at the high.
- Volume multiple: the volume of the sweep candle divided by the simple average volume of the previous 20 closed candles of the same coin. The sweep candle is not part of its own average. If the average is zero or missing, the multiple is n/a.
- Class: SHOCK when the multiple is at least 2.0; QUIET when it is at most 0.7; NORMAL in between; n/a when the multiple is n/a.
- The chart coin is checked from the candles of the chart itself, the basket coins from their own candles. Every decision is taken on closed candles only.

WHAT YOU SEE
- Marks on the chart coin only. SHOCK: a label with the multiple, for example "x2.4", orange above the high for a BSL sweep, blue below the low for an SSL sweep. NORMAL: a small triangle in the same colours, no text, shown by default. QUIET: a small grey dot, hidden by default. The tooltip of every mark shows the side, the exact multiple and the class. A mark is placed on the sweep candle when it closes and does not move afterwards.
- Table (top right by default). Header: timeframe and lookback. One row per listed coin, the most recent sweep first: Coin, Side (BSL, SSL or BSL+SSL), Ago (closed candles since the sweep, 0 = the last closed candle), Vol x (the multiple) and Class. A coin is listed only if its last sweep happened within the last 48 candles, and at most 10 coins are shown; when more coins qualify, the bottom line says how many swept and how many are shown. The row of a coin that swept on the last closed candle is highlighted. If no coin swept within the lookback, the table has no rows and the bottom line says so.
- Bottom line: how many listed coins are hidden by the row limit (if any), the number of basket coins with a SHOCK sweep on the last closed candle, the number of coins with data out of the basket, and a note that these are historical data, not a forecast.

ALERTS
Every alert is evaluated on the close of a candle; create alerts with the frequency "Once per bar close".
- "Any alert() function call": one message per candle with a SHOCK sweep on the chart coin ("SHOCK sweep: BTCUSDT.P 240 | SSL | x2.4 volume") and/or with at least 3 basket coins on SHOCK on the same candle ("Basket SHOCK sweeps: 5 of 20 coins | BTCUSDT.P 240 | ETH x3.1, SOL x2.6"); if both happen on one candle the message has two lines.
- Two alert conditions: "SHOCK sweep on chart" and "Basket SHOCK sweeps", with the messages "SHOCK sweep on <ticker> <interval>" and "Basket SHOCK sweeps on <ticker> <interval>".
- Use one of the two ways; if you create both, you get two messages for the same event.

HOW TO READ IT
- A SHOCK mark means the pool was taken on heavy trading for this coin; a QUIET sweep means it was taken on almost nothing. The multiple compares a coin with itself: x2.0 on a thin coin and x2.0 on BTC both mean "twice its own average".
- The table tells you where the heavy sweeps in the basket are right now and how old they are; the bottom line tells you whether the last candle was a basket-wide event or a single coin.
- This is context for your own analysis, not an entry signal.

INPUTS (defaults; all inputs are hidden from the status line)
- Pool length (candles): 20
- Volume average (candles): 20
- SHOCK threshold (x average): 2.0
- QUIET threshold (x average): 0.7
- Basket coins (max 20): the list above
- Table lookback (candles): 48
- Table rows (max 20): 10
- Alert: min SHOCK coins on one candle: 3
- Show NORMAL sweep marks: on
- Show QUIET sweep marks: off
- Table position: Top right

REALTIME BEHAVIOUR AND LIMITS
- On the closing tick of a chart candle the other coins' candles may not have their final volume yet, or may not be matched in time, and such a coin is not counted on that candle. The live multiple and class of a basket coin can therefore differ from the values the script gets when it recalculates the history, and after a chart reload the table, the bottom line and the alerts that would have fired can change. The chart coin's own volume is final on a closed candle.
- Up to 200 labels in total, so only the most recent sweeps of the chart coin are marked. The table always shows the current state of the basket.
- The basket is requested from the chart's exchange. On an exchange without USDT perpetuals the bottom line shows 0/20 coins and the table has no rows. On a spot chart the chart coin's sweeps and volume are spot while the basket is read from the perpetuals.
- Exchanges report volume in different units (base coin, quote currency, contracts); the multiple is a ratio within one coin, so the class does not depend on the unit, and raw volume is never shown.
- Up to 20 coins are read on every candle; loading can be slow on very small timeframes with long history.
- Built for standard candles. Heikin Ashi, Renko and other synthetic charts change the prices the script reads.
- Colours follow the chart background (light or dark).

Not financial advice.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
indicator("Sweep Volume Shock [Zen]", overlay = true, max_labels_count = 200)

// ---------- Inputs ----------
gP = "Pool & sweep"
poolLen = input.int(20, "Pool length (candles)", minval = 5, group = gP, display = display.none, tooltip = "Pool = highest high / lowest low of the previous N closed candles of each coin. Sweep = wick beyond the pool and close back inside, on a closed candle.")
volLen  = input.int(20, "Volume average (candles)", minval = 5, group = gP, display = display.none, tooltip = "The sweep candle's volume is divided by the average volume of the previous N closed candles of the same coin.")
shockX  = input.float(2.0, "SHOCK threshold (x average)", minval = 1.0, step = 0.1, group = gP, display = display.none, tooltip = "A sweep is SHOCK when its volume is at least this many times the average.")
quietX  = input.float(0.7, "QUIET threshold (x average)", minval = 0.1, maxval = 1.0, step = 0.1, group = gP, display = display.none, tooltip = "A sweep is QUIET when its volume is at most this many times the average. Everything in between is NORMAL.")

gB = "Basket"
basketStr = input.string("BTC,ETH,SOL,XRP,BNB,DOGE,ADA,LINK,AVAX,LTC,SUI,NEAR,AAVE,ONDO,DOT,TRX,BCH,UNI,APT,ARB", "Basket coins (max 20)", group = gB, display = display.none, tooltip = "Comma separated, no trailing comma. Each coin is requested as chart exchange + coin + USDT.P, for example BITGET:ETHUSDT.P, on the chart timeframe. A coin with no data on the exchange is left out.")
lookback  = input.int(48, "Table lookback (candles)", minval = 1, maxval = 500, group = gB, display = display.none, tooltip = "A coin is listed only if its last sweep happened within this many candles.")
maxRows   = input.int(10, "Table rows (max 20)", minval = 1, maxval = 20, group = gB, display = display.none, tooltip = "The table shows at most this many coins, the most recent sweeps first.")
alertMin  = input.int(3, "Alert: min SHOCK coins on one candle", minval = 1, maxval = 20, group = gB, display = display.none)

gV = "Display"
showNormal = input.bool(true, "Show NORMAL sweep marks", group = gV, display = display.none)
showQuiet  = input.bool(false, "Show QUIET sweep marks", group = gV, display = display.none)
tblPosIn   = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = gV, display = display.none)

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI    = isLight ? #AD4A12 : #D9703A
color cLO    = isLight ? #1B46B4 : #6F88EE
color cMUTED = isLight ? #505C69 : #9AA3B2
color cTXT   = isLight ? #131722 : #D1D4DC
color cINK   = isLight ? #FFFFFF : #131722
color cBG    = isLight ? color.new(#FFFFFF, 8) : color.new(#131722, 8)
color cHEAD  = isLight ? color.new(#647482, 80) : color.new(#8391A4, 75)
color cFRESH = color.new(#C98B78, 60)

tblPos = tblPosIn == "Top right" ? position.top_right : tblPosIn == "Bottom right" ? position.bottom_right : tblPosIn == "Bottom left" ? position.bottom_left : position.top_left

// ---------- Per-coin sweep + volume ratio (runs in each coin's own context) ----------
f_sv(int len, int vlen) =>
    float hh  = ta.highest(high, len)[1]
    float ll  = ta.lowest(low, len)[1]
    float avg = ta.sma(volume, vlen)[1]
    bool ok = bar_index >= math.max(len, vlen)
    int sh = (ok and high > hh and close <= hh) ? 1 : 0
    int sl = (ok and low < ll and close >= ll) ? 1 : 0
    float r = (ok and not na(avg) and avg > 0) ? volume / avg : na
    [sh, sl, r, time]

f_cls(float r) =>
    na(r) ? -1 : r >= shockX ? 2 : r <= quietX ? 0 : 1

f_clsTxt(int c) =>
    c == 2 ? "SHOCK" : c == 1 ? "NORMAL" : c == 0 ? "QUIET" : "n/a"

// ---------- State ----------
var int[]   lastSide = array.new_int(20, 0)
var int[]   lastBar  = array.new_int(20, -1)
var float[] lastR    = array.new_float(20, na)
var int lastShock = 0
var table tbl = na

string[] coinsRaw = str.split(basketStr, ",")
int n = math.min(coinsRaw.size(), 20)

f_name(int idx) => str.upper(str.trim(coinsRaw.get(idx)))

// ---------- Requests: every bar, unconditional ----------
int[]   swH = array.new_int(20, 0)
int[]   swL = array.new_int(20, 0)
float[] rt  = array.new_float(20, na)
int okCnt = 0
for i = 0 to n - 1
    string sym = syminfo.prefix + ":" + f_name(i) + "USDT.P"
    [a, b, r, t] = request.security(sym, timeframe.period, f_sv(poolLen, volLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    bool valid = not na(t) and t == time
    swH.set(i, (valid and a == 1) ? 1 : 0)
    swL.set(i, (valid and b == 1) ? 1 : 0)
    rt.set(i, valid ? r : na)
    okCnt += valid ? 1 : 0

// ---------- Chart symbol ----------
[oSH, oSL, oR, oT] = f_sv(poolLen, volLen)

// ---------- Closed candles only ----------
int shockNow = 0
string shockList = ""
bool chartShock = false
string chartMsg = ""

if barstate.isconfirmed
    for i = 0 to n - 1
        bool sw = swH.get(i) == 1 or swL.get(i) == 1
        if sw
            float r = rt.get(i)
            lastSide.set(i, swH.get(i) == 1 and swL.get(i) == 1 ? 3 : swH.get(i) == 1 ? 1 : 2)
            lastBar.set(i, bar_index)
            lastR.set(i, r)
            if f_cls(r) == 2
                shockNow += 1
                shockList += (shockList == "" ? "" : ", ") + f_name(i) + " x" + str.tostring(r, "0.0")
    lastShock := shockNow
    if oSH == 1 or oSL == 1
        int c = f_cls(oR)
        bool isHi = oSH == 1
        string side = oSH == 1 and oSL == 1 ? "BSL+SSL" : oSH == 1 ? "BSL" : "SSL"
        string tip = side + " sweep\nvolume x" + str.tostring(oR, "0.00") + " vs " + str.tostring(volLen) + "-candle average\n" + f_clsTxt(c)
        if c == 2
            chartShock := true
            chartMsg := "SHOCK sweep: " + syminfo.ticker + " " + timeframe.period + " | " + side + " | x" + str.tostring(oR, "0.0") + " volume"
            label.new(bar_index, isHi ? high : low, "x" + str.tostring(oR, "0.0"), style = isHi ? label.style_label_down : label.style_label_up, color = isHi ? cHI : cLO, textcolor = cINK, size = size.small, tooltip = tip)
        else if c == 1 and showNormal
            label.new(bar_index, isHi ? high : low, "", style = isHi ? label.style_triangledown : label.style_triangleup, color = isHi ? cHI : cLO, size = size.tiny, tooltip = tip)
        else if c == 0 and showQuiet
            label.new(bar_index, isHi ? high : low, "", style = label.style_circle, color = cMUTED, size = size.tiny, tooltip = tip)

// ---------- Alerts ----------
bool basketAlert = barstate.isconfirmed and shockNow >= alertMin
if barstate.isconfirmed and (chartShock or basketAlert)
    string m = (chartShock ? chartMsg : "") + (chartShock and basketAlert ? "\n" : "") + (basketAlert ? "Basket SHOCK sweeps: " + str.tostring(shockNow) + " of " + str.tostring(okCnt) + " coins | " + syminfo.ticker + " " + timeframe.period + " | " + shockList : "")
    alert(m, alert.freq_once_per_bar_close)
alertcondition(chartShock, "SHOCK sweep on chart", "SHOCK sweep on {{ticker}} {{interval}}")
alertcondition(basketAlert, "Basket SHOCK sweeps", "Basket SHOCK sweeps on {{ticker}} {{interval}}")

// ---------- Table: most recent sweeps in the basket ----------
if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    int ref = barstate.isconfirmed ? bar_index : bar_index - 1
    int[] ord = array.new_int()
    for i = 0 to n - 1
        int ago0 = lastBar.get(i) >= 0 ? ref - lastBar.get(i) : -1
        if ago0 >= 0 and ago0 <= lookback
            ord.push(i)
    int m = ord.size()
    if m >= 2
        for a = 0 to m - 2
            int best = a
            for b = a + 1 to m - 1
                if lastBar.get(ord.get(b)) > lastBar.get(ord.get(best))
                    best := b
            if best != a
                int tmp = ord.get(a)
                ord.set(a, ord.get(best))
                ord.set(best, tmp)
    int rows = math.min(m, maxRows)
    tbl := table.new(tblPos, 5, rows + 3, bgcolor = cBG, border_width = 0, frame_width = 0)
    table.cell(tbl, 0, 0, "SWEEP VOLUME SHOCK · " + timeframe.period + " · last " + str.tostring(lookback) + " candles", text_color = cTXT, text_size = size.small, text_halign = text.align_left, bgcolor = cHEAD)
    table.merge_cells(tbl, 0, 0, 4, 0)
    table.cell(tbl, 0, 1, "Coin", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 1, "Side", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 2, 1, "Ago", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 3, 1, "Vol x", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
    table.cell(tbl, 4, 1, "Class", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_right)
    if rows > 0
        for k = 0 to rows - 1
            int i = ord.get(k)
            int row = k + 2
            int ago = ref - lastBar.get(i)
            int sd = lastSide.get(i)
            float r = lastR.get(i)
            int c = f_cls(r)
            color sideCol = sd == 1 ? cHI : sd == 2 ? cLO : cTXT
            color rowBg = ago == 0 ? cFRESH : na
            table.cell(tbl, 0, row, f_name(i), text_color = cTXT, text_size = size.small, text_halign = text.align_left, bgcolor = rowBg)
            table.cell(tbl, 1, row, sd == 1 ? "BSL" : sd == 2 ? "SSL" : "BSL+SSL", text_color = sideCol, text_size = size.small, text_halign = text.align_right, bgcolor = rowBg)
            table.cell(tbl, 2, row, str.tostring(ago), text_color = cTXT, text_size = size.small, text_halign = text.align_right, bgcolor = rowBg)
            table.cell(tbl, 3, row, na(r) ? "n/a" : "x" + str.tostring(r, "0.0"), text_color = cTXT, text_size = size.small, text_halign = text.align_right, bgcolor = rowBg)
            table.cell(tbl, 4, row, f_clsTxt(c), text_color = c == 2 ? sideCol : cMUTED, text_size = size.small, text_halign = text.align_right, bgcolor = rowBg)
    table.cell(tbl, 0, rows + 2, (m == 0 ? "No sweeps in the last " + str.tostring(lookback) + " candles | " : (m > rows ? str.tostring(m) + " coins swept, " + str.tostring(rows) + " shown | " : "")) + "Last closed candle: " + str.tostring(lastShock) + " SHOCK sweeps | " + str.tostring(okCnt) + "/" + str.tostring(n) + " coins · historical data, not a forecast", text_color = cMUTED, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(tbl, 0, rows + 2, 4, rows + 2)
````
