# Multi-Symbol Trend Matrix

- url: https://www.tradingview.com/script/Swwq52tJ-Multi-Symbol-Trend-Matrix/
- type: indicator
- pine_id: PUB;6a73d58a652a419cbee6c79e8d9be761
- version: 1.0

## Description

Multi-Symbol Trend Matrix shows the trend of up to 8 symbols across 4 timeframes in one table, so you can see at a glance what is trending, what is weak, and whether the overall market is risk-on or risk-off.

How it works:
Each symbol and timeframe is classified with the same rules as MTF Trend Dashboard:
- Bullish (▲): price above the fast EMA, fast EMA above the slow EMA, and RSI above 50
- Bearish (▼): price below the fast EMA, fast EMA below the slow EMA, and RSI below 50
- Neutral (•): anything else

Table:
- Score from -4 to +4 for each symbol (sum of all timeframes)
- Rows are sorted by score, strongest first (can be turned off)
- Daily % change for each symbol
- The current chart symbol is marked with ▶
- Market row: overall bias across all enabled symbols (risk-on, risk-off or mixed)

On the chart:
- Fast / slow EMA cloud colored by the current trend of the chart symbol

Alerts:
- A symbol becomes bullish or bearish on all 4 timeframes (checked on bar close)

Settings:
- Choose any 8 symbols (stocks, crypto, forex, futures, commodities) and enable or disable each one
- Change the 4 timeframes, EMA lengths and RSI length
- Table position, text size and colors

Default symbols: SPY, QQQ, IWM, BTCUSDT, ETHUSDT, XAUUSD, EURUSD, USOIL.

Note: values on higher timeframes update in real time and can change until the bar closes. This is a trend-analysis tool, not financial advice or a trading signal.

## Source Code

````pine
//@version=6
indicator("Multi-Symbol Trend Matrix", shorttitle = "Trend Matrix", overlay = true)

// =====================================================
// INPUTS
// =====================================================
G_SYM = "Symbols"
G_TF  = "Timeframes"
G_TR  = "Trend logic"
G_DSP = "Display"

use1 = input.bool(true, "1", inline = "s1", group = G_SYM)
sym1 = input.symbol("AMEX:SPY",        "Symbol 1", inline = "s1", group = G_SYM)
use2 = input.bool(true, "2", inline = "s2", group = G_SYM)
sym2 = input.symbol("NASDAQ:QQQ",      "Symbol 2", inline = "s2", group = G_SYM)
use3 = input.bool(true, "3", inline = "s3", group = G_SYM)
sym3 = input.symbol("AMEX:IWM",        "Symbol 3", inline = "s3", group = G_SYM)
use4 = input.bool(true, "4", inline = "s4", group = G_SYM)
sym4 = input.symbol("BINANCE:BTCUSDT", "Symbol 4", inline = "s4", group = G_SYM)
use5 = input.bool(true, "5", inline = "s5", group = G_SYM)
sym5 = input.symbol("BINANCE:ETHUSDT", "Symbol 5", inline = "s5", group = G_SYM)
use6 = input.bool(true, "6", inline = "s6", group = G_SYM)
sym6 = input.symbol("OANDA:XAUUSD",    "Symbol 6", inline = "s6", group = G_SYM)
use7 = input.bool(true, "7", inline = "s7", group = G_SYM)
sym7 = input.symbol("FX:EURUSD",       "Symbol 7", inline = "s7", group = G_SYM)
use8 = input.bool(true, "8", inline = "s8", group = G_SYM)
sym8 = input.symbol("TVC:USOIL",       "Symbol 8", inline = "s8", group = G_SYM)

tf1 = input.timeframe("15",  "Timeframe 1", group = G_TF)
tf2 = input.timeframe("60",  "Timeframe 2", group = G_TF)
tf3 = input.timeframe("240", "Timeframe 3", group = G_TF)
tf4 = input.timeframe("D",   "Timeframe 4", group = G_TF)

