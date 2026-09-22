<!-- tradingview-pine-id: PUB;366f389bbd494d7f8ff6fe1efe655fb9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sales & EPS Qrtly YOY% (Market-Surge Style)

Source: https://www.tradingview.com/script/i1rLW7Tr-Sales-EPS-Qrtly-YOY-Market-Surge-Style/

## Description

WHAT IT DOES

Puts the two numbers that actually drive a stock — quarterly sales growth and quarterly
earnings growth — directly on the price chart, where you are already looking.

On every earnings print the indicator stamps a label above the bar showing that quarter's
year-over-year change in revenue and in EPS. A companion table holds the full reported
history: report date, EPS, EPS YoY%, sales, sales YoY%, with an ANNUAL roll-up row inserted
after every four quarters.

Growth stocks work because the fundamentals are accelerating. This lets you see whether
the price base you are looking at was built on 12% growth or 90% growth without leaving
the chart.

ON THE CHART

A two-line label prints above each earnings bar:

  Sales +38%
  EPS +52%

Green for expansion, red for contraction. Negative prints can be hidden entirely if you
only want to see the quarters that worked.

Year-over-year means the same quarter one year earlier — the print four reports back —
not the sequential quarter. That is the comparison that strips out seasonality.

THE TABLE

  Report Date | EPS($) | %Chg | Sales($) | %Chg

Rows are the last N reported quarters (2 to 24, default 8). The date shown is the actual
date the results hit the tape, taken from the data feed — not a derived or estimated
fiscal period.

After every four quarters an ANNUAL row sums that block: EPS summed, revenue summed, and
%Chg measured against the four quarters before it. Hover the ANNUAL cell to see exactly
which four report dates it covers.

Reading the table top to bottom, you are looking for the shape of the growth curve:
sequential acceleration in the YoY numbers, the quarter where margins turned, or the
point where a multi-quarter deceleration began.

SETTINGS

  Use standardized EPS     Standardized instead of reported/actual EPS
  Show negative growth     Hide the down quarters if you only want the wins
  Percent decimals         0, 1 or 2

  Show quarterly table     On/off
  Quarters to show         2 to 24
  Newest quarter on top    Flips row order
  Annual roll-up row       On/off
  Report-date format       2026-08-05, Aug 5 2026, or 08/05/26
  Table theme              Black (default), White, Grey, or Clear
  Position / Text size     Any of six corners; tiny to large

Clear removes every cell background and the table borders so only the numbers float over
the chart, and it follows your chart's light/dark theme automatically.

HOW IT HANDLES THE DATA

A new quarter is detected on a change in either EPS or revenue, with a 30-day lockout so
a single print arriving across two bars cannot register twice. Detecting on EPS alone
silently drops a quarter whenever two consecutive quarters report the same cents figure
(-1.89 then -1.89, common in loss-making names), which then mis-pairs every year-over-year
comparison after it. Using revenue as the co-detector removes that failure.

Percent change is (current - prior) / |prior|. The absolute-value denominator matters for
loss-makers: a loss narrowing from -2.48 to -1.88 reads correctly as +24%, not -24%.

Where a comparison is undefined — no year-ago print yet, or a prior value of zero — the
cell shows a dash rather than a misleading number.

LIMITATIONS, STATED PLAINLY

• Coverage is whatever TradingView's fundamental data provides for that symbol. Thin or
  newly listed names will show partial history or blanks. Nothing is estimated to fill a gap.

• The ANNUAL rows are trailing four-quarter blocks counted back from the most recent
  print. That equals the reported fiscal year only when the latest print is a Q4. It is a
  TTM roll-up, and it is labeled as one.

• No forward estimate rows. Pine returns consensus for the quarter being reported, not for
  future quarters, so projected years cannot be shown.

• The table renders on the last bar, as Pine tables do. It reflects the full reported
  history regardless of where you are scrolled.

Layout is inspired by the fundamental data blocks in MarketSurge and similar growth-stock
platforms. It is an independent implementation on TradingView's own earnings and financial
data, not affiliated with or endorsed by any of them.

