# SF Raw Anchored Return Lines

- url: https://www.tradingview.com/script/ha3r8YnY-SF-Raw-Anchored-Return-Lines/
- type: indicator
- pine_id: PUB;42c523d4899b4e91aa3b0de1a0a6e736
- version: 1.0

## Description

[b]Sector Rotation Lines
[/b]
A Plain-English Guide
[i]Authors Stephen_F and Claude, August 19, 2026

[/i][i]What This Tool Shows You
[/i]
Sector Rotation Lines is a chart tool that answers one simple question: “which parts of the stock market are doing better or worse than the others, right now?” 
     The U.S. stock market is made up of 11 broad sectors — groups of companies that do similar things. Technology, Financials, Health Care, Energy, and so on. Money doesn't move evenly through all of them at once. At any given time, some sectors are leading (attracting more buying) and some are lagging (falling behind). Traders call the natural ebb and flow between them “sector rotation.”
     This tool draws one line per sector, all starting from the same point (zero), so you can see at a glance who's pulling ahead and who's falling behind over whatever time period you choose.

How to Read the Chart
• Every line starts at 0% on the left-hand side. That's the “starting line” for all 11 sectors — they all begin equal, even though the underlying stocks are priced completely differently.
• As you move right across the chart, each line rises or falls based on how much that sector's price has gone up or down since the starting point.
• A line sitting above 0% means that sector has gained value since the start of the window. Below 0% means it has lost value.
• The higher a line sits above the others, the stronger that sector has performed over the period you're looking at.

[i]Why rebase everything to zero?
[/i]A single share of one sector fund might cost $40, while another costs $200. Comparing raw prices tells you nothing useful. By resetting every sector to the same starting point, the chart lets you compare percentage moves directly — an apples-to-apples view of performance.

[i]The Dashed Average Line
[/i]Alongside the 11 colored sector lines, you'll see one black dashed line. This is the average of all 11 sectors combined — think of it as “the market as a whole,” built directly from the same sectors on your chart (it isn't a separate index or fund).

This line is one of the most useful things on the chart:
• Any sector line sitting above the dashed average is currently outperforming the broad market — it's a leader.
• Any sector line sitting below the dashed average is currently underperforming — it's a laggard.

This is the quickest way to separate the sectors worth paying attention to from the ones that are just drifting along with everything else.

[i]Choosing Your Data Source
[/i]Sector performance can be measured a few different ways, depending on which fund family's products you use as the stand-in for each sector. This tool lets you pick from five built-in options, plus a fully custom option:

[b]Option -- SPDR (Cap-Weighted)
[/b]The most widely watched sector funds (the “XL” funds). Weighted so larger companies count for more — this is the industry-standard default most people mean when they talk about “the sectors.”
[b]Option -- Vanguard (Total Market)
[/b]Vanguard's broader sector funds, covering a wider slice of each sector's companies, not just the biggest names.
[b]Option == Invesco (Equal-Weight)
[/b]Every company in a sector counts equally, regardless of size. This can highlight smaller companies that a cap-weighted view would hide behind giants like Apple or Microsoft.
[b]Option -- Fidelity (Total Market)
[/b]Fidelity's version of broad sector coverage, similar in spirit to Vanguard's.
[b]Option == S&P 500 Sector Indices
[/b]The raw index values behind the sector funds, rather than a tradable fund itself.
[b]Option == Custom
[/b]Type in your own preferred symbol for each sector if you have a specific fund family or ticker in mind.

If you're not sure which to pick, the SPDR (Cap-Weighted) option is the most common starting point and matches what most financial news reports.

[i]Choosing Your Time Window
[/i]Sector leadership changes over different time horizons — a sector can be the weakest performer this week and the strongest this year. The tool lets you choose how far back the comparison starts:
[b]Window -- 1 Week
[/b]The last 5 trading days — a short-term, fast-moving snapshot.
[i]1 Month
[/i]The last 21 trading days — a good general-purpose view for spotting a rotation that's building.
[i]1 Quarter
[/i]The last 63 trading days — roughly three months, useful for medium-term trends.
[i]1 Year
[/i]The last 252 trading days — the big-picture view of which sectors have led all year.
[i]Custom[/i]
Pick your own exact start and end dates — useful for comparing a specific news event, earnings season, or period you care about.

