# SectorFlow Clean - Leaders Laggards + Heatmap

- url: https://www.tradingview.com/script/ir0EEIcd-SectorFlow-Clean-Leaders-Laggards-Heatmap/
- type: indicator
- pine_id: PUB;8fa6a19f3c2f4fff9019f5ab1674e0d7
- version: 2.0

## Description

Default setting:
Line metric: Relative to SPY
Line display mode: Leaders + laggards only
Show top N leaders: 3
Show bottom N laggards: 3
Show compact heatmap table: On

## Source Code

````pine
//@version=6
// =============================================================================
//  SectorFlow  v3  ·  Leaders / Laggards + Flow Heatmap  (multi-universe)
// -----------------------------------------------------------------------------
//  Rebased relative performance vs a benchmark, from a chosen start date.
//  38 selectable tickers in 4 groups (Sectors / Themes / Factor / Custom),
//  exactly like the RRG script - pick a group under Focus and it drives the
//  lines, the ranking, the labels and the sorted table.
//
//  READING IT
//    - 0 line = the benchmark. Above 0 = outperforming since the start date.
//    - Table is sorted: row 1 = today's strongest, bottom row = weakest.
//    - A star on a row = it crossed the 0 line this bar (just flipped).
//
//  TIP: view ONE group at a time. Mixing sectors and themes on one chart is
//  busy and rarely useful - use "Show group" under Focus to switch.
// =============================================================================

indicator(shorttitle = "SectorFlow", title = "SectorFlow v3 · Leaders/Laggards + Heatmap", overlay = false, max_labels_count = 60, dynamic_requests = true)

// ---------------------------------------------------------------- settings ---
gC = "Calculation"
calcTf     = input.timeframe("D", "Calculation timeframe", group = gC, tooltip = "Symbols are sampled at this timeframe. Daily is the natural choice.", display = display.none)
benchSym   = input.symbol("AMEX:SPY", "Benchmark", group = gC, tooltip = "0 line = this symbol. Try RSP (equal weight) to strip out mega-cap distortion.", display = display.none)
lineMetric = input.string("Relative to benchmark", "Metric", options = ["Relative to benchmark", "Base return"], group = gC, tooltip = "Relative = true ratio return vs the benchmark (correct at any size of move).\nBase = raw rebased return since the start date.", display = display.none)

gR = "Rebase window"
rebaseMode = input.string("Rolling months back", "Rebase from", options = ["Rolling months back", "Year to date", "Manual date"], group = gR, tooltip = "Rolling = a moving window that always ends today (default 3 months).\nYear to date = Jan 1 of this year.\nManual = the exact date below.", display = display.none)
monthsBack = input.int(3, "Months back (rolling)", minval = 1, maxval = 60, group = gR, display = display.none)
manualStart= input.time(timestamp("01 Jan 2026 00:00 +0000"), "Manual date", group = gR)
_tm = year(timenow) * 12 + month(timenow) - 1 - monthsBack
_sy = _tm / 12
_sm = _tm % 12 + 1
_sd = math.min(dayofmonth(timenow), 28)
startDate = rebaseMode == "Year to date" ? timestamp(year(timenow), 1, 1, 0, 0) : rebaseMode == "Manual date" ? manualStart : timestamp(_sy, _sm, _sd, 0, 0)

gF = "Focus"
groupShow  = input.string("Sectors only", "Show group", options = ["All", "Sectors only", "Themes only", "Factor & Style only", "Custom only"], group = gF, tooltip = "Which universe to display. View one group at a time for a readable chart.")

gL = "Lines"
lineMode   = input.string("All (in group)", "Show lines", options = ["All (in group)", "Leaders + laggards only", "Heatmap only (no lines)"], group = gL, display = display.none)
topN       = input.int(3, "Top leaders", minval = 1, maxval = 6, group = gL, display = display.none)
bottomN    = input.int(3, "Bottom laggards", minval = 1, maxval = 6, group = gL, display = display.none)
showZero   = input.bool(true, "Show 0 / benchmark line", group = gL, display = display.none)
showLabels = input.bool(true, "Right-side labels", group = gL, display = display.none)
labelOff   = input.int(5, "Label offset", minval = 1, group = gL, display = display.none)
labelGap   = input.int(5, "Label spacing %", minval = 0, maxval = 30, group = gL, tooltip = "Spreads the right-side labels apart so they stop overlapping. The number stays the true value; only its vertical position is nudged. 0 = off.", display = display.none)