fastLen = input.int(20, "Fast EMA", minval = 1, group = G_TR)
slowLen = input.int(50, "Slow EMA", minval = 1, group = G_TR)
rsiLen  = input.int(14, "RSI length", minval = 1, group = G_TR)

sortRows  = input.bool(true, "Sort by score (strongest first)", group = G_DSP)
showChg   = input.bool(true, "Show daily % change", group = G_DSP)
showCloud = input.bool(true, "EMA cloud on chart", group = G_DSP)
tablePos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_DSP)
tableSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = G_DSP)
cBull = input.color(color.teal, "Bullish", inline = "c", group = G_DSP)
cBear = input.color(color.red,  "Bearish", inline = "c", group = G_DSP)

// =====================================================
// TREND LOGIC (same rules as MTF Trend Dashboard)
//  1 = price > fast EMA > slow EMA and RSI > 50
// -1 = price < fast EMA < slow EMA and RSI < 50
//  0 = neutral
// =====================================================
f_trend() =>
    f = ta.ema(close, fastLen)
    s = ta.ema(close, slowLen)
    r = ta.rsi(close, rsiLen)
    int st = close > f and f > s and r > 50 ? 1 : close < f and f < s and r < 50 ? -1 : 0
    float chg = (close - close[1]) / close[1] * 100
    [st, chg]

// 4 requests per symbol -> 32 in total
f_sym(string sym) =>
    [a1, c1] = request.security(sym, tf1, f_trend(), ignore_invalid_symbol = true)
    [a2, c2] = request.security(sym, tf2, f_trend(), ignore_invalid_symbol = true)
    [a3, c3] = request.security(sym, tf3, f_trend(), ignore_invalid_symbol = true)
    [a4, c4] = request.security(sym, tf4, f_trend(), ignore_invalid_symbol = true)
    [a1, a2, a3, a4, c4]

[t11, t12, t13, t14, ch1] = f_sym(sym1)
[t21, t22, t23, t24, ch2] = f_sym(sym2)
[t31, t32, t33, t34, ch3] = f_sym(sym3)
[t41, t42, t43, t44, ch4] = f_sym(sym4)
[t51, t52, t53, t54, ch5] = f_sym(sym5)
[t61, t62, t63, t64, ch6] = f_sym(sym6)
[t71, t72, t73, t74, ch7] = f_sym(sym7)
[t81, t82, t83, t84, ch8] = f_sym(sym8)

// =====================================================
// CHART EMA CLOUD (current symbol)
// =====================================================
fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
[stNow, _chg] = f_trend()
trendCol = stNow == 1 ? cBull : stNow == -1 ? cBear : color.gray
p1 = plot(showCloud ? fastEma : na, "Fast EMA", trendCol, 2)
p2 = plot(showCloud ? slowEma : na, "Slow EMA", color.new(trendCol, 40), 1)
fill(p1, p2, showCloud ? color.new(trendCol, 85) : na, title = "EMA cloud")

// =====================================================
// HELPERS
// =====================================================
f_name(string sym) =>
    parts = str.split(sym, ":")
    parts.size() > 0 ? parts.last() : sym

f_tfName(string tf) =>
    sec = timeframe.in_seconds(tf)
    sec < 3600 ? str.tostring(math.round(sec / 60)) + "m" : sec < 86400 ? str.tostring(math.round(sec / 3600)) + "H" : sec < 604800 ? "D" : sec < 2592000 ? "W" : "M"

f_cellTxt(int st) =>
    na(st) ? "-" : st == 1 ? "▲" : st == -1 ? "▼" : "•"

f_cellCol(int st) =>
    na(st) ? color.new(color.gray, 80) : st == 1 ? color.new(cBull, 25) : st == -1 ? color.new(cBear, 25) : color.new(color.gray, 60)