[i]A note on the Custom option
[/i]When you switch to Custom, you'll set both a start date and an end date yourself. If you leave the end date far in the future, the chart will simply keep updating with today's most recent data — exactly like the preset windows do. Only set a specific end date if you want to “freeze” the comparison at a particular point in the past, for example to study exactly what happened during a specific week.

[i]The Labels and the Table
[/i]Two things help you identify each line without guessing:
• End-of-line labels: each line has its ticker symbol sitting right at its endpoint, so you can trace any line back to its name just by looking at the right edge of the chart.
• The legend table: a small table in the corner of the chart lists every sector by name along with its exact percentage return for the period, sorted from best performer to worst. This is the fastest way to get an exact number rather than eyeballing the lines.

[b]A Few Ways to Use This in Practice
[/b]• Quick market check: glance at the 1 Month view to see which sectors are currently leading — this is often the first thing worth checking before digging into individual stocks.
• Confirming a trend: if a sector is above the dashed average line on the 1 Week, 1 Month, and 1 Quarter views, that's a sector with real, sustained momentum, not just a one-day blip.
• Spotting a turn: watch for a sector that has been near the bottom of the pack starting to cross above the dashed average — this is often an early signal of money starting to rotate into that area.
• Comparing data sources: if you're unsure whether a move is broad-based or driven by a few large companies, switch between the Cap-Weighted and Equal-Weight presets and see if the picture changes.
[i]This tool is for informational and educational purposes and is not investment advice.[/i]

## Source Code

````pine
//@version=6
indicator("SF Raw Anchored Return Lines", shorttitle="Sector Raw Lines", overlay=false, max_labels_count=100, max_lines_count=300)

// ================= WINDOW SELECTION =================
grp_window = "Calculation Window"
windowPreset = input.string("1 Month", "Window Preset", options=["1 Week", "1 Month", "1 Quarter", "1 Year", "Custom"], group=grp_window, tooltip="Week/Month/Quarter/Year use standard trading-day counts (5/21/63/252 bars back from the most recent bar) — assumes a DAILY chart. Custom lets you pick exact start/end dates below.")
customAnchor = input.time(timestamp("2026-07-13 00:00 +0000"), "Custom Start (used only when preset = Custom)", group=grp_window)
customEndT   = input.time(timestamp("2099-12-31 00:00 +0000"), "Custom End (used only when preset = Custom, leave far future to track live bar)", group=grp_window)

barsBackForPreset(p) =>
    switch p
        "1 Week"    => 5
        "1 Month"   => 21
        "1 Quarter" => 63
        "1 Year"    => 252
        => na

isCustomWindow = windowPreset == "Custom"
presetBarsBack = barsBackForPreset(windowPreset)
anchorBarIndex = isCustomWindow ? na : last_bar_index - presetBarsBack

grp_universe = "Sector Data Source"
sectorUniverse = input.string("SPDR Select Sector (Cap-Weighted)", "Sector Universe Preset", options=["SPDR Select Sector (Cap-Weighted)", "Vanguard (Total Market)", "Invesco (Equal-Weight)", "Fidelity (Total Market)", "S&P 500 Sector Indices", "Custom (edit symbols below)"], group=grp_universe)

grp_sym = "Sector Symbols (used only when preset = Custom)"
symTechCustom = input.symbol("XLK",  "Technology", group=grp_sym)
symFinCustom  = input.symbol("XLF",  "Financials", group=grp_sym)
symCommCustom = input.symbol("XLC",  "Communication Svcs", group=grp_sym)
symDiscCustom = input.symbol("XLY",  "Cons. Discretionary", group=grp_sym)
symIndCustom  = input.symbol("XLI",  "Industrials", group=grp_sym)
symHCCustom   = input.symbol("XLV",  "Health Care", group=grp_sym)
symStapCustom = input.symbol("XLP",  "Cons. Staples", group=grp_sym)
symEnerCustom = input.symbol("XLE",  "Energy", group=grp_sym)
symUtilCustom = input.symbol("XLU",  "Utilities", group=grp_sym)
symRECustom   = input.symbol("XLRE", "Real Estate", group=grp_sym)
symMatCustom  = input.symbol("XLB",  "Materials", group=grp_sym)

