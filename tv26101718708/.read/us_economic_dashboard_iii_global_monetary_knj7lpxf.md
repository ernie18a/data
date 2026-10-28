# US Economic Dashboard III - Global & Monetary

- url: https://www.tradingview.com/script/kNJ7lPxF-US-Economic-Dashboard-III-Global-Monetary/
- type: indicator
- pine_id: PUB;54fa599300694120b6507816d010ad5c
- version: 1.0

## Description

[b]US Economic Dashboard III — Global & Monetary[/b]
A comprehensive macro intelligence panel displaying 40 critical economic indicators covering money supply, fiscal policy, labor markets, regional manufacturing, inflation measures, global central bank policy, foreign exchange, and commodities — designed as the third tier of a layered macro framework, complementing Dashboards I (core indicators) and II (extended detail) with zero overlap.

[b]Overview[/b]
This dashboard captures the monetary plumbing, global policy context, and cross-asset signals that drive US and international markets. Where Dashboard I covers the headline releases every trader watches and Dashboard II drills into sub-components and regional detail, Dashboard III zooms out to the global and monetary layer — showing how US conditions interact with Europe, Asia, and commodity markets, alongside the bank lending, Treasury operations, and liquidity flows that underpin the entire financial system.

[b]Categories Covered[/b]
💵 [i]Money & Banking [/i]— M1 supply, M2 velocity, total bank loans, C&I lending, and real estate loan books. These track the actual transmission of monetary policy through the banking system.
🏛[i] Fiscal Detail[/i] — Total public debt, federal outlays, receipts, interest expense, and annual deficit. The fiscal picture matters more than ever given debt-service dynamics.
👷[i] Labor Extended[/i] — U-6 underemployment, employment-to-population ratio, average hourly earnings MoM, Challenger job cuts, and average weekly hours. The deeper labor market texture behind the headline unemployment rate.
🏭 [i]Regional Manufacturing Surveys[/i] — Dallas, Richmond, and Kansas City Fed manufacturing surveys plus ISM Manufacturing New Orders and Prices Paid. Leading signals that often move ahead of the national ISM print.
🔬[i] Inflation Nuance[/i] — 5Y breakevens, Atlanta Fed Sticky CPI, Dallas Fed Trimmed Mean PCE, Cleveland Fed Median CPI, and export prices. Alternative inflation gauges that strip out noise and capture underlying trend.
🌍 [i]Global Inflation & Policy[/i] — China, Eurozone, and UK CPI alongside ECB and BoJ policy rates. Essential context for FX, commodities, and cross-border capital flows.
💱 [i]FX & International Rates[/i] — EUR/USD, USD/JPY, USD/CNH, German 10Y Bund, and Japan 10Y JGB. The key pairs and sovereign yields that define global risk appetite and dollar dynamics.
⛏ [i]Commodities[/i] — Gold, silver, copper, natural gas, and US gasoline. Real-economy price signals and inflation pressure gauges.

[b]Features[/b]
	•	Two-panel layout with clean dividers, matching the visual design of Dashboards I and II for consistent scanning across all three
	•	Color-coded status cells — Healthy (green), Caution (yellow), Stress (red), N/A (gray) — with thresholds tuned for each indicator’s natural range
	•	Directional change arrows (▲ ▼) that color based on whether the move is favorable given the indicator’s context (e.g., falling inflation toward target shows green even though the value dropped)
	•	Three evaluation modes per indicator: MODE_UP (higher is better), MODE_DOWN (lower is better), MODE_RANGE (optimal zone, deviations in either direction flagged)
	•	Adaptive formatting handling 12 different unit types: percentages, thousands, millions, billions, trillions, FX rates, and raw indices
	•	Category toggles — disable any of the 8 sections individually to declutter the view
	•	Position control — six placement options, defaults to Bottom Right to coexist with Dashboards I (Top Right) and II (Top Left)
	•	Three text size options — Tiny, Small, Normal
	•	Last-bar rendering only — zero impact on chart performance
Use Cases
	•	Catch global disinflation or reflation trends before they show up in US data
	•	Monitor bank lending conditions and liquidity for early credit cycle turns
	•	Watch fiscal sustainability metrics as debt-service costs grow
	•	Cross-reference regional Fed surveys to anticipate ISM direction
	•	Track alternative inflation measures (Sticky, Trimmed Mean, Median) for signal separation from headline noise
	•	Use the commodity complex and FX pairs as real-time cross-asset confirmation

