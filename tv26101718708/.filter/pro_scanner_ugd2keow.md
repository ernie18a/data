# Pro Scanner 

- url: https://www.tradingview.com/script/Ugd2KEoW-Pro-Scanner/
- type: indicator
- pine_id: PUB;b183e7551da7428c9809e6bd848a665e
- version: 1.0

## Description

Multi-Symbol Trend & Momentum Scanner

OVERVIEW
This indicator scans up to 15 user-defined symbols and presents them in a
single color-coded dashboard on your chart. Instead of flipping between charts,
you get a consolidated view of price, change, trend bias, RSI and a combined
signal for every symbol in your watchlist.

HOW IT WORKS
For each symbol, the script requests data on a timeframe you choose and computes:
- LTP: the latest close.
- Chg%: percentage change vs the previous bar of the selected timeframe
  (set the Scanner Timeframe to "D" for daily change).
- Trend: bullish (up) when price is above its EMA, bearish (down) when below.
  EMA length is adjustable.
- RSI: standard Relative Strength Index with adjustable length; cells are shaded
  for overbought (above 70) and oversold (below 30).
- Signal: a combined read from trend direction and RSI — BUY when trend is up
  and RSI is firm, SELL when trend is down and RSI is weak, neutral otherwise.
The table can be sorted by percentage change so the strongest movers rise to the top.

HOW TO USE
1. Add the indicator to any chart.
2. In settings, enter your symbols in EXCHANGE:TICKER form (e.g. NSE:RELIANCE).
3. Set the scanner timeframe, EMA length and RSI length to match your style.
4. Use the dashboard to see which symbols share the same trend and momentum bias.
   It is meant as a quick filter to shortlist symbols for closer analysis on
   their own charts.

SETTINGS
- Scanner Timeframe, Trend EMA Length, RSI Length
- Sort by % change (on/off)
- Table position and text size
- 15 editable symbols

NOTES
This tool is for analysis and education only. It does not predict future prices
and is not financial advice. Reliable results require a valid data feed for each
symbol. Always do your own research and manage risk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//   PRO SCANNER  🐘 @darshakssc
//   Clean multi-stock dashboard • Heatmap cells • Sortable by % change
// ════════════════════════════════════════════════════════════════════
indicator("Pro Scanner 🐘 @darshakssc", overlay = true)

// ───────────────────────────── INPUTS ──────────────────────────────
gG = "General"
scTF   = input.timeframe("", "Scanner Timeframe (blank = chart, 'D' = day %)", group = gG)
emaLen = input.int(34, "Trend EMA Length", minval = 2, group = gG)
rsiLen = input.int(14, "RSI Length", minval = 2, group = gG)
sortOn = input.bool(true, "Sort by % Change (desc)", group = gG)
pos    = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Top Left", "Bottom Right"], group = gG)
txtSz  = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = gG)

gW = "Watchlist"
s01 = input.symbol("NSE:RELIANCE",   "1",  group = gW)
s02 = input.symbol("NSE:HDFCBANK",   "2",  group = gW)
s03 = input.symbol("NSE:ICICIBANK",  "3",  group = gW)
s04 = input.symbol("NSE:SBIN",       "4",  group = gW)
s05 = input.symbol("NSE:AXISBANK",   "5",  group = gW)
s06 = input.symbol("NSE:KOTAKBANK",  "6",  group = gW)
s07 = input.symbol("NSE:INFY",       "7",  group = gW)
s08 = input.symbol("NSE:TCS",        "8",  group = gW)
s09 = input.symbol("NSE:BAJFINANCE", "9",  group = gW)
s10 = input.symbol("NSE:TATAMOTORS", "10", group = gW)
s11 = input.symbol("NSE:MARUTI",     "11", group = gW)
s12 = input.symbol("NSE:LT",         "12", group = gW)
s13 = input.symbol("NSE:ITC",        "13", group = gW)
s14 = input.symbol("NSE:BHARTIARTL", "14", group = gW)
s15 = input.symbol("NSE:HINDUNILVR", "15", group = gW)

// ───────────────────────────── ENGINE ──────────────────────────────
f_scan(sym) =>
    [c, pc, e, r] = request.security(sym, scTF, [close, close[1], ta.ema(close, emaLen), ta.rsi(close, rsiLen)], barmerge.gaps_off, barmerge.lookahead_off)
    chg = pc != 0 ? (c - pc) / pc * 100 : 0.0
    [c, chg, c > e, r]

f_nm(s) => str.replace_all(str.replace_all(s, "NSE:", ""), "BSE:", "")