pickSym(u, spdr, vanguard, invesco, fidelity, spindex, customVal) =>
    switch u
        "SPDR Select Sector (Cap-Weighted)" => spdr
        "Vanguard (Total Market)"           => vanguard
        "Invesco (Equal-Weight)"            => invesco
        "Fidelity (Total Market)"           => fidelity
        "S&P 500 Sector Indices"            => spindex
        => customVal

symTech = pickSym(sectorUniverse, "XLK",  "VGT", "RSPT", "AMEX:FTEC", "SP:S5INFT", symTechCustom)
symFin  = pickSym(sectorUniverse, "XLF",  "VFH", "RSPF", "AMEX:FNCL", "SP:SPF",    symFinCustom)
symComm = pickSym(sectorUniverse, "XLC",  "VOX", "RSPC", "AMEX:FCOM", "SP:S5TELS", symCommCustom)
symDisc = pickSym(sectorUniverse, "XLY",  "VCR", "RSPD", "AMEX:FDIS", "SP:S5COND", symDiscCustom)
symInd  = pickSym(sectorUniverse, "XLI",  "VIS", "RSPN", "AMEX:FIDU", "SP:S5INDU", symIndCustom)
symHC   = pickSym(sectorUniverse, "XLV",  "VHT", "RSPH", "AMEX:FHLC", "SP:S5HLTH", symHCCustom)
symStap = pickSym(sectorUniverse, "XLP",  "VDC", "RSPS", "AMEX:FSTA", "SP:S5CONS", symStapCustom)
symEner = pickSym(sectorUniverse, "XLE",  "VDE", "RSPG", "AMEX:FENY", "SP:SPN",    symEnerCustom)
symUtil = pickSym(sectorUniverse, "XLU",  "VPU", "RSPU", "AMEX:FUTY", "SP:S5UTIL", symUtilCustom)
symRE   = pickSym(sectorUniverse, "XLRE", "VNQ", "RSPR", "AMEX:FREL", "SP:S5REAS", symRECustom)
symMat  = pickSym(sectorUniverse, "XLB",  "VAW", "RSPM", "AMEX:FMAT", "SP:S5MATR", symMatCustom)

grp_bench = "Sector Average (Dashed Line)"
showBenchmark  = input.bool(true, "Show Sector-Average Line", group=grp_bench, tooltip="Equal-weight average of the 11 sector anchored returns for that bar — shows which sectors are running above/below the group average.")
benchmarkColor = input.color(color.black, "Average Line Color", group=grp_bench)

