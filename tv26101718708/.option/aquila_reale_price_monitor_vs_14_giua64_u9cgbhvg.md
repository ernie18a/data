# Aquila Reale  Price Monitor vs 1.4  @giua64

- url: https://www.tradingview.com/script/U9CgBhvG/
- type: indicator
- pine_id: PUB;34a65ee679974298ae9acc4c057ffb97
- version: 3.0

## Description

🦅 Aquila Reale — Price Monitor
A single-panel macro dashboard built to keep the bond market and the US dollar under control at a glance, so you never trade gold (or indices) blind to what is actually driving them.
Instead of jumping between ten tabs, this table pulls together every cross-asset driver that moves XAU/USD and risk assets, and refreshes on the last bar:

🏦 Yields & Dollar — DXY, the full US Treasury curve (2Y, 5Y, 10Y, 30Y), 10Y breakeven inflation, and WTI crude. Daily % change is colour-coded so you instantly see who is pushing and in which direction.

🥇 Gold Zone — the part that matters most for a gold trader:

10Y Real Yield (10Y minus breakeven) with a configurable threshold flagging when the real rate is supportive or hostile for gold.

10Y-2Y spread showing whether the curve is normal or inverted.

Gold Bias — an intraday read scored from the two main drivers (2Y and DXY): when both fall, bias is gold-positive; when both rise, gold-negative.

Steepener — tells you not just that the curve is widening, but why: a 2Y-led move (bull steepener, gold-positive) versus a 10Y-led move (bear steepener, gold-negative).

📈 Futures — Gold, Silver, S&P, Nasdaq, Dow and DAX, to read overall risk appetite.
🇪🇺 Eurozone — Bund and BTP 10Y plus the BTP-Bund spread in basis points, with a stress flag for European risk.

😱 Volatility — VIX as the fear gauge.
Everything is configurable: symbols, text size, table position with fine horizontal/vertical offset, bias sensitivity and the real-yield threshold. No repainting tricks — it simply reports daily and intraday change from the underlying instruments.
Built to monitor and keep yields in check before pulling the trigger.

🦅  Aquile Reali, Nate per volare, nate per osare.

## Source Code

````pine
//@version=6
indicator("🦅 Aquila Reale — Price Monitor vs 1.6 | giua64", overlay = true, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════════
// VIEW MODE
// ════════════════════════════════════════════════════════════════════
grp_view = "👁️ View Mode"
viewMode = input.string("Extended", "Mode", options = ["Minimal","Extended"], group = grp_view, tooltip = "Minimal = only Yields & Dollar + Gold Zone. Extended = full dashboard (Futures, Eurozone, Volatility).")
isMin = viewMode == "Minimal"

// ════════════════════════════════════════════════════════════════════
// SYMBOLS
// ════════════════════════════════════════════════════════════════════
grp_y = "🏦 Yields & Dollar"
symDXY = input.symbol("TVC:DXY",   "💵 DXY",   group = grp_y)
symU02 = input.symbol("TVC:US02Y", "🎯 US02Y", group = grp_y)
symU05 = input.symbol("TVC:US05Y", "🏛️ US05Y", group = grp_y)
symU10 = input.symbol("TVC:US10Y", "🏦 US10Y", group = grp_y)
symU30 = input.symbol("TVC:US30Y", "🏰 US30Y", group = grp_y)
symBE  = input.symbol("FRED:T10YIE","📊 10Y Breakeven", group = grp_y)
symCL  = input.symbol("NYMEX:CL1!", "🛢️ WTI Fut (CL)", group = grp_y)

grp_f = "📈 Futures"
symGC = input.symbol("OANDA:XAUUSD",  "🥇 Gold (XAUUSD)",   group = grp_f)
symSI = input.symbol("OANDA:XAGUSD",  "🪙 Silver (XAGUSD)", group = grp_f)
symES = input.symbol("CME_MINI:ES1!", "🇺🇸 S&P Fut (ES)",   group = grp_f)
symNQ = input.symbol("CME_MINI:NQ1!", "💻 Nasdaq Fut (NQ)", group = grp_f)
symYM = input.symbol("CBOT_MINI:YM1!", "🏭 Dow Fut (YM)",   group = grp_f)
symDX = input.symbol("EUREX:FDAX1!", "🇩🇪 DAX Fut (FDAX)", group = grp_f)

grp_e = "🇪🇺 Eurozone"
symDE10 = input.symbol("TVC:DE10Y", "🇩🇪 Bund 10Y", group = grp_e)
symIT10 = input.symbol("TVC:IT10Y", "🇮🇹 BTP 10Y",  group = grp_e)

grp_v = "😱 Volatility"
symVIX = input.symbol("TVC:VIX", "😱 VIX", group = grp_v)

// ── Settings ──
grp_set = "Settings"
realThr  = input.float(1.5,  "10Y real yield threshold for 'gold ✓' (%)", step = 0.1, group = grp_set, tooltip = "Below this threshold the real yield is considered supportive for gold.")
biasSens = input.float(0.05, "BIAS sensitivity (% driver move)", step = 0.01, minval = 0.0, group = grp_set, tooltip = "Minimum move (in %, on the chart TF) to consider a driver 'rising' or 'falling'. Lower = more reactive.")

// ── Direction arrow: follows the CHART timeframe (close vs open of current candle) ──
grp_dir = "🧭 Direction (chart TF)"
_dirNote = input.bool(true, "Arrow = current candle direction on chart TF", group = grp_dir, tooltip = "The DIR arrow reads each asset on the SAME timeframe as your chart (close vs open of the live candle): ▲ blue = up, ▼ red = down, ▬ grey = flat. Using the chart TF avoids the 'unsupported resolution' error and keeps under TradingView's 40 request limit.")

// ════════════════════════════════════════════════════════════════════
// LAYOUT
// ════════════════════════════════════════════════════════════════════
grp_lay = "Layout"
sizeOpt = input.string("normal", "Text Size", options = ["tiny","small","normal","large"], group = grp_lay)
posOpt  = input.string("middle_right", "Position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"],
     group = grp_lay)
