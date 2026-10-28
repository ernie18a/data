# Regime Correlation Matrix - More Tickers

- url: https://www.tradingview.com/script/UkOHpSj8-Regime-Correlation-Matrix-More-Tickers/
- type: indicator
- pine_id: PUB;f1cb995644c14ba687414ec329ea9023
- version: 2.0

## Description

an extension of my previous correlation matrix indicator

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maysoncunningham2

//@version=5
indicator("Regime Correlation Matrix - More Tickers", overlay=true, max_lines_count=0, max_labels_count=0)

// ============================================================
// REGIME CORRELATION MATRIX
// Instruments: NQ, ES, CL, 6C, HG, GC, ZN, ZT, CNH, DXY
// Displays rolling Pearson correlation vs base chart symbol
// Color: Green = positive correlation, Red = negative, Gray = neutral
// ============================================================

// --- INPUTS ---
length = input.int(78, "Correlation Length (bars)", minval=5, maxval=500,
     tooltip="78 = ~1 RTH session on 5m | 20 = rolling 2-hour window | 390 = 1 week on 5m")

show_pval = input.bool(false, "Show Strength Label (|r| > 0.6 = Strong)")

pos_col   = input.color(color.new(color.green, 0),  "Positive Color")
neg_col   = input.color(color.new(color.red,   0),  "Negative Color")
neut_col  = input.color(color.new(color.gray,  0),  "Neutral Color")
bg_col    = input.color(color.new(color.black, 20), "Table Background")
txt_col   = input.color(color.white,                "Text Color")

// --- SYMBOL REQUESTS ---
// Using close prices of each instrument
// Adjust symbols if your broker uses different prefixes
nq  = request.security("CME_MINI:NQ1!", timeframe.period, close)  // Nasdaq100 futures cts. con
es  = request.security("CME_MINI:ES1!", timeframe.period, close)  // SP500 futures cts. con
cl  = request.security("NYMEX:CL1!",    timeframe.period, close)  // Crude Oil - WTI
bz  = request.security("NYMEX:BZ1!",    timeframe.period, close)  // Crude Oil - Brent
xle = request.security("XLE",      timeframe.period, close)  // Energy ETF
c6  = request.security("CME:6C1!",      timeframe.period, close)  // Canadian Dollar
hg  = request.security("COMEX:HG1!",    timeframe.period, close)  // Copper
gc  = request.security("COMEX:GC1!",    timeframe.period, close)  // Gold
zn  = request.security("CBOT:ZN1!",     timeframe.period, close)  // 10Y Treasury
cnh = request.security("FX:USDCNH",     timeframe.period, close)  // Offshore Yuan (inverse: up = CNH weak)
dxy = request.security("DXY",           timeframe.period, close)  // USD basket
zt  = request.security("CBOT:ZT1!",     timeframe.period, close)  // 2Y Treasury
vix = request.security("CBOE:VIX",      timeframe.period, close)  // VIX
vvix = request.security("CBOE:VVIX",      timeframe.period, close)  // VVIX (vol of vol)
vix1d = request.security("CBOE:VIX1D",      timeframe.period, close)  // VIX1D
vix9d = request.security("CBOE:VIX9D",      timeframe.period, close)  // VIX9D
btc = request.security("COINBASE:BTCUSD",timeframe.period, close) // BTC pegged to greenback
eur= request.security("FOREXCOM:EURUSD",timeframe.period, close)  // Euro pegged to greenback
gbp= request.security("FOREXCOM:GBPUSD",timeframe.period, close)  // Pound pegged to greenback
jpy= request.security("CME:6J1!",timeframe.period, close)  // Yen future - cannot pull JPYUSD

base = close  // Whatever chart you are on (NQ recommended)

// --- CORRELATION CALCULATIONS ---
r_es  = ta.correlation(base, es,  length)
r_cl  = ta.correlation(base, cl,  length)
r_c6  = ta.correlation(base, c6,  length)
r_hg  = ta.correlation(base, hg,  length)
r_gc  = ta.correlation(base, gc,  length)
r_zn  = ta.correlation(base, zn,  length)
r_cnh = ta.correlation(base, cnh, length)
r_dxy = ta.correlation(base, dxy, length)
r_zt  = ta.correlation(base, zt,  length)
r_vix = ta.correlation(base, vix,  length)
r_eur = ta.correlation(base, eur, length)
r_gbp = ta.correlation(base, gbp, length)
r_bz  = ta.correlation(base, bz, length)
r_btc = ta.correlation(base, btc, length)
r_nq  = ta.correlation(base, nq, length)
r_jpy = ta.correlation(base, jpy, length)
r_vvix = ta.correlation(base, vvix,  length)
r_vix1d = ta.correlation(base, vix1d,  length)
r_vix9d = ta.correlation(base,vix9d,  length)
r_xle = ta.correlation(base, xle,  length)