grp_col = "Colors"
colTech = input.color(#2962FF, "Technology", group=grp_col)
colFin  = input.color(#00C853, "Financials", group=grp_col)
colComm = input.color(#AA00FF, "Communication Svcs", group=grp_col)
colDisc = input.color(#FF6D00, "Cons. Discretionary", group=grp_col)
colInd  = input.color(#795548, "Industrials", group=grp_col)
colHC   = input.color(#00BCD4, "Health Care", group=grp_col)
colStap = input.color(#8BC34A, "Cons. Staples", group=grp_col)
colEner = input.color(#D50000, "Energy", group=grp_col)
colUtil = input.color(#FFD600, "Utilities", group=grp_col)
colRE   = input.color(#607D8B, "Real Estate", group=grp_col)
colMat  = input.color(#EC407A, "Materials", group=grp_col)

grp_lines = "Line Display"
lineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=grp_lines)

grp_labels = "End-of-Line Ticker Labels"
showEndLabels  = input.bool(true, "Show End-of-Line Ticker Labels", group=grp_labels)
endLabelSize   = input.string("large", "End Label Text Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_labels)

grp_legend = "Legend Table"
showLegend = input.bool(true, "Show Legend Table (name, color, % return)", group=grp_legend)
legendPos = input.string("Top Right", "Legend Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grp_legend)
legendTextSize = input.string("normal", "Legend Text Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_legend)
legendSortByValue = input.bool(true, "Sort Legend by Return (highest first)", group=grp_legend)

posMap(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

textSizeMap(s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

stripPrefix(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

// ================= REBASE HELPER (bar-index preset window OR custom time window) =================
rebasedIndexWindowed(useCustom, customAnchorT, customEndT, anchorBarIdx) =>
    var float aClose = na
    inWin = useCustom ? (time >= customAnchorT and time <= customEndT) : (bar_index >= anchorBarIdx)
    if na(aClose) and inWin
        aClose := close
    inWin and not na(aClose) ? close / aClose * 100 : na

idxTech = request.security(symTech, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxFin  = request.security(symFin,  timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxComm = request.security(symComm, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxDisc = request.security(symDisc, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxInd  = request.security(symInd,  timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxHC   = request.security(symHC,   timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxStap = request.security(symStap, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxEner = request.security(symEner, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxUtil = request.security(symUtil, timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxRE   = request.security(symRE,   timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))
idxMat  = request.security(symMat,  timeframe.period, rebasedIndexWindowed(isCustomWindow, customAnchor, customEndT, anchorBarIndex))

anchTech = na(idxTech) ? na : idxTech - 100
anchFin  = na(idxFin)  ? na : idxFin  - 100
anchComm = na(idxComm) ? na : idxComm - 100
anchDisc = na(idxDisc) ? na : idxDisc - 100
anchInd  = na(idxInd)  ? na : idxInd  - 100
anchHC   = na(idxHC)   ? na : idxHC   - 100
anchStap = na(idxStap) ? na : idxStap - 100
anchEner = na(idxEner) ? na : idxEner - 100
anchUtil = na(idxUtil) ? na : idxUtil - 100
anchRE   = na(idxRE)   ? na : idxRE   - 100
anchMat  = na(idxMat)  ? na : idxMat  - 100

// ================= SECTOR AVERAGE (computed, not fetched) =================
sectorVals = array.from(anchTech, anchFin, anchComm, anchDisc, anchInd, anchHC, anchStap, anchEner, anchUtil, anchRE, anchMat)
sumVal = 0.0
cntVal = 0
for v in sectorVals
    if not na(v)
        sumVal += v
        cntVal += 1
anchBench = cntVal > 0 ? sumVal / cntVal : na

hline(0, "0%", color=color.gray)

// ================= 11 RAW ANCHORED RETURN LINES =================
plot(anchTech, "Technology",         color=colTech, linewidth=lineWidth, style=plot.style_line)
plot(anchFin,  "Financials",         color=colFin,  linewidth=lineWidth, style=plot.style_line)
plot(anchComm, "Communication Svcs", color=colComm, linewidth=lineWidth, style=plot.style_line)
plot(anchDisc, "Cons. Discretionary",color=colDisc, linewidth=lineWidth, style=plot.style_line)
plot(anchInd,  "Industrials",        color=colInd,  linewidth=lineWidth, style=plot.style_line)
plot(anchHC,   "Health Care",        color=colHC,   linewidth=lineWidth, style=plot.style_line)
plot(anchStap, "Cons. Staples",      color=colStap, linewidth=lineWidth, style=plot.style_line)
plot(anchEner, "Energy",             color=colEner, linewidth=lineWidth, style=plot.style_line)
plot(anchUtil, "Utilities",          color=colUtil, linewidth=lineWidth, style=plot.style_line)
plot(anchRE,   "Real Estate",        color=colRE,   linewidth=lineWidth, style=plot.style_line)
plot(anchMat,  "Materials",          color=colMat,  linewidth=lineWidth, style=plot.style_line)

// ================= SECTOR-AVERAGE DASHED LINE (manual draw, plot() can't dash) =================
var float prevBenchVal  = na
var int   prevBenchTime = na

if showBenchmark and not na(anchBench)
    if not na(prevBenchVal)
        line.new(x1=prevBenchTime, y1=prevBenchVal, x2=time, y2=anchBench, xloc=xloc.bar_time, style=line.style_dashed, color=benchmarkColor, width=lineWidth)
    prevBenchVal := anchBench
    prevBenchTime := time

// ================= TRACK LAST VALID POINT PER SERIES (for end-of-line labels) =================
var float[] lastVal  = array.new_float(12, na)
var int[]   lastTime = array.new_int(12, na)

valNow = array.from(anchTech, anchFin, anchComm, anchDisc, anchInd, anchHC, anchStap, anchEner, anchUtil, anchRE, anchMat, anchBench)
for i = 0 to 11
    v = array.get(valNow, i)
    if not na(v)
        array.set(lastVal, i, v)
        array.set(lastTime, i, time)

// ================= END-OF-LINE TICKER LABELS =================
if showEndLabels and barstate.islast
    lblSize = textSizeMap(endLabelSize)
    tickerArr = array.from(stripPrefix(symTech), stripPrefix(symFin), stripPrefix(symComm), stripPrefix(symDisc), stripPrefix(symInd), stripPrefix(symHC), stripPrefix(symStap), stripPrefix(symEner), stripPrefix(symUtil), stripPrefix(symRE), stripPrefix(symMat), "AVG")
    colArrAll = array.from(colTech, colFin, colComm, colDisc, colInd, colHC, colStap, colEner, colUtil, colRE, colMat, benchmarkColor)
    for i = 0 to 11
        if (i < 11 or showBenchmark) and not na(array.get(lastVal, i))
            label.new(x=array.get(lastTime, i), y=array.get(lastVal, i), xloc=xloc.bar_time, text=array.get(tickerArr, i), style=label.style_label_left, textcolor=array.get(colArrAll, i), color=color.new(color.white, 100), size=lblSize)

// ================= LEGEND TABLE (name + color + % return, includes sector average) =================
fmtPct(v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.#") + "%"

if showLegend and barstate.islast
    var table legendTbl = table.new(posMap(legendPos), 2, 13, bgcolor=color.white, border_width=1, border_color=color.black, frame_width=1, frame_color=color.black)

    ts = textSizeMap(legendTextSize)
    table.cell(legendTbl, 0, 0, "Sector",  text_color=color.white, bgcolor=color.black, text_size=ts)
    table.cell(legendTbl, 1, 0, "Return",  text_color=color.white, bgcolor=color.black, text_size=ts)

    nameArr = array.from("Technology", "Financials", "Communication Svcs", "Cons. Discretionary", "Industrials", "Health Care", "Cons. Staples", "Energy", "Utilities", "Real Estate", "Materials", "Sector Average")
    valArr  = array.from(anchTech, anchFin, anchComm, anchDisc, anchInd, anchHC, anchStap, anchEner, anchUtil, anchRE, anchMat, anchBench)
    colArr  = array.from(colTech, colFin, colComm, colDisc, colInd, colHC, colStap, colEner, colUtil, colRE, colMat, benchmarkColor)

    var int[] legendOrder = array.new_int(0)
    array.clear(legendOrder)
    for i = 0 to 11
        array.push(legendOrder, i)

    if legendSortByValue
        for i = 0 to 10
            maxIdx = i
            for j = i + 1 to 11
                vj = array.get(valArr, array.get(legendOrder, j))
                vm = array.get(valArr, array.get(legendOrder, maxIdx))
                if not na(vj) and (na(vm) or vj > vm)
                    maxIdx := j
            if maxIdx != i
                tmp = array.get(legendOrder, i)
                array.set(legendOrder, i, array.get(legendOrder, maxIdx))
                array.set(legendOrder, maxIdx, tmp)

    for r = 0 to 11
        idx = array.get(legendOrder, r)
        nm  = array.get(nameArr, idx)
        v   = array.get(valArr, idx)
        col = array.get(colArr, idx)
        rowBg = r % 2 == 0 ? color.white : color.new(color.gray, 92)
        table.cell(legendTbl, 0, r + 1, nm, text_color=col, bgcolor=rowBg, text_size=ts)
        table.cell(legendTbl, 1, r + 1, na(v) ? "n/a" : fmtPct(v), text_color=na(v) ? color.gray : col, bgcolor=rowBg, text_size=ts)
````