[b]Data Sources[/b]
All data pulled directly from TradingView’s ECONOMICS, FRED (St. Louis Fed), FX, COMEX, and TVC feeds via request.security() with lookahead_on for point-in-time accuracy. Uses 40 security calls — the maximum allowed per indicator, leaving no room for padding but maximizing coverage density.

## Source Code

````pine
//@version=6
indicator("US Economic Dashboard III — Global & Monetary", overlay = true)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grp_c = "Category Toggles"
show_mon = input.bool(true, "Money & Banking",       group = grp_c)
show_fis = input.bool(true, "Fiscal Detail",         group = grp_c)
show_lab = input.bool(true, "Labor Extended",        group = grp_c)
show_reg = input.bool(true, "Regional Mfg Surveys",  group = grp_c)
show_inf = input.bool(true, "Inflation Nuance",      group = grp_c)
show_int = input.bool(true, "Global Inflation/Policy", group = grp_c)
show_fx  = input.bool(true, "FX & Intl Rates",       group = grp_c)
show_com = input.bool(true, "Commodities",           group = grp_c)

grp_d = "Display"
i_pos  = input.string("Bottom Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group = grp_d)
i_size = input.string("Small", "Text Size", options = ["Tiny","Small","Normal"], group = grp_d)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
var C_TITLE   = #1a1a2e
var C_CAT     = #16213e
var C_ROW1    = #0f0f23
var C_ROW2    = #131328
var C_SPACER  = #0a0a18
var C_DIV     = #0d0d1f
var C_GREEN   = #00c853
var C_YELLOW  = #ffd600
var C_RED     = #ff1744
var C_GRAY    = #78909c
var C_TXT     = #e0e0e0
var C_TXT_D   = #9e9e9e
var C_WHT     = #ffffff

FMT_PCT = 0
FMT_K   = 1
FMT_MFK = 2
FMT_M   = 3
FMT_IDX = 4
FMT_BFM = 5
FMT_USD = 6
FMT_TFB = 7
FMT_B   = 8
FMT_TFM = 9
FMT_FX  = 10   // 4-decimal FX rate
FMT_RAW = 11

MODE_UP    = 0
MODE_DOWN  = 1
MODE_RANGE = 2

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
f_pos() =>
    switch i_pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        => position.middle_left

f_sz() =>
    switch i_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        => size.normal

f_fmt(float v, int fmt) =>
    if na(v)
        "N/A"
    else
        switch fmt
            FMT_PCT => str.tostring(v, "#.##") + "%"
            FMT_K   => str.tostring(v, "#.#") + "K"
            FMT_MFK => str.tostring(v / 1000, "#.##") + "M"
            FMT_M   => str.tostring(v, "#.##") + "M"
            FMT_IDX => str.tostring(v, "#.##")
            FMT_BFM => (v < 0 ? "-$" : "$") + str.tostring(math.abs(v) / 1000, "#.#") + "B"
            FMT_USD => "$" + str.tostring(v, "#.##")
            FMT_TFB => "$" + str.tostring(v / 1000, "#.##") + "T"
            FMT_B   => (v < 0 ? "-$" : "$") + str.tostring(math.abs(v), "#.#") + "B"
            FMT_TFM => (v < 0 ? "-$" : "$") + str.tostring(math.abs(v) / 1000000, "#.##") + "T"
            FMT_FX  => str.tostring(v, "#.####")
            FMT_RAW => str.tostring(v, "#.##")
            => str.tostring(v, "#.##")

f_status_clr(float val, float g_lo, float g_hi, float y_lo, float y_hi) =>
    if na(val)
        C_GRAY
    else if val >= g_lo and val <= g_hi
        C_GREEN
    else if val >= y_lo and val <= y_hi
        C_YELLOW
    else
        C_RED

f_status_txt(float val, float g_lo, float g_hi, float y_lo, float y_hi) =>
    if na(val)
        "N/A"
    else if val >= g_lo and val <= g_hi
        "Healthy"
    else if val >= y_lo and val <= y_hi
        "Caution"
    else
        "Stress"

f_chg_clr(float chg, float val, int mode, float g_lo, float g_hi) =>
    if na(chg) or math.abs(chg) < 1e-10
        C_GRAY
    else
        bool good = switch mode
            MODE_UP    => chg > 0
            MODE_DOWN  => chg < 0
            MODE_RANGE =>
                if val > g_hi
                    chg < 0
                else if val < g_lo
                    chg > 0
                else
                    false
            => false
        if math.abs(chg) < 1e-10
            C_GRAY
        else
            good ? C_GREEN : C_RED

f_arrow(float chg) =>
    if na(chg) or math.abs(chg) < 1e-10
        "─"
    else
        chg > 0 ? "▲" : "▼"

f_row_bg(int r) =>
    r % 2 == 0 ? C_ROW1 : C_ROW2

f_cat_row(table tbl, int r, string title, int co) =>
    table.cell(tbl, co + 0, r, " " + title, text_color = C_WHT, bgcolor = C_CAT, text_halign = text.align_left,   text_size = f_sz())
    table.cell(tbl, co + 1, r, "",          text_color = C_WHT, bgcolor = C_CAT, text_halign = text.align_right,  text_size = f_sz())
    table.cell(tbl, co + 2, r, "",          text_color = C_WHT, bgcolor = C_CAT, text_halign = text.align_right,  text_size = f_sz())
    table.cell(tbl, co + 3, r, "",          text_color = C_WHT, bgcolor = C_CAT, text_halign = text.align_center, text_size = f_sz())
    table.cell(tbl, co + 4, r, "",          text_color = C_WHT, bgcolor = C_CAT, text_halign = text.align_center, text_size = f_sz())
    table.merge_cells(tbl, co + 0, r, co + 4, r)
    r + 1

f_data_row(table tbl, int r, string name, float val, float prev, string freq, int fmt, float g_lo, float g_hi, float y_lo, float y_hi, int mode, int co) =>
    float chg     = not na(val) and not na(prev) ? val - prev : na
    color bg      = f_row_bg(r)
    color sc      = f_status_clr(val, g_lo, g_hi, y_lo, y_hi)
    string st     = f_status_txt(val, g_lo, g_hi, y_lo, y_hi)
    color ac      = f_chg_clr(chg, val, mode, g_lo, g_hi)
    string arrow  = f_arrow(chg)
    string chg_s  = na(chg) ? "N/A" : arrow + " " + f_fmt(math.abs(chg), fmt)
    table.cell(tbl, co + 0, r, " " + name,      text_color = C_TXT,   bgcolor = bg, text_halign = text.align_left,   text_size = f_sz())
    table.cell(tbl, co + 1, r, f_fmt(val, fmt), text_color = C_TXT,   bgcolor = bg, text_halign = text.align_right,  text_size = f_sz())
    table.cell(tbl, co + 2, r, chg_s,           text_color = ac,      bgcolor = bg, text_halign = text.align_right,  text_size = f_sz())
    table.cell(tbl, co + 3, r, freq,            text_color = C_TXT_D, bgcolor = bg, text_halign = text.align_center, text_size = f_sz())
    table.cell(tbl, co + 4, r, st,              text_color = C_WHT,   bgcolor = sc, text_halign = text.align_center, text_size = f_sz())
    r + 1

f_spacer_row(table tbl, int r, int co) =>
    for c = 0 to 4
        table.cell(tbl, co + c, r, "", bgcolor = C_SPACER, text_size = size.tiny)
    r + 1

f_empty_row(table tbl, int r, int co) =>
    for c = 0 to 4
        table.cell(tbl, co + c, r, "", bgcolor = C_ROW1, text_size = size.tiny)
    r + 1

// ═══════════════════════════════════════════════════════════════
//  SECURITY CALLS  (40 calls — complementary to Dashboards I + II)
// ═══════════════════════════════════════════════════════════════
// ── Money & Banking (5)
[v01, p01] = request.security("FRED:M1SL",             "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // M1 Money Supply ($B)
[v02, p02] = request.security("FRED:M2V",              "3M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // M2 Velocity
[v03, p03] = request.security("FRED:TOTLL",            "W",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Total Loans & Leases ($B)
[v04, p04] = request.security("FRED:BUSLOANS",         "W",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // C&I Loans ($B)
[v05, p05] = request.security("FRED:REALLN",           "W",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Real Estate Loans ($B)

// ── Fiscal Detail (5)
[v06, p06] = request.security("FRED:GFDEBTN",          "3M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Total Public Debt ($M)
[v07, p07] = request.security("FRED:FGEXPND",          "3M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Federal Expenditures ($B)
[v08, p08] = request.security("FRED:MTSR133FMS",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Federal Receipts ($M, monthly)
[v09, p09] = request.security("FRED:A091RC1Q027SBEA",  "3M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Fed Interest Expense ($B)
[v10, p10] = request.security("FRED:FYFSD",            "12M",[close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Annual Fed Surplus/Deficit ($M)

// ── Labor Extended (5)
[v11, p11] = request.security("FRED:U6RATE",           "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // U-6 Unemployment
[v12, p12] = request.security("FRED:EMRATIO",          "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Emp-Pop Ratio
[v13, p13] = request.security("ECONOMICS:USAHE",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // AHE MoM
[v14, p14] = request.security("ECONOMICS:USCJC",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Challenger Job Cuts
[v15, p15] = request.security("ECONOMICS:USAWH",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Avg Weekly Hours

// ── Regional Mfg Surveys (5)
[v16, p16] = request.security("ECONOMICS:USDFMI",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Dallas Fed Mfg
[v17, p17] = request.security("ECONOMICS:USRFMI",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Richmond Fed Mfg
[v18, p18] = request.security("ECONOMICS:USKFMI",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Kansas Fed Mfg
[v19, p19] = request.security("ECONOMICS:USMNO",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // ISM Mfg New Orders
[v20, p20] = request.security("ECONOMICS:USMPR",       "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // ISM Mfg Prices Paid

// ── Inflation Nuance (5)
[v21, p21] = request.security("FRED:T5YIE",                   "D", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // 5Y Breakeven
[v22, p22] = request.security("FRED:CORESTICKM159SFRBATL",    "M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Atlanta Fed Sticky CPI YoY
[v23, p23] = request.security("FRED:PCETRIM12M159SFRBDAL",    "M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Dallas Fed Trimmed Mean PCE YoY
[v24, p24] = request.security("FRED:MEDCPIM158SFRBCLE",       "M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Cleveland Fed Median CPI
[v25, p25] = request.security("ECONOMICS:USEPYY",             "M", [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Export Prices YoY

// ── Global Inflation / Policy (5)
[v26, p26] = request.security("ECONOMICS:CNIRYY",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // China CPI YoY
[v27, p27] = request.security("ECONOMICS:EUIRYY",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Eurozone CPI YoY
[v28, p28] = request.security("ECONOMICS:GBIRYY",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // UK CPI YoY
[v29, p29] = request.security("ECONOMICS:EUINTR",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // ECB Rate
[v30, p30] = request.security("ECONOMICS:JPINTR",      "M",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // BoJ Rate

// ── FX & International Rates (5)
[v31, p31] = request.security("FX:EURUSD",             "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // EUR/USD
[v32, p32] = request.security("FX:USDJPY",             "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // USD/JPY
[v33, p33] = request.security("FX:USDCNH",             "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // USD/CNH
[v34, p34] = request.security("TVC:DE10Y",             "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // German 10Y Bund
[v35, p35] = request.security("TVC:JP10Y",             "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Japan 10Y JGB

// ── Commodities (5)
[v36, p36] = request.security("TVC:GOLD",              "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Gold
[v37, p37] = request.security("TVC:SILVER",            "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Silver
[v38, p38] = request.security("COMEX:HG1!",            "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Copper Futures
[v39, p39] = request.security("FRED:DHHNGSP",          "D",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // Henry Hub Nat Gas
[v40, p40] = request.security("FRED:GASREGW",          "W",  [close, close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on)  // US Gasoline Price

// ═══════════════════════════════════════════════════════════════
//  BUILD TWO-PANEL TABLE
// ═══════════════════════════════════════════════════════════════
if barstate.islast
    var tbl = table.new(f_pos(), 11, 34, border_width = 0, frame_width = 2, frame_color = #333366)

    int LO = 0
    int RO = 6
    sz = f_sz()

    // Headers
    table.cell(tbl, 0, 0, "  INDICATOR",  text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_left,   text_size = sz)
    table.cell(tbl, 1, 0, "VALUE ",       text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_right,  text_size = sz)
    table.cell(tbl, 2, 0, "Δ CHG ",       text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_right,  text_size = sz)
    table.cell(tbl, 3, 0, "FREQ",         text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_center, text_size = sz)
    table.cell(tbl, 4, 0, "STATUS",       text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_center, text_size = sz)
    table.cell(tbl, 5, 0, "",             bgcolor = C_DIV, text_size = size.tiny)
    table.cell(tbl, 6,  0, "  INDICATOR", text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_left,   text_size = sz)
    table.cell(tbl, 7,  0, "VALUE ",      text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_right,  text_size = sz)
    table.cell(tbl, 8,  0, "Δ CHG ",      text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_right,  text_size = sz)
    table.cell(tbl, 9,  0, "FREQ",        text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_center, text_size = sz)
    table.cell(tbl, 10, 0, "STATUS",      text_color = C_TXT_D, bgcolor = C_TITLE, text_halign = text.align_center, text_size = sz)

    // ═══════════════════════════════════════════════════════
    //  LEFT PANEL: Money → Fiscal → Labor → Regional Mfg
    // ═══════════════════════════════════════════════════════
    int L = 1

    if show_mon
        L := f_cat_row(tbl, L, "💵 MONEY & BANKING", LO)
        L := f_data_row(tbl, L, "M1 Money Supply",     v01, p01, "Monthly", FMT_TFB, 0,    99999, 0,     99999, MODE_UP,    LO)
        L := f_data_row(tbl, L, "M2 Velocity",         v02, p02, "Qtrly",   FMT_IDX, 1.5,  999,   1.2,   999,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "Total Bank Loans",    v03, p03, "Weekly",  FMT_TFB, 0,    99999, 0,     99999, MODE_UP,    LO)
        L := f_data_row(tbl, L, "C&I Loans",           v04, p04, "Weekly",  FMT_TFB, 0,    99999, 0,     99999, MODE_UP,    LO)
        L := f_data_row(tbl, L, "Real Estate Loans",   v05, p05, "Weekly",  FMT_TFB, 0,    99999, 0,     99999, MODE_UP,    LO)
        L := f_spacer_row(tbl, L, LO)

    if show_fis
        L := f_cat_row(tbl, L, "🏛 FISCAL DETAIL", LO)
        L := f_data_row(tbl, L, "Total Public Debt",   v06, p06, "Qtrly",   FMT_TFM, 0,    99999999, 0,   99999999, MODE_DOWN, LO)
        L := f_data_row(tbl, L, "Federal Outlays",     v07, p07, "Qtrly",   FMT_TFB, 0,    99999, 0,     99999, MODE_DOWN,  LO)
        L := f_data_row(tbl, L, "Federal Receipts",    v08, p08, "Monthly", FMT_BFM, 300000, 9999999, 200000, 9999999, MODE_UP, LO)
        L := f_data_row(tbl, L, "Fed Interest Expense",v09, p09, "Qtrly",   FMT_TFB, 0,    500,   0,     800,   MODE_DOWN,  LO)
        L := f_data_row(tbl, L, "Annual Deficit ($M)", v10, p10, "Yearly",  FMT_BFM, -500000, 0,  -1500000, 0,  MODE_UP,    LO)
        L := f_spacer_row(tbl, L, LO)

    if show_lab
        L := f_cat_row(tbl, L, "👷 LABOR EXTENDED", LO)
        L := f_data_row(tbl, L, "U-6 Unemployment",    v11, p11, "Monthly", FMT_PCT, 0,    7.0,   0,     9.0,   MODE_DOWN,  LO)
        L := f_data_row(tbl, L, "Emp-Pop Ratio",       v12, p12, "Monthly", FMT_PCT, 60,   100,   58,    100,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "Avg Hourly Earn MoM", v13, p13, "Monthly", FMT_PCT, 0.2,  0.4,   0.1,   0.6,   MODE_RANGE, LO)
        L := f_data_row(tbl, L, "Challenger Job Cuts", v14, p14, "Monthly", FMT_K,   0,    50,    0,     80,    MODE_DOWN,  LO)
        L := f_data_row(tbl, L, "Avg Weekly Hours",    v15, p15, "Monthly", FMT_IDX, 34.3, 35.0,  34.0,  35.5,  MODE_RANGE, LO)
        L := f_spacer_row(tbl, L, LO)

    if show_reg
        L := f_cat_row(tbl, L, "🏭 REGIONAL MFG SURVEYS", LO)
        L := f_data_row(tbl, L, "Dallas Fed Mfg",      v16, p16, "Monthly", FMT_IDX, 0,    999,   -10,   999,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "Richmond Fed Mfg",    v17, p17, "Monthly", FMT_IDX, 0,    999,   -10,   999,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "Kansas Fed Mfg",      v18, p18, "Monthly", FMT_IDX, 0,    999,   -10,   999,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "ISM Mfg New Orders",  v19, p19, "Monthly", FMT_IDX, 52,   999,   48,    999,   MODE_UP,    LO)
        L := f_data_row(tbl, L, "ISM Mfg Prices Paid", v20, p20, "Monthly", FMT_IDX, 40,   55,    30,    65,    MODE_RANGE, LO)

    // ═══════════════════════════════════════════════════════
    //  RIGHT PANEL: Inflation Nuance → Global → FX → Commods
    // ═══════════════════════════════════════════════════════
    int R = 1

    if show_inf
        R := f_cat_row(tbl, R, "🔬 INFLATION NUANCE", RO)
        R := f_data_row(tbl, R, "5Y Breakeven",        v21, p21, "Daily",   FMT_PCT, 1.8,  2.4,   1.5,   3.0,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Sticky CPI YoY",      v22, p22, "Monthly", FMT_PCT, 1.5,  2.5,   0.5,   3.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Trimmed PCE YoY",     v23, p23, "Monthly", FMT_PCT, 1.5,  2.5,   0.5,   3.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Median CPI YoY",      v24, p24, "Monthly", FMT_PCT, 1.5,  2.5,   0.5,   3.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Export Prices YoY",   v25, p25, "Monthly", FMT_PCT, -1.0, 3.0,   -3.0,  5.0,   MODE_RANGE, RO)
        R := f_spacer_row(tbl, R, RO)

    if show_int
        R := f_cat_row(tbl, R, "🌍 GLOBAL INFLATION & POLICY", RO)
        R := f_data_row(tbl, R, "China CPI YoY",       v26, p26, "Monthly", FMT_PCT, 1.0,  3.0,   -1.0,  4.0,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Eurozone CPI YoY",    v27, p27, "Monthly", FMT_PCT, 1.5,  2.5,   0.5,   3.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "UK CPI YoY",          v28, p28, "Monthly", FMT_PCT, 1.5,  2.5,   0.5,   3.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "ECB Rate",            v29, p29, "Monthly", FMT_PCT, 0,    3.0,   0,     4.5,   MODE_DOWN,  RO)
        R := f_data_row(tbl, R, "BoJ Rate",            v30, p30, "Monthly", FMT_PCT, 0,    1.0,   -0.5,  2.0,   MODE_RANGE, RO)
        R := f_spacer_row(tbl, R, RO)

    if show_fx
        R := f_cat_row(tbl, R, "💱 FX & INTL RATES", RO)
        R := f_data_row(tbl, R, "EUR/USD",             v31, p31, "Daily",   FMT_FX,  1.05, 1.20,  0.95,  1.30,  MODE_RANGE, RO)
        R := f_data_row(tbl, R, "USD/JPY",             v32, p32, "Daily",   FMT_IDX, 110,  150,   100,   160,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "USD/CNH",             v33, p33, "Daily",   FMT_IDX, 6.5,  7.2,   6.0,   7.5,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "German 10Y Bund",     v34, p34, "Daily",   FMT_PCT, 1.0,  3.5,   0.0,   5.0,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "Japan 10Y JGB",       v35, p35, "Daily",   FMT_PCT, 0.0,  1.5,   -0.5,  2.5,   MODE_RANGE, RO)
        R := f_spacer_row(tbl, R, RO)

    if show_com
        R := f_cat_row(tbl, R, "⛏ COMMODITIES", RO)
        R := f_data_row(tbl, R, "Gold",                v36, p36, "Daily",   FMT_USD, 1800, 3500,  1500,  5000,  MODE_UP,    RO)
        R := f_data_row(tbl, R, "Silver",              v37, p37, "Daily",   FMT_USD, 20,   40,    15,    60,    MODE_UP,    RO)
        R := f_data_row(tbl, R, "Copper",              v38, p38, "Daily",   FMT_USD, 3.5,  5.0,   2.5,   6.5,   MODE_UP,    RO)
        R := f_data_row(tbl, R, "Nat Gas (HH)",        v39, p39, "Daily",   FMT_USD, 2.0,  4.5,   1.0,   8.0,   MODE_RANGE, RO)
        R := f_data_row(tbl, R, "US Gasoline",         v40, p40, "Weekly",  FMT_USD, 2.50, 3.75,  2.00,  4.50,  MODE_RANGE, RO)

    // ── Fill divider column + pad shorter panel ──
    int maxR = math.max(L, R)
    for i = 0 to maxR - 1
        table.cell(tbl, 5, i, "", bgcolor = i == 0 ? C_TITLE : C_DIV, text_size = size.tiny)
    if L < maxR
        for i = L to maxR - 1
            f_empty_row(tbl, i, LO)
    if R < maxR
        for i = R to maxR - 1
            f_empty_row(tbl, i, RO)
````
