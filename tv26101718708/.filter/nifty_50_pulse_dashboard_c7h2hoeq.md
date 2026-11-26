# Nifty 50 Pulse Dashboard

- url: https://www.tradingview.com/script/C7h2hoeQ-Nifty-50-Pulse-Dashboard/
- type: indicator
- pine_id: PUB;f13ba87ff1d44c92a8ea11c9054d0753
- version: 1.0

## Description

[b]Nifty 50 Price & Volume Progress Dashboard
[/b]
This table is a compact market-breadth and learning tool designed to provide a quick visual overview of Nifty 50 constituent stocks. It displays stock names along with price direction, price percentage change, and volume movement. The consolidated header provides an overall view of advancing and declining stocks, together with volume breadth, helping users understand the general market condition at a glance.

The table is arranged in a simple 5-row structure with 10 stocks per row. Green indicates positive price movement, while red indicates negative movement. The upward and downward volume indicators show whether the current volume is higher or lower than the previous candle. The table can be positioned at different locations on the chart, and its text size and display settings can be adjusted from the indicator settings.

How to Use
Add the indicator to any TradingView chart and use the dashboard as a quick market overview rather than as a standalone trading signal. Compare the Buy and Sell breadth in the header with the individual stock movements. A higher percentage of advancing stocks may indicate broader positive participation, while a higher percentage of declining stocks may indicate broader negative participation. Increasing volume breadth can indicate stronger market participation, but volume alone does not determine market direction.

Important Note
This indicator is intended strictly for learning, education, market observation and testing of analytical processes. It does not provide investment advice, financial advice, buy or sell recommendations, or guaranteed trading signals. The Buy and Sell percentages represent price breadth, not actual exchange-level buying and selling orders. Volume figures represent changes in reported trading volume and should not be interpreted as direct buyer-versus-seller volume.

Disclaimer
Stock market and securities trading involve substantial risk and can result in partial or complete loss of capital. Past price or volume behaviour does not guarantee future results. This tool should not be used as the sole basis for making investment or trading decisions. Users should conduct their own research, understand the risks involved, and consult a qualified financial professional where appropriate. The author and publisher accept no responsibility for losses arising from the use or interpretation of this indicator.

This script is provided for educational and training purposes only. It is not a recommendation to buy, sell, or hold any security.

## Source Code

````pine
//@version=6
indicator("Nifty 50 Pulse Dashboard • Indices + Top 33", shorttitle = "N50 Pulse", overlay = false)

// ══════════════════════════════════════════════════════════════════════════════
//  NIFTY 50 PULSE DASHBOARD — 7 LIVE INDICES + TOP 33 ACTIVE STOCKS
//  • One table, exactly 40 data requests (fits Essential / Plus / Premium)
//  • Top: SENSEX · NIFTY 50 · BANK NIFTY · MIDCAP 50 · FIN NIFTY · NIFTY IT · NIFTY FMCG
//  • Header: breadth + consolidated Buy / Sell volume progress bar
//  • Grid: 33 stocks, alphabetical, 3 rows × 11
//  • Movable (9 positions) + resizable (text size, column width, row height)
//  • Theme: sky blue · white · light red, soft flash on price change
// ══════════════════════════════════════════════════════════════════════════════

// ───────────────────────────── CONSTANTS ─────────────────────────────
const int NI   = 7    // indices
const int N    = 33   // stocks
const int PER  = 11   // stocks per row
const int GRP  = 3    // stock rows
const int COLS = 22   // 2 sub-columns per stock
const int ROWS = 18   // 2 index + gap + 3 header + gap + 3×3 stock rows + 2 gaps
const int HB   = 3    // first header row (title band)
const int SB   = 7    // first stock row

// ───────────────────────────── INPUTS ─────────────────────────────
const string G_DATA = "Data"
const string G_LAY  = "Table Position & Size"
const string G_FX   = "Flash & Heat"
const string G_COL  = "Theme Colors"

string tfIn     = input.timeframe("D", "Data Timeframe", group = G_DATA, tooltip = "Timeframe used for price & volume change.\n'D' = today vs previous session.")
int    volLen   = input.int(1, "Volume Compare Length", minval = 1, maxval = 50, group = G_DATA, tooltip = "1 = vs previous bar's volume.\n>1 = vs average volume of the previous N bars.")
string nameMode = input.string("Short Name", "Display", options = ["Short Name", "Ticker"], group = G_DATA)
float  biasHi   = input.float(55, "Bullish When Buy % ≥", minval = 50, maxval = 90, group = G_DATA)
float  biasLo   = input.float(45, "Bearish When Buy % ≤", minval = 10, maxval = 50, group = G_DATA)