Open source — read it, fork it, change what you disagree with.

---

## Source Code

````pine
//@version=6
// Sales & EPS Qrtly YOY% (Market-Surge Style) — chart labels + quarterly/annual history table
//   Labels: per-earnings-bar Sales/EPS YoY% stacked above the bar (unchanged behaviour).
//   Table : last N reported quarters — Report Date | EPS($) | %Chg | Sales($) | %Chg,
//           with an ANNUAL roll-up row after every 4 quarters. Fed by the SAME
//           epsArr/salesArr history the labels use, so table and labels cannot disagree.
indicator("Sales & EPS Qrtly YOY% (Market-Surge Style)", shorttitle="Sales & EPS YOY%", overlay=true)

// ===== Inputs
useStandardized = input.bool(false, "Use standardized EPS (else reported/actual)")
showNegative    = input.bool(true,  "Show negative growth labels")
decimals        = input.int(0, "Percent decimals (0–2)", minval=0, maxval=2)

grpT        = "Quarterly table"
showTable   = input.bool(true,  "Show quarterly table",                  group = grpT)
numQuarters = input.int(8,      "Quarters to show", minval=2, maxval=24, group = grpT)
newestFirst = input.bool(false, "Newest quarter on top",                 group = grpT)
showAnnual  = input.bool(true,  "Annual roll-up row after every 4 quarters", group = grpT, tooltip="Sums the 4 quarters immediately above it (EPS and revenue). Blocks are counted back from the most recent print, so the newest block is a trailing-twelve-month figure — it only equals the reported fiscal year when the latest print is a Q4.")
dateFmtIn   = input.string("2026-08-05", "Report-date format", options=["2026-08-05","Aug 5 2026","08/05/26"], group = grpT)
themeIn     = input.string("Black", "Table theme", options=["White","Grey","Black","Clear"], group = grpT)
tblPosIn    = input.string("Top right", "Position", options=["Top right","Middle right","Bottom right","Top left","Middle left","Bottom left"], group = grpT)
tblSizeIn   = input.string("Small",     "Text size", options=["Tiny","Small","Normal","Large"], group = grpT)