f_scoreCol(int sc) =>
    sc >= 3 ? color.new(cBull, 10) : sc >= 1 ? color.new(cBull, 50) : sc <= -3 ? color.new(cBear, 10) : sc <= -1 ? color.new(cBear, 50) : color.new(color.gray, 55)

f_use(int i) =>
    switch i
        0 => use1
        1 => use2
        2 => use3
        3 => use4
        4 => use5
        5 => use6
        6 => use7
        => use8

f_scoreTxt(int sc) =>
    (sc > 0 ? "+" : "") + str.tostring(sc)

// =====================================================
// TABLE
// =====================================================
tPos = switch tablePos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.top_right

tSize = switch tableSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table mtx = table.new(tPos, 7, 10, bgcolor = color.new(#0b1220, 5), border_color = color.new(color.gray, 75), border_width = 1)

// =====================================================
// SCORES + RANKING (no bool arrays, no dynamic loops)
// =====================================================
sc1 = nz(t11) + nz(t12) + nz(t13) + nz(t14)
sc2 = nz(t21) + nz(t22) + nz(t23) + nz(t24)
sc3 = nz(t31) + nz(t32) + nz(t33) + nz(t34)
sc4 = nz(t41) + nz(t42) + nz(t43) + nz(t44)
sc5 = nz(t51) + nz(t52) + nz(t53) + nz(t54)
sc6 = nz(t61) + nz(t62) + nz(t63) + nz(t64)
sc7 = nz(t71) + nz(t72) + nz(t73) + nz(t74)
sc8 = nz(t81) + nz(t82) + nz(t83) + nz(t84)

e1 = use1 ? 1 : 0
e2 = use2 ? 1 : 0
e3 = use3 ? 1 : 0
e4 = use4 ? 1 : 0
e5 = use5 ? 1 : 0
e6 = use6 ? 1 : 0
e7 = use7 ? 1 : 0
e8 = use8 ? 1 : 0
nEnabled = e1 + e2 + e3 + e4 + e5 + e6 + e7 + e8

// 1 if symbol j (score scj, index j, enabled ej) should be above symbol i
f_above(int ej, int scj, int j, int sci, int i) =>
    ej == 1 and j != i and (sortRows ? (scj > sci or (scj == sci and j < i)) : j < i) ? 1 : 0

f_pos(int sci, int i) =>
    f_above(e1, sc1, 1, sci, i) + f_above(e2, sc2, 2, sci, i) + f_above(e3, sc3, 3, sci, i) + f_above(e4, sc4, 4, sci, i) + f_above(e5, sc5, 5, sci, i) + f_above(e6, sc6, 6, sci, i) + f_above(e7, sc7, 7, sci, i) + f_above(e8, sc8, 8, sci, i) + 1

f_drawRow(int row, string sym, int a, int b, int c, int d, int sc, float chg) =>
    string nm = (sym == syminfo.tickerid ? "▶ " : "") + f_name(sym)
    table.cell(mtx, 0, row, nm, text_color = color.white, text_size = tSize, text_halign = text.align_left)
    table.cell(mtx, 1, row, f_cellTxt(a), bgcolor = f_cellCol(a), text_color = color.white, text_size = tSize)
    table.cell(mtx, 2, row, f_cellTxt(b), bgcolor = f_cellCol(b), text_color = color.white, text_size = tSize)
    table.cell(mtx, 3, row, f_cellTxt(c), bgcolor = f_cellCol(c), text_color = color.white, text_size = tSize)
    table.cell(mtx, 4, row, f_cellTxt(d), bgcolor = f_cellCol(d), text_color = color.white, text_size = tSize)
    table.cell(mtx, 5, row, f_scoreTxt(sc), bgcolor = f_scoreCol(sc), text_color = color.white, text_size = tSize)
    if showChg
        string ct = na(chg) ? "-" : (chg > 0 ? "+" : "") + str.tostring(chg, "#.##") + "%"
        table.cell(mtx, 6, row, ct, text_color = na(chg) ? color.gray : chg >= 0 ? cBull : cBear, text_size = tSize)
    row

// Alerts when a symbol becomes fully aligned on all timeframes (checked on bar close)
f_alignAlert(bool use, string sym, int sc) =>
    if use and barstate.isconfirmed and sc != sc[1]
        if sc == 4
            alert(f_name(sym) + ": bullish on all timeframes", alert.freq_once_per_bar_close)
        if sc == -4
            alert(f_name(sym) + ": bearish on all timeframes", alert.freq_once_per_bar_close)
    sc

f_alignAlert(use1, sym1, sc1)
f_alignAlert(use2, sym2, sc2)
f_alignAlert(use3, sym3, sc3)
f_alignAlert(use4, sym4, sc4)
f_alignAlert(use5, sym5, sc5)
f_alignAlert(use6, sym6, sc6)
f_alignAlert(use7, sym7, sc7)
f_alignAlert(use8, sym8, sc8)

if barstate.islast
    table.clear(mtx, 0, 0, 6, 9)

    // Header
    table.cell(mtx, 0, 0, "Symbol", text_color = color.silver, text_size = tSize)
    table.cell(mtx, 1, 0, f_tfName(tf1), text_color = color.silver, text_size = tSize)
    table.cell(mtx, 2, 0, f_tfName(tf2), text_color = color.silver, text_size = tSize)
    table.cell(mtx, 3, 0, f_tfName(tf3), text_color = color.silver, text_size = tSize)
    table.cell(mtx, 4, 0, f_tfName(tf4), text_color = color.silver, text_size = tSize)
    table.cell(mtx, 5, 0, "Score", text_color = color.silver, text_size = tSize)
    if showChg
        table.cell(mtx, 6, 0, "Day %", text_color = color.silver, text_size = tSize)

    // Rows
    if use1
        f_drawRow(f_pos(sc1, 1), sym1, t11, t12, t13, t14, sc1, ch1)
    if use2
        f_drawRow(f_pos(sc2, 2), sym2, t21, t22, t23, t24, sc2, ch2)
    if use3
        f_drawRow(f_pos(sc3, 3), sym3, t31, t32, t33, t34, sc3, ch3)
    if use4
        f_drawRow(f_pos(sc4, 4), sym4, t41, t42, t43, t44, sc4, ch4)
    if use5
        f_drawRow(f_pos(sc5, 5), sym5, t51, t52, t53, t54, sc5, ch5)
    if use6
        f_drawRow(f_pos(sc6, 6), sym6, t61, t62, t63, t64, sc6, ch6)
    if use7
        f_drawRow(f_pos(sc7, 7), sym7, t71, t72, t73, t74, sc7, ch7)
    if use8
        f_drawRow(f_pos(sc8, 8), sym8, t81, t82, t83, t84, sc8, ch8)

    // Footer: overall market bias
    int total = e1 * sc1 + e2 * sc2 + e3 * sc3 + e4 * sc4 + e5 * sc5 + e6 * sc6 + e7 * sc7 + e8 * sc8
    int maxTotal = nEnabled * 4
    string bias = maxTotal == 0 ? "No symbols enabled (check settings)" : total >= maxTotal * 0.4 ? "Risk-on / bullish" : total <= -maxTotal * 0.4 ? "Risk-off / bearish" : "Mixed"
    color biasCol = bias == "Risk-on / bullish" ? color.new(cBull, 20) : bias == "Risk-off / bearish" ? color.new(cBear, 20) : color.new(color.gray, 50)
    int footRow = nEnabled + 1
    table.cell(mtx, 0, footRow, "Market: " + bias + "  (" + str.tostring(total) + " / " + str.tostring(maxTotal) + ")", bgcolor = biasCol, text_color = color.white, text_size = tSize)
    table.merge_cells(mtx, 0, footRow, showChg ? 6 : 5, footRow)
````