gH = "Heatmap"
showTable  = input.bool(true, "Show sorted table", group = gH, display = display.none)
showBanner = input.bool(true, "Show regime banner", group = gH, display = display.none)
tblPos     = input.string("Right", "Table position", options = ["Right", "Left"], group = gH, display = display.none)
tblSize    = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = gH, display = display.none)

gA = "Alerts"
alLeader   = input.bool(false, "Alert on new leading symbol", group = gA, display = display.none)
alBreadth  = input.bool(false, "Alert on breadth flip", group = gA, display = display.none)

// ---------------------------------------------------------------- universe ---
// Enable a symbol, edit its ticker, or add your own in the Custom group.

gS = "Universe · Sectors"
e01 = input.bool(true, "", inline = "u1", group = gS, display = display.none), s01 = input.symbol("XLK",   "", inline = "u1", group = gS, display = display.none)
e02 = input.bool(true, "", inline = "u2", group = gS, display = display.none), s02 = input.symbol("XLF",   "", inline = "u2", group = gS, display = display.none)
e03 = input.bool(true, "", inline = "u3", group = gS, display = display.none), s03 = input.symbol("XLI",   "", inline = "u3", group = gS, display = display.none)
e04 = input.bool(true, "", inline = "u4", group = gS, display = display.none), s04 = input.symbol("XLY",   "", inline = "u4", group = gS, display = display.none)
e05 = input.bool(true, "", inline = "u5", group = gS, display = display.none), s05 = input.symbol("XLC",   "", inline = "u5", group = gS, display = display.none)
e06 = input.bool(true, "", inline = "u6", group = gS, display = display.none), s06 = input.symbol("XLB",   "", inline = "u6", group = gS, display = display.none)
e07 = input.bool(true, "", inline = "u7", group = gS, display = display.none), s07 = input.symbol("XLE",   "", inline = "u7", group = gS, display = display.none)
e08 = input.bool(true, "", inline = "u8", group = gS, display = display.none), s08 = input.symbol("XLRE",  "", inline = "u8", group = gS, display = display.none)
e09 = input.bool(true, "", inline = "u9", group = gS, display = display.none), s09 = input.symbol("XLV",   "", inline = "u9", group = gS, display = display.none)
e10 = input.bool(true, "", inline = "u10", group = gS, display = display.none), s10 = input.symbol("XLU",   "", inline = "u10", group = gS, display = display.none)
e11 = input.bool(true, "", inline = "u11", group = gS, display = display.none), s11 = input.symbol("XLP",   "", inline = "u11", group = gS, display = display.none)