string posIn    = input.string("Bottom Center", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_LAY)
string sizeIn   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_LAY)
float  cellW    = input.float(3.9, "Column Width % (0 = Auto)", minval = 0, maxval = 10, step = 0.1, group = G_LAY, tooltip = "Width of each sub-column as % of chart width (22 sub-columns in total).\nFixed width keeps columns even. 0 = auto-fit text.")
float  cellH    = input.float(0.0, "Row Height % (0 = Auto)", minval = 0, maxval = 10, step = 0.1, group = G_LAY)
float  barH     = input.float(0.0, "Progress Bar Height % (0 = Auto)", minval = 0, maxval = 8, step = 0.1, group = G_LAY)
bool   gaps     = input.bool(true, "Gap Between Sections", group = G_LAY)
string fontIn   = input.string("Default", "Font", options = ["Default", "Monospace"], group = G_LAY)

bool   flashOn  = input.bool(true,  "Flash Price Cells On Change", group = G_FX)
bool   flashVol = input.bool(false, "Flash Volume Cells On Change", group = G_FX, tooltip = "Volume changes on almost every tick, so this is off by default to keep the table calm.")
int    flashMs  = input.int(1200, "Flash Duration (ms)", minval = 200, maxval = 10000, step = 100, group = G_FX)
float  heatMax  = input.float(3.0, "Stock Full Tint At ±%", minval = 0.5, maxval = 10, step = 0.5, group = G_FX)
float  heatIdx  = input.float(1.5, "Index Full Tint At ±%", minval = 0.25, maxval = 10, step = 0.25, group = G_FX)