// ===== Colors setup
posColor   = color.new(color.green, 0)
negColor   = color.new(color.red, 0)
bgBoxColor = color.new(#131722, 20)      // Dark, semi-transparent background box
transColor = color.new(color.white, 100) // 100% transparent label background

// ===== Table theme
clearC  = color.new(color.white, 100)
isClear = themeIn == "Clear"

tHdrBg = themeIn == "White" ? color.new(#e8eaed, 0) : themeIn == "Grey" ? color.new(#9aa0a6, 0) : themeIn == "Black" ? color.new(#1c1f26, 0) : clearC
tRowBg = themeIn == "White" ? color.new(#ffffff, 0) : themeIn == "Grey" ? color.new(#d5d8dc, 0) : themeIn == "Black" ? color.new(#0d0f13, 0) : clearC
tAltBg = themeIn == "White" ? color.new(#f4f5f7, 0) : themeIn == "Grey" ? color.new(#c8ccd1, 0) : themeIn == "Black" ? color.new(#14171d, 0) : clearC
tAnnBg = themeIn == "White" ? color.new(#dde1e6, 0) : themeIn == "Grey" ? color.new(#868c93, 0) : themeIn == "Black" ? color.new(#272d37, 0) : clearC
tTxt   = themeIn == "White" ? color.new(#1c1e21, 0) : themeIn == "Grey" ? color.new(#15181c, 0) : themeIn == "Black" ? color.new(#e8eaed, 0) : chart.fg_color
tPos   = themeIn == "Black" or isClear ? color.new(#26a65b, 0) : color.new(#0a8f3c, 0)
tNeg   = themeIn == "Black" or isClear ? color.new(#ef5350, 0) : color.new(#d1342f, 0)
tFrame = themeIn == "White" ? color.new(#b0b4ba, 0) : themeIn == "Grey" ? color.new(#6f757c, 0) : themeIn == "Black" ? color.new(#3a3f4a, 0) : clearC
tLine  = isClear ? 0 : 1

tblPos  = tblPosIn  == "Top right" ? position.top_right : tblPosIn == "Middle right" ? position.middle_right : tblPosIn == "Bottom right" ? position.bottom_right : tblPosIn == "Top left" ? position.top_left : tblPosIn == "Middle left" ? position.middle_left : position.bottom_left
tblSize = tblSizeIn == "Tiny" ? size.tiny : tblSizeIn == "Small" ? size.small : tblSizeIn == "Normal" ? size.normal : size.large

mult    = decimals == 0 ? 1.0 : decimals == 1 ? 10.0 : 100.0
pctFmt  = decimals == 0 ? "#,##0" : decimals == 1 ? "#,##0.0" : "#,##0.00"
dateFmt = dateFmtIn == "2026-08-05" ? "yyyy-MM-dd" : dateFmtIn == "Aug 5 2026" ? "MMM d yyyy" : "MM/dd/yy"

// ===== Formatters
fmtPct(float x) =>
    string out = "—"
    if not na(x)
        r = math.round(x * mult) / mult
        out := (r >= 0 ? "+" : "") + str.tostring(r, pctFmt) + "%"
    out

fmtMoney(float v) =>
    string out = "—"
    if not na(v)
        a = math.abs(v)
        out := a >= 1e12 ? str.tostring(v / 1e12, "#,##0.0") + "T" : a >= 1e9 ? str.tostring(v / 1e9, "#,##0.0") + "B" : str.tostring(v / 1e6, "#,##0.0") + "M"
    out

fmtEps(float e) => na(e) ? "—" : str.tostring(e, "0.00")

// Actual date the results hit the tape — no fiscal-period derivation, no heuristic.
rptDate(int tms) => na(tms) ? "—" : str.format_time(tms, dateFmt, syminfo.timezone)

yoy(float cur, float prev) => na(cur) or na(prev) or prev == 0 ? na : ((cur - prev) / math.abs(prev)) * 100.0

// ===== Get Data
eps   = request.earnings(syminfo.tickerid, useStandardized ? earnings.standardized : earnings.actual, ignore_invalid_symbol = true)
sales = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "FQ", ignore_invalid_symbol = true)

// A fresh print is a CHANGE in either series. Detecting on EPS alone drops a quarter whenever
// two consecutive quarters print the same cents figure (common, e.g. -1.89 then -1.89), which
// then mis-aligns every downstream YoY pair. Revenue almost never repeats, so it carries detection.
epsChanged   = not na(eps)   and (na(eps[1])   or eps   != eps[1])
salesChanged = not na(sales) and (na(sales[1]) or sales != sales[1])

// Keep history
var float[] epsArr    = array.new_float()
var float[] salesArr  = array.new_float()
var int[]   timeArr   = array.new_int()
var int     lastQTime = na

// 30-day lockout: no two fiscal quarters report within a month, so anything inside that
// window is the same print arriving on a different bar, not a new quarter.
isEarningsBar = (epsChanged or salesChanged) and (na(lastQTime) or time - lastQTime > 30 * 86400000)

if isEarningsBar
    // Save this quarter's data
    lastQTime := time
    array.push(epsArr, eps)
    array.push(salesArr, sales)
    array.push(timeArr, time)

    // Only calculate YoY if we have at least 4 previous quarters
    if array.size(epsArr) > 4
        prevEps   = array.get(epsArr, array.size(epsArr) - 5)
        prevSales = array.get(salesArr, array.size(salesArr) - 5)

        yoyEps   = yoy(eps, prevEps)
        yoySales = yoy(sales, prevSales)

        // Format Sales String & Determine Color
        txtSales = ""
        salesCol = color.white
        if not na(yoySales)
            pctS = math.round(yoySales * mult) / mult
            txtSales := "Sales " + (pctS >= 0 ? "+" : "") + str.tostring(pctS) + "%"
            salesCol := pctS >= 0 ? posColor : negColor

        // Format EPS String & Determine Color
        txtEps = ""
        epsCol = color.white
        if not na(yoyEps)
            pctE = math.round(yoyEps * mult) / mult
            txtEps := "EPS " + (pctE >= 0 ? "+" : "") + str.tostring(pctE) + "%"
            epsCol := pctE >= 0 ? posColor : negColor

        // --- DRAWING LOGIC ---
        hasSales = txtSales != ""
        hasEps   = txtEps != ""

        // Check user filter (show if 'showNegative' is true OR if either metric is positive)
        showLabel = showNegative or (not na(yoyEps) and yoyEps >= 0) or (not na(yoySales) and yoySales >= 0)

        if (hasSales or hasEps) and showLabel

            // If we have both, execute the 3-layer stack trick
            if hasSales and hasEps
                // 1. Draw the background box using hidden spaces
                label.new(bar_index, high, "         \n         ", style=label.style_label_down, yloc=yloc.abovebar, color=bgBoxColor, size=size.small)

                // 2. Draw Sales text (forced to the top using a newline after the text)
                label.new(bar_index, high, txtSales + "\n ", style=label.style_label_down, yloc=yloc.abovebar, color=transColor, textcolor=salesCol, size=size.small)

                // 3. Draw EPS text (forced to the bottom using a newline before the text)
                label.new(bar_index, high, " \n" + txtEps, style=label.style_label_down, yloc=yloc.abovebar, color=transColor, textcolor=epsCol, size=size.small)

            // If we only have one metric, draw a standard single label
            else if hasSales
                label.new(bar_index, high, txtSales, style=label.style_label_down, yloc=yloc.abovebar, color=bgBoxColor, textcolor=salesCol, size=size.small)
            else if hasEps
                label.new(bar_index, high, txtEps, style=label.style_label_down, yloc=yloc.abovebar, color=bgBoxColor, textcolor=epsCol, size=size.small)

// A plain guarded `if` rather than an `else` — same logic, no dependence on Pine's
// block parser matching an else across the long nested label block above.
if not isEarningsBar and array.size(timeArr) > 0 and (epsChanged or salesChanged)
    // Straggler patch: if EPS and revenue land on different bars of the same print, fold the
    // late arrival into the row already created rather than opening a phantom quarter.
    li = array.size(timeArr) - 1
    if not na(eps)
        array.set(epsArr, li, eps)
    if not na(sales)
        array.set(salesArr, li, sales)

// ===== Quarterly table (same arrays as the labels — one source of truth)
annMax  = showAnnual ? int(numQuarters / 4) : 0
totRows = numQuarters + annMax + 1

var table qt = table.new(tblPos, 5, totRows, frame_color = tFrame, frame_width = tLine, border_color = tFrame, border_width = tLine)

if showTable and barstate.islast
    n     = array.size(timeArr)
    shown = math.min(numQuarters, n)
    table.clear(qt, 0, 0, 4, totRows - 1)

    table.cell(qt, 0, 0, "Report Date", text_color = tTxt, bgcolor = tHdrBg, text_size = tblSize, text_halign = text.align_left)
    table.cell(qt, 1, 0, "EPS($)",      text_color = tTxt, bgcolor = tHdrBg, text_size = tblSize, text_halign = text.align_right)
    table.cell(qt, 2, 0, "%Chg",        text_color = tTxt, bgcolor = tHdrBg, text_size = tblSize, text_halign = text.align_right)
    table.cell(qt, 3, 0, "Sales($)",    text_color = tTxt, bgcolor = tHdrBg, text_size = tblSize, text_halign = text.align_right)
    table.cell(qt, 4, 0, "%Chg",        text_color = tTxt, bgcolor = tHdrBg, text_size = tblSize, text_halign = text.align_right)

    if shown > 0
        int row = 0
        for r = 0 to shown - 1
            idx = newestFirst ? n - 1 - r : n - shown + r
            row += 1
            bg = row % 2 == 0 ? tAltBg : tRowBg

            e  = array.get(epsArr,   idx)
            s  = array.get(salesArr, idx)
            tm = array.get(timeArr,  idx)

            float pe = na
            float ps = na
            if idx >= 4
                pe := array.get(epsArr,   idx - 4)
                ps := array.get(salesArr, idx - 4)

            yE = yoy(e, pe)
            yS = yoy(s, ps)

            table.cell(qt, 0, row, rptDate(tm),  text_color = tTxt, bgcolor = bg, text_size = tblSize, text_halign = text.align_left)
            table.cell(qt, 1, row, fmtEps(e),    text_color = tTxt, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)
            table.cell(qt, 2, row, fmtPct(yE),   text_color = na(yE) ? tTxt : yE >= 0 ? tPos : tNeg, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)
            table.cell(qt, 3, row, fmtMoney(s),  text_color = tTxt, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)
            table.cell(qt, 4, row, fmtPct(yS),   text_color = na(yS) ? tTxt : yS >= 0 ? tPos : tNeg, bgcolor = bg, text_size = tblSize, text_halign = text.align_right)

            // Close a block of 4? Blocks are counted back from the newest print, so the run of 4
            // just emitted is complete when this row is the block's newest (oldest-first render)
            // or its oldest (newest-first render).
            int lo = na
            int hi = na
            if showAnnual
                if newestFirst
                    if (n - idx) % 4 == 0
                        lo := idx
                        hi := idx + 3
                else
                    if (n - 1 - idx) % 4 == 0 and idx - 3 >= n - shown and idx - 3 >= 0
                        lo := idx - 3
                        hi := idx

            if not na(lo)
                // Sum the block. A missing leg makes that side na rather than a silently short sum.
                float aE = 0.0
                float aS = 0.0
                bool  oE = true
                bool  oS = true
                for q = lo to hi
                    ve = array.get(epsArr, q)
                    vs = array.get(salesArr, q)
                    oE := oE and not na(ve)
                    oS := oS and not na(vs)
                    aE += na(ve) ? 0.0 : ve
                    aS += na(vs) ? 0.0 : vs

                // Prior 4-quarter block, for the annual %Chg.
                float bE  = 0.0
                float bS  = 0.0
                bool  oBE = lo - 4 >= 0
                bool  oBS = lo - 4 >= 0
                if lo - 4 >= 0
                    for q2 = lo - 4 to hi - 4
                        ve2 = array.get(epsArr, q2)
                        vs2 = array.get(salesArr, q2)
                        oBE := oBE and not na(ve2)
                        oBS := oBS and not na(vs2)
                        bE += na(ve2) ? 0.0 : ve2
                        bS += na(vs2) ? 0.0 : vs2

                annE = oE ? aE : na
                annS = oS ? aS : na
                yaE  = yoy(annE, oBE ? bE : na)
                yaS  = yoy(annS, oBS ? bS : na)
                tip = "Annual roll-up: sum of the 4 quarters reported " + rptDate(array.get(timeArr, lo)) + " → " + rptDate(array.get(timeArr, hi)) + ". %Chg is vs. the prior 4-quarter block."

                row += 1
                table.cell(qt, 0, row, "ANNUAL",      text_color = tTxt, bgcolor = tAnnBg, text_size = tblSize, text_halign = text.align_left, tooltip = tip)
                table.cell(qt, 1, row, fmtEps(annE),  text_color = tTxt, bgcolor = tAnnBg, text_size = tblSize, text_halign = text.align_right)
                table.cell(qt, 2, row, fmtPct(yaE),   text_color = na(yaE) ? tTxt : yaE >= 0 ? tPos : tNeg, bgcolor = tAnnBg, text_size = tblSize, text_halign = text.align_right)
                table.cell(qt, 3, row, fmtMoney(annS),text_color = tTxt, bgcolor = tAnnBg, text_size = tblSize, text_halign = text.align_right)
                table.cell(qt, 4, row, fmtPct(yaS),   text_color = na(yaS) ? tTxt : yaS >= 0 ? tPos : tNeg, bgcolor = tAnnBg, text_size = tblSize, text_halign = text.align_right)
````