grp_off = "Table position (Offset)"
hOffset = input.int(0, "Horizontal Offset  (← neg | pos →)", minval = -50, maxval = 50, group = grp_off)
vOffset = input.int(0, "Vertical Offset  (↑ neg | pos ↓)",   minval = -30, maxval = 30, group = grp_off)

// ════════════════════════════════════════════════════════════════════
// HELPERS & COLORS
// ════════════════════════════════════════════════════════════════════
getPos(p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        =>                 position.bottom_right
getSz(s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal
txtSz  = getSz(sizeOpt)
tabPos = getPos(posOpt)

c_hdr   = color.rgb(20, 20, 60)
c_bg    = color.rgb(10, 10, 10)
c_txt   = color.white
c_yel   = color.yellow
c_long  = color.rgb(0, 230, 118)
c_short = color.rgb(255, 20, 110)
c_neut  = color.rgb(200, 200, 200)
c_pad   = color.new(color.black, 100)
c_sec   = color.rgb(35, 35, 75)

// ── direction arrow colors (high contrast on near-black bg) ──
c_dirUp   = color.rgb(0, 170, 255)    // azzurro acceso = su
c_dirDn   = color.rgb(255, 60, 60)    // rosso = giù
c_dirFlat = color.rgb(150, 150, 150)  // grigio = flat

// ── emphasized GOLD ZONE colors ──
c_bg_o  = color.rgb(40, 30, 0)
c_sec_o = color.rgb(212, 160, 23)
c_o_txt = color.rgb(0, 0, 0)

// ════════════════════════════════════════════════════════════════════
// FETCH ALL — one direction (1H) per asset, classic request.security.
//  Per asset: 1 daily call (price + %chg) + 1 hourly call (1H direction)
//  = 2 calls/asset * 16 = 32, + 3 bias drivers = 35. Under the 40 limit. ✓
//  Direction = 1H close vs 1H open. +1 up | -1 down | 0 flat/na.
// ════════════════════════════════════════════════════════════════════
f_dir1(float c, float o) => na(o) or na(c) ? 0 : c > o ? 1 : c < o ? -1 : 0

f_all(simple string sym) =>
    [dC, dPC] = request.security(sym, "D", [close, close[1]], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    [cTF, oTF] = request.security(sym, timeframe.period, [close, open], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    chg = dPC != 0 and not na(dPC) ? (dC - dPC) / dPC * 100 : 0.0
    [dC, chg, f_dir1(cTF, oTF)]

[pxDXY, chDXY, dDXY] = f_all(symDXY)
[pxU02, chU02, dU02] = f_all(symU02)
[pxU05, chU05, dU05] = f_all(symU05)
[pxU10, chU10, dU10] = f_all(symU10)
[pxU30, chU30, dU30] = f_all(symU30)
[pxBE,  chBE,  dBE ] = f_all(symBE)
[pxCL,  chCL,  dCL ] = f_all(symCL)
[pxGC,  chGC,  dGC ] = f_all(symGC)
[pxSI,  chSI,  dSI ] = f_all(symSI)
[pxES,  chES,  dES ] = f_all(symES)
[pxNQ,  chNQ,  dNQ ] = f_all(symNQ)
[pxYM,  chYM,  dYM ] = f_all(symYM)
[pxDAX, chDAX, dDAX] = f_all(symDX)
[pxDE,  chDE,  dDE ] = f_all(symDE10)
[pxIT,  chIT,  dIT ] = f_all(symIT10)
[pxVIX, chVIX, dVIX] = f_all(symVIX)

// ── FETCH INTRADAY %CHANGE on chart TF (only the 3 bias drivers) ──
f_chgTF(simple string sym) =>
    [c, pc] = request.security(sym, timeframe.period, [close, close[1]], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    pc != 0 and not na(pc) ? (c - pc) / pc * 100 : 0.0

iDXY = f_chgTF(symDXY)   // dollar intraday
i02  = f_chgTF(symU02)   // 2Y intraday
i10  = f_chgTF(symU10)   // 10Y intraday

// derived (no extra calls)
real10    = pxU10 - pxBE
spread102 = pxU10 - pxU02

// ════════════════════════════════════════════════════════════════════
// GOLD BIAS (intraday read)
// drivers: 2Y down = gold-positive, DXY down = gold-positive
// ════════════════════════════════════════════════════════════════════
up02  = i02  >  biasSens
dn02  = i02  < -biasSens
upDXY = iDXY >  biasSens
dnDXY = iDXY < -biasSens

// score: -1 each if the driver RISES (against gold), +1 if it FALLS (gold-positive)
score = (dn02 ? 1 : up02 ? -1 : 0) + (dnDXY ? 1 : upDXY ? -1 : 0)

biasTxt = score >=  2 ? "STRONG ↑" : score == 1 ? "↑" : score == 0 ? "neutral" : score == -1 ? "↓" : "STRONG ↓"
biasCol = score >  0 ? c_long : score < 0 ? c_short : c_neut

// ── STEEPENER: is the 10Y-2Y spread widening? and why? ──
spreadDir = i10 - i02   // >0 spread widens, <0 compresses
up10 = i10 > biasSens
string steepTxt = "—"
color  steepCol = c_neut
if spreadDir > biasSens
    if dn02
        steepTxt := "good ✓"      // 2Y falling = bull steepener = gold-positive
        steepCol := c_long
    else if up10
        steepTxt := "bad ✗"       // 10Y rising = bear steepener = gold-negative
        steepCol := c_short
    else
        steepTxt := "widening"
        steepCol := c_neut
else if spreadDir < -biasSens
    steepTxt := "flattening"
    steepCol := dn02 ? c_neut : c_short
else
    steepTxt := "flat"
    steepCol := c_neut

// ════════════════════════════════════════════════════════════════════
// DISPLAY HELPERS
// ════════════════════════════════════════════════════════════════════
f_fmt(float v) =>
    na(v) ? "—" : v >= 10000 ? str.tostring(v, "#,###") : v >= 1000 ? str.tostring(v, "#,###.#") : v >= 100 ? str.tostring(v, "#.##") : str.tostring(v, "#.###")

f_chgstr(float v) => (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"
f_ccol(float v)   => v > 0.001 ? c_long : v < -0.001 ? c_short : c_neut

// direction arrow glyph + color (filled triangles + horizontal bar for flat)
f_arrow(int d) => d > 0 ? "▲" : d < 0 ? "▼" : "▬"
f_acol(int d)  => d > 0 ? c_dirUp : d < 0 ? c_dirDn : c_dirFlat

// ════════════════════════════════════════════════════════════════════
// LAYOUT + OFFSET (BEFORE the table)
// ════════════════════════════════════════════════════════════════════
isLeftAnchor   = posOpt == "top_left"    or posOpt == "middle_left"   or posOpt == "bottom_left"
isRightAnchor  = posOpt == "top_right"   or posOpt == "middle_right"  or posOpt == "bottom_right"
isTopAnchor    = posOpt == "top_left"    or posOpt == "top_center"    or posOpt == "top_right"
isBottomAnchor = posOpt == "bottom_left" or posOpt == "bottom_center" or posOpt == "bottom_right"

int  hPad    = 0
bool padLeft = false
if hOffset < 0 and not isLeftAnchor
    hPad := math.abs(hOffset)
    padLeft := false
if hOffset > 0 and not isRightAnchor
    hPad := hOffset
    padLeft := true

int  vPad   = 0
bool padTop = false
if vOffset < 0 and not isTopAnchor
    vPad := math.abs(vOffset)
    padTop := false
if vOffset > 0 and not isBottomAnchor
    vPad := vOffset
    padTop := true

// columns now: 0=Name 1=Price 2=%chg 3=dir15m 4=dir1H 5=dir4H  → 6 visible cols
VIS_COLS = 4
// Minimal: rows 0..12  (13 rows) — Title, Yields(7), Gold Zone(5)
// Extended: rows 0..25 (26 rows) — adds Futures, Eurozone, Volatility
VIS_ROWS = isMin ? 13 : 26
totCols = VIS_COLS + hPad
totRows = VIS_ROWS + vPad
cStart  = padLeft ? hPad : 0
rStart  = padTop  ? vPad : 0

spreadBTP = pxIT - pxDE

// row helper: name | price | %chg | dir15m | dir1H | dir4H  (customizable bg)
f_row2(table t, int r, string lbl, color lblColor, float px, float ch, color bg, int d) =>
    table.cell(t, cStart + 0, rStart + r, lbl, text_color = lblColor, bgcolor = bg, text_size = txtSz)
    table.cell(t, cStart + 1, rStart + r, f_fmt(px), text_color = c_txt, bgcolor = bg, text_size = txtSz, text_halign = text.align_right)
    table.cell(t, cStart + 2, rStart + r, f_chgstr(ch), text_color = f_ccol(ch), bgcolor = bg, text_size = txtSz, text_halign = text.align_right)
    table.cell(t, cStart + 3, rStart + r, f_arrow(d), text_color = f_acol(d), bgcolor = bg, text_size = txtSz, text_halign = text.align_center)

f_row(table t, int r, string lbl, color lblColor, float px, float ch, int d) =>
    f_row2(t, r, lbl, lblColor, px, ch, c_bg, d)

f_sec3(table t, int r, string lbl, color bg, color txt) =>
    table.cell(t, cStart + 0, rStart + r, lbl, text_color = txt, bgcolor = bg, text_size = txtSz, text_halign = text.align_left)
    table.merge_cells(t, cStart + 0, rStart + r, cStart + 3, rStart + r)

f_sec(table t, int r, string lbl) =>
    f_sec3(t, r, lbl, c_sec, c_yel)

// header for the direction column (follows chart timeframe)
f_dirHdr(table t, int r) =>
    table.cell(t, cStart + 3, rStart + r, "DIR", text_color = c_neut, bgcolor = c_hdr, text_size = txtSz, text_halign = text.align_center)

// ════════════════════════════════════════════════════════════════════
// TABLE (no borders, no frame) — rebuilt every update to avoid overlap
// ════════════════════════════════════════════════════════════════════
var table dash = na

if barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(tabPos, totCols, totRows, border_width = 0, frame_width = 0)

    if hPad > 0 or vPad > 0
        for c = 0 to totCols - 1
            for r = 0 to totRows - 1
                inVis = (c >= cStart and c < cStart + VIS_COLS) and (r >= rStart and r < rStart + VIS_ROWS)
                if not inVis
                    table.cell(dash, c, r, " ", bgcolor = c_pad, text_color = c_pad, text_size = txtSz)

    // title (spans name+price+%chg) + direction sub-headers (15m/1H/4H)
    table.cell(dash, cStart + 0, rStart + 0, "🦅 PRICE MONITOR", text_color = c_txt, bgcolor = c_hdr, text_size = txtSz, text_halign = text.align_center)
    table.merge_cells(dash, cStart + 0, rStart + 0, cStart + 2, rStart + 0)
    f_dirHdr(dash, 0)

    // 🏦 Yields & Dollar  (always shown)
    f_sec(dash, 1,  "🏦 YIELDS & DOLLAR")
    f_row(dash, 2, "💵 DXY",    color.aqua,   pxDXY, chDXY, dDXY)
    f_row(dash, 3, "🎯 US02Y",  color.lime,   pxU02, chU02, dU02)
    f_row(dash, 4, "🏛️ US05Y",  color.teal,   pxU05, chU05, dU05)
    f_row(dash, 5, "🏦 US10Y",  color.orange, pxU10, chU10, dU10)
    f_row(dash, 6, "🏰 US30Y",  color.maroon, pxU30, chU30, dU30)
    f_row(dash, 7, "🛢️ WTI CL",  color.red,    pxCL,  chCL, dCL)

    // ═══ 🥇 GOLD ZONE (BIAS + CURVE) ═══  (always shown)
    f_sec3(dash, 8, "🥇 GOLD ZONE", c_sec_o, c_o_txt)
    table.cell(dash, cStart + 0, rStart + 9, "💎 10Y REAL", text_color = c_sec_o, bgcolor = c_bg_o, text_size = txtSz)
    table.cell(dash, cStart + 1, rStart + 9, str.tostring(real10, "#.###") + "%", text_color = c_txt, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_right)
    table.cell(dash, cStart + 2, rStart + 9, real10 < realThr ? "gold ✓" : "gold ✗", text_color = real10 < realThr ? c_long : c_short, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_right)
    table.merge_cells(dash, cStart + 2, rStart + 9, cStart + 3, rStart + 9)
    table.cell(dash, cStart + 0, rStart + 10, "📐 10Y-2Y", text_color = color.gray, bgcolor = c_bg_o, text_size = txtSz)
    table.cell(dash, cStart + 1, rStart + 10, (spread102 > 0 ? "+" : "") + str.tostring(spread102, "#.###"), text_color = spread102 >= 0 ? c_long : c_short, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_right)
    table.cell(dash, cStart + 2, rStart + 10, spread102 >= 0 ? "normal" : "INVERTED", text_color = spread102 >= 0 ? c_long : c_short, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_right)
    table.merge_cells(dash, cStart + 2, rStart + 10, cStart + 3, rStart + 10)
    table.cell(dash, cStart + 0, rStart + 11, "🎯 GOLD BIAS", text_color = c_sec_o, bgcolor = c_bg_o, text_size = txtSz)
    table.cell(dash, cStart + 1, rStart + 11, biasTxt, text_color = biasCol, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_center)
    table.merge_cells(dash, cStart + 1, rStart + 11, cStart + 3, rStart + 11)
    table.cell(dash, cStart + 0, rStart + 12, "🔧 STEEPENER", text_color = color.gray, bgcolor = c_bg_o, text_size = txtSz)
    table.cell(dash, cStart + 1, rStart + 12, steepTxt, text_color = steepCol, bgcolor = c_bg_o, text_size = txtSz, text_halign = text.align_center)
    table.merge_cells(dash, cStart + 1, rStart + 12, cStart + 3, rStart + 12)

    // ═══ EXTENDED-ONLY SECTIONS ═══
    if not isMin
        // 📈 Futures
        f_sec(dash, 13, "📈 FUTURES")
        f_row(dash, 14, "🥇 Gold",      color.yellow, pxGC,  chGC, dGC)
        f_row(dash, 15, "🪙 Silver",    color.silver, pxSI,  chSI, dSI)
        f_row(dash, 16, "🇺🇸 S&P ES",   color.purple, pxES,  chES, dES)
        f_row(dash, 17, "💻 Nq NQ",    color.aqua,   pxNQ,  chNQ, dNQ)
        f_row(dash, 18, "🏭 Dow YM",   color.white,  pxYM,  chYM, dYM)
        f_row(dash, 19, "🇩🇪 DAX FDAX", color.white,  pxDAX, chDAX, dDAX)

        // 🇪🇺 Eurozone
        f_sec(dash, 20, "🇪🇺 EUROZONE")
        f_row(dash, 21, "🇩🇪 Bund 10Y", color.aqua,   pxDE, chDE, dDE)
        f_row(dash, 22, "🇮🇹 BTP 10Y",  color.green,  pxIT, chIT, dIT)
        table.cell(dash, cStart + 0, rStart + 23, "📊 BTP-Bund", text_color = color.gray, bgcolor = c_bg, text_size = txtSz)
        table.cell(dash, cStart + 1, rStart + 23, str.tostring(spreadBTP * 100, "#") + " bp", text_color = c_txt, bgcolor = c_bg, text_size = txtSz, text_halign = text.align_right)
        table.cell(dash, cStart + 2, rStart + 23, spreadBTP * 100 < 150 ? "ok" : "stress", text_color = spreadBTP * 100 < 150 ? c_long : c_short, bgcolor = c_bg, text_size = txtSz, text_halign = text.align_right)
        table.merge_cells(dash, cStart + 2, rStart + 23, cStart + 3, rStart + 23)

        // 😱 Volatility
        f_sec(dash, 24, "😱 VOLATILITY")
        f_row(dash, 25, "😱 VIX",      color.fuchsia, pxVIX, chVIX, dVIX)
````