// --- HELPER FUNCTIONS ---
// Color by correlation value
cell_color(r) =>
    if r >=  0.6
        color.new(pos_col, 20)
    else if r >=  0.2
        color.new(pos_col, 60)
    else if r <= -0.6
        color.new(neg_col, 20)
    else if r <= -0.2
        color.new(neg_col, 60)
    else
        color.new(neut_col, 60)

// Format correlation value as string
fmt(r) =>
    str.tostring(math.round(r, 2))

// Strength tag
strength(r) =>
    a = math.abs(r)
    if a >= 0.8
        " ●●●"
    else if a >= 0.6
        " ●●"
    else if a >= 0.4
        " ●"
    else
        ""

// Regime interpretation
regime_tag(sym, r) =>
    // Special logic for CNH (inverse — USD/CNH up = CNH weak = tariff fear)
    if sym == "USD/CNH"
        r <= -0.4 ? "↑ tariff relief" : r >= 0.4 ? "↓ tariff fear" : "neutral"
    else if sym == "CL"
        r >= 0.4  ? "risk-on / supply bid" : r <= -0.4 ? "stagflation" : "neutral"
    else if sym == "6C"
        r >= 0.4  ? "tariff relief" : r <= -0.4 ? "tariff fear" : "neutral"
    else if sym == "HG"
        r >= 0.4  ? "growth / trade relief" : r <= -0.4 ? "demand destruction" : "neutral"
    else if sym == "GC"
        r >= 0.4  ? "risk-on (unusual)" : r <= -0.4 ? "uncertainty bid" : "neutral"
    else if sym == "ZN"
        r >= 0.4  ? "deflation / risk-off" : r <= -0.4 ? "inflation / risk-on" : "neutral"
    else if sym == "ES"
        r >= 0.8  ? "tight correlation" : r >= 0.4 ? "loose correlation" : r <= 0.2 ? "DECOUPLED" : "normal"
    else
        ""

// --- BUILD TABLE ---
var table t = table.new(
     position.top_right, 4, 19,
     bgcolor        = bg_col,
     border_width   = 1,
     border_color   = color.new(color.gray, 60),
     frame_width    = 1,
     frame_color    = color.new(color.gray, 40))