[c01, h01, t01, r01] = f_scan(s01)
[c02, h02, t02, r02] = f_scan(s02)
[c03, h03, t03, r03] = f_scan(s03)
[c04, h04, t04, r04] = f_scan(s04)
[c05, h05, t05, r05] = f_scan(s05)
[c06, h06, t06, r06] = f_scan(s06)
[c07, h07, t07, r07] = f_scan(s07)
[c08, h08, t08, r08] = f_scan(s08)
[c09, h09, t09, r09] = f_scan(s09)
[c10, h10, t10, r10] = f_scan(s10)
[c11, h11, t11, r11] = f_scan(s11)
[c12, h12, t12, r12] = f_scan(s12)
[c13, h13, t13, r13] = f_scan(s13)
[c14, h14, t14, r14] = f_scan(s14)
[c15, h15, t15, r15] = f_scan(s15)

// ───────────────────────────── HELPERS ─────────────────────────────
f_pos() =>
    switch pos
        "Middle Right" => position.middle_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_sz() =>
    switch txtSz
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

f_rsiCol(r) =>
    r >= 70 ? color.new(#ef5350, 20) : r <= 30 ? color.new(#26a69a, 20) : color.new(color.gray, 40)

f_sig(t, r) =>
    t and r > 55 ? "BUY" : not t and r < 45 ? "SELL" : "—"

f_sigCol(t, r) =>
    t and r > 55 ? color.new(#26a69a, 0) : not t and r < 45 ? color.new(#ef5350, 0) : color.new(color.gray, 50)

// ───────────────────────────── RENDER ──────────────────────────────
var table tb = table.new(f_pos(), 6, 16, border_width = 1, border_color = color.new(color.gray, 70))

if barstate.islast
    table_id = tb
    names = array.from(f_nm(s01), f_nm(s02), f_nm(s03), f_nm(s04), f_nm(s05), f_nm(s06), f_nm(s07), f_nm(s08), f_nm(s09), f_nm(s10), f_nm(s11), f_nm(s12), f_nm(s13), f_nm(s14), f_nm(s15))
    ltps  = array.from(c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11, c12, c13, c14, c15)
    chgs  = array.from(h01, h02, h03, h04, h05, h06, h07, h08, h09, h10, h11, h12, h13, h14, h15)
    trs   = array.from(t01, t02, t03, t04, t05, t06, t07, t08, t09, t10, t11, t12, t13, t14, t15)
    rsis  = array.from(r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11, r12, r13, r14, r15)

    order = sortOn ? array.sort_indices(chgs, order.descending) : array.from(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)

    sz = f_sz()
    hbg = color.new(#1e1e2e, 0)
    // header
    table.cell(table_id, 0, 0, "Symbol", text_color = color.white, bgcolor = hbg, text_size = sz)
    table.cell(table_id, 1, 0, "LTP",    text_color = color.white, bgcolor = hbg, text_size = sz)
    table.cell(table_id, 2, 0, "Chg%",   text_color = color.white, bgcolor = hbg, text_size = sz)
    table.cell(table_id, 3, 0, "Trend",  text_color = color.white, bgcolor = hbg, text_size = sz)
    table.cell(table_id, 4, 0, "RSI",    text_color = color.white, bgcolor = hbg, text_size = sz)
    table.cell(table_id, 5, 0, "Signal", text_color = color.white, bgcolor = hbg, text_size = sz)

    for i = 0 to array.size(names) - 1
        idx = array.get(order, i)
        nm  = array.get(names, idx)
        lt  = array.get(ltps, idx)
        ch  = array.get(chgs, idx)
        tr  = array.get(trs, idx)
        rs  = array.get(rsis, idx)
        row = i + 1
        rowbg = row % 2 == 0 ? color.new(#2a2a3a, 20) : color.new(#22222e, 20)
        table.cell(table_id, 0, row, nm, text_color = color.white, bgcolor = rowbg, text_size = sz)
        table.cell(table_id, 1, row, str.tostring(lt, "0.00"), text_color = color.white, bgcolor = rowbg, text_size = sz)
        table.cell(table_id, 2, row, str.tostring(ch, "0.00") + "%", text_color = color.white, bgcolor = ch >= 0 ? color.new(#26a69a, 30) : color.new(#ef5350, 30), text_size = sz)
        table.cell(table_id, 3, row, tr ? "▲" : "▼", text_color = color.white, bgcolor = tr ? color.new(#26a69a, 10) : color.new(#ef5350, 10), text_size = sz)
        table.cell(table_id, 4, row, str.tostring(rs, "0"), text_color = color.white, bgcolor = f_rsiCol(rs), text_size = sz)
        table.cell(table_id, 5, row, f_sig(tr, rs), text_color = color.white, bgcolor = f_sigCol(tr, rs), text_size = sz)
````
