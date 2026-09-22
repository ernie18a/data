<!-- tradingview-pine-id: PUB;3f769e6d782c48b4b44554f45715a0e9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Hyperscaler Total Capex

Source: https://www.tradingview.com/script/Ki2UebzK-Ai-Hyperscaler-Total-Capex/

## Description

[image]https://www.tradingview.com/x/sUQZFAg1/[/image]
Hyperscaler Total Capex
It answers one question:
How much are the big platform companies spending on capital investment, and is that number still growing?
The mechanics:
It takes four configurable ticker symbols - MSFT, GOOGL, AMZN, META by default.
[pine]// ── Inputs ──
s1 = input.symbol("NASDAQ:MSFT", "Company 1", group = "Basket")
s2 = input.symbol("NASDAQ:GOOGL", "Company 2", group = "Basket")
s3 = input.symbol("NASDAQ:AMZN", "Company 3", group = "Basket")
s4 = input.symbol("NASDAQ:META", "Company 4", group = "Basket")[/pine]
It asks TradingView for each one's CAPITAL_EXPENDITURES financial series, converted to USD.
Capex comes through as a negative number (it's cash going out), so it takes the absolute value and divides into billions. 
You get positive USD billions, which reads more naturally as "spending."
For each company it pulls 

[*]The latest reported figure. 
[*]The previous one.
[*]And a year-ago.
On fiscal-quarter mode "year-ago" means four reports back.
It draws the four companies as stacked areas in a separate pane, so the top of the stack is the basket total and each colour band is one company's slice.

A table shows per-company figures, the basket total, year-on-year and quarter-on-quarter growth, data coverage, and a one-word label:

[*]ACCELERATING (>15% YoY). 
[*]EXPANDING (>0%).
[*]or CONTRACTING.
The four companies don't report on the same dates. Naively stacking them means the "total" at any given bar is a mix of stale and fresh numbers, and worse, growth math would treat one company's filing update as if the whole basket had advanced a quarter.
So it matches each company against its own previous and year-ago report before aggregating. When not all four have data, it doesn't substitute zero it suppresses the total, the growth figures, and the plot, and the label reads INCOMPLETE. 
Missing stays missing.
It measures total company capital expenditure. It does not isolate AI or data-centre spending.
Separating that out would need a real allocation model built on company disclosures, which this doesn't attempt. It's a reporting monitor.

Look at it to see whether the disclosed number moved and by how much, then go read the filing.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alex_l_dunstan

//@version=6
indicator("Hyperscaler Total Capex", overlay = false)

// ── How the capex data gets here ──
// 1. request.financial() pulls TradingView's "CAPITAL_EXPENDITURES" cash-flow field for each
//    company, per fiscal quarter (FQ) or fiscal year (FY), converted to USD.
// 2. gaps_on means the request is non-na ONLY on the bar where a new report first appears on
//    this chart. Every other bar is na. That bar is the "report event".
// 3. On each report event we store the value. ta.valuewhen() then gives the latest report, the
//    previous report, and the year-ago report (4 FQ reports back, or 1 FY report back).
// 4. Values are shown as abs() in USD billions. TradingView's sign convention for this field is
//    not verified here, so abs() makes the display independent of it. Verify against filings.
// 5. The basket total is the sum of each company's LATEST report. It steps up or down whenever
//    any one company reports, and companies can be on different fiscal calendars (e.g. MSFT).
// 6. Growth compares each company to its OWN prior reports, then sums, so staggered report
//    dates never get treated as consecutive basket quarters.

// ── Inputs ──
s1 = input.symbol("NASDAQ:MSFT", "Company 1", group = "Basket")
s2 = input.symbol("NASDAQ:GOOGL", "Company 2", group = "Basket")
s3 = input.symbol("NASDAQ:AMZN", "Company 3", group = "Basket")
s4 = input.symbol("NASDAQ:META", "Company 4", group = "Basket")
per = input.string("FQ", "Reporting period", options = ["FQ", "FY"], group = "Data", tooltip = "FQ = fiscal quarter, FY = fiscal year. Year-on-year compares against 4 FQ reports back or 1 FY report back.")
posStr = input.string("top_left", "Table position", options = ["top_left", "top_right", "bottom_left", "bottom_right", "middle_right"], group = "Display")

tblPos = switch posStr
    "top_right" => position.top_right
    "bottom_left" => position.bottom_left
    "bottom_right" => position.bottom_right
    "middle_right" => position.middle_right
    => position.top_left

// Growth above this YoY % is labelled ACCELERATING.
ACCEL_THRESHOLD = 15.0

// Company colours, shared by stacked bands and table labels.
col1 = color.blue
col2 = color.teal
col3 = color.orange
col4 = color.fuchsia

yearlyLookback = per == "FQ" ? 4 : 1

// ── Per-company data ──
// Returns [latest, previous, year-ago] capex in USD billions and the time the latest report
// first appeared on the chart.
f_company(sym) =>
    raw = request.financial(sym, "CAPITAL_EXPENDITURES", per, gaps = barmerge.gaps_on, ignore_invalid_symbol = true, currency = currency.USD)
    isReport = not na(raw)
    capexB = isReport ? math.abs(raw) / 1e9 : na
    latest = ta.valuewhen(isReport, capexB, 0)
    previous = ta.valuewhen(isReport, capexB, 1)
    yearAgo = ta.valuewhen(isReport, capexB, yearlyLookback)
    reportTime = ta.valuewhen(isReport, time, 0)
    [latest, previous, yearAgo, reportTime]

[c1, p1, y1, t1] = f_company(s1)
[c2, p2, y2, t2] = f_company(s2)
[c3, p3, y3, t3] = f_company(s3)
[c4, p4, y4, t4] = f_company(s4)

// ── Basket ──
countValid(a, b, c, d) => (na(a) ? 0 : 1) + (na(b) ? 0 : 1) + (na(c) ? 0 : 1) + (na(d) ? 0 : 1)
pctChange(now, before) => na(now) or na(before) or before == 0 ? na : (now / before - 1) * 100

currentCoverage = countValid(c1, c2, c3, c4)
previousCoverage = countValid(p1, p2, p3, p4)
yearCoverage = countValid(y1, y2, y3, y4)

// Totals and growth are only shown when all four companies have the data; missing never becomes zero.
completeCurrent = currentCoverage == 4
totalB = completeCurrent ? c1 + c2 + c3 + c4 : na
previousTotalB = completeCurrent and previousCoverage == 4 ? p1 + p2 + p3 + p4 : na
yearAgoTotalB = completeCurrent and yearCoverage == 4 ? y1 + y2 + y3 + y4 : na
yoy = pctChange(totalB, yearAgoTotalB)
qoq = per == "FQ" ? pctChange(totalB, previousTotalB) : na

regime = not completeCurrent ? "INCOMPLETE" : na(yoy) ? "NEED MORE HISTORY" : yoy > ACCEL_THRESHOLD ? "ACCELERATING" : yoy > 0 ? "EXPANDING" : "CONTRACTING"
regCol = na(yoy) ? color.gray : yoy > ACCEL_THRESHOLD ? color.green : yoy > 0 ? color.teal : color.red

// ── Stacked bands ──
// Each area is a running total drawn from zero; later plots paint over earlier ones, so the
// visible slice of each colour is that company's own capex.
plot(totalB, "Stack: 1+2+3+4", color = color.new(col4, 15), style = plot.style_area, display = display.pane)
plot(completeCurrent ? c1 + c2 + c3 : na, "Stack: 1+2+3", color = color.new(col3, 15), style = plot.style_area, display = display.pane)
plot(completeCurrent ? c1 + c2 : na, "Stack: 1+2", color = color.new(col2, 15), style = plot.style_area, display = display.pane)
plot(completeCurrent ? c1 : na, "Stack: 1", color = color.new(col1, 15), style = plot.style_area, display = display.pane)

// Real (non-cumulative) values for the status line and Data Window.
plot(c1, "Company 1 capex ($B)", color = col1, display = display.data_window + display.status_line)
plot(c2, "Company 2 capex ($B)", color = col2, display = display.data_window + display.status_line)
plot(c3, "Company 3 capex ($B)", color = col3, display = display.data_window + display.status_line)
plot(c4, "Company 4 capex ($B)", color = col4, display = display.data_window + display.status_line)
plot(totalB, "Total capex ($B)", color = color.white, display = display.data_window + display.status_line)

// ── Table helpers ──
tick(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 0 ? array.get(parts, array.size(parts) - 1) : s
usd(x) => na(x) ? "—" : "$" + str.tostring(x, "#.0") + "B"
pct(x) => na(x) ? "—" : (x >= 0 ? "+" : "") + str.tostring(x, "#.0") + "%"
// int() cast: ta.valuewhen() may hand back a float, which str.format_time() will not accept.
dateStr(t) => na(t) ? "—" : str.format_time(int(t), "yyyy-MM-dd", syminfo.timezone)
growthBg(x) => color.new(na(x) ? color.gray : x >= 0 ? color.green : color.red, 70)

cell(t, c, r, txt, tc, bg, align) => table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = size.small, text_halign = align)

companyRow(t, r, sym, col, latest, yearAgo, reportTime, bg) =>
    cell(t, 0, r, tick(sym), col, bg, text.align_left)
    cell(t, 1, r, usd(latest), color.white, bg, text.align_right)
    yoyCompany = pctChange(latest, yearAgo)
    cell(t, 2, r, pct(yoyCompany), color.white, growthBg(yoyCompany), text.align_right)
    cell(t, 3, r, dateStr(reportTime), color.silver, bg, text.align_right)

// ── Dashboard ──
var table dash = table.new(tblPos, 4, 9, frame_color = color.gray, frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
if barstate.islast
    hb = color.new(regCol, 20)
    gr = color.new(color.gray, 90)
    tb = color.new(color.blue, 60)

    cell(dash, 0, 0, "TOTAL CAPEX / " + per, color.white, hb, text.align_left)
    cell(dash, 1, 0, regime, color.white, hb, text.align_right)
    table.merge_cells(dash, 1, 0, 3, 0)

    cell(dash, 0, 1, "Company", color.silver, gr, text.align_left)
    cell(dash, 1, 1, "Latest", color.silver, gr, text.align_right)
    cell(dash, 2, 1, "YoY", color.silver, gr, text.align_right)
    cell(dash, 3, 1, "Reported", color.silver, gr, text.align_right)

    companyRow(dash, 2, s1, col1, c1, y1, t1, gr)
    companyRow(dash, 3, s2, col2, c2, y2, t2, gr)
    companyRow(dash, 4, s3, col3, c3, y3, t3, gr)
    companyRow(dash, 5, s4, col4, c4, y4, t4, gr)

    cell(dash, 0, 6, "Basket total", color.white, tb, text.align_left)
    cell(dash, 1, 6, usd(totalB), color.white, tb, text.align_right)
    cell(dash, 2, 6, pct(yoy), color.white, growthBg(yoy), text.align_right)
    cell(dash, 3, 6, per == "FQ" ? "QoQ " + pct(qoq) : "QoQ n/a (FY)", color.white, per == "FQ" ? growthBg(qoq) : gr, text.align_right)

    coverageOk = currentCoverage == 4 and yearCoverage == 4
    cell(dash, 0, 7, "Coverage", color.white, gr, text.align_left)
    cell(dash, 1, 7, str.tostring(currentCoverage) + "/4 latest · " + str.tostring(yearCoverage) + "/4 year-ago", color.white, color.new(coverageOk ? color.green : color.orange, 60), text.align_right)
    table.merge_cells(dash, 1, 7, 3, 7)

    cell(dash, 0, 8, "Source: CAPITAL_EXPENDITURES · " + per + " · abs · USD bn · Reported = first bar the figure appeared on this chart", color.gray, gr, text.align_left)
    table.merge_cells(dash, 0, 8, 3, 8)
````