color cSky     = input.color(#1A8FD6, "Sky Blue (Primary)", group = G_COL, inline = "c1")
color cRed     = input.color(#E25C6E, "Light Red",          group = G_COL, inline = "c1")
color cSkyTint = input.color(#B7E1F8, "Sky Tint",           group = G_COL, inline = "c2")
color cRedTint = input.color(#F8C4CB, "Red Tint",           group = G_COL, inline = "c2")
color cWhite   = input.color(#FFFFFF, "Cell White",         group = G_COL, inline = "c3")
color cNavy    = input.color(#13304D, "Text",               group = G_COL, inline = "c3")

color C_HEAD    = cSky
color C_ROW2    = #F4F9FD
color C_GUTTER  = #E3EDF6
color C_MUTED   = #6E8098
color C_FLASH_U = #9FD8F7
color C_FLASH_D = #F6AFB9
color C_FLASH_V = #DDF0FB

// ───────────────────────────── INDICES ─────────────────────────────
var array<string> ISYMS  = array.from("BSE:SENSEX", "NSE:NIFTY", "NSE:BANKNIFTY", "NSE:NIFTYMIDCAP50", "NSE:CNXFINANCE", "NSE:CNXIT", "NSE:CNXFMCG")
var array<string> INAMES = array.from("SENSEX",     "NIFTY 50",  "BANK NIFTY",    "MIDCAP 50",         "FIN NIFTY",      "NIFTY IT",  "NIFTY FMCG")
// column layout of the index strip across 22 sub-columns: spans 3,3,3,4,3,3,3
var array<int>    ISTART = array.from(0, 3, 6, 9, 13, 16, 19)
var array<int>    ISPAN  = array.from(3, 3, 3, 4, 3, 3, 3)

// ───────────────────────────── STOCKS (alphabetical) ─────────────────────────────
// Top 33 high-beta / high-turnover Nifty 50 names.
var array<string> SYMS = array.from(
     "NSE:ADANIENT",   "NSE:ADANIPORTS", "NSE:AXISBANK",   "NSE:BAJAJ_AUTO", "NSE:BAJFINANCE", "NSE:BAJAJFINSV",
     "NSE:BEL",        "NSE:BHARTIARTL", "NSE:BSE",        "NSE:COALINDIA",  "NSE:EICHERMOT",
     "NSE:ETERNAL",    "NSE:HCLTECH",    "NSE:HDFCBANK",   "NSE:HINDALCO",   "NSE:ICICIBANK",  "NSE:INDIGO",
     "NSE:INFY",       "NSE:JIOFIN",     "NSE:JSWSTEEL",   "NSE:KOTAKBANK",  "NSE:LT",
     "NSE:M_M",        "NSE:MAXHEALTH",  "NSE:ONGC",       "NSE:RELIANCE",   "NSE:SBIN",       "NSE:SHRIRAMFIN",
     "NSE:TMPV",       "NSE:TATASTEEL",  "NSE:TCS",        "NSE:TECHM",      "NSE:TRENT")

var array<string> NAMES = array.from(
     "Adani Ent",      "Adani Ports",    "Axis Bank",      "Bajaj Auto",     "Bajaj Finance",  "Bajaj Finserv",
     "BEL",            "Bharti Airtel",  "BSE",            "Coal India",     "Eicher Motors",
     "Eternal",        "HCL Tech",       "HDFC Bank",      "Hindalco",       "ICICI Bank",     "IndiGo",
     "Infosys",        "Jio Financial",  "JSW Steel",      "Kotak Bank",     "L&T",
     "M&M",            "Max Health",     "ONGC",           "Reliance",       "SBI",            "Shriram Fin",
     "Tata Motors PV", "Tata Steel",     "TCS",            "Tech Mahindra",  "Trent")

// ───────────────────────────── HELPERS ─────────────────────────────
f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        => position.bottom_center

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_mix(color a, color b, float t) =>
    color.from_gradient(math.max(0.0, math.min(1.0, t)), 0.0, 1.0, a, b)

f_heat(float chg, float mx) =>
    na(chg) ? cWhite : chg >= 0 ? f_mix(cWhite, cSkyTint, chg / mx) : f_mix(cWhite, cRedTint, -chg / mx)

f_arrow(float x) =>
    na(x) ? "•" : x > 0 ? "▲" : x < 0 ? "▼" : "■"

f_signed(float x, string fmt) =>
    na(x) ? "—" : (x > 0 ? "+" : "") + str.tostring(x, fmt)

f_pct(float x, string fmt) =>
    na(x) ? "—" : f_signed(x, fmt) + "%"

f_vol(float v) =>
    na(v) ? "—" : v >= 1e7 ? str.tostring(v / 1e7, "#,##0.00") + " Cr" : v >= 1e5 ? str.tostring(v / 1e5, "#,##0.00") + " L" : v >= 1e3 ? str.tostring(v / 1e3, "#,##0.0") + " K" : str.tostring(v, "#,##0")

f_flashBg(bool on, int t0, color fc, color base) =>
    int el = timenow - t0
    on and t0 > 0 and el < flashMs ? color.from_gradient(el, 0, flashMs, fc, base) : base

f_cell(table t, int col, int row, string txt, color bg, color tc, float w, float h, string sz, string ff, string tip = "", string ha = text.align_center) =>
    t.cell(col, row, txt, width = w, height = h, text_color = tc, text_halign = ha, text_valign = text.align_center, text_size = sz, bgcolor = bg, tooltip = tip, text_font_family = ff)

// ───────────────────────────── DATA REQUESTS (7 + 33 = 40 unique) ─────────────────────────────
var array<float> iC  = array.new_float(NI, na)
var array<float> iPC = array.new_float(NI, na)
var array<float> iH  = array.new_float(NI, na)
var array<float> iL  = array.new_float(NI, na)

for i = 0 to NI - 1
    [c, pc, h, l] = request.security(ISYMS.get(i), tfIn, [close, close[1], high, low], ignore_invalid_symbol = true)
    iC.set(i, c)
    iPC.set(i, pc)
    iH.set(i, h)
    iL.set(i, l)

var array<float> aC  = array.new_float(N, na)
var array<float> aPC = array.new_float(N, na)
var array<float> aH  = array.new_float(N, na)
var array<float> aL  = array.new_float(N, na)
var array<float> aV  = array.new_float(N, na)
var array<float> aVA = array.new_float(N, na)

for i = 0 to N - 1
    [c, pc, h, l, v, va] = request.security(SYMS.get(i), tfIn, [close, close[1], high, low, volume, ta.sma(volume, volLen)[1]], ignore_invalid_symbol = true)
    aC.set(i, c)
    aPC.set(i, pc)
    aH.set(i, h)
    aL.set(i, l)
    aV.set(i, v)
    aVA.set(i, va)

// ───────────────────────────── REALTIME FLASH STATE ─────────────────────────────
varip array<float> fLastI = array.new_float(NI, na)
varip array<int>   fTimeI = array.new_int(NI, 0)
varip array<int>   fDirI  = array.new_int(NI, 0)
varip array<float> fLastP = array.new_float(N, na)
varip array<float> fLastV = array.new_float(N, na)
varip array<int>   fTimeP = array.new_int(N, 0)
varip array<int>   fDirP  = array.new_int(N, 0)
varip array<int>   fTimeV = array.new_int(N, 0)
varip float        lastBuy = na
varip int          tBuy    = 0
varip int          dBuy    = 0

// ───────────────────────────── TABLE ─────────────────────────────
// Rebuilt on every update so merged cells survive realtime rollbacks.
var table tbl = na

if barstate.islast
    string sz   = f_size(sizeIn)
    string ff   = fontIn == "Monospace" ? font.family_monospace : font.family_default
    float  w    = cellW
    float  h    = cellH
    float  gapH = gaps ? 0.4 : 0.08

    if not na(tbl)
        tbl.delete()
    tbl := table.new(f_pos(posIn), COLS, ROWS, bgcolor = C_GUTTER, frame_color = cSky, frame_width = 1, border_color = C_GUTTER, border_width = 1)
    for row = 0 to ROWS - 1
        for col = 0 to COLS - 1
            tbl.cell(col, row, "", width = w, height = h, bgcolor = C_GUTTER)

    // ══ INDEX STRIP (rows 0–1) ══
    for i = 0 to NI - 1
        int   st  = ISTART.get(i)
        int   sp  = ISPAN.get(i)
        int   lsp = sp >= 4 ? 2 : 1                 // LTP sub-columns
        float c   = iC.get(i)
        float pc  = iPC.get(i)
        float pts = na(c) or na(pc) ? na : c - pc
        float chg = na(pts) or pc == 0 ? na : pts / pc * 100

        if not na(c)
            float lp = fLastI.get(i)
            if not na(lp) and c != lp
                fTimeI.set(i, timenow)
                fDirI.set(i, c > lp ? 1 : -1)
            fLastI.set(i, c)

        string tip    = ISYMS.get(i) + (na(c) ? "\nNo data" : "\nLTP: " + str.tostring(c, "#,##0.00") + "\nPrev Close: " + str.tostring(pc, "#,##0.00") + "\nHigh / Low: " + str.tostring(iH.get(i), "#,##0.00") + " / " + str.tostring(iL.get(i), "#,##0.00"))
        color  dirCol = na(chg) ? C_MUTED : chg > 0 ? cSky : chg < 0 ? cRed : C_MUTED
        color  ltpBg  = f_flashBg(flashOn, fTimeI.get(i), fDirI.get(i) > 0 ? C_FLASH_U : C_FLASH_D, cWhite)

        f_cell(tbl, st, 0, f_arrow(chg) + "  " + INAMES.get(i), C_HEAD, color.white, w, h, sz, ff, tip)
        f_cell(tbl, st, 1, na(c) ? "—" : str.tostring(c, "#,##0.00"), ltpBg, cNavy, w, h, sz, ff, tip, text.align_right)
        f_cell(tbl, st + lsp, 1, f_signed(pts, "#,##0.0") + "   " + f_pct(chg, "0.00"), f_heat(chg, heatIdx), dirCol, w, h, sz, ff, tip)

    f_cell(tbl, 0, 2, "", C_GUTTER, C_GUTTER, w, gapH, sz, ff)

    // ══ STOCK STATS + change detection ══
    array<float> chgA  = array.new_float(N, na)
    array<float> vchgA = array.new_float(N, na)
    float buyT   = 0.0
    float sellT  = 0.0
    float sumChg = 0.0
    int   nValid = 0
    int   adv    = 0
    int   dec    = 0
    int   unch   = 0

    for i = 0 to N - 1
        float c  = aC.get(i)
        float pc = aPC.get(i)
        float hi = aH.get(i)
        float lo = aL.get(i)
        float v  = aV.get(i)
        float va = aVA.get(i)

        if not na(c) and not na(pc) and pc != 0
            float chg = (c - pc) / pc * 100
            chgA.set(i, chg)
            nValid += 1
            sumChg += chg
            if chg > 0
                adv += 1
            else if chg < 0
                dec += 1
            else
                unch += 1

        if not na(v) and not na(va) and va > 0
            vchgA.set(i, (v - va) / va * 100)

        // Buy / sell split: close location within the range, weighted by turnover
        if not na(c) and not na(v) and not na(hi) and not na(lo)
            float turn = v * c
            float rng  = hi - lo
            float bf   = rng > 0 ? (c - lo) / rng : 0.5
            buyT  += turn * bf
            sellT += turn * (1 - bf)

        if not na(c)
            float lp = fLastP.get(i)
            if not na(lp) and c != lp
                fTimeP.set(i, timenow)
                fDirP.set(i, c > lp ? 1 : -1)
            fLastP.set(i, c)
        if not na(v)
            float lv = fLastV.get(i)
            if not na(lv) and v != lv
                fTimeV.set(i, timenow)
            fLastV.set(i, v)

    float totT    = buyT + sellT
    float buyPct  = totT > 0 ? buyT / totT * 100 : na
    float sellPct = na(buyPct) ? na : 100 - buyPct
    float avgChg  = nValid > 0 ? sumChg / nValid : na

    if not na(buyPct)
        if not na(lastBuy) and math.abs(buyPct - lastBuy) >= 0.05
            tBuy := timenow
            dBuy := buyPct > lastBuy ? 1 : -1
        lastBuy := buyPct

    // ══ HEADER ROW (HB) : title | breadth | avg + clock ══
    f_cell(tbl, 0, HB, "NIFTY 50 PULSE  ·  TOP 33 ACTIVE", C_HEAD, color.white, w, h, sz, ff, "33 high-beta / high-turnover Nifty 50 stocks", text.align_left)
    string breadth = "▲ " + str.tostring(adv) + " Advancing      ▼ " + str.tostring(dec) + " Declining      ■ " + str.tostring(unch) + " Unchanged"
    f_cell(tbl, 8, HB, breadth, C_HEAD, color.white, w, h, sz, ff, "Breadth vs previous close")
    string clock = str.format_time(timenow, "HH:mm:ss", "Asia/Kolkata")
    f_cell(tbl, 15, HB, "Avg " + f_pct(avgChg, "0.00") + "   ·   " + clock + " IST", C_HEAD, color.white, w, h, sz, ff, "Average % change of the 33 stocks", text.align_right)

    // ══ HEADER ROW (HB+1) : BUY / SELL progress bar ══
    int    nG     = na(buyPct) ? 0 : math.max(0, math.min(COLS, math.round(buyPct / 100 * COLS)))
    string barTip = na(buyPct) ? "No data" : "Buy " + str.tostring(buyPct, "0.0") + "%  |  Sell " + str.tostring(sellPct, "0.0") + "%"
    if na(buyPct)
        f_cell(tbl, 0, HB + 1, "Waiting for data…", C_ROW2, C_MUTED, w, barH, sz, ff, barTip)
    else
        color bgB = dBuy > 0 ? f_flashBg(flashOn, tBuy, cSkyTint, cSky) : cSky
        color bgS = dBuy < 0 ? f_flashBg(flashOn, tBuy, cRedTint, cRed) : cRed
        if nG > 0
            f_cell(tbl, 0, HB + 1, nG >= 3 ? "▲  BUY VOLUME   " + str.tostring(buyPct, "0.0") + "%" : "", bgB, color.white, w, barH, sz, ff, barTip, text.align_left)
        if nG < COLS
            f_cell(tbl, nG, HB + 1, COLS - nG >= 3 ? str.tostring(sellPct, "0.0") + "%   SELL VOLUME  ▼" : "", bgS, color.white, w, barH, sz, ff, barTip, text.align_right)

    // ══ HEADER ROW (HB+2) : buy turnover | bias | sell turnover ══
    string biasTxt = na(buyPct) ? "■  NO DATA" : buyPct >= biasHi ? "▲  BULLISH BIAS" : buyPct <= biasLo ? "▼  BEARISH BIAS" : "■  NEUTRAL"
    color  biasBg  = na(buyPct) ? cWhite : buyPct >= 50 ? f_mix(cWhite, cSkyTint, (buyPct - 50) / 15) : f_mix(cWhite, cRedTint, (50 - buyPct) / 15)
    f_cell(tbl, 0, HB + 2, "Buy Turnover  ₹ " + (totT > 0 ? str.tostring(buyT / 1e7, "#,##0") + " Cr" : "—"), cWhite, cSky, w, h, sz, ff, "Estimated buy-side turnover", text.align_left)
    f_cell(tbl, 8, HB + 2, biasTxt + "   ·   Total ₹ " + (totT > 0 ? str.tostring(totT / 1e7, "#,##0") + " Cr" : "—"), biasBg, cNavy, w, h, sz, ff, "Turnover ≈ Σ(volume × LTP)")
    f_cell(tbl, 15, HB + 2, "₹ " + (totT > 0 ? str.tostring(sellT / 1e7, "#,##0") + " Cr" : "—") + "  Sell Turnover", cWhite, cRed, w, h, sz, ff, "Estimated sell-side turnover", text.align_right)

    f_cell(tbl, 0, HB + 3, "", C_GUTTER, C_GUTTER, w, gapH, sz, ff)

    // ══ STOCK GRID : 3 rows × 11 stocks ══
    for g = 0 to GRP - 1
        int base = SB + g * 4
        for k = 0 to PER - 1
            int    i    = g * PER + k
            int    col  = k * 2
            float  c    = aC.get(i)
            float  chg  = chgA.get(i)
            float  vchg = vchgA.get(i)
            float  v    = aV.get(i)
            string sym  = SYMS.get(i)
            string nm   = nameMode == "Ticker" ? str.replace(sym, "NSE:", "") : NAMES.get(i)
            string tip  = sym + (na(c) ? "\nNo data" : "\nLTP: " + str.tostring(c, "#,##0.00") + "\nPrev Close: " + str.tostring(aPC.get(i), "#,##0.00") + "\nHigh / Low: " + str.tostring(aH.get(i), "#,##0.00") + " / " + str.tostring(aL.get(i), "#,##0.00") + "\nVolume: " + f_vol(v) + "\nCompare Vol: " + f_vol(aVA.get(i)))

            color dirCol = na(chg) ? C_MUTED : chg > 0 ? cSky : chg < 0 ? cRed : C_MUTED

            // name (soft tint by % change)
            f_cell(tbl, col, base, f_arrow(chg) + "  " + nm, f_heat(chg, heatMax), cNavy, w, h, sz, ff, tip)

            // price | % change  (soft flash on tick)
            color pBg = f_flashBg(flashOn, fTimeP.get(i), fDirP.get(i) > 0 ? C_FLASH_U : C_FLASH_D, cWhite)
            f_cell(tbl, col,     base + 1, na(c) ? "—" : str.tostring(c, "#,##0.00"), pBg, cNavy, w, h, sz, ff, tip, text.align_right)
            f_cell(tbl, col + 1, base + 1, f_pct(chg, "0.00"), pBg, dirCol, w, h, sz, ff, tip)

            // volume | % vs comparison
            color vBg   = f_flashBg(flashVol, fTimeV.get(i), C_FLASH_V, C_ROW2)
            color vcCol = na(vchg) ? C_MUTED : vchg >= 0 ? cSky : cRed
            f_cell(tbl, col,     base + 2, f_vol(v), vBg, C_MUTED, w, h, sz, ff, tip, text.align_right)
            f_cell(tbl, col + 1, base + 2, "Vol " + f_pct(vchg, "0"), vBg, vcCol, w, h, sz, ff, tip)

        if g < GRP - 1
            f_cell(tbl, 0, base + 3, "", C_GUTTER, C_GUTTER, w, gapH, sz, ff)

    // ══ MERGES (done last, on the freshly built table) ══
    for i = 0 to NI - 1
        int st  = ISTART.get(i)
        int sp  = ISPAN.get(i)
        int lsp = sp >= 4 ? 2 : 1
        tbl.merge_cells(st, 0, st + sp - 1, 0)                 // index name
        if lsp > 1
            tbl.merge_cells(st, 1, st + lsp - 1, 1)            // LTP
        tbl.merge_cells(st + lsp, 1, st + sp - 1, 1)           // change
    tbl.merge_cells(0, 2, COLS - 1, 2)                         // gap

    tbl.merge_cells(0, HB, 7, HB)
    tbl.merge_cells(8, HB, 14, HB)
    tbl.merge_cells(15, HB, COLS - 1, HB)
    if na(buyPct)
        tbl.merge_cells(0, HB + 1, COLS - 1, HB + 1)
    else
        if nG > 1
            tbl.merge_cells(0, HB + 1, nG - 1, HB + 1)         // BUY block
        if COLS - nG > 1
            tbl.merge_cells(nG, HB + 1, COLS - 1, HB + 1)      // SELL block
    tbl.merge_cells(0, HB + 2, 7, HB + 2)
    tbl.merge_cells(8, HB + 2, 14, HB + 2)
    tbl.merge_cells(15, HB + 2, COLS - 1, HB + 2)
    tbl.merge_cells(0, HB + 3, COLS - 1, HB + 3)               // gap

    for g = 0 to GRP - 1
        int base = SB + g * 4
        for k = 0 to PER - 1
            tbl.merge_cells(k * 2, base, k * 2 + 1, base)      // stock name
        if g < GRP - 1
            tbl.merge_cells(0, base + 3, COLS - 1, base + 3)
````