gT = "Universe · Themes"
e12 = input.bool(false, "", inline = "u12", group = gT, display = display.none), s12 = input.symbol("SMH",   "", inline = "u12", group = gT, display = display.none)
e13 = input.bool(false, "", inline = "u13", group = gT, display = display.none), s13 = input.symbol("IGV",   "", inline = "u13", group = gT, display = display.none)
e14 = input.bool(false, "", inline = "u14", group = gT, display = display.none), s14 = input.symbol("AIQ",   "", inline = "u14", group = gT, display = display.none)
e15 = input.bool(false, "", inline = "u15", group = gT, display = display.none), s15 = input.symbol("QTUM",  "", inline = "u15", group = gT, display = display.none)
e16 = input.bool(false, "", inline = "u16", group = gT, display = display.none), s16 = input.symbol("CIBR",  "", inline = "u16", group = gT, display = display.none)
e17 = input.bool(false, "", inline = "u17", group = gT, display = display.none), s17 = input.symbol("BOTZ",  "", inline = "u17", group = gT, display = display.none)
e18 = input.bool(false, "", inline = "u18", group = gT, display = display.none), s18 = input.symbol("ARKX",  "", inline = "u18", group = gT, display = display.none)
e19 = input.bool(false, "", inline = "u19", group = gT, display = display.none), s19 = input.symbol("ITA",   "", inline = "u19", group = gT, display = display.none)
e20 = input.bool(false, "", inline = "u20", group = gT, display = display.none), s20 = input.symbol("URA",   "", inline = "u20", group = gT, display = display.none)
e21 = input.bool(false, "", inline = "u21", group = gT, display = display.none), s21 = input.symbol("NLR",   "", inline = "u21", group = gT, display = display.none)
e22 = input.bool(false, "", inline = "u22", group = gT, display = display.none), s22 = input.symbol("GRID",  "", inline = "u22", group = gT, display = display.none)
e23 = input.bool(false, "", inline = "u23", group = gT, display = display.none), s23 = input.symbol("ICLN",  "", inline = "u23", group = gT, display = display.none)
e24 = input.bool(false, "", inline = "u24", group = gT, display = display.none), s24 = input.symbol("XBI",   "", inline = "u24", group = gT, display = display.none)
e25 = input.bool(false, "", inline = "u25", group = gT, display = display.none), s25 = input.symbol("IBIT",  "", inline = "u25", group = gT, display = display.none)
e26 = input.bool(false, "", inline = "u26", group = gT, display = display.none), s26 = input.symbol("PAVE",  "", inline = "u26", group = gT, display = display.none)

gV = "Universe · Factor & Style"
e27 = input.bool(false, "", inline = "u27", group = gV, display = display.none), s27 = input.symbol("RSP",   "", inline = "u27", group = gV, display = display.none)
e28 = input.bool(false, "", inline = "u28", group = gV, display = display.none), s28 = input.symbol("IWM",   "", inline = "u28", group = gV, display = display.none)
e29 = input.bool(false, "", inline = "u29", group = gV, display = display.none), s29 = input.symbol("MTUM",  "", inline = "u29", group = gV, display = display.none)
e30 = input.bool(false, "", inline = "u30", group = gV, display = display.none), s30 = input.symbol("QUAL",  "", inline = "u30", group = gV, display = display.none)
e31 = input.bool(false, "", inline = "u31", group = gV, display = display.none), s31 = input.symbol("VLUE",  "", inline = "u31", group = gV, display = display.none)
e32 = input.bool(false, "", inline = "u32", group = gV, display = display.none), s32 = input.symbol("USMV",  "", inline = "u32", group = gV, display = display.none)

gU = "Universe · Custom"
e33 = input.bool(false, "", inline = "u33", group = gU, display = display.none), s33 = input.symbol("SOXX",  "", inline = "u33", group = gU, display = display.none), c33 = input.string("", "", inline = "u33", group = gU, display = display.none)
e34 = input.bool(false, "", inline = "u34", group = gU, display = display.none), s34 = input.symbol("EWY",   "", inline = "u34", group = gU, display = display.none), c34 = input.string("", "", inline = "u34", group = gU, display = display.none)
e35 = input.bool(false, "", inline = "u35", group = gU, display = display.none), s35 = input.symbol("GDX",   "", inline = "u35", group = gU, display = display.none), c35 = input.string("", "", inline = "u35", group = gU, display = display.none)
e36 = input.bool(false, "", inline = "u36", group = gU, display = display.none), s36 = input.symbol("KRE",   "", inline = "u36", group = gU, display = display.none), c36 = input.string("", "", inline = "u36", group = gU, display = display.none)
e37 = input.bool(false, "", inline = "u37", group = gU, display = display.none), s37 = input.symbol("XOP",   "", inline = "u37", group = gU, display = display.none), c37 = input.string("", "", inline = "u37", group = gU, display = display.none)
e38 = input.bool(false, "", inline = "u38", group = gU, display = display.none), s38 = input.symbol("TAN",   "", inline = "u38", group = gU, display = display.none), c38 = input.string("", "", inline = "u38", group = gU, display = display.none)