if barstate.islast

    // Header row
    table.cell(t, 0, 0, "INSTRUMENT",  text_color=txt_col, bgcolor=color.new(color.navy, 20), text_size=size.small)
    table.cell(t, 1, 0, "CORR (r)",    text_color=txt_col, bgcolor=color.new(color.navy, 20), text_size=size.small)
    table.cell(t, 2, 0, "STRENGTH",    text_color=txt_col, bgcolor=color.new(color.navy, 20), text_size=size.small)
    table.cell(t, 3, 0, "REGIME READ", text_color=txt_col, bgcolor=color.new(color.navy, 20), text_size=size.small)

    // NQ row
    table.cell(t, 0, 1, "NQ (Nasdaq)",         text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 1, fmt(r_nq),           text_color=txt_col, bgcolor=cell_color(r_es), text_size=size.small)
    table.cell(t, 2, 1, strength(r_nq),      text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 1, regime_tag("NQ ", r_nq), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // ES row
    table.cell(t, 0, 2, "ES (S&P)",         text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 2, fmt(r_es),           text_color=txt_col, bgcolor=cell_color(r_es), text_size=size.small)
    table.cell(t, 2, 2, strength(r_es),      text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 2, regime_tag("ES", r_es), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // CL row
    table.cell(t, 0, 3, "CL (WTI Crude)",        text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 3, fmt(r_cl),            text_color=txt_col, bgcolor=cell_color(r_cl), text_size=size.small)
    table.cell(t, 2, 3, strength(r_cl),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 3, regime_tag("CL", r_cl), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // BZ row
    table.cell(t, 0, 4, "BZ (Brent Crude)",        text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 4, fmt(r_bz),            text_color=txt_col, bgcolor=cell_color(r_cl), text_size=size.small)
    table.cell(t, 2, 4, strength(r_bz),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 4, regime_tag("BZ", r_bz), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // XLE row
    table.cell(t, 0, 5, "XLE (Energy ETF)",        text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 5, fmt(r_xle),            text_color=txt_col, bgcolor=cell_color(r_xle), text_size=size.small)
    table.cell(t, 2, 5, strength(r_xle),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 5, regime_tag("XLE", r_xle), text_color=txt_col, bgcolor=bg_col, text_size=size.small)


    // 6C row
    table.cell(t, 0, 6, "6C (CAD)",          text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 6, fmt(r_c6),            text_color=txt_col, bgcolor=cell_color(r_c6), text_size=size.small)
    table.cell(t, 2, 6, strength(r_c6),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 6, regime_tag("6C", r_c6), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // HG row
    table.cell(t, 0, 7, "HG (Copper)",       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 7, fmt(r_hg),            text_color=txt_col, bgcolor=cell_color(r_hg), text_size=size.small)
    table.cell(t, 2, 7, strength(r_hg),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 7, regime_tag("HG", r_hg), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // GC row
    table.cell(t, 0, 8, "GC (Gold)",         text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 8, fmt(r_gc),            text_color=txt_col, bgcolor=cell_color(r_gc), text_size=size.small)
    table.cell(t, 2, 8, strength(r_gc),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 8, regime_tag("GC", r_gc), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // ZN row
    table.cell(t, 0, 9, "ZN (10Y Bond)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 9, fmt(r_zn),            text_color=txt_col, bgcolor=cell_color(r_zn), text_size=size.small)
    table.cell(t, 2, 9, strength(r_zn),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 9, regime_tag("ZN", r_zn), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // ZT row
    table.cell(t, 0, 10, "ZT (2Y T-Note)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 10, fmt(r_zt),            text_color=txt_col, bgcolor=cell_color(r_zt), text_size=size.small)
    table.cell(t, 2, 10, strength(r_zt),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 10, regime_tag("ZT", r_zt), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // DXY row
    table.cell(t, 0, 11, "DXY (USD$ Basket)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 11, fmt(r_dxy),            text_color=txt_col, bgcolor=cell_color(r_dxy), text_size=size.small)
    table.cell(t, 2, 11, strength(r_dxy),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 11, regime_tag("DXY", r_dxy), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // VIX row
    table.cell(t, 0, 12, "VIX (30d SPX Vol swap)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 12, fmt(r_vix),            text_color=txt_col, bgcolor=cell_color(r_vix), text_size=size.small)
    table.cell(t, 2, 12, strength(r_vix),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 12, regime_tag("VIX", r_vix), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // CNH row (note: USD/CNH is inverse — high = CNH weak)
    table.cell(t, 0, 13, "USD/CNH (Yuan)",    text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 13, fmt(r_cnh),           text_color=txt_col, bgcolor=cell_color(r_cnh), text_size=size.small)
    table.cell(t, 2, 13, strength(r_cnh),      text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 13, regime_tag("USD/CNH", r_cnh), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // EUR row
    table.cell(t, 0, 14, "EURUSD (Fiber)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 14, fmt(r_eur),            text_color=txt_col, bgcolor=cell_color(r_eur), text_size=size.small)
    table.cell(t, 2, 14, strength(r_eur),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 14, regime_tag("EURUSD", r_eur), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // GBP row
    table.cell(t, 0, 15, "GBPUSD (Cable)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 15, fmt(r_gbp),            text_color=txt_col, bgcolor=cell_color(r_gbp), text_size=size.small)
    table.cell(t, 2, 15, strength(r_gbp),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 15, regime_tag("GBPUSD", r_gbp), text_color=txt_col, bgcolor=bg_col, text_size=size.small)

    // BTC row
    table.cell(t, 0, 16, "BTCUSD (Bitcoin)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 16, fmt(r_btc),            text_color=txt_col, bgcolor=cell_color(r_btc), text_size=size.small)
    table.cell(t, 2, 16, strength(r_btc),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 16, regime_tag("BTCUSD", r_btc), text_color=txt_col, bgcolor=bg_col, text_size=size.small)


    // 6J1! row
    table.cell(t, 0, 17, "6J1! (Yen Futures)",     text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 1, 17, fmt(r_jpy),            text_color=txt_col, bgcolor=cell_color(r_jpy), text_size=size.small)
    table.cell(t, 2, 17, strength(r_jpy),       text_color=txt_col, bgcolor=bg_col, text_size=size.small)
    table.cell(t, 3, 17, regime_tag("6J1!", r_jpy), text_color=txt_col, bgcolor=bg_col, text_size=size.small)


    // Footer — length reminder (colspan not supported in Pine v5, use 4 cells)
    length_label = "Length: " + str.tostring(length) + " bars  |  tf: " + timeframe.period + "  |  Base: " + syminfo.ticker
    table.cell(t, 0, 18, length_label, text_color=color.new(color.gray, 20), bgcolor=bg_col, text_size=size.tiny)
    table.cell(t, 1, 18, "", text_color=color.new(color.gray, 20), bgcolor=bg_col, text_size=size.tiny)
    table.cell(t, 2, 18, "", text_color=color.new(color.gray, 20), bgcolor=bg_col, text_size=size.tiny)
    table.cell(t, 3, 18, "", text_color=color.new(color.gray, 20), bgcolor=bg_col, text_size=size.tiny)
````