enSlot  = array.from(e01, e02, e03, e04, e05, e06, e07, e08, e09, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30, e31, e32, e33, e34, e35, e36, e37, e38)
symSlot = array.from(s01, s02, s03, s04, s05, s06, s07, s08, s09, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36, s37, s38)
custSlot= array.from("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", c33, c34, c35, c36, c37, c38)
grpSlot = array.from(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3)
colArr  = array.from(#f2d043, #4fd97a, #ff9e3d, #c874e8, #ff5c5c, #8b7bf0, #b5773a, #2fd6c3, #f368b0, #a6e05a, #34b5e8, #ff6b35, #4cc9f0, #e56399, #9d4edd, #90be6d, #ffadad, #5390d9, #f9844a, #48cae4, #d4a373, #a3f7bf, #ff8fab, #e0c3fc, #fca311, #6ee7b7, #f2d043, #4fd97a, #ff9e3d, #c874e8, #ff5c5c, #8b7bf0, #b5773a, #2fd6c3, #f368b0, #a6e05a, #34b5e8, #ff6b35)
N = array.size(symSlot)

// ---------------------------------------------------------------- helpers ----
shortName(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, array.size(parts) - 1) : s

longName(t) =>
    switch t
        "XLK" => "Technology"
        "XLF" => "Financials"
        "XLI" => "Industrials"
        "XLY" => "Cons Cyclical"
        "XLC" => "Communication"
        "XLB" => "Materials"
        "XLE" => "Energy"
        "XLRE" => "Real Estate"
        "XLV" => "Healthcare"
        "XLU" => "Utilities"
        "XLP" => "Cons Defensive"
        "SMH" => "Semiconductors"
        "IGV" => "Software"
        "AIQ" => "AI & Big Data"
        "QTUM" => "Quantum"
        "CIBR" => "Cybersecurity"
        "BOTZ" => "Robotics & AI"
        "ARKX" => "Space & Drones"
        "ITA" => "Aero & Defense"
        "URA" => "Uranium"
        "NLR" => "Nuclear"
        "GRID" => "Smart Grid"
        "ICLN" => "Clean Energy"
        "XBI" => "Biotech"
        "IBIT" => "Bitcoin"
        "PAVE" => "Infrastructure"
        "RSP" => "Equal Weight"
        "IWM" => "Small Caps"
        "MTUM" => "Momentum"
        "QUAL" => "Quality"
        "VLUE" => "Value"
        "USMV" => "Min Volatility"
        "SOXX" => "Semis (iShares)"
        "EWY" => "South Korea"
        "GDX" => "Gold Miners"
        "KRE" => "Regional Banks"
        "XOP" => "Oil & Gas E&P"
        "TAN" => "Solar"
        "URNM" => "Uranium Miners"
        "XME" => "Metals & Mining"
        "COPX" => "Copper"
        "LIT" => "Lithium"
        "JETS" => "Airlines"
        "HACK" => "Cybersecurity"
        "IHI" => "Medical Devices"
        "ARKK" => "Innovation"
        "QQQ" => "Nasdaq 100"
        "EEM" => "Emerging Mkts"
        "EFA" => "Developed exUS"
        "EWJ" => "Japan"
        "EWG" => "Germany"
        "EWT" => "Taiwan"
        "FXI" => "China"
        "INDA" => "India"
        "SLV" => "Silver"
        "GLD" => "Gold"
        "TLT" => "20Y Treasury"
        => ""

pctTxt(x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "#.##") + "%"

metricUnit() =>
    lineMetric == "Relative to benchmark" ? " vs bench" : ""

cellCol(x) =>
    na(x) ? color.new(color.gray, 82) : x > 0 ? color.new(#26a65b, 55) : x < 0 ? color.new(#e04350, 55) : color.new(color.gray, 82)

grpOn(g) =>
    switch groupShow
        "Sectors only"        => g == 0
        "Themes only"         => g == 1
        "Factor & Style only" => g == 2
        "Custom only"         => g == 3
        =>                       true

// Unique 1..K rank of element i among the ACTIVE set (1 = highest). Ties broken
// by slot index, so ranks are always a clean permutation - which sorts the table.
rankOf(i, arr) =>
    x = array.get(arr, i)
    r = 999
    if not na(x)
        r := 1
        for j = 0 to N - 1
            if j != i
                o = array.get(arr, j)
                if not na(o) and (o > x or (o == x and j < i))
                    r += 1
    r

// ---------------------------------------------------------------- benchmark --
var float baseBench = na
[pxBench, dayBench] = request.security(benchSym, calcTf, [close, 100.0 * (close / close[1] - 1.0)], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
if na(baseBench) and time >= startDate and not na(pxBench)
    baseBench := pxBench
idxBench = not na(baseBench) and baseBench > 0 ? pxBench / baseBench * 100.0 : na

// ---------------------------------------------------------------- state ------
var array<float> baseArr = array.new<float>(N, na)
var array<int>   signArr = array.new<int>(N, 0)
var array<label> labArr  = array.new<label>(N, na)
var int prevLeader = -1

// ---------------------------------------------------------------- per-bar ----
tickArr  = array.new<string>(N, "")
nameArr  = array.new<string>(N, "")
mArr     = array.new<float>(N, na)
dayArr   = array.new<float>(N, na)
crossArr = array.new<bool>(N, false)
int activeCount = 0

for i = 0 to N - 1
    tk = shortName(array.get(symSlot, i))
    array.set(tickArr, i, tk)
    cn = array.get(custSlot, i)
    ln = longName(tk)
    array.set(nameArr, i, cn != "" ? cn : ln != "" ? ln : tk)

    active = array.get(enSlot, i) and grpOn(array.get(grpSlot, i))
    if active
        [px, day] = request.security(array.get(symSlot, i), calcTf, [close, 100.0 * (close / close[1] - 1.0)], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
        b = array.get(baseArr, i)
        if na(b) and time >= startDate and not na(px)
            b := px
            array.set(baseArr, i, b)
        idx = not na(b) and b > 0 ? px / b * 100.0 : na
        m = lineMetric == "Relative to benchmark" ? (not na(idx) and not na(idxBench) ? (idx / idxBench - 1.0) * 100.0 : na) : (na(idx) ? na : idx - 100.0)
        array.set(mArr, i, m)
        array.set(dayArr, i, day)
        if not na(m)
            activeCount += 1
        s  = na(m) ? 0 : m > 0 ? 1 : m < 0 ? -1 : 0
        ps = array.get(signArr, i)
        array.set(crossArr, i, ps != 0 and s != 0 and s != ps)
        if barstate.isconfirmed and s != 0
            array.set(signArr, i, s)

// ---------------------------------------------------------------- ranks ------
topRank = array.new<int>(N, 999)
for i = 0 to N - 1
    array.set(topRank, i, rankOf(i, mArr))

vis(i) =>
    r = array.get(topRank, i)
    r > N ? false : lineMode == "Heatmap only (no lines)" ? false : lineMode == "All (in group)" ? true : (r <= topN or r > activeCount - bottomN)

// ---------------------------------------------------------------- plots ------
plot(showZero ? 0 : na, "Benchmark / Zero", color = color.new(color.gray, 55), linewidth = 1)

gv(i) => vis(i) ? array.get(mArr, i) : na
plot(gv(0), "1", color = #f2d043, linewidth = 2)
plot(gv(1), "2", color = #4fd97a, linewidth = 2)
plot(gv(2), "3", color = #ff9e3d, linewidth = 2)
plot(gv(3), "4", color = #c874e8, linewidth = 2)
plot(gv(4), "5", color = #ff5c5c, linewidth = 2)
plot(gv(5), "6", color = #8b7bf0, linewidth = 2)
plot(gv(6), "7", color = #b5773a, linewidth = 2)
plot(gv(7), "8", color = #2fd6c3, linewidth = 2)
plot(gv(8), "9", color = #f368b0, linewidth = 2)
plot(gv(9), "10", color = #a6e05a, linewidth = 2)
plot(gv(10), "11", color = #34b5e8, linewidth = 2)
plot(gv(11), "12", color = #ff6b35, linewidth = 2)
plot(gv(12), "13", color = #4cc9f0, linewidth = 2)
plot(gv(13), "14", color = #e56399, linewidth = 2)
plot(gv(14), "15", color = #9d4edd, linewidth = 2)
plot(gv(15), "16", color = #90be6d, linewidth = 2)
plot(gv(16), "17", color = #ffadad, linewidth = 2)
plot(gv(17), "18", color = #5390d9, linewidth = 2)
plot(gv(18), "19", color = #f9844a, linewidth = 2)
plot(gv(19), "20", color = #48cae4, linewidth = 2)
plot(gv(20), "21", color = #d4a373, linewidth = 2)
plot(gv(21), "22", color = #a3f7bf, linewidth = 2)
plot(gv(22), "23", color = #ff8fab, linewidth = 2)
plot(gv(23), "24", color = #e0c3fc, linewidth = 2)
plot(gv(24), "25", color = #fca311, linewidth = 2)
plot(gv(25), "26", color = #6ee7b7, linewidth = 2)
plot(gv(26), "27", color = #f2d043, linewidth = 2)
plot(gv(27), "28", color = #4fd97a, linewidth = 2)
plot(gv(28), "29", color = #ff9e3d, linewidth = 2)
plot(gv(29), "30", color = #c874e8, linewidth = 2)
plot(gv(30), "31", color = #ff5c5c, linewidth = 2)
plot(gv(31), "32", color = #8b7bf0, linewidth = 2)
plot(gv(32), "33", color = #b5773a, linewidth = 2)
plot(gv(33), "34", color = #2fd6c3, linewidth = 2)
plot(gv(34), "35", color = #f368b0, linewidth = 2)
plot(gv(35), "36", color = #a6e05a, linewidth = 2)
plot(gv(36), "37", color = #34b5e8, linewidth = 2)
plot(gv(37), "38", color = #ff6b35, linewidth = 2)

// ---------------------------------------------------------------- labels -----
declY = array.new<float>(N, na)
if barstate.islast
    float vmax = na
    float vmin = na
    for i = 0 to N - 1
        m = array.get(mArr, i)
        if vis(i) and not na(m)
            vmax := na(vmax) ? m : math.max(vmax, m)
            vmin := na(vmin) ? m : math.min(vmin, m)
    minGap = not na(vmax) and not na(vmin) and vmax > vmin ? (vmax - vmin) * labelGap / 100.0 : 0.0

    float lastY = na
    for p = 1 to N
        idx = -1
        for i = 0 to N - 1
            if array.get(topRank, i) == p
                idx := i
        if idx != -1 and vis(idx)
            m = array.get(mArr, idx)
            if not na(m)
                y = na(lastY) ? m : math.min(m, lastY - minGap)
                array.set(declY, idx, y)
                lastY := y

    for i = 0 to N - 1
        lab = array.get(labArr, i)
        m   = array.get(mArr, i)
        y   = array.get(declY, i)
        if showLabels and vis(i) and not na(m) and not na(y)
            txt = array.get(tickArr, i) + " " + array.get(nameArr, i) + " | " + pctTxt(m) + metricUnit()
            if na(lab)
                lab := label.new(bar_index + labelOff, y, txt, xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = array.get(colArr, i), size = size.small)
            else
                label.set_xy(lab, bar_index + labelOff, y)
                label.set_text(lab, txt)
                label.set_color(lab, array.get(colArr, i))
        else if not na(lab)
            label.delete(lab)
            lab := na
        array.set(labArr, i, lab)

// ---------------------------------------------------------------- breadth ----
int upDay    = 0
int downDay  = 0
int upMetric = 0
for i = 0 to N - 1
    d = array.get(dayArr, i)
    m = array.get(mArr, i)
    upDay    += not na(d) and d > 0 ? 1 : 0
    downDay  += not na(d) and d < 0 ? 1 : 0
    upMetric += not na(m) and m > 0 ? 1 : 0

hi = math.max(2, math.ceil(activeCount * 0.8))
mostUp = math.max(1, math.ceil(activeCount * 0.65))
inBench = lineMetric == "Relative to benchmark"
regime = activeCount == 0 ? "No symbols enabled" :
         upDay    >= hi      ? "Broad buying today"  :
         downDay  >= hi      ? "Broad selling today" :
         upMetric >= mostUp  ? (inBench ? "Most beating benchmark" : "Most positive") :
         upMetric <= activeCount - mostUp ? (inBench ? "Most lagging benchmark" : "Most negative") :
         "Mixed / rotation"
regCol = upDay >= hi ? color.new(#1b7a44, 20) : downDay >= hi ? color.new(#8a2530, 20) : color.new(#333a45, 20)

// ---------------------------------------------------------------- table ------
// Vertical + sorted: one row per active symbol, strongest at the top.
var table tbl = table.new(position.top_right, 5, 41, border_width = 1)
var table ban = table.new(position.bottom_right, 1, 1)

tsz = tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small

if barstate.islast
    table.set_position(tbl, tblPos == "Left" ? position.top_left : position.top_right)
    table.clear(tbl, 0, 0, 4, 40)
    if showTable and activeCount > 0
        hb = color.new(color.black, 0)
        hc = color.new(color.white, 25)
        table.cell(tbl, 0, 0, "#",    text_color = hc, bgcolor = hb, text_size = tsz)
        table.cell(tbl, 1, 0, "Sym",  text_color = hc, bgcolor = hb, text_size = tsz)
        table.cell(tbl, 2, 0, "Name", text_color = hc, bgcolor = hb, text_size = tsz, text_halign = text.align_left)
        table.cell(tbl, 3, 0, inBench ? "vs Bench" : "Return", text_color = hc, bgcolor = hb, text_size = tsz)
        table.cell(tbl, 4, 0, "Day",  text_color = hc, bgcolor = hb, text_size = tsz)
        for p = 1 to activeCount
            idx = -1
            for i = 0 to N - 1
                if array.get(topRank, i) == p
                    idx := i
            if idx != -1
                m    = array.get(mArr, idx)
                star = array.get(crossArr, idx) ? "★ " : ""
                table.cell(tbl, 0, p, str.tostring(p), text_color = color.new(color.white, 45), bgcolor = hb, text_size = tsz)
                table.cell(tbl, 1, p, array.get(tickArr, idx), text_color = color.white, bgcolor = color.new(array.get(colArr, idx), 25), text_size = tsz)
                table.cell(tbl, 2, p, array.get(nameArr, idx), text_color = color.new(color.white, 10), bgcolor = hb, text_size = tsz, text_halign = text.align_left)
                table.cell(tbl, 3, p, star + pctTxt(m), text_color = color.white, bgcolor = cellCol(m), text_size = tsz)
                table.cell(tbl, 4, p, pctTxt(array.get(dayArr, idx)), text_color = color.white, bgcolor = cellCol(array.get(dayArr, idx)), text_size = tsz)

    table.clear(ban, 0, 0)
    if showBanner
        table.set_position(ban, tblPos == "Left" ? position.bottom_left : position.bottom_right)
        table.cell(ban, 0, 0, str.tostring(upDay) + "▲ / " + str.tostring(downDay) + "▼   ·   " + regime, text_color = color.white, bgcolor = regCol, text_size = tsz)

// ---------------------------------------------------------------- alerts -----
leaderIdx = -1
for i = 0 to N - 1
    if array.get(topRank, i) == 1
        leaderIdx := i

if barstate.isconfirmed
    if alLeader and leaderIdx != -1 and leaderIdx != prevLeader and prevLeader != -1
        alert("SectorFlow: new leader → " + array.get(tickArr, leaderIdx) + " " + array.get(nameArr, leaderIdx), alert.freq_once_per_bar_close)
    if alBreadth and activeCount > 0 and (upDay >= hi or downDay >= hi)
        alert("SectorFlow: " + regime + " (" + str.tostring(upDay) + " up / " + str.tostring(downDay) + " down)", alert.freq_once_per_bar_close)
    prevLeader := leaderIdx
````
